---------------------------------------------------------------------------
-- instruction_memory.vhd - Implementation of A Single-Port, 16 x 16-bit
--                          Instruction Memory.
-- 
-- Notes: refer to headers in single_cycle_core.vhd for the supported ISA.
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

entity instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(11 downto 0);
           insn_out : out std_logic_vector(15 downto 0) );
end instruction_memory;

architecture behavioral of instruction_memory is

type mem_array is array(0 to 63) of std_logic_vector(15 downto 0);
signal sig_insn_mem : mem_array;

begin
    mem_process: process ( clk,
                           addr_in ) is
  
    variable var_insn_mem : mem_array;
    variable var_addr     : integer;
  
    begin
        if (reset = '1') then
            -- initial values of the instruction memory :
            --  insn_0 : load  $1, $0, 0   - load data 0($0) into $1
            --  insn_1 : load  $2, $0, 1   - load data 2($0) into $2
            --  insn_2 : add   $3, $0, $1  - $3 <- $0 + $1
            --  insn_3 : add   $4, $1, $2  - $4 <- $1 + $2
            --  insn_4 : store $3, $0, 2   - store data $3 into 1($0)
            --  insn_5 : store $4, $0, 3   - store data $4 into 3($0)
            --  insn_6 - insn_15 : noop    - end of program
  
--            var_insn_mem(0)  := X"1010";
--            var_insn_mem(1)  := X"1022";
--            var_insn_mem(2)  := X"8013";
--            var_insn_mem(3)  := X"8124";
--            var_insn_mem(4)  := X"3031";
--            var_insn_mem(5)  := X"3043";
--            var_insn_mem(6)  := X"e123";
--            var_insn_mem(7)  := X"0000";
--            var_insn_mem(8)  := X"0000";
--            var_insn_mem(9)  := X"0000";
--            var_insn_mem(10) := X"0000";
--            var_insn_mem(11) := X"0000";
--            var_insn_mem(12) := X"0000";
--            var_insn_mem(13) := X"0000";
--            var_insn_mem(14) := X"0000";
--            var_insn_mem(15) := X"0000";

            var_insn_mem(1)  := X"901F"; -- addi $1,$0,15  $1=15     $1 15   /F
            var_insn_mem(2)  := X"8111"; -- add  $1,$1,$1  $1=$1+$1  $1 30   /1E
            var_insn_mem(3)  := X"9026"; -- addi $2,$0,6   $2=15     $2 15   /F
            var_insn_mem(4)  := X"C123"; -- and  $3,$2,$1  $3=$1&$2  $3 13   /E
            var_insn_mem(5)  := X"9043"; -- addi $4,$0,3   $4=3      $4 3    /3
            var_insn_mem(6)  := X"E431"; -- sll  $3,$4,1   $4=$4<<1  $4 6    /6  
            var_insn_mem(7)  := X"E442"; -- sll  $4,$4,2   $4=$4<<2  $4 24   /18
            var_insn_mem(8)  := X"f452"; -- srl  $5,$4,2   
            var_insn_mem(9)  := X"f462"; -- srl  $6,$4,2   
            var_insn_mem(10)  := X"d437"; -- xor  $7,$4,$3
            var_insn_mem(11) := X"b438"; -- sub  $8,$4,$3
            var_insn_mem(12) := X"b348"; -- sub  $8,$3,$4
            var_insn_mem(13) := X"a009"; 
            var_insn_mem(14) := X"a21a";
            var_insn_mem(15) := X"a12b";
            var_insn_mem(16) := X"0000"; -- jmp to 20
            var_insn_mem(17) := X"901F";
            var_insn_mem(18) := X"2014";
            var_insn_mem(19) := X"0000";
            var_insn_mem(20) := X"0000";
            var_insn_mem(21) := X"6012"; --beq to +2
            var_insn_mem(22) := X"4012"; --bne to +2
            var_insn_mem(23) := X"0000";
            var_insn_mem(24) := X"0000";
            var_insn_mem(25) := X"4002"; --bne to +2
            var_insn_mem(26) := X"6002"; --beq to +2
            var_insn_mem(27) := X"0000";
            var_insn_mem(28) := X"0000"; 
            var_insn_mem(29) := X"600C";--beq to -4
            var_insn_mem(30) := X"0000";
            var_insn_mem(31) := X"0000";
            var_insn_mem(32) := X"0000";
            
        elsif (rising_edge(clk)) then
            -- read instructions on the rising clock edge
            var_addr := conv_integer(addr_in);
            insn_out <= var_insn_mem(var_addr);
        end if;

        -- the following are probe signals (for simulation purpose)
        sig_insn_mem <= var_insn_mem;

    end process;
  
end behavioral;
