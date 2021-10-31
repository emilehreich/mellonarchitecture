library ieee;
use ieee.std_logic_1164.all;

entity logic_unit is
    port(
        a  : in  std_logic_vector(31 downto 0);
        b  : in  std_logic_vector(31 downto 0);
        op : in  std_logic_vector(1 downto 0);
        r  : out std_logic_vector(31 downto 0)
    );
end logic_unit;

architecture synth of logic_unit is
    
    signal result : std_logic_vector(31 downto 0);
    
begin
    
    --process that exectutes the logic operation given the op input
    opreation : process(op, a, b)
    begin
        if op = "00" then
            result <= a nor b;
        elsif op = "01" then
            result <= a and b;
        elsif op = "10" then
            result <= a or b;
        elsif op = "11" then
            result <= a xnor b;
        end if;
    end process;
    
    --outputs assignment
    r <= result;
    
                
    
end synth;
