---------------------------------------------------------------------------
-- fwd_unit_b.vhd - forwarding unit
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

entity fwd_unit_b is
    port (  src_reg_a       : in std_logic_vector(3 downto 0);
            src_reg_b       : in std_logic_vector(3 downto 0);
            reg_write_dm    : in std_logic;
            reg_write_wb    : in std_logic;   
            alu_src         : in std_logic;
            write_reg_dm    : in std_logic_vector(3 downto 0);
            write_reg_wb    : in std_logic_vector(3 downto 0);
            alu_fwd_dm_or_w_a   : out std_logic;
            alu_fwd_dm_or_w_b   : out std_logic;
            alu_src_a_ctrl  : out std_logic;
            alu_src_b_ctrl  : out std_logic
            );
end fwd_unit_b;

architecture behavioral of fwd_unit_b is
begin

    fwd_unit_process: process ( src_reg_a,
                                src_reg_b,
                                reg_write_dm,
                                reg_write_wb,
                                alu_src,     
                                write_reg_dm, 
                                write_reg_wb ) is
        begin
        
        -- determine if we need to forward to src b
        if ( alu_src = '0' and ((reg_write_dm = '1' and src_reg_b = write_reg_dm ) or (reg_write_wb = '1' and src_reg_b = write_reg_wb)) ) then
            alu_src_b_ctrl <= '1';
        else
            alu_src_b_ctrl <= '0';
        end if;
        
        -- determine if we need to forward to src a
        if ( (reg_write_dm = '1' and src_reg_a = write_reg_dm ) or (reg_write_wb = '1' and src_reg_a = write_reg_wb) ) then
            alu_src_a_ctrl <= '1';
        else
            alu_src_a_ctrl <= '0';
        end if;
        
        -- choose between dm and write for a
        if ( reg_write_dm = '1' and write_reg_dm = src_reg_a ) then
            alu_fwd_dm_or_w_a <= '0';
        else 
            alu_fwd_dm_or_w_a <= '1';
        end if;
        
        -- choose between dm and write for b
        if ( reg_write_dm = '1' and write_reg_dm = src_reg_b ) then
            alu_fwd_dm_or_w_b <= '0';
        else 
            alu_fwd_dm_or_w_b <= '1';
        end if;
        
    end process;
end behavioral;