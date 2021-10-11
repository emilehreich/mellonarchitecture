library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is

    --signals
    signal mask : std_logic_vector(31 downto 0);
    signal s_result : std_logic_vector(32 downto 0); --33 bits to get the carry out
    signal s_b, s_a, s_subMode : std_logic_vector(32 downto 0);

begin

    operation : process(a, b, sub_mode, mask, s_b, s_subMode, s_a)
    begin
        -- compute inverse of b in case of substraction
        mask <= (others => sub_mode);
        s_b <= ('0'&(mask xor b));
        -- prepare data for addition
        -- 'a' -> 33 bits
        s_a <= ('0'&a);
        s_subMode <= (32 downto 1 => '0', others => sub_mode); --'1' or '0' in 33 bits
        -- compute operation
        s_result <= std_logic_vector(unsigned(s_b) + unsigned(s_a) + unsigned(s_subMode));
    end process;

    assignment : process(s_result)
    begin
      if (s_result(31 downto 0) = x"00000000") then
        zero <= '1';
      else
        zero <= '0';
      end if;
        r <= s_result(31 downto 0);
        carry <= s_result(32);
    end process;
    --zero <= '1' WHEN s_result(31 downto 0) = x"0000" else '0';
    -- r <= s_result(31 downto 0);
    -- carry <= s_result(32);
end synth;
