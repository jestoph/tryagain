---------------------------------------------------------------------------
-- control_unit.vhd - Control Unit Implementation
--
-- Notes: refer to headers in single_cycle_core.vhd for the supported ISA.
--
--  control signals:
--     reg_dst    : asserted for ADD instructions, so that the register
--                  destination number for the 'write_register' comes from
--                  the rd field (bits 3-0). 
--     reg_write  : asserted for ADD and LOAD instructions, so that the
--                  register on the 'write_register' input is written with
--                  the value on the 'write_data' port.
--     alu_src    : asserted for LOAD and STORE instructions, so that the
--                  second ALU operand is the sign-extended, lower 4 bits
--                  of the instruction.
--     mem_write  : asserted for STORE instructions, so that the data 
--                  memory contents designated by the address input are
--                  replaced by the value on the 'write_data' input.
--     mem_to_reg : asserted for LOAD instructions, so that the value fed
--                  to the register 'write_data' input comes from the
--                  data memory.
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

entity control_unit is
    port ( opcode     : in  std_logic_vector(3 downto 0);
           reg_dst    : out std_logic;
           reg_write  : out std_logic;
           alu_src    : out std_logic;
           mem_write  : out std_logic;
           mem_read   : out std_logic;
           mem_to_reg : out std_logic;
           do_jmp     : out std_logic;
           do_slt     : out std_logic;
           byte_addr  : out  std_logic;
		   alu_op : out std_logic_vEcToR(2 downto 0));
end control_unit;

architecture behavioural of control_unit is

constant OP_LOAD  : std_logic_vector(3 downto 0) := "0001"; -- 1
constant OP_STORE : std_logic_vector(3 downto 0) := "0011"; -- 3

constant OP_ADD   : std_logic_vector(3 downto 0) := "1000"; -- 8
constant OP_ADDI  : std_logic_vector(3 downto 0) := "1001"; -- 9
constant OP_AND   : std_logic_vector(3 downto 0) := "1100"; -- C
constant OP_XOR   : std_logic_vector(3 downto 0) := "1101"; -- D
constant OP_SLT   : std_logic_vector(3 downto 0) := "1010"; -- A
constant OP_SUB   : std_logic_vector(3 downto 0) := "1011"; -- b

constant OP_LDB   : std_logic_vector(3 downto 0) := "0101"; -- 5
constant OP_STB   : std_logic_vector(3 downto 0) := "0111"; -- 7

constant OP_BNE   : std_logic_vector(3 downto 0) := "0100"; -- 4
constant OP_BEQ   : std_logic_vector(3 downto 0) := "0110"; -- 6
constant OP_JMP   : std_logic_vector(3 downto 0) := "0010"; -- 2

constant OP_LSL   : std_logic_vector(3 downto 0) := "1110"; -- E
constant OP_LSR   : std_logic_vector(3 downto 0) := "1111"; -- F
 
begin
	-- operation that the alu performs
	alu_op <= "001" when (opcode = OP_SUB
                            or opcode = OP_SLT) else
			  "010" when (opcode = OP_XOR) else
			  "011" when (opcode = OP_AND) else 
			  "110" when (opcode = OP_LSL) else
			  "111" when (opcode = OP_LSR) else
			  "000";
	
	-- '1' when we are writing our output to Rd, '0' when writing to Rt 
    reg_dst    <= '1' when (opcode = OP_ADD
							or opcode = OP_AND
							or opcode = OP_XOR
							or opcode = OP_SLT
							or opcode = OP_SUB
							or opcode = OP_LSL
							or opcode = OP_LSR) else
                  '0';

	-- '1' When we're writing back to a register (as opposed to memory)
    reg_write  <= '1' when (opcode = OP_ADD 
							or opcode = OP_ADDI
							or opcode = OP_AND
							or opcode = OP_XOR
							or opcode = OP_SLT
							or opcode = OP_SUB
							or opcode = OP_LSL
							or opcode = OP_LSR
                            or opcode = OP_LOAD
							or opcode = OP_LDB) else
                  '0';
    
	-- '1' when using Immediate, '0' when using a register
    alu_src    <= '1' when (opcode = OP_LOAD 
                           or opcode = OP_STORE
						   or opcode = OP_ADDI
						   or opcode = OP_LDB
						   or opcode = OP_STB
						   or opcode = OP_LSL
						   or opcode = OP_LSR) else
                  '0';
                 
    mem_write  <= '1' when (opcode = OP_STORE
						   or opcode = OP_STB) else
                  '0';
                 
    mem_to_reg <= '1' when (opcode = OP_LOAD
						   or opcode = OP_LDB) else
                  '0';
                  
    do_slt     <= '1' when (opcode = OP_SLT) else
                  '0';
                  
    do_jmp     <= '1' when (opcode = OP_JMP) else
                  '0';

    byte_addr  <= '1' when (opcode = OP_LDB
                            or opcode = OP_STB) else
                   '0';
                   
    mem_read   <= '1' when (opcode = OP_LOAD
						   or opcode = OP_LDB) else
                  '0';
end behavioural;
