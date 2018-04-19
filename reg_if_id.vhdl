---------------------------------------------------------------------------
-- reg_if_id.vhd - register stage between IF and ID
-- 
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

entity reg_if_id is
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           id_out			: out  std_logic_vector(15 downto 0);
           if_in     	: in std_logic_vector(15 downto 0) );
end reg_if_id;

architecture behavioral of reg_if_id is

signal sig_insn_in      : std_logic_vector(15 downto 0);
signal sig_insn_out     : std_logic_vector(15 downto 0);
signal sig_insn         : std_logic_vector(15 downto 0);

begin
	reg_process: process(reset,
                        clk, 
								if_in) is
   
   variable var_insn    : std_logic_vector(15 downto 0);
   variable var_insn_in : std_logic_vector(15 downto 0);
   variable var_insn_out: std_logic_vector(15 downto 0);
                  
   begin
   
   sig_insn_in <= if_in;
   
   if(rising_edge(clk)) then
      if(reset = '1') then
         var_insn_in   := X"0000";
         var_insn      := X"0000";
         var_insn_out  := X"0000";
         sig_insn_out  <= X"0000";
      else
         --var_insn_in  := sig_insn_in;
         --var_insn_out := var_insn;
         
         var_insn_in  := sig_insn_in;         
         var_insn_out := var_insn_in;
         sig_insn_out <= var_insn_out;
      end if;
      
   end if;
   
   sig_insn <= var_insn;
   id_out <= sig_insn_out;-- after 1ns;
   
   end process;
end behavioral;