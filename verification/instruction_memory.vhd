

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

type mem_array is array(0 to 59) of std_logic_vector(15 downto 0);
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

var_dat_mem(0) := X"0010"; -- Offset to key in bytes
var_dat_mem(1) := X"0020" -- Offset to random array in bytes
var_dat_mem(2) := X"00A8" -- Offset to Input array in bytes
var_dat_mem(3) := X"0020" -- Length of the input string in bytes (including padding)
var_dat_mem(4) := X"0000" -- padding
var_dat_mem(5) := X"0000" -- padding
var_dat_mem(6) := X"0000" -- padding
var_dat_mem(7) := X"0000" -- padding

-- Key 

var_dat_mem(8) := X"3412" -- key[0]
var_dat_mem(9) := X"7856" -- key[1]
var_dat_mem(10) := X"BC9A" -- key[2]
var_dat_mem(11) := X"F0DE" -- key[3]
var_dat_mem(12) := X"0000" -- padding
var_dat_mem(13) := X"0000" -- padding
var_dat_mem(14) := X"0000" -- padding
var_dat_mem(15) := X"0000" -- padding

-- Random 

var_dat_mem(16) := X"0100" -- randomarray[0]
var_dat_mem(17) := X"0302" -- randomarray[1]
var_dat_mem(18) := X"0504" -- randomarray[2]
var_dat_mem(19) := X"0706" -- randomarray[3]
var_dat_mem(20) := X"0908" -- randomarray[4]
var_dat_mem(21) := X"0B0A" -- randomarray[5]
var_dat_mem(22) := X"0D0C" -- randomarray[6]
var_dat_mem(23) := X"0F0E" -- randomarray[7]
var_dat_mem(24) := X"1110" -- randomarray[8]
var_dat_mem(25) := X"1312" -- randomarray[9]
var_dat_mem(26) := X"1514" -- randomarray[10]
var_dat_mem(27) := X"1716" -- randomarray[11]
var_dat_mem(28) := X"1918" -- randomarray[12]
var_dat_mem(29) := X"1B1A" -- randomarray[13]
var_dat_mem(30) := X"1D1C" -- randomarray[14]
var_dat_mem(31) := X"1F1E" -- randomarray[15]
var_dat_mem(32) := X"2120" -- randomarray[16]
var_dat_mem(33) := X"2322" -- randomarray[17]
var_dat_mem(34) := X"2524" -- randomarray[18]
var_dat_mem(35) := X"2726" -- randomarray[19]
var_dat_mem(36) := X"2928" -- randomarray[20]
var_dat_mem(37) := X"2B2A" -- randomarray[21]
var_dat_mem(38) := X"2D2C" -- randomarray[22]
var_dat_mem(39) := X"2F2E" -- randomarray[23]
var_dat_mem(40) := X"3130" -- randomarray[24]
var_dat_mem(41) := X"3332" -- randomarray[25]
var_dat_mem(42) := X"3534" -- randomarray[26]
var_dat_mem(43) := X"3736" -- randomarray[27]
var_dat_mem(44) := X"3938" -- randomarray[28]
var_dat_mem(45) := X"3B3A" -- randomarray[29]
var_dat_mem(46) := X"3D3C" -- randomarray[30]
var_dat_mem(47) := X"3F3E" -- randomarray[31]
var_dat_mem(48) := X"4140" -- randomarray[32]
var_dat_mem(49) := X"4342" -- randomarray[33]
var_dat_mem(50) := X"4544" -- randomarray[34]
var_dat_mem(51) := X"4746" -- randomarray[35]
var_dat_mem(52) := X"4948" -- randomarray[36]
var_dat_mem(53) := X"4B4A" -- randomarray[37]
var_dat_mem(54) := X"4D4C" -- randomarray[38]
var_dat_mem(55) := X"4F4E" -- randomarray[39]
var_dat_mem(56) := X"5150" -- randomarray[40]
var_dat_mem(57) := X"5352" -- randomarray[41]
var_dat_mem(58) := X"5554" -- randomarray[42]
var_dat_mem(59) := X"5756" -- randomarray[43]
var_dat_mem(60) := X"5958" -- randomarray[44]
var_dat_mem(61) := X"5B5A" -- randomarray[45]
var_dat_mem(62) := X"5D5C" -- randomarray[46]
var_dat_mem(63) := X"5F5E" -- randomarray[47]
var_dat_mem(64) := X"6160" -- randomarray[48]
var_dat_mem(65) := X"6362" -- randomarray[49]
var_dat_mem(66) := X"6564" -- randomarray[50]
var_dat_mem(67) := X"6766" -- randomarray[51]
var_dat_mem(68) := X"6968" -- randomarray[52]
var_dat_mem(69) := X"6B6A" -- randomarray[53]
var_dat_mem(70) := X"6D6C" -- randomarray[54]
var_dat_mem(71) := X"6F6E" -- randomarray[55]
var_dat_mem(72) := X"7170" -- randomarray[56]
var_dat_mem(73) := X"7372" -- randomarray[57]
var_dat_mem(74) := X"7574" -- randomarray[58]
var_dat_mem(75) := X"7776" -- randomarray[59]
var_dat_mem(76) := X"7978" -- randomarray[60]
var_dat_mem(77) := X"7B7A" -- randomarray[61]
var_dat_mem(78) := X"7D7C" -- randomarray[62]
var_dat_mem(79) := X"7F7E" -- randomarray[63]
var_dat_mem(80) := X"0000" -- padding
var_dat_mem(81) := X"0000" -- padding
var_dat_mem(82) := X"0000" -- padding
var_dat_mem(83) := X"0000" -- padding

-- Input 

var_dat_mem(84) := X"6568" -- inputarray[0] : 'eh'
var_dat_mem(85) := X"6C6C" -- inputarray[1] : 'll'
var_dat_mem(86) := X"206F" -- inputarray[2] : ' o'
var_dat_mem(87) := X"6874" -- inputarray[3] : 'ht'
var_dat_mem(88) := X"7265" -- inputarray[4] : 're'
var_dat_mem(89) := X"2065" -- inputarray[5] : ' e'
var_dat_mem(90) := X"6F68" -- inputarray[6] : 'oh'
var_dat_mem(91) := X"2077" -- inputarray[7] : ' w'
var_dat_mem(92) := X"7261" -- inputarray[8] : 'ra'
var_dat_mem(93) := X"2065" -- inputarray[9] : ' e'
var_dat_mem(94) := X"6F79" -- inputarray[10] : 'oy'
var_dat_mem(95) := X"3F75" -- inputarray[11] : '?u'
var_dat_mem(96) := X"0000" -- padding
var_dat_mem(97) := X"0000" -- padding
var_dat_mem(98) := X"0000" -- padding
var_dat_mem(99) := X"0000" -- padding

-- Output 

var_dat_mem(100) := X"1234" -- outputarray[0]
var_dat_mem(101) := X"5678" -- outputarray[1]
var_dat_mem(102) := X"9ABC" -- outputarray[2]
var_dat_mem(103) := X"DEF0" -- outputarray[3]
var_dat_mem(104) := X"0000" -- outputarray[4]
var_dat_mem(105) := X"0000" -- outputarray[5]
var_dat_mem(106) := X"0000" -- outputarray[6]
var_dat_mem(107) := X"0000" -- outputarray[7]
var_dat_mem(108) := X"0000" -- outputarray[8]
var_dat_mem(109) := X"0000" -- outputarray[9]
var_dat_mem(110) := X"0000" -- outputarray[10]
var_dat_mem(111) := X"0000" -- outputarray[11]
var_dat_mem(112) := X"0000" -- padding
var_dat_mem(113) := X"0000" -- padding
var_dat_mem(114) := X"0000" -- padding
var_dat_mem(115) := X"0000" -- padding



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
        
        data_out <= var_dm_out;
        
        
        -- the following are probe signals (for simulation purpose) 
        sig_data_mem <= var_data_mem;

    end process;
  
end behavioral;


