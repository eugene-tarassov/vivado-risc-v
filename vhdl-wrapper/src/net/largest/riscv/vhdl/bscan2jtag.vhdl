library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

-- 1. first shift after idle state should be 8-bit number of TAPs in the external scan chain, not including the target TAP.
-- The shift should go through DRUPDATE and end in DRPAUSE state.
--
-- 2. each sequent shift should include:
--         Prefix bits - for TAPs after target
--         Mode bit
--         TDI or TDI/TMS bits
--         Postfix bits - for TAPs before target
-- The shift should end in DRPAUSE state
--
-- Use mode 1 for target DR and mode 0 for everything else - this substantially improves performance.
--
-- A second shift is needed to capture last bits of TDO (when TDO is needed):
--         Prefix bits - for TAPs after target
--         Mode bit - ignored
-- The shift should end in DRPAUSE state.
-- This shift pushes out TDO bits, which otherwise would stack in the chain.
-- The shift does not affect the target, because the shift stops before reaching TDI/TMS phase.
--
-- This sequence repeated until there is nothing to shift, e.g. no more DAP commands in the debugger queue.
--
-- 3. when the driver done with current block of shifts, it moves external JTAG state to IDLE, which puts bscan2jtag back to idle state.

entity bscan2jtag is
    generic (
        enable_tck_bufg : in boolean := true);
    port (
        S_BSCAN_bscanid_en  : in std_logic;
        S_BSCAN_capture     : in std_logic;
        S_BSCAN_drck        : in std_logic;
        S_BSCAN_reset       : in std_logic;
        S_BSCAN_runtest     : in std_logic;
        S_BSCAN_sel         : in std_logic;
        S_BSCAN_shift       : in std_logic;
        S_BSCAN_tck         : in std_logic;
        S_BSCAN_tdi         : in std_logic;
        S_BSCAN_tdo         : out std_logic;
        S_BSCAN_tms         : in std_logic;
        S_BSCAN_update      : in std_logic;

        jtag_tdo : in std_logic;
        jtag_tdi : out std_logic;
        jtag_tms : out std_logic;
        jtag_tck : out std_logic;
        jtag_tdt : in std_logic);
end bscan2jtag;

architecture Behavioral of bscan2jtag is
    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_INFO OF S_BSCAN_update: SIGNAL IS "xilinx.com:interface:bscan:1.0 S_BSCAN UPDATE";
    ATTRIBUTE X_INTERFACE_INFO OF S_BSCAN_tms: SIGNAL IS "xilinx.com:interface:bscan:1.0 S_BSCAN TMS";
    ATTRIBUTE X_INTERFACE_INFO OF S_BSCAN_tdo: SIGNAL IS "xilinx.com:interface:bscan:1.0 S_BSCAN TDO";
    ATTRIBUTE X_INTERFACE_INFO OF S_BSCAN_tdi: SIGNAL IS "xilinx.com:interface:bscan:1.0 S_BSCAN TDI";
    ATTRIBUTE X_INTERFACE_INFO OF S_BSCAN_tck: SIGNAL IS "xilinx.com:interface:bscan:1.0 S_BSCAN TCK";
    ATTRIBUTE X_INTERFACE_INFO OF S_BSCAN_shift: SIGNAL IS "xilinx.com:interface:bscan:1.0 S_BSCAN SHIFT";
    ATTRIBUTE X_INTERFACE_INFO OF S_BSCAN_sel: SIGNAL IS "xilinx.com:interface:bscan:1.0 S_BSCAN SEL";
    ATTRIBUTE X_INTERFACE_INFO OF S_BSCAN_runtest: SIGNAL IS "xilinx.com:interface:bscan:1.0 S_BSCAN RUNTEST";
    ATTRIBUTE X_INTERFACE_INFO OF S_BSCAN_reset: SIGNAL IS "xilinx.com:interface:bscan:1.0 S_BSCAN RESET";
    ATTRIBUTE X_INTERFACE_INFO OF S_BSCAN_drck: SIGNAL IS "xilinx.com:interface:bscan:1.0 S_BSCAN DRCK";
    ATTRIBUTE X_INTERFACE_INFO OF S_BSCAN_capture: SIGNAL IS "xilinx.com:interface:bscan:1.0 S_BSCAN CAPTURE";
    ATTRIBUTE X_INTERFACE_INFO OF S_BSCAN_bscanid_en: SIGNAL IS "xilinx.com:interface:bscan:1.0 S_BSCAN BSCANID_EN";

    ATTRIBUTE X_INTERFACE_INFO of jtag_tck: SIGNAL is "xilinx.com:interface:jtag:1.0 JTAG TCK";
    ATTRIBUTE X_INTERFACE_INFO of jtag_tms: SIGNAL is "xilinx.com:interface:jtag:1.0 JTAG TMS";
    ATTRIBUTE X_INTERFACE_INFO of jtag_tdi: SIGNAL is "xilinx.com:interface:jtag:1.0 JTAG TD_I";
    ATTRIBUTE X_INTERFACE_INFO of jtag_tdo: SIGNAL is "xilinx.com:interface:jtag:1.0 JTAG TD_O";
    ATTRIBUTE X_INTERFACE_INFO of jtag_tdt: SIGNAL is "xilinx.com:interface:jtag:1.0 JTAG TD_T";

    signal tap_cnt    : std_logic_vector(7 downto 0);
    signal tap_cnt_ok : std_logic;
    signal bit_cnt    : std_logic_vector(7 downto 0);
    signal mode_reg   : std_logic;
    signal tms_reg    : std_logic;
    signal tms_ok     : std_logic;

    subtype bit_cnt_type is integer range 0 to 31;
    signal id_cnt     : bit_cnt_type;

    constant id_reg   : std_logic_vector(31 downto 0) := "00000100100100000000011000000001"; -- 0x04900601
    signal id_tdo     : std_logic;

begin

    tck_buf_1 : if enable_tck_bufg generate
        tck_buf : BUFGCTRL
        generic map (
            INIT_OUT => 1,
            PRESELECT_I0 => FALSE,
            PRESELECT_I1 => FALSE,
            IS_S0_INVERTED => '1',
            IS_S1_INVERTED => '0'
        )
        port map (
            CE0 => '1',
            CE1 => '1',
            IGNORE0 => '1',
            IGNORE1 => '1',
            S0 => tms_ok,
            S1 => tms_ok,
            I0 => '1',
            I1 => S_BSCAN_tck,
            O => jtag_tck
        );
    end generate tck_buf_1;
    tck_buf_2 : if not enable_tck_bufg generate
        -- Note: it is not recommended to have LUT cells on the clock path
        -- enable_tck_bufg=true is preffered
        jtag_tck <= S_BSCAN_tck or not tms_ok;
    end generate tck_buf_2;

    jtag_tdi <= S_BSCAN_tdi;
    S_BSCAN_tdo <= id_tdo when S_BSCAN_bscanid_en = '1' else jtag_tdo;

    jtag_ctrl : process (S_BSCAN_tck)
    begin
        if S_BSCAN_tck'event and S_BSCAN_tck = '1' then
            if S_BSCAN_reset = '1' then
                tap_cnt_ok <= '0';
            elsif S_BSCAN_update = '1' and S_BSCAN_sel = '1' then
                tap_cnt_ok <= '1';
            end if;
            if S_BSCAN_bscanid_en = '0' then
                id_tdo <= '0';
                id_cnt <= 0;
            else
                id_tdo <= id_reg(id_cnt);
                id_cnt <= id_cnt + 1;
            end if;
            if S_BSCAN_capture = '1' or S_BSCAN_update = '1' then
                bit_cnt <= (others => '0');
                mode_reg <= '0';
                tms_reg <= '0';
                tms_ok <= '0';
            elsif S_BSCAN_shift = '1' and S_BSCAN_sel = '1' then
                if tap_cnt_ok = '0' then
                    -- in the first DR shift after reset, host sets total number of TAPs in the JTAG chain - 1
                    -- if this is the only TAP in the cahin, tap_cnt shoud be 0
                    tap_cnt <= S_BSCAN_tdi & tap_cnt(tap_cnt'high downto 1);
                elsif S_BSCAN_tms = '1' then
                    -- if exiting Shift DR state, clear shift state
                    bit_cnt <= (others => '0');
                    mode_reg <= '0';
                    tms_reg <= '0';
                    tms_ok <= '0';
                elsif bit_cnt < tap_cnt then
                    -- if JTAG chain contains other TAPs, skip bypass bits
                    bit_cnt <= bit_cnt + 1;
                elsif bit_cnt = tap_cnt then
                    bit_cnt <= bit_cnt + 1;
                    -- the first shifted bit is mode bit:
                    --   0: host sends pairs of TMS + TDI bits
                    --   1: host sends TDI bits only, TMS = 0
                    if S_BSCAN_tdi = '1' then
                        mode_reg <= '1';
                        tms_ok <= '1';
                    end if;
                elsif mode_reg = '0' then
                    if tms_ok = '0' then
                        tms_reg <= S_BSCAN_tdi;
                    end if;
                    tms_ok <= not tms_ok;
                end if;
            end if;
        end if;
        if S_BSCAN_tck'event and S_BSCAN_tck = '0' then
            jtag_tms <= tms_reg;
        end if;
    end process;

end Behavioral;
