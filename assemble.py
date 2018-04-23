#!/usr/bin/python
import sys

# An example use of this would be to translate the following:
#
#  ALIAS x $3
#  ALIAS i $7
#  ALIAS y $2
#  
#  addi i $0 7      ; Do loop seven times
#  addi x $0 1
#  # Begin loop
#  sub i i x
#  slt y x i # 2 <- $7 < 1? 1 : 0
#  beq y x -2 
#  nop


intro = """
---------------------------------------------------------------------------
-- instruction_memory.vhd - Implementation of A Single-Port, 16 x 16-bit
--                          Instruction Memory.
-- 
-- Notes: refer to headers in single_cycle_core.vhd for the supported ISA.
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

entity instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(11 downto 0);
           insn_out : out std_logic_vector(15 downto 0) );
end instruction_memory;

architecture behavioral of instruction_memory is

type mem_array is array(0 to 512) of std_logic_vector(15 downto 0);
signal sig_insn_mem : mem_array;

begin
    mem_process: process ( clk,
                           addr_in ) is
  
    variable var_insn_mem : mem_array;
    variable var_addr     : integer;
  
    begin
        if (reset = '1') then




"""

outro = """
        elsif (rising_edge(clk)) then
            -- read instructions on the rising clock edge
            var_addr := conv_integer(addr_in);
            insn_out <= var_insn_mem(var_addr);
        end if;

        -- the following are probe signals (for simulation purpose)
        sig_insn_mem <= var_insn_mem;

    end process;
  
end behavioral;


"""


instructions = {
    'add'   : 0x8, 
    'xor'   : 0xd, 
    'nop'   : 0x0, 
    'sub'   : 0xb, 
    'slt'   : 0xa, 
    'and'   : 0xc, 
    'addi'  : 0x9, 
    'sll'   : 0xe, 
    'srl'   : 0xf, 
    'bne'   : 0x4, 
    'beq'   : 0x6, 
    'j'     : 0x2, 
    'lw'    : 0x1, 
    'sw'    : 0x3, 
    'lb'    : 0x5, 
    'sb'    : 0x7, 
}

# This holds any register aliases
aliases = {}

registers = {}
for i in range(16):
    registers["$" + str(i)] = i

# This holds any jumps
labels = {}

def isint(a):
    try:
        if int(a):
            return True
        int(a,16)
        return True
    except:
        return False

def getint(a):
    try:
        return int(a)
    except:
        return int(a,16)

def parsefile(file):
    lines = []
    index = 0
    for line in file:

        if "ALIAS" in line:
            vals = line.split()
            aliases[vals[1]] = vals[2]
            continue

        data= {}
        things=line.strip().split("#")

        data['textinstruction'] = things[0]

        if len(things[0]) < 1 and len(things) > 1:
            data['comment'] = things[1]
            lines += [data]
            continue
        elif len(things[0]) < 1:
            continue
        if len(things) > 1:
            data['comment'] = things[1]

        parts = [a.strip() for a in things[0].split()]

        # Handle jumps differently - destination may not be registers yet
        
        data['inst'] = ""

        # First word is an instruction or a label
        # We filter out the 'odd' ones here
        # ie Lables, Jump and Nop
        if parts[0] == "nop":
            data['inst'] += "0000"
            index += 1
            lines.append(data)
            continue
        elif parts[0] == 'j':
            data['inst'] += "{:X}".format(instructions[parts[0]])
            data['tojump'] = parts[1]
            index += 1
            lines.append(data)
            continue
        elif ":" in parts[0]:
            labels[parts[0].replace(":","")] = index
            data['label'] = parts[0].replace(":","")
            lines.append(data)
            continue


        # If we get here then we have a four-field instruction
        if len(parts) < 4:
            Exception("Unknown instruction ", parts)

        # Substitute any aliases
        for i in range(1,4):
            if parts[i] in aliases:
                parts[i] = aliases[parts[i]]

        data['inst'] += "{:X}".format(instructions[parts[0]])
        data['inst'] += "{:X}".format(registers[parts[2]])

        if parts[3] in registers:
            data['inst'] += "{:X}".format(registers[parts[3]])
            # Destination Register
            data['inst'] += "{:X}".format(registers[parts[1]])
        elif isint(parts[3]):
            # Destination Register
            data['inst'] += "{:X}".format(registers[parts[1]])
            data['inst'] += "{:X}".format(getint(parts[3]) & 0xf)
        elif 'bne' in parts[0] or 'beq' in parts[0]:
            data['inst'] += "{:X}".format(registers[parts[1]])
            data['tobranch'] = parts[3]
        else:
            Exception("I don't know how to handle", parts[3], "in", parts)

        index += 1
                

        lines.append(data)

    return lines

        
def dumpfile(file,lines):


    file.write(intro)
    index = 0
    for line in lines:
        output=""
        if 'label' in line:
            output += "-- " + line['label']               
        elif 'inst' in line:
            output += "var_insn_mem("+str(index)+") := X\""+line['inst']
            if 'tojump' in line:
                output += "{:03X}".format(labels[line['tojump']])
            if 'tobranch' in line:
                length = labels[line['tobranch']] - index
                if abs(length) > 8:
                    Exception("Branch instruction can only jump 8 instructions")
                output += "{:01X}".format(length & 0xf)
            output += "\"; "
            index += 1

        output += "--" + line['textinstruction']
        if 'comment' in line:
            output += "#"+line['comment']
        file.write(output)
        file.write("\r\n")


        #print output
        
    file.write(outro)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print "Usage: ",sys.argv[0],"filename"
    else:
        with open(sys.argv[1]) as file:
            lines = parsefile(file)
            with open(sys.argv[1]+".out", "w") as file:
                dumpfile(file, lines)
