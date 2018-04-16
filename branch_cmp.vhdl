---------------------------------------------------------------------------
-- branch_cmp.vhd - Implementation of register comparitor for branch
--                  
-- 

--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity branch_cmp is
    port ( b_type       : in  std_logic; -- 1 for beq
           b_insn       : in  std_logic; -- 1 for b instruction
           src_a        : in  std_logic_vector(15 downto 0);
           src_b        : in  std_logic_vector(15 downto 0);
           do_branch    : out std_logic); -- 1 if doing branch
end branch_cmp;

architecture behavioral of branch_cmp is

signal sig_cmp_eq       : std_logic;

begin
 
--    branch_cmp_process : process (  src_a,
--                                    src_b,
--                                    b_type ) is
--                                    
--                                    
--    begin
--    
--    
--    
--    
--    
--    end process;

    sig_cmp_eq  <= '1' when (src_a = src_b) else
                  '0';
                  
    
    do_branch   <= '1' when (b_insn = '1' and ((sig_cmp_eq = '1' and b_type = '1')
                                                or (sig_cmp_eq = '0' and b_type = '0'))) else
                  '0';
                  


end behavioral;