---------------------------------------------------------------------------
-- data_memory.vhd - Implementation of A Single-Port, 16 x 16-bit Data
--                   Memory.
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
 
entity shared_memory is
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           write_enable : in  std_logic;
           read_enable  : in  std_logic;
		   byte_addr_w	: in  std_logic;
           byte_addr_r  : in  std_logic;
           write_data   : in  std_logic_vector(15 downto 0);
           addr_in_r    : in  std_logic_vector(11 downto 0);
           addr_in_w    : in  std_logic_vector(11 downto 0);
           data_out     : out std_logic_vector(15 downto 0));
end shared_memory;

architecture behavioral of shared_memory is

type mem_array is array(0 to 4096) of std_logic_vector(15 downto 0);
signal sig_data_mem : mem_array;
--signal sig_data_mem_tmp : mem_array;
--signal sig_var_addr_b : std_logic_vector (11 downto 0);

signal sig_addr_in_r : std_logic_vector (11 downto 0);
signal sig_addr_in_w : std_logic_vector (11 downto 0);
signal sig_r_type : std_logic_vector(3 downto 0);
--signal sig_addr : std_logic_vector(11 downto 0);

begin
    mem_process: process ( clk,
                           write_enable,
                           write_data,
                           addr_in_r,
                           addr_in_w,
                           read_enable,
						   byte_addr_r,
                           byte_addr_w) is
  
    variable var_data_mem : mem_array;
    variable var_addr_w   : integer;
    variable var_addr_r   : integer;
    variable var_dm_out : std_logic_vector (15 downto 0);
    variable var_r_type : std_logic_vector (3 downto 0);
    
	begin
		var_addr_w := conv_integer(addr_in_w);
		var_addr_w := var_addr_w / 2;
        
        var_addr_r := conv_integer(addr_in_r);
		var_addr_r := var_addr_r / 2;
        
        sig_addr_in_r <= addr_in_r;
        sig_addr_in_w <= addr_in_w;
        
        if (reset = '1') then
        
            --Memory structure
            -- 0        - 7         : pointers and input arguments
            -- 8        - 11        : key
            -- 12       - 15        : padding
            -- 16       - 143       : rng table
            -- 144      - 149       : padding
            -- 150      - (150+x-1) : string length x
            -- 150+x    - 153+x     : padding
            -- 154+x    - 154+2x-1  : output string
            

--var_data_mem(0) := X"0100"; -- 
--var_data_mem(1) := X"0302"; -- 
--var_data_mem(2) := X"0504"; -- 
--var_data_mem(3) := X"0706"; -- 
--var_data_mem(4) := X"0908"; -- 
--var_data_mem(5) := X"0b0a"; -- 
--var_data_mem(6) := X"0d0c"; -- 
--var_data_mem(7) := X"0f0e"; -- 
--var_data_mem(8) := X"1110"; -- 
--var_data_mem(9) := X"1312"; -- 
--var_data_mem(10) := X"1514"; -- 

-- Initial Array

-- Initial Array

var_data_mem(0) := X"0000"; -- Intentionally Left Blank
var_data_mem(1) := X"0184"; -- Pointer to Key
var_data_mem(2) := X"0020"; -- Pointer to Random Table
var_data_mem(3) := X"0130"; -- Pointer to input string
var_data_mem(4) := X"0152"; -- Pointer to output string
var_data_mem(5) := X"000a"; -- m our repetition parameter
var_data_mem(6) := X"000c"; -- n out shift parmeter
var_data_mem(7) := X"0174"; -- Pointer to our tag
var_data_mem(8) := X"0012"; -- string length --Padding 0 of 8
var_data_mem(9) := X"0000"; -- Padding 1 of 8
var_data_mem(10) := X"0000"; -- Padding 2 of 8
var_data_mem(11) := X"0000"; -- Padding 3 of 8
var_data_mem(12) := X"0000"; -- Padding 4 of 8
var_data_mem(13) := X"0000"; -- Padding 5 of 8
var_data_mem(14) := X"0000"; -- Padding 6 of 8
var_data_mem(15) := X"0000"; -- Padding 7 of 8

-- Random 

--var_data_mem(16) := X"0100"; -- randomarray[0]
--var_data_mem(17) := X"0302"; -- randomarray[1]
--var_data_mem(18) := X"0504"; -- randomarray[2]
--var_data_mem(19) := X"0706"; -- randomarray[3]
--var_data_mem(20) := X"0908"; -- randomarray[4]
--var_data_mem(21) := X"0B0A"; -- randomarray[5]
--var_data_mem(22) := X"0D0C"; -- randomarray[6]
--var_data_mem(23) := X"0F0E"; -- randomarray[7]
--var_data_mem(24) := X"1110"; -- randomarray[8]
--var_data_mem(25) := X"1312"; -- randomarray[9]
--var_data_mem(26) := X"1514"; -- randomarray[10]
--var_data_mem(27) := X"1716"; -- randomarray[11]
--var_data_mem(28) := X"1918"; -- randomarray[12]
--var_data_mem(29) := X"1B1A"; -- randomarray[13]
--var_data_mem(30) := X"1D1C"; -- randomarray[14]
--var_data_mem(31) := X"1F1E"; -- randomarray[15]
--var_data_mem(32) := X"2120"; -- randomarray[16]
--var_data_mem(33) := X"2322"; -- randomarray[17]
--var_data_mem(34) := X"2524"; -- randomarray[18]
--var_data_mem(35) := X"2726"; -- randomarray[19]
--var_data_mem(36) := X"2928"; -- randomarray[20]
--var_data_mem(37) := X"2B2A"; -- randomarray[21]
--var_data_mem(38) := X"2D2C"; -- randomarray[22]
--var_data_mem(39) := X"2F2E"; -- randomarray[23]
--var_data_mem(40) := X"3130"; -- randomarray[24]
--var_data_mem(41) := X"3332"; -- randomarray[25]
--var_data_mem(42) := X"3534"; -- randomarray[26]
--var_data_mem(43) := X"3736"; -- randomarray[27]
--var_data_mem(44) := X"3938"; -- randomarray[28]
--var_data_mem(45) := X"3B3A"; -- randomarray[29]
--var_data_mem(46) := X"3D3C"; -- randomarray[30]
--var_data_mem(47) := X"3F3E"; -- randomarray[31]
--var_data_mem(48) := X"4140"; -- randomarray[32]
--var_data_mem(49) := X"4342"; -- randomarray[33]
--var_data_mem(50) := X"4544"; -- randomarray[34]
--var_data_mem(51) := X"4746"; -- randomarray[35]
--var_data_mem(52) := X"4948"; -- randomarray[36]
--var_data_mem(53) := X"4B4A"; -- randomarray[37]
--var_data_mem(54) := X"4D4C"; -- randomarray[38]
--var_data_mem(55) := X"4F4E"; -- randomarray[39]
--var_data_mem(56) := X"5150"; -- randomarray[40]
--var_data_mem(57) := X"5352"; -- randomarray[41]
--var_data_mem(58) := X"5554"; -- randomarray[42]
--var_data_mem(59) := X"5756"; -- randomarray[43]
--var_data_mem(60) := X"5958"; -- randomarray[44]
--var_data_mem(61) := X"5B5A"; -- randomarray[45]
--var_data_mem(62) := X"5D5C"; -- randomarray[46]
--var_data_mem(63) := X"5F5E"; -- randomarray[47]
--var_data_mem(64) := X"6160"; -- randomarray[48]
--var_data_mem(65) := X"6362"; -- randomarray[49]
--var_data_mem(66) := X"6564"; -- randomarray[50]
--var_data_mem(67) := X"6766"; -- randomarray[51]
--var_data_mem(68) := X"6968"; -- randomarray[52]
--var_data_mem(69) := X"6B6A"; -- randomarray[53]
--var_data_mem(70) := X"6D6C"; -- randomarray[54]
--var_data_mem(71) := X"6F6E"; -- randomarray[55]
--var_data_mem(72) := X"7170"; -- randomarray[56]
--var_data_mem(73) := X"7372"; -- randomarray[57]
--var_data_mem(74) := X"7574"; -- randomarray[58]
--var_data_mem(75) := X"7776"; -- randomarray[59]
--var_data_mem(76) := X"7978"; -- randomarray[60]
--var_data_mem(77) := X"7B7A"; -- randomarray[61]
--var_data_mem(78) := X"7D7C"; -- randomarray[62]
--var_data_mem(79) := X"7F7E"; -- randomarray[63]
--var_data_mem(80) := X"8180"; -- randomarray[64]
--var_data_mem(81) := X"8382"; -- randomarray[65]
--var_data_mem(82) := X"8584"; -- randomarray[66]
--var_data_mem(83) := X"8786"; -- randomarray[67]
--var_data_mem(84) := X"8988"; -- randomarray[68]
--var_data_mem(85) := X"8B8A"; -- randomarray[69]
--var_data_mem(86) := X"8D8C"; -- randomarray[70]
--var_data_mem(87) := X"8F8E"; -- randomarray[71]
--var_data_mem(88) := X"9190"; -- randomarray[72]
--var_data_mem(89) := X"9392"; -- randomarray[73]
--var_data_mem(90) := X"9594"; -- randomarray[74]
--var_data_mem(91) := X"9796"; -- randomarray[75]
--var_data_mem(92) := X"9998"; -- randomarray[76]
--var_data_mem(93) := X"9B9A"; -- randomarray[77]
--var_data_mem(94) := X"9D9C"; -- randomarray[78]
--var_data_mem(95) := X"9F9E"; -- randomarray[79]
--var_data_mem(96) := X"A1A0"; -- randomarray[80]
--var_data_mem(97) := X"A3A2"; -- randomarray[81]
--var_data_mem(98) := X"A5A4"; -- randomarray[82]
--var_data_mem(99) := X"A7A6"; -- randomarray[83]
--var_data_mem(100) := X"A9A8"; -- randomarray[84]
--var_data_mem(101) := X"ABAA"; -- randomarray[85]
--var_data_mem(102) := X"ADAC"; -- randomarray[86]
--var_data_mem(103) := X"AFAE"; -- randomarray[87]
--var_data_mem(104) := X"B1B0"; -- randomarray[88]
--var_data_mem(105) := X"B3B2"; -- randomarray[89]
--var_data_mem(106) := X"B5B4"; -- randomarray[90]
--var_data_mem(107) := X"B7B6"; -- randomarray[91]
--var_data_mem(108) := X"B9B8"; -- randomarray[92]
--var_data_mem(109) := X"BBBA"; -- randomarray[93]
--var_data_mem(110) := X"BDBC"; -- randomarray[94]
--var_data_mem(111) := X"BFBE"; -- randomarray[95]
--var_data_mem(112) := X"C1C0"; -- randomarray[96]
--var_data_mem(113) := X"C3C2"; -- randomarray[97]
--var_data_mem(114) := X"C5C4"; -- randomarray[98]
--var_data_mem(115) := X"C7C6"; -- randomarray[99]
--var_data_mem(116) := X"C9C8"; -- randomarray[100]
--var_data_mem(117) := X"CBCA"; -- randomarray[101]
--var_data_mem(118) := X"CDCC"; -- randomarray[102]
--var_data_mem(119) := X"CFCE"; -- randomarray[103]
--var_data_mem(120) := X"D1D0"; -- randomarray[104]
--var_data_mem(121) := X"D3D2"; -- randomarray[105]
--var_data_mem(122) := X"D5D4"; -- randomarray[106]
--var_data_mem(123) := X"D7D6"; -- randomarray[107]
--var_data_mem(124) := X"D9D8"; -- randomarray[108]
--var_data_mem(125) := X"DBDA"; -- randomarray[109]
--var_data_mem(126) := X"DDDC"; -- randomarray[110]
--var_data_mem(127) := X"DFDE"; -- randomarray[111]
--var_data_mem(128) := X"E1E0"; -- randomarray[112]
--var_data_mem(129) := X"E3E2"; -- randomarray[113]
--var_data_mem(130) := X"E5E4"; -- randomarray[114]
--var_data_mem(131) := X"E7E6"; -- randomarray[115]
--var_data_mem(132) := X"E9E8"; -- randomarray[116]
--var_data_mem(133) := X"EBEA"; -- randomarray[117]
--var_data_mem(134) := X"EDEC"; -- randomarray[118]
--var_data_mem(135) := X"EFEE"; -- randomarray[119]
--var_data_mem(136) := X"F1F0"; -- randomarray[120]
--var_data_mem(137) := X"F3F2"; -- randomarray[121]
--var_data_mem(138) := X"F5F4"; -- randomarray[122]
--var_data_mem(139) := X"F7F6"; -- randomarray[123]
--var_data_mem(140) := X"F9F8"; -- randomarray[124]
--var_data_mem(141) := X"FBFA"; -- randomarray[125]
--var_data_mem(142) := X"FDFC"; -- randomarray[126]
--var_data_mem(143) := X"FFFE"; -- randomarray[127]
--var_data_mem(144) := X"0000"; -- Padding 0 of 8
--var_data_mem(145) := X"0000"; -- Padding 1 of 8
--var_data_mem(146) := X"0000"; -- Padding 2 of 8
--var_data_mem(147) := X"0000"; -- Padding 3 of 8
--var_data_mem(148) := X"0000"; -- Padding 4 of 8
--var_data_mem(149) := X"0000"; -- Padding 5 of 8
--var_data_mem(150) := X"0000"; -- Padding 6 of 8
--var_data_mem(151) := X"0000"; -- Padding 7 of 8

var_data_mem(16) := X"13AE"; -- randomarray[0]
var_data_mem(17) := X"602F"; -- randomarray[1]
var_data_mem(18) := X"D585"; -- randomarray[2]
var_data_mem(19) := X"2366"; -- randomarray[3]
var_data_mem(20) := X"B29F"; -- randomarray[4]
var_data_mem(21) := X"6D30"; -- randomarray[5]
var_data_mem(22) := X"88ED"; -- randomarray[6]
var_data_mem(23) := X"4BD1"; -- randomarray[7]
var_data_mem(24) := X"053B"; -- randomarray[8]
var_data_mem(25) := X"DBA1"; -- randomarray[9]
var_data_mem(26) := X"7DE1"; -- randomarray[10]
var_data_mem(27) := X"0DAD"; -- randomarray[11]
var_data_mem(28) := X"F1F0"; -- randomarray[12]
var_data_mem(29) := X"88AF"; -- randomarray[13]
var_data_mem(30) := X"A40F"; -- randomarray[14]
var_data_mem(31) := X"5262"; -- randomarray[15]
var_data_mem(32) := X"B40B"; -- randomarray[16]
var_data_mem(33) := X"59FD"; -- randomarray[17]
var_data_mem(34) := X"A55A"; -- randomarray[18]
var_data_mem(35) := X"501E"; -- randomarray[19]
var_data_mem(36) := X"4621"; -- randomarray[20]
var_data_mem(37) := X"9A82"; -- randomarray[21]
var_data_mem(38) := X"C609"; -- randomarray[22]
var_data_mem(39) := X"B92F"; -- randomarray[23]
var_data_mem(40) := X"4345"; -- randomarray[24]
var_data_mem(41) := X"82A8"; -- randomarray[25]
var_data_mem(42) := X"76BC"; -- randomarray[26]
var_data_mem(43) := X"0450"; -- randomarray[27]
var_data_mem(44) := X"6084"; -- randomarray[28]
var_data_mem(45) := X"C093"; -- randomarray[29]
var_data_mem(46) := X"17EF"; -- randomarray[30]
var_data_mem(47) := X"7574"; -- randomarray[31]
var_data_mem(48) := X"511B"; -- randomarray[32]
var_data_mem(49) := X"61F5"; -- randomarray[33]
var_data_mem(50) := X"7865"; -- randomarray[34]
var_data_mem(51) := X"0822"; -- randomarray[35]
var_data_mem(52) := X"76C9"; -- randomarray[36]
var_data_mem(53) := X"89E0"; -- randomarray[37]
var_data_mem(54) := X"B1E6"; -- randomarray[38]
var_data_mem(55) := X"B97E"; -- randomarray[39]
var_data_mem(56) := X"6572"; -- randomarray[40]
var_data_mem(57) := X"4A53"; -- randomarray[41]
var_data_mem(58) := X"BCB8"; -- randomarray[42]
var_data_mem(59) := X"0419"; -- randomarray[43]
var_data_mem(60) := X"DB4D"; -- randomarray[44]
var_data_mem(61) := X"C4B3"; -- randomarray[45]
var_data_mem(62) := X"896A"; -- randomarray[46]
var_data_mem(63) := X"4F4B"; -- randomarray[47]
var_data_mem(64) := X"0F15"; -- randomarray[48]
var_data_mem(65) := X"4871"; -- randomarray[49]
var_data_mem(66) := X"DF12"; -- randomarray[50]
var_data_mem(67) := X"543B"; -- randomarray[51]
var_data_mem(68) := X"5341"; -- randomarray[52]
var_data_mem(69) := X"742B"; -- randomarray[53]
var_data_mem(70) := X"D299"; -- randomarray[54]
var_data_mem(71) := X"286C"; -- randomarray[55]
var_data_mem(72) := X"ADE7"; -- randomarray[56]
var_data_mem(73) := X"3DD5"; -- randomarray[57]
var_data_mem(74) := X"9793"; -- randomarray[58]
var_data_mem(75) := X"FBE6"; -- randomarray[59]
var_data_mem(76) := X"DE97"; -- randomarray[60]
var_data_mem(77) := X"742E"; -- randomarray[61]
var_data_mem(78) := X"DB44"; -- randomarray[62]
var_data_mem(79) := X"481B"; -- randomarray[63]
var_data_mem(80) := X"5E54"; -- randomarray[64]
var_data_mem(81) := X"E351"; -- randomarray[65]
var_data_mem(82) := X"6B54"; -- randomarray[66]
var_data_mem(83) := X"42AA"; -- randomarray[67]
var_data_mem(84) := X"0F71"; -- randomarray[68]
var_data_mem(85) := X"5E87"; -- randomarray[69]
var_data_mem(86) := X"5237"; -- randomarray[70]
var_data_mem(87) := X"580E"; -- randomarray[71]
var_data_mem(88) := X"6FE3"; -- randomarray[72]
var_data_mem(89) := X"141B"; -- randomarray[73]
var_data_mem(90) := X"C34E"; -- randomarray[74]
var_data_mem(91) := X"D5EB"; -- randomarray[75]
var_data_mem(92) := X"F11B"; -- randomarray[76]
var_data_mem(93) := X"F6E8"; -- randomarray[77]
var_data_mem(94) := X"304F"; -- randomarray[78]
var_data_mem(95) := X"CE1D"; -- randomarray[79]
var_data_mem(96) := X"706F"; -- randomarray[80]
var_data_mem(97) := X"C61D"; -- randomarray[81]
var_data_mem(98) := X"0830"; -- randomarray[82]
var_data_mem(99) := X"137C"; -- randomarray[83]
var_data_mem(100) := X"F7B6"; -- randomarray[84]
var_data_mem(101) := X"B550"; -- randomarray[85]
var_data_mem(102) := X"D443"; -- randomarray[86]
var_data_mem(103) := X"1A1E"; -- randomarray[87]
var_data_mem(104) := X"D470"; -- randomarray[88]
var_data_mem(105) := X"F68B"; -- randomarray[89]
var_data_mem(106) := X"A2F4"; -- randomarray[90]
var_data_mem(107) := X"34F6"; -- randomarray[91]
var_data_mem(108) := X"1308"; -- randomarray[92]
var_data_mem(109) := X"22B3"; -- randomarray[93]
var_data_mem(110) := X"92B4"; -- randomarray[94]
var_data_mem(111) := X"DB2B"; -- randomarray[95]
var_data_mem(112) := X"BA60"; -- randomarray[96]
var_data_mem(113) := X"5B5F"; -- randomarray[97]
var_data_mem(114) := X"D0D6"; -- randomarray[98]
var_data_mem(115) := X"E64B"; -- randomarray[99]
var_data_mem(116) := X"E9F5"; -- randomarray[100]
var_data_mem(117) := X"CFF6"; -- randomarray[101]
var_data_mem(118) := X"DB8D"; -- randomarray[102]
var_data_mem(119) := X"35CA"; -- randomarray[103]
var_data_mem(120) := X"1642"; -- randomarray[104]
var_data_mem(121) := X"507B"; -- randomarray[105]
var_data_mem(122) := X"0367"; -- randomarray[106]
var_data_mem(123) := X"C565"; -- randomarray[107]
var_data_mem(124) := X"DBBA"; -- randomarray[108]
var_data_mem(125) := X"EFDB"; -- randomarray[109]
var_data_mem(126) := X"4D22"; -- randomarray[110]
var_data_mem(127) := X"2E14"; -- randomarray[111]
var_data_mem(128) := X"3F33"; -- randomarray[112]
var_data_mem(129) := X"4EF0"; -- randomarray[113]
var_data_mem(130) := X"3B88"; -- randomarray[114]
var_data_mem(131) := X"076D"; -- randomarray[115]
var_data_mem(132) := X"788E"; -- randomarray[116]
var_data_mem(133) := X"F052"; -- randomarray[117]
var_data_mem(134) := X"EE97"; -- randomarray[118]
var_data_mem(135) := X"4A02"; -- randomarray[119]
var_data_mem(136) := X"2A01"; -- randomarray[120]
var_data_mem(137) := X"5B46"; -- randomarray[121]
var_data_mem(138) := X"80A4"; -- randomarray[122]
var_data_mem(139) := X"A5EF"; -- randomarray[123]
var_data_mem(140) := X"7B24"; -- randomarray[124]
var_data_mem(141) := X"B422"; -- randomarray[125]
var_data_mem(142) := X"C4D5"; -- randomarray[126]
var_data_mem(143) := X"667F"; -- randomarray[127]
var_data_mem(144) := X"0000"; -- Padding 0 of 8
var_data_mem(145) := X"0000"; -- Padding 1 of 8
var_data_mem(146) := X"0000"; -- Padding 2 of 8
var_data_mem(147) := X"0000"; -- Padding 3 of 8
var_data_mem(148) := X"0000"; -- Padding 4 of 8
var_data_mem(149) := X"0000"; -- Padding 5 of 8
var_data_mem(150) := X"0000"; -- Padding 6 of 8
var_data_mem(151) := X"0000"; -- Padding 7 of 8 

-- Input 

var_data_mem(152) := X"2049"; -- inputarray[0] : ' I'
var_data_mem(153) := X"6548"; -- inputarray[1] : 'eH'
var_data_mem(154) := X"7261"; -- inputarray[2] : 'ra'
var_data_mem(155) := X"2074"; -- inputarray[3] : ' t'
var_data_mem(156) := X"7548"; -- inputarray[4] : 'uH'
var_data_mem(157) := X"6B63"; -- inputarray[5] : 'kc'
var_data_mem(158) := X"6261"; -- inputarray[6] : 'ba'
var_data_mem(159) := X"6565"; -- inputarray[7] : 'ee'
var_data_mem(160) := X"2E73"; -- inputarray[8] : '.s'
var_data_mem(161) := X"0000"; -- Padding 0 of 8
var_data_mem(162) := X"0000"; -- Padding 1 of 8
var_data_mem(163) := X"0000"; -- Padding 2 of 8
var_data_mem(164) := X"0000"; -- Padding 3 of 8
var_data_mem(165) := X"0000"; -- Padding 4 of 8 <-- out string
var_data_mem(166) := X"0000"; -- Padding 5 of 8
var_data_mem(167) := X"0000"; -- Padding 6 of 8
var_data_mem(168) := X"0000"; -- Padding 7 of 8

-- Output 

var_data_mem(169) := X"1234"; -- outputarray[0]
var_data_mem(170) := X"5678"; -- outputarray[1]
var_data_mem(171) := X"9ABC"; -- outputarray[2]
var_data_mem(172) := X"DEF0"; -- outputarray[3]
var_data_mem(173) := X"0000"; -- outputarray[4]
var_data_mem(174) := X"0000"; -- outputarray[5]
var_data_mem(175) := X"0000"; -- outputarray[6]
var_data_mem(176) := X"0000"; -- outputarray[7]
var_data_mem(177) := X"0000"; -- outputarray[8]
var_data_mem(178) := X"0000"; -- Padding 0 of 8 <-- tag
var_data_mem(179) := X"0000"; -- Padding 1 of 8
var_data_mem(180) := X"0000"; -- Padding 2 of 8
var_data_mem(181) := X"0000"; -- Padding 3 of 8
var_data_mem(182) := X"0000"; -- Padding 4 of 8
var_data_mem(183) := X"0000"; -- Padding 5 of 8
var_data_mem(184) := X"0000"; -- Padding 6 of 8
var_data_mem(185) := X"0000"; -- Padding 7 of 8
var_data_mem(186) := X"0000"; -- Tag Info 0 of 5
var_data_mem(187) := X"0000"; -- Tag Info 1 of 5
var_data_mem(188) := X"0000"; -- Tag Info 2 of 5
var_data_mem(189) := X"0000"; -- Tag Info 3 of 5
var_data_mem(190) := X"0000"; -- Tag Info 4 of 5
var_data_mem(191) := X"0000"; -- Tag 0 of 3
var_data_mem(192) := X"0000"; -- Tag 1 of 3
var_data_mem(193) := X"0000"; -- Tag 2 of 3

-- Key 

var_data_mem(194) := X"3412"; -- key[0]
var_data_mem(195) := X"7856"; -- key[1]
var_data_mem(196) := X"BC9A"; -- key[2]
var_data_mem(197) := X"F0DE"; -- key[3]
var_data_mem(198) := X"1234"; -- key[0]
var_data_mem(199) := X"5678"; -- key[1]
var_data_mem(200) := X"9abc"; -- key[2]
var_data_mem(201) := X"def0"; -- key[3]

        elsif (falling_edge(clk) and write_enable = '1') then
            -- memory writes on the falling clock edge 
			if(byte_addr_w = '1') then
			-- Take the relevant byte and zero extend
				if(addr_in_w(0) = '1') then
					var_data_mem(var_addr_w)(15 downto 8) := write_data(7 downto 0);
				else
					var_data_mem(var_addr_w)(7 downto 0) := write_data(7 downto 0);		
				end if;
			else 				
		    -- WORD Addressible
                if(addr_in_w(0) = '1') then
                    var_data_mem(var_addr_w)(15 downto 8) := write_data(7 downto 0);
                    var_data_mem(var_addr_w + 1)(7 downto 0) := write_data(15 downto 8);
                else
                    var_data_mem(var_addr_w) := write_data;
                end if;
			end if;
		
		
        elsif(falling_edge(clk) and read_enable = '1') then
            -- Byte Addressible Mode	
            if(byte_addr_r = '1') then
                -- Take the relevant byte and zero extend
                if(addr_in_r(0) = '1') then
                    var_dm_out := X"00" & var_data_mem(var_addr_r)(15 downto 8);
                else
                    var_dm_out := X"00" & var_data_mem(var_addr_r)(7 downto 0);			
                end if;
                var_r_type := x"0";
            else 				
                -- WORD Addressible
                if(addr_in_r(0) = '1') then
                    var_dm_out(7 downto 0) := var_data_mem(var_addr_r)(15 downto 8);
                    var_dm_out(15 downto 8) := var_data_mem(var_addr_r + 1)(7 downto 0);
                else
                    var_dm_out := var_data_mem(var_addr_r);
                end if;
                var_r_type := x"1";
            end if;
        else
            --var_dm_out := x"0000";
            var_r_type := x"2";
        end if;
		
		data_out <= var_dm_out;
		sig_r_type <= var_r_type;
		
        -- the following are probe signals (for simulation purpose) 
        sig_data_mem <= var_data_mem;

    end process;
  
end behavioral;
