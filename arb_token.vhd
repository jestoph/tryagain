library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity r_token is
    port ( clk          : in    std_logic;
           reset        : in    std_logic;
           init         : in    std_logic;
           req          : in    std_logic;
           others_req   : in    std_logic;
           tok_in       : in    std_logic;
           tok_out      : out   std_logic;
           tok_stat     : out   std_logic );
end r_token;

architecture behavioural of r_token is

signal    sig_tok_out   : std_logic;
signal    sig_tok_d     : std_logic;
signal    sig_tok_in    : std_logic;
signal    sig_tok       : std_logic;

begin
    token_process : process ( reset,
                              clk,
                              req,
                              others_req,
                              tok_in ) is
                              
    variable   var_token    : std_logic;
    
    begin
    
    sig_tok          <= var_token;
    sig_tok_in       <= tok_in;
    sig_tok_d        <= ((not others_req and sig_tok) or (tok_in and req));
    sig_tok_out      <= ((tok_in and not req) or sig_tok);
    tok_stat         <= sig_tok;
    tok_out          <= sig_tok_out after 5ns;
    
       if (reset = '1') then
            var_token   := init; 
       elsif (rising_edge(clk)) then
            var_token   := sig_tok_d;
       end if;
    
    end process;
end behavioural;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity w_token is
    port ( clk          : in    std_logic;
           reset        : in    std_logic;
           init         : in    std_logic;
           req          : in    std_logic;
           others_req   : in    std_logic;
           tok_in       : in    std_logic;
           tok_out      : out   std_logic;
           tok_stat     : out   std_logic );
end w_token;

architecture behavioural of w_token is

signal    sig_tok_out   : std_logic;
signal    sig_tok_d     : std_logic; --current status of token
signal    sig_tok_in    : std_logic;
signal    sig_tok       : std_logic;

begin
    token_process : process ( reset,
                              clk,
                              req,
                              others_req,
                              tok_in) is
                              
    variable   var_token    : std_logic;
    
    begin
       if (reset = '1') then
            var_token   := init; 
       elsif (falling_edge(clk)) then
            var_token   := sig_tok_d;
       end if;
       
    sig_tok          <= var_token;
    sig_tok_in       <= tok_in;
    sig_tok_d        <= ((not others_req and sig_tok) or (tok_in and req));
    sig_tok_out      <= ((tok_in and not req) or sig_tok);
    tok_stat         <= sig_tok;
    tok_out          <= sig_tok_out after 5ns;
    
    end process;
end behavioural;