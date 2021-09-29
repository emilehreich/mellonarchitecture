-- test bench for the adder / subtractor
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_add_sub is
end tb_add_sub;

architecture sim of tb_add_sub is

  -- signal declaration
  signal s_a, s_b : std_logic_vector(31 DOWNTO 0);
  signal s_mode, s_carry_out, s_zero : std_logic;
  signal s_result : std_logic_vector(31 DOWNTO 0);

  begin

  -- import component to test
  adder : entity work.add_sub
    port map(
      a => s_a,
      b => s_b,
      sub_mode => s_mode,
      zero => s_zero,
      carry => s_carry_out,
      r => s_result);


  sim : process is
    -- testing procedure
    procedure check_result(a : in natural; b : in natural; operator : in std_logic) is
          variable res : natural;
          begin
            -- input the operation choice
            s_mode <= operator;
            -- transform the numbers and input them
            s_a <= std_logic_vector(to_signed(a, 32));
            s_b <= std_logic_vector(to_signed(b, 32));

            assert false
                report "================TEST================"
            severity note;
            res := to_integer(unsigned(s_result));
            -- wait for a short time and output result
            wait for 20 ns;
            if operator = '1' then

              -- substraction
              assert false
                report "addition : " --& std_logic_vector'image(s_result)
              severity note;
            else
              -- addition
              assert false
                report "substarction : " --& std_logic_vector'image(s_result)
              severity note;
            end if;
      end procedure check_result;
    begin

    -- check the addition
    check_result(1, 2, '0');

    -- check the substractions
    check_result(1, 2, '1');

    -- end of the test bench, undefined wait
    wait;
  end process sim;


end architecture sim;
