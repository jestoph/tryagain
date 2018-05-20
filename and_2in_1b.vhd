library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity and_2in_1b is
    port ( in_a     : in  std_logic;
           in_b     : in  std_logic;
           and_out   : out std_logic );
end and_2in_1b;

architecture behavioural of and_2in_1b is
begin

    and_out <= in_a and in_b;

end behavioural;
