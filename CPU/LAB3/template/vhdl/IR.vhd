library ieee;
use ieee.std_logic_1164.all;

entity IR is
    port(
        clk    : in  std_logic;
        enable : in  std_logic;
        D      : in  std_logic_vector(31 downto 0);
        Q      : out std_logic_vector(31 downto 0)
    );
end IR;

architecture synth of IR is

  signal s_register : std_logic_vector(31 downto 0);

begin

  writeNext : process(clk, enable)
  begin
    if (rising_edge(clk) and enable='1') then
          s_register <= D;
    end if;
  end process;

  output : process(s_register)
  begin
    Q <= s_register;
  end process;
end synth;
