---------------------------------------------------------------------------
-- single_cycle_core.vhd - A Single-Cycle Processor Implementation
--
-- Notes : 
--
-- See single_cycle_core.pdf for the block diagram of this single
-- cycle processor core.
--
-- Instruction Set Architecture (ISA) for the single-cycle-core:
--   Each instruction is 16-bit wide, with four 4-bit fields.
--
--     noop      
--        # no operation or to signal end of program
--        # format:  | opcode = 0 |  0   |  0   |   0    | 
--
--     load  rt, rs, offset     
--        # load data at memory location (rs + offset) into rt
--        # format:  | opcode = 1 |  rs  |  rt  | offset |
--
--     store rt, rs, offset
--        # store data rt into memory location (rs + offset)
--        # format:  | opcode = 3 |  rs  |  rt  | offset |
--
--     add   rd, rs, rt
--        # rd <- rs + rt
--        # format:  | opcode = 8 |  rs  |  rt  |   rd   |
--
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
--
-- The single-cycle processor core is provided AS IS, with no warranty of 
-- any kind, express or implied. The user of the program accepts full 
-- responsibility for the application of the program and the use of any 
-- results. This work may be downloaded, compiled, executed, copied, and 
-- modified solely for nonprofit, educational, noncommercial research, and 
-- noncommercial scholarship purposes provided that this notice in its 
-- entirety accompanies all copies. Copies of the modified software can be 
-- delivered to persons who use it solely for nonprofit, educational, 
-- noncommercial research, and noncommercial scholarship purposes provided 
-- that this notice in its entirety accompanies all copies.
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity single_cycle_core is
    port ( reset  : in  std_logic;
           clk    : in  std_logic;
           w_req  : out std_logic;
           r_req  : out std_logic;
           w_en   : out std_logic;
           r_en   : out std_logic;
           w_b_addr : out std_logic;
           r_b_addr : out std_logic;
           core_num :in std_logic_vector(15 downto 0));
end single_cycle_core;

architecture structural of single_cycle_core is

component program_counter is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           refresh  : in  std_logic;
           stall    : in  std_logic;
           addr_in  : in  std_logic_vector(11 downto 0);
           addr_out : out std_logic_vector(11 downto 0) );
end component;

component instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           stall    : in  std_logic;
           addr_in  : in  std_logic_vector(11 downto 0);
           insn_out : out std_logic_vector(15 downto 0);
           insn_out_raw : out std_logic_vector(15 downto 0)           );
end component;

component sign_extend_4to16 is
    port ( data_in  : in  std_logic_vector(3 downto 0);
           data_out : out std_logic_vector(15 downto 0) );
end component;

component sign_extend_4to12 is
    port ( data_in  : in  std_logic_vector(3 downto 0);
           data_out : out std_logic_vector(11 downto 0) );
end component;

component mux_2to1_4b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(3 downto 0);
           data_b     : in  std_logic_vector(3 downto 0);
           data_out   : out std_logic_vector(3 downto 0) );
end component;

component mux_2to1_12b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(11 downto 0);
           data_b     : in  std_logic_vector(11 downto 0);
           data_out   : out std_logic_vector(11 downto 0) );
end component;

component mux_2to1_16b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(15 downto 0);
           data_b     : in  std_logic_vector(15 downto 0);
           data_out   : out std_logic_vector(15 downto 0) );
end component;

component control_unit is
    port ( opcode     : in  std_logic_vector(3 downto 0);
           reg_dst    : out std_logic;
           reg_write  : out std_logic;
           alu_src    : out std_logic;
           alu_op	  : out std_logic_vector(2 downto 0);
           mem_write  : out std_logic;
           do_jmp     : out std_logic;
           do_not_jmp : out std_logic;
           do_slt     : out std_logic;
           byte_addr  : out std_logic;
           b_type     : out std_logic;
           b_insn     : out std_logic;
           mem_read   : out std_logic;
           do_branch  : in  std_logic;
           do_pc_offset : out std_logic;
           mem_to_reg : out std_logic );
end component;

component register_file is
    port ( reset           : in  std_logic;
           clk             : in  std_logic;
           read_register_a : in  std_logic_vector(3 downto 0);
           read_register_b : in  std_logic_vector(3 downto 0);
           write_enable    : in  std_logic;
           write_register  : in  std_logic_vector(3 downto 0);
           write_data      : in  std_logic_vector(15 downto 0);
           read_data_a     : out std_logic_vector(15 downto 0);
           read_data_b     : out std_logic_vector(15 downto 0) );
end component;

component adder_4b is
    port ( src_a     : in  std_logic_vector(3 downto 0);
           src_b     : in  std_logic_vector(3 downto 0);
           sum       : out std_logic_vector(3 downto 0);
           carry_out : out std_logic );
end component;

component alu_16b is
    port ( src_a     : in  std_logic_vector(15 downto 0);
           src_b     : in  std_logic_vector(15 downto 0);
           alu_out   : out std_logic_vector(15 downto 0);
           alu_op	 : in  std_logic_vector(2 downto 0);
           do_slt    : in  std_logic;
           carry_out : out std_logic );
end component;

component data_memory is
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           write_enable : in  std_logic;
           read_enable  : in  std_logic;
           write_data   : in  std_logic_vector(15 downto 0);
           byte_addr	   : in  std_logic;
           addr_in      : in  std_logic_vector(11 downto 0);
           data_out     : out std_logic_vector(15 downto 0) );
end component;

component branch_cmp is
    port ( b_type       : in  std_logic; -- 1 for beq
           b_insn       : in  std_logic; -- 1 for b instruction
           src_a        : in  std_logic_vector(15 downto 0);
           src_b        : in  std_logic_vector(15 downto 0);
           do_branch    : out std_logic); -- 1 if doing branch
end component;

component adder_12b is
    port ( src_a     : in  std_logic_vector(11 downto 0);
           src_b     : in  std_logic_vector(11 downto 0);
           sum       : out std_logic_vector(11 downto 0);
           carry_in  : in  std_logic;
           carry_out : out std_logic );
end component;

--------------------------------------------------------------
-- pipeline registers
--
--------------------------------------------------------------

component generic_register is
	generic ( LEN			: integer );
    port ( reset        : in  std_logic;
           flush        : in  std_logic;
           clk          : in  std_logic;
           data_out		: out std_logic_vector(LEN-1 downto 0);
           data_in     	: in  std_logic_vector(LEN-1 downto 0));
end component;

component generic_register_fe is
	generic ( LEN			: integer );
    port ( reset        : in  std_logic;
           flush        : in  std_logic;
           clk          : in  std_logic;
           data_out		: out std_logic_vector(LEN-1 downto 0);
           data_in     	: in  std_logic_vector(LEN-1 downto 0));
end component;

component if_id_reg is
	generic ( LEN			: integer );
    port ( reset        : in  std_logic;
           flush        : in  std_logic;
           stall        : in  std_logic;
           clk          : in  std_logic;
           data_out		: out std_logic_vector(LEN-1 downto 0);
           data_in     	: in  std_logic_vector(LEN-1 downto 0));
end component;

--------------------------------------------------------------
-- forwarding unit
--
--------------------------------------------------------------

component fwd_unit is
    port (  src_reg_a       : in std_logic_vector(3 downto 0);
            src_reg_b       : in std_logic_vector(3 downto 0);
            reg_write_dm    : in std_logic;
            reg_write_wb    : in std_logic;   
            alu_src         : in std_logic;
            write_reg_dm    : in std_logic_vector(3 downto 0);
            write_reg_wb    : in std_logic_vector(3 downto 0);
            alu_fwd_dm_or_w_a   : out std_logic;
            alu_fwd_dm_or_w_b   : out std_logic;
            alu_src_a_ctrl  : out std_logic;
            alu_src_b_ctrl  : out std_logic
            );
end component;

component pc_ctrl_if is
    port ( opcode     : in  std_logic_vector(3 downto 0);
           do_jmp     : out std_logic;
           do_not_jmp : out std_logic;
           b_type     : out std_logic;
           b_insn     : out std_logic;
           do_branch  : in  std_logic;
           do_pc_offset : out std_logic;
           b_or_jmp     : out std_logic;
           pc_src       : out std_logic);
end component;

component hzd_ctrl is
    port ( opcode     : in  std_logic_vector(3 downto 0);
           do_jmp     : out std_logic;
           do_not_jmp : out std_logic;
           b_type     : out std_logic;
           b_insn     : out std_logic;
           do_branch  : in  std_logic;
           do_pc_offset : out std_logic;
           b_or_jmp     : out std_logic;
           pc_src       : out std_logic;
           insn_if      : in  std_logic_vector(15 downto 0);
           insn_id      : in  std_logic_vector(15 downto 0);
           stall        : out std_logic);
end component;

component or_gate is 
    port(src_a  : in  std_logic;
         src_b  : in  std_logic;
         d_out  : out std_logic);
end component;

component jmp_ctrl is 
    port(OPCODE  : in  std_logic_vector (3 downto 0);
         jmp_flag: out std_logic);
end component;

component mux_4to1_16b is
    port ( mux_select : in  std_logic_vector(1 downto 0);
           data_0     : in  std_logic_vector(15 downto 0);
           data_1     : in  std_logic_vector(15 downto 0);
           data_2     : in  std_logic_vector(15 downto 0);
           data_3     : in  std_logic_vector(15 downto 0);
           data_out   : out std_logic_vector(15 downto 0) );
end component; 

signal sig_next_pc              : std_logic_vector(11 downto 0);
signal sig_curr_pc              : std_logic_vector(11 downto 0);
signal sig_one_4b               : std_logic_vector(3 downto 0);
signal sig_one_12b              : std_logic_vector(11 downto 0);
signal sig_pc_carry_out         : std_logic;
signal sig_insn                 : std_logic_vector(15 downto 0);
signal sig_sign_extended_offset_id : std_logic_vector(15 downto 0);
signal sig_sign_extended_offset_ex : std_logic_vector(15 downto 0);
signal sig_reg_dst               : std_logic;
signal sig_reg_write_id         : std_logic;
signal sig_alu_src_id           : std_logic;
signal sig_alu_src_ex           : std_logic;
signal sig_mem_write_id         : std_logic;
signal sig_mem_to_reg_id        : std_logic;
signal sig_write_data           : std_logic_vector(15 downto 0);
signal sig_read_data_a_id       : std_logic_vector(15 downto 0);
signal sig_read_data_a_ex       : std_logic_vector(15 downto 0);
signal sig_read_data_b_id       : std_logic_vector(15 downto 0);
signal sig_alu_src_b            : std_logic_vector(15 downto 0);
signal sig_alu_result           : std_logic_vector(15 downto 0); 
signal sig_alu_carry_out        : std_logic;
signal sig_data_mem_out         : std_logic_vector(15 downto 0);
signal sig_alu_op_id        : std_logic_vector(2 downto 0);
signal sig_alu_op_ex        : std_logic_vector(2 downto 0);
signal sig_do_slt_id            : std_logic;
signal sig_do_slt_ex            : std_logic;
signal sig_byte_addr_id         : std_logic;
signal sig_mem_read_id           : std_logic;
signal sig_b_type               : std_logic;
signal sig_b_insn               : std_logic;
signal sig_stall                : std_logic;

-- The following are added to allow for modifications to the pc
-- ie for branching and jumping.
-- When jumping (signaled by sig_do_jmp=1) we read the address from
-- the immediate that is within the instruction itself
-- When branching we still read the address from the instruction 
-- immediate, but in this case it is a 4-bit value so must be sign extended 
-- NOTE! The instruction memory is limited to 2^12 addresses for 
-- convenience.


signal sig_do_branch            : std_logic;
signal sig_do_jmp               : std_logic;
signal sig_curr_pc_or_branch    : std_logic_vector(11 downto 0);
signal sig_branch_offset        : std_logic_vector(11 downto 0);
signal sig_z_12b                : std_logic_vector(11 downto 0);
signal sig_jump_or_branch_addr  : std_logic_vector(11 downto 0);
signal sig_do_pc_offset_id      : std_logic;
signal sig_do_pc_offset_ex      : std_logic;
signal sig_pc_or_jmp            : std_logic_vector(11 downto 0);
signal sig_z_or_branch          : std_logic_vector(11 downto 0);
signal sig_one_or_branch        : std_logic_vector(11 downto 0);
signal sig_do_not_jmp           : std_logic;

-------------------------------------------
-- Pipeline signals
-- 
-------------------------------------------
signal sig_next_pc_if           : std_logic_vector(11 downto 0);
signal sig_curr_pc_if            : std_logic_vector(11 downto 0);
signal sig_insn_if              : std_logic_vector(15 downto 0);

signal sig_next_pc_id           : std_logic_vector(11 downto 0);
signal sig_curr_pc_id           : std_logic_vector(11 downto 0);
signal sig_insn_id              : std_logic_vector(15 downto 0); 
signal sig_write_register_id    : std_logic_vector(3 downto 0);

signal sig_alu_result_ex        : std_logic_vector(15 downto 0);  
signal sig_read_data_b_ex       : std_logic_vector(15 downto 0);
signal sig_byte_addr_ex         : std_logic;
--signal sig_reg_dst_ex           : std_logic;
signal sig_reg_write_ex         : std_logic;
signal sig_mem_write_ex         : std_logic;
signal sig_mem_read_ex          : std_logic;
signal sig_mem_to_reg_ex        : std_logic;
signal sig_write_register_ex    : std_logic_vector(3 downto 0);

signal sig_alu_result_dm        : std_logic_vector(15 downto 0);  
signal sig_read_data_b_dm       : std_logic_vector(15 downto 0);
signal sig_byte_addr_dm         : std_logic;
--signal sig_reg_dst_dm           : std_logic;
signal sig_reg_write_dm         : std_logic;
signal sig_mem_write_dm         : std_logic;
signal sig_mem_read_dm          : std_logic;
signal sig_mem_to_reg_dm        : std_logic;
signal sig_write_register_dm    : std_logic_vector(3 downto 0);
signal sig_data_mem_out_dm      : std_logic_vector(15 downto 0);

signal sig_alu_result_wb        : std_logic_vector(15 downto 0);
signal sig_data_mem_out_wb      : std_logic_vector(15 downto 0);
signal sig_write_register_wb    : std_logic_vector(3 downto 0);
signal sig_mem_to_reg_wb        : std_logic;
signal sig_reg_write_wb         : std_logic;

-------------------------------------------
-- Hazard detection signals
-- 
-------------------------------------------
signal sig_alu_haz_res_src_a    : std_logic_vector(15 downto 0);
signal sig_alu_haz_res_src_b    : std_logic_vector(15 downto 0);
signal sig_alu_fwd_dm_or_w_a    : std_logic;
signal sig_alu_fwd_dm_or_w_b    : std_logic;
signal sig_alu_fwd_src_a        : std_logic_vector(15 downto 0);
signal sig_alu_fwd_src_b        : std_logic_vector(15 downto 0);
signal sig_alu_src_a_ctrl       : std_logic;
signal sig_alu_src_b_ctrl       : std_logic;
signal sig_reg_read_a_id        : std_logic_vector(3 downto 0);
signal sig_reg_read_b_id        : std_logic_vector(3 downto 0);
signal sig_reg_read_a_ex        : std_logic_vector(3 downto 0);
signal sig_reg_read_b_ex        : std_logic_vector(3 downto 0);
signal sig_reg_if_id_bubble     : std_logic;
signal sig_ctrl_out             : std_logic_vector(15 downto 0);
signal sig_curr_pc_p1           : std_logic_vector(11 downto 0);
signal sig_curr_pc_fly          : std_logic_vector(11 downto 0);
signal sig_pc_src               : std_logic;
signal sig_b_or_jmp             : std_logic;
signal sig_pc_b_addr            : std_logic_vector(11 downto 0);
signal sig_b_adder_carry_out    : std_logic;
signal sig_jmp_flag             : std_logic;
signal sig_pc_p1_or_jmp         : std_logic_vector(11 downto 0);
signal sig_refresh              : std_logic;
signal sig_insn_ex              : std_logic_vector(15 downto 0);

-------------------------------------------
-- PC as it moves through the pipe
-- 
-------------------------------------------
signal sig_pc_stage_if          : std_logic_vector(11 downto 0);
signal sig_pc_stage_id          : std_logic_vector(11 downto 0);
signal sig_pc_stage_ex          : std_logic_vector(11 downto 0);
signal sig_pc_stage_dm          : std_logic_vector(11 downto 0);
signal sig_pc_stage_wb          : std_logic_vector(11 downto 0);
signal sig_insn_pc              : std_logic_vector(11 downto 0);
signal sig_next_pc_in           : std_logic_vector(11 downto 0);
signal sig_insn_if_raw          : std_logic_vector(15 downto 0);
signal sig_insn_id_fe           : std_logic_vector(15 downto 0);
signal sig_insn_id_storage      : std_logic_vector(15 downto 0);

begin

    sig_one_4b              <= "0001";
	 sig_one_12b             <= "000000000001";
    sig_z_12b               <= "000000000000";

    sig_alu_result          <= sig_alu_result;
--    sig_read_data_b         <= sig_read_data_b;
--    sig_byte_addr           <= sig_byte_addr_ex;
----    sig_reg_dst             <= sig_reg_dst_ex;
--    sig_reg_write           <= sig_reg_write_ex;
--    sig_mem_write           <= sig_mem_write_ex; 
--    sig_mem_read            <= sig_mem_read_ex;
--    sig_mem_to_reg          <= sig_mem_to_reg_ex;
    sig_reg_read_a_id       <= sig_insn_id(11 downto 8);
    sig_reg_read_b_id       <= sig_insn_id(7 downto 4);


    pc : program_counter
    port map ( reset    => reset,
               clk      => clk,
               refresh  => '0',
               stall    => sig_stall,
               addr_in  => sig_next_pc,
               addr_out => sig_curr_pc_if ); 

    -- We need to sign extend because a branch encodes the address in an immediate
    branch_extend : sign_extend_4to12 
    port map ( data_in  => sig_insn_id(3 downto 0),
               data_out => sig_branch_offset );
    
    pc_inc_or_jmp : mux_2to1_12b 
    port map ( mux_select => sig_jmp_flag,
               data_a     => sig_curr_pc_p1, --increment
               data_b     => sig_insn_if(11 downto 0), --or we can jump
               data_out   => sig_pc_p1_or_jmp);
               
    
    pc_b_addr : adder_12b
    port map ( src_a     => sig_curr_pc_id, 
               src_b     => sig_branch_offset,
               sum       => sig_pc_b_addr,   
               carry_in  => '1',
               carry_out => sig_b_adder_carry_out);
    
        -- Choose whether we go to a branch or not 
    pc_src_select : mux_2to1_12b 
    port map ( mux_select => sig_pc_src,
               data_a     => sig_pc_p1_or_jmp, --execute sequentially
               data_b     => sig_pc_b_addr, --or jump/branch
               data_out   => sig_next_pc);
    
    next_pc : adder_12b 
    port map ( src_a     => sig_curr_pc_if, 
               src_b     => x"001",
               sum       => sig_curr_pc_p1,   
               carry_in  => '0',
               carry_out => sig_pc_carry_out );
    
    insn_mem : instruction_memory 
    port map ( reset    => reset,
               clk      => clk,
               stall    => sig_stall,
               addr_in  => sig_curr_pc_if,
               insn_out => sig_insn_if,
               insn_out_raw => sig_insn_if_raw);

    sign_extend : sign_extend_4to16 
    port map ( data_in  => sig_insn_id(3 downto 0),
               data_out => sig_sign_extended_offset_id );

    ctrl_unit : control_unit 
    port map ( opcode     => sig_insn_id(15 downto 12),
               reg_dst    => sig_reg_dst,
               reg_write  => sig_reg_write_id,
               alu_src    => sig_alu_src_id,
               mem_write  => sig_mem_write_id,
               mem_read   => sig_mem_read_id,
               mem_to_reg => sig_mem_to_reg_id,
               do_jmp     => sig_ctrl_out(0),--sig_do_jmp,
               do_not_jmp => sig_ctrl_out(1),--sig_do_not_jmp,
               do_slt     => sig_do_slt_id,
               byte_addr  => sig_byte_addr_id,
               b_type     => sig_ctrl_out(4),--sig_b_type,
               b_insn     => sig_ctrl_out(5),--sig_b_insn,
               do_branch  => sig_ctrl_out(6),--sig_do_branch,
               do_pc_offset => sig_ctrl_out(7),--sig_do_pc_offset_id,
               alu_op	  => sig_alu_op_id);

    mux_reg_dst : mux_2to1_4b 
    port map ( mux_select => sig_reg_dst,
               data_a     => sig_insn_id(7 downto 4),
               data_b     => sig_insn_id(3 downto 0),
               data_out   => sig_write_register_id );

    reg_file : register_file  
    port map ( reset           => reset, 
               clk             => clk,
               read_register_a => sig_reg_read_a_id,
               read_register_b => sig_reg_read_b_id,
               write_enable    => sig_reg_write_wb,
               write_register  => sig_write_register_wb,
               write_data      => sig_write_data,
               read_data_a     => sig_read_data_a_id,
               read_data_b     => sig_read_data_b_id );
               
    reg_cmp   : branch_cmp
    port map ( b_type     => sig_b_type,
               b_insn     => sig_b_insn,
               src_a      => sig_read_data_a_id,
               src_b      => sig_read_data_b_id,
               do_branch  => sig_do_branch);
    
    mux_alu_src : mux_2to1_16b 
    port map ( mux_select => sig_alu_src_ex,
               data_a     => sig_read_data_b_ex,
               data_b     => sig_sign_extended_offset_ex,
               data_out   => sig_alu_src_b );

    alu : alu_16b 
    port map ( src_a      => sig_alu_haz_res_src_a,
               src_b      => sig_alu_haz_res_src_b,
               alu_out    => sig_alu_result_ex,
               alu_op 	  => sig_alu_op_ex,
               do_slt     => sig_do_slt_ex,
               carry_out  => sig_alu_carry_out );

    data_mem : data_memory 
    port map ( reset        => reset,
               clk          => clk,
               write_enable => sig_mem_write_dm,
               read_enable  => sig_mem_read_dm,
               write_data   => sig_read_data_b_dm,
               byte_addr	=> sig_byte_addr_dm,
               addr_in      => sig_alu_result_dm(11 downto 0),
               data_out     => sig_data_mem_out_dm );
               
    mux_mem_to_reg : mux_2to1_16b 
    port map ( mux_select => sig_mem_to_reg_wb,
               data_a     => sig_alu_result_wb,
               data_b     => sig_data_mem_out_wb,
               data_out   => sig_write_data );

----------------------------------------------------
-- Pipeline registers
--
----------------------------------------------------

   register_if_id   : if_id_reg
   generic map( LEN => 16 )
   port map(  reset       => reset,
              clk         => clk,
              flush       => sig_pc_src,
              stall       => sig_stall,
              
              data_out	  => sig_insn_id,
              data_in     => sig_insn_if);
              
   register_ex_dm   : generic_register
   generic map( LEN => 41 )
   port map(  reset       => reset,
              clk         => clk,
              flush       => '0',
              
              data_in(15 downto 0)      => sig_alu_result_ex,
              data_in(31 downto 16)     => sig_read_data_b_ex,
              data_in(32)               => sig_byte_addr_ex,
              data_in(33)               => sig_reg_write_ex,
              data_in(34)               => sig_mem_write_ex, 
              data_in(35)               => sig_mem_read_ex, 
              data_in(36)               => sig_mem_to_reg_ex,
              data_in(40 downto 37)     => sig_write_register_ex,
              
              data_out(15 downto 0)	    => sig_alu_result_dm,
              data_out(31 downto 16)    => sig_read_data_b_dm,
              data_out(32)              => sig_byte_addr_dm,
              data_out(33)              => sig_reg_write_dm,
              data_out(34)              => sig_mem_write_dm, 
              data_out(35)              => sig_mem_read_dm, 
              data_out(36)              => sig_mem_to_reg_dm,
              data_out(40 downto 37)    => sig_write_register_dm);
   
   register_dm_wb   : generic_register   
   generic map( LEN => 38 )
   port map(  reset       => reset,
              clk         => clk,
              flush       => '0',
              
              data_in(15 downto 0)      => sig_alu_result_dm,
              data_in(31 downto 16)     => sig_data_mem_out_dm,
              data_in(35 downto 32)	    => sig_write_register_dm,
              data_in(36)               => sig_mem_to_reg_dm,
              data_in(37)               => sig_reg_write_dm,
              
              data_out(15 downto 0)     => sig_alu_result_wb,
              data_out(31 downto 16)    => sig_data_mem_out_wb,
              data_out(35 downto 32)    => sig_write_register_wb,
              data_out(36)              => sig_mem_to_reg_wb,
              data_out(37)              => sig_reg_write_wb);


   register_id_ex   : generic_register
   generic map( LEN => 87 )						-- Guess 48 for the moment, probably going to be more like 53
   port map(  	    reset       => reset,
					clk         => clk,
                    flush       => '0',
				  
					-- This register stores:
					--   Reg A and Reg B from the register file
					--   Output from the sign extender
					--   All the control unit outputs except branch and jump signals

					-- Inputs (Control signals)
                    data_in(86 downto 71)       => sig_insn_id,
                    data_in(70 downto 67)       => sig_reg_read_a_id,
                    data_in(66 downto 63)       => sig_reg_read_b_id,
					data_in(62 downto 59)	    => sig_write_register_id,
					data_in(58) 				=> sig_reg_write_id,
					data_in(57) 				=> sig_alu_src_id,
					data_in(56 downto 54) 	    => sig_alu_op_id,
					data_in(53) 				=> sig_mem_write_id,
					data_in(52) 				=> sig_do_slt_id,
					data_in(51) 				=> sig_byte_addr_id,
					data_in(50) 				=> sig_mem_read_id,
					data_in(49) 				=> sig_do_pc_offset_id,
					data_in(48) 				=> sig_mem_to_reg_id,
					
					-- Inputs (others)
					data_in(47 downto 32)  	=> sig_read_data_a_id,   -- TODO: find other connections here
					data_in(31 downto 16)   => sig_read_data_b_id,  -- TODO: find other connections here
					data_in(15 downto 0)   	=> sig_sign_extended_offset_id,  -- TODO: find other connections here

					-- Outputs (Control Signals)
                    data_out(86 downto 71)      => sig_insn_ex,
                    data_out(70 downto 67)      => sig_reg_read_a_ex,
                    data_out(66 downto 63)      => sig_reg_read_b_ex,
					data_out(62 downto 59)	    => sig_write_register_ex,
					data_out(58) 				=> sig_reg_write_ex,
					data_out(57) 				=> sig_alu_src_ex,
					data_out(56 downto 54) 	    => sig_alu_op_ex,
					data_out(53) 				=> sig_mem_write_ex,
					data_out(52) 				=> sig_do_slt_ex,
					data_out(51) 				=> sig_byte_addr_ex,
					data_out(50) 				=> sig_mem_read_ex,
					data_out(49) 				=> sig_do_pc_offset_ex,
					data_out(48) 				=> sig_mem_to_reg_ex,
					
					-- Outputs (others)
					data_out(47 downto 32)	=> sig_read_data_a_ex,
					data_out(31 downto 16)	=> sig_read_data_b_ex,
					data_out(15 downto 0)	=> sig_sign_extended_offset_ex);
                    
-------------------------------------------------------------
-- Forwarding unit
--
-------------------------------------------------------------
    --mux to choose between forawrd and original src
    mux_alu_src_a : mux_2to1_16b 
    port map ( mux_select => sig_alu_src_a_ctrl,
               data_a     => sig_read_data_a_ex,
               data_b     => sig_alu_fwd_src_a,
               data_out   => sig_alu_haz_res_src_a );
               
    mux_alu_src_b : mux_2to1_16b 
    port map ( mux_select => sig_alu_src_b_ctrl,
               data_a     => sig_alu_src_b,
               data_b     => sig_alu_fwd_src_b,
               data_out   => sig_alu_haz_res_src_b );
               
    --mux to choose between dm and wb forwards
    mux_alu_fwd_a : mux_2to1_16b 
    port map ( mux_select => sig_alu_fwd_dm_or_w_a,
               data_a     => sig_alu_result_dm,
               data_b     => sig_write_data,
               data_out   => sig_alu_fwd_src_a );
               
    mux_alu_fwd_b : mux_2to1_16b 
    port map ( mux_select => sig_alu_fwd_dm_or_w_b,
               data_a     => sig_alu_result_dm,
               data_b     => sig_write_data,
               data_out   => sig_alu_fwd_src_b );
               
    forwarding_unit : fwd_unit 
    port map ( src_reg_a            => sig_reg_read_a_ex,
               src_reg_b            => sig_reg_read_b_ex,
               reg_write_dm         => sig_reg_write_dm,
               reg_write_wb         => sig_reg_write_wb,
               alu_src              => sig_alu_src_ex,
               write_reg_dm         => sig_write_register_dm,
               write_reg_wb         => sig_write_register_wb,
               alu_fwd_dm_or_w_a    => sig_alu_fwd_dm_or_w_a,
               alu_fwd_dm_or_w_b    => sig_alu_fwd_dm_or_w_b,
               alu_src_a_ctrl       => sig_alu_src_a_ctrl,
               alu_src_b_ctrl       => sig_alu_src_b_ctrl
               );

-------------------------------------------------------------
-- Structural control unit
-- Assume branch not taken
-------------------------------------------------------------

   register_pc_if_id   : generic_register
   generic map( LEN => 12 )
   port map(  reset       => reset,
              clk         => clk,
              flush       => '0',

              data_in(11 downto 0) => sig_curr_pc_if,
              
              data_out(11 downto 0) => sig_curr_pc_id);
                            
--   if_pc_ctrl           : pc_ctrl_if
--   port map ( opcode    => sig_insn_id(15 downto 12),
--            do_jmp      => sig_do_jmp,
--            do_not_jmp  => sig_do_not_jmp,
--            b_type      => sig_b_type,
--            b_insn      => sig_b_insn,
--            do_branch   => sig_do_branch,
--            do_pc_offset => sig_do_pc_offset_id,
--            b_or_jmp    => sig_b_or_jmp,
--            pc_src      => sig_pc_src );
            
    jump_control        :jmp_ctrl 
    port map(OPCODE => sig_insn_if(15 downto 12),
             jmp_flag => sig_jmp_flag);
    
--    bubble_sel          : or_gate 
--    port map (  src_a  => sig_pc_src,
--                src_b  => reset,
--                d_out  => sig_reg_if_id_bubble);


-------------------------------------------------------------
-- PC tracking 
-- 
-------------------------------------------------------------

--   register_pc_dummy_pc_track   : generic_register   
--   generic map( LEN => 12 )
--   port map(  reset       => reset,
--              clk         => clk,
--              flush       => '0',
--              
--              data_in(11 downto 0)      => sig_curr_pc_if,
--
--              data_out(11 downto 0)     => sig_insn_pc);
              
              
   register_insn_dummy_pc_track   : generic_register   
   generic map( LEN => 12 )
   port map(  reset       => reset,
              clk         => clk,
              flush       => '0',
              
              data_in(11 downto 0)      => sig_curr_pc_if,

              data_out(11 downto 0)     => sig_pc_stage_if);
              
    

   register_if_id_pc_track   : generic_register   
   generic map( LEN => 12 )
   port map(  reset       => reset,
              clk         => clk,
              flush       => '0',
              
              data_in(11 downto 0)      => sig_pc_stage_if,

              data_out(11 downto 0)     => sig_pc_stage_id);
              
   register_id_ex_pc_track   : generic_register   
   generic map( LEN => 12 )
   port map(  reset       => reset,
              clk         => clk,
              flush       => '0',
              
              data_in(11 downto 0)      => sig_pc_stage_id,

              data_out(11 downto 0)     => sig_pc_stage_ex);
              
   register_if_ex_dm_track   : generic_register   
   generic map( LEN => 12 )
   port map(  reset       => reset,
              clk         => clk,
              flush       => '0',
              
              data_in(11 downto 0)      => sig_pc_stage_ex,

              data_out(11 downto 0)     => sig_pc_stage_dm);
              
   register_dm_wb_pc_track   : generic_register   
   generic map( LEN => 12 )
   port map(  reset       => reset,
              clk         => clk,
              flush       => '0',
              
              data_in(11 downto 0)      => sig_pc_stage_dm,

              data_out(11 downto 0)     => sig_pc_stage_wb);

   hazard_control_unit        : hzd_ctrl
   port map ( opcode    => sig_insn_id_storage(15 downto 12),
            do_jmp      => sig_do_jmp,
            do_not_jmp  => sig_do_not_jmp,
            b_type      => sig_b_type,
            b_insn      => sig_b_insn,
            do_branch   => sig_do_branch,
            do_pc_offset => sig_do_pc_offset_id,
            b_or_jmp    => sig_b_or_jmp,
            pc_src      => sig_pc_src,
            insn_if     => sig_insn_id_storage,
            insn_id     => sig_insn_ex,
            stall       => sig_stall            );
            
    refresh_select          : or_gate 
    port map (  src_a  => sig_pc_src,
                src_b  => sig_jmp_flag,
                d_out  => sig_refresh);
    
--    register_if_id_insn_fe   : generic_register_fe   
--    generic map( LEN => 16 )
--    port map(  reset       => reset,
--              clk         => clk,
--              flush       => sig_pc_src,
--              
--              data_in(15 downto 0)      => sig_insn_if,
--
--              data_out(15 downto 0)     => sig_insn_id_fe);
              
    register_if_id_track   : generic_register   
    generic map( LEN => 16 )
    port map(  reset       => reset,
              clk         => clk,
              flush       => '0',
              
              data_in(15 downto 0)      => sig_insn_if,

              data_out(15 downto 0)     => sig_insn_id_storage);
              
--    insn_mem_staller          : mux_2to1_16b 
--    port map ( mux_select => sig_stall,
--               data_a     => sig_insn,
--               data_b     => X"0000",
--               data_out   => sig_insn_if );
--               
--    pc_staller                : mux_2to1_12b 
--    port map ( mux_select => sig_stall,
--               data_a     => sig_curr_pc,
--               data_b     => sig_pc_stage_if,
--               data_out   => sig_curr_pc_if );
               
end structural;
