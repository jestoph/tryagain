---------------------------------------------------------------------------
-- multi_core.vhd 
-- wiring for multiple single cycles
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity multi_core is 
   port(reset  : in  std_logic;
        clk    : in  std_logic);
end multi_core;


architecture structural of multi_core is

component single_cycle_core is
    port ( reset  : in  std_logic;
           clk    : in  std_logic;
           w_req  : out std_logic;
           r_req  : out std_logic;
           w_en   : out std_logic; -- token
           r_en   : out std_logic; -- token
           w_b_addr : out std_logic; -- byte address mode
           r_b_addr : out std_logic; -- byte address mode
           w_mem_bus    : out std_logic_vector(15 downto 0);
           r_mem_bus    : in  std_logic_vector(15 downto 0);
           addr_r_bus   : out std_logic_vector(11 downto 0);
           addr_w_bus   : out std_logic_vector(11 downto 0);
           core_num :in std_logic_vector(15 downto 0));
end component;

component shared_memory is
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           write_enable : in  std_logic;
           read_enable  : in  std_logic;
		   byte_addr_w	: in  std_logic;
           byte_addr_r  : in  std_logic;
           write_data   : in  std_logic_vector(15 downto 0);
           addr_in_r    : in  std_logic_vector(11 downto 0);
           addr_in_w    : in  std_logic_vector(11 downto 0);
           data_out     : out std_logic_vector(15 downto 0));
end component;

component or_3in_1b is
port (     in_a         : in    std_logic;
           in_b         : in    std_logic;
           in_c         : in    std_logic;
           or_out       : out   std_logic);
end component;

component or_4in_1b is
port (     in_a         : in    std_logic;
           in_b         : in    std_logic;
           in_c         : in    std_logic;
           in_d         : in    std_logic;
           or_out       : out   std_logic);
end component;

component r_token is
port (     clk          : in    std_logic;
           reset        : in    std_logic;
           init         : in    std_logic;
           req          : in    std_logic;
           others_req   : in    std_logic;
           tok_in       : out   std_logic;
           tok_out      : out   std_logic;
           tok_stat     : out   std_logic   );
end component;

component w_token is
port (     clk          : in    std_logic;
           reset        : in    std_logic;
           init         : in    std_logic;
           req          : in    std_logic;
           others_req   : in    std_logic;
           tok_in       : out   std_logic;
           tok_out      : out   std_logic;
           tok_stat     : out   std_logic   );
end component;


signal sig_r_req_0      : std_logic;
signal sig_r_req_1      : std_logic;
signal sig_r_req_2      : std_logic;
signal sig_r_req_3      : std_logic;

signal sig_w_req_0      : std_logic;
signal sig_w_req_1      : std_logic;
signal sig_w_req_2      : std_logic;
signal sig_w_req_3      : std_logic;

signal sig_w_others_0   : std_logic;
signal sig_w_others_1   : std_logic;
signal sig_w_others_2   : std_logic;
signal sig_w_others_3   : std_logic;

signal sig_r_others_0   : std_logic;
signal sig_r_others_1   : std_logic;
signal sig_r_others_2   : std_logic;
signal sig_r_others_3   : std_logic;

signal sig_r_tok_0to1   : std_logic;
signal sig_r_tok_1to2   : std_logic;
signal sig_r_tok_2to3   : std_logic;
signal sig_r_tok_3to0   : std_logic; 

signal sig_w_tok_0to1   : std_logic;
signal sig_w_tok_1to2   : std_logic;
signal sig_w_tok_2to3   : std_logic;
signal sig_w_tok_3to0   : std_logic; 

signal sig_r_tok_stat_0 : std_logic;
signal sig_r_tok_stat_1 : std_logic;
signal sig_r_tok_stat_2 : std_logic;
signal sig_r_tok_stat_3 : std_logic;

signal sig_w_tok_stat_0 : std_logic;
signal sig_w_tok_stat_1 : std_logic;
signal sig_w_tok_stat_2 : std_logic;
signal sig_w_tok_stat_3 : std_logic;

signal sig_w_b_addr_bus : std_logic;
signal sig_r_b_addr_bus : std_logic;
signal sig_w_mem_bus    : std_logic_vector(15 downto 0);
signal sig_r_mem_bus    : std_logic_vector(15 downto 0);
signal sig_addr_r_bus   : std_logic_vector(11 downto 0);
signal sig_addr_w_bus   : std_logic_vector(11 downto 0);

signal sig_write_enable : std_logic;
signal sig_read_enable : std_logic;

begin

    other_r_req_0 : or_3in_1b 
    port map ( in_a      => sig_r_req_1, 
               in_b      => sig_r_req_2,
               in_c      => sig_r_req_3,   
               or_out    => sig_r_others_0 );

    other_r_req_1 : or_3in_1b 
    port map ( in_a      => sig_r_req_0, 
               in_b      => sig_r_req_2,
               in_c      => sig_r_req_3,   
               or_out    => sig_r_others_1 );

    other_r_req_2 : or_3in_1b 
    port map ( in_a      => sig_r_req_0, 
               in_b      => sig_r_req_1,
               in_c      => sig_r_req_3,   
               or_out    => sig_r_others_2 );

    other_r_req_3 : or_3in_1b 
    port map ( in_a      => sig_w_req_0, 
               in_b      => sig_w_req_1,
               in_c      => sig_w_req_2,   
               or_out    => sig_w_others_3 );
               
    other_w_req_0 : or_3in_1b 
    port map ( in_a      => sig_w_req_1, 
               in_b      => sig_w_req_2,
               in_c      => sig_w_req_3,   
               or_out    => sig_w_others_0 );

    other_w_req_1 : or_3in_1b 
    port map ( in_a      => sig_w_req_0, 
               in_b      => sig_w_req_2,
               in_c      => sig_w_req_3,   
               or_out    => sig_w_others_1 );

    other_w_req_2 : or_3in_1b 
    port map ( in_a      => sig_w_req_0, 
               in_b      => sig_w_req_1,
               in_c      => sig_w_req_3,   
               or_out    => sig_w_others_2 );

    other_w_req_3 : or_3in_1b 
    port map ( in_a      => sig_w_req_0, 
               in_b      => sig_w_req_1,
               in_c      => sig_w_req_2,   
               or_out    => sig_w_others_3 );
   
    write_enable_or : or_4in_1b   
    port map ( in_a      => sig_w_req_0,
               in_b      => sig_w_req_1,
               in_c      => sig_w_req_2,
               in_d      => sig_w_req_3,
               or_out    => sig_write_enable);

    read_enable_or : or_4in_1b   
    port map ( in_a      => sig_r_req_0,
               in_b      => sig_r_req_1,
               in_c      => sig_r_req_2,
               in_d      => sig_r_req_3,
               or_out    => sig_read_enable);

    arb_r_token_0 : r_token
    port map ( clk         => clk,
               reset       => reset,
               init        => '1',
               req         => sig_r_req_0,
               others_req  => sig_r_others_0,
               tok_in      => sig_r_tok_3to0,
               tok_out     => sig_r_tok_0to1,
               tok_stat    => sig_r_tok_stat_0
               );

    arb_r_token_1 : r_token
    port map ( clk         => clk,
               reset       => reset,
               init        => '0',
               req         => sig_r_req_1,
               others_req  => sig_r_others_1,
               tok_in      => sig_r_tok_0to1,
               tok_out     => sig_r_tok_1to2,
               tok_stat    => sig_r_tok_stat_1
               );
               
    arb_r_token_2 : r_token
    port map ( clk         => clk,
               reset       => reset,
               init        => '0',
               req         => sig_r_req_2,
               others_req  => sig_r_others_2,
               tok_in      => sig_r_tok_1to2,
               tok_out     => sig_r_tok_2to3,
               tok_stat    => sig_r_tok_stat_2
               );

    arb_r_token_3 : r_token
    port map ( clk         => clk,
               reset       => reset,
               init        => '0',
               req         => sig_r_req_3,
               others_req  => sig_r_others_3,
               tok_in      => sig_r_tok_2to3,
               tok_out     => sig_r_tok_3to0,
               tok_stat    => sig_r_tok_stat_3
               );

    arb_w_token_0 : w_token
    port map ( clk         => clk,
               reset       => reset,
               init        => '1',
               req         => sig_w_req_0,
               others_req  => sig_w_others_0,
               tok_in      => sig_w_tok_3to0,
               tok_out     => sig_w_tok_0to1,
               tok_stat    => sig_w_tok_stat_0
               );

    arb_w_token_1 : w_token
    port map ( clk         => clk,
               reset       => reset,
               init        => '0',
               req         => sig_w_req_1,
               others_req  => sig_w_others_1,
               tok_in      => sig_w_tok_0to1,
               tok_out     => sig_w_tok_1to2,
               tok_stat    => sig_w_tok_stat_1
               );
               
    arb_w_token_2 : w_token
    port map ( clk         => clk,
               reset       => reset,
               init        => '0',
               req         => sig_w_req_2,
               others_req  => sig_w_others_2,
               tok_in      => sig_w_tok_1to2,
               tok_out     => sig_w_tok_2to3,
               tok_stat    => sig_w_tok_stat_2
               );

    arb_w_token_3 : w_token
    port map ( clk         => clk,
               reset       => reset,
               init        => '0',
               req         => sig_w_req_3,
               others_req  => sig_w_others_3,
               tok_in      => sig_w_tok_2to3,
               tok_out     => sig_w_tok_3to0,
               tok_stat    => sig_w_tok_stat_3
               );

    core_0          :   single_cycle_core
    port map  ( reset       =>  reset,
                clk         =>  clk,
                w_req       =>  sig_w_req_0,
                r_req       =>  sig_r_req_0,
                w_en        =>  sig_w_tok_stat_0,
                r_en        =>  sig_r_tok_stat_0,
                w_b_addr    =>  sig_w_b_addr_bus,
                r_b_addr    =>  sig_r_b_addr_bus,
                w_mem_bus   =>  sig_w_mem_bus,
                r_mem_bus   =>  sig_r_mem_bus,
                addr_r_bus  =>  sig_addr_r_bus,
                addr_w_bus  =>  sig_addr_w_bus,
                core_num    =>  x"0000");
                
    core_1          :   single_cycle_core
    port map  ( reset       =>  reset,
                clk         =>  clk,
                w_req       =>  sig_w_req_1,
                r_req       =>  sig_r_req_1,
                w_en        =>  sig_w_tok_stat_1,
                r_en        =>  sig_r_tok_stat_1,
                w_b_addr    =>  sig_w_b_addr_bus,
                r_b_addr    =>  sig_r_b_addr_bus,
                w_mem_bus   =>  sig_w_mem_bus,
                r_mem_bus   =>  sig_r_mem_bus,
                addr_r_bus  =>  sig_addr_r_bus,
                addr_w_bus  =>  sig_addr_w_bus,
                core_num    =>  x"0001");
                
    core_2          :   single_cycle_core
    port map  ( reset       =>  reset,
                clk         =>  clk,
                w_req       =>  sig_w_req_2,
                r_req       =>  sig_r_req_2,
                w_en        =>  sig_w_tok_stat_2,
                r_en        =>  sig_r_tok_stat_2,
                w_b_addr    =>  sig_w_b_addr_bus,
                r_b_addr    =>  sig_r_b_addr_bus,
                w_mem_bus   =>  sig_w_mem_bus,
                r_mem_bus   =>  sig_r_mem_bus,
                addr_r_bus  =>  sig_addr_r_bus,
                addr_w_bus  =>  sig_addr_w_bus,
                core_num    =>  x"0002");
                
    core_3          :   single_cycle_core
    port map  ( reset       =>  reset,
                clk         =>  clk,
                w_req       =>  sig_w_req_3,
                r_req       =>  sig_r_req_3,
                w_en        =>  sig_w_tok_stat_3,
                r_en        =>  sig_r_tok_stat_3,
                w_b_addr    =>  sig_w_b_addr_bus,
                r_b_addr    =>  sig_r_b_addr_bus,
                w_mem_bus   =>  sig_w_mem_bus,
                r_mem_bus   =>  sig_r_mem_bus,
                addr_r_bus  =>  sig_addr_r_bus,
                addr_w_bus  =>  sig_addr_w_bus,
                core_num    =>  x"0003");
                
    data_mem : shared_memory
    port map ( reset        => reset,
               clk          => clk,
               write_enable => sig_read_enable,
               read_enable  => sig_write_enable,
               write_data   => sig_w_mem_bus,
               byte_addr_r	=> sig_r_b_addr_bus,
               byte_addr_w	=> sig_w_b_addr_bus,
               addr_in_r    => sig_addr_r_bus,
               addr_in_w    => sig_addr_w_bus,
               data_out     => sig_r_mem_bus );
               

end structural;
   