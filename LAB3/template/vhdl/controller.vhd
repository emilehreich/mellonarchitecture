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

  --Finite State Machine
  Type exec_state is (FETCH1, FETCH2, DECODE);
  signal current_exec_state, next_state : exec_state;

  --signals for output logic
  signal s_read, s_en, s_signed, s_ir_en, s_sel_b, s_sel_rc, s_rf_wren, s_sel_addr, s_sel_mem, s_write: std_logic;
  signal s_op_alu : std_logic_vector(5 downto 0);

  --flags to move forward in the cycles
  signal flag_FETCH1, flag_LOAD2, flag_cycle_done : std_logic;

begin
  --=======================================================================
  --Finite State Machine
  update_state : process(clk, reset_n)
  begin
    if(reset_n = '1') then
      current_exec_state <= FETCH1;
    elsif (rising_edge(clk) and flag_cycle_done = '1') then
      -- case current_exec_state is
      --   when FETCH1 => current_exec_state <= FETCH2;
      --   when FETCH2 => current_exec_state <= DECODE;
      --   when DECODE => current_exec_state <= FETCH2;
      current_exec_state <= next_state;
    end if;
  end process;

  compute_next_state : process(next_state, current_exec_state)
  begin
    case current_exec_state is
      when FETCH1 => next_state <= FETCH2;
      when FETCH2 => next_state <= DECODE;
      when DECODE => next_state <= FETCH1;
    end case;
  end process;

  --========================================================================
  --FETCH1 cycle

  --CHECK DESIGN: independent from clock ???
  FETCH1_cycle : process(clk, reset_n)
  begin
    --asynchronous reset_n
    if(reset_n = '0') then
      s_read <= '1';

      --=====================
      --initialization
      s_write <= '0';
      s_en <= '0';
      s_signed <= '0';
      s_ir_en <= '0';
      s_sel_b <= '0';
      s_sel_rc <= '0';
      s_rf_wren <= '0';
      s_sel_addr <= '0';
      s_sel_mem <= '0';
      flag_cycle_done <='0';
      --=====================

      -- current_exec_state <= FETCH1;
      flag_FETCH1 <= '1';
    elsif (rising_edge(clk)) then
      if (current_exec_state = FETCH1 and flag_FETCH1='1') then
        -- current_exec_state <= FETCH2;
        flag_cycle_done <= '1';
        flag_FETCH1 <='0';
      end if;
    end if;
  end process;

  -- --output logic for FETCH1 cycle
  -- FETCH1_output_logic : process(s_read)
  -- begin
  --   read <= s_read;
  -- end process;

  --========================================================================
  --FETCH2 cycle

  --The process has effects after FETCH1 is done
  FETCH2_cycle : process(clk)
  begin
    if (rising_edge(clk)) then
      if (current_exec_state = FETCH2) then
          s_read <= '0';
          s_en <= '1';
          s_ir_en <= '1';
          -- current_exec_state <= DECODE;
          flag_cycle_done <= '1';
      end if;
    end if;
  end process;

  --output logic for FETCH1 cycle
  -- FETCH2_output_logic : process(s_en, s_ir_en)
  -- begin
  --   pc_en <= s_en;
  --   ir_en <= s_ir_en;
  -- end process;
  --========================================================================
  --DECODE cycle

  --reads the opcode
  DECODE_cycle : process(clk)
    variable v_signed : std_logic_vector(5 downto 0);
  begin
    if (rising_edge(clk)) then
      if (current_exec_state = DECODE) then
        --Decoding
        --===================================================
        --R_OP
        if(("00"&op) = x"3A") then
          s_sel_b <= '1';
          s_sel_rc <= '1';
          s_op_alu <= opx;
          v_signed := opx;
          -- current_exec_state <= FETCH1;
          flag_cycle_done <= '1';
        --===================================================
        -- LOAD
        elsif (("00"&op) = x"17") then
          --LOAD 2
          if (flag_LOAD2 = '1') then
            s_rf_wren <= '1';
            s_sel_mem <= '1';
            flag_LOAD2 <= '0';
            -- current_exec_state <= FETCH1;
            flag_cycle_done <= '1';
          --LOAD 1
          else
            s_read <= '1';
            s_sel_addr <= '1';
            flag_LOAD2 <= '1';
          end if;
        --===================================================
        --STORE
        elsif (("00"&op) = x"15") then
          s_read <= '0';
          s_write <= '1';
          s_sel_b <= '0';

          s_rf_wren <= '0';
          s_sel_mem <= '0';

          -- current_exec_state <= FETCH1;
          flag_cycle_done <= '1';
        --===================================================
        --BREAK
        elsif (("00"&opx) = x"34") then
          -- toComplete
        --===================================================
        -- I_OP
        else
          s_rf_wren <= '1';
          s_sel_b <= '0';
          s_sel_rc <= '0';
          s_op_alu <= op;
          v_signed := op;
          -- current_exec_state <= FETCH1;
          flag_cycle_done <= '1';
        end if;
        --===================================================
        -- signed
        if (v_signed = "011001" or v_signed = "011010") then
          s_signed <= '1';
        else
          s_signed <= '0';
        end if;
      end if;
    end if;
  end process;

  DECODE_output_logic : process(s_op_alu, s_signed, s_sel_b, s_sel_rc, s_rf_wren, s_sel_addr, s_sel_mem, s_write, s_read, s_en, s_ir_en)
  begin
    op_alu <= s_op_alu;
    imm_signed <= s_signed;
    sel_b <= s_sel_b;
    sel_rC <= s_sel_rc;
    rf_wren <= s_rf_wren;
    sel_addr <= s_sel_addr;
    sel_mem <= s_sel_mem;
    write <= s_write;
    read <= s_read;
    pc_en <= s_en;
    ir_en <= s_ir_en;
  end process;


end synth;
