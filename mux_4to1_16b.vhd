---------------------------------------------------------------------------
-- mux_4to1_16b.vhd - 16-bit 2-to-1 Multiplexer Implementation
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
  
entity mux_4to1_16b is
    port ( mux_select : in  std_logic_vector(1 downto 0);
           data_0     : in  std_logic_vector(15 downto 0);
           data_1     : in  std_logic_vector(15 downto 0);
           data_2     : in  std_logic_vector(15 downto 0);
           data_3     : in  std_logic_vector(15 downto 0);
           data_out   : out std_logic_vector(15 downto 0) );
end mux_4to1_16b;

architecture structural of mux_4to1_16b is

begin
    
    data_out <= data_0 when mux_select = x"00" else
                data_1 when mux_select = x"01" else
                data_2 when mux_select = x"10" else
                data_3 when mux_select = x"11" ;
    
end structural;
