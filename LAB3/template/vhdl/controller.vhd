library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is

  --signals for output logic
  signal s_read, s_en, s_signed : std_logic;
  signal s_op_alu : std_logic_vector(5 downto 0);


  --flags to move forward in the cycles
  signal flag_FETCH1, flag_FETCH2, flag_DECODE : std_logic;

  

begin

  --========================================================================
  --FETCH1 cycle

  --CHECK DESIGN: independent from clock ???
  FETCH1 : process(reset_n)
  begin
    --asynchronous reset_n
    if(reset_n = '0') then
      s_read <= '1';
      flag_FETCH1 <= '1';
    end if;
  end process;

  --output logic for FETCH1 cycle
  FETCH1_output_logic : process(s_read)
  begin
    read <= s_read;
  end process;

  --========================================================================
  --FETCH2 cycle

  --The process has effects after FETCH1 is done
  FETCH2 : process(clk)
  begin
    if (flag_FETCH1 = '1') then
      if (rising_edge(clk)) then
        s_en <= '1';
        flag_FETCH1 <= '0';
        flag_FETCH2 <= '1';
      end if;
    end if;
  end process;

  --output logic for FETCH1 cycle
  FETCH2_output_logic : process(s_en)
  begin
    pc_en <= s_en;
  end process;
  --========================================================================
  --DECODE cycle

  --reads the opcode
  DECODE : process(clk)
  begin
    if (rising_edge(clk)) then
      if (flag_FETCH2 = '1') then
        flag_FETCH2 <= 0;
        s_op_alu <= op;
        --==============================
        --I_OP
        if (op = "011001" or op = "011010") then
          s_signed <= '1';
        else 
          s_signed <= '0';
        --==============================
        --R_OP

        --TODO
        end if;
      end if;
    end if;
  end process;

  DECODE_output_logic : process(s_op_alu, s_signed)
  begin
    op_alu <= s_op_alu;
    imm_signed <= s_signed;
  end process;

  --========================================================================
  --LOAD

  --TODO
  --========================================================================
  --STORE


  --TODO

  --========================================================================
  --BREAK


  --TODO

end synth;
