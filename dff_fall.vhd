library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
  
entity dff_fall is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           d_in     : in  std_logic;
           d_out    : out std_logic
           );
end dff_fall;

architecture behavioral of dff_fall is
begin

    update_process: process ( reset,
                              clk ) is
    variable d : std_logic;
    begin
       if (reset = '1') then
           d := '0';
       elsif (falling_edge(clk)) then
           d := d_in;
       end if;
       d_out <= d;
    end process;
end behavioral;