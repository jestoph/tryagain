

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
 
entity data_memory is
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           write_enable : in  std_logic;
           read_enable  : in  std_logic;
           byte_addr    : in  std_logic;
           write_data   : in  std_logic_vector(15 downto 0);
           addr_in      : in  std_logic_vector(11 downto 0);
           data_out     : out std_logic_vector(15 downto 0) );
end data_memory;

architecture behavioral of data_memory is

type mem_array is array(0 to 255) of std_logic_vector(15 downto 0);
signal sig_data_mem : mem_array;
--signal sig_data_mem_tmp : mem_array;
--signal sig_var_addr_b : std_logic_vector (11 downto 0);

signal sig_dm_chosen : std_logic_vector (15 downto 0);
--signal sig_addr : std_logic_vector(11 downto 0);

begin
    mem_process: process ( clk,
                           write_enable,
                           write_data,
                           addr_in,
                           read_enable,
                           byte_addr) is
  
    variable var_data_mem : mem_array;
    variable var_addr     : integer;
    variable var_dm_out : std_logic_vector (15 downto 0);
    
    begin
        --var_addr := conv_integer(addr_in);
        
        --var_addr_b (10 downto 0) <= addr_in (11 downto 1);
        var_addr := conv_integer(addr_in);
        var_addr := var_addr / 2;
        
        if (reset = '1') then


-- Initial Array

var_data_mem(0) := X"0010"; -- Offset to key in bytes
var_data_mem(1) := X"0020"; -- Offset to random array in bytes
var_data_mem(2) := X"0128"; -- Offset to Input array in bytes
var_data_mem(3) := X"001A"; -- Length of the input string in bytes + padding
var_data_mem(4) := X"0000"; -- padding
var_data_mem(5) := X"0000"; -- padding
var_data_mem(6) := X"0000"; -- padding
var_data_mem(7) := X"0000"; -- padding

-- Key 

var_data_mem(8) := X"3412"; -- key[0]
var_data_mem(9) := X"7856"; -- key[1]
var_data_mem(10) := X"BC9A"; -- key[2]
var_data_mem(11) := X"F0DE"; -- key[3]
var_data_mem(12) := X"0000"; -- padding
var_data_mem(13) := X"0000"; -- padding
var_data_mem(14) := X"0000"; -- padding
var_data_mem(15) := X"0000"; -- padding

-- Random 

var_data_mem(16) := X"0100"; -- randomarray[0]
var_data_mem(17) := X"0302"; -- randomarray[1]
var_data_mem(18) := X"0504"; -- randomarray[2]
var_data_mem(19) := X"0706"; -- randomarray[3]
var_data_mem(20) := X"0908"; -- randomarray[4]
var_data_mem(21) := X"0B0A"; -- randomarray[5]
var_data_mem(22) := X"0D0C"; -- randomarray[6]
var_data_mem(23) := X"0F0E"; -- randomarray[7]
var_data_mem(24) := X"1110"; -- randomarray[8]
var_data_mem(25) := X"1312"; -- randomarray[9]
var_data_mem(26) := X"1514"; -- randomarray[10]
var_data_mem(27) := X"1716"; -- randomarray[11]
var_data_mem(28) := X"1918"; -- randomarray[12]
var_data_mem(29) := X"1B1A"; -- randomarray[13]
var_data_mem(30) := X"1D1C"; -- randomarray[14]
var_data_mem(31) := X"1F1E"; -- randomarray[15]
var_data_mem(32) := X"2120"; -- randomarray[16]
var_data_mem(33) := X"2322"; -- randomarray[17]
var_data_mem(34) := X"2524"; -- randomarray[18]
var_data_mem(35) := X"2726"; -- randomarray[19]
var_data_mem(36) := X"2928"; -- randomarray[20]
var_data_mem(37) := X"2B2A"; -- randomarray[21]
var_data_mem(38) := X"2D2C"; -- randomarray[22]
var_data_mem(39) := X"2F2E"; -- randomarray[23]
var_data_mem(40) := X"3130"; -- randomarray[24]
var_data_mem(41) := X"3332"; -- randomarray[25]
var_data_mem(42) := X"3534"; -- randomarray[26]
var_data_mem(43) := X"3736"; -- randomarray[27]
var_data_mem(44) := X"3938"; -- randomarray[28]
var_data_mem(45) := X"3B3A"; -- randomarray[29]
var_data_mem(46) := X"3D3C"; -- randomarray[30]
var_data_mem(47) := X"3F3E"; -- randomarray[31]
var_data_mem(48) := X"4140"; -- randomarray[32]
var_data_mem(49) := X"4342"; -- randomarray[33]
var_data_mem(50) := X"4544"; -- randomarray[34]
var_data_mem(51) := X"4746"; -- randomarray[35]
var_data_mem(52) := X"4948"; -- randomarray[36]
var_data_mem(53) := X"4B4A"; -- randomarray[37]
var_data_mem(54) := X"4D4C"; -- randomarray[38]
var_data_mem(55) := X"4F4E"; -- randomarray[39]
var_data_mem(56) := X"5150"; -- randomarray[40]
var_data_mem(57) := X"5352"; -- randomarray[41]
var_data_mem(58) := X"5554"; -- randomarray[42]
var_data_mem(59) := X"5756"; -- randomarray[43]
var_data_mem(60) := X"5958"; -- randomarray[44]
var_data_mem(61) := X"5B5A"; -- randomarray[45]
var_data_mem(62) := X"5D5C"; -- randomarray[46]
var_data_mem(63) := X"5F5E"; -- randomarray[47]
var_data_mem(64) := X"6160"; -- randomarray[48]
var_data_mem(65) := X"6362"; -- randomarray[49]
var_data_mem(66) := X"6564"; -- randomarray[50]
var_data_mem(67) := X"6766"; -- randomarray[51]
var_data_mem(68) := X"6968"; -- randomarray[52]
var_data_mem(69) := X"6B6A"; -- randomarray[53]
var_data_mem(70) := X"6D6C"; -- randomarray[54]
var_data_mem(71) := X"6F6E"; -- randomarray[55]
var_data_mem(72) := X"7170"; -- randomarray[56]
var_data_mem(73) := X"7372"; -- randomarray[57]
var_data_mem(74) := X"7574"; -- randomarray[58]
var_data_mem(75) := X"7776"; -- randomarray[59]
var_data_mem(76) := X"7978"; -- randomarray[60]
var_data_mem(77) := X"7B7A"; -- randomarray[61]
var_data_mem(78) := X"7D7C"; -- randomarray[62]
var_data_mem(79) := X"7F7E"; -- randomarray[63]
var_data_mem(80) := X"8180"; -- randomarray[64]
var_data_mem(81) := X"8382"; -- randomarray[65]
var_data_mem(82) := X"8584"; -- randomarray[66]
var_data_mem(83) := X"8786"; -- randomarray[67]
var_data_mem(84) := X"8988"; -- randomarray[68]
var_data_mem(85) := X"8B8A"; -- randomarray[69]
var_data_mem(86) := X"8D8C"; -- randomarray[70]
var_data_mem(87) := X"8F8E"; -- randomarray[71]
var_data_mem(88) := X"9190"; -- randomarray[72]
var_data_mem(89) := X"9392"; -- randomarray[73]
var_data_mem(90) := X"9594"; -- randomarray[74]
var_data_mem(91) := X"9796"; -- randomarray[75]
var_data_mem(92) := X"9998"; -- randomarray[76]
var_data_mem(93) := X"9B9A"; -- randomarray[77]
var_data_mem(94) := X"9D9C"; -- randomarray[78]
var_data_mem(95) := X"9F9E"; -- randomarray[79]
var_data_mem(96) := X"A1A0"; -- randomarray[80]
var_data_mem(97) := X"A3A2"; -- randomarray[81]
var_data_mem(98) := X"A5A4"; -- randomarray[82]
var_data_mem(99) := X"A7A6"; -- randomarray[83]
var_data_mem(100) := X"A9A8"; -- randomarray[84]
var_data_mem(101) := X"ABAA"; -- randomarray[85]
var_data_mem(102) := X"ADAC"; -- randomarray[86]
var_data_mem(103) := X"AFAE"; -- randomarray[87]
var_data_mem(104) := X"B1B0"; -- randomarray[88]
var_data_mem(105) := X"B3B2"; -- randomarray[89]
var_data_mem(106) := X"B5B4"; -- randomarray[90]
var_data_mem(107) := X"B7B6"; -- randomarray[91]
var_data_mem(108) := X"B9B8"; -- randomarray[92]
var_data_mem(109) := X"BBBA"; -- randomarray[93]
var_data_mem(110) := X"BDBC"; -- randomarray[94]
var_data_mem(111) := X"BFBE"; -- randomarray[95]
var_data_mem(112) := X"C1C0"; -- randomarray[96]
var_data_mem(113) := X"C3C2"; -- randomarray[97]
var_data_mem(114) := X"C5C4"; -- randomarray[98]
var_data_mem(115) := X"C7C6"; -- randomarray[99]
var_data_mem(116) := X"C9C8"; -- randomarray[100]
var_data_mem(117) := X"CBCA"; -- randomarray[101]
var_data_mem(118) := X"CDCC"; -- randomarray[102]
var_data_mem(119) := X"CFCE"; -- randomarray[103]
var_data_mem(120) := X"D1D0"; -- randomarray[104]
var_data_mem(121) := X"D3D2"; -- randomarray[105]
var_data_mem(122) := X"D5D4"; -- randomarray[106]
var_data_mem(123) := X"D7D6"; -- randomarray[107]
var_data_mem(124) := X"D9D8"; -- randomarray[108]
var_data_mem(125) := X"DBDA"; -- randomarray[109]
var_data_mem(126) := X"DDDC"; -- randomarray[110]
var_data_mem(127) := X"DFDE"; -- randomarray[111]
var_data_mem(128) := X"E1E0"; -- randomarray[112]
var_data_mem(129) := X"E3E2"; -- randomarray[113]
var_data_mem(130) := X"E5E4"; -- randomarray[114]
var_data_mem(131) := X"E7E6"; -- randomarray[115]
var_data_mem(132) := X"E9E8"; -- randomarray[116]
var_data_mem(133) := X"EBEA"; -- randomarray[117]
var_data_mem(134) := X"EDEC"; -- randomarray[118]
var_data_mem(135) := X"EFEE"; -- randomarray[119]
var_data_mem(136) := X"F1F0"; -- randomarray[120]
var_data_mem(137) := X"F3F2"; -- randomarray[121]
var_data_mem(138) := X"F5F4"; -- randomarray[122]
var_data_mem(139) := X"F7F6"; -- randomarray[123]
var_data_mem(140) := X"F9F8"; -- randomarray[124]
var_data_mem(141) := X"FBFA"; -- randomarray[125]
var_data_mem(142) := X"FDFC"; -- randomarray[126]
var_data_mem(143) := X"FFFE"; -- randomarray[127]
var_data_mem(144) := X"0000"; -- padding
var_data_mem(145) := X"0000"; -- padding
var_data_mem(146) := X"0000"; -- padding
var_data_mem(147) := X"0000"; -- padding

--var_data_mem(16) := X"0000"; -- randomarray[0]
--var_data_mem(17) := X"0000"; -- randomarray[1]
--var_data_mem(18) := X"0000"; -- randomarray[2]
--var_data_mem(19) := X"0000"; -- randomarray[3]
--var_data_mem(20) := X"0000"; -- randomarray[4]
--var_data_mem(21) := X"0000"; -- randomarray[5]
--var_data_mem(22) := X"0000"; -- randomarray[6]
--var_data_mem(23) := X"0000"; -- randomarray[7]
--var_data_mem(24) := X"0000"; -- randomarray[8]
--var_data_mem(25) := X"0000"; -- randomarray[9]
--var_data_mem(26) := X"0000"; -- randomarray[10]
--var_data_mem(27) := X"0000"; -- randomarray[11]
--var_data_mem(28) := X"0000"; -- randomarray[12]
--var_data_mem(29) := X"0000"; -- randomarray[13]
--var_data_mem(30) := X"0000"; -- randomarray[14]
--var_data_mem(31) := X"0000"; -- randomarray[15]
--var_data_mem(32) := X"0000"; -- randomarray[16]
--var_data_mem(33) := X"0000"; -- randomarray[17]
--var_data_mem(34) := X"0000"; -- randomarray[18]
--var_data_mem(35) := X"0000"; -- randomarray[19]
--var_data_mem(36) := X"0000"; -- randomarray[20]
--var_data_mem(37) := X"0000"; -- randomarray[21]
--var_data_mem(38) := X"0000"; -- randomarray[22]
--var_data_mem(39) := X"0000"; -- randomarray[23]
--var_data_mem(40) := X"0000"; -- randomarray[24]
--var_data_mem(41) := X"0000"; -- randomarray[25]
--var_data_mem(42) := X"0000"; -- randomarray[26]
--var_data_mem(43) := X"0000"; -- randomarray[27]
--var_data_mem(44) := X"0000"; -- randomarray[28]
--var_data_mem(45) := X"0000"; -- randomarray[29]
--var_data_mem(46) := X"0000"; -- randomarray[30]
--var_data_mem(47) := X"0000"; -- randomarray[31]
--var_data_mem(48) := X"0000"; -- randomarray[32]
--var_data_mem(49) := X"0000"; -- randomarray[33]
--var_data_mem(50) := X"0000"; -- randomarray[34]
--var_data_mem(51) := X"0000"; -- randomarray[35]
--var_data_mem(52) := X"0000"; -- randomarray[36]
--var_data_mem(53) := X"0000"; -- randomarray[37]
--var_data_mem(54) := X"0000"; -- randomarray[38]
--var_data_mem(55) := X"0000"; -- randomarray[39]
--var_data_mem(56) := X"0000"; -- randomarray[40]
--var_data_mem(57) := X"0000"; -- randomarray[41]
--var_data_mem(58) := X"0000"; -- randomarray[42]
--var_data_mem(59) := X"0000"; -- randomarray[43]
--var_data_mem(60) := X"0000"; -- randomarray[44]
--var_data_mem(61) := X"0000"; -- randomarray[45]
--var_data_mem(62) := X"0000"; -- randomarray[46]
--var_data_mem(63) := X"0000"; -- randomarray[47]
--var_data_mem(64) := X"0000"; -- randomarray[48]
--var_data_mem(65) := X"0000"; -- randomarray[49]
--var_data_mem(66) := X"0000"; -- randomarray[50]
--var_data_mem(67) := X"0000"; -- randomarray[51]
--var_data_mem(68) := X"0000"; -- randomarray[52]
--var_data_mem(69) := X"0000"; -- randomarray[53]
--var_data_mem(70) := X"0000"; -- randomarray[54]
--var_data_mem(71) := X"0000"; -- randomarray[55]
--var_data_mem(72) := X"0000"; -- randomarray[56]
--var_data_mem(73) := X"0000"; -- randomarray[57]
--var_data_mem(74) := X"0000"; -- randomarray[58]
--var_data_mem(75) := X"0000"; -- randomarray[59]
--var_data_mem(76) := X"0000"; -- randomarray[60]
--var_data_mem(77) := X"0000"; -- randomarray[61]
--var_data_mem(78) := X"0000"; -- randomarray[62]
--var_data_mem(79) := X"0000"; -- randomarray[63]
--var_data_mem(80) := X"0000"; -- randomarray[64]
--var_data_mem(81) := X"0000"; -- randomarray[65]
--var_data_mem(82) := X"0000"; -- randomarray[66]
--var_data_mem(83) := X"0000"; -- randomarray[67]
--var_data_mem(84) := X"0000"; -- randomarray[68]
--var_data_mem(85) := X"0000"; -- randomarray[69]
--var_data_mem(86) := X"0000"; -- randomarray[70]
--var_data_mem(87) := X"0000"; -- randomarray[71]
--var_data_mem(88) := X"0000"; -- randomarray[72]
--var_data_mem(89) := X"0000"; -- randomarray[73]
--var_data_mem(90) := X"0000"; -- randomarray[74]
--var_data_mem(91) := X"0000"; -- randomarray[75]
--var_data_mem(92) := X"0000"; -- randomarray[76]
--var_data_mem(93) := X"0000"; -- randomarray[77]
--var_data_mem(94) := X"0000"; -- randomarray[78]
--var_data_mem(95) := X"0000"; -- randomarray[79]
--var_data_mem(96) := X"0000"; -- randomarray[80]
--var_data_mem(97) := X"0000"; -- randomarray[81]
--var_data_mem(98) := X"0000"; -- randomarray[82]
--var_data_mem(99) := X"0000"; -- randomarray[83]
--var_data_mem(100) := X"0000"; -- randomarray[84]
--var_data_mem(101) := X"0000"; -- randomarray[85]
--var_data_mem(102) := X"0000"; -- randomarray[86]
--var_data_mem(103) := X"0000"; -- randomarray[87]
--var_data_mem(104) := X"0000"; -- randomarray[88]
--var_data_mem(105) := X"0000"; -- randomarray[89]
--var_data_mem(106) := X"0000"; -- randomarray[90]
--var_data_mem(107) := X"0000"; -- randomarray[91]
--var_data_mem(108) := X"0000"; -- randomarray[92]
--var_data_mem(109) := X"0000"; -- randomarray[93]
--var_data_mem(110) := X"0000"; -- randomarray[94]
--var_data_mem(111) := X"0000"; -- randomarray[95]
--var_data_mem(112) := X"0000"; -- randomarray[96]
--var_data_mem(113) := X"0000"; -- randomarray[97]
--var_data_mem(114) := X"0000"; -- randomarray[98]
--var_data_mem(115) := X"0000"; -- randomarray[99]
--var_data_mem(116) := X"0000"; -- randomarray[100]
--var_data_mem(117) := X"0000"; -- randomarray[101]
--var_data_mem(118) := X"0000"; -- randomarray[102]
--var_data_mem(119) := X"0000"; -- randomarray[103]
--var_data_mem(120) := X"0000"; -- randomarray[104]
--var_data_mem(121) := X"0000"; -- randomarray[105]
--var_data_mem(122) := X"0000"; -- randomarray[106]
--var_data_mem(123) := X"0000"; -- randomarray[107]
--var_data_mem(124) := X"0000"; -- randomarray[108]
--var_data_mem(125) := X"0000"; -- randomarray[109]
--var_data_mem(126) := X"0000"; -- randomarray[110]
--var_data_mem(127) := X"0000"; -- randomarray[111]
--var_data_mem(128) := X"0000"; -- randomarray[112]
--var_data_mem(129) := X"0000"; -- randomarray[113]
--var_data_mem(130) := X"0000"; -- randomarray[114]
--var_data_mem(131) := X"0000"; -- randomarray[115]
--var_data_mem(132) := X"0000"; -- randomarray[116]
--var_data_mem(133) := X"0000"; -- randomarray[117]
--var_data_mem(134) := X"0000"; -- randomarray[118]
--var_data_mem(135) := X"0000"; -- randomarray[119]
--var_data_mem(136) := X"0000"; -- randomarray[120]
--var_data_mem(137) := X"0000"; -- randomarray[121]
--var_data_mem(138) := X"0000"; -- randomarray[122]
--var_data_mem(139) := X"0000"; -- randomarray[123]
--var_data_mem(140) := X"0000"; -- randomarray[124]
--var_data_mem(141) := X"0000"; -- randomarray[125]
--var_data_mem(142) := X"0000"; -- randomarray[126]
--var_data_mem(143) := X"0000"; -- randomarray[127]
--var_data_mem(144) := X"0000"; -- padding
--var_data_mem(145) := X"0000"; -- padding
--var_data_mem(146) := X"0000"; -- padding
--var_data_mem(147) := X"0000"; -- padding

-- Input 

var_data_mem(148) := X"2049"; -- inputarray[0] : ' I'
var_data_mem(149) := X"6548"; -- inputarray[1] : 'eH'
var_data_mem(150) := X"7261"; -- inputarray[2] : 'ra'
var_data_mem(151) := X"2074"; -- inputarray[3] : ' t'
var_data_mem(152) := X"7548"; -- inputarray[4] : 'uH'
var_data_mem(153) := X"6B63"; -- inputarray[5] : 'kc'
var_data_mem(154) := X"6261"; -- inputarray[6] : 'ba'
var_data_mem(155) := X"6565"; -- inputarray[7] : 'ee'
var_data_mem(156) := X"2E73"; -- inputarray[8] : '.s'
var_data_mem(157) := X"0000"; -- padding
var_data_mem(158) := X"0000"; -- padding
var_data_mem(159) := X"0000"; -- padding
var_data_mem(160) := X"0000"; -- padding

-- Output 

var_data_mem(161) := X"1234"; -- outputarray[0]
var_data_mem(162) := X"5678"; -- outputarray[1]
var_data_mem(163) := X"9ABC"; -- outputarray[2]
var_data_mem(164) := X"DEF0"; -- outputarray[3]
var_data_mem(165) := X"0000"; -- outputarray[4]
var_data_mem(166) := X"0000"; -- outputarray[5]
var_data_mem(167) := X"0000"; -- outputarray[6]
var_data_mem(168) := X"0000"; -- outputarray[7]
var_data_mem(169) := X"0000"; -- outputarray[8]
var_data_mem(170) := X"0000"; -- padding
var_data_mem(171) := X"0000"; -- padding
var_data_mem(172) := X"0000"; -- padding
var_data_mem(173) := X"0000"; -- padding



        elsif (falling_edge(clk) and write_enable = '1') then
            -- memory writes on the falling clock edge 
            if(byte_addr = '1') then
            -- Take the relevant byte and zero extend
                if(addr_in(0) = '1') then
                    var_data_mem(var_addr)(15 downto 8) := write_data(7 downto 0);
                else
                    var_data_mem(var_addr)(7 downto 0) := write_data(7 downto 0);       
                end if;
            else                
            -- WORD Addressible
                if(addr_in(0) = '1') then
                    var_data_mem(var_addr)(15 downto 8) := write_data(7 downto 0);
                    var_data_mem(var_addr + 1)(7 downto 0) := write_data(15 downto 8);
                else
                    var_data_mem(var_addr) := write_data;
                end if;
            end if;
        
            
            --var_data_mem(var_addr) := write_data;
        end if;
       
        -- continuous read of the memory location given by var_addr 
        --data_out <= var_data_mem(var_addr);
        
        if(read_enable = '1') then
            -- Byte Addressible Mode
            report "The Address Requested is " & integer'image(var_addr);   
            if(byte_addr = '1') then
                -- Take the relevant byte and zero extend
                if(addr_in(0) = '1') then
                    var_dm_out := X"00" & var_data_mem(var_addr)(15 downto 8);
                else
                    var_dm_out := X"00" & var_data_mem(var_addr)(7 downto 0);           
                end if;
            else                
                -- WORD Addressible
                if(addr_in(0) = '1') then
                    var_dm_out(7 downto 0) := var_data_mem(var_addr)(15 downto 8);
                    var_dm_out(15 downto 8) := var_data_mem(var_addr + 1)(7 downto 0);
                else
                    var_dm_out := var_data_mem(var_addr);
                end if;
            end if;
        else
            var_dm_out := "0000000000000000";
        end if;
        
        data_out <= var_dm_out after 2.9 ns;
        
        
        -- the following are probe signals (for simulation purpose) 
        sig_data_mem <= var_data_mem;

    end process;
  
end behavioral;


