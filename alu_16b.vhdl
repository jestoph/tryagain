---------------------------------------------------------------------------
-- adder_16b.vhd - 16-bit Adder Implementation
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
use IEEE.NUMERIC_STD.ALL;

entity alu_16b is
    port ( src_a     : in  std_logic_vector(15 downto 0);
           src_b     : in  std_logic_vector(15 downto 0);
           sum       : out std_logic_vector(15 downto 0);
		     alu_op	   : in std_logic_vector(2 downto 0);
           carry_out : out std_logic);
		   
end alu_16b;

architecture behavioural of alu_16b is

signal sig_result : std_logic_vector(16 downto 0);

begin
	
	sll_process : process ( src_a,
							src_b,
							alu_op) is    
   variable var_shift_l_amt  		: integer;
   variable var_shift_buf        : std_logic_vector(15 downto 0);
	variable var_shift_r_amt  		: integer;
   	
	begin


		if (alu_op = "001") then
			-- sub
			sig_result <= ('0' & src_a) - ('0' & src_b);
			sum        <= sig_result(15 downto 0);
			carry_out  <= sig_result(16);
		elsif (alu_op =  "010") then 
			-- xor
			sig_result <= ('0' & src_a) xor ('0' & src_b);
			sum        <= sig_result(15 downto 0);
			carry_out  <= '0';		
		elsif (alu_op =  "011") then 	
			-- and
			sig_result <= ('0' & src_a) and ('0' & src_b);
			sum        <= sig_result(15 downto 0);
			carry_out  <= '0';			
		elsif (alu_op =  "110") then 
			-- lsl
			var_shift_l_amt := conv_integer(src_b);
			var_shift_buf   := src_a;
			for I in 1 to var_shift_l_amt loop
				var_shift_buf := var_shift_buf(14 downto 0) & '0';
			end loop;
	--        sig_sll_16b     <= shift_left(unsigned(src),var_shift_l_amt);
	--        sll_result      <= sig_sll_16b;
			sum     <= var_shift_buf;    
		elsif (alu_op =  "111") then 
			-- lsr
			var_shift_r_amt := conv_integer(src_b);
			var_shift_buf   := src_a;
			for I in 1 to var_shift_r_amt loop
				var_shift_buf := '0' & var_shift_buf(15 downto 1);
			end loop;
			sum     <= var_shift_buf;
		else 
			-- add
			sig_result <= ('0' & src_a) + ('0' & src_b);
			sum        <= sig_result(15 downto 0);
			carry_out  <= sig_result(16);		
		end if;
	
	end process;
end behavioural;
