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

type mem_array is array(0 to 128) of std_logic_vector(15 downto 0);
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
  
            var_insn_mem(0)  := X"1055";
            var_insn_mem(1)  := X"1022";
            var_insn_mem(2)  := X"8013";
            var_insn_mem(3)  := X"8124";
            var_insn_mem(4)  := X"3031";
            var_insn_mem(5)  := X"3043";
            var_insn_mem(6)  := X"e123";
            var_insn_mem(7)  := X"0000";
            var_insn_mem(8)  := X"0000";
            var_insn_mem(9)  := X"0000";
            var_insn_mem(10) := X"0000";
            var_insn_mem(11) := X"0000";
            var_insn_mem(12) := X"0000";
            var_insn_mem(13) := X"0000";
            var_insn_mem(14) := X"0000";
            var_insn_mem(15) := X"0000";

--var_insn_mem(0) := X"0000"; --nop
--var_insn_mem(1) := X"0000"; --nop
---- INIT--INIT:
--var_insn_mem(2) := X"10B0"; --lw rkp $0 0     ; Load Key address
--var_insn_mem(3) := X"1052"; --lw rrn $0 2     ; Load Random Table
--var_insn_mem(4) := X"1064"; --lw ris $0 4      ; Load Input address
--var_insn_mem(5) := X"1076"; --lw ros $0 6     ; string length
--var_insn_mem(6) := X"9774"; --(padding should be 8, not 4)--4"; -- string length + padding | add ros ros padding
--var_insn_mem(7) := X"8677"; -- calculate output string addr | add ros ros ris
--
--var_insn_mem(8) := X"0000"; --nop
--var_insn_mem(9) := X"0000"; --nop
--
--
--var_insn_mem(10) := X"1BC0"; --lw rk1 rkp 0    ; key1 = *key + 0
--var_insn_mem(11) := X"1BD2"; --lw rk1 rkp 0    ; key2 = *key + 2
--var_insn_mem(12) := X"1BE4"; --lw rk1 rkp 0    ; key3 = *key + 4
--var_insn_mem(13) := X"1BF6"; --lw rk1 rkp 0    ; key4 = *key + 6
--var_insn_mem(14) := X"0000";  
--var_insn_mem(15) := X"9031"; --addi rkc $0 1   ; load 0x0001
--var_insn_mem(16) := X"e33F"; --srl  rkc rkc 1  ; make 0x8000
--var_insn_mem(17) := X"90AF"; --addi rm1 $0 0xf ; make 0x000f
--var_insn_mem(18) := X"EAA4"; --sll  rm1 rm1 4  ; make 0x00f0
--var_insn_mem(19) := X"9AAF"; --addi rm1 rm1 0xf ;make 0x00ff
---- MAIN--MAIN:          ; do {
--var_insn_mem(20) := X"5620"; --lb re ris 0      ; load byte of string into re ; tmp = string[j]
--var_insn_mem(21) := X"9661"; --addi ris ris 1    ; j++ or *string++
--var_insn_mem(22) := X"0000"; 
--var_insn_mem(23) := X"0000"; --nop
--var_insn_mem(24) := X"4021"; --bne re $0 START  ; if(*string != EOF) continue
--var_insn_mem(25) := X"2043"; --j END
---- START--START:
----var_insn_mem(26) := X"5B80"; --lb s1 rkp 0       ;load first value of key into s1
----var_insn_mem(27) := X"D282"; --xor re re s1 ;xor input char with first key byte
----var_insn_mem(28) := X"8529"; --add s2 rrn re    ;get the index of the r table
----var_insn_mem(29) := X"5920"; --lb re s2 0       ;load the rng table's value
----var_insn_mem(30) := X"9BB1"; --addi rkp rkp 1   ;get next subkey
--
--var_insn_mem(26) := X"0000";
--var_insn_mem(27) := X"0000";
--var_insn_mem(28) := X"0000";
--
--var_insn_mem(29) := X"9018"; --addi ri $0 8 ;for(ri = -8; ri < 0; ri--) ri = -8
--var_insn_mem(30) := X"b011"; --addi ri $0 8 ;for(ri = -8; ri < 0; ri--) ri = -8
--
---- ENCRYPT_lOOP--ENCRYPT_lOOP:
--var_insn_mem(31) := X"9111"; --addi ri ri 1     ;increment ri by 1
--var_insn_mem(32) := X"5B80"; --lb  s1 rkp 0     ;load subkey into s1
--var_insn_mem(33) := X"D282"; --xor  re re s1    ;xor subkey with char
--var_insn_mem(34) := X"8529"; --add  s2 rrn re   ;get the index of the table
--var_insn_mem(35) := X"5920"; --lb  re s2 0      ;retrieve value from rng table
--var_insn_mem(36) := X"9BB1"; --addi rkp rkp 1   ;increment subkey pointer
--
--var_insn_mem(37) := X"6011"; --beq ri $0 SAVE_ENCRYPT  ;once all 8 subkeys have been processed, save and do tag
--var_insn_mem(38) := X"201F"; --j ENCRYPT_lOOP
---- SAVE_ENCRYPT
--var_insn_mem(39) := X"9018"; --addi ri, $0, 8
--var_insn_mem(40) := X"bB1B"; --sub rkp rkp ri   ;rkp - 8 -> returned to original value
--var_insn_mem(41) := X"7720"; --sb re ros 0     ;store the output byte
--var_insn_mem(42) := X"9771"; --addi ros ros 1  ;increment output str pointer
--
---- DOTAG--DOTAG:            ; shift encrypted character left by 1 if needed
--
--var_insn_mem(43) := X"AF31"; --slt  ri rk4 rkc  ; if rk1 < 1b80, Msb is 0 -> ri=1
--var_insn_mem(44) := X"0000";
--var_insn_mem(45) := X"0000";
--var_insn_mem(46) := X"0000";
--var_insn_mem(47) := X"4011"; --bne  ri $0 1     ; if ri != 0 (ri == 1), don't shift
--var_insn_mem(48) := X"E221"; --sll  re re 1     ; shift encrypted char left by 1
--var_insn_mem(49) := X"D244"; --xor rT re rT ; XOR the tag with the shifted character ;only the ls 8 bits needed. ;Mask the output of the tag at END
--var_insn_mem(50) := X"AF31"; --slt  ri rk4 rkc  ; if rk4 < 0x80, Msb = 0 -> ri = 1 ; rotate key4 left
--var_insn_mem(51) := X"EFF1"; --sll  rk4 rk4 1   ; shift rk4 left by 1
--var_insn_mem(52) := X"AC38"; --slt  s1 rk1 rkc  ; if rk1 < 0x80, Msb = 0 -> s1 = 1
--var_insn_mem(53) := X"ECC1"; --sll rk1 rk1 1    ; shift rk1 left by 1
--var_insn_mem(54) := X"4011"; --bne  ri $0 1     ; if ri != 0 (ri == 1) don't add carry
--var_insn_mem(55) := X"9CC1"; --addi rk1 rk1 1   ; add carry
--var_insn_mem(56) := X"AD31"; --slt  ri rk2 rkc  ; if rk2 < 0x80, Msb = 0 -> ri = 1
--var_insn_mem(57) := X"EDD1"; --sll rk2 rk2 1    ; shift rk2 left by 1
--var_insn_mem(58) := X"4081"; --bne  s1 $0 1     ; if s1 != 0 (s1 == 1) don't add carry
--var_insn_mem(59) := X"9DD1"; --addi rk2 rk2 1   ; add carry
--var_insn_mem(60) := X"AE38"; --slt  s1 rk3 rkc  ; if rk3 < 0x80, Msb = 0 -> s1 = 1
--var_insn_mem(61) := X"EEE1"; --sll rk3 rk3 1    ; shift rk3 left by 1
--var_insn_mem(62) := X"4011"; --bne  ri $0 1     ; if ri != 0 (ri == 1) don't add carry
--var_insn_mem(63) := X"9EE1"; --addi rk3 rk3 1   ; add carry
--var_insn_mem(64) := X"4081"; --bne  s1 $0 1     ; if s1 != 0 (s1 == 1)no Msb to rotate
--var_insn_mem(65) := X"9FF1"; --addi rk4 rk4 1   ; move Msb to lsb
---- DOTaG_ExIT--DOTaG_ExIT:     ; Modify Tag given output and key
--var_insn_mem(66) := X"2014"; --j MAIN
---- END--END:
--var_insn_mem(67) := X"C4A4"; --and rT rT rm1    ;mask the tag
--var_insn_mem(67) := X"7744"; --sb    ;store the tag
--var_insn_mem(68) := X"0000"; --nop              ; Finished.
--var_insn_mem(69) := X"2045"; -- infinite loop



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
