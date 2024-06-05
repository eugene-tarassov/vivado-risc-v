library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity bscan is
    generic (
        JTAG_CHAIN : in integer := 2);
    port (
        M_BSCAN_bscanid_en  : out std_logic;
        M_BSCAN_capture     : out std_logic;
        M_BSCAN_drck        : out std_logic;
        M_BSCAN_reset       : out std_logic;
        M_BSCAN_runtest     : out std_logic;
        M_BSCAN_sel         : out std_logic;
        M_BSCAN_shift       : out std_logic;
        M_BSCAN_tck         : out std_logic;
        M_BSCAN_tdi         : out std_logic;
        M_BSCAN_tdo         : in std_logic;
        M_BSCAN_tms         : out std_logic;
        M_BSCAN_update      : out std_logic);
end bscan;

architecture Behavioral of bscan is
    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_INFO OF M_BSCAN_update: SIGNAL IS "xilinx.com:interface:bscan:1.0 M_BSCAN UPDATE";
    ATTRIBUTE X_INTERFACE_INFO OF M_BSCAN_tms: SIGNAL IS "xilinx.com:interface:bscan:1.0 M_BSCAN TMS";
    ATTRIBUTE X_INTERFACE_INFO OF M_BSCAN_tdo: SIGNAL IS "xilinx.com:interface:bscan:1.0 M_BSCAN TDO";
    ATTRIBUTE X_INTERFACE_INFO OF M_BSCAN_tdi: SIGNAL IS "xilinx.com:interface:bscan:1.0 M_BSCAN TDI";
    ATTRIBUTE X_INTERFACE_INFO OF M_BSCAN_tck: SIGNAL IS "xilinx.com:interface:bscan:1.0 M_BSCAN TCK";
    ATTRIBUTE X_INTERFACE_INFO OF M_BSCAN_shift: SIGNAL IS "xilinx.com:interface:bscan:1.0 M_BSCAN SHIFT";
    ATTRIBUTE X_INTERFACE_INFO OF M_BSCAN_sel: SIGNAL IS "xilinx.com:interface:bscan:1.0 M_BSCAN SEL";
    ATTRIBUTE X_INTERFACE_INFO OF M_BSCAN_runtest: SIGNAL IS "xilinx.com:interface:bscan:1.0 M_BSCAN RUNTEST";
    ATTRIBUTE X_INTERFACE_INFO OF M_BSCAN_reset: SIGNAL IS "xilinx.com:interface:bscan:1.0 M_BSCAN RESET";
    ATTRIBUTE X_INTERFACE_INFO OF M_BSCAN_drck: SIGNAL IS "xilinx.com:interface:bscan:1.0 M_BSCAN DRCK";
    ATTRIBUTE X_INTERFACE_INFO OF M_BSCAN_capture: SIGNAL IS "xilinx.com:interface:bscan:1.0 M_BSCAN CAPTURE";
    ATTRIBUTE X_INTERFACE_INFO OF M_BSCAN_bscanid_en: SIGNAL IS "xilinx.com:interface:bscan:1.0 M_BSCAN BSCANID_EN";

begin

    M_BSCAN_bscanid_en <= '0';

    BSCANE2_inst : BSCANE2
    generic map (
      JTAG_CHAIN => JTAG_CHAIN    -- Value for USER command.
    )
    port map (
      CAPTURE => M_BSCAN_capture, -- 1-bit output: CAPTURE output from TAP controller.
      DRCK => M_BSCAN_drck,       -- 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or SHIFT are asserted.
      RESET => M_BSCAN_reset,     -- 1-bit output: Reset output for TAP controller.
      RUNTEST => M_BSCAN_runtest, -- 1-bit output: Output asserted when TAP controller is in Run Test/Idle state.
      SEL => M_BSCAN_sel,         -- 1-bit output: USER instruction active output.
      SHIFT => M_BSCAN_shift,     -- 1-bit output: SHIFT output from TAP controller.
      TCK => M_BSCAN_tck,         -- 1-bit output: Test Clock output. Fabric connection to TAP Clock pin.
      TDI => M_BSCAN_tdi,         -- 1-bit output: Test Data Input (TDI) output from TAP controller.
      TMS => M_BSCAN_tms,         -- 1-bit output: Test Mode Select output. Fabric connection to TAP.
      UPDATE => M_BSCAN_update,   -- 1-bit output: UPDATE output from TAP controller
      TDO => M_BSCAN_tdo          -- 1-bit input: Test Data Output (TDO) input for USER function.
    );

end Behavioral;
