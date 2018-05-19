library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tok_req_ctrl is
    port ( write_enable     : in  std_logic;
           read_enable      : in  std_logic;
           addr_in          : in  std_logic_vector(15 downto 0);
           w_req            : out std_logic;
           r_req            : out std_logic);
end tok_req_ctrl;

architecture behavioural of tok_req_ctrl is

signal sig_core_req std_logic

begin

    sig_core_req    <= '1' when addr_in = 0x"00000000" else '0';
    
    w_req           <= write_enable and not sig_core_req;
    r_req           <= read_enable and not sig_core_req;

end behavioural;
