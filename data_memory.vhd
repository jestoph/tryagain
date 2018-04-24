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
            -- initial values of the data memory : reset to zero 
            var_data_mem(0) := X"000a"; -- START_OF_ARRAY Initial_Pointers[]RPKRPK
            var_data_mem(1) := X"0034"; -- random_tableKrandom_tableK
            var_data_mem(2) := X"0014"; -- InputStringInputString
            var_data_mem(3) := X"001e"; -- OutputStringOutputString
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
            var_data_mem(14) := X"4f00";
            var_data_mem(15) := X"0000"; -- START_OF_ARRAY  OuputArray
            var_data_mem(16) := X"0000"; -- 
            var_data_mem(17) := X"0000"; -- 
            var_data_mem(18) := X"0000"; -- 
            var_data_mem(19) := X"0000"; -- 
            var_data_mem(20) := X"0000"; -- 
            var_data_mem(21) := X"0000"; -- 
            var_data_mem(22) := X"0000"; -- 
            var_data_mem(23) := X"0000"; -- 
            var_data_mem(24) := X"0000"; -- 
            var_data_mem(25) := X"0000"; -- END_OF_ARRAY 
            var_data_mem(26) := X"4259"; -- START_OF_ARRAY random_table[]
            var_data_mem(27) := X"a691"; -- 
            var_data_mem(28) := X"14c5"; -- 
            var_data_mem(29) := X"5e9e"; -- 
            var_data_mem(30) := X"286f"; -- 
            var_data_mem(31) := X"768d"; -- 
            var_data_mem(32) := X"2615"; -- 
            var_data_mem(33) := X"b1d2"; -- 
            var_data_mem(34) := X"2773"; -- 
            var_data_mem(35) := X"3365"; -- 
            var_data_mem(36) := X"edc1"; -- 
            var_data_mem(37) := X"426c"; -- 
            var_data_mem(38) := X"5101"; -- 
            var_data_mem(39) := X"fc85"; -- 
            var_data_mem(40) := X"9551"; -- 
            var_data_mem(41) := X"92ef"; -- 
            var_data_mem(42) := X"38ca"; -- 
            var_data_mem(43) := X"e128"; -- 
            var_data_mem(44) := X"befe"; -- 
            var_data_mem(45) := X"e570"; -- 
            var_data_mem(46) := X"053a"; -- 
            var_data_mem(47) := X"9b3d"; -- 
            var_data_mem(48) := X"553f"; -- 
            var_data_mem(49) := X"7209"; -- 
            var_data_mem(50) := X"a906"; -- 
            var_data_mem(51) := X"2ddd"; -- 
            var_data_mem(52) := X"2802"; -- 
            var_data_mem(53) := X"8506"; -- 
            var_data_mem(54) := X"6a9e"; -- 
            var_data_mem(55) := X"7d4c"; -- 
            var_data_mem(56) := X"4d5b"; -- 
            var_data_mem(57) := X"b282"; -- 
            var_data_mem(58) := X"0000"; -- END_OF_ARRAY 
            var_data_mem(59) := X"0000";

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
