;//////////////////////////////////////////////////
;// Define registers
;// $0    R0    zero
;// $1    ri    scratch i
;// $2    re    encrypted character
;// $3    rkc    key comparison = 0x8000 for doshift
;// $4    rT    Tag
;// $5    rrn    Pointer to RNG table
;// $6    ris    Pointer to input string
;// $7    ros    Pointer to output string
;// $8    s1    scratch 1
;// $9    s2    scratch 2
;// $10    rm1  mask for 0x00FF
;// $11    rkp  Initially pointer to key
;// $12    rk1     15 : 0 key copy
;// $13    rk2     31 : 16 key copy
;// $14    rk3     47 : 32 key copy
;// $15    rk4     63 : 48 key copy
;//
;// -- $2    rT    tmp for encrypt (scratch t)
;//
;////////////////////////////////////////////////


ALIAS  R0    $0   ; zero
ALIAS  ri    $1   ; scratch i
ALIAS  re    $2   ; encrypted character
ALIAS  rkc   $3   ;  key comparison = 0x8000 for doshift
ALIAS  rT    $4   ; Tag
ALIAS  rrn   $5   ;  Pointer to RNG table
ALIAS  ris   $6   ;  Pointer to input string
ALIAS  ros   $7   ;  Pointer to output string
ALIAS  s1    $8   ; scratch 1
ALIAS  s2    $9   ; scratch 2
ALIAS   rm1  $10  ; mask for 0x00FF
ALIAS   rkp  $11  ; Initially pointer to key
ALIAS   rk1  $12  ;    15 : 0 key copy
ALIAS   rk2  $13  ;    31 : 16 key copy
ALIAS   rk3  $14  ;    47 : 32 key copy
ALIAS   rk4  $15  ;    63 : 48 key copy



INIT:

nop
nop
nop
nop

lw rkp $0 0     ; Load Key address
lw rrn $0 2     ; Load Random Table
lw ris $0 4       ; Load Input address
lw ros $0 6     ; Load string length

; copy the key
    ; This copies the key into registers.

lw rk1 ros 6    ; key1 = *key + 0
lw rk2 ros 4    ; key2 = *key + 2
lw rk3 ros 2    ; key3 = *key + 4
lw rk4 ros 0    ; key4 = *key + 6


; load constants 
;rkc    key comparison = 0x8000 for doshift
addi    rkc $0 1            ; load 0x0001    
sll     rkc  rkc 15         ; make 0x8000

;create rm1 (mask 0x00ff)
addi rm1  $0  0xf           ;make 0x000f
sll     rm1  rm1  4         ;make 0x00f0
addi rm1  rm1  0xf          ;make 0x00ff

MAIN:                       ; do {

    lb re ris  0            ; Load byte of string into re
                            ; tmp = string[j]
    addi ris ris 1          ; j++ or *string++
    nop
nop
bne re $0 STArT             ; if(*string != EOF) continue
j END

STArT: 

    ;for(ri = -8; ri < 0; ri++)
    addi ri   $0   8          ;ri = 8
    sub  ri   $0   ri         ;ri = -8

ENCRYPT_LOOP:
    addi ri   ri   1          ;increment ri by 1
    lb   s1   rkp  0          ;load subkey into s1
    xor  re   re   s1         ;xor subkey with char
    add  s2   rrn  re        ;get the index of the table
    lb   re   s2   0           ;retrieve value from rng table
    addi rkp  rkp  1        ;increment subkey pointer    
    nop
    beq  ri   $0   SAVE_ENCRYPT  ;once all 8 subkeys have been processed  save and do tag    
    j ENCRYPT_LOOP

SAVE_ENCRYPT:
    addi ri   $0   8
    sub  rkp  rkp  ri          ;rkp - 8 -> returned to original value
    sb   re   ros  0          ;store the output byte
    addi ros  ros  1        ;increment output str pointer
    
    
DOTAG:
    ; shift encrypted character left by 1 if needed
    slt    ri  rk4  rkc     ; if rk4 < 1b80  MSB is 0 -> ri=1
    nop
    nop    
    nop 
    bne    ri  $0  1        ; if ri != 0 (ri == 1)  don't shift
    sll    re  re  1        ; shift encrypted char left by 1

    ; XOR the tag with the shifted character
    xor     rT  re  rT      ;only the LS 8 bits needed. 
                            ;Mask the output of the tag at END

    ; rotate key4 left
    slt    ri  rk4  rkc     ; if rk4 < 0x80  MSB = 0 -> ri = 1
    sll    rk4 rk4  1       ; shift rk4 left by 1

    slt    s1  rk1  rkc     ; if rk1 < 0x80  MSB = 0 -> s1 = 1
    sll  rk1 rk1  1         ; shift rk1 left by 1
    bne    ri  $0  1        ; if ri != 0 (ri == 1) don't add carry
    addi    rk1 rk1 1       ; add carry

    slt    ri  rk2  rkc     ; if rk2 < 0x80  MSB = 0 -> ri = 1
    sll  rk2 rk2  1         ; shift rk2 left by 1
    bne    s1  $0  1        ; if s1 != 0 (s1 == 1) don't add carry
    addi    rk2 rk2 1       ; add carry
    
    slt    s1  rk3  rkc     ; if rk3 < 0x80  MSB = 0 -> s1 = 1
    sll  rk3 rk3  1         ; shift rk3 left by 1
    bne    ri  $0  1        ; if ri != 0 (ri == 1) don't add carry
    addi    rk3 rk3 1       ; add carry 

    bne    s1  $0  1        ; if s1 != 0 (s1 == 1)no MSB to rotate
    addi    rk4 rk4 1       ; move MSB to LSB

DOTAG_EXIT:

    j MAIN
END:
    and rT  rT  rm1         ;mask the tag
    sb        ros rT 4
    nop                    ; Finished.
