*-----------------------------------------------------------
* Title      : OP Code routines for Disassembler
* Written by : Daniel Yan
* Date       : 2/28/2019, Updated 3/16/2019

* Description: Disassembler routines to identify any valid
* OP code dependent on current supported list.
*------------------------------------------------------------
OP_SIZE         DS.B    1   ;This constant refers to the size of the current OP code 
MNEMONIC        DS.B    1   ;Constant for EA, first 4 bits (15-12) of a 4 hex OP code
FIRST_3         DS.B    1   ;Constant for EA, 3 bits (11-9) of a 4 hex OP code
SECOND_3        DS.B    1   ;Constant for EA, 3 bits (8-6) of a 4 hex OP code
THIRD_3         DS.B    1   ;Constant for EA, 3 bits (5-3) of a 4 hex OP code
FOURTH_3        DS.B    1   ;Constant for EA, 3 bits (2-0) of a 4 hex OP code

************************************************************************************
* PRINTING BUFFER FUNCTION HAS BEEN FINISHED
* STATUS: 
* IDENTIFICATION FOR ALL OP CODES: 		DONE
* VALIDATION TESTING FOR ALL OP CODES: 	DONE
* PRINTING ALL OP CODES TO BUFFER: 		DONE
* PRINTING SIZE BITS OF ALL OP CODES:   DONE
*-----------------------------------------------------------
*First Nibble Values (15-12)
*Value                  Operations
*$0                     GROUP_0: ORI,BCLR (static and dynamic),CMPI --- DONE
*$1                     GROUP_1: MOVE.B                             --- DONE
*$2                     GROUP_2: MOVE.L, MOVEA.L                    --- DONE
*$3                     GROUP_3: MOVE.W, MOVEA.W                    --- DONE
*$4                     GROUP_4: LEA,JSR,RTS,NEG,MOVEM              --- DONE
*$5                     GROUP_5: SUBQ                               --- DONE
*$6                     GROUP_6: Bcc(BCS,BGE,BLT,BVC), BRA          --- DONE
*$7                     GROUP_7: INVALID_OP                         --- DONE
*$8                     GROUP_8: DIVS, OR                           --- DONE
*$9                     GROUP_9: SUB                                --- DONE
*$A                     GROUP_A: INVALID_OP                         --- DONE
*$B                     GROUP_B: EOR, CMP                           --- DONE
*$C                     GROUP_C: MULS                               --- DONE
*$D                     GROUP_D: ADD, ADDA                          --- DONE
*$E                     GROUP_E: LSR, LSL, ASR, ASL, ROL, ROR       --- DONE
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

OP_JSR_Routine:
    MOVEM.L D0-D1, -(SP)           ;Backup registers D0 and D1 by pushing it on the Stack
    MOVE.W CUR_OP_CODE,D0
    MOVE.B #1,IS_VALID
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
         CMP.B #1,IS_VALID
         BEQ    main_EA             ;This runs EA's routines after OP code portion is finished
         BNE    check_print
**********************************************************************************    
* FIND_2_BIT_SIZE_7_TO_6
**********************************************************************************
* Description: For OP codes with 2 bit size fields, the 2 relevant bits (7-6) will 
* be parsed and moved to the appropriate registers.
*
* Registers used: D0,D1
*
* Precondition: OP code has been identified with 2 size bit field for CUR_OP_CODE.
*
* Postcondition: 2 bit size field has been isolated and stored into OP_SIZE.
**********************************************************************************
FIND_2_BIT_SIZE_7_TO_6:         ;Move the 2 bit size field relevant register
    MOVEM.L  D0-D1,-(SP)        ;Save all changed registers
    MOVE.W   CUR_OP_CODE,D0     ;Move current OP code into D0
    MOVE.W   #8,D1              ;Prepare 8 bit shift to D1
    LSL.W    D1,D0              ;Truncate to find the 2 size bits
    LSR.W    D1,D0              ;Reposition the bits
    MOVE.W   #6,D1              ;Prepare 6 bit shift to D1
    LSR.W    D1,D0              ;Truncate to shift 2 bits to a byte
    MOVE.B   D0,OP_SIZE         ;Move 2 size bits into OP_SIZE
    MOVEM.L (SP)+,D0-D1         ;Restore registers
    RTS                         ;Return to stack
**********************************************************************************

* FIND_1_BIT_SIZE_6
**********************************************************************************
* Description: For OP codes with 1 bit size fields, the 1 relevant bit 6 will 
* be parsed and moved to the appropriate registers.
* This particular size parsing is used for MOVEM
*
* Registers used: D0,D1
*
* Precondition: OP code has been identified with 1 size bit field for CUR_OP_CODE.
*
* Postcondition: 1 bit size field has been isolated and stored into OP_SIZE.
**********************************************************************************
FIND_1_BIT_SIZE_6:              ;Move the 1 bit size field relevant register
    MOVEM.L  D0-D1,-(SP)        ;Save all changed registers
    MOVE.W   CUR_OP_CODE,D0     ;Move current OP code into D0
    MOVE.W   #9,D1              ;Prepare 9 bit shift to D1
    LSL.W    D1,D0              ;Truncate to find the size bit
    LSR.W    D1,D0              ;Reposition the bits
    MOVE.W   #6,D1              ;Prepare 6 bit shift to D1
    LSR.W    D1,D0              ;Truncate to shift 1 bit to a byte
    MOVE.B   D0,OP_SIZE         ;Move 1 size bit into OP_SIZE
    MOVEM.L (SP)+,D0-D1         ;Restore registers
    RTS                         ;Return to stack
**********************************************************************************

* FIND_1_BIT_SIZE_8
**********************************************************************************
* Description: For OP codes with 1 bit size fields, the 1 relevant bit 8 will 
* be parsed and moved to the appropriate registers.
* This particular size parsing is used for ADDA
*
* Registers used: D0,D1
*
* Precondition: OP code has been identified with 1 size bit field for CUR_OP_CODE.
*
* Postcondition: 1 bit size field has been isolated and stored into OP_SIZE.
*
**********************************************************************************
FIND_1_BIT_SIZE_8:         ;Move the 1 bit size field relevant register
    MOVEM.L  D0-D1,-(SP)        ;Save all changed registers
    MOVE.W   CUR_OP_CODE,D0     ;Move current OP code into D0
    MOVE.W   #7,D1              ;Prepare 7 bit shift to D1
    LSL.W    D1,D0              ;Truncate to find the 1 size bit
    LSR.W    D1,D0              ;Reposition the bits
    MOVE.W   #8,D1              ;Prepare 8 bit shift to D1
    LSR.W    D1,D0              ;Truncate to shift 1 bit to a byte
    MOVE.B   D0,OP_SIZE         ;Move 1 size bit into OP_SIZE
    MOVEM.L (SP)+,D0-D1         ;Restore registers
    RTS                         ;Return to stack
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
****MOVING_SOURCE***********
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
********** EA Parsing ************************************************************
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
* Supported OP codes:
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
* 
* Unsupported OP codes:
* ORI_TO_CCR, ORI_TO_SR, ANDI_TO_CCR, ANDI_TO_SR, ANDI, SUBI, ADDI, EORI_TO_CCR
* EORI_TO_SR, EORI, STATIC_BTST, STATIC_BCHG, STATIC_BSET, DYNAMIC_BTST,
* DYNAMIC_BCHG, DYNAMIC_BSET, MOVEP 
********************************************************************************
C_GROUP_0:
    MOVEM.L D0-D1, -(SP)        	;Backup registers
	
*Unsupported OP codes that are fully static in bits
CHECK_OP_ORI_TO_CCR:
    MOVE.W CUR_OP_CODE,D0      		;Move current instruction set into D0
    CMP.W #$003C,D0            		;Compare the direct full bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_ORI_TO_SR     		;Check next routine
    
CHECK_OP_ORI_TO_SR:
    MOVE.W CUR_OP_CODE,D0      		;Move current instruction set into D0
    CMP.W #$007C,D0            		;Compare the direct full bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_ANDI_TO_CCR   		;Check next routine
    
CHECK_OP_ANDI_TO_CCR:
    MOVE.W CUR_OP_CODE,D0      		;Move current instruction set into D0
    CMP.W #$023C,D0            		;Compare the direct full bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_ANDI_TO_SR    		;Check next routine
    
CHECK_OP_ANDI_TO_SR:
    MOVE.W CUR_OP_CODE,D0      		;Move current instruction set into D0
    CMP.W #$027C,D0            		;Compare the direct full bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_EORI_TO_CCR          		;Check next routine

CHECK_OP_EORI_TO_CCR:
    MOVE.W CUR_OP_CODE,D0      		;Move current instruction set into D0
    CMP.W #$0A3C,D0            		;Compare the direct full bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_EORI_TO_SR    		;Check next routine
    
CHECK_OP_EORI_TO_SR:
    MOVE.W CUR_OP_CODE,D0      		;Move current instruction set into D0
    CMP.W #$0A7C,D0            		;Compare the direct full bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_ANDI          		;Check next routine
    
*Unsupported OP codes to check with partial static bits
CHECK_OP_ANDI:
    MOVE.W CUR_OP_CODE,D0      		;Move current instruction set into D0
    ANDI.W #$FF00,D0           		;Mask relevant bits to D0
    CMP.W #$0200,D0            		;Compare the appropriate masked bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_SUBI          		Check next routine
    
CHECK_OP_SUBI:
    MOVE.W CUR_OP_CODE,D0      		;Move current instruction set into D0
    ANDI.W #$FF00,D0           		;Mask relevant bits to D0
    CMP.W #$0400,D0            		;Compare the appropriate masked bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_ADDI          		;Check next routine

CHECK_OP_ADDI:
    MOVE.W CUR_OP_CODE,D0      		;Move current instruction set into D0
    ANDI.W #$FF00,D0           		;Mask relevant bits to D0
    CMP.W #$0600,D0            		;Compare the appropriate masked bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_EORI          		;Check next routine 

CHECK_OP_EORI:
    MOVE.W CUR_OP_CODE,D0      		;Move current instruction set into D0
    ANDI.W #$FF00,D0           		;Mask relevant bits to D0
    CMP.W #$0A00,D0            		;Compare the appropriate masked bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_STATIC_BTST   		;Check next routine
    
CHECK_OP_STATIC_BTST:
    MOVE.W CUR_OP_CODE,D0      		;Move current instruction set into D0
    ANDI.W #$FFC0,D0           		;Mask relevant bits to D0
    CMP.W #$0800,D0            		;Compare the appropriate masked bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_STATIC_BCHG   		;Check next routine
    
CHECK_OP_STATIC_BCHG:
    MOVE.W CUR_OP_CODE,D0   	    ;Move current instruction set into D0
    ANDI.W #$FFC0,D0        	    ;Mask relevant bits to D0
    CMP.W #$0840,D0         	    ;Compare the appropriate masked bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_STATIC_BSET   		;Check next routine

CHECK_OP_STATIC_BSET:
    MOVE.W CUR_OP_CODE,D0   	    ;Move current instruction set into D0
    ANDI.W #$FFC0,D0        	    ;Mask relevant bits to D0
    CMP.W #$08C0,D0         	    ;Compare the appropriate masked bits
    BEQ GROUP0_INVALID      	    ;INVALID OP code found   
    BNE CHECK_OP_DYNAMIC_BTST  		;Check next routine

CHECK_OP_DYNAMIC_BTST:
    MOVE.W CUR_OP_CODE,D0   	    ;Move current instruction set into D0
    ANDI.W #$F1C0,D0        	    ;Mask relevant bits to D0
    CMP.W #$0100,D0         	    ;Compare the appropriate masked bits
    BEQ GROUP0_INVALID      	    ;INVALID OP code found
    BNE CHECK_OP_DYNAMIC_BCHG  		;Check next routine

CHECK_OP_DYNAMIC_BCHG:
    MOVE.W CUR_OP_CODE,D0       	;Move current instruction set into D0
    ANDI.W #$F1C0,D0            	;Mask relevant bits to D0
    CMP.W #$0140,D0             	;Compare the appropriate masked bits 
    BEQ GROUP0_INVALID          	;INVALID OP code found
    BNE CHECK_OP_DYNAMIC_BSET   	;Check next routine
    
CHECK_OP_DYNAMIC_BSET:

    MOVE.W  CUR_OP_CODE,D0      	;Move current instruction set into D0
    ANDI.W  #$F1C0,D0           	;Mask relevant bits to D0
    CMP.W   #$01C0,D0           	;Compare the appropriate masked bits 
    BEQ     BIT_CHECK_MOVEP     	;Check special case for MOVEP
    BNE     CHECK_OP_MOVEP      	;Check next routine

BIT_CHECK_MOVEP:								;This is a special case check for MOVEP
    MOVE.W  CUR_OP_CODE,D0      	;Move current instruction set into D0
    MOVE.W  #10,D1              	;Prepare a 10-bit shift
    LSL.W   D1,D0               	;Shift out 10 bits left 
    LSR.W   D1,D0               	;Reposition D0 for last 6 bits
    LSR.W   #3,D0               	;Shift out 3 bits right, D0 contains bits 5-3
    CMP.W   #$1,D0              	;Compare bits to D0
    BEQ     CHECK_OP_MOVEP      	;If bits are $1 then it's addressing, goto MOVEP
    BNE     GROUP0_INVALID      	;If not then it's DYNAMIC_BSET which is invalid
	
CHECK_OP_MOVEP:
    MOVE.W CUR_OP_CODE,D0       	;Move current instruction set into D0
    ANDI.W #$F138,D0            	;Mask relevant bits to D0
    CMP.W #$0108,D0             	;Compare the appropriate masked bits
    BEQ INVALID_OP              	;INVALID OP code found
    BNE CHECK_OP_ORI            	;Check next routine

*Supported OP code checks
CHECK_OP_ORI:
    MOVE.W  CUR_OP_CODE,D0          ;Move current instruction set into D0
    ANDI.W  #$FF00,D0               ;Mask relevant bits to D0
    CMP.W   #$0000,D0               ;Compare the appropriate masked bits     
    BNE     CHECK_OP_CMPI           ;Branch to next comparison if not equal
    JSR     FIND_2_BIT_SIZE_7_TO_6
    JSR     PRINT_OP_ORI            ;Print the OP code if equal    
    BRA     GROUP0_SUCCESS          ;Finish routine
    
CHECK_OP_CMPI:
    MOVE.W  CUR_OP_CODE,D0          ;Move current instruction set into D0
    ANDI.W  #$FF00,D0               ;Mask relevant bits to D0
    CMP.W   #$0C00,D0               ;Compare the appropriate masked bits   
    BNE     CHECK_OP_STATIC_BCLR    ;Branch to next comparison if not equal       
    JSR     FIND_2_BIT_SIZE_7_TO_6
    JSR     PRINT_OP_CMPI           ;Print the OP code if equal
    BRA     GROUP0_SUCCESS          ;Finish routine
    
CHECK_OP_STATIC_BCLR:
    MOVE.W  CUR_OP_CODE,D0          ;Move current instruction set into D0
    ANDI.W  #$FF00,D0               ;Mask relevant bits to D0
    CMP.W   #$0800,D0               ;Compare the appropriate masked bits
    BNE     CHECK_OP_DYNAMIC_BCLR   ;Branch to next comparison if not equal
    JSR     FIND_2_BIT_SIZE_7_TO_6
    JSR     PRINT_OP_STATIC_BCLR    ;Print the OP code if equal
    BRA     GROUP0_SUCCESS          ;Finish routine
    
CHECK_OP_DYNAMIC_BCLR:
    MOVE.W  CUR_OP_CODE,D0          ;Move current instruction set into D0
    ANDI.W  #$0180,D0   			;Mask relevant bits to D0
    CMP.W   #$0180,D0   			;Compare the appropriate masked bits
    BNE     GROUP0_INVALID          ;If not equal this must be an invalid OP code
    JSR     FIND_2_BIT_SIZE_7_TO_6
    JSR     PRINT_OP_DYNAMIC_BCLR   ;Print the OP code if equal
    BRA     GROUP0_SUCCESS          ;Finish routine

GROUP0_INVALID:                     ;Checks have been finished, invalid OP code has been found
    JSR INVALID_OP                  ;INVALID OP code found
GROUP0_SUCCESS:                     ;Checks have been finished,a valid OP code has been found
    MOVEM.L (SP)+,D0-D1             ;Restore registers
    RTS                             ;Return to stack
    
* GROUP_1                      
********************************************************************************
* Supported OP code:
* MOVE.B: $1, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
********************************************************************************
C_GROUP_1:
    MOVEM.L D0-D1,-(SP)             ;Save registers to stack

CHECK_OP_MOVE_B:
    MOVE.W  CUR_OP_CODE,D0          ;Move current instruction set into D0          
    ANDI.W  #$F000,D0               ;Mask relevant bits to D0
    CMP.W   #$1000,D0               ;Compare the appropriate masked bits 
    BNE     GROUP1_INVALID          ;Invalid OP code has been found
    JSR     PRINT_OP_MOVEB          ;Print the OP code if equal
    BRA     GROUP1_SUCCESS          ;Finish routine
    
GROUP1_INVALID:
    JSR INVALID_OP                  ;Invalid OP code found
GROUP1_SUCCESS:
    MOVEM.L (SP)+,D0-D1             ;Restore register
    RTS                             ;Return to stack
* GROUP_2
********************************************************************************
* Supported OP codes:
* MOVEA.L: $2, 11-9 DST Reg, 8-6 %001, 5-3 SRC Mode, 2-0 SRC Reg
* MOVE.L: $2, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
********************************************************************************
C_GROUP_2:
    MOVEM.L D0-D2,-(SP)             ;Save registers to stack

CHECK_OP_MOVEA_L:
    MOVE.W CUR_OP_CODE,D0           ;Move current instruction set into D0  
    ANDI.W #$F000,D0                ;Mask relevant bits to D0
    CMP.W #$2000,D0                 ;Compare the appropriate masked bits
    JMP FIND_MOVEA_L_DIFFERENCE     ;Branch always to check 
    
FIND_MOVEA_L_DIFFERENCE:            ;Finds difference between MOVEA and MOVE
    MOVE.W   CUR_OP_CODE,D0         ;Move current OP code into D0
    MOVE.W   #7,D1                  ;Prepare 7 bit shift to D1
    LSL.W    D1,D0                  ;Truncate to find the 3 address mode bits
    LSR.W    D1,D0                  ;Reposition the bits
    MOVE.W   #6,D1                  ;Prepare 6 bit shift to D1
    LSR.W    D1,D0                  ;Truncate to shift 3 bits to a register
    MOVE.W   D0,D2                  ;Move 3 address mode bits into D6
    CMP.W   #$1,D2                  ;Check if the address mode value is MOVEA
    BNE     CHECK_OP_MOVE_L         ;Branch if not equal to check MOVE
    JSR     PRINT_OP_MOVEA_L        ;Print the OP code if it's a match
    BRA     GROUP2_SUCCESS          ;Finish routine
    
    
CHECK_OP_MOVE_L:
    MOVE.W CUR_OP_CODE,D0           ;Move current instruction set into D0
    ANDI.W #$F000,D0                ;Mask relevant bits to D0
    CMP.W #$2000,D0                 ;Compare the appropriate masked bits
    BNE GROUP2_INVALID              ;If not equal, OP code is invalid
    JSR PRINT_OP_MOVE_L             ;Print out MOVE.L
    BRA GROUP2_SUCCESS              ;Finish routine
    
GROUP2_INVALID:    
    JSR INVALID_OP                  ;Invalid OP code found
GROUP2_SUCCESS:
    MOVEM.L (SP)+,D0-D2             ;Restore register
    RTS                             ;Return to stack
* GROUP_3
********************************************************************************
* Supported OP codes:
* MOVEA.W: $3, 11-9 DST Reg, 8-6 %001, 5-3 SRC Mode, 2-0 SRC Reg
* MOVE.W: $3, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
********************************************************************************
C_GROUP_3:
    MOVEM.L D0-D2,-(SP)			    ;Save registers to stack
	
CHECK_OP_MOVEA_W:
    MOVE.W   CUR_OP_CODE,D0        ;Move current instruction set into D0
    ANDI.W   #$F000,D0			   ;Mask relevant bits to D0
    CMP.W    #$3000,D0			   ;Compare the appropriate masked bits
    JMP      FIND_MOVEA_W_DIFF	   ;Custom routine to differentiate MOVE and MOVEA

    
FIND_MOVEA_W_DIFF:      		   ;Finds difference between MOVEA and MOVE
    MOVE.W   CUR_OP_CODE,D0        ;Move current instruction set into D0
    MOVE.W   #7,D1          	   ;Prepare 7 bit shift to D1
    LSL.W    D1,D0          	   ;Truncate to find the 3 address mode bits
    LSR.W    D1,D0          	   ;Reposition the bits
    MOVE.W   #6,D1          	   ;Prepare 6 bit shift to D1
    LSR.W    D1,D0          	   ;Truncate to shift 3 bits to a register
    MOVE.W   D0,D2          	   ;Move 3 address mode bits into D6
    CMP.W    #$1,D2          	   ;Check if the address mode value is MOVEA
    BNE      CHECK_OP_MOVE_W	   ;If bits do not match, try MOVE 
    JSR      PRINT_OP_MOVEA_W  	   ;Print the OP code if it's a match
    BRA      GROUP3_SUCCESS		   ;Finish routine
    
CHECK_OP_MOVE_W:
    MOVE.W   CUR_OP_CODE,D0    	   ;Move current instruction set into D0
    ANDI.W   #$F000,D0			   ;Mask relevant bits to D0
    CMP.W    #$3000,D0			   ;Compare the appropriate masked bits
    BNE      GROUP3_INVALID        ;INVALID OP code found
    JSR      PRINT_OP_MOVE_W	   ;Print the OP code if it's a match
    BRA      GROUP3_SUCCESS        ;Finish routine
    
GROUP3_INVALID:
    JSR INVALID_OP				   ;INVALID OP code found
GROUP3_SUCCESS:
    MOVEM.L (SP)+,D0-D2 		   ;Restore registers from stack
    RTS							   ;Return to stack

* GROUP_4
********************************************************************************
* Supported OP codes:
* LEA: $4, 11-9 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
* JSR: $4E, 7-6 %10, 5-3 EA Mode, 2-0 EA Reg 
* RTS: $4E75
* NEG: $44, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
* MOVEM: $4, 11 %1, 10 %D, 9-7 %001, 6 S, 5-3 EA Mode, 2-0 EA Reg
* %D = 0 , Register to Memory, 1 Memory to Register
* Unsupported OP codes: MOVE_FROM_SR, MOVE_TO_CCR, MOVE_TO_SR, NEGX, CLR, NOT
* EXT, NBCD, SWAP, PEA, ILLEGAL, TAS, TST, TRAP, LINK, UNLK, MOVE_USP, RESET,
* NOP, STOP, RTE, TRAPV, RTR, JMP, CHK
********************************************************************************
C_GROUP_4:
    MOVE.L  D0,-(SP)         	;Save registers
	
*Unsupported OP codes to check that are full static bits
CHECK_OP_STOP:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    CMP.W  #$4E72,D0	     		;Compare the appropriate bits
    BEQ    GROUP4_INVALID    		;INVALID OP code found
    BNE    CHECK_OP_RESET    		;Check next OP code
    
CHECK_OP_RESET:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    CMP.W  #$4E70,D0	     		;Compare the appropriate bits
    BEQ    GROUP4_INVALID	 		;INVALID OP code found
    BNE    CHECK_OP_ILLEGAL         ;Check next OP code
        
CHECK_OP_ILLEGAL:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    CMP.W  #$4AFC,D0	     		;Compare the appropriate bits
    BEQ    GROUP4_INVALID	 		;INVALID OP code found
    BNE    CHECK_OP_RTE      		;Check next OP code
    
CHECK_OP_RTE:    
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    CMP.W #$4E73,D0	         		;Compare the appropriate bits
    BEQ   GROUP4_INVALID	 		;INVALID OP code found
    BNE   CHECK_OP_TRAPV     		;Check next OP code
    
CHECK_OP_TRAPV:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    CMP.W  #$4E76,D0	     		;Compare the appropriate bits
    BEQ    GROUP4_INVALID	 		;INVALID OP code found
    BNE    CHECK_OP_RTR      		;Check next OP code
    
CHECK_OP_RTR:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    CMP.W #$4E77,D0	     	 		;Compare the appropriate bits
    BEQ    GROUP4_INVALID	 		;INVALID OP code found
    BNE    CHECK_OP_MOVE_FROM_SR   	;Check next OP code


*Unsupported OP codes to check that have partial static bits
CHECK_OP_MOVE_FROM_SR:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask relevant bits to D0
    CMP.W  #$40C0,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code found	
    BNE    CHECK_OP_MOVE_TO_CCR		;Check next OP code
    
CHECK_OP_MOVE_TO_CCR:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask relevant bits to D0
    CMP.W  #$44C0,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code found
    BNE    CHECK_OP_MOVE_TO_SR		;Check next OP code
    
CHECK_OP_MOVE_TO_SR:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask relevant bits to D0
    CMP.W  #$46C0,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code found
    BNE    CHECK_OP_NEGX			;Check next OP code
    
CHECK_OP_NEGX:
    MOVE.W CUR_OP_CODE,D0   		 ;Move current instruction set into D0
    ANDI.W #$FF00,D0				;Mask relevant bits to D0
    CMP.W  #$4000,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code found
    BNE    CHECK_OP_CLR				;Check next OP code
    
CHECK_OP_CLR:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FF00,D0				;Mask relevant bits to D0
    CMP.W  #$4200,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code found
    BNE    CHECK_OP_NOT				;Check next OP code
    
CHECK_OP_NOT:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FF00,D0				;Mask relevant bits to D0
    CMP.W  #$4600,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code found
    BNE    CHECK_OP_EXT				;Check next OP code
    
CHECK_OP_EXT:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FF88,D0				;Mask relevant bits to D0
    CMP.W  #$4880,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code BIT_CHECK_EXT
    BNE    CHECK_OP_NBCD			;Check next OP code

BIT_CHECK_EXT:    
    MOVE.W CUR_OP_CODE,D0    		;This is a special case to check against MOVEM
    MOVE.W #10,D1					;Prepare a 10 bit shift into D1
    LSL.W  D1,D0					;Shift D0 left 10 bits
    LSR.W  D0,D0					;Reposition D0
    LSR.W  #3,D0					;Shift D0 3 bits
    CMP.W  %000,D0					;Check the specific bits needed to differentiate EXT
    BEQ    GROUP4_INVALID  			;This means that this OP code is EXT
    BNE    CHECK_OP_MOVEM   	    ;This is the only other possibility 
    
CHECK_OP_NBCD:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask relevant bits to D0			
    CMP.W  #$4800,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_SWAP			;Check next OP code
    
CHECK_OP_SWAP:                  	; This must go before CHECK_OP PEA as first 3 nibbles can be equivalent
    MOVE.W CUR_OP_CODE,D0       	;Move current instruction set into D0
    ANDI.W #$FF48,D0				;Mask relevant bits to D0
    CMP.W  #$4840,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_PEA				;Check next OP code
 
CHECK_OP_PEA:               		;This must go after CHECK_OP_SWAP as first 3 nibbles can be equivalent
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FF40,D0				;Mask relevant bits to D0
    CMP.W  #$4840,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_TAS				;Check next OP code
    
CHECK_OP_TAS:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask relevant bits to D0
    CMP.W  #$4AC0,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_TST				;Check next OP code

CHECK_OP_TST:               		;This must go after CHECK_OP_TAS as first 2 nibbles are equivalent
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FF00,D0				;Mask relevant bits to D0
    CMP.W  #$4A00,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_TRAP			;Check next OP code
    
CHECK_OP_TRAP:
    MOVE.W CUR_OP_CODE,D0		    ;Move current instruction set into D0
    ANDI.W #$FFF0,D0				;Mask relevant bits to D0
    CMP.W  #$4E40,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_LINK			;Check next OP code
    
CHECK_OP_LINK:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FFF8,D0				;Mask relevant bits to D0
    CMP.W  #$4E50,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_UNLK			;Check next OP code

CHECK_OP_UNLK:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FFF8,D0				;Mask relevant bits to D0
    CMP.W  #$4E58,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_MOVE_USP	    ;Check next OP
    
CHECK_OP_MOVE_USP:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FFF0,D0				;Mask relevant bits to D0
    CMP.W  #$4E60,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_JMP				;Check next OP

CHECK_OP_JMP:
     MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
     ANDI.W #$FFC0,D0				;Mask relevant bits to D0
     CMP.W  #$4EC0,D0				;Compare the appropriate masked bits
     BEQ    GROUP4_INVALID			;INVALID OP code
     BNE    CHECK_OP_CHK			;Check next OP code
     
CHECK_OP_CHK:
    MOVE.W  CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W  #$F1C0,D0				;Mask relevant bits to D0
    CMP.W   #$4180,D0				;Compare the appropriate masked bits
    BEQ     INVALID_OP				;INVALID OP code
    BNE     CHECK_OP_NOP			;Check next OP code

*Supported OP codes to check
CHECK_OP_NOP:                       ;While this code is not in the supported docs, Nash covered it in class and expects it to be implemented
    MOVE.W CUR_OP_CODE,D0   		;Move current instruction set into D0
    CMP.W  #$4E71,D0	     		;Compare the appropriate bits
    BNE    CHECK_OP_RTS       		;Check next OP code
    JSR    PRINT_OP_NOP             ;Print out OP code
    BRA    GROUP4_SUCCESS           ;Finish routine
    
CHECK_OP_RTS:
    MOVE.W CUR_OP_CODE,D0		    ;Move current instruction set into D0
    CMP.W  #$4E75,D0				;Mask exact bits for RTS	
    BNE    CHECK_OP_LEA				;If it's equal check next code
    JSR    PRINT_OP_RTS				;Print out OP code
    BRA    GROUP4_SUCCESS           ;Finish routine
 
CHECK_OP_LEA:
    MOVE.W CUR_OP_CODE,D0   		;Move current instruction set into D0
    ANDI.W #$F1C0,D0				;Mask appropriate bits
    CMP.W  #$41C0,D0				;Compare masked bits
    BNE    CHECK_OP_JSR				;Check next OP code
    JSR    PRINT_OP_LEA				;Print out OP code
    BRA    GROUP4_SUCCESS           ;Finish routine
 
CHECK_OP_JSR:
    MOVE.W CUR_OP_CODE,D0  			;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask appropriate bits
    CMP.W  #$4E80,D0				;Compare masked bits
    BNE    CHECK_OP_NEG				;Check next OP code
    JSR    PRINT_OP_JSR				;Print out OP code
    BRA    GROUP4_SUCCESS           ;Finish routine
    
CHECK_OP_NEG:
    MOVE.W CUR_OP_CODE,D0   		;Move current instruction set into D0
    ANDI.W #$FF00,D0				;Mask appropriate bits
    CMP.W  #$4400,D0				;Compare masked bits
    BNE    CHECK_OP_MOVEM			;Check next OP code
    JSR     FIND_2_BIT_SIZE_7_TO_6	;Find size field
    JSR    PRINT_OP_NEG				;Print out OP code
    BRA    GROUP4_SUCCESS           ;Finish routine
    
CHECK_OP_MOVEM:
    MOVE.W CUR_OP_CODE,D0   		;Move current instruction set into D0
    ANDI.W #$FB80,D0				;Mask appropriate bits
    CMP.W  #$4880,D0				;Compare masked bits
    BNE    INVALID_OP       		;If no code is found, it is invalid
    JSR    PRINT_OP_MOVEM_W			;Print out OP code
    BRA    GROUP4_SUCCESS			;Finish routine
    
GROUP4_INVALID:
    JSR INVALID_OP					;INVALID op code has been found, set IS_VALID to 0
    JMP GROUP4_SUCCESS 
GROUP4_SUCCESS:
    MOVEM.L (SP)+,D0 				;Restore saved registers
    RTS								;Return to stack
* GROUP_5
********************************************************************************
* Supported OP code:
* SUBQ: $5, 11-9 DATA, 8 %1, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
* Unsupported OP codes: ADDQ, Scc, DBcc
* Validation checking:
* Check against, ADDQ, Scc, DBcc
********************************************************************************
C_GROUP_5:
    MOVEM.L D0,-(SP)         		;Save registers to stack
*Unsupported OP codes
CHECK_OP_DBcc:               		;These are ordered first due to checking bits 7-6
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$F0C8,D0		 		;Mask appropriate bits
    CMP.W  #$50C8,D0				;Compare appropriate masked bits
    BEQ    GROUP5_INVALID			;INVALID op code found
    BNE    CHECK_OP_Scc 			;Check next OP code

CHECK_OP_Scc:
    MOVE.W CUR_OP_CODE,D0   		;Move current instruction set into D0
    ANDI.W #$F0C0,D0 				;Mask appropriate bits
    CMP.W  #$50C0,D0				;Compare appropriate masked bits
    BEQ     GROUP5_INVALID			;INVALID OP code found
    BNE     CHECK_OP_ADDQ			;Check next OP code

CHECK_OP_ADDQ:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$F100,D0				;Mask appropriate bits
    CMP.W  #$5000,D0				;Compare appropriate masked bits
    BEQ    GROUP5_INVALID			;INVALID OP code found
    BNE    CHECK_OP_SUBQ			;Check next OP code

*Supported OP code   
CHECK_OP_SUBQ     
    MOVE.W  CUR_OP_CODE,D0  		;Actual check for SUBQ
    ANDI.W #$F100,D0        		;Bitmask check for SUBQ
    CMP.W  #$5100,D0        		;Compare the proper value
    BNE    GROUP5_INVALID       	;Else the operand is invalid
    JSR    FIND_2_BIT_SIZE_7_TO_6	;Find size bit to print
    JSR    PRINT_OP_SUBQ    		;If equal print it out
    BRA    GROUP5_SUCCESS   		;Finish routine
    
GROUP5_INVALID: 
    JSR INVALID_OP          		;INVALID OP has been found, set IS_VALID to 0
GROUP5_SUCCESS:
    MOVEM.L (SP)+,D0        		;Restore registers from stack
    RTS                     		;Return to stack
    
* GROUP_6
********************************************************************************
* Supported OP codes
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
* Unsupported OP code: BSR
********************************************************************************
C_GROUP_6:
    MOVEM.L D0,-(SP)        	;Save register to stack
*Unsupported OP code
CHECK_OP_BSR:
    MOVE.W  CUR_OP_CODE,D0		;Move current instruction set to D0
    ANDI.W  #$FF00,D0			;Mask appropriate bits
    CMP.W   #$6100,D0			;Compare masked bits
    BEQ     GROUP6_INVALID		;INVALID OP code found
    BNE     CHECK_OP_BGT		;Check next OP code
    
CHECK_OP_BGT:
    MOVE.W CUR_OP_CODE,D0   	;Move current instruction set into D0
    ANDI.W #$FF00,D0			;Mask appropriate bits
    CMP.W  #$6E00,D0 			;Compare masked bits
    BEQ    GROUP6_INVALID       ;INVALID OP code found
    BNE    CHECK_OP_BCC         ;Check next OP code

CHECK_OP_BCC:
    MOVE.W CUR_OP_CODE,D0   	;Move current instruction set into D0
    ANDI.W #$FF00,D0			;Mask appropriate bits
    CMP.W  #$6400,D0 			;Compare masked bits
    BEQ    GROUP6_INVALID       ;INVALID OP code found
    BNE    CHECK_OP_BEQ         ;Check next OP code 

CHECK_OP_BEQ:
    MOVE.W CUR_OP_CODE,D0   	;Move current instruction set into D0
    ANDI.W #$FF00,D0			;Mask appropriate bits
    CMP.W  #$6700,D0 			;Compare masked bits
    BEQ    GROUP6_INVALID       ;INVALID OP code found
    BNE    CHECK_OP_BHI         ;Check next OP code

CHECK_OP_BHI:
    MOVE.W CUR_OP_CODE,D0   	;Move current instruction set into D0
    ANDI.W #$FF00,D0			;Mask appropriate bits
    CMP.W  #$6200,D0 			;Compare masked bits
    BEQ    GROUP6_INVALID       ;INVALID OP code found
    BNE    CHECK_OP_BLS         ;Check next OP code

CHECK_OP_BLS:
    MOVE.W CUR_OP_CODE,D0   	;Move current instruction set into D0
    ANDI.W #$FF00,D0			;Mask appropriate bits
    CMP.W  #$6300,D0 			;Compare masked bits
    BEQ    GROUP6_INVALID       ;INVALID OP code found
    BNE    CHECK_OP_BMI         ;Check next OP code

CHECK_OP_BMI:
    MOVE.W CUR_OP_CODE,D0   	;Move current instruction set into D0
    ANDI.W #$FF00,D0			;Mask appropriate bits
    CMP.W  #$6B00,D0 			;Compare masked bits
    BEQ    GROUP6_INVALID       ;INVALID OP code found
    BNE    CHECK_OP_BNE         ;Check next OP code

CHECK_OP_BNE:
    MOVE.W CUR_OP_CODE,D0   	;Move current instruction set into D0
    ANDI.W #$FF00,D0			;Mask appropriate bits
    CMP.W  #$6600,D0 			;Compare masked bits
    BEQ    GROUP6_INVALID       ;INVALID OP code found
    BNE    CHECK_OP_BPL         ;Check next OP code    

CHECK_OP_BPL:
    MOVE.W CUR_OP_CODE,D0   	;Move current instruction set into D0
    ANDI.W #$FF00,D0			;Mask appropriate bits
    CMP.W  #$6A00,D0 			;Compare masked bits
    BEQ    GROUP6_INVALID       ;INVALID OP code found
    BNE    CHECK_OP_BRA         ;Check next OP code 


*Supported OP codes
CHECK_OP_BRA:
    MOVE.W  CUR_OP_CODE,D0  	;Move current instruction set into D0       
    ANDI.W  #$FF00,D0			;Mask appropriate bits
    CMP.W   #$6000,D0			;Compare masked bits
    BNE     CHECK_OP_BCS		;Check next OP code
    JSR     PRINT_OP_BRA		;Print out OP code
    BRA     GROUP6_SUCCESS		;Finish routine
    
CHECK_OP_BCS:
    MOVE.W CUR_OP_CODE,D0   	;Move current instruction set into D0
    ANDI.W #$FF00,D0			;Mask appropriate bits
    CMP.W  #$6500,D0 			;Compare masked bits
    BNE    CHECK_OP_BGE			;Check next OP code
    JSR    PRINT_OP_BCS			;Print out OP code
    BRA    GROUP6_SUCCESS		;Finish routine

    
CHECK_OP_BGE:
    MOVE.W CUR_OP_CODE,D0	   	;Move current instruction set into D0
    ANDI.W #$FF00,D0			;Mask appropriate bits
    CMP.W  #$6C00,D0 			;Compare masked bits
    BNE    CHECK_OP_BLT			;Check next OP code
    JSR    PRINT_OP_BGE			;Print out OP code
    BRA    GROUP6_SUCCESS		;Finish routine
    
    
CHECK_OP_BLT:
    MOVE.W CUR_OP_CODE,D0   	;Move current instruction set into D0
    ANDI.W #$FF00,D0			;Mask appropriate bits
    CMP.W  #$6D00,D0 			;Compare masked bits
    BNE    CHECK_OP_BVC			;Check next OP code
    JSR    PRINT_OP_BLT			;Print out OP code
    BRA    GROUP6_SUCCESS		;Finish routine
    
CHECK_OP_BVC:
    MOVE.W CUR_OP_CODE,D0   	;Move current instruction set into D0
    ANDI.W #$FF00,D0			;Mask appropriate bits
    CMP.W  #$6800,D0 			;Compare masked bits
    BNE    GROUP6_INVALID		;Check next OP code
    JSR    PRINT_OP_BVC			;Print out OP code
    BRA    GROUP6_SUCCESS		;Finish routine
    
GROUP6_INVALID:
    JSR    INVALID_OP    		;INVALID OP code found, set IS_VALID to 0
GROUP6_SUCCESS:
    MOVEM.L (SP)+,D0			;Restore registers from stack
    RTS							;Return from stack
    
*GROUP_7
********************************************************************************
* Currently no OP codes here are supported. MOVEQ is the only code in this group
* Unsupported OP code: MOVEQ
********************************************************************************
C_GROUP_7:
    MOVEM.L D0,-(SP)        	;Save register to stack
*Unsupported OP code
CHECK_OP_MOVEQ
    MOVE.W CUR_OP_CODE,D0		;Move current instruction set to D0
    ANDI.W #$F100,D0			;Mask appropriate bits
    CMP.W  #$7000,D0			;Compare masked bits
    BRA    GROUP7_INVALID		;INVALID OP code found

GROUP7_INVALID:
    JSR INVALID_OP				;INVALID OP code found, set IS_VALID to 0
GROUP7_SUCCESS:    
    MOVEM.L (SP)+,D0			;Restore registers from stack
    RTS							;Return from stack
* GROUP_8
********************************************************************************
* Supported OP code:
* DIVS: $8, 11-9 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
* OR: $80, 7-6 Size, 5-3 EA Mode, 2-0 EA Register
* Unsupported OP codes: DIVU, SBCD
********************************************************************************
C_GROUP_8:
    MOVEM.L D0,-(SP)
*Unsupported OP codes
CHECK_OP_DIVU:
    MOVE.W  CUR_OP_CODE,D0   			;Move current instruction set into D0
    ANDI.W  #$F1C0,D0					;Mask appropriate bits
    CMP.W   #$80C0,D0					;Compare masked bits
    BEQ     GROUP8_INVALID				;INVALID OP code found
    BNE     CHECK_OP_SBCD 				;Check next OP code

CHECK_OP_SBCD:
    MOVE.W  CUR_OP_CODE,D0   			;Move current instruction set into D0
    ANDI.W  #$F1F0,D0					;Mask appropriate bits
    CMP.W   #$8100,D0					;Compare masked bits
    BEQ     GROUP8_INVALID				;INVALID OP code found
    BNE     CHECK_OP_DIVS				;Check next OP code
    
*Supported OP codes
CHECK_OP_DIVS:
    MOVE.W  CUR_OP_CODE,D0   			;Move current instruction set into D0
    ANDI.W  #$F1C0,D0					;Mask appropriate bits
    CMP.W   #$81C0,D0					;Compare masked bits
    BNE     CHECK_OP_OR					;Check next OP code
    JSR     PRINT_OP_DIVS				;OP Code found
    BRA     GROUP8_SUCCESS
CHECK_OP_OR:              				;At this point only remaining $8 code is OR
    JSR     FIND_2_BIT_SIZE_7_TO_6		;Finding size bit to print out
    JSR     PRINT_OP_OR					;Print out OR
    BRA     GROUP8_SUCCESS				;Finish routine
GROUP8_INVALID:
     JSR     INVALID_OP					;INVALID OP code found, set IS_VALID to 0
GROUP8_SUCCESS:
     MOVEM.L (SP)+,D0					;Restore register from stack
     RTS								;Return to stack
     
* GROUP_9                      
********************************************************************************
* Supported OP code:
* SUB: $9, 11-9 Reg, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* Unsupported OP codes: SUBX, SUBA
********************************************************************************
C_GROUP_9:
    MOVEM.L D0-D1,-(SP)     			;Save the registers
*Unsupported OP codes
CHECK_SIZE_BIT_FOR_SUB:
    JSR     FIND_2_BIT_SIZE_7_TO_6      ;Find the size bits in 7-6
    CMP.B   #%11,OP_SIZE                ;If the bits are %11, it has to be SUBA
    BEQ     CHECK_OP_SUBA               ;If the bits equal it must be SUBA
    BNE     CHECK_OP_SUBX               ;If the bits are not equal it could be SUBX
    
CHECK_OP_SUBA:             				;Check SUBA first as it has static bits
    MOVE.W  CUR_OP_CODE,D0    			;Move current instruction set into D0
    ANDI.W  #$F0C0,D0					;Mask appropriate bits
    CMP.W   #$90C0,D0					;Compare masked bits
    BEQ     GROUP9_INVALID			    ;INVALID OP has been found
    BNE     CHECK_OP_SUBX				;Check next OP

CHECK_OP_SUBX:
    MOVE.W  CUR_OP_CODE,D0    			;Move current instruction set into D0
    ANDI.W  #$F130,D0					;Mask appropriate bits
    CMP.W   #$9100,D0					;Compare masked bits
    BRA     BIT_CHECK_SUBX				;Checking if this code is SUBX through bit shifts
    
BIT_CHECK_SUBX:    
    MOVE.W  CUR_OP_CODE,D0      		;Move current instruction set into D0
    MOVE.W  #7,D1               		;Prepare a shift of 7 bits into D1
    LSL.W   D1,D0               		;Shift left 7 bits truncate 15-9 bits
    LSR.W   D1,D0               		;Reposition D0
    LSR.W   #4,D0               		;Truncate 4 right most bits to
    ANDI.W  #$FF13,D0           		;Compare remaining static bits
    CMP.W   #$0010,D0           		;If equal to this value it's SUBX
    BEQ     GROUP9_INVALID      		;INVALID OP code found
    BNE     CHECK_OP_SUB        		;Not can only be SUB here
    
*Supported OP code 
CHECK_OP_SUB:                   		;At this point only remaining $9 is SUB
    JSR     FIND_2_BIT_SIZE_7_TO_6		;Find the size bit to print out
    JSR     PRINT_OP_SUB				;Print out SUB
    BRA     GROUP9_SUCCESS				;Finish routine
    
GROUP9_INVALID:
     JSR     INVALID_OP					;INVALID OP code found, set IS_VALID to 0
GROUP9_SUCCESS: 
    MOVEM.L (SP)+,D0-D1         		;Restore registers
    RTS                         		;Return to stack

*GROUP_A
********************************************************************************
* Currently no OP codes here are supported. There are no current OP codes here.
********************************************************************************
C_GROUP_A:
    JSR INVALID_OP						;INVALID OP code found, set IS_VALID to 0
    RTS									;Return to stack
    
* GROUP_B                     
********************************************************************************
* Supported OP codes:
* EOR: $B, 11-9 Reg, 8 %1, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* CMP: $B, 11-9 Reg, 8 %0, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* The specific bit difference is listed 
* Unsupported OP codes: CMPM, CMPA
********************************************************************************
C_GROUP_B:
    MOVEM.L D0,-(SP)         			;Save current registers to stack
*Unsupported OP codes    
CHECK_OP_CMPM
    MOVE.W  CUR_OP_CODE,D0    			;Move current instruction set into D0
    ANDI.W  #$F138,D0					;Mask appropriate bits
    CMP.W   #$B108,D0					;Compare masked bits
    BEQ     GROUPB_INVALID				;INVALID OP found
    BNE     CHECK_OP_CMPA				;Check next OP
    
CHECK_OP_CMPA:
    MOVE.W  CUR_OP_CODE,D0    			;Move current instruction set into D0
    ANDI.W  #$F0C0,D0					;Mask appropriate bits
    CMP.W   #$B0C0,D0					;Compare masked bits
    BEQ     GROUPB_INVALID				;INVALID OP found
    BNE     CHECK_OP_EOR				;Check next OP

*Supported OP codes    
CHECK_OP_EOR:
    MOVE.W  CUR_OP_CODE,D0    			;Move current instruction set into D0
    ANDI.W  #$F100,D0					;Mask appropriate bits
    CMP.W   #$B100,D0					;Compare masked bits
    BNE     CHECK_OP_CMP				;Check next OP 
    JSR     FIND_2_BIT_SIZE_7_TO_6		;Find size bit field to print out size
    JSR     PRINT_OP_EOR				;Print out OP code
    BRA     GROUPB_SUCCESS				;Finish routine
    
CHECK_OP_CMP:
    MOVE.W  CUR_OP_CODE,D0    			;Move current instruction set into D0
    ANDI.W  #$F100,D0					;Mask appropriate bits
    CMP.W   #$B000,D0					;Compare masked bits
    BNE     GROUPB_INVALID				;INVALID OP code found
    JSR     FIND_2_BIT_SIZE_7_TO_6		;Find size bit field to print out size
    JSR     PRINT_OP_CMP				;Print out OP code
    BRA     GROUPB_SUCCESS				;Finish routine
    
GROUPB_INVALID:
    JSR     INVALID_OP           		;INVALID OP has been found, set IS_VALID to 0
GROUPB_SUCCESS:
    MOVEM.L (SP)+,D0         			;Restore registers from stack
    RTS                      			;Return to stack
* GROUP_C                     
********************************************************************************
* Supported OP code:
* MULS: $C, 11-8 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
* Note: EXG OP mode has to be 01000, 01001, 10001, as such can never be 11 for
* bits 7-6
* Unsupported OP codes: MULU, ABCD, EXG, AND
********************************************************************************
C_GROUP_C:
*Unsupported OP codes
    MOVEM.L D0-D1,-(SP)
    
CHECK_OP_MULU:
    MOVE.W  CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W  #$F1C0,D0
    CMP.W   #$C0C0,D0
    BEQ     GROUPC_INVALID
    BNE     CHECK_OP_ABCD
 
CHECK_OP_ABCD:
    MOVE.W  CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W  #$F1F0,D0
    CMP.W   #$C100,D0
    BEQ     GROUPC_INVALID
    BNE     CHECK_OP_EXG
 
CHECK_OP_EXG:
    BRA     BIT_CHECK_EXG       ;Always do bit check here
                        
BIT_CHECK_EXG:                 ;Checks the OP mode bits 7-6 which cannot be 11 for EXG
    MOVE.W  CUR_OP_CODE,D0
    MOVE.W  #7,D1
    LSL.W   D1,D0
    LSR.W   D1,D0
    LSR.W   #4,D0
    ANDI.W  #$FF83,D0
    CMP.W   #$0010,D0          ;Bit mask static EXG bits
    BEQ     GROUPC_INVALID     ;If this equals, then OP must be EXG
    BNE     CHECK_OP_MULS      ;Otherwise it's MULS
*Supported OP code
CHECK_OP_MULS:
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F1C0,D0
    CMP.W  #$C1C0,D0
    BNE    CHECK_OP_AND          ; OP_AND is completely dynamic outside of first nibble
    JSR    PRINT_OP_MULS
    BRA    GROUPC_SUCCESS
*Odd completely dynamic unsupported OP code    
CHECK_OP_AND:                 ;This would be the only possible OP code left after CHECK_OP_MULS
    MOVE.W  CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W  #$F000,D0
    CMP.W   #$C000,D0
    BRA    GROUPC_INVALID    
    
GROUPC_INVALID:
    JSR     INVALID_OP
    
GROUPC_SUCCESS:
    MOVEM.L (SP)+,D0-D1
    RTS
    
* GROUP_D                     
********************************************************************************
* Supported OP codes:
* ADD: $D, 11-9 Reg, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* ADDA: $D, 11- 9 Reg, 8-6 OPMODE, 7-6 %11, 5-3 EA Mode, 2-0 EA Reg
* The specific bit difference is listed out in the OPMODE field.
* Unsupported: ADDX
********************************************************************************
C_GROUP_D:
    MOVEM.L D0,-(SP)        		;Save registers to stack
*Unsupported OP codes
BIT_SIZE_CHECK
    MOVE    CUR_OP_CODE,D0          ;Move current instruction set into D0
    JSR     FIND_2_BIT_SIZE_7_TO_6  ;Specific size bit checking to see if it's 11
    CMP.B   #%11,OP_SIZE            ;If it's %11 it cannot be ADDX and is either ADDA or ADD
    BEQ     CHECK_OP_ADDA           ;If it's equal check ADDA
    BNE     CHECK_OP_ADDX           ;If it's not equal check ADDX
    
CHECK_OP_ADDX:
    MOVE    CUR_OP_CODE,D0
    ANDI.W #$F130,D0				;Mask appropriate bits
    CMP.W  #$D100,D0				;Compare masked bits
    BEQ    GROUPD_INVALID			;INVALID OP code found
    BNE    CHECK_OP_ADD 			;Check next OP code
    
*Supported OP codes
CHECK_OP_ADD:
    JSR PRINT_OP_ADD        		;Only remaining OP in $D is ADD at this point
    BRA GROUPD_SUCCESS              ;Finish routine

CHECK_OP_ADDA:
    MOVE    CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$F0C0,D0				;Mask applicable bits
    CMP.W  #$D0C0,D0				;Compare masked bits
    BNE    CHECK_OP_ADD				;Check next OP code
    JSR    FIND_1_BIT_SIZE_8		;Size bit to print
    JSR    PRINT_OP_ADDA			;Print out OP code
    BRA    GROUPD_SUCCESS			;Finish routine
    
GROUPD_INVALID:
    JSR INVALID_OP                  ;INVALID OP code found
GROUPD_SUCCESS:
    MOVEM.L (SP)+,D0        		;Restore registers from stack
    RTS                     		;Return to stack
    
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
* Split into ROT and NO_ROT groups first to make identifying easier.
* Unsupported: ROXL, ROXR
********************************************************************************
C_GROUP_E:
    MOVEM.L D0,-(SP)
*Unsupported OP codes
CHECK_OP_ROXR_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FFC0,D0
    CMP.W  #$E4C0,D0
    BEQ    GROUPE_INVALID
    BNE    CHECK_OP_ROXL_NO_ROT

CHECK_OP_ROXL_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FFC0,D0
    CMP.W  #$E5C0,D0
    BEQ    GROUPE_INVALID
    BNE    CHECK_OP_ROR_NO_ROT

*Supported OP codes
CHECK_OP_ROR_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FFC0,D0
    CMP.W  #$E6C0,D0
    BNE    CHECK_OP_ROL_NO_ROT
    JSR    PRINT_OP_ROR
    BRA    GROUPE_SUCCESS
    
CHECK_OP_ROL_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FFC0,D0
    CMP.W  #$E7C0,D0
    BNE    CHECK_OP_LSR_NO_ROT
    JSR    PRINT_OP_ROL
    BRA    GROUPE_SUCCESS
 
CHECK_OP_LSR_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FFC0,D0
    CMP.W  #$E2C0,D0
    BNE    CHECK_OP_LSL_NO_ROT
    JSR    PRINT_OP_LSR
    BRA    GROUPE_SUCCESS

CHECK_OP_LSL_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FFC0,D0
    CMP.W  #$E3C0,D0
    BNE    CHECK_OP_ASR_NO_ROT
    JSR    PRINT_OP_LSL
    BRA    GROUPE_SUCCESS

CHECK_OP_ASR_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FFC0,D0
    CMP.W  #$E0C0,D0
    BNE    CHECK_OP_ASL_NO_ROT
    JSR    PRINT_OP_ASR
    BRA    GROUPE_SUCCESS
            
CHECK_OP_ASL_NO_ROT:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FFC0,D0
    CMP.W  #$E1C0,D0
    BNE    CHECK_OP_ROXR
    JSR    PRINT_OP_ASL
    BRA    GROUPE_SUCCESS

*Unsupported OP codes
CHECK_OP_ROXR:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E010,D0
    BEQ    GROUPE_INVALID
    BNE    CHECK_OP_ROXL
    
CHECK_OP_ROXL:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E110,D0
    BEQ    GROUPE_INVALID
    BNE    CHECK_OP_ROR
    
*Supported OP codes
CHECK_OP_ROR:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E018,D0
    BNE    CHECK_OP_ROL
    JSR    FIND_2_BIT_SIZE_7_TO_6     
    JSR    PRINT_OP_ROR
    BRA    GROUPE_SUCCESS

CHECK_OP_ROL:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E118,D0
    BNE    CHECK_OP_LSR
    JSR    FIND_2_BIT_SIZE_7_TO_6     
    JSR    PRINT_OP_ROL
    BRA    GROUPE_SUCCESS
    
CHECK_OP_LSR:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E008,D0
    BNE    CHECK_OP_LSL
    JSR    FIND_2_BIT_SIZE_7_TO_6     
    JSR    PRINT_OP_LSR
    BRA    GROUPE_SUCCESS

CHECK_OP_LSL:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E108,D0
    BNE    CHECK_OP_ASR
    JSR    FIND_2_BIT_SIZE_7_TO_6     
    JSR    PRINT_OP_LSL
    BRA    GROUPE_SUCCESS

CHECK_OP_ASR:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E000,D0
    BNE    CHECK_OP_ASL
    JSR    FIND_2_BIT_SIZE_7_TO_6     
    JSR    PRINT_OP_ASR
    BRA    GROUPE_SUCCESS

CHECK_OP_ASL:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E100,D0
    BNE    GROUPE_INVALID      ;Last possible OP code
    JSR    FIND_2_BIT_SIZE_7_TO_6     
    JSR    PRINT_OP_ASL
    BRA    GROUPE_SUCCESS

GROUPE_INVALID:
    JSR     INVALID_OP
GROUPE_SUCCESS:
    MOVEM.L (SP)+,D0
    RTS
* GROUP_F
********************************************************************************
* Currently no OP codes here are supported. There are no OP codes here
********************************************************************************
C_GROUP_F:
    JSR INVALID_OP
    RTS
    
* INVALID_OP                     
********************************************************************************
* Any value that is not covered in the above groups would be considered invalid. 
* The following values in the first nibble would also indicate that the 
* operand codes is already invalid: $7, $A, $F.
* For unsupported OP codes, display DATA $WXYZ   
* THIS WILL NEED TO BE CHANGED TO DISPLAY: 1000 DATA $WXYZ IN THE FUTURE
********************************************************************************
INVALID_OP:  ; ONLY SETS IS_VALID TO 0
    MOVE.B #0,IS_VALID
    RTS

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

* Prints the loaded item into G_BUFFER
PRINT_TO_BUFFER:
    MOVE.L #G_BUFFER, Arg_AddStrToBuffer_Buffer
    JSR AddStrToBuffer
    RTS
    
****************************** GROUP 0 **************************************** 
PRINT_OP_ORI:
    MOVE.L #P_OP_ORI, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_CMPI:
    MOVE.L #P_OP_CMPI, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_STATIC_BCLR:
    MOVE.L #P_OP_BCLR, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
	
PRINT_OP_DYNAMIC_BCLR:
    MOVE.L #P_OP_BCLR, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
******************************* END OF GROUP 0 ********************************

****************************** GROUP 1 ****************************************    
PRINT_OP_MOVEB:
    MOVE.L #P_OP_MOVEB, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS
******************************* END OF GROUP 1 ********************************
    
****************************** GROUP 2 **************************************** 
PRINT_OP_MOVEA_L:
    MOVE.L #P_OP_MOVEA_L, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS
PRINT_OP_MOVE_L:
    MOVE.L #P_OP_MOVE_L, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS
******************************* END OF GROUP 2 ********************************
    
****************************** GROUP 3 ****************************************    
PRINT_OP_MOVEA_W:
    MOVE.L #P_OP_MOVEA_W, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS
PRINT_OP_MOVE_W:
    MOVE.L #P_OP_MOVE_W, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS
******************************* END OF GROUP 3 ********************************

****************************** GROUP 4 ****************************************
PRINT_OP_JSR:
    MOVE.L #P_OP_JSR, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS
PRINT_OP_RTS:
    MOVE.L #P_OP_RTS, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS
PRINT_OP_NOP:
    MOVE.L #P_OP_NOP, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS
PRINT_OP_LEA:
    MOVE.L #P_OP_LEA, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_NEG:
    MOVE.L #P_OP_NEG, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_MOVEM_W:
    MOVE.L #P_OP_MOVEM_W, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS
PRINT_OP_MOVEM_L:
    MOVE.L #P_OP_MOVEM_L, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS
******************************* END OF GROUP 4 ********************************
    
****************************** GROUP 5 ****************************************
PRINT_OP_SUBQ:
    MOVE.L #P_OP_SUBQ, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
******************************* END OF GROUP 5 ********************************

****************************** GROUP 6 ****************************************
PRINT_OP_BCS:
    MOVE.L #P_OP_BCS, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_BGE:
    MOVE.L #P_OP_BGE, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_BLT:
    MOVE.L #P_OP_BLT, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_BVC:
    MOVE.L #P_OP_BVC, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_BRA:
    MOVE.L #P_OP_BRA, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
******************************* END OF GROUP 6 ********************************

****************************** GROUP 7 ****************************************
* No currently supported OP codes to print here.
******************************* END OF GROUP 7 ********************************

****************************** GROUP 8 ****************************************
PRINT_OP_DIVS:
    MOVE.L #P_OP_DIVS, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS
PRINT_OP_OR:
    MOVE.L #P_OP_OR, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
******************************* END OF GROUP 8 ********************************

****************************** GROUP 9 ****************************************
PRINT_OP_SUB:
    MOVE.L #P_OP_SUB, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
******************************* END OF GROUP 9 ********************************

****************************** GROUP A ****************************************
* No currently supported OP codes to print here.
******************************* END OF GROUP A ********************************

****************************** GROUP B ****************************************
PRINT_OP_EOR:
    MOVE.L #P_OP_EOR, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_CMP:
    MOVE.L #P_OP_CMP, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
******************************* END OF GROUP B ********************************

****************************** GROUP C ****************************************
PRINT_OP_MULS:
    MOVE.L #P_OP_MULS, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS
******************************* END OF GROUP C ********************************

****************************** GROUP D ****************************************
PRINT_OP_ADD:
    MOVE.L #P_OP_ADD, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_ADDA:
    MOVE.L #P_OP_ADDA, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_ADDA
    RTS

******************************* END OF GROUP D ********************************

****************************** GROUP E ****************************************
PRINT_OP_LSL:
    MOVE.L #P_OP_LSL, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_LSR:
    MOVE.L #P_OP_LSR, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_ASR:
    MOVE.L #P_OP_ASR, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_ASL:
    MOVE.L #P_OP_ASL, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_ROL:
    MOVE.L #P_OP_ROL, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
PRINT_OP_ROR:
    MOVE.L #P_OP_ROR, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE
    RTS
******************************* END OF GROUP E ********************************

****************************** GROUP F ****************************************
* No currently supported OP codes to print here.
******************************* END OF GROUP F ********************************

****************************** SIZE PRINTS ************************************
PRINT_SIZE_BYTE:
    MOVE.L #P_SIZE_B, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS    

PRINT_SIZE_WORD:
    MOVE.L #P_SIZE_W, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS
    
PRINT_SIZE_LONG:
    MOVE.L #P_SIZE_L, Arg_AddStrToBuffer_String
    JSR PRINT_TO_BUFFER
    RTS

PRINT_OP_SIZE:                     ;Prints current OP code byte size if applicable
    CMP.B  #%00,OP_SIZE         ;Checks for byte size
    BEQ    PRINT_SIZE_BYTE      ;Print .B to buffer
    CMP.B  #%01,OP_SIZE         ;Check for word size
    BEQ    PRINT_SIZE_WORD      ;Print .W to buffer
    CMP.B  #%10,OP_SIZE         ;Check for long size
    BEQ    PRINT_SIZE_LONG      ;Print .L to buffer
    RTS
    
PRINT_OP_SIZE_ADDA:                  ;Special  print for ADDA
    CMP.B #%0,OP_SIZE
    BEQ    PRINT_SIZE_WORD
    BNE    PRINT_SIZE_LONG
    
******************* END OF SIZE PRINTS ****************************************

******************* END OF PRINTING ROUTINES **********************************

******************* END OF JMP LABELS *****************************************

******************* DATA CONSTANT PRINTS **************************************
* Formatting is as follows: P_OP_<OPCODE>, where P = Print, OP = Operation,
* <OPCODE> is any valid operand

P_INVALID_OP    DC.B    '   DATA   $',0
OP_FOUND        DC.B    'Found OP',0 ; this should be taken out later
P_SIZE_B        DC.B    '.B ',0
P_SIZE_W        DC.B    '.W ',0
P_SIZE_L        DC.B    '.L ',0
P_OP_ORI        DC.B    '   ORI',0
P_OP_CMPI       DC.B    '   CMPI',0
P_OP_BCLR     	DC.B    '   BCLR',0
P_OP_MOVEB      DC.B    '   MOVE.B ',0
P_OP_MOVEA_L    DC.B    '   MOVEA.L ',0 
P_OP_MOVE_L     DC.B    '   MOVE.L ',0
P_OP_MOVEA_W    DC.B    '   MOVEA.W ',0
P_OP_MOVE_W     DC.B    '   MOVE.W ',0
P_OP_MOVEM_W    DC.B    '   MOVEM.W ',0
P_OP_MOVEM_L    DC.B    '   MOVEM.L ',0
P_OP_LEA        DC.B    '   LEA',0
P_OP_JSR        DC.B    '   JSR',0
P_OP_NOP        DC.B    '   NOP',0
P_OP_RTS        DC.B    '   RTS',0
P_OP_NEG        DC.B    '   NEG',0
P_OP_SUBQ       DC.B    '   SUBQ',0
P_OP_BRA        DC.B    '   BRA',0
P_OP_BCS        DC.B    '   BCS',0
P_OP_BGE        DC.B    '   BGE',0
P_OP_BLT        DC.B    '   BLT',0
P_OP_BVC        DC.B    '   BVC',0
P_OP_DIVS       DC.B    '   DIVS.W ',0
P_OP_OR         DC.B    '   OR',0
P_OP_SUB        DC.B    '   SUB',0
P_OP_EOR        DC.B    '   EOR',0
P_OP_CMP        DC.B    '   CMP',0
P_OP_MULS       DC.B    '   MULS.W ',0
P_OP_ADDA       DC.B    '   ADDA',0
P_OP_ADD        DC.B    '   ADD',0
P_OP_LSR        DC.B    '   LSR',0
P_OP_LSL        DC.B    '   LSL',0
P_OP_ASR        DC.B    '   ASR',0
P_OP_ASL        DC.B    '   ASL',0
P_OP_ROR        DC.B    '   ROR',0
P_OP_ROL        DC.B    '   ROL',0
***************** END OF DATA CONSTANT PRINTS ***********************************
 













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
