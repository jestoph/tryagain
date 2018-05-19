library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity stall_unit is
port ( hzd_stall  : in  std_logic;
           w_en       : in  std_logic;
           r_en       : in  std_logic;
           w_req      : in  std_logic;
           r_req      : in  std_logic;
           stall      : out std_logic );
end stall_unit;

architecture behavioural of stall_unit is

signal sig_hzd_stall  : std_logic;
signal sig_w_en       : std_logic;
signal sig_r_en       : std_logic;
signal sig_w_req      : std_logic;
signal sig_r_req      : std_logic;
signal sig_stall      : std_logic;

begin
   sig_hzd_stall  <= hzd_stall;
   sig_w_en       <= w_en;
   sig_r_en       <= r_en;
   sig_w_req      <= w_req;
   sig_r_req      <= r_req;
   sig_hzd_stall  <= hzd_stall;

   sig_stall      <= '1' when ((w_req = '1' and w_en = '1') 
                                or (r_req = '1' and r_en = '1') 
                                or (r_req = '0' and w_req = '0'))
                                else '0';
                      
   stall          <= sig_stall or sig_hzd_stall;

end behavioural;