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

type mem_array is array(0 to 256) of std_logic_vector(15 downto 0);
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
  
--            var_insn_mem(0)  := X"1055";
--            var_insn_mem(1)  := X"1022";
--            var_insn_mem(2)  := X"8013";
--            var_insn_mem(3)  := X"8124";
--            var_insn_mem(4)  := X"3031";
--            var_insn_mem(5)  := X"3043";
--            var_insn_mem(6)  := X"3054";
--            var_insn_mem(7)  := X"0000";
--            var_insn_mem(8)  := X"0000";
--            var_insn_mem(9)  := X"0000";
--            var_insn_mem(10) := X"0000";
--            var_insn_mem(11) := X"0000";
--            var_insn_mem(12) := X"0000";
--            var_insn_mem(13) := X"0000";
--            var_insn_mem(14) := X"0000";
--            var_insn_mem(15) := X"0000";
--            
--            var_insn_mem(0)  := X"5010"; -- load core number to $1
--            var_insn_mem(1)  := X"e121"; -- $2 = 2 x $1
--            var_insn_mem(2)  := X"0000";--922f"; -- $2 = $2 - 1
--            var_insn_mem(3)  := X"5231"; -- $3 = mem($2 + 1)
--            var_insn_mem(4)  := X"5240"; -- $4 = mem($2)
--            var_insn_mem(5)  := X"8435"; -- $5 = $4 + $3
--            var_insn_mem(6)  := X"7221";
--            var_insn_mem(7)  := X"7246";
--            var_insn_mem(8)  := X"7257";
--            var_insn_mem(9)  := X"0000";
--            var_insn_mem(10) := X"0000";
--            var_insn_mem(11) := X"0000";
--            var_insn_mem(12) := X"0000";
--            var_insn_mem(13) := X"0000";
--            var_insn_mem(14) := X"0000";
--            var_insn_mem(15) := X"0000";

--#//////////////////////////////////////////////////
--#//
--#// Define registers
--#// $0    r0    zero
--#// $1    rc    core number
--#// $2    rm    value of m (encrypt iterations)
--#// $3    rn    value of n (tag iterations)
--#// $4    rsz    size of string
--#// $5    s1    scratch 1
--#// $6    s2 re    scratch 2
--#// $7    s3 rkc    scratch 3
--#// $8    ris    Pointer to input string
--#// $9    ros    Pointer to output string
--#// $10    rrn    Pointer to RNG table
--#// $11    rkp  Initially pointer to key
--#// $12    rk1     63 : 48 key copy (initially pointer to key)
--#// $13    rk2     47 : 32 key copy
--#// $14    rk3     31 : 16 key copy
--#// $15    rk4     15 : 0  key copy
--#//
--#////////////////////////////////////////////////
var_insn_mem(0) := X"0000"; --nop
var_insn_mem(1) := X"0000"; --nop
var_insn_mem(2) := X"0000"; --nop
var_insn_mem(3) := X"0000"; --nop
var_insn_mem(4) := X"0000"; --nop
var_insn_mem(5) := X"0000"; --nop
var_insn_mem(6) := X"904e"; --addi rsz, r0, 0xe
var_insn_mem(7) := X"1442"; --lw rsz, rsz, 0x2 #load size of string
--# INITIALISATION
var_insn_mem(8) := X"10B2"; --lw  rkp  r0  0x2      #  Load  Key     address
var_insn_mem(9) := X"10A4"; --lw  rrn  r0  0x4      #  Load  Random  Table
var_insn_mem(10) := X"1086"; --lw  ris  r0  0x6      #  Load  Input   address
var_insn_mem(11) := X"1098"; --lw  ros  r0  0x8      #  Load  output  address
var_insn_mem(12) := X"5010"; --lb  rc   r0  0x0     #  load  core    number
var_insn_mem(13) := X"102A"; --lw  rm   r0  0xa     #  load  value   of       m
var_insn_mem(14) := X"103C"; --lw  rn   r0  0xc     #  load  value   of       n
var_insn_mem(15) := X"8818"; --add  ris  ris  rc   #//set    offset
var_insn_mem(16) := X"8919"; --add  ros  ros  rc   #//set    offset
var_insn_mem(17) := X"8005"; --add  s1   r0   r0   #//clear  scratch  registers
var_insn_mem(18) := X"8006"; --add  s2   r0   r0   #//clear  scratch  registers
var_insn_mem(19) := X"8007"; --add  s3   r0   r0   #//clear  scratch  registers
var_insn_mem(20) := X"90C7"; --addi  rk1  r0   0x7  #//make      a         mask  for  the  loop  counter
--var_insn_mem(21) := X"90FF"; --addi  rk4  r0   0xF  #//00000000  00111111
--var_insn_mem(22) := X"EFF4"; --sll   rk4  rk4  0x4  #//00000000  11111100
--var_insn_mem(23) := X"9FFF"; --addi  rk4  rk4  0xF  #//00000000  11111111
var_insn_mem(21) := X"90F7"; -- addi rk4 r0 0x7
var_insn_mem(22) := X"0000";
var_insn_mem(23) := X"0000";

var_insn_mem(24) := X"9071"; --addi s3, r0, 1 initialize
var_insn_mem(25) := X"8015"; --add s1, r0, rc
var_insn_mem(26) := X"0000"; --nop
--#//begin encryption
--#//s1 keeps track of number of characters processed
--#//s2 keeps track of encrypted character
--#//s3 keeps track of the iteration number of the encrypt loop
-- ENCRYPT_STRING--ENCRYPT_STRING:
--#//if chars_processed > num_chars finish
var_insn_mem(27) := X"4071"; --bne s3 r0 ENCRYPT_CHAR    #//encrypt if s3 == 1
var_insn_mem(28) := X"2035"; --j   END_ENCRYPT_STRING
-- ENCRYPT_CHAR--ENCRYPT_CHAR:
var_insn_mem(29) := X"5860"; --lb   re  ris 0x0   #//load character to encrypt
var_insn_mem(30) := X"9884"; --addi ris ris 0x4   #//increase in string pointer
var_insn_mem(31) := X"9BD0"; --addi rk2 rkp 0x0   #//place key pointer in rk2
var_insn_mem(32) := X"8007"; --add  s3  r0  r0    #//reset the loop counter
-- ENCRYPT_LOOP--ENCRYPT_LOOP:
var_insn_mem(33) := X"9771"; --addi  s3  s3  0x1           #//increment loop counter

var_insn_mem(34) := X"0000"; --nop   
var_insn_mem(35) := X"C7FE"; --and   rk3 s3  rk4           #//get the next subkey index (<8)
var_insn_mem(36) := X"5DD0"; --lb    rk2 rk2 0x0           #//load subkey
var_insn_mem(37) := X"D6D6"; --xor   re  re  rk2           #//xor char with subkey
var_insn_mem(38) := X"86AD"; --add   rk2 re  rrn           #//get a new table pointer
var_insn_mem(39) := X"0000"; --nop don't maskand   rk2 rk2 rk4           #//mask the table pointer
var_insn_mem(40) := X"5D60"; --lb    re  rk2 0x0           #//load table value
var_insn_mem(41) := X"8EBD"; --add   rk2 rk3 rkp           #//update key pointer
var_insn_mem(42) := X"6271"; --beq   s3 rm ENCRYPT_SAVE   #//if counter !< m save character
var_insn_mem(43) := X"2021"; --j     ENCRYPT_LOOP
-- ENCRYPT_SAVE--ENCRYPT_SAVE:

var_insn_mem(44) := X"9077"; -- addi s3 r0 //make 0x7 mask
var_insn_mem(45) := X"E774"; -- sll s3 s3 4
var_insn_mem(46) := X"977f"; -- addi s3 s3 0xf
var_insn_mem(47) := X"c676"; -- and re re s3

var_insn_mem(48) := X"9554"; --addi  s1  s1  0x4           #//inc num of chars processed by 4


var_insn_mem(49) := X"A547"; --slt   s3  s1  rsz            #//if rsz>s1 s3=1
var_insn_mem(50) := X"7960"; --sb    re  ros 0x0           #//store encrypted character
var_insn_mem(51) := X"9994"; --addi  ros ros 0x4           #//increment out string pointer
var_insn_mem(52) := X"201B"; --j     ENCRYPT_STRING

--var_insn_mem(49) := X"0000";
--var_insn_mem(50) := X"0000";
--var_insn_mem(51) := X"0000";
--var_insn_mem(52) := X"0000";
--var_insn_mem(53) := X"0000";
--var_insn_mem(54) := X"0000";
--var_insn_mem(55) := X"0000";
--var_insn_mem(56) := X"0000";
--var_insn_mem(57) := X"0000";
--var_insn_mem(58) := X"0000";
--var_insn_mem(59) := X"0000";
--var_insn_mem(60) := X"2031";


-- END_ENCRYPT_STRING--END_ENCRYPT_STRING:
-- DOTAG--DOTAG:
var_insn_mem(53) := X"800a"; --initialize rnn

var_insn_mem(54) := X"1BF8"; --lw    rk4 rkp 0xe
var_insn_mem(55) := X"1BEa"; --lw    rk3 rkp 0xc
var_insn_mem(56) := X"1BDc"; --lw    rk2 rkp 0xa
var_insn_mem(57) := X"1BCe"; --lw    rk1 rkp 0x8
--KEY_PREP_START:
var_insn_mem(58) := X"4a11";
var_insn_mem(59) := X"204a"; -- J KEY_PREP_END
var_insn_mem(60) := X"9aa1";
var_insn_mem(61) := X"fcbf";
var_insn_mem(62) := X"ecc1";
var_insn_mem(63) := X"fd2f";
var_insn_mem(64) := X"edd1";
var_insn_mem(65) := X"8dbd";
var_insn_mem(66) := X"febf";
var_insn_mem(67) := X"eee1";
var_insn_mem(68) := X"8e2e";
var_insn_mem(69) := X"ff2f";
var_insn_mem(70) := X"eff1";
var_insn_mem(71) := X"8fbf";
var_insn_mem(72) := X"8c2c";
var_insn_mem(73) := X"203a"; -- J KEY_PREP_START go back to prep start
--KEY_PREP_END:
--#//strategy:
--#//each processor will xor their own tags. Store tags at mem(tag + 2 + core id)
--#// when each processor finishes its tag generation it will set mem(tag + 2 + core id + 4) to ff
--#// processor 3 will (theoretically) finish last.
--#//Core 3 will poll mem(tag + 2 + 6 + (012)) to see if other processors are done
--#//once it's done core 3 will xor everyones results and place it in mem(tag)
--#//available registers:
--#//re s1 s3 rkp rrn rm
--#// rkp: rkc 0x800
--#// re: re…
--#// rrn: s1
--#// rm: ri
--#// ris: tag / tag pointer
--#//s1 keeps track of number of characters processed
--#//s3 keeps track of the iteration number of the tag loop
--# load constants
--#rkc    key comparison = 0x8000 for doshift
var_insn_mem(74) := X"90a1"; --addi    rrn $0  0x1         # load 0x0001
var_insn_mem(75) := X"Eaaf"; --sll     rrn rrn 0x15        # make 0x8000
var_insn_mem(76) := X"1098"; --lw   ros $0 0xc             # Load output string pointer
var_insn_mem(77) := X"8919"; --add  ros ros rc             #//get out string offset
var_insn_mem(78) := X"9021"; --nop  addi rm r0 1           #make 0x8000
var_insn_mem(79) := X"e22f"; --nop  sll  rm rm f
var_insn_mem(80) := X"0000"; --nop
var_insn_mem(81) := X"8005"; --add   s1  r0  r0            #//initialize s1
var_insn_mem(82) := X"8008"; --add   ris r0  r0            #//initialize tag
var_insn_mem(83) := X"8007"; --add   s3  r0  r0            #//initialize s3
-- DOTAG_STRING--DOTAG_STRING:
--#//if chars_processed > num_chars finish
var_insn_mem(84) := X"A547"; --slt   s3 s1 rsz             #//if rsz>s1 s3=1
var_insn_mem(85) := X"9554"; --addi  s1 s1 0x4             #// increment counter
var_insn_mem(86) := X"0000"; --nop
var_insn_mem(87) := X"0000"; --nop
var_insn_mem(88) := X"4071"; --bne   s3 r0 DOTAG_CHAR      #//make tag if s3 == 1
var_insn_mem(89) := X"2076"; --j     END_DOTAG_STRING
-- DOTAG_CHAR--DOTAG_CHAR:
var_insn_mem(90) := X"5960"; --lb    re  ros  0x0           #//load character to tag
var_insn_mem(91) := X"Afa2"; --slt   rm  rk4  rrn          # if rk4 < 1b80 MSB is 0 -> ri=1
var_insn_mem(92) := X"9994"; --addi  ros ros  0x4           #//increase out string pointer
var_insn_mem(93) := X"8007"; --add   s3  r0   r0            #//reset the  loop counter


var_insn_mem(94) := X"0000"; --nop
var_insn_mem(95) := X"0000"; --nop
var_insn_mem(96) := X"4206"; --bne   rm $0 DONT_SHIFT      # if ri != 0 (ri == 1) don'tshift
var_insn_mem(97) := X"0000"; --nop
-- DOTAG_LOOP--DOTAG_LOOP: #//shift re n times
var_insn_mem(98) := X"6374"; --beq   s3 rn  DONT_SHIFT #don't shift if loop number reached
var_insn_mem(99) := X"9771"; --addi  s3  s3  0x1        #//increment counter
var_insn_mem(100) := X"0000"; --nop slt   rrn s3  rn    # //rrn = 1 if s3 < rn
var_insn_mem(101) := X"E661"; --sll   re  re  0x1     # shift encrypted char left by 1

var_insn_mem(102) := X"2062"; --j     DOTAG_LOOP
-- DONT_SHIFT--DONT_SHIFT:
--# XOR the tag with the shifted character
var_insn_mem(103) := X"D688"; --xor   ris re  ris    #only the LS 8 bits needed.
--#Mask the output of the tag at END
--# rotate key4s left
var_insn_mem(104) := X"9aa4";
var_insn_mem(105) := X"fcbc";
var_insn_mem(106) := X"ecc4";
var_insn_mem(107) := X"fd2c";
var_insn_mem(108) := X"edd4";
var_insn_mem(109) := X"8dbd";
var_insn_mem(110) := X"febc";
var_insn_mem(111) := X"eee4";
var_insn_mem(112) := X"8e2e";
var_insn_mem(113) := X"ff2c";
var_insn_mem(114) := X"eff4";
var_insn_mem(115) := X"8fbf";
var_insn_mem(116) := X"8c2c";

var_insn_mem(117) := X"2054"; --j DOTAG_STRING

-- END_DOTAG_STRING--END_DOTAG_STRING:
var_insn_mem(118) := X"90A3"; --addi  rrn  r0  0x3      #load core number 3 into rrn
var_insn_mem(119) := X"106E"; --lw    re   r0  0xe      # Load tag pointer
var_insn_mem(120) := X"8616"; --add   re   re  rc       #//get tag offset
var_insn_mem(121) := X"90Cf"; --addi  rk1  r0  0x15
var_insn_mem(122) := X"0000"; --nop--sll   rk1  rk1 0x4
var_insn_mem(123) := X"0000"; --nop--addi  rk1  rk1 0x15     # //generate 0xff code
var_insn_mem(124) := X"7682"; --sb    ris  re  0x2
var_insn_mem(125) := X"76C6"; --sb    rk1  re  0x6      # //store operation complete code
var_insn_mem(126) := X"b616"; --sub    re re rc         #//revert tag pointer
var_insn_mem(127) := X"61A1"; --beq   rrn  rc COMPILE_TAG   #    // make tag if this is core 3
var_insn_mem(128) := X"20a5"; --j    EXIT
-- COMPILE_TAG--COMPILE_TAG:
--#//wait for other cores to finish
-- WAIT_0--WAIT_0:
var_insn_mem(129) := X"56A6"; --lb    rrn re 0x6
--var_insn_mem(111) := X"0000"; --nop
var_insn_mem(130) := X"0000"; --nop
var_insn_mem(131) := X"0000"; --nop
var_insn_mem(132) := X"6AC1"; --beq  rk1 rrn WAIT_1
var_insn_mem(133) := X"2081"; --j WAIT_0
-- WAIT_1--WAIT_1:
var_insn_mem(134) := X"56A7"; --lb    rrn re 0x7
var_insn_mem(135) := X"0000"; --nop
var_insn_mem(136) := X"0000"; --nop
var_insn_mem(137) := X"0000"; --nop
var_insn_mem(138) := X"6AC1"; --beq  rk1 rrn WAIT_2
var_insn_mem(139) := X"2086"; --j WAIT_1
-- WAIT_2--WAIT_2:
var_insn_mem(140) := X"56A8"; --lb    rrn re 0x8
var_insn_mem(141) := X"0000"; --nop
var_insn_mem(142) := X"0000"; --nop
var_insn_mem(143) := X"0000"; --nop
var_insn_mem(144) := X"6AC1"; --beq  rk1 rrn XOR_TAGS
var_insn_mem(145) := X"208c"; --j WAIT_2
-- XOR_TAGS--XOR_TAGS:
var_insn_mem(146) := X"56A5"; --lb    rrn re 0x5 #//load the tags
var_insn_mem(147) := X"56D2"; --lb    rk2 re 0x2
var_insn_mem(148) := X"56E3"; --lb    rk3 re 0x3
var_insn_mem(149) := X"56F4"; --lb    rk4 re 0x4
var_insn_mem(150) := X"DDAA"; --xor   rrn rk2 rrn
var_insn_mem(151) := X"DEAA"; --xor   rrn rk3 rrn
var_insn_mem(152) := X"DFAA"; --xor   rrn rk4 rrn #//xor the tags
var_insn_mem(153) := X"0000"; --nop
var_insn_mem(154) := X"0000"; --nop
var_insn_mem(155) := X"0000"; --nop
var_insn_mem(156) := X"0000"; --nop
var_insn_mem(157) := X"0000"; --nop
var_insn_mem(158) := X"36A0"; --sw    rrn  re 0x0
var_insn_mem(159) := X"36AA"; --sw    rrn  re 0xa
var_insn_mem(160) := X"36AB"; --sw    rrn  re 0xb
var_insn_mem(161) := X"36AC"; --sw    rrn  re 0xc
var_insn_mem(162) := X"36AD"; --sw    rrn  re 0xd
var_insn_mem(163) := X"36AE"; --sw    rrn  re 0xe
var_insn_mem(164) := X"36AF"; --sw    rrn  re 0xf
-- EXIT--EXIT:
var_insn_mem(165) := X"0000"; --nop
var_insn_mem(166) := X"0000"; --nop
var_insn_mem(167) := X"0000"; --nop
var_insn_mem(168) := X"0000"; --nop
var_insn_mem(169) := X"20a5"; --nop


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
