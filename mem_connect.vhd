library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mem_connect is
    port ( write_enable :   in  std_logic;
           read_enable  :   in  std_logic;
           write_token  :   in  std_logic;
           read_token   :   in  std_logic;
           write_data   :   in  std_logic_vector(15 downto 0);
           byte_addr	:   in  std_logic;
           addr_in      :   in  std_logic_vector(15 downto 0);
           data_out     :   out std_logic_vector(15 downto 0);
           mem_r_bus    :   in  std_logic_vector(15 downto 0);
           mem_w_bus    :   out std_logic_vector(15 downto 0);
           core_num     :   in  std_logic_vector(15 downto 0);
           addr_w_bus   :   out std_logic_vector(15 downto 0);
           addr_r_bus   :   out std_logic_vector(15 downto 0);
           byte_addr_r_bus  : out std_logic;
           byte_addr_w_bus  : out std_logic);
end mem_connect;

architecture behavioural of mem_connect is

signal  sig_r_begin         :   std_logic;
signal  sig_w_begin         :   std_logic;
signal  sig_core_req        :   std_logic;
signal  sig_r_sel           :   std_logic_vector(15 downto 0);

begin

    sig_r_begin <=  read_token and read_enable;
    sig_w_begin <=  write_token and write_enable;
    sig_core_req    <= '1' when addr_in = 0x"00000000" else '0';
    sig_r_sel   <=  mem_r_bus when sig_core_req = '0' else core_num;
    
-- only write when the all clear is given
    mem_w_bus   <=  write_data when sig_w_begin = '1' and sig_core_req = '0'
                    else (others => 'Z');
                    
    addr_w_bus  <=  add_in when sig_w_begin = '1' and sig_core_req = '0'
                    else (others => 'Z');
                    
    byte_addr_w_bus <=  byte_addr when sig_w_begin = '1' and sig_core_req = '0'
                    else (others => 'Z');
                    
-- only read when the all clear is given
    data_out    <=  mem_r_bus when sig_core_req = '0' else core_num;
                    
    add_r_bus   <=  add_in when sig_r_begin = '1' and sig_core_req = '0'
                    else (others => 'Z');
                    
    byte_addr_r_bus <=  byte_addr when sig_r_begin = '1' and sig_core_req = '0'
                    else (others => 'Z');
    
end behavioural;
