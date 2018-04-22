library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity jmp_premp is
    port (  instr_in        : in std_logic_vector(15 downto 0);
            do_jmp          : out std_logic;
            do_not_jmp      : out std_logic;
            jmp_addr        : out std_logic_vector(15 downto 0)   
            );
end jmp_premp;

architecture behavioral of jmp_premp is
begin
    do_jmp <= '0';
    do_not_jmp <= '1';
    jmp_addr <= X"0000";
    jmp_premp_process: process ( instr_in ) is
        begin
        
        if (instr_in(15 downto 11) = "0010") then
            jmp_addr <=  "0000" & instr_in(11 downto 0);
            do_jmp <= '1';
            do_not_jmp <= '0';
        else
            do_jmp <= '0';
            do_not_jmp <= '1';
            jmp_addr <= X"0000";
        end if;
        
    end process;
end behavioral;