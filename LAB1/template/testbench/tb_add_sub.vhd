-- test bench for the adder / subtractor
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_add_sub is
end tb_add_sub;

architecture sim of tb_add_sub is

  -- signal declaration
  signal s_a, s_b : std_logic_vector(31 DOWNTO 0);
  signal s_mode, s_carry_out, s_zero : std_logic_vector;
  signal s_result : std_logic_vector(31 DOWNTO 0);

  begin

  -- import component to test
  adder : entity work.add_sub
    port map(
      a => s_a;
      b => s_b;
      sub_mode => s_mode;
      zero => s_zero;
      carry => s_carry_out;
      r => s_result);


  sim : process is
    -- testing procedure
    procedure check_add(a, b, operator) is
        signal s_inputA : std_logic_vector(31 downto 0);
        signal s_inputB : std_logic_vector(31 downto 0);
        begin
          -- input the operation choice
          s_mode <= operator;

          -- transform the numbers and input them
          s_input_A <= std_logic_vector(to_signed(a, 31 donwto 0));
          s_input_B <= std_logic_vector(to_signed(b, 31 donwto 0));

          -- verify the result
          -- comparison on s_zero
          -- comparison on s_
          s_zero;

          assert false
            report "result :" & unsigned(s_zero);
            severity ;

          if operator = '1' then
            -- substraction
            assert false
              report "result :" & unsigned(s_zero);
              severity warning;
          else
            -- addition
            assert false
              report "error encoutered for substraction"
              severity warning;
          end if;

          -- wait for a short time and output result
          wait for 20ns;
    end procedure check_result;

    begin
    -- max value for a 32 bits :
    -- min value for a 32 bits :

    -- check the addition
    check_add(1, 2, '0');

    -- check the substractions
    check_add(1, 2, '1');

    -- end of the test bench, undefined wait
    wait;
  end process sim;


end architecture sim;
