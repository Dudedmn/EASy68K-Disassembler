*-----------------------------------------------------------
* Title      : OP Code routines for Disassembler
* Written by : Daniel Yan
* Date       : 2/28/2019, Updated 3/9/2019

* Description: Op code determining to identify values

  ORG $2000
CUR_OP_CODE DS.W 1  ; Current OP Code Word
  ORG $2100 
G_BUFFER    DS.B 100
    LEA G_BUFFER,A4
  ORG $1000 ; Start at Address $1000
    
START ; Start the op code routine
    
***************************** Inputs **********************************************
    ;MOVE.W #%0000100010000010,CUR_OP_CODE       ;Static BCLR
    ;MOVE.W #%0000111110001110,CUR_OP_CODE       ;Dynamic BCLR
    ;MOVE.W #%0000000001000001,CUR_OP_CODE       ;ORI.W D1
    
    ;MOVE.W #%0000111110001110,D0              ;Dynamic BCLR
    ;IN HEX $018E. D7 = 110, D6 = 001, D4 = %110, D5 = 7, (A6) = %0000
    
    ;MOVE.W  #$018E,D0                        ;Dynamic BCLR in hex
    ;MOVE.W  #$02FF,(A6)                         ;INVALID_OP code
    ;MOVE.W #%0000110001010111,(A6)
    MOVE.W #%0010011001001101,D0                       ;MOVEA                        
    ;MOVE.W #%0010001001001101,CUR_OP_CODE              ;MOVEA.L A5,A1
    ;MOVE.W CUR_OP_CODE,(A6)
    ;MOVE.W #$224D
    ;Expected values:
    ;D7, DST REG:   011
    ;D6, DST MODE:  001
    ;D5, SRC REG:   101
    ;D4, SRC MODE:  001
    ;CHECK IF DST MODE IS %111 or SRC MODE IS %111 for MOVE
    ;(A3), DST TRAIL:  001
    ;(A2), SRC TRAIL: ONLY FOR MOVE
    ;MOVE.W #%0010000000001101,(A6)              ;MOVE.L A5,A1
    ;MOVE.W #%0011011001001101,(A6)              ;MOVEA.W A5,A1
    ;MOVE.W #%0011000000001101,(A6)              ;MOVE.W A5,A1
    ;MOVE.W #%0000000001000001,(A6)              ;ORI.W D1
    ;MOVE.W CUR_OP_CODE,A6                       ;Loading memory space to address register
    ;MOVE.W CUR_OP_CODE,(A6)                     ;Loading memory value to address value
************************************************************************************
LOAD_OP_CODE:
    MOVE.W D0,CUR_OP_CODE
    MOVE.W CUR_OP_CODE,(A6)
    MOVE.W (A6),D0          ;Load current instruction set into D0
    JSR OP_JSR_Routine      ;Use the JSR routine to identify the op code
*-----------------------------------------------------------
*First Nibble Values (15-12)
*Value                  Operations
*$0                     GROUP_0: ORI,BCLR (static and dynamic),CMPI
*$1                     GROUP_1: MOVE.B                   
*$2                     GROUP_2: MOVE.L, MOVEA.L
*$3                     GROUP_3: MOVE.W, MOVEA.W
*$4                     GROUP_4: LEA,JSR,RTS,NEG,MOVEM
*$5                     GROUP_5: SUBQ
*$6                     GROUP_6: Bcc(BCS,BGE,BLT,BVC), BRA
*$7                     GROUP_7: INVALID_OP
*$8                     GROUP_8: DIVS, OR
*$9                     GROUP_7: SUB
*$A                     GROUP_A: INVALID_OP
*$B                     GROUP_B: EOR, CMP
*$C                     GROUP_C: MULS
*$D                     GROUP_D: ADD, ADDA
*$E                     GROUP_E: LSR, LSL, ASR, ASL, ROL, ROR
*$F                     GROUP_F: INVALID_OP


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
    MOVE.W (A6),D0           ;Move current OP code into D0
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
    MOVE.W   (A6),D0        ;Move current OP code into D0
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
    MOVE.W   (A6),D0        ;Move current OP code into D0
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
    MOVE.W   (A6),D0        ;Move current OP code into D0
    MOVE.W   #7,D1          ;Prepare 4 bit shift to D1
    LSL.W    D1,D0          ;Truncate to find the 2 size bits
    LSR.W    D1,D0          ;Reposition the bits
    MOVE.W   #6,D1          ;Prepare 9 bit shift to D1
    LSR.W    D1,D0          ;Truncate to shift 3 bits to a byte
    MOVE.W   D0,(A3)          ;Move 3 register bits into D4
   ; MOVEM.L (SP)+,D0-D5/A6  ;Restore registers
    RTS                    ;Return to stack
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
* Precondition: First nibble has been identified as $0
* Postcondition: Parses proper OP code with a nibble value of $0 or finds an
* invalid OP code. After a successful parse loading for EA values will be done
* through a subroutine.
********************************************************************************
C_GROUP_0:
    MOVEM.L D0-D1, -(SP) ; Backup registers
    
CHECK_OP_ORI:
    MOVE.W  (A6),D0         ;Move current instruction set into D
    ANDI.W  #$FF00,D0       ;Mask relevant bits to D0
    CMP.W   #$0000,D0       ;Compare the appropriate masked bits     
    BNE     CHECK_OP_CMPI   ;Branch to next comparison if not equal
    JSR     PRINT_OP_ORI    ;Print the OP code if equal
    JSR     FIND_2_BIT_SIZE_TO_EA         
    BRA     CG0_C           ;Finish routine
CHECK_OP_CMPI:
    MOVE.W  (A6),D0         ;Move current instruction set into D
    ANDI.W  #$FF00,D0       ;Mask relevant bits to D0
    CMP.W   #$0C00,D0       ;Compare the appropriate masked bits   
    BNE     CHECK_OP_S_BCLR ;Branch to next comparison if not equal       
    JSR     PRINT_OP_CMPI   ;Print the OP code if equal
    BRA     CG0_C           ;Finish routine
CHECK_OP_S_BCLR:
    MOVE.W  (A6),D0         ;Move current instruction set into D
    ANDI.W  #$FF00,D0       ;Mask relevant bits to D0
    CMP.W   #$0800,D0       ;Compare the appropriate masked bits
    BNE     CHECK_OP_D_BCLR ;Branch to next comparison if not equal
    JSR     PRINT_OP_S_BCLR ;Print the OP code if equal
    ;MOVEM.L (SP)+,D6-D7     ;POP STACK
    BRA     CG0_C           ;Finish routine
CHECK_OP_D_BCLR:
    MOVE.W (A6),D0                ;Move current instruction set into D
    ANDI.W  #%0000000110000000,D0 ;Do a direct binary bitmask to see which bits are needed
    CMP.W   #%0000000110000000,D0 ;Compare the expected binary value
    BNE     CG0_F                 ;If not equal this must be an invalid OP code
    JSR     PRINT_OP_D_BCLR       ;Print the OP code if equal
    BRA     CG0_C                ;Finish routine
CG0_F:                       ;Checks have been finished, invalid OP code has been found
    BRA INVALID_OP    
CG0_C:                       ;Checks have been finished,a valid OP code has been found
    RTS                      ;Return to stack
    
* GROUP_1                      
********************************************************************************
* MOVE.B: $1, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
********************************************************************************
C_GROUP_1:

CHECK_OP_MOVE_B:
    MOVE.W (A6),D0                  ;Move current instruction set into D0          
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
    MOVE.W (A6),D0                  ;Move current instruction set into D0  
    ANDI.W #$FF00,D0                ;Mask relevant bits to D0
    CMP.W #$2000,D0                 ;Compare the appropriate masked bits
    BRA FIND_MOVEA_L_DIFFERENCE     ;Branch always to check 

    
FIND_MOVEA_L_DIFFERENCE:    ;Finds difference between MOVEA and MOVE
    MOVE.W   (A6),D0        ;Move current OP code into D0
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
    MOVE.W (A6),D0
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
    MOVE.W (A6),D0
    ANDI.W #$FF00,D0
    CMP.W #$3000,D0
    BRA FIND_MOVEA_W_DIFFERENCE

    
FIND_MOVEA_W_DIFFERENCE:      ;Finds difference between MOVEA and MOVE
    MOVE.W   (A6),D0        ;Move current OP code into D0
    MOVE.W   #7,D1          ;Prepare 7 bit shift to D1
    LSL.W    D1,D0          ;Truncate to find the 3 address mode bits
    LSR.W    D1,D0          ;Reposition the bits
    MOVE.W   #6,D1          ;Prepare 6 bit shift to D1
    LSR.W    D1,D0          ;Truncate to shift 3 bits to a register
    MOVE.W   D0,D6          ;Move 3 address mode bits into D6
    CMP.W   #$1,D6          ;Check if the address mode value is MOVEA
    JSR     MOVE_AND_MOVEA_PARSE_EA
    BNE     CHECK_OP_MOVE_W 
    BEQ     PRINT_OP_MOVEA_W  
    
CHECK_OP_MOVE_W:
    MOVE.W (A6),D0
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
    
CHECK_OP_LEA:
    MOVE.W (A6),D0
   ; ANDI.W #$
CHECK_OP_JSR:

CHECK_OP_RTS:

CHECK_OP_NEG:

* GROUP_5
********************************************************************************
* SUBQ: $5, 11-9 DATA, 8 %1, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
********************************************************************************
C_GROUP_5:

CHECK_OP_SUBQ:

* GROUP_6
********************************************************************************
* BRA: $60, 7-0 8-Bit Displacement
* Bcc: $6, 11-8 Condition, 7-0 8-Bit Displacement
*   Branch: <Condition>   
*   BCS: %0101  		
*   BGE: %1100		
*   BLT: %1101	
*   BVC: %1000

********************************************************************************
C_GROUP_6:

CHECK_OP_BRA:

CHECK_OP_BCS:

CHECK_OP_BGE:

CHECK_OP_BLT:

CHECK_OP_BVC:

*GROUP_7
********************************************************************************
* Currently no OP codes here are supported.
********************************************************************************
C_GROUP_7:
    JSR INVALID_OP

* GROUP_8
********************************************************************************
* DIVS: $8, 11-9 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
* OR: $80, 7-6 Size, 5-3 EA Mode, 2-0 EA Register
********************************************************************************
C_GROUP_8:

CHECK_OP_DIVS:

CHECK_OP_OR:

* GROUP_9                      
********************************************************************************
* SUB: $9, 11-9 Reg, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
********************************************************************************
C_GROUP_9:

CHECK_OP_SUB:

*GROUP_A
********************************************************************************
* Currently no OP codes here are supported.
********************************************************************************
C_GROUP_A:
    JSR INVALID_OP

* GROUP_B                     
********************************************************************************
* EOR: $B, 11-9 Reg, 8 %1, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* CMP: $B, 11-9 Reg, 8 %0, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* The specific bit difference is listed 
********************************************************************************
C_GROUP_B:

CHECK_OP_EOR:

CHECK_OP_CMP:

* GROUP_C                     
********************************************************************************
* MULS: $C, 11-8 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
********************************************************************************
C_GROUP_C:

CHECK_OP_MULS:

* GROUP_D                     
********************************************************************************
* ADD: $D, 11-9 Reg, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* ADDA: $D, 11- 9 Reg, 8-6 OPMODE, 7-6 %11, 5-3 EA Mode, 2-0 EA Reg
* The specific bit difference is listed out in the OPMODE field.
********************************************************************************
C_GROUP_D:

CHECK_OP_ADDA:

CHECK_OP_ADD:

* GROUP_E                     
********************************************************************************
* LSR: $E, 11-9 Count/Reg, 8 %0, 7-6 Size, 5 i/r, 4-3 %01, 2-0 Reg
* LSL: $E, 11-9 Count/Reg, 8 %1, 7-6 Size, 5 i/r, 4-3 %01, 2-0 Reg
* ASR: $E, $0, 8 %0, 7-6 %11, 5-3 EA Mode, 2-0 EA reg
* ASL: $E, $0, 8 %1, 7-6 %11, 5-3 EA Mode, 2-0 EA reg
* ROR: $E, 11-9 Count/Reg, 8 %0, 7-6 Size, 5 i/r, 4-3 %11, 2-0 Reg
* ROL: $E, 11-9 Count/Reg, 8 %1, 7-6 Size, 5 i/r, 4-3 %11, 2-0 Reg
* Count/Reg for LSR/LSL refers to shift count, where 0 = shift count of 8, 1-7 
* refers to the respective value when i/r = 0. If i/r = 1, data register in the 
* Count/Reg field specifies the shift count.  
* 
* Count/Reg for ROR/ROL specifies rotate count instead of shift count.
********************************************************************************
C_GROUP_E:

CHECK_OP_LSR:

CHECK_OP_LSL:

CHECK_OP_ASL:

CHECK_OP_ASR:

CHECK_OP_ROL:

CHECK_OP_ROR:

* GROUP_F
********************************************************************************
* Currently no OP codes here are supported.
********************************************************************************
C_GROUP_F:
    JSR INVALID_OP
    
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
    
********************** PRINTING ROUTINES ****************************************
PRINT_OP_ORI:
    LEA P_OP_ORI,A1
    ;MOVE.W P_OP_ORI,(A4)+
    JSR PRINT_OP
    RTS
PRINT_OP_CMPI:
    JSR FIND_3_BIT_REG_TO_EA
    JSR FIND_2_BIT_SIZE_TO_EA
    JSR MOVE_LAST_6_BITS_TO_EA
    LEA P_OP_CMPI,A1
    ;MOVE.W P_OP_CMPI,(A4)+
    JSR PRINT_OP
    RTS
PRINT_OP_S_BCLR:
    	JSR MOVE_LAST_6_BITS_TO_EA
	JSR FIND_3_BIT_REG_TO_EA
	MOVE.W #$0,(A6)
	MOVE.W #%000, D4
    LEA P_OP_S_BCLR,A1
    ;MOVE.W P_OP_S_BCLR,(A4)+
    JSR PRINT_OP
    RTS
PRINT_OP_D_BCLR:
	JSR MOVE_LAST_6_BITS_TO_EA
	JSR FIND_3_BIT_REG_TO_EA
	MOVE.W #$0,(A6)
	MOVE.W #%110, D4
    LEA P_OP_D_BCLR,A1
    ;MOVE.W P_OP_D_BCLR,(A4)+
    JSR PRINT_OP
    RTS    
PRINT_OP_MOVEB:
    JSR MOVE_AND_MOVEA_PARSE_EA
    MOVE.W #$1,(A6)
    LEA P_OP_MOVEB,A1
    ;MOVE.W P_OP_MOVEB,(A4)+
    JSR PRINT_OP
    RTS
PRINT_OP_MOVEA_L:
    JSR MOVE_AND_MOVEA_PARSE_EA
    MOVE.W #$2,(A6)
    LEA P_OP_MOVEA_L,A1
    ;MOVE.W P_OP_MOVEA_L,(A4)+
    JSR PRINT_OP
    RTS
PRINT_OP_MOVE_L:
    JSR MOVE_AND_MOVEA_PARSE_EA
    MOVE.W #$2,(A6)
    LEA P_OP_MOVE_L,A1
    ;MOVE.W P_OP_MOVE_L,(A4)+
    JSR PRINT_OP
    RTS
PRINT_OP_MOVEA_W:
    JSR MOVE_AND_MOVEA_PARSE_EA
    MOVE.W #$3,(A6)
    LEA P_OP_MOVEA_W,A1
    ;MOVE.W P_OP_MOVEA_W,(A4)+
    JSR PRINT_OP
    RTS
PRINT_OP_MOVE_W:
    JSR MOVE_AND_MOVEA_PARSE_EA
    MOVE.W #$3,(A6)
    LEA P_OP_MOVE_W,A1
    ;MOVE.W P_OP_MOVE_W,(A4)+
    JSR PRINT_OP
    RTS    
PRINT_OP:   ;Prints current op code byte
    ;MOVE.W (A4),(A1)       ; NEEDS TO USE G_BUFFER LATER
    MOVE.B #13,D0
    TRAP #15
    RTS
******************* END OF PRINTING ROUTINES ***********************************

******************* END OF JMP LABELS ******************************************

******************* DATA CONSTANT PRINTS ***************************************
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
    END START











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
