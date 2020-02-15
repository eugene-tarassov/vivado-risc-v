library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.Vcomponents.all;

entity JtagSeries7 is
generic (
    JTAG_CHAIN : integer := 2);       -- Chain number.
port (
    clock    : in std_logic;
    reset    : in std_logic;
    -- Debug Module interface
    dmi_o_ready  : in std_logic;
    dmi_o_valid  : out std_logic;
    dmi_o_addr   : out std_logic_vector(6 downto 0);
    dmi_o_data   : out std_logic_vector(31 downto 0);
    dmi_o_op     : out std_logic_vector(1 downto 0);
    dmi_i_ready  : out std_logic;
    dmi_i_valid  : in std_logic;
    dmi_i_data   : in std_logic_vector(31 downto 0);
    dmi_i_resp   : in std_logic_vector(1 downto 0));
end JtagSeries7;

architecture Behaviour of JtagSeries7 is

    -- JTAG TCK clock domain

    signal jtag_capture: std_logic;
    signal jtag_dclock : std_logic;
    signal jtag_reset  : std_logic;
    signal jtag_runtest: std_logic;
    signal jtag_select : std_logic;
    signal jtag_shift  : std_logic;
    signal jtag_tck_inp: std_logic;
    signal jtag_tck    : std_logic;
    signal jtag_tdi    : std_logic;
    signal jtag_tms    : std_logic;
    signal jtag_update : std_logic;
    signal jtag_tdo    : std_logic;

    signal dr          : std_logic_vector(39 downto 0);
    signal req         : std_logic;
    signal done        : std_logic;
    signal overrun     : std_logic;
    signal error       : std_logic_vector(1 downto 0);
    signal abort       : std_logic;
    signal rst         : std_logic;
    signal cmd         : std_logic_vector(7 downto 0);
    signal arg         : std_logic_vector(31 downto 0);
    signal res         : std_logic_vector(31 downto 0);
    signal lock        : std_logic := '1';

    signal crc         : std_logic_vector(31 downto 0);
    signal crc_add     : boolean;

    constant ID : std_logic_vector(31 downto 0) := "00000101001100000000000000000000";

    -- Debug Module clock domain

    signal dap_req     : std_logic;
    signal dap_err     : std_logic;
    signal dap_done    : std_logic;
    signal req_done    : std_logic;
    signal dat         : std_logic_vector(31 downto 0);
    signal stb         : std_logic;
    signal err         : std_logic_vector(1 downto 0);
    signal we          : std_logic;

    function calc_crc(c: std_logic_vector; w: std_logic_vector) return std_logic_vector is
        -- 0xBA0DC66B, Koopman, P., "32-bit cyclic redundancy codes for Internet applications"
        constant poly: std_logic_vector(31 downto 0) := "10111010000011011100011001101011";

        variable a: std_logic_vector(c'range);
        variable a0: std_logic;
    begin
        a := c;
        for j in w'reverse_range loop
            a0 := w(j) xor a(a'low);
            a := "0" & a(a'high downto a'low + 1);
            for i in a'reverse_range loop
                if poly(i) = '1' then a(i) := a(i) xor a0; end if;
            end loop;
        end loop;
        return a;
    end calc_crc;

begin

    jtag : BSCANE2
    generic map (
        JTAG_CHAIN => JTAG_CHAIN) -- Chain number.
    port map (
        SEL     => jtag_select,  -- USER instruction has been loaded into the JTAG Instruction Register
        DRCK    => jtag_dclock,  -- Gated version of TCK, it toggles during the CAPTURE-DR and SHIFT-DR states
        RESET   => jtag_reset,   -- TAP controller is in the TEST-LOGIC-RESET state
        RUNTEST => jtag_runtest, -- TAP controller is in Run-Test/Idle state.
        CAPTURE => jtag_capture, -- TAP controller is in the CAPTURE-DR state
        SHIFT   => jtag_shift,   -- TAP controller is in the SHIFT-DR state
        UPDATE  => jtag_update,  -- TAP controller is in the UPDATE-DR state
        TCK     => jtag_tck_inp, -- Mirror of TCK input pin
        TDI     => jtag_tdi,     -- Mirror of TDI input pin
        TMS     => jtag_tms,     -- Mirror of TMS input pin
        TDO     => jtag_tdo);    -- Routed to external JTAG TDO pin

    jtag_tdo <= dr(0);

    tck_buf : BUFG
    port map (
        I => jtag_tck_inp,
        O => jtag_tck);

    process (jtag_tck)
    begin
        if jtag_tck'event and jtag_tck = '1' then
            if jtag_reset = '1' or jtag_select = '0' then
                res <= ID;
                overrun <= '0';
                abort <= '0';
                req <= '0';
                crc <= (others => '0');
                crc_add <= false;
            else
                crc_add <= jtag_capture = '1' or jtag_update = '1';
                if crc_add then crc <= calc_crc(crc, dr); end if;
                if jtag_capture = '1' then
                    if req = '1' or done = '1' then overrun <= '1'; end if;
                    dr <= lock & rst & error & overrun & abort & done & req & res;
                elsif jtag_shift = '1' then
                    dr <= jtag_tdi & dr(39 downto 1);
                elsif jtag_update = '1' then
                    if dr(39 downto 32) = "00000000" then
                        null;
                    elsif dr(39 downto 32) = "11111110" then
                        lock <= dr(0);
                    elsif dr(39 downto 32) = "11111111" then
                        if overrun = '0' and req = '0' then res <= crc; end if;
                        overrun <= '0';
                    elsif dr(39 downto 38) = "11" then
                        null;
                    elsif overrun = '0' and req = '0' and abort = '0' and lock = '0' then
                        req <= '1';
                        cmd <= dr(39 downto 32);
                        arg <= dr(31 downto 0);
                    end if;
                end if;
                if req = '1' and done = '1' then
                    error <= err;
                    if err /= "00" then
                        abort <= '1';
                    end if;
                    res <= dat;
                    req <= '0';
                end if;
            end if;
        end if;
    end process;

    syn_req : entity work.synchronizer
    port map (
        clock => clock,
        dinp  => req,
        dout  => dap_req);

    syn_done : entity work.synchronizer
    port map (
        clock => jtag_tck,
        dinp  => dap_done,
        dout  => done);

    syn_reset : entity work.synchronizer
    port map (
        clock => jtag_tck,
        dinp  => reset,
        dout  => rst);

    dmi_o_valid <= stb and not req_done;
    dmi_o_op <= "10" when we = '1' else "01";
    dmi_i_ready <= '1';

    process (clock)
    begin
        if clock'event and clock = '1' then
            if reset = '1' then
                dat <= (others => '0');
                dap_done <= dap_req;
                req_done <= '0';
                err <= (others => '1');
                stb <= '0';
            elsif dap_done = '1' then
                if dap_req = '0' then
                    dap_done <= '0';
                end if;
            elsif stb = '1' then
                if dmi_i_valid = '1' then
                    if we = '0' then
                        dat <= dmi_i_data;
                    end if;
                    dap_done <= '1';
                    err <= dmi_i_resp;
                    req_done <= '0';
                    stb <= '0';
                elsif dmi_o_ready = '1' and req_done = '0' then
                    req_done <= '1';
                end if;
            elsif dap_req = '1' then
                if cmd(7) = '1' then
                    dat <= arg;
                    dmi_o_addr <= cmd(6 downto 0);
                    dmi_o_data <= arg;
                    stb <= '1';
                    we <= '1';
                else
                    dmi_o_addr <= cmd(6 downto 0);
                    stb <= '1';
                    we <= '0';
                end if;
            end if;
        end if;
    end process;

end Behaviour;
