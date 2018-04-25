---------------------------------------------------------------------------
-- jmp_ctrl.vhd - jump or increment pc
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


entity jmp_ctrl is 
    port(opcode  : in  std_logic_vector (3 downto 0);
         jmp_flag: out std_logic);
end jmp_ctrl;

architecture behavioural of jmp_ctrl is
constant OP_JMP   : std_logic_vector(3 downto 0) := "0010"; -- 2
begin

     jmp_flag <= '1' when opcode = OP_JMP else '0' after 0.2 ns;

end behavioural;