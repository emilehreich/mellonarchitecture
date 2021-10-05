library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
    port(
        address : in  std_logic_vector(15 downto 0);
        cs_LEDS : out std_logic;
        cs_RAM  : out std_logic;
        cs_ROM  : out std_logic
    );
end decoder;

architecture synth of decoder is

    signal s_cs_ram, s_cs_rom, s_cs_led : std_logic;

begin

  --decodes the inputed address
  eval : process(address)
  begin

    if unsigned(address) <= unsigned(to_stdlogicvector(x"0FFC")) then
      s_cs_rom <= '1';
      s_cs_led <= '0';
      s_cs_ram <= '0';
    elsif unsigned(address) <= unsigned(to_stdlogicvector(x"1FFC")) and unsigned(address) >= unsigned(to_stdlogicvector(x"1000")) then
      s_cs_rom <= '0';
      s_cs_led <= '0';
      s_cs_ram <= '1';
    elsif  unsigned(address) <= unsigned(to_stdlogicvector(x"2000")) and unsigned(address) >= unsigned(to_stdlogicvector(x"200C")) then
      s_cs_rom <= '0';
      s_cs_led <= '1';
      s_cs_ram <= '0';
    else
      s_cs_rom <= '0';
      s_cs_led <= '0';
      s_cs_ram <= '0';
    end if;
  end process;

  --output logic
  assignment : process(s_cs_led, s_cs_ram, s_cs_rom)
  begin
    cs_RAM <= s_cs_ram;
    cs_ROM <= s_cs_rom;
    cs_LEDS <= s_cs_led;
  end process;

end synth;
