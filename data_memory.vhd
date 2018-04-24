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
		   byte_addr	: in  std_logic;
           write_data   : in  std_logic_vector(15 downto 0);
           addr_in      : in  std_logic_vector(11 downto 0);
           data_out     : out std_logic_vector(15 downto 0) );
end data_memory;

architecture behavioral of data_memory is

type mem_array is array(0 to 4096) of std_logic_vector(15 downto 0);
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
        
            --Memory structure
            -- 0        - 7         : pointers and input arguments
            -- 8        - 11        : key
            -- 12       - 15        : padding
            -- 16       - 143       : rng table
            -- 144      - 149       : padding
            -- 150      - (150+x-1) : string length x
            -- 150+x    - 153+x     : padding
            -- 154+x    - 154+2x-1  : output string
            

            -- initial values of the data memory : reset to zero 
            -- initial values of the data memory : reset to zero 
--            var_data_mem(0) := X"000a"; -- START_OF_ARRAY Initial_Pointers[]RPKRPK
--            var_data_mem(1) := X"0034"; -- random_tableKrandom_tableK
--            var_data_mem(2) := X"0014"; -- InputStringInputString
--            var_data_mem(3) := X"001e"; -- OutputStringOutputString
--            var_data_mem(4) := X"0000"; -- END_OF_ARRAY 
--            var_data_mem(5) := X"1234"; -- START_OF_ARRAY Key[]
--            var_data_mem(6) := X"5678"; -- 
--            var_data_mem(7) := X"9abc"; -- 
--            var_data_mem(8) := X"def0"; -- 
--            var_data_mem(9) := X"0000"; -- END_OF_ARRAY 
--            var_data_mem(10) := X"4849"; -- START_OF_ARRAY  InputArray[]
--            var_data_mem(11) := X"4652"; -- 
--            var_data_mem(12) := X"4945"; -- 
--            var_data_mem(13) := X"4e44"; -- 
--            var_data_mem(14) := X"4f00";
--            var_data_mem(15) := X"0000"; -- START_OF_ARRAY  OuputArray
--            var_data_mem(16) := X"0000"; -- 
--            var_data_mem(17) := X"0000"; -- 
--            var_data_mem(18) := X"0000"; -- 
--            var_data_mem(19) := X"0000"; -- 
--            var_data_mem(20) := X"0000"; -- 
--            var_data_mem(21) := X"0000"; -- 
--            var_data_mem(22) := X"0000"; -- 
--            var_data_mem(23) := X"0000"; -- 
--            var_data_mem(24) := X"0000"; -- 
--            var_data_mem(25) := X"0000"; -- END_OF_ARRAY 
--            var_data_mem(26) := X"4259"; -- START_OF_ARRAY random_table[]
--            var_data_mem(27) := X"a691"; -- 
--            var_data_mem(28) := X"14c5"; -- 
--            var_data_mem(29) := X"5e9e"; -- 
--            var_data_mem(30) := X"286f"; -- 
--            var_data_mem(31) := X"768d"; -- 
--            var_data_mem(32) := X"2615"; -- 
--            var_data_mem(33) := X"b1d2"; -- 
--            var_data_mem(34) := X"2773"; -- 
--            var_data_mem(35) := X"3365"; -- 
--            var_data_mem(36) := X"edc1"; -- 
--            var_data_mem(37) := X"426c"; -- 
--            var_data_mem(38) := X"5101"; -- 
--            var_data_mem(39) := X"fc85"; -- 
--            var_data_mem(40) := X"9551"; -- 
--            var_data_mem(41) := X"92ef"; -- 
--            var_data_mem(42) := X"38ca"; -- 
--            var_data_mem(43) := X"e128"; -- 
--            var_data_mem(44) := X"befe"; -- 
--            var_data_mem(45) := X"e570"; -- 
--            var_data_mem(46) := X"053a"; -- 
--            var_data_mem(47) := X"9b3d"; -- 
--            var_data_mem(48) := X"553f"; -- 
--            var_data_mem(49) := X"7209"; -- 
--            var_data_mem(50) := X"a906"; -- 
--            var_data_mem(51) := X"2ddd"; -- 
--            var_data_mem(52) := X"2802"; -- 
--            var_data_mem(53) := X"8506"; -- 
--            var_data_mem(54) := X"6a9e"; -- 
--            var_data_mem(55) := X"7d4c"; -- 
--            var_data_mem(56) := X"4d5b"; -- 
--            var_data_mem(57) := X"b282"; -- 
--            var_data_mem(58) := X"0000"; -- END_OF_ARRAY 
--            var_data_mem(59) := X"0000";

var_data_mem(0) := X"000A"; -- pointer to key
var_data_mem(1) := X"0034"; -- pointer to random_tableKrandom_tableK
var_data_mem(2) := X"0014"; -- pointer to InputString
var_data_mem(3) := X"0008"; -- input string length
var_data_mem(4) := X"0000"; -- END_OF_ARRAY 
var_data_mem(5) := X"1234"; -- START_OF_ARRAY Key[]
var_data_mem(6) := X"5678"; -- 
var_data_mem(7) := X"9abc"; -- 
var_data_mem(8) := X"def0"; -- 
var_data_mem(9) := X"0000"; -- END_OF_ARRAY 
var_data_mem(10) := X"4849"; -- START_OF_ARRAY  InputArray[]
var_data_mem(11) := X"4652"; -- 
var_data_mem(12) := X"4945"; -- 
var_data_mem(13) := X"4e44"; -- 
var_data_mem(14) := X"0000";
var_data_mem(15) := X"0000"; -- 
var_data_mem(16) := X"0000"; -- START_OF_ARRAY  OuputArray
var_data_mem(17) := X"0000"; -- 
var_data_mem(18) := X"0000"; -- 
var_data_mem(19) := X"0000"; -- 
var_data_mem(20) := X"0000"; -- 
var_data_mem(21) := X"0000"; -- 
var_data_mem(22) := X"0000"; -- 
var_data_mem(23) := X"0000"; -- 
var_data_mem(24) := X"0000"; -- 
var_data_mem(25) := X"0000"; -- END_OF_ARRAY 
var_data_mem(26) := X"9f3b"; -- START_OF_ARRAY random_table[]
var_data_mem(27) := X"bdfa"; -- 
var_data_mem(28) := X"61b3"; -- 
var_data_mem(29) := X"817f"; -- 
var_data_mem(30) := X"150d"; -- 
var_data_mem(31) := X"3282"; -- 
var_data_mem(32) := X"cfcb"; -- 
var_data_mem(33) := X"7f0d"; -- 
var_data_mem(34) := X"6f49"; -- 
var_data_mem(35) := X"d67b"; -- 
var_data_mem(36) := X"839a"; -- 
var_data_mem(37) := X"e57e"; -- 
var_data_mem(38) := X"4293"; -- 
var_data_mem(39) := X"38cf"; -- 
var_data_mem(40) := X"ac0c"; -- 
var_data_mem(41) := X"68c0"; -- 
var_data_mem(42) := X"1641"; -- 
var_data_mem(43) := X"9278"; -- 
var_data_mem(44) := X"ba3f"; -- 
var_data_mem(45) := X"9900"; -- 
var_data_mem(46) := X"209f"; -- 
var_data_mem(47) := X"a9df"; -- 
var_data_mem(48) := X"1d90"; -- 
var_data_mem(49) := X"9bc0"; -- 
var_data_mem(50) := X"0da1"; -- 
var_data_mem(51) := X"99b7"; -- 
var_data_mem(52) := X"b5c7"; -- 
var_data_mem(53) := X"e2cb"; -- 
var_data_mem(54) := X"a563"; -- 
var_data_mem(55) := X"4700"; -- 
var_data_mem(56) := X"fd35"; -- 
var_data_mem(57) := X"06d3"; -- 
var_data_mem(58) := X"477b"; -- 
var_data_mem(59) := X"feea"; -- 
var_data_mem(60) := X"aed7"; -- 
var_data_mem(61) := X"7f2f"; -- 
var_data_mem(62) := X"6fb3"; -- 
var_data_mem(63) := X"9f17"; -- 
var_data_mem(64) := X"625a"; -- 
var_data_mem(65) := X"4910"; -- 
var_data_mem(66) := X"f7e8"; -- 
var_data_mem(67) := X"abc0"; -- 
var_data_mem(68) := X"6c0d"; -- 
var_data_mem(69) := X"7890"; -- 
var_data_mem(70) := X"35db"; -- 
var_data_mem(71) := X"ee81"; -- 
var_data_mem(72) := X"4ea9"; -- 
var_data_mem(73) := X"7727"; -- 
var_data_mem(74) := X"0c6d"; -- 
var_data_mem(75) := X"d6a1"; -- 
var_data_mem(76) := X"e946"; -- 
var_data_mem(77) := X"b2ee"; -- 
var_data_mem(78) := X"026b"; -- 
var_data_mem(79) := X"62d4"; -- 
var_data_mem(80) := X"54eb"; -- 
var_data_mem(81) := X"4bae"; -- 
var_data_mem(82) := X"5f51"; -- 
var_data_mem(83) := X"994f"; -- 
var_data_mem(84) := X"6237"; -- 
var_data_mem(85) := X"1c65"; -- 
var_data_mem(86) := X"185b"; -- 
var_data_mem(87) := X"b374"; -- 
var_data_mem(88) := X"09af"; -- 
var_data_mem(89) := X"0a46"; -- 
var_data_mem(90) := X"1bf9"; -- 
var_data_mem(91) := X"d64e"; -- 
var_data_mem(92) := X"6695"; -- 
var_data_mem(93) := X"db32"; -- 
var_data_mem(94) := X"ebdc"; -- 
var_data_mem(95) := X"f3c0"; -- 
var_data_mem(96) := X"43c9"; -- 
var_data_mem(97) := X"5656"; -- 
var_data_mem(98) := X"88d0"; -- 
var_data_mem(99) := X"c8ff"; -- 
var_data_mem(100) := X"875e"; -- 
var_data_mem(101) := X"c903"; -- 
var_data_mem(102) := X"b15b"; -- 
var_data_mem(103) := X"19bc"; -- 
var_data_mem(104) := X"6aa3"; -- 
var_data_mem(105) := X"c56e"; -- 
var_data_mem(106) := X"d30e"; -- 
var_data_mem(107) := X"60a8"; -- 
var_data_mem(108) := X"cbda"; -- 
var_data_mem(109) := X"26ba"; -- 
var_data_mem(110) := X"cba0"; -- 
var_data_mem(111) := X"16d0"; -- 
var_data_mem(112) := X"38cb"; -- 
var_data_mem(113) := X"9ebe"; -- 
var_data_mem(114) := X"f068"; -- 
var_data_mem(115) := X"0fca"; -- 
var_data_mem(116) := X"aa9d"; -- 
var_data_mem(117) := X"f035"; -- 
var_data_mem(118) := X"f2e6"; -- 
var_data_mem(119) := X"3352"; -- 
var_data_mem(120) := X"5ed4"; -- 
var_data_mem(121) := X"e763"; -- 
var_data_mem(122) := X"8c99"; -- 
var_data_mem(123) := X"a551"; -- 
var_data_mem(124) := X"bd8b"; -- 
var_data_mem(125) := X"d98d"; -- 
var_data_mem(126) := X"f7ba"; -- 
var_data_mem(127) := X"8a8f"; -- 
var_data_mem(128) := X"b452"; -- 
var_data_mem(129) := X"5d9e"; -- 
var_data_mem(130) := X"04d0"; -- 
var_data_mem(131) := X"de36"; -- 
var_data_mem(132) := X"122b"; -- 
var_data_mem(133) := X"66ee"; -- 
var_data_mem(134) := X"9e96"; -- 
var_data_mem(135) := X"d936"; -- 
var_data_mem(136) := X"f01f"; -- 
var_data_mem(137) := X"f535"; -- 
var_data_mem(138) := X"06ea"; -- 
var_data_mem(139) := X"2883"; -- 
var_data_mem(140) := X"41ce"; -- 
var_data_mem(141) := X"9de7"; -- 
var_data_mem(142) := X"e3ba"; -- 
var_data_mem(143) := X"f53f"; -- 
var_data_mem(144) := X"affc"; -- 
var_data_mem(145) := X"9199"; -- 
var_data_mem(146) := X"0737"; -- 
var_data_mem(147) := X"e8dd"; -- 
var_data_mem(148) := X"2b1f"; -- 
var_data_mem(149) := X"45d3"; -- 
var_data_mem(150) := X"82d0"; -- 
var_data_mem(151) := X"ab64"; -- 
var_data_mem(152) := X"b1ba"; -- 
var_data_mem(153) := X"afb4"; -- 
var_data_mem(154) := X"0000"; -- END_OF_ARRAY 
var_data_mem(155) := X"0000";

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
        --end if;
        
        -- continuous read of the memory location given by var_addr 
        --data_out <= var_data_mem(var_addr);
		
        elsif(falling_edge(clk) and read_enable = '1') then
            -- Byte Addressible Mode	
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
