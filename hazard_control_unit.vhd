---------------------------------------------------------------------------
-- hazard_control_unit.vhd - detects / resolves load hazards
-- 
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

entity hzd_ctrl is
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
end hzd_ctrl;

architecture behavioural of hzd_ctrl is

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

signal   sig_do_jmp : std_logic;
signal   sig_op_if  : std_logic_vector(3 downto 0);
signal   sig_op_id  : std_logic_vector(3 downto 0);
signal   sig_src_a_if  : std_logic_vector(3 downto 0);
signal   sig_src_b_if  : std_logic_vector(3 downto 0);
signal   sig_dst_id    : std_logic_vector(3 downto 0);
signal   sig_src_b_en  : std_logic;

begin

    sig_op_id    <= insn_id(15 downto 12);
    sig_op_if    <= insn_if(15 downto 12);
    sig_src_a_if <= insn_if(11 downto 8);
    sig_src_b_if <= insn_if(7 downto 4);
    sig_src_b_en <= '1' when (sig_op_if = OP_ADD or sig_op_if = OP_AND or
                                              sig_op_if = OP_BNE or sig_op_if = OP_BEQ or 
                                              sig_op_if = OP_XOR or sig_op_if = OP_SLT or
                                              sig_op_if = OP_SLT or sig_op_if = OP_SUB) else
                                              '0';
    sig_dst_id   <= insn_id(7 downto 4) when (sig_op_id = OP_LOAD or sig_op_id = OP_LDB) else (others => '0');

    sig_do_jmp     <= '1' when (opcode = OP_JMP) else
                  '0';

    b_insn     <= '1' when (opcode = OP_BEQ
                           or opcode = OP_BNE) else
                  '0' after 1.5ns;
    
    b_type     <= '1' when (opcode = OP_BEQ) else
                  '0' after 1.5ns;
    
    do_jmp     <= sig_do_jmp after 1.5ns;
    do_not_jmp <= not sig_do_jmp after 1.5ns;
    do_pc_offset <= do_branch or sig_do_jmp after 1.5ns;
    
    stall      <= '1' when (  (sig_op_id = OP_LOAD or sig_op_id = OP_LDB) 
                              and (sig_src_a_if = sig_dst_id or (sig_src_b_en = '1' and
                                    (sig_src_b_if = sig_dst_id)))) else '0' after 1ns;
    b_or_jmp    <= sig_do_jmp after 1.5ns;
    pc_src      <= do_branch after 1.5ns;
    
    

end behavioural;