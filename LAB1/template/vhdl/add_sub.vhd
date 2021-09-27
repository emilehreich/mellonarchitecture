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
    signal SUB : std_logic_vector(31 downto 0);
    signal s_result : std_logic_vector(32 downto 0); --33 bits to get the carry out
    signal s_zero : std_logic;
    signal s_b : std_logic_vector(31 downto 0);


begin
    
    operation : process(a, b, sub_mode)
    begin
        SUB <= (others => sub_mode);
        s_b <= SUB xor b;

        s_result <= std_logic_vector(to_unsigned(s_b) + to_unsigned(a) + to_unsigned(sub_mode));

    end process;

    s_zero <= '1' WHEN s_result(31 downto 0) = x"0000" else '0';
    zero <= s_zero;

    r <= s_result(31 downto 0);
    carry <= s_result(32);

end synth;
