#!/usr/bin/python

import random

inputstring = "I Heart Huckabees."

intro = """

---------------------------------------------------------------------------
-- data_memory.vhd - Implementation of A Single-Port, 16 x 16-bit Data
--                   Memory.
-- 
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
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
 
entity data_memory is
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           write_enable : in  std_logic;
           read_enable  : in  std_logic;
           byte_addr    : in  std_logic;
           write_data   : in  std_logic_vector(15 downto 0);
           addr_in      : in  std_logic_vector(11 downto 0);
           data_out     : out std_logic_vector(15 downto 0) );
end data_memory;

architecture behavioral of data_memory is

type mem_array is array(0 to 255) of std_logic_vector(15 downto 0);
signal sig_data_mem : mem_array;
--signal sig_data_mem_tmp : mem_array;
--signal sig_var_addr_b : std_logic_vector (11 downto 0);

signal sig_dm_chosen : std_logic_vector (15 downto 0);
--signal sig_addr : std_logic_vector(11 downto 0);

begin
    mem_process: process ( clk,
                           write_enable,
                           write_data,
                           addr_in,
                           read_enable,
                           byte_addr) is
  
    variable var_data_mem : mem_array;
    variable var_addr     : integer;
    variable var_dm_out : std_logic_vector (15 downto 0);
    
    begin
        --var_addr := conv_integer(addr_in);
        
        --var_addr_b (10 downto 0) <= addr_in (11 downto 1);
        var_addr := conv_integer(addr_in);
        var_addr := var_addr / 2;
        
        if (reset = '1') then
"""

outro = """


        elsif (falling_edge(clk) and write_enable = '1') then
            -- memory writes on the falling clock edge 
            if(byte_addr = '1') then
            -- Take the relevant byte and zero extend
                if(addr_in(0) = '1') then
                    var_data_mem(var_addr)(15 downto 8) := write_data(7 downto 0);
                else
                    var_data_mem(var_addr)(7 downto 0) := write_data(7 downto 0);       
                end if;
            else                
            -- WORD Addressible
                if(addr_in(0) = '1') then
                    var_data_mem(var_addr)(15 downto 8) := write_data(7 downto 0);
                    var_data_mem(var_addr + 1)(7 downto 0) := write_data(15 downto 8);
                else
                    var_data_mem(var_addr) := write_data;
                end if;
            end if;
        
            
            --var_data_mem(var_addr) := write_data;
        end if;
       
        -- continuous read of the memory location given by var_addr 
        --data_out <= var_data_mem(var_addr);
        
        if(read_enable = '1') then
            -- Byte Addressible Mode
            report "The Address Requested is " & integer'image(var_addr);   
            if(byte_addr = '1') then
                -- Take the relevant byte and zero extend
                if(addr_in(0) = '1') then
                    var_dm_out := X"00" & var_data_mem(var_addr)(15 downto 8);
                else
                    var_dm_out := X"00" & var_data_mem(var_addr)(7 downto 0);           
                end if;
            else                
                -- WORD Addressible
                if(addr_in(0) = '1') then
                    var_dm_out(7 downto 0) := var_data_mem(var_addr)(15 downto 8);
                    var_dm_out(15 downto 8) := var_data_mem(var_addr + 1)(7 downto 0);
                else
                    var_dm_out := var_data_mem(var_addr);
                end if;
            end if;
        else
            var_dm_out := "0000000000000000";
        end if;
        
        data_out <= var_dm_out;
        
        
        -- the following are probe signals (for simulation purpose) 
        sig_data_mem <= var_data_mem;

    end process;
  
end behavioral;

"""


def makepairs(a):
    out=[]
    tmp=[]
    for i in range(len(a)):
        if i%2:
            tmp.insert(0,a[i])  
            out.append(tmp)
            tmp=[]
        else:
            tmp.append(a[i])  

    # This makes sure we always return full pairs
    if len(tmp) %2:
        tmp.append(0,0)
        out.append(tmp)
    return out
            


key = [
    0x12,
    0x34,
    0x56,
    0x78,
    0x9a,
    0xBC,
    0xDE,
    0xf0,
]

randomarray=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255]



inputarray = [ ord(a) for a in inputstring]

outputarray=[0 for a in inputstring]

for i in range(4):
    outputarray[2*i + 1] = key[2*i]
    outputarray[2*i] = key[2*i + 1]


print intro

initialoffset = 8
print
print "-- Initial Array"
print
pos=8*2
current = 0
print "var_data_mem({}) := X\"{:04X}\"; -- Offset to key in bytes".format(current,pos)
pos+=len(key) + 8
current += 1
print "var_data_mem({}) := X\"{:04X}\"; -- Offset to random array in bytes".format(current,pos)
pos+=len(randomarray) + 8
current += 1
print "var_data_mem({}) := X\"{:04X}\"; -- Offset to Input array in bytes".format(current,pos)
pos+=len(inputarray)+ 4
current += 1
print "var_data_mem({}) := X\"{:04X}\"; -- Length of the input string in bytes".format(current,len(inputarray) )
current += 1

for i in range(4):
    print "var_data_mem({}) := X\"{:04X}\"; -- padding".format(current,0)
    current += 1

print
print "-- Key "
print
for i, a in enumerate(makepairs(key)):
    print "var_data_mem({}) := X\"{:02X}{:02X}\"; -- key[{}]".format(current,a[0],a[1],i)
    current += 1

for i in range(4):
    print "var_data_mem({}) := X\"{:04X}\"; -- padding".format(current,0)
    current += 1

print
print "-- Random "
print
for i, a in enumerate(makepairs(randomarray)):
    print "var_data_mem({}) := X\"{:02X}{:02X}\"; -- randomarray[{}]".format(current,a[0],a[1],i)
    current += 1

for i in range(4):
    print "var_data_mem({}) := X\"{:04X}\"; -- padding".format(current,0)
    current += 1

print
print "-- Input " 
print
for i, a in enumerate(makepairs(inputarray)):
    print "var_data_mem({}) := X\"{:02X}{:02X}\"; -- inputarray[{}] : \'{}{}\'".format(current,a[0],a[1],i,chr(a[0]),chr(a[1]))
    current += 1

for i in range(4):
    print "var_data_mem({}) := X\"{:04X}\"; -- padding".format(current,0)
    current += 1

print
print "-- Output " 
print

for i, a in enumerate(makepairs(outputarray)):
    print "var_data_mem({}) := X\"{:02X}{:02X}\"; -- outputarray[{}]".format(current,a[0],a[1],i)
    current += 1

for i in range(4):
    print "var_data_mem({}) := X\"{:04X}\"; -- padding".format(current,0)
    current += 1


print outro
