---------------------------------------------------------------------------
-- reg_if_id.vhd - register stage between ID and EXE
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

entity if_id_reg is
	generic(
				LEN : integer := 100 -- Intentionally strange number so can tell if forget to set it
			);

    port ( reset        : in  std_logic;
           flush        : in  std_logic;
           stall        : in  std_logic;
           clk          : in  std_logic;
           data_out		: out  std_logic_vector(LEN-1 downto 0);
           data_in     	: in std_logic_vector(LEN-1 downto 0);
           stop         : in  std_logic);
	end if_id_reg;

architecture behavioral of if_id_reg is

signal sig_val_in      : std_logic_vector(LEN-1 downto 0);
signal sig_val_out     : std_logic_vector(LEN-1 downto 0);
signal sig_val         : std_logic_vector(LEN-1 downto 0);

begin
reg_process: process(reset,
                        clk,
                        stall) is
   
   variable var_val    : std_logic_vector(LEN-1 downto 0);
   variable var_val_in : std_logic_vector(LEN-1 downto 0);
   variable var_val_out: std_logic_vector(LEN-1 downto 0);
                  
   begin
   
   sig_val_in <= data_in;
   
   
   if (reset = '1') then
      data_out <= (others => '0'); 
   elsif(stop = '1') then
   
   elsif(rising_edge(stall)) then
      data_out <= (others => '0');
   elsif (rising_edge(clk)) then
      if(flush = '1') then
         data_out <= (others => '0');
      --elsif(stall = '1') then
      --   data_out <= (others => '0');
      else
         data_out <= data_in after 10ns; 
      end if;
   end if;
   
   
--   sig_val <= var_val;
--   data_out <= sig_val_out after 20 ns;
   
   end process;
end behavioral;
