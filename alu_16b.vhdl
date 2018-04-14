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
           alu_out   : out std_logic_vector(15 downto 0);
		   alu_op	 : in  std_logic_vector(2 downto 0);
           do_slt    : in  std_logic;
           carry_out : out std_logic);
		   
end alu_16b;

architecture behavioural of alu_16b is

signal sig_alu_src_a    : std_logic_vector(15 downto 0);
signal sig_alu_src_b    : std_logic_vector(15 downto 0);
signal sig_alu_sum      : std_logic_vector(15 downto 0);

begin
	
	sll_process : process ( src_a,
							src_b,
							alu_op) is    
   variable var_shift_amt  		: integer;
   variable var_shift_buf       : std_logic_vector(15 downto 0);
   variable var_sum             : std_logic_vector(15 downto 0);
   variable var_result          : std_logic_vector(16 downto 0);
   variable var_carry_out       : std_logic;
   	
	begin
        sig_alu_src_a <= src_a;
        sig_alu_src_b <= src_b;


		if (alu_op = "001") then
			-- sub
			var_result := ('0' & src_a) - ('0' & src_b);
            var_carry_out  := var_result(16);
            if (do_slt = '1') then
                var_sum(15 downto 1)    := "000000000000000";
                var_sum(1)              := var_result(15);
            else
                var_sum        := var_result(15 downto 0);
            end if;
		elsif (alu_op =  "010") then 
			-- xor
			var_result     := ('0' & src_a) xor ('0' & src_b);
			var_sum        := var_result(15 downto 0);
			var_carry_out  := '0';		
		elsif (alu_op =  "011") then 	
			-- and
			var_result := ('0' & src_a) and ('0' & src_b);
			var_sum    := var_result(15 downto 0);
			var_carry_out  := '0';			
		elsif (alu_op =  "110") then 
			-- lsl
			var_shift_amt   := conv_integer(src_b);
			var_shift_buf   := src_a;
			for I in 1 to var_shift_amt loop
				var_shift_buf := var_shift_buf(14 downto 0) & '0';
			end loop;
	--        sig_sll_16b     <= shift_left(unsigned(src),var_shift_l_amt);
	--        sll_result      <= sig_sll_16b;
			var_sum     := var_shift_buf;    
		elsif (alu_op =  "111") then 
			-- lsr
			var_shift_amt   := conv_integer(src_b);
			var_shift_buf   := src_a;
			for I in 1 to var_shift_amt loop
				var_shift_buf := '0' & var_shift_buf(15 downto 1);
			end loop;
			var_sum     := var_shift_buf;
        elsif (alu_op =  "000") then 
            -- add
			var_result      := ('0' & src_a) + ('0' & src_b);
			var_sum         := var_result(15 downto 0);
			var_carry_out   := var_result(16);	
		else 
			-- add
			var_result      := ('0' & src_a) + ('0' & src_b);
			var_sum         := var_result(15 downto 0);
			var_carry_out   := var_result(16);		
		end if;

        alu_out         <= var_sum;
        carry_out       <= var_carry_out;
	end process;
end behavioural;
