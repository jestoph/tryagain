--------------------------------------------------------------------------------
-- Copyright (c) 1995-2003 Xilinx, Inc.
-- All Right Reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 7.1.03i
--  \   \         Application : ISE WebPACK
--  /   /         Filename : single_cycle_core_testbench.vhw
-- /___/   /\     Timestamp : Tue Jul 25 16:23:28 2006
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: 
--Design Name: single_cycle_core_testbench
--Device: Xilinx
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY single_cycle_core_testbench IS
END single_cycle_core_testbench;

ARCHITECTURE testbench_arch OF single_cycle_core_testbench IS
    FILE RESULTS: TEXT OPEN WRITE_MODE IS "results.txt";

    COMPONENT single_cycle_core
        PORT (
            reset   : In std_logic;
            clk     : In std_logic;
            clk_pc  : in std_logic
        );
    END COMPONENT;

    SIGNAL reset : std_logic := '1';
    SIGNAL clk : std_logic := '0';
    signal clk_pc : std_logic := '0';

    SHARED VARIABLE TX_ERROR : INTEGER := 0;
    SHARED VARIABLE TX_OUT : LINE;

    constant PERIOD : time := 200 ns;
    constant DUTY_CYCLE : real := 0.5;
    constant DUTY_CYCLE_PC: real := 0.51;
    constant OFFSET : time := 0 ns;

    BEGIN
        UUT : single_cycle_core
        PORT MAP (
            reset => reset,
            clk => clk,
            clk_pc => clk_pc
        );

        PROCESS    -- clock process for clk
        BEGIN
            WAIT for OFFSET;
            CLOCK_LOOP : LOOP
                clk <= '0';
                WAIT FOR (PERIOD - (PERIOD * DUTY_CYCLE));
                clk <= '1';
                WAIT FOR (PERIOD * DUTY_CYCLE);
            END LOOP CLOCK_LOOP;
        END PROCESS;
        
        process     --clock process for clk_pc
        begin
            wait for OFFSET;
            CLOCK_LOOP_PC : Loop
                clk_pc <= '0';
                wait for (PERIOD - (PERIOD * DUTY_CYCLE_PC));
                clk_pc <= '1';
                wait for (PERIOD * DUTY_CYCLE_PC);
            end loop CLOCK_LOOP_PC;
        end process;

        PROCESS
            BEGIN
                -- -------------  Current Time:  285ns
                WAIT FOR 285 ns;
                reset <= '0';
                -- -------------------------------------
                WAIT FOR 285000 ns;

                IF (TX_ERROR = 0) THEN
                    STD.TEXTIO.write(TX_OUT, string'("No errors or warnings"));
                    STD.TEXTIO.writeline(RESULTS, TX_OUT);
                    ASSERT (FALSE) REPORT
                      "Simulation successful (not a failure).  No problems detected."
                      SEVERITY FAILURE;
                ELSE
                    STD.TEXTIO.write(TX_OUT, TX_ERROR);
                    STD.TEXTIO.write(TX_OUT,
                        string'(" errors found in simulation"));
                    STD.TEXTIO.writeline(RESULTS, TX_OUT);
                    ASSERT (FALSE) REPORT "Errors found during simulation"
                         SEVERITY FAILURE;
                END IF;
            END PROCESS;

    END testbench_arch;

