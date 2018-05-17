library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity or_4in_1b is
    port ( in_a     : in  std_logic;
           in_b     : in  std_logic;
           in_c     : in  std_logic;
           in_d     : in  std_logic;
           or_out   : out std_logic );
end mux_2to1_1b;

architecture behavioural of or_4in_1b is
begin

    or_out <= in_a or in_b or in_c or in_d;

end behavioural;
