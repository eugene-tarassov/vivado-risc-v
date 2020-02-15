library ieee;
use ieee.std_logic_1164.all;

entity synchronizer is
    port (
        clock    : in std_logic;
        dinp     : in std_logic;
        dout     : out std_logic);
end synchronizer;

architecture Behaviour of synchronizer is

    signal shreg : std_logic_vector(2 downto 0);

    -- This property instructs the synthesis tool to infer shift registers.
    attribute SHREG_EXTRACT : string;
    attribute SHREG_EXTRACT of shreg : signal is "no";

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of shreg: signal is "TRUE";
begin
    dout <= shreg(2);
    process (clock)
    begin
        if clock'event and clock = '1' then
            shreg <= shreg(1 downto 0) & dinp;
        end if;
    end process;
end Behaviour;
