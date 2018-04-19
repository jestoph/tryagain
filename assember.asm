INIT:
	# copy the key

	# This copies the key into registers.
	lw   rk1,0(rk4)			# key2 = *key1
	add  rk4,k4,1			# key1++
	lw   rk2,0(rk4)			# key2 = *key1
	add  rk4,rk4,1			# key1++
	lw   rk3,0(rk4)			# key2 = *key1
	add  rk4,rk4,1			# key1++
	lw   rk4,0(rk4)			# key2 = *key1

	# rk[0:3] now have the key (needed later for shifting)

	# load constants 
	#rkc	key comparison = 0x8000 for doshift
	addi rkc, $0, 1			# load 0x0001	
	srl  rkc, rkc,1			# make 0x8000

	#create rm1 (mask 0x00ff)
	addi rm1, $0, 0xf		#make 0x000f
	sll  rm1, rm1, 1		#make 0x00f0
	addi rm1, rm1, 0xf		#make 0x00ff

MAIN:						# do {

	#
	# ENCRYPT method
	# 
	# Encrypts a single byte of the input string
	# Leaves the result in register ‘re’
	# Writes the result to the output string

	lb   re ris			# Load byte of string into re
						# tmp = string[j]

	addi s1,$0,15		# s1 = 15
	addi s1,$0,1		# s1 = 16
	add  s2,$0,$0		# Load an immediate in to scratch
	add  s2,$0,rkp		# set s2 to the start of the key
ENCRYPT:				# This is our for(i=0# i!=16 # i++){
	lb   ri,0(s2)		# ri = key[i] / ri = *(s2) 
						# ie. Load byte of key into scratch	
	addi s2,s2,1		# i++
	xor  re,re,ri		# tmp = tmp ^ key[i]

	and  re,re,s1		# mask for random table
	add  re,re,rrn		# set re to rrn + re
	lb   re,0(re)			# Load mem(re) into re

	add  s2,s2,1			# reduce index
	bne  s2,s1,ENCRYPT_EXIT

	# end of loop. Loop if s2 != 16
	j	 ENCRYPT			# }

ENCRYPT_EXIT:

	and  re,re,0x1f		# Mask the output to make ascii
	sb   ros,ri			# *output = tmp & 0x1f
	addi ros,ros,1		# output ++

DOTAG:
	# shift encrypted character left by 1 if needed
	slt	 ri, rk1, rkc	# if rk1 < 1b80, Msb is 0 -> ri=1
	bne	 ri, $0, 1		# if ri != 0 (ri == 1), don't shift
	sll	 re, re, 1 		# shift encrypted char left by 1

	# XOR the tag with the shifted character
	xor  s1, re, s1	#only the Ls 8 bits needed. 
	#Mask the output of the tag at END

	# rotate key2 left
	slt	 ri, rk4, rkc	# if rk4 < 0x80, Msb = 0 -> ri = 1
	sll	 rk4,rk4, 1		# shift rk4 left by 1

	slt	 s1, rk3, rkc   # if rk3 < 0x80, Msb = 0 -> s1 = 1
	sll  rk3,rk3, 1		# shift rk3 left by 1
	bne	 ri, $0, 1		# if ri != 0 (ri == 1) don't add carry
	addi rk3,rk3,1		# add carry

	slt	 ri, rk2, rkc	# if rk2 < 0x80, Msb = 0 -> ri = 1
	sll  rk2,rk2, 1		# shift rk2 left by 1
	bne	 s1, $0, 1		# if s1 != 0 (s1 == 1) don't add carry
	addi rk3,rk3,1		# add carry
	
	slt	 s1, rk1, rkc	# if rk1 < 0x80, Msb = 0 -> s1 = 1
	sll  rk1,rk1, 1		# shift rk1 left by 1
	bne	 ri, $0, 1		# if ri != 0 (ri == 1) don't add carry
	addi rk1,rk1,1		# add carry 

	bne	 s1, $0, 1		# if s1 != 0 (s1 == 1)no Msb to rotate
	addi rk4,rk4,1		# move Msb to Lsb

DOTAG_EXIT: 	# Modify Tag given output and key
				
	add  ris,ris,1		# j++ or *string++
	beq  row,$0,END		# } while(*string == EOF) - skip loop if done 
	j	 MAIN
END:
	and  rT,rT,rm1		#mask the tag
	nop					# Finished.