library ieee;
use ieee.std_logic_1164.all;

entity tb_logic_unit is
end tb_logic_unit;

architecture testbench of tb_logic_unit is
    signal a, b, r : std_logic_vector(31 downto 0);
    signal op      : std_logic_vector(1 downto 0);

    -- declaration of the logic_unit interface
    component logic_unit is
        port(
            a  : in  std_logic_vector(31 downto 0);
            b  : in  std_logic_vector(31 downto 0);
            op : in  std_logic_vector(1 downto 0);
            r  : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    -- logic unit instance
    logic_unit_0 : logic_unit port map(
            a  => a,
            b  => b,
            op => op,
            r  => r
        );

    -- process for verification of the logic unit
    check : process
    begin
        -- This is the 4 possible 2 bits combinaisons between A and B
        a <= (31 downto 4 => '0') & "1100";
        b <= (31 downto 4 => '0') & "1010";

        -- A NOR B
        -- assign the correct value to op to test A NOR B
        op <= "00";
        wait for 20 ns;                 -- wait for circuit to settle
        assert r(3 downto 0) = "0001" -- Should be true
          report "Incorrect NOR Behavior" -- Message to display
          severity warning;

        -- A AND B
        op <= "01";
        -- assign the correct value to op to test A AND B
        wait for 20 ns;                 -- wait for circuit to settle
        assert r(3 downto 0) = "1000" -- Should be true
          report "Incorrect OR Behavior" -- Message to display
          severity warning;

        -- A OR B
        op <= "10";
        -- assign the correct value to op to test A OR B
        wait for 20 ns;                 -- wait for circuit to settle
        assert r(3 downto 0) = "1110" -- Should be true
          report "Incorrect OR Behavior" -- Message to display
          severity warning;

        -- A XNOR B
        op <= "11";
        -- assign the correct value to op to test A XNOR B
        wait for 20 ns;                 -- wait for circuit to settle
        assert r(3 downto 0) = "1001" -- Should be true
          report "Incorrect OR Behavior" -- Message to display
          severity warning;

        assert r(3 downto 0) = "1101" -- Should be true
            report "Incorrect OR Behavior" -- Message to display
            severity warning;
        wait;                           -- wait forever
    end process;

end testbench;
