library ieee;
use ieee.std_logic_1164.all;

entity multiplexer is
    port(
        i0  : in  std_logic_vector(31 downto 0);
        i1  : in  std_logic_vector(31 downto 0);
        i2  : in  std_logic_vector(31 downto 0);
        i3  : in  std_logic_vector(31 downto 0);
        sel : in  std_logic_vector(1 downto 0);
        o   : out std_logic_vector(31 downto 0)
    );
end multiplexer;

architecture synth of multiplexer is
begin

    output_result : process(sel, i0, i1, i2, i3)
    BEGIN
      Case sel is
         When "00" => o <= i0;
         When "01" => o <= i1;
         When "10" => o <= i2;
         When "11" => o <= i3;
         -- defaut output value, choosed arbitrarely
         -- to be a 32bits 0
         When OTHERS => o <= (OTHERS => '0');
      End case;
    end process output_result;

end synth;
