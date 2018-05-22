library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
  
entity dff is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           d_in     : in  std_logic;
           d_out    : out std_logic
           );
end dff;

architecture behavioral of dff is
begin

    update_process: process ( reset,
                              clk ) is
    variable d : std_logic;
    begin
       if (reset = '1') then
           d := '0';
       elsif (rising_edge(clk)) then
           d := d_in;
       end if;
       d_out <= d;
    end process;
end behavioral;