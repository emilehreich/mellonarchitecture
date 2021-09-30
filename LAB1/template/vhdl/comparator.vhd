library ieee;
use ieee.std_logic_1164.all;

entity comparator is
    port(
        a_31    : in  std_logic;
        b_31    : in  std_logic;
        diff_31 : in  std_logic;
        carry   : in  std_logic;
        zero    : in  std_logic;
        op      : in  std_logic_vector(2 downto 0);
        r       : out std_logic
    );
end comparator;

architecture synth of comparator is

  signal s_r : std_logic;

begin

  operation : process (a_31, b_31, diff_31, carry, zero, op)
  begin
    if op = "011" then
      s_r <= not zero;
    elsif op = "100" then
      s_r <= zero;
    elsif op = "101" then
      s_r <= not carry or zero;
    elsif op = "110" then
      s_r <= carry and not zero;
    elsif op = "001" then
      s_r <= (a_31 and not b_31) or ((a_31 xnor b_31) and (diff_31 or zero));
    elsif op = "010" then
      s_r <= (not a_31 and b_31) or ((a_31 xnor b_31) and (not diff_31 and not zero));
    else
      s_r <= zero; --default operation
    end if;
  end process;

  assignment : process(s_r)
  begin
    r <= s_r;
  end process;

end synth;
