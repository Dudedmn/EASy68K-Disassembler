*-----------------------------------------------------------
* Title      : OP Code routines for Disassembler
* Written by : Daniel Yan
* Date       : 2/28/2019, Updated 3/9/2019

* Description: Op code determining to identify values


;FAHAD CODE
; ORG place for G_BUFFER
; ORG place for CUR_OP_CODE
; ORG place for VALID_OP_CODE
; ORG place for all other constants
; ORG START $1000
; WE NEED TO SEE APPROX HOW MUCH ADDRESS SPACE ALL OUR ROUTINES COVER
; ORG OUR CONSTANTS/BUFFERS AT A SAFE DISTANCE BETWEEN ROUTINES AND TEST PROGRAM

; MEMORY_ADDRESS OPCODE $HEX_VALUE
;G_BUFFER
; 1254 MOVEA.L A3,A6, $3ASD
; 1254 RTS $4E75
;B_BUFFER
; 1254 DATA $CURRENT_OP

; JSR INVALID_OP
; 

; 8800 MOVEA.L A3,A6 $3FCA
; 8800 DATA $3FCA

  ORG $1000 ; Start at Address $1000
CUR_OP_CODE DS.W 1  ; Current OP Code Word
EA_SIZE     DS.B 1
G_BUFFER    DS.B 80
B_BUFFER    DS.B 80
MNEMONIC    DS.B 1
FIRST_3     DS.B 1
SECOND_3    DS.B 1
THIRD_3     DS.B 1
FOURTH_3    DS.B 1

P_OP_MOVEA_L_T  DC.L    'MOVEA.L',0
P_OP_MOVEA_L_A_L DC.L   'A.L',0
    LEA G_BUFFER,A4
    

START
    ; Start the op code routine
    ;LEA G_BUFFER, A4
    MOVE.B #0, (A4)
    
    ;MOVE.L (A5)+, D0
    
    ; Load the message onto A4
    ;MOVE.L #P_OP_MOVEA_L_T, Arg_AddStrToBuffer_String
    ;MOVE.L #G_BUFFER, Arg_AddStrToBuffer_Buffer 
    
    
    ;JSR AddStrToBuffer
    ;LEA G_BUFFER, A4   ; Load the value of the message onto the G_BUFFER
    ;MOVE.L P_OP_MOVEA_L_T,(A4)+
    ;MOVE.L P_OP_MOVEA_L_A_L,(A4)+
    
    
    

    ; AFTER THIS POINT THE BUFFER HAS THIS 'MOVE' + 'A.L'          ; Increment 4 spaces in the address
    
    
       
    
   
   ;This is the right area for pointer now, however when I add here it can't go
   ;back 
*********************************************************************************
* Here I'm attempting to 'skip' forward in the address to find the proper location for the string
* In the prior command 'LEA P_OP_MOVEA_L,A4' I have loaded 'MOVE' into address space. I cannot move
* more than 4 bytes (long) at a single time, so I need to move 'A.L' after which is 3 more bytes
* So what I need to do is LOAD 'MOVE' into the address space, skip 4 bytes, then load 'A.L' right
* after 'MOVE'. So this would show 'MOVEA.L' in the address space. Which then Denny can load his stuff
* after mine.
*
*In the ideal world this would look something like: P_OP_MOVEA_L then P_OP_A_L then _P_OP_TAB
* which would appear as 'MOVEA.L    ' in the address space. This would require 4 increments
* after MOVE, then 'A.L' being inserted, then 3 increments (or 7 from start) for the tab
********************************************************************************* 
    
    ;ADD.L $FFFF,G_BUFFER_PREP
    ;LEA P_OP_A_L,A1
    ;MOVE.L (A4),G_BUFFER_PREP
    
***************************** Input Tests ********************************************
    ***GROUP 0 tests**** SUPPORTED: ORI, BCLR (static, dynamic), CMPI
    
    ***GROUP 1 tests**** SUPPORTED: MOVE.B
    
    ***GROUP 2 tests**** SUPPORTED: MOVEA.L, MOVE.L
    
    ***GROUP 3 tests**** SUPPORTED: MOVEA.W, MOVE.W
    
    ***CATEGORIZE THESE TESTS INTO APPROPRIATE AREA****************
    ;MOVE.W #%0000100010000010,CUR_OP_CODE       ;Static BCLR
    ;MOVE.W #%0000111110001110,CUR_OP_CODE       ;Dynamic BCLR
    ;MOVE.W #%0000000001000001,CUR_OP_CODE       ;ORI.W D1
        
    ;MOVE.W #%0000111110001110,CUR_OP_CODE              ;Dynamic BCLR
    ;IN HEX $018E. D7 = 110, D6 = 001, D4 = %110, D5 = 7, (A6) = %0000
    ;MOVE.W #%0000100010001110,CUR_OP_CODE              ;Static BCLR
    ;IN HEX $018E. D7 = 110, D6 = 001, D4 = %110, D5 = 7, (A6) = %0000
   
    ;MOVE.W  #$018E,CUR_OP_CODE                        ;Dynamic BCLR in hex
    ;MOVE.W  #$02FF,CUR_OP_CODE                         ;INVALID_OP code
    ;MOVE.W #%0000110001010111,CUR_OP_CODE
    ;MOVE.W #%0010011001001101,CUR_OP_CODE                       ;MOVEA  
     ;MOVE.W #%0010001001001101,CUR_OP_CODE              ;MOVEA.L A5,A1
    ;MOVE.W CUR_OP_CODE,(A6)
    ;MOVE.W #$264D
    ;Expected values:
    ;D7, DST REG:   011
    ;D6, DST MODE:  001
    ;D5, SRC REG:   101
    ;D4, SRC MODE:  001
    ;CHECK IF DST MODE IS %111 or SRC MODE IS %111 for MOVE
    ;(A3), DST TRAIL:  001
    ;(A2), SRC TRAIL: ONLY FOR MOVE
    ;MOVE.W #%0010000000001101,CUR_OP_CODE              ;MOVE.L A5,A1
    ;MOVE.W #%0011011001001101,CUR_OP_CODE              ;MOVEA.W A5,A1
    ;MOVE.W #%1001011001111101,CUR_OP_CODE               ;MOVE TO TEST PARSE_EA_CONSTANT_BITS
    ;MOVE.W #%0011000000001101,CUR_OP_CODE              ;MOVE.W A5,A1
    ;MOVE.W #%0000000001000001,CUR_OP_CODE              ;ORI.W D1
    ;MOVE.W CUR_OP_CODE,A6                              ;Loading memory space to address register
    ;MOVE.W CUR_OP_CODE,(A6)                            ;Loading memory value to address value
    ***CATEGORIZE THESE TESTS INTO APPROPRIATE AREA***************
    
    
    ****GROUP 4 tests**** SUPPORTED: LEA, JSR, RTS, NEG, MOVEM
    ;MOVE.W #$4E75,CUR_OP_CODE                            ;RTS
    ;MOVE.W #$4E71,CUR_OP_CODE                            ;NOP
    ;MOVE.W #$4415,CUR_OP_CODE                            ;NEG.L D5
    ;MOVE.W #$43CC,CUR_OP_CODE                            ;LEA A1,A6
    ;MOVE.W #%0100100010001110,CUR_OP_CODE
    ;MOVE.W #$488E,CUR_OP_CODE                            ;MOVEM.W Reg to Mem, A6
    ;MOVE.W #$4C8E,CUR_OP_CODE                            ;MOVEM.W Mem to Reg, A6
    ;MOVE.W #$4E95,CUR_OP_CODE                            ;JSR (A5)               
    ****GROUP 5 tests****
    ;MOVE.W #%0101111110001111
    
    *****GROUP 5 TESTS**** SUPPORTED: SUBQ
    ;#%0101111100000101, SUBQ.B D5
    ;MOVE.W #$5F05,CUR_OP_CODE ; for SUBQ.B D5
    ;#%0101111110001110, SUBQ.L A6 
    ;MOVE.W #$5F8E,CUR_OP_CODE
    ******GROUP 5 VALIDATION TESTS**********
    ;MOVE.W #%0101111000001110,CUR_OP_CODE  ; ADDQ
    ;MOVE.W #%0101010011000110,CUR_OP_CODE ; Scc
    ;MOVE.W #%0101010011001110,CUR_OP_CODE ; DBcc
   
    *****GROUP 6 TESTS********* SUPPORTED: BCS,BGE,BLT,BVC
    ; DISPLACEMENT, $00 is 16 bits, $FF is 32 bits
    ; DISPLACEMENT = Last 8 bits
    ;MOVE.W #%0110000001010101,CUR_OP_CODE   ;BRA
    ;MOVE.W #%0110010100000001,CUR_OP_CODE   ;BCS
    ;MOVE.W #%0110110001010100,CUR_OP_CODE   ;BGE
    MOVE.W #%0110110110101010,CUR_OP_CODE   ;BLT
    ;MOVE.W #%0110100001010100,CUR_OP_CODE   ;BVC
    
    *****GROUP 7 TESTS**********        ;Should be ALL INVALID
    
    *****GROUP 8 TESTS********** SUPPORTED: DIVS, OR
    
    *****GROUP 9 TESTS********** SUPPORTED: SUB
    
    *****GROUP A TESTS**********        ;Should be ALL INVALID
    
    *****GROUP B TESTS********** SUPPORTED: EOR, CMP
    
    *****GROUP C TESTS********** SUPPORTED: MULS
    
    *****GROUP D TESTS********** SUPPORTED: ADD, ADDA
    
    *****GROUP E TESTS********** SUPPORTED: LSX, ASX, ROX
    
    *****GROUP F TESTS**********        ;Should be ALL INVALID
    
    
    
************************************************************************************
* PRINTING BUFFER FUNCTION HAS BEEN FINISHED
*-----------------------------------------------------------
*First Nibble Values (15-12)
*Value                  Operations
*$0                     GROUP_0: ORI,BCLR (static and dynamic),CMPI --- DONE, need validation testing
*$1                     GROUP_1: MOVE.B                             --- DONE, need validation testing
*$2                     GROUP_2: MOVE.L, MOVEA.L                    --- DONE, need validation testing
*$3                     GROUP_3: MOVE.W, MOVEA.W                    --- Partial, needs trailing bits
*$4                     GROUP_4: LEA,JSR,RTS,NEG,MOVEM              --- Partial, needs SIZE print for NEG, MOVE
*$5                     GROUP_5: SUBQ                               --- Partial, needs SIZE pri
*$6                     GROUP_6: Bcc(BCS,BGE,BLT,BVC), BRA          --- Not started
*$7                     GROUP_7: INVALID_OP                         --- DONE
*$8                     GROUP_8: DIVS, OR                           --- Not started
*$9                     GROUP_9: SUB                                --- Not started
*$A                     GROUP_A: INVALID_OP                         --- DONE
*$B                     GROUP_B: EOR, CMP                           --- Not started
*$C                     GROUP_C: MULS                               --- Not started
*$D                     GROUP_D: ADD, ADDA                          --- Not started
*$E                     GROUP_E: LSR, LSL, ASR, ASL, ROL, ROR       --- Not started
*$F                     GROUP_F: INVALID_OP                         --- DONE


* OP_JSR_Routine
**********************************************************************************
* Description: Catalog all supported OP codes into groupings based on their hex
* values. Sort the supported OP codes by looking at the first nibble for their
* grouping value. Call underlying subroutines for further identification of the
* op code.
*
* Registers used: A6,D0,D1 
*
* Precondition: Instruction set (size Word) has been loaded in the appropriate
* address to be parsed and read.

* Postcondition: OP code has been identified as either valid or invalid. If it is
* valid, it is stored into A6 and EA parsing methods are called to pass needed
* information to EA. If invalid, DATA output will be utilized to indicate so.
**********************************************************************************
* These valid operand codes refer to the basic supported operand codes
* Groups refer to the first nibble value that is supported by the operand
LOAD_OP_CODE:
    MOVE.W CUR_OP_CODE,D0
    MOVE.W CUR_OP_CODE,(A6)
    MOVE.W (A6),D0          ;Load current instruction set into D0
    JSR OP_JSR_Routine      ;Use the JSR routine to identify the op code
OP_JSR_Routine:
    MOVEM.L D0-D1, -(SP)           ;Backup registers D0 and D1 by pushing it on the Stack
    MOVE.L #12, D1                 ;Prepare bit shift left for D1   
    LSR.L   D1,D0                  ;Shift 12 bits to only get first 4 bits for D0

GROUP_0:                ;$0| ORI, BCLR (static and dynamic), CMPI                  
    CMP.B   #$0,D0                 ;Compare first nibble
    BNE     GROUP_1                ;If first nibble value isn't $0, branch to next
    JSR     C_GROUP_0              ;Jump to group 0 checking if nibble value is $0
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished
    
GROUP_1:                ;$1| MOVE.B
    CMP.B   #$1,D0                 ;Compare first nibble
    BNE     GROUP_2                ;If first nibble value isn't $1, branch to next
    JSR     C_GROUP_1              ;Jump to group 1 checking if nibble value is $1
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished

GROUP_2:                ;$2| MOVE.L, MOVEA.L
    CMP.B   #$2,D0                 ;Compare first nibble
    BNE     GROUP_3                ;If first nibble value isn't $2, branch to next
    JSR     C_GROUP_2              ;Jump to group 2 checking if nibble value is $2
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished

GROUP_3:                ;$3| MOVE.W, MOVEA.W
    CMP.B   #$3,D0                 ;Compare first nibble
    BNE     GROUP_4                ;If first nibble value isn't $3, branch to next
    JSR     C_GROUP_3              ;Jump to group 3 checking if nibble value is $3
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished

GROUP_4:                ;$4| LEA, JSR, RTS, NEG, MOVEM
    CMP.B   #$4,D0                 ;Compare first nibble
    BNE     GROUP_5                ;If first nibble value isn't $4, branch to next
    JSR     C_GROUP_4              ;Jump to group 4 checking if nibble value is $4
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished


GROUP_5:                ;$5| SUBQ
    CMP.B   #$5,D0                 ;Compare first nibble
    BNE     GROUP_6                ;If first nibble value isn't $5, branch to next
    JSR     C_GROUP_5              ;Jump to group 5 checking if nibble value is $5
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished


GROUP_6:                ;$6| Bcc (BCS,BGE,BLT,BVC) BRA
    CMP.B   #$6,D0                 ;Compare first nibble
    BNE     GROUP_7                ;If first nibble value isn't $6, branch to next
    JSR     C_GROUP_6              ;Jump to group 6 checking if nibble value is $6
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished


GROUP_7:                ;$7| Display: DATA, $WXYZ (Unsupported)
    CMP.B   #$7,D0                 ;Compare first nibble
    BNE     GROUP_8                ;If first nibble value isn't $7, branch to next
    JSR     C_GROUP_7              ;Jump to group 7 checking if nibble value is $7
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished


GROUP_8:                ;$8| DIVS, OR
    CMP.B   #$8,D0                 ;Compare first nibble
    BNE     GROUP_9                ;If first nibble value isn't $8, branch to next
    JSR     C_GROUP_8              ;Jump to group 8 checking if nibble value is $8
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished


GROUP_9:                ;$9| SUB
    CMP.B   #$9,D0                 ;Compare first nibble
    BNE     GROUP_A                ;If first nibble value isn't $9, branch to next
    JSR     C_GROUP_9              ;Jump to group 9 checking if nibble value is $9
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished


GROUP_A:                ;$A| Display: DATA, $WXYZ (Unsupported)
    CMP.B   #$A,D0                 ;Compare first nibble
    BNE     GROUP_B                ;If first nibble value isn't $A, branch to next
    JSR     C_GROUP_A              ;Jump to group A checking if nibble value is $A
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished


GROUP_B:                ;$B| EOR, CMP
    CMP.B   #$B,D0                 ;Compare first nibble
    BNE     GROUP_C                ;If first nibble value isn't $B, branch to next
    JSR     C_GROUP_B              ;Jump to group B checking if nibble value is $B
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished


GROUP_C:                ;$C| MULS
    CMP.B   #$C,D0                 ;Compare first nibble
    BNE     GROUP_D                ;If first nibble value isn't $C, branch to next
    JSR     C_GROUP_C              ;Jump to group C checking if nibble value is $C
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished


GROUP_D:                 ;$D| ADD, ADDA
    CMP.B   #$D,D0                 ;Compare first nibble
    BNE     GROUP_E                ;If first nibble value isn't $D, branch to next
    JSR     C_GROUP_D              ;Jump to group D checking if nibble value is $D
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished


GROUP_E:                ;$E| LSR, LSL, ASR, ASL, ROL, ROR
    CMP.B   #$E,D0                 ;Compare first nibble
    BNE     GROUP_F                ;If first nibble value isn't $E, branch to next
    JSR     C_GROUP_E              ;Jump to group E checking if nibble value is $E
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished


GROUP_F:                ;$F| Display: DATA, $WXYZ (Unsupported)
    CMP.B   #$F,D0                 ;Compare first nibble
    JSR     C_GROUP_F              ;Jump to group F checking if nibble value is $F
    BRA     OP_JSR_DONE            ;Finish subroutine once checking is finished


OP_JSR_DONE:
         MOVEM.L (SP)+,D0-D1       ;Recover register D0
         JMP READ_NEXT_INSTRUCTION
**********************************************************************************

********** EA Parsing ************************************************************

* MOVE_LAST_6_BITS_TO_EA
**********************************************************************************
* Description: For OP codes with the last 6 bits specified as EA Mode and EA Reg,
* the last 6 bits will be parsed and moved into the appropriate registers.
*
* Registers used: A6,D0,D1,D6,D7 

* Precondition: OP code has been identified with only the last 6 bits for EA,
* current instruction set is stored into A6.

* Postcondition: Last 6 bits of instruction bit has been isolated and stored. Bits
* for EA Mode have been stored in D7, Bits for EA Reg been stored in D6.
**********************************************************************************
MOVE_LAST_6_BITS_TO_EA:      ;Move last 6 bits from EA field to relevant registers
   ; MOVEM.L D0-D7/A6, -(SP)  ;Save all changed registers
    MOVE.W CUR_OP_CODE,D0           ;Move current OP code into D0
    MOVE.W  #10,D1           ;Prepare 10 bit shift to D1
    LSL.W   D1,D0            ;Truncate to find the last 6 bits
    LSR.W   D1,D0            ;Shift back to get the proper 6 bits
    MOVE.W  D0,D7            ;Move last 6 bits into D7
    MOVE.W  #3,D1            ;Prepare 3 bit shift into D1
    LSR.W   D1,D7            ;Shift 3 bits off D7 to obtain EA Mode
    MOVE.W  D7,D6            ;Move the 'upper' 3 bits into D6
    MOVE.W  #13,D1           ;Prepare 13 bit shift into D1
    LSL.W   D1,D0            ;Shift D0 left 13 bits to reposition current 3 bits
    LSR.W   D1,D0            ;Shift D0 right 13 bits to reposition current 3 bits
    MOVE.W  D0,D7            ;Move the 'lower' 3 bits into D7
   ; MOVEM.L (SP)+,D0-D7/A6   ;Restore registers
    RTS                      ;Return to stack
    
* FIND_2_BIT_SIZE_TO_EA
**********************************************************************************
* Description: For OP codes with 2 bit size fields, the 2 relevant bits (7-6) will 
* be parsed and moved to the appropriate registers.
*
* Registers used: A6,D0,D1,D5
*
* Precondition: OP code has been identified with 2 size bit field for EA, current
* instruction set for OP code is stored in to A6.
*
* Postcondition: 2 bit size field has been isolated and stored into D5.
**********************************************************************************
FIND_2_BIT_SIZE_TO_EA:      ;Move the 2 bit size field relevant register
   ; MOVEM.L  D0-D5/A6,-(SP) ;Save all changed registers
    MOVE.W   CUR_OP_CODE,D0        ;Move current OP code into D0
    MOVE.W   #8,D1          ;Prepare 8 bit shift to D1
    LSL.W    D1,D0          ;Truncate to find the 2 size bits
    LSR.W    D1,D0          ;Reposition the bits
    MOVE.W   #6,D1          ;Prepare 6 bit shift to D1
    LSR.W    D1,D0          ;Truncate to shift 2 bits to a byte
    MOVE.W   D0,D4          ;Move 2 size bits into D5
  ;  MOVEM.L (SP)+,D0-D5/A6  ;Restore registers
    RTS                     ;Return to stack
**********************************************************************************

* FIND_3_BIT_REG_TO_EA
**********************************************************************************
* Description: OP codes with a dynamic 3 bit register in bits 11-9 will be parsed
* and have those 3 bits isolated and moved to the appropriate registers.
*
* Registers used: A6,D0,D1,D5
*
* Precondition: OP code has been identified with a dynamic 3 bit register in bits
* 11-9.
*
* Postcondition: 3 bit dynamic register has been isolated and stored into D4.
**********************************************************************************
FIND_3_BIT_REG_TO_EA:       ;Move the 3 bit dynamic register bits to proper register
   ; MOVEM.L  D0-D5/A6,-(SP) ;Save all changed registers
    MOVE.W   CUR_OP_CODE,D0        ;Move current OP code into D0
    MOVE.W   #4,D1          ;Prepare 4 bit shift to D1
    LSL.W    D1,D0          ;Truncate to find the 2 size bits
    LSR.W    D1,D0          ;Reposition the bits
    MOVE.W   #9,D1          ;Prepare 9 bit shift to D1
    LSR.W    D1,D0          ;Truncate to shift 3 bits to a byte
    MOVE.W   D0,D5          ;Move 3 register bits into D4
   ; MOVEM.L (SP)+,D0-D5/A6  ;Restore registers
    RTS                     ;Return to stack
**********************************************************************************

* MOVE_AND_MOVEA_PARSE_EA
**********************************************************************************
* Description: Special parsing for the SRC and DST Mode/Reg for MOVE/MOVE
*
* Registers used: A6,D0,D1,D7,D6,D5,D4
*
* Precondition: OP code has been identified with either MOVE or MOVEA
*
* Postcondition: Store all relevant EA bits into associated register.
**********************************************************************************
MOVE_AND_MOVEA_PARSE_EA:       ;Move the 3 bit dynamic register bits to proper register
   ; MOVEM.L D0-D7/A6, -(SP)  ;Save all changed registers
    MOVE.W CUR_OP_CODE,D0           ;Move current OP code into D0
    MOVE.W  #10,D1           ;Prepare 10 bit shift to D1
    LSL.W   D1,D0            ;Truncate to find the last 6 bits
    LSR.W   D1,D0            ;Shift back to get the proper 6 bits
    MOVE.W  D0,D7            ;Move last 6 bits into D7, SRC REG MODE
    MOVE.W  #3,D1            ;Prepare 3 bit shift into D1
    LSR.W   D1,D7            ;Shift 3 bits off D7 to obtain EA Mode
    MOVE.W  D7,D5            ;Move the 'upper' 3 bits into D6
    MOVE.W  #13,D1           ;Prepare 13 bit shift into D1
    LSL.W   D1,D0            ;Shift D0 left 13 bits to reposition current 3 bits
    LSR.W   D1,D0            ;Shift D0 right 13 bits to reposition current 3 bits
    MOVE.W  D0,D4            ;Move the 'lower' 3 bits into D7
    **************MOVING SOURCE*********** TO BE DONE LATER
    ; MOVE.W #%0011 011 001 001 101,(A6)              ;MOVEA.W A5,A3
    ; MOVE.W #%0010 011 001 001 101,D0                ;MOVEA.L A5,A3
     ;Expected values:
    ;D7, DST REG:   011
    ;D6, DST MODE:  001
    ;D5, SRC MODE:  001
    ;D4, SRC REG:   101
    ;00011001
    MOVE.W CUR_OP_CODE,D0     ;Move current OP code into D0     
    MOVE.W  #4,D1             ;Prepare 4 bit shift to D1
    LSL.W   D1,D0             ;Truncate to find bits 11-6
    LSR.W   D1,D0             ;Reposition bits
    MOVE.W  #6,D1             ;Prepare 6 bit shift to D1
    LSR.W   D1,D0             ;Truncate the SRC Reg/Mode bits
    MOVE.W  #3,D1             ;Prepare a 3 bit shift to D1 for DST Reg/Mode
    MOVE.W  D0,D6             ;Copy over the current 6 bits to D6
    LSR.W   D1,D0             ;Truncate DST Mode  
    MOVE.W  D0,D7             ;Move DST Reg to D7
    MOVE.W  #13,D1             
    LSL.W   D1,D6             ;Truncate 13 bits in D6
    LSR.W   D1,D6             ;Reposition D6
                              ;D6 now contains the DST Reg
   ; MOVEM.L (SP)+,D0-D7/A6   ;Restore registers
    RTS                     ;Return to stack
**********************************************************************************

*FIND_TRAILING_BITS_TO_EA
**********************************************************************************
FIND_TRAILING_BITS_TO_EA:       ;Move the 3 bit dynamic register bits to proper register
   ; MOVEM.L  D0-D5/A6,-(SP) ;Save all changed registers
    MOVE.W   CUR_OP_CODE,D0        ;Move current OP code into D0
    MOVE.W   #7,D1          ;Prepare 4 bit shift to D1
    LSL.W    D1,D0          ;Truncate to find the 2 size bits
    LSR.W    D1,D0          ;Reposition the bits
    MOVE.W   #6,D1          ;Prepare 9 bit shift to D1
    LSR.W    D1,D0          ;Truncate to shift 3 bits to a byte
    MOVE.W   D0,(A3)          ;Move 3 register bits into D4
   ; MOVEM.L (SP)+,D0-D5/A6  ;Restore registers
    RTS                    ;Return to stack
**********************************************************************************

*PARSE_EA_CONSTANT_BITS
**********************************************************************************
* Definition: Uses CUR_OP_CODE to shift the proper bits into the global constants
* used for EA (MNEMONIC,FIRST_3,SECOND_3,THIRD_3,FOURTH_3. Where MNEMONIC refers
* to the first 4 bits of CUR_OP_CODE (15-12), FIRST_3 refers to the first group
* of 3 bits (11-9), SECOND_3 refers to the second group of 3 bits (8-6), THIRD_3
* refers to the third group of 3 bits (5-3), and FOURTH_3 refers to the fourth
* group of 3 bits (2-0). Shifts CUR_OP_CODE bits to initialize constants.
*
* Registers used: D0,D1
*
* Precondition: CUR_OP_CODE has been set with an 4 hex instruction set
* 
* Postcondition: MNEMONIC, FIRST_3, SECOND_3, THIRD_3, FOURTH_3 have been set
* to the corresponding values.
**********************************************************************************
PARSE_EA_CONSTANT_BITS:
    *MNEMONIC SHIFT
    MOVE.W CUR_OP_CODE,D0       ;Load in current instruction set into D0
    MOVE.W #12,D1               ;Prepare a bit shift of 12 into D1
    LSR.W D1,D0                 ;Shift 12 bits from D0 right
    MOVE.B D0,MNEMONIC          ;Set MNEMONIC to D0
    *FIRST_3 SHIFT
    MOVE.W #9,D1                ;Prepare a bit shift of 9 into D1
    MOVE.W CUR_OP_CODE,D0       ;Load in current instruction set into D
    LSL.W #4,D0                 ;Shift out bits 15-12 in D0
    LSR.W #4,D0                 ;Reposition D0
    LSR.W  D1,D0                ;Shift D0 9 bits right
    MOVE.B D0,FIRST_3           ;Set FIRST_3 to D0
    *SECOND_3 SHIFT
    MOVE.W CUR_OP_CODE,D0       ;Load in current instruction set into D
    LSL.W #7,D0                 ;Shift out bits 15-9 in D0
    LSR.W #7,D0                 ;Reposition D0
    LSR.W #6,D0                 ;Shift D0 6 bits right
    MOVE.B D0,SECOND_3          ;Set SECOND_3 to D0
    *THIRD_3 SHIFT
    MOVE.W CUR_OP_CODE,D0       ;Load in current instruction set into D
    LSR.W #3,D0                 ;Shift D0 3 bits right
    MOVE.W #13,D1               ;Prepare a 13 bit shift into D1
    LSL.W D1,D0                 ;Truncate first 13 bits of D0
    LSR.W D1,D0                 ;Reposition D0
    MOVE.B D0,THIRD_3           ;Set THIRD_3 to D0
    *FOURTH_3 SHIFT
    MOVE.W CUR_OP_CODE,D0       ;Load in current instruction set into D
    LSL.W D1,D0                 ;Grab the fourth 3-bit group
    LSR.W D1,D0                 ;Shift D0 back into position
    MOVE.B D0,FOURTH_3          ;Set FOURTH_3 to Do
    RTS                         ;Return to stack
**********************************************************************************
********** End of EA Parsing *****************************************************

*******************JMP LABELS ****************************************************
* Labelling for group codes will be in the following format

* <JMP Labelname>
********************************************************************************
* Checking List Order (If more than one value)
* Operand1 - $<nibble value>, a-b <specifier>, c-d <specifier> ...
* Operand2 - $<nibble value>, a-b <specifier>, c-d <specifier> ...

* Where a-b will refer to the bit corresponding bit value in the instruction
* format, and a specifier will be attached such as Size, EA Mode, SRC Reg, etc
* to clarify what a specific bit range means.
* Checking order refers to what order the checks will be performed in. 
* Any other code outside of the listed ones will be INVALID_OP.
********************************************************************************

********************************************************************************
* Global Field Descriptions
* Size Field: Byte = 00 Word = 01 Long = 10
* EA Mode: Refer to EA Address Modes
* EA Reg: 3-bit input that is mapped to the respective binary value
********************************************************************************

* GROUP_0                      
********************************************************************************
* Description: Checks for the following listed OP codes to be present or not
*
* ORI: $00, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
* CMPI: $0C, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
* Dynamic BCLR: $0, 11-9 Register, 8-6 %110, 5-3 EA Mode, 2-0 EA Reg
* Static BCLR: $01, 7-6 10, 5-3 EA Mode, 2-0 EA Reg
*
* Registers used: D0
*
* Precondition: First nibble has been identified as $0
*
* Postcondition: Parses proper OP code with a nibble value of $0 or finds an
* invalid OP code. After a successful parse loading for EA values will be done
* through a subroutine.
********************************************************************************
C_GROUP_0:
    MOVEM.L D0-D1, -(SP)        ;Backup registers
    
CHECK_OP_ORI:
    MOVE.W  CUR_OP_CODE,D0      ;Move current instruction set into D
    ANDI.W  #$FF00,D0           ;Mask relevant bits to D0
    CMP.W   #$0000,D0           ;Compare the appropriate masked bits     
    BNE     CHECK_OP_CMPI       ;Branch to next comparison if not equal
    JSR     PRINT_OP_ORI        ;Print the OP code if equal    
    BRA     CG0_C               ;Finish routine
CHECK_OP_CMPI:
    MOVE.W  CUR_OP_CODE,D0      ;Move current instruction set into D
    ANDI.W  #$FF00,D0           ;Mask relevant bits to D0
    CMP.W   #$0C00,D0           ;Compare the appropriate masked bits   
    BNE     CHECK_OP_S_BCLR     ;Branch to next comparison if not equal       
    JSR     PRINT_OP_CMPI       ;Print the OP code if equal
    BRA     CG0_C               ;Finish routine
CHECK_OP_S_BCLR:
    MOVE.W  CUR_OP_CODE,D0      ;Move current instruction set into D
    ANDI.W  #$FF00,D0           ;Mask relevant bits to D0
    CMP.W   #$0800,D0           ;Compare the appropriate masked bits
    BNE     CHECK_OP_D_BCLR     ;Branch to next comparison if not equal
    JSR     PRINT_OP_S_BCLR     ;Print the OP code if equal
    ;MOVEM.L (SP)+,D6-D7        ;POP STACK
    BRA     CG0_C               ;Finish routine
CHECK_OP_D_BCLR:
    MOVE.W  CUR_OP_CODE,D0        ;Move current instruction set into D
    ANDI.W  #%0000000110000000,D0 ;Do a direct binary bitmask to see which bits are needed
    CMP.W   #%0000000110000000,D0 ;Compare the expected binary value
    BNE     CG0_F                 ;If not equal this must be an invalid OP code
    JSR     PRINT_OP_D_BCLR       ;Print the OP code if equal
    BRA     CG0_C                 ;Finish routine
CG0_F:                            ;Checks have been finished, invalid OP code has been found
    BRA INVALID_OP    
CG0_C:                            ;Checks have been finished,a valid OP code has been found
    RTS                           ;Return to stack
    
* GROUP_1                      
********************************************************************************
* MOVE.B: $1, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
********************************************************************************
C_GROUP_1:

CHECK_OP_MOVE_B:
    MOVE.W  CUR_OP_CODE,D0          ;Move current instruction set into D0          
    ANDI.W  #$FF00,D0               ;Mask relevant bits to D0
    CMP.W #$1000,D0                 ;Compare the appropriate masked bits 
    BNE INVALID_OP                  ;Invalid OP code has been found
    BEQ PRINT_OP_MOVEB              ;Print the OP code if equal
    RTS                             ;Return to stack
* GROUP_2
********************************************************************************
* MOVEA.L: $2, 11-9 DST Reg, 8-6 %001, 5-3 SRC Mode, 2-0 SRC Reg
* MOVE.L: $2, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
********************************************************************************
C_GROUP_2:

CHECK_OP_MOVEA_L:
    MOVE.W CUR_OP_CODE,D0                  ;Move current instruction set into D0  
    ANDI.W #$FF00,D0                ;Mask relevant bits to D0
    CMP.W #$2000,D0                 ;Compare the appropriate masked bits
    BRA FIND_MOVEA_L_DIFFERENCE     ;Branch always to check 

    
FIND_MOVEA_L_DIFFERENCE:    ;Finds difference between MOVEA and MOVE
    MOVE.W   CUR_OP_CODE,D0        ;Move current OP code into D0
    MOVE.W   #7,D1          ;Prepare 7 bit shift to D1
    LSL.W    D1,D0          ;Truncate to find the 3 address mode bits
    LSR.W    D1,D0          ;Reposition the bits
    MOVE.W   #6,D1          ;Prepare 6 bit shift to D1
    LSR.W    D1,D0          ;Truncate to shift 3 bits to a register
    MOVE.W   D0,D6          ;Move 3 address mode bits into D6
    CMP.W   #$1,D6          ;Check if the address mode value is MOVEA
    BNE     CHECK_OP_MOVE_L  ;Branch if not equal to check MOVE
    BEQ     PRINT_OP_MOVEA_L ;Print out the MOVEA address 
    
CHECK_OP_MOVE_L:
    MOVE.W CUR_OP_CODE,D0       ;Move current instruction set into D0
    ANDI.W #$FF00,D0
    CMP.W #$2000,D0
    BNE INVALID_OP
    BEQ PRINT_OP_MOVE_L
    RTS
    
* GROUP_3
********************************************************************************
* MOVEA.W: $3, 11-9 DST Reg, 8-6 %001, 5-3 SRC Mode, 2-0 SRC Reg
* MOVE.W: $3, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
********************************************************************************
C_GROUP_3:

CHECK_OP_MOVEA_W:
    MOVE.W CUR_OP_CODE,D0       ;Move current instruction set into D0
    ANDI.W #$FF00,D0
    CMP.W #$3000,D0
    BRA FIND_MOVEA_W_DIFFERENCE

    
FIND_MOVEA_W_DIFFERENCE:      ;Finds difference between MOVEA and MOVE
    MOVE.W   CUR_OP_CODE,D0        ;Move current instruction set into D0
    MOVE.W   #7,D1          ;Prepare 7 bit shift to D1
    LSL.W    D1,D0          ;Truncate to find the 3 address mode bits
    LSR.W    D1,D0          ;Reposition the bits
    MOVE.W   #6,D1          ;Prepare 6 bit shift to D1
    LSR.W    D1,D0          ;Truncate to shift 3 bits to a register
    MOVE.W   D0,D6          ;Move 3 address mode bits into D6
    CMP.W   #$1,D6          ;Check if the address mode value is MOVEA
    BNE     CHECK_OP_MOVE_W 
    BEQ     PRINT_OP_MOVEA_W  
    
CHECK_OP_MOVE_W:
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FF00,D0
    CMP.W #$3000,D0
    BNE INVALID_OP
    BEQ PRINT_OP_MOVE_W
    RTS

* GROUP_4
********************************************************************************
* LEA: $4, 11-9 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
* JSR: $4E, 7-6 %10, 5-3 EA Mode, 2-0 EA Reg 
* RTS: $4E75
* NEG: $44, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
* MOVEM: $4, 11 %1, 10 %D, 9-7 %001, 6 S, 5-3 EA Mode, 2-0 EA Reg
* %D = 0 , Register to Memory, 1 Memory to Register
********************************************************************************
C_GROUP_4:
CHECK_OP_RTS:
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    CMP.W  #$4E75,D0
    BNE    CHECK_OP_NOP
    BEQ    PRINT_OP_RTS
    
CHECK_OP_NOP:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    CMP.W  #$4E71,D0
    BNE    CHECK_OP_LEA
    BEQ    PRINT_OP_NOP
    
CHECK_OP_LEA:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$F1C0,D0
    CMP.W  #$41C0,D0
    BNE    CHECK_OP_JSR
    BEQ    PRINT_OP_LEA
    
CHECK_OP_JSR:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$FFC0,D0
    CMP.W  #$4E80,D0
    BNE    CHECK_OP_NEG
    BEQ    PRINT_OP_JSR
    
CHECK_OP_NEG:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$FF00,D0
    CMP.W  #$4400,D0
    BNE    CHECK_OP_MOVEM
    BEQ    PRINT_OP_NEG
**************** COME BACK TO FINISH UP SIZE **********************************
CHECK_OP_MOVEM:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$FB80,D0
    CMP.W  #$4880,D0
    BNE    INVALID_OP
    BEQ    PRINT_OP_MOVEM_W
    
* GROUP_5
********************************************************************************
* SUBQ: $5, 11-9 DATA, 8 %1, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
* Validation checking:
* Check against, ADDQ, Scc, DBcc
********************************************************************************
C_GROUP_5:

VALID_CHECK_OP_SUBQ:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$F1C0,D0        ;Bitmask check for Scc, DBcc and ADDQ
    CMP.W  #$51C0,D0        ;This should be the only valid one for SUBQ
    BEQ    INVALID_OP       ;If not equal it's invalid
    BNE    CHECK_OP_SUBQ
CHECK_OP_SUBQ     
    MOVE.W  CUR_OP_CODE,D0  ;Actual check for SUBQ
    ANDI.W #$F100,D0        ;Bitmask check for SUBQ
    CMP.W  #$5100,D0        ;Compare the proper value
    BEQ    PRINT_OP_SUBQ    ;If equal print it out
    BNE    INVALID_OP       ;Else the operand is invalid
    
* GROUP_6
********************************************************************************
* BRA: $60, 7-0 8-Bit Displacement
* Bcc: $6, 11-8 Condition, 7-0 8-Bit Displacement
*   Branch: <Condition>   
*   BCS: %0101  		
*   BGE: %1100		
*   BLT: %1101	
*   BVC: %1000
*   
*   MOVE.W #%0110010100000000   ;BCS
*   MOVE.W #%0110110001010101   ;BGE
*   MVE.W #%0110110110101010    ;BLT
*   MOVE.W #%0110100001010101   ;BVC
********************************************************************************
C_GROUP_6:

CHECK_OP_BRA:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0       
    ANDI.W #$FF00,D0
    CMP.W  #$6000,D0
    BEQ     PRINT_OP_BRA
    BNE     CHECK_OP_BCS

CHECK_OP_BCS:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$FF00,D0
    CMP.W  #$6500,D0 
    BEQ    PRINT_OP_BCS
    BNE    CHECK_OP_BGE
    
CHECK_OP_BGE:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$FF00,D0
    CMP.W  #$6C00,D0 
    BEQ    PRINT_OP_BGE
    BNE    CHECK_OP_BLT
    
CHECK_OP_BLT:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$FF00,D0
    CMP.W  #$6D00,D0 
    BEQ    PRINT_OP_BLT
    BNE    CHECK_OP_BVC
    
CHECK_OP_BVC:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$FF00,D0
    CMP.W  #$6800,D0 
    BEQ    PRINT_OP_BVC
    BNE    INVALID_OP
    
    
*GROUP_7
********************************************************************************
* Currently no OP codes here are supported.
********************************************************************************
C_GROUP_7:
    JMP INVALID_OP

* GROUP_8
********************************************************************************
* Supported:
* DIVS: $8, 11-9 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
* OR: $80, 7-6 Size, 5-3 EA Mode, 2-0 EA Register
* Unsupported: DIVU, SBCD
********************************************************************************
C_GROUP_8:

CHECK_OP_DIVS:
    MOVE CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$F1C0,D0
    CMP.W #$81C0,D0
    BEQ PRINT_OP_DIVS
    BNE CHECK_OP_OR
    
CHECK_OP_DIVU:
    MOVE CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$F1C0,D0
    CMP.W #$80C0,D0
    BEQ INVALID_OP
    BNE CHECK_OP_SBCD
    
CHECK_OP_SBCD:
    MOVE CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$F100,D0
    CMP.W #$8100,D0
    BEQ INVALID_OP
    BNE CHECK_OP_OR
    
CHECK_OP_OR:              ;At this point only remaining $8 code is OR
    JMP PRINT_OP_OR
* GROUP_9                      
********************************************************************************
* Supported
* SUB: $9, 11-9 Reg, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* Unsupported: SUBX, SUBA
********************************************************************************
C_GROUP_9:

CHECK_OP_SUBA:             ;Check SUBA first as it has static bits
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F0C0,D0
    CMP.W #$90C0,D0
    BEQ INVALID_OP
    BNE CHECK_OP_SUBX

CHECK_OP_SUBX:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F130,D0
    CMP.W #$9100,D0
    BEQ INVALID_OP
    BNE CHECK_OP_SUB

CHECK_OP_SUB:           ;At this point only remaining $9 is SUB
    JMP PRINT_OP_SUB

*GROUP_A
********************************************************************************
* Currently no OP codes here are supported. There are no current OP codes here.
********************************************************************************
C_GROUP_A:
    JMP INVALID_OP

* GROUP_B                     
********************************************************************************
* Supported:
* EOR: $B, 11-9 Reg, 8 %1, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* CMP: $B, 11-9 Reg, 8 %0, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* The specific bit difference is listed 
* Unsupported: CMPM, CMPA
********************************************************************************
C_GROUP_B:

CHECK_OP_CMPM
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F138,D0
    CMP.W  #$B108,D0
    BEQ INVALID_OP
    BNE CHECK_OP_CMPA
    
CHECK_OP_CMPA:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F0C0,D0
    CMP.W  #$B0C0,D0
    BEQ INVALID_OP
    BNE CHECK_OP_EOR
    
CHECK_OP_EOR:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F100,D0
    CMP.W #$B100,D0
    BEQ PRINT_OP_EOR
    BNE CHECK_OP_CMP
    
CHECK_OP_CMP:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F100,D0
    CMP.W #$B000,D0
    BEQ PRINT_OP_CMP
    BNE INVALID_OP
    
* GROUP_C                     
********************************************************************************
* Supported:
* MULS: $C, 11-8 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
* Unsupported: MULU, ABCD, EXG, AND
* Note: EXG OP mode has to be 01000, 01001, 10001, as such can never be 11 for
* bits 7-6
********************************************************************************
C_GROUP_C:

CHECK_OP_MULS:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F1C0,D0
    CMP.W #$C1C0,D0
    BEQ PRINT_OP_MULS
    BNE INVALID_OP          ; This can only be the supported operand

* GROUP_D                     
********************************************************************************
* Supported:
* ADD: $D, 11-9 Reg, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* ADDA: $D, 11- 9 Reg, 8-6 OPMODE, 7-6 %11, 5-3 EA Mode, 2-0 EA Reg
* The specific bit difference is listed out in the OPMODE field.
* Unsupported: ADDX
********************************************************************************
C_GROUP_D:

CHECK_OP_ADDX:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F130,D0
    CMP.W #$D100,D0
    BEQ   INVALID_OP
    BNE CHECK_OP_ADDA

CHECK_OP_ADDA:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F0C0,D0
    CMP.W #$D0C0,D0
    BEQ   PRINT_OP_ADDA
    BNE   CHECK_OP_ADD

CHECK_OP_ADD:
    JMP PRINT_OP_ADD        ;Only remaining OP in $D is ADD
* GROUP_E                     
********************************************************************************
* Supported:
* LSR: $E, 11-9 Count/Reg, 8 %0, 7-6 Size, 5 i/r, 4-3 %01, 2-0 Reg
* LSL: $E, 11-9 Count/Reg, 8 %1, 7-6 Size, 5 i/r, 4-3 %01, 2-0 Reg
* ASR: $E, $0, 8 %0, 7-6 %11, 5-3 EA Mode, 2-0 EA reg
* ASL: $E, $0, 8 %1, 7-6 %11, 5-3 EA Mode, 2-0 EA reg
* ROR: $E, 11-9 Count/Reg, 8 %0, 7-6 Size, 5 i/r, 4-3 %11, 2-0 Reg
* ROL: $E, 11-9 Count/Reg, 8 %1, 7-6 Size, 5 i/r, 4-3 %11, 2-0 Reg
* Count/Reg for LSR/LSL refers to shift count, where 0 = shift count of 8, 1-7 
* refers to the respective value when i/r = 0. If i/r = 1, data register in the 
* Count/Reg field specifies the shift count.  
* For directional bit at 8, R = 0, L = 1
* Count/Reg for ROR/ROL specifies rotate count instead of shift count.
*
* Unsupported: ROXL, ROXR
********************************************************************************
C_GROUP_E:

CHECK_OP_ROXR_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F4C0,D0
    CMP.W #$E4C0,D0
    BEQ   INVALID_OP
    BNE   CHECK_OP_ROXL_NO_ROT

CHECK_OP_ROXL_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F5C0,D0
    CMP.W #$E5C0,D0
    BEQ   INVALID_OP
    BNE   CHECK_OP_LSR_NO_ROT

CHECK_OP_ROR_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F7C0,D0
    CMP.W #$E6C0,D0
    BEQ   PRINT_OP_ROR
    BNE   CHECK_OP_ROL_NO_ROT
    
CHECK_OP_ROL_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F7C0,D0
    CMP.W #$E7C0,D0
    BEQ   PRINT_OP_ROL
    BNE   CHECK_OP_LSR_NO_ROT
 
CHECK_OP_LSR_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F2C0,D0
    CMP.W #$E2C0,D0
    BEQ   PRINT_OP_LSR
    BNE   CHECK_OP_LSL_NO_ROT

CHECK_OP_LSL_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F3C0,D0
    CMP.W #$E3C0,D0
    BEQ   PRINT_OP_LSL
    BNE   CHECK_OP_ASL_NO_ROT

CHECK_OP_ASR_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F1C0,D0
    CMP.W #$E0C0,D0
    BEQ   PRINT_OP_ASR
    BNE   CHECK_OP_ASL_NO_ROT

CHECK_OP_ASL_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F1C0,D0
    CMP.W #$01C0,D0
    BEQ   PRINT_OP_ASL
    BNE   CHECK_OP_ROR_NO_ROT

CHECK_OP_ROXR:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E010,D0
    BEQ    INVALID_OP
    BNE    CHECK_OP_ROXL
    
CHECK_OP_ROXL:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E110,D0
    BEQ    INVALID_OP
    BNE    CHECK_OP_ROR

CHECK_OP_ROR:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E018,D0
    BEQ    PRINT_OP_ROR
    BNE    CHECK_OP_ROL

CHECK_OP_ROL:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E118,D0
    BEQ    PRINT_OP_ROL
    BNE    CHECK_OP_LSR
    
CHECK_OP_LSR:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E008,D0
    BEQ    PRINT_OP_LSR
    BNE    CHECK_OP_LSL

CHECK_OP_LSL:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E108,D0
    BEQ    PRINT_OP_LSL
    BNE    CHECK_OP_ASR

CHECK_OP_ASR:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E000,D0
    BEQ    PRINT_OP_ASR
    BNE    CHECK_OP_ASL

CHECK_OP_ASL:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E100,D0
    BEQ    PRINT_OP_ASL
    BNE    INVALID_OP      ;Last possible OP code


* GROUP_F
********************************************************************************
* Currently no OP codes here are supported. There are no OP codes here
********************************************************************************
C_GROUP_F:
    JMP INVALID_OP
    
* INVALID_OP                     
********************************************************************************
* Any value that is not covered in the above groups would be considered invalid. 
* The following values in the first nibble would also indicate that the 
* operand codes is already invalid: $7, $A, $F.
* For unsupported OP codes, display DATA $WXYZ   
* THIS WILL NEED TO BE CHANGED TO DISPLAY: 1000 DATA $WXYZ IN THE FUTURE
********************************************************************************
INVALID_OP:  ; Prints DATA for invalid op
    LEA P_INVALID_OP,A1
    MOVE.B #13,D0
    TRAP #15
    SIMHALT
READ_NEXT_INSTRUCTION: ; Needs to read next instruction set {PLACEHOLDER}
    SIMHALT

MAKE_VAL_ASCII:
    CMPI.B  #$9,D0
    BGT     LETTER_ASCII
    BLE     NUMBER_ASCII
    RTS
    
LETTER_ASCII:
    ADDI.B #$37,D0 ; A-F
    RTS
    
NUMBER_ASCII
    ADDI.B #$30,D0 ; 0-9
    RTS
    
ADD_PERIOD:
    MOVE.L D0,-(SP)
    MOVE.B #$0,D0
    ADDI.B #$46,D0
    MOVE.L (SP)+,D0
********************** PRINTING ROUTINES **************************************
* Description: These routines are to print the associated op codes, by placing
* them in the appropriate area to the buffer
*
* Registers used: A1 for loading, A6 for EA parsing.
*
* Precondition: The relevant opcode has been identified correctly.
*
* Postcondition: Prints out the associated opcode to the buffer.

* THIS NEEDS TO BE RETOOLED TO PRINT TO BUFFER NOT TO CONSOLE
*******************************************************************************

****************************** GROUP 0 **************************************** 
PRINT_OP_ORI:
    LEA P_OP_ORI,A1
    JSR PRINT_OP
    RTS
PRINT_OP_CMPI:
    LEA P_OP_CMPI,A1
    JSR PRINT_OP
    RTS
PRINT_OP_S_BCLR:
    LEA P_OP_S_BCLR,A1
    JSR PRINT_OP
    RTS
PRINT_OP_D_BCLR:
    LEA P_OP_D_BCLR,A1
    JSR PRINT_OP
    RTS
******************************* END OF GROUP 0 ********************************

****************************** GROUP 1 ****************************************    
PRINT_OP_MOVEB:
    LEA P_OP_MOVEB,A1
    JSR PRINT_OP
    RTS
******************************* END OF GROUP 1 ********************************
    
****************************** GROUP 2 **************************************** 
PRINT_OP_MOVEA_L:
    LEA P_OP_MOVEA_L,A1
    JSR PRINT_OP
    RTS
PRINT_OP_MOVE_L:
    LEA P_OP_MOVE_L,A1
    JSR PRINT_OP
    RTS
******************************* END OF GROUP 2 ********************************
    
****************************** GROUP 3 ****************************************    
PRINT_OP_MOVEA_W:
    LEA P_OP_MOVEA_W,A1
    JSR PRINT_OP
    RTS
PRINT_OP_MOVE_W:
    LEA P_OP_MOVE_W,A1
    JSR PRINT_OP
    RTS
******************************* END OF GROUP 3 ********************************

****************************** GROUP 4 ****************************************
PRINT_OP_NOP:
    LEA P_OP_NOP,A1
    JSR PRINT_OP
    RTS
PRINT_OP_JSR:
    LEA P_OP_JSR,A1
    JSR PRINT_OP
    RTS
PRINT_OP_RTS:
    LEA P_OP_RTS,A1
    JSR PRINT_OP
    RTS
PRINT_OP_LEA:
    LEA P_OP_LEA,A1
    JSR PRINT_OP
    RTS
PRINT_OP_NEG:
    LEA P_OP_NEG,A1
    JSR PRINT_OP
    RTS
PRINT_OP_MOVEM_W:
    LEA P_OP_MOVEM_W,A1
    JSR PRINT_OP
    RTS
PRINT_OP_MOVEM_L:
    LEA P_OP_MOVEM_L,A1
    JSR PRINT_OP
    RTS
******************************* END OF GROUP 4 ********************************
    
****************************** GROUP 5 ****************************************
PRINT_OP_SUBQ:
    LEA P_OP_SUBQ,A1
    JSR PRINT_OP
    RTS
******************************* END OF GROUP 5 ********************************

****************************** GROUP 6 ****************************************
PRINT_OP_BCS:
    LEA P_OP_BCS,A1
    JSR PRINT_OP
    RTS
PRINT_OP_BGE:
    LEA P_OP_BGE,A1
    JSR PRINT_OP
    RTS
PRINT_OP_BLT:
    LEA P_OP_BLT,A1
    JSR PRINT_OP
    RTS
PRINT_OP_BVC:
    LEA P_OP_BVC,A1
    JSR PRINT_OP
    RTS
PRINT_OP_BRA:
    LEA P_OP_BRA,A1
    JSR PRINT_OP
    RTS
******************************* END OF GROUP 6 ********************************

****************************** GROUP 7 ****************************************
* No currently supported OP codes to print here.
******************************* END OF GROUP 7 ********************************

****************************** GROUP 8 ****************************************
PRINT_OP_DIVS:
    LEA P_OP_DIVS,A1
    JSR PRINT_OP
    RTS
PRINT_OP_OR:
    LEA P_OP_OR,A1
    JSR PRINT_OP
    RTS
******************************* END OF GROUP 8 ********************************

****************************** GROUP 9 ****************************************
PRINT_OP_SUB:
    LEA P_OP_SUB,A1
    JSR PRINT_OP
    RTS
******************************* END OF GROUP 9 ********************************

****************************** GROUP A ****************************************
* No currently supported OP codes to print here.
******************************* END OF GROUP A ********************************

****************************** GROUP B ****************************************
PRINT_OP_EOR:
    LEA P_OP_EOR,A1
    JSR PRINT_OP
    RTS
PRINT_OP_CMP:
    LEA P_OP_CMP,A1
    JSR PRINT_OP
    RTS
******************************* END OF GROUP B ********************************

****************************** GROUP C ****************************************
PRINT_OP_MULS:
    LEA P_OP_MULS,A1
    JSR PRINT_OP
    RTS
******************************* END OF GROUP C ********************************

****************************** GROUP D ****************************************
PRINT_OP_ADD:
    LEA P_OP_ADD,A1
    JSR PRINT_OP
    RTS
PRINT_OP_ADDA:
    LEA P_OP_ADDA,A1
    JSR PRINT_OP
    RTS

******************************* END OF GROUP D ********************************

****************************** GROUP E ****************************************
PRINT_OP_LSL:
    LEA P_OP_LSL,A1
    JSR PRINT_OP
    RTS
PRINT_OP_LSR:
    LEA P_OP_LSR,A1
    JSR PRINT_OP
    RTS
PRINT_OP_ASR:
    LEA P_OP_ASR,A1
    JSR PRINT_OP
    RTS
PRINT_OP_ASL:
    LEA P_OP_ASL,A1
    JSR PRINT_OP
    RTS
PRINT_OP_ROL:
    LEA P_OP_ROL,A1
    JSR PRINT_OP
    RTS
PRINT_OP_ROR:
    LEA P_OP_ROR,A1
    JSR PRINT_OP
    RTS
******************************* END OF GROUP E ********************************

****************************** GROUP F ****************************************
* No currently supported OP codes to print here.
******************************* END OF GROUP F ********************************



PRINT_OP:   ;Prints current op code byte
    ;MOVE.W (A4),(A1)       ; NEEDS TO USE G_BUFFER LATER
    MOVE.B #13,D0
    TRAP #15
    RTS
******************* END OF PRINTING ROUTINES **********************************

******************* END OF JMP LABELS *****************************************

******************* DATA CONSTANT PRINTS **************************************
* Formatting is as follows: P_OP_<OPCODE>, where P = Print, OP = Operation,
* <OPCODE> is any valid operand

P_INVALID_OP    DC.B    'DATA',0
OP_FOUND        DC.B    'Found OP',0 ; this should be taken out later
P_SIZE_B        DC.B    '.B',0
P_SIZE_W        DC.B    '.W',0
P_SIZE_L        DC.B    '.L',0
P_OP_ORI        DC.B    'ORI',0
P_OP_CMPI       DC.B    'CMPI',0
P_OP_S_BCLR     DC.B    'BCLR',0
P_OP_D_BCLR     DC.B    'BCLR',0
P_OP_MOVEB      DC.B    'MOVE.B',0
P_OP_MOVEA_L    DC.B    'MOVEA.L',0 
P_OP_MOVE_L     DC.B    'MOVE.L',0
P_OP_MOVEA_W    DC.B    'MOVEA.W',0
P_OP_MOVE_W     DC.B    'MOVE.W',0
P_OP_MOVEM_W    DC.B    'MOVEM.W',0
P_OP_MOVEM_L    DC.B    'MOVEM.L',0
P_OP_LEA        DC.B    'LEA',0
P_OP_JSR        DC.B    'JSR',0
P_OP_NOP        DC.B    'NOP',0
P_OP_RTS        DC.B    'RTS',0
P_OP_NEG        DC.B    'NEG',0
P_OP_SUBQ       DC.B    'SUBQ',0
P_OP_BRA        DC.B    'BRA',0
P_OP_BCS        DC.B    'BCS',0
P_OP_BGE        DC.B    'BGE',0
P_OP_BLT        DC.B    'BLT',0
P_OP_BVC        DC.B    'BVC',0
P_OP_DIVS       DC.B    'DIVS',0
P_OP_OR         DC.B    'OR',0
P_OP_SUB        DC.B    'SUB',0
P_OP_EOR        DC.B    'EOR',0
P_OP_CMP        DC.B    'CMP',0
P_OP_MULS       DC.B    'MULS',0
P_OP_ADDA       DC.B    'ADDA',0
P_OP_ADD        DC.B    'ADD',0
P_OP_LSR        DC.B    'LSR',0
P_OP_LSL        DC.B    'LSL',0
P_OP_ASR        DC.B    'ASR',0
P_OP_ASL        DC.B    'ASL',0
P_OP_ROR        DC.B    'ROR',0
P_OP_ROL        DC.B    'ROL',0
***************** END OF DATA CONSTANT PRINTS ***********************************
 

**
* AddStrToBuffer
**
* Adds the given NULL-terminated string to the specified buffer.
*
* Default buffer length is 80 characters, but can be modified in the argument
* variables.
*
* If the buffer length is exceeded, either due to lack of a NULL character or
* an incorrectly specified length, 1 is returned. Otherwise, 0 is returned to
* indicate success.
*
**
* @param Arg_AddStrToBuffer_String              Pointer to string
* @param Arg_AddStrToBuffer_Buffer              Pointer to buffer
* @param Arg_AddStrToBuffer_BufferLength        Length of buffer (default 80 chars)
* @return Ret_AddStrToBuffer_Success            0 if successful, 1 otherwise.
* @branch _AddStrToBuffer_FindBufferNullLoop    Loop to find NULL in buffer
* @branch _AddStrToBuffer_AddLoop               Loop to add string to buffer
* @branch _AddStrToBuffer_Success               Branch when string successfully added
* @branch _AddStrToBuffer_StringLengthExceeded  Branch when length exceeded (either string or buffer)
* @branch _AddStrToBuffer_End                   End of subroutine
**
Arg_AddStrToBuffer_String           DS.L    1
Arg_AddStrToBuffer_Buffer           DS.L    1
Arg_AddStrToBuffer_BufferLength     DC.L    80
Ret_AddStrToBuffer_Success          DS.B    1

AddStrToBuffer:                     DS.W    0
    MOVEM.L     D0-D1/A0-A1, -(SP)                  * Backup registers to stack

    MOVE.L      Arg_AddStrToBuffer_String, A0       * Load string pointer
    MOVE.L      Arg_AddStrToBuffer_Buffer, A1       * Load buffer pointer
    MOVE.L      Arg_AddStrToBuffer_BufferLength, D0 * Load buffer length
    CLR.W       Ret_AddStrToBuffer_Success          * Clear success bit
    CLR.L       D1                                  * Clear loop counter

_AddStrToBuffer_BufferLoop
    CMPI.B      #0, (A1)                            * If buffer char is NULL
    BEQ         _AddStrToBuffer_AddLoop             * Start adding string to bufer
    
    CMP.L       D0, D1                              * If counter >= max length
    BGE         _AddStrToBuffer_LengthExceeded      * Error, return
    
    ADDQ.L      #1, A1                              * Go to next character
    ADDQ.B      #1, D1                              * Increment counter
    BRA         _AddStrToBuffer_BufferLoop          * Loop back
    
_AddStrToBuffer_AddLoop
    CMPI.B      #0, (A0)                            * If string char is NULL
    BEQ         _AddStrToBuffer_Success             * String successfully added
    
    CMP.B       D0, D1                              * If counter >= max length
    BGE         _AddStrToBuffer_LengthExceeded      * Error, return
    
    MOVE.B      (A0)+, (A1)+                        * Move string char to buffer char
    ADDQ.B      #1, D1                              * Increment counter
    BRA         _AddStrToBuffer_AddLoop             * Loop back

_AddStrToBuffer_Success
    MOVE.B      #0, (A1)                            * Add NULL to end of string
    BRA         _AddStrToBuffer_End                 * Finish subroutine

_AddStrToBuffer_LengthExceeded
    MOVE.W      #1, Ret_AddStrToBuffer_Success      * Invalidate success bit

_AddStrToBuffer_End
    MOVEM.L     (SP)+, D0-D1/A0-A1                  * Restore registers from stack
    RTS                  
   
    END START













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
