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
           clk_pc  : in std_logic           );
end single_cycle_core;

architecture structural of single_cycle_core is

component program_counter is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(11 downto 0);
           addr_out : out std_logic_vector(11 downto 0) );
end component;

component instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(11 downto 0);
           insn_out : out std_logic_vector(15 downto 0) );
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
           clk          : in  std_logic;
           data_out		: out std_logic_vector(LEN-1 downto 0);
           data_in     	: in  std_logic_vector(LEN-1 downto 0));
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
signal sig_insn_if              : std_logic_vector(15 downto 0);

signal sig_next_pc_id           : std_logic_vector(11 downto 0);
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
signal sig_alu_fwd_ctr_a        : std_logic;
signal sig_alu_fwd_ctr_b        : std_logic;
signal sig_alu_fwd_src_a        : std_logic_vector(15 downto 0);
signal sig_alu_fwd_src_b        : std_logic_vector(15 downto 0);
signal sig_alu_src_a_ctrl       : std_logic;
signal sig_alu_src_b_ctrl       : std_logic;


begin

    sig_one_4b              <= "0001";
	 sig_one_12b             <= "000000000001";
    sig_z_12b               <= "000000000000";
    sig_insn                <= sig_insn_id;
    sig_alu_result          <= sig_alu_result;
--    sig_read_data_b         <= sig_read_data_b;
--    sig_byte_addr           <= sig_byte_addr_ex;
----    sig_reg_dst             <= sig_reg_dst_ex;
--    sig_reg_write           <= sig_reg_write_ex;
--    sig_mem_write           <= sig_mem_write_ex; 
--    sig_mem_read            <= sig_mem_read_ex;
--    sig_mem_to_reg          <= sig_mem_to_reg_ex;
    

    pc : program_counter
    port map ( reset    => reset,
               clk      => clk,
               addr_in  => sig_next_pc,
               addr_out => sig_curr_pc ); 

    -- We need to sign extend because a branch encodes the address in an immediate
    branch_extend : sign_extend_4to12 
    port map ( data_in  => sig_insn_id(3 downto 0),
               data_out => sig_branch_offset );

    -- Choose whether we're branching or not
    -- or from an immediate (j)
    pc_mux_bjmp : mux_2to1_12b 
    port map ( mux_select => sig_do_branch,
               data_a     => sig_z_12b, -- or we don't branch
               data_b     => sig_branch_offset, -- Branch has address encoded in last nibble
               data_out   => sig_one_or_branch);
    

    -- Choose whether we go to an absolute jump or not 
    pc_mux_offset : mux_2to1_12b 
    port map ( mux_select => sig_do_jmp,
               data_a     => sig_curr_pc, --or not jump
               data_b     => sig_insn_id(11 downto 0), --we can jump
               data_out   => sig_pc_or_jmp);

    next_pc : adder_12b 
    port map ( src_a     => sig_pc_or_jmp, 
               src_b     => sig_one_or_branch,
               sum       => sig_next_pc,   
               carry_in  => sig_do_not_jmp,
               carry_out => sig_pc_carry_out );
    
    insn_mem : instruction_memory 
    port map ( reset    => reset,
               clk      => clk,
               addr_in  => sig_next_pc,
               insn_out => sig_insn_if );

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
               do_jmp     => sig_do_jmp,
               do_not_jmp => sig_do_not_jmp,
               do_slt     => sig_do_slt_id,
               byte_addr  => sig_byte_addr_id,
               b_type     => sig_b_type,
               b_insn     => sig_b_insn,
               do_branch  => sig_do_branch,
               do_pc_offset => sig_do_pc_offset_id,
					alu_op	  => sig_alu_op_id);

    mux_reg_dst : mux_2to1_4b 
    port map ( mux_select => sig_reg_dst,
               data_a     => sig_insn_id(7 downto 4),
               data_b     => sig_insn_id(3 downto 0),
               data_out   => sig_write_register_id );

    reg_file : register_file 
    port map ( reset           => reset, 
               clk             => clk,
               read_register_a => sig_insn_id(11 downto 8),
               read_register_b => sig_insn_id(7 downto 4),
               write_enable    => sig_reg_write_dm,
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

   register_if_id   : generic_register
   generic map( LEN => 16 )
   port map(  reset       => reset,
              clk         => clk,
              
              data_out	  => sig_insn_id,
              data_in     => sig_insn_if);
              
   register_ex_dm   : generic_register
   generic map( LEN => 41 )
   port map(  reset       => reset,
              clk         => clk,
              
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
   generic map( LEN => 63 )						-- Guess 48 for the moment, probably going to be more like 53
   port map(  	reset       => reset,
					clk         => clk,
				  
					-- This register stores:
					--   Reg A and Reg B from the register file
					--   Output from the sign extender
					--   All the control unit outputs except branch and jump signals

					-- Inputs (Control signals)
					data_in(62 downto 59)	=> sig_write_register_id,
					data_in(58) 				=> sig_reg_write_id,
					data_in(57) 				=> sig_alu_src_id,
					data_in(56 downto 54) 	=> sig_alu_op_id,
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
					data_out(62 downto 59)	=> sig_write_register_ex,
					data_out(58) 				=> sig_reg_write_ex,
					data_out(57) 				=> sig_alu_src_ex,
					data_out(56 downto 54) 	=> sig_alu_op_ex,
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
-- Hazard control
--
-------------------------------------------------------------

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
               
    mux_alu_fwd_a : mux_2to1_16b 
    port map ( mux_select => sig_alu_fwd_ctr_a,
               data_a     => sig_alu_result_dm,
               data_b     => sig_write_data,
               data_out   => sig_alu_fwd_src_a );
               
    mux_alu_fwd_b : mux_2to1_16b 
    port map ( mux_select => sig_alu_fwd_ctr_b,
               data_a     => sig_alu_result_dm,
               data_b     => sig_write_data,
               data_out   => sig_alu_fwd_src_b );
               

end structural;
