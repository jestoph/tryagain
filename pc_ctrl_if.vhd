---------------------------------------------------------------------------
-- pc_ctrl_if.vhd - Branch control in the if stage
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
 
entity pc_ctrl_if is
    port ( opcode     : in  std_logic_vector(3 downto 0);
           do_jmp     : out std_logic;
           do_not_jmp : out std_logic;
           b_type     : out std_logic;
           b_insn     : out std_logic;
           do_branch  : in  std_logic;
           do_pc_offset : out std_logic;
           b_or_jmp     : out std_logic;
           pc_src       : out std_logic);
end pc_ctrl_if;

architecture behavioural of pc_ctrl_if is

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

begin

    sig_do_jmp     <= '1' when (opcode = OP_JMP) else
                  '0';

    b_insn     <= '1' when (opcode = OP_BEQ
                           or opcode = OP_BNE) else
                  '0';
    
    b_type     <= '1' when (opcode = OP_BEQ) else
                  '0';
    
    do_jmp     <= sig_do_jmp;
    do_not_jmp <= not sig_do_jmp;
    do_pc_offset <= do_branch or sig_do_jmp;
    
    b_or_jmp    <= sig_do_jmp after 1ns;
    pc_src      <= do_branch after 1ns;

end behavioural;