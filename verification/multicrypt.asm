;//////////////////////////////////////////////////
;//
;// Define registers
;// $0    r0    zero
;// $1    rc    core number
;// $2    rm    value of m (encrypt iterations)
;// $3    rn    value of n (tag iterations)
;// $4    rsz    size of string    
;// $5    s1    scratch 1
;// $6    s2 re    scratch 2
;// $7    s3 rkc    scratch 3
;// $8    ris    Pointer to input string
;// $9    ros    Pointer to output string
;// $10    rrn    Pointer to RNG table
;// $11    rkp  Initially pointer to key
;// $12    rk1     63 : 48 key copy (initially pointer to key)
;// $13    rk2     47 : 32 key copy
;// $14    rk3     31 : 16 key copy
;// $15    rk4     15 : 0  key copy
;//
;////////////////////////////////////////////////

ALIAS  r0   $0    ;   zero
ALIAS  rc   $1    ;   core number
ALIAS  rm   $2    ;   value of m (encrypt iterations)
ALIAS  rn   $3    ;   value of n (tag iterations)
ALIAS  rsz  $4    ;    size of string    
ALIAS  s1   $5    ;   scratch 1
ALIAS  s2   $6    ; 
ALIAS  re   $6    ;    scratch 2
ALIAS  s3   $7    ; 
ALIAS  rkc  $7    ;    scratch 3
ALIAS  ris  $8    ;    Pointer to input string
ALIAS  ros  $9    ;    Pointer to output string
ALIAS  rrn  $10   ;    Pointer to RNG table
ALIAS  rkp  $11   ;  Initially pointer to key
ALIAS  rk1  $12   ;     63 : 48 key copy (initially pointer to key)
ALIAS  rk2  $13   ;     47 : 32 key copy
ALIAS  rk3  $14   ;     31 : 16 key copy
ALIAS  rk4  $15   ;     15 : 0  key copy

nop
nop
nop
nop

nop
nop
nop
nop

; INITIALISATION
    lw  rkp  r0  0x2      ;  Load  Key     address
    lw  rrn  r0  0x4      ;  Load  Random  Table
    lw  ris  r0  0x6      ;  Load  Input   address
    lw  ros  r0  0x8      ;  Load  output  address
    lb  rc   r0  0x0     ;  load  core    number
    lw  rm   r0  0xa     ;  load  value   of       m
    lw  rn   r0  0xc     ;  load  value   of       n
    
    add  ris  ris  rc   ;//set    offset
    add  ros  ros  rc   ;//set    offset
    add  s1   r0   r0   ;//clear  scratch  registers
    add  s2   r0   r0   ;//clear  scratch  registers
    add  s3   r0   r0   ;//clear  scratch  registers
    
    addi  rk1  r0   0x7  ;//make      a         mask  for  the  loop  counter;//create  0x00ff  mask
    addi  rk4  r0   0xF  ;//00000000  00111111
    sll   rk4  rk4  0x2  ;//00000000  11111100
    addi  rk4  rk4  0xF  ;//00000000  11111111

    nop
    nop
    nop

    ;//begin encryption 
    ;//s1 keeps track of number of characters processed
    ;//s2 keeps track of encrypted character
    ;//s3 keeps track of the iteration number of the encrypt loop
ENCRYPT_STRING:
    ;//if chars_processed > num_chars finish
    beq s3 r0 ENCRYPT_CHAR    ;//encrypt if s3 == 0
    j   END_ENCRYPT_STRING        

ENCRYPT_CHAR:
    lb   re  ris 0x0   ;//load character to encrypt
    addi ris ris 0x4   ;//increase in string pointer
    add  rk2 rkp 0x0   ;//place key pointer in rk2
    add  s3  r0  r0    ;//reset the loop counter

ENCRYPT_LOOP:
    addi  s3  s3  0x1           ;//increment loop counter
    and   rk3 s3  rk4           ;//get the next subkey index (<8)
    slt   rk3 s3  rm            ;//check if loop counter < m
    lb    rk2 rk2 0x0           ;//load subkey 
    xor   re  re  rk2           ;//xor char with subkey
    add   rk2 re  rrn           ;//get a new table pointer
    and   rk2 rk2 rk4           ;//mask the table pointer
    lb    re  rk2 0x0           ;//load table value
    add   rk2 rk3 rkp           ;//update key pointer
    beq   rk3 r0 ENCRYPT_SAVE   ;//if counter !< m save character
    j     ENCRYPT_LOOP

ENCRYPT_SAVE:
    addi  s1  s1  0x4           ;//inc num of chars processed by 4
    slt   s3  rsz s1            ;//if rsz<s1 s3=1
    sb    re  ros 0x0           ;//store encrypted character
    addi  ros ros 0x4           ;//increment out string pointer
    j     ENCRYPT_STRING

END_ENCRYPT_STRING:

DOTAG:
    lw    rk4 rkp 0x6
    lw    rk3 rkp 0x4
    lw    rk2 rkp 0x2
    lw    rk1 rkp 0x0


    ;//strategy:
    ;//each processor will xor their own tags. Store tags at mem(tag + 2 + core id)
    ;// when each processor finishes its tag generation it will set mem(tag + 2 + core id + 4) to ff
    ;// processor 3 will (theoretically) finish last. 
    ;//Core 3 will poll mem(tag + 2 + 6 + (012)) to see if other processors are done
    ;//once it’s done core 3 will xor everyones results and place it in mem(tag)
    ;//available registers:
    ;//re s1 s3 rkp rrn rm
    ;// rkp: rkc 0x800
    ;// re: re…
    ;// rrn: s1
    ;// rm: ri
    ;// ris: tag / tag pointer
    ;//s1 keeps track of number of characters processed
    ;//s3 keeps track of the iteration number of the tag loop

    ; load constants 
    ;rkc    key comparison = 0x8000 for doshift
    addi    rkp $0  0x1         ; load 0x0001    
    sll     rkp rkp 0x15        ; make 0x8000

    lw   ros $0 0xc             ; Load output string pointer
    add  ros ros rc             ;//get out string offset

    nop
    nop
    nop

    add   s1  r0  r0            ;//initialize s1
    add   ris r0  r0            ;//initialize tag 
    add   s3  r0  r0            ;//initialize s3

DOTAG_STRING:
    ;//if chars_processed > num_chars finish
    slt   s3 rsz s1             ;//if rsz<s1 s3=1
    nop
    nop
    nop
    beq   s3 r0 DOTAG_CHAR      ;//make tag if s3 == 0
    j     END_DOTAG_STRING

DOTAG_CHAR:
    lb    re  ros  0x0           ;//load character to tag
    addi  ros ros  0x4           ;//increase out string pointer
    add   s3  r0   r0            ;//reset the  loop counter

    slt   rm  rk4  rkp          ; if rk4 < 1b80 MSB is 0 -> ri=1
    nop
    nop    
    nop 
    bne   rm $0 DONT_SHIFT      ; if ri != 0 (ri == 1) don'tshift

DOTAG_LOOP: ;//shift re n times
    addi  s3  s3  0x1        ;//increment counter
    slt   rrn s3  rn    ; //rrn = 1 if s3 < rn    
    sll   re  re  0x1     ; shift encrypted char left by 1
    bne   rrn r0  DONT_SHIFT
    j     DOTAG_LOOP

DONT_SHIFT:
    ; XOR the tag with the shifted character
    xor   ris re  ris    ;only the LS 8 bits needed. 
    ;Mask the output of the tag at END

    ; rotate key4 left
    slt   rm  rk4 rkp    ; if rk4 < 0x80 MSB = 0 -> ri = 1
    sll   rk4 rk4 0x1    ; shift rk4 left by 1

    slt   rrn rk1 rkp   ; if rk1 < 0x80 MSB = 0 -> s1 = 1
    sll   rk1 rk1 0x1    ; shift rk1 left by 1
    bne   rm  $0  0x1        ; if ri != 0 (ri == 1) don't add carry
    addi  rk1 rk1 0x1        ; add carry

    slt   rm  rk2 rkp    ; if rk2 < 0x80 MSB = 0 -> ri = 1
    sll   rk2 rk2 0x1    ; shift rk2 left by 1
    bne   rrn $0  0x1        ; if s1 != 0 (s1 == 1) don't add carry
    addi  rk2 rk2 0x1        ; add carry
    
    slt   rrn rk3 rkp    ; if rk3 < 0x80 MSB = 0 -> s1 = 1
    sll   rk3 rk3 0x1    ; shift rk3 left by 1
    bne   rm  $0  0x1        ; if ri != 0 (ri == 1) don't add carry
    addi  rk3 rk3 0x1        ; add carry 

    bne   rrn $0  0x1        ; if s1 != 0 (s1 == 1)no MSB to rotate
    addi  rk4 rk4 0x1        ; move MSB to LSB


END_DOTAG_STRING:
    addi  rrn  r0  0x3      ;load core number 3 into rrn
    lw    re   r0  0xe      ; Load tag pointer
    add   re   re  rc       ;//get tag offset
    sb    ris  re  0x2
    addi  rk1  r0  0x15
    sll   rk1  rk1 0x4
    addi  rk1  rk1 0x15     ; //generate 0xff code
    sb    rk1  re  0x6      ; //store operation complete code
    beq   rrn  rc COMPILE_TAG   ;    // make tag if this is core 3 
    j    EXIT

COMPILE_TAG:
    lw    re r0 0xe         ;//load tag pointer

;//wait for other cores to finish
WAIT_0:
    lb    rrn re 0x6
    nop
    nop
    nop
    beq  rk1 rrn WAIT_1
    j WAIT_0

WAIT_1:
    lb    rrn re 0x7
    nop
    nop
    nop
    beq  rk1 rrn WAIT_2
    j WAIT_1

WAIT_2:
    lb    rrn re 0x8 
    nop
    nop
    nop
    beq  rk1 rrn XOR_TAGS
    j WAIT_2

XOR_TAGS:

    lb    rk2 re 0x2
    lb    rk3 re 0x3
    lb    rk4 re 0x4
    lb    rrn re 0x5 ;//load the tags

    xor   rrn rk2 rrn
    xor   rrn rk3 rrn
    xor   rrn rk4 rrn ;//xor the tags

    sw    rrn  re 0x0
    sw    rrn  re 0xa
    sw    rrn  re 0xb
    sw    rrn  re 0xc
    sw    rrn  re 0xd
    sw    rrn  re 0xe
    sw    rrn  re 0xf

EXIT:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

