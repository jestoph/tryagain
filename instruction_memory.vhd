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
           stall    : in  std_logic;
           addr_in  : in  std_logic_vector(11 downto 0);
           insn_out : out std_logic_vector(15 downto 0);
           insn_out_raw : out std_logic_vector(15 downto 0));
end instruction_memory;

architecture behavioral of instruction_memory is

type mem_array is array(0 to 71) of std_logic_vector(15 downto 0);
signal sig_insn_mem : mem_array;

begin
    mem_process: process ( clk,
                           addr_in
                           ) is
  
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

--            var_insn_mem(1)  := X"901F"; -- addi $1,$0,15  $1=15     $1 15   /F
--            var_insn_mem(2)  := X"8111"; -- add  $1,$1,$1  $1=$1+$1  $1 30   /1E
--            var_insn_mem(3)  := X"9026"; -- addi $2,$0,6   $2=15     $2 15   /F
--            var_insn_mem(4)  := X"C123"; -- and  $3,$2,$1  $3=$1&$2  $3 13   /E
--            var_insn_mem(5)  := X"9043"; -- addi $4,$0,3   $4=3      $4 3    /3
--            var_insn_mem(6)  := X"E431"; -- sll  $3,$4,1   $4=$4<<1  $4 6    /6  
--            var_insn_mem(7)  := X"E442"; -- sll  $4,$4,2   $4=$4<<2  $4 24   /18
--            var_insn_mem(8)  := X"f452"; -- srl  $5,$4,2   
--            var_insn_mem(9)  := X"f462"; -- srl  $6,$4,2   
--            var_insn_mem(10) := X"d437"; -- xor  $7,$4,$3
--            var_insn_mem(11) := X"b438"; -- sub  $8,$4,$3
--            var_insn_mem(12) := X"b348"; -- sub  $8,$3,$4
--            var_insn_mem(13) := X"a009"; 
--            var_insn_mem(14) := X"a21a";
--            var_insn_mem(15) := X"a12b";
--            var_insn_mem(16) := X"0000"; -- jmp to 20
--            var_insn_mem(17) := X"901F";
--            var_insn_mem(18) := X"2014";
--            var_insn_mem(19) := X"0000";
--            var_insn_mem(20) := X"0000";
--            var_insn_mem(21) := X"6012"; --beq to +2
--            var_insn_mem(22) := X"4012"; --bne to +2
--            var_insn_mem(23) := X"0000";
--            var_insn_mem(24) := X"0000";
--            var_insn_mem(25) := X"4002"; --bne to +2
--            var_insn_mem(26) := X"6002"; --beq to +2
--            var_insn_mem(27) := X"0000";
--            var_insn_mem(28) := X"0000"; 
--            var_insn_mem(29) := X"600C";--beq to -4
--            var_insn_mem(30) := X"0000";
--            var_insn_mem(31) := X"0000";
--            var_insn_mem(32) := X"0000";
            
--            var_insn_mem(1)  := X"9011"; -- addi $1,$0,1  
--            var_insn_mem(2)  := X"9022"; -- addi $2,$0,2  
--            var_insn_mem(3)  := X"9033"; -- addi $3,$0,3   
--            var_insn_mem(4)  := X"8104"; -- 
--            var_insn_mem(5)  := X"8434"; -- 
--            var_insn_mem(6)  := X"8415"; -- 
--            var_insn_mem(7)  := X"8416"; -- 
--            var_insn_mem(8)  := X"8167"; -- 
--            var_insn_mem(9)  := X"8168"; -- 
--            var_insn_mem(10) := X"8124"; -- 
--            var_insn_mem(11) := X"4003"; --  bne
--            var_insn_mem(12) := X"9111"; --
--            var_insn_mem(13) := X"9222"; 
--            var_insn_mem(14) := X"9333";
--            var_insn_mem(15) := X"9444"; -- bne
--            var_insn_mem(16) := X"9555"; 
--            var_insn_mem(17) := X"9666";
--            var_insn_mem(18) := X"9777";-- jmp to 20
--            var_insn_mem(19) := X"9888";
--            var_insn_mem(20) := X"9999";
--            var_insn_mem(21) := X"6012"; --beq to +2
--            var_insn_mem(22) := X"4012"; --bne to +2
--            var_insn_mem(23) := X"0000";
--            var_insn_mem(24) := X"0000";
--            var_insn_mem(25) := X"4002"; --bne to +2
--            var_insn_mem(26) := X"6002"; --beq to +2
--            var_insn_mem(27) := X"0000";
--            var_insn_mem(28) := X"0000"; 
--            var_insn_mem(29) := X"600C";--beq to -4
--            var_insn_mem(30) := X"5555";
--            var_insn_mem(31) := X"6666";
--            var_insn_mem(32) := X"7777";


--            var_insn_mem(1)  := X"9011"; -- addi $1,$0,1  
--            var_insn_mem(2)  := X"9022"; -- addi $2,$0,2  
--            var_insn_mem(3)  := X"9033"; -- addi $3,$0,3   
--            var_insn_mem(4)  := X"6115"; -- 
--            var_insn_mem(5)  := X"9111"; -- 
--            var_insn_mem(6)  := X"9222"; -- 
--            var_insn_mem(7)  := X"9333"; -- 
--            var_insn_mem(8)  := X"9444"; -- 
--            var_insn_mem(9)  := X"9555"; -- 
--            var_insn_mem(10) := X"9666"; -- 
--            var_insn_mem(11) := X"9777"; --  bne
--            var_insn_mem(12) := X"1080"; --
--            var_insn_mem(13) := X"8888"; 
--            var_insn_mem(14) := X"7090";  
--            var_insn_mem(15) := X"8999"; -- bne
--            var_insn_mem(16) := X"0000"; 
--            var_insn_mem(17) := X"2005";
--            var_insn_mem(18) := X"9777";-- jmp to 20
--            var_insn_mem(19) := X"9888";
--            var_insn_mem(20) := X"9999";
--            var_insn_mem(21) := X"6012"; --beq to +2
--            var_insn_mem(22) := X"4012"; --bne to +2
--            var_insn_mem(23) := X"0000";
--            var_insn_mem(24) := X"0000";
--            var_insn_mem(25) := X"4002"; --bne to +2
--            var_insn_mem(26) := X"6002"; --beq to +2
--            var_insn_mem(27) := X"0000";
--            var_insn_mem(28) := X"0000"; 
--            var_insn_mem(29) := X"600C";--beq to -4
--            var_insn_mem(30) := X"5555";
--            var_insn_mem(31) := X"6666";
--            var_insn_mem(32) := X"7777";
            
                var_insn_mem(0) := X"0000"; --nop
var_insn_mem(1) := X"0000"; --nop
var_insn_mem(2) := X"0000"; --nop
var_insn_mem(3) := X"0000"; --nop
var_insn_mem(4) := X"0000"; --nop
var_insn_mem(5) := X"0000"; --nop
-- INIT--INIT:
var_insn_mem(6) := X"10B0"; --lw rkp $0 0   ; Load Key address
var_insn_mem(7) := X"1052"; --lw rrn $0 2   ; Load Random Table
var_insn_mem(8) := X"1064"; --lw ris $0 4       ; Load Input address
var_insn_mem(9) := X"1076"; --lw ros $0 6   ; Load output address
var_insn_mem(10) := X"1BC0"; --lw rk1 rkp 0 ; key1 = *key + 0
var_insn_mem(11) := X"1BD2"; --lw rk2 rkp 2 ; key2 = *key + 2
var_insn_mem(12) := X"1BE4"; --lw rk3 rkp 4 ; key3 = *key + 4
var_insn_mem(13) := X"1BF6"; --lw rk4 rkp 6 ; key4 = *key + 6
var_insn_mem(14) := X"9031"; --addi rkc $0 1   ; Load constants load 0x0001
var_insn_mem(15) := X"F33F"; --srl  rkc rkc 15 ; make 0x8000
var_insn_mem(16) := X"90AF"; --addi rm1 $0 0xf ; create rm1 (mask 0x00ff) make 0x000f
var_insn_mem(17) := X"EAA1"; --sll  rm1 rm1 1  ; make 0x00f0
var_insn_mem(18) := X"9AAF"; --addi rm1 rm1 0xf ;make 0x00ff
-- MAIN--MAIN:          ; do {
var_insn_mem(19) := X"5620"; --lb re ris 0      ; load byte of string into re ; tmp = string[j]
var_insn_mem(20) := X"0000"; --nop
var_insn_mem(21) := X"8661"; --add ris ris 1    ; j++ or *string++
var_insn_mem(22) := X"4022"; --bne re $0 START  ; if(*string != EOF) continue
var_insn_mem(23) := X"203E"; --j END
-- START--START:
var_insn_mem(24) := X"5B80"; --lb s1 rkp 0      ;load first value of key into s1
var_insn_mem(25) := X"D282"; --xor re re s1 ;xor input char with first key byte
var_insn_mem(26) := X"8529"; --add s2 rrn re    ;get the index of the r table
var_insn_mem(27) := X"5920"; --lb re s2 0       ;load the rng table’s value
var_insn_mem(28) := X"9BB1"; --addi rkp rkp 1   ;get next subkey
var_insn_mem(29) := X"9017"; --addi ri $0 7 ;for(ri = 7; ri > 0; ri--) ri = 7
-- ENCRYPT_lOOP--ENCRYPT_lOOP:
var_insn_mem(30) := X"5B80"; --lb  s1 rkp 0 ;load subkey into s1
var_insn_mem(31) := X"D282"; --xor  re re s1    ;xor subkey with char
var_insn_mem(32) := X"8529"; --add  s2 rrn re   ;get the index of the table
var_insn_mem(33) := X"5920"; --lb  re s2 0      ;retrieve value from rng table
var_insn_mem(34) := X"9BB1"; --addi rkp rkp 1   ;increment subkey pointer
var_insn_mem(35) := X"911F"; --addi ri ri 15    ;decrement ri by 1
var_insn_mem(36) := X"6015"; --beq ri $0 DOTAG  ;once all 8 subkeys have been processed, do tag
var_insn_mem(37) := X"201E"; --j ENCRYPT_lOOP
var_insn_mem(38) := X"9BB9"; --addi rkp rkp 9   ;rkp - 7 -> returned to original value
var_insn_mem(39) := X"7720"; --sb re ros 0     ;store the output byte
var_insn_mem(40) := X"9771"; --addi ros ros 1  ;increment output str pointer
-- DOTAG--DOTAG:            ; shift encrypted character left by 1 if needed
var_insn_mem(41) := X"AC31"; --slt  ri rk1 rkc  ; if rk1 < 1b80, Msb is 0 -> ri=1
var_insn_mem(42) := X"4011"; --bne  ri $0 1     ; if ri != 0 (ri == 1), don't shift
var_insn_mem(43) := X"E221"; --sll  re re 1     ; shift encrypted char left by 1
var_insn_mem(44) := X"D288"; --xor s1 re s1 ; XOR the tag with the shifted character ;only the ls 8 bits needed. ;Mask the output of the tag at END
var_insn_mem(45) := X"AF31"; --slt  ri rk4 rkc  ; if rk4 < 0x80, Msb = 0 -> ri = 1 ; rotate key2 left
var_insn_mem(46) := X"EFF1"; --sll  rk4 rk4 1   ; shift rk4 left by 1
var_insn_mem(47) := X"AE38"; --slt  s1 rk3 rkc  ; if rk3 < 0x80, Msb = 0 -> s1 = 1
var_insn_mem(48) := X"EEE1"; --sll rk3 rk3 1    ; shift rk3 left by 1
var_insn_mem(49) := X"4011"; --bne  ri $0 1     ; if ri != 0 (ri == 1) don't add carry
var_insn_mem(50) := X"9EE1"; --addi rk3 rk3 1   ; add carry
var_insn_mem(51) := X"AD31"; --slt  ri rk2 rkc  ; if rk2 < 0x80, Msb = 0 -> ri = 1
var_insn_mem(52) := X"EDD1"; --sll rk2 rk2 1    ; shift rk2 left by 1
var_insn_mem(53) := X"4081"; --bne  s1 $0 1     ; if s1 != 0 (s1 == 1) don't add carry
var_insn_mem(54) := X"9EE1"; --addi rk3 rk3 1   ; add carry
var_insn_mem(55) := X"AC38"; --slt  s1 rk1 rkc  ; if rk1 < 0x80, Msb = 0 -> s1 = 1
var_insn_mem(56) := X"ECC1"; --sll rk1 rk1 1    ; shift rk1 left by 1
var_insn_mem(57) := X"4011"; --bne  ri $0 1     ; if ri != 0 (ri == 1) don't add carry
var_insn_mem(58) := X"9CC1"; --addi rk1 rk1 1   ; add carry
var_insn_mem(59) := X"4081"; --bne  s1 $0 1     ; if s1 != 0 (s1 == 1)no Msb to rotate
var_insn_mem(60) := X"9FF1"; --addi rk4 rk4 1   ; move Msb to lsb
-- DOTaG_ExIT--DOTaG_ExIT:     ; Modify Tag given output and key
var_insn_mem(61) := X"2013"; --j MAIN
-- END--END:
var_insn_mem(62) := X"C4A4"; --and rT rT rm1    ;mask the tag
var_insn_mem(63) := X"0000"; --nop              ; Finished.


        elsif (falling_edge(clk) and stall = '0') then
            -- read instructions on the rising clock edge
            var_addr := conv_integer(addr_in);
            insn_out <= var_insn_mem(var_addr);
            insn_out_raw <= var_insn_mem(var_addr);
        end if;

        -- the following are probe signals (for simulation purpose)
        sig_insn_mem <= var_insn_mem;

    end process;
  
end behavioral;
