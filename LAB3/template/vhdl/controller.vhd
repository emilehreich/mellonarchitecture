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
  Type exec_state is (FETCH1, FETCH2, DECODE, R_OP, STORE, BREAK, LOAD1, LOAD2, I_OP);
  signal current_exec_state, next_state : exec_state;

  --signals for output logic
  signal s_read,
         s_en, s_signed,
         s_ir_en,
         s_sel_b,
         s_sel_rc,
         s_rf_wren,
         s_sel_addr,
         s_sel_mem,
         s_write,
         s_sel_ra,
         s_sel_pc: std_logic;

  signal s_op_alu,
         v_signed  : std_logic_vector(5 downto 0);

begin
  --=======================================================================
  --Finite State Machine
  update_state : process(clk, reset_n)
  begin
    if(reset_n = '0') then
      current_exec_state <= FETCH1;
    elsif (rising_edge(clk)) then
      current_exec_state <= next_state;
    end if;
  end process;

  compute_next_state : process(next_state, current_exec_state)
  begin
    case current_exec_state is
      when FETCH1 =>
        next_state <= FETCH2;
      when FETCH2 =>
        next_state <= DECODE;
      when LOAD1 =>
        next_state <= LOAD2;
      when DECODE =>
        --R_OP
        if (("00"&op) = x"3A") then
          if (("00"&opx) = x"34") then
            next_state <= BREAK;
          else
            next_state <= R_OP;
            v_signed <= opx;
          end if;
        --LOAD1
        elsif (("00"&op) = x"17") then
          next_state <= LOAD1;
          -- s_op_alu <= op;
        --STORE
        elsif (("00"&op) = x"15") then
          next_state <= STORE;
          -- s_op_alu <= op;
        --I_OP
        elsif (("00"&op) = x"04") then
          -- s_op_alu <= op;
          next_state <= I_OP;
          v_signed <= op;

        end if;
      when I_OP =>
        next_state <= FETCH1;
      when R_OP =>
        next_state <= FETCH1;
      when STORE =>
        next_state <= FETCH1;
      when LOAD2 =>
        next_state <= FETCH1;
      when BREAK =>
        next_state <= BREAK;
    end case;
  end process;

  --========================================================================
  --signals assignments
  s_write    <= '1' when current_exec_state = STORE
                    else '0';
  s_read     <= '1' when current_exec_state = FETCH1 or current_exec_state = LOAD1
                    else '0';
  s_en       <= '1' when current_exec_state = FETCH2
                    else '0';
  s_ir_en    <= '1' when current_exec_state = FETCH2
                    else '0';
  s_sel_b    <= '1' when current_exec_state = R_OP
                    else '0';
  s_sel_rc   <= '1' when current_exec_state = R_OP
                    else '0';
  s_rf_wren  <= '1' when current_exec_state = LOAD2 or current_exec_state = R_OP or current_exec_state = I_OP
                    else '0';
  s_sel_addr <= '1' when current_exec_state = LOAD1 or current_exec_state = STORE
                    else '0';
  s_sel_mem  <= '1' when current_exec_state = LOAD2
                    else '0';
  s_signed   <= '1' when current_exec_state = LOAD1 or current_exec_state = STORE or current_exec_state = I_OP
                    else '0';
  s_sel_pc   <= '0' when current_exec_state = R_OP or current_exec_state = I_OP or current_exec_state = LOAD2
                    else '1';
  s_sel_ra   <= '0' when current_exec_state = R_OP or current_exec_state = I_OP or current_exec_state = LOAD2
                    else '1';
  --========================================================================
  --op_alu_generation
  generation : process(op, opx)is
  begin
    if ("00"&op = x"3A") then
      if ("00"&opx = x"0E") then
        s_op_alu <= "100001";
      elsif ("00"&opx = x"1B") then
        s_op_alu <= "110011";
      else
        s_op_alu <= opx;
      end if;
    else
      s_op_alu <= "000000";
    end if;
  end process;
  --========================================================================
  --Output logic

  output_logic : process(s_op_alu, s_signed, s_sel_b, s_sel_rc, s_rf_wren, s_sel_addr, s_sel_mem, s_write, s_read, s_en, s_ir_en, s_sel_pc, s_sel_ra)
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
    branch_op <='0';
    pc_add_imm <='0';
    pc_sel_a   <='0';
    pc_sel_imm <='0';
    sel_pc <= s_sel_pc;
    sel_ra <= s_sel_ra;
  end process;

end synth;
