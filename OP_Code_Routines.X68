*-----------------------------------------------------------
* Title      : OP Code routines for Disassembler
* Written by : Daniel Yan
* Date       : 2/28/2019, Updated 3/12/2019

* Description: Disassembler routines to identify any valid
* OP code dependent on current supported list.
*------------------------------------------------------------
  ORG $1000 ; Start at Address $1000
CUR_OP_CODE DS.W 1  ; Current OP Code Word
IS_VALID    DS.B 1  ; Tells if the current OP code is valid or not
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
    

START
    LEA G_BUFFER,A4
    MOVE.B #0, (A4)
    
    ;MOVE.L (A5)+, D0
************** BUFFER PRINTING/LOADING EXAMPLES *************************************
    ; Load the message onto A4
    ;MOVE.L #P_OP_MOVEA_L_T, Arg_AddStrToBuffer_String
    ;MOVE.L #G_BUFFER, Arg_AddStrToBuffer_Buffer 
    ;JSR AddStrToBuffer
    ;LEA G_BUFFER, A4   ; Load the value of the message onto the G_BUFFER
    ;MOVE.L P_OP_MOVEA_L_T,(A4)+
    ;MOVE.L P_OP_MOVEA_L_A_L,(A4)+
    
***************************** Input Tests ********************************************
    ***GROUP 0 tests**** SUPPORTED: ORI, BCLR (static, dynamic), CMPI
    ;MOVE.W #%0000000000111100,CUR_OP_CODE      ;ORI TO CCR              SHOULD FAIL
    ;MOVE.W #%0000000001111100,CUR_OP_CODE      ;ORI TO SR               SHOULD FAIL
    ;MOVE.W #%0000000010000101,CUR_OP_CODE      ;ORI.W D5                SHOULD PASS
    ;MOVE.W #%0000001001111100,CUR_OP_CODE      ;ANDI TO CCR             SHOULD FAIL
    ;MOVE.W #%0000001001111100,CUR_OP_CODE      ;ANDI TO SR              SHOULD FAIL
    ;MOVE.W #%0000001010000101,CUR_OP_CODE      ;ANDI.W D5               SHOULD FAIL
    ;MOVE.W #%0000010010000101,CUR_OP_CODE      ;SUBI.W D5               SHOULD FAIL
    ;MOVE.W #%0000011010000101,CUR_OP_CODE      ;ADDI.W D5               SHOULD FAIL
    ;MOVE.W #%0000101000111100,CUR_OP_CODE      ;EORI TO CCR             SHOULD FAIL
    ;MOVE.W #%0000101001111100,CUR_OP_CODE      ;EORI TO SR              SHOULD FAIL
    ;MOVE.W #%0000101010000101,CUR_OP_CODE      ;EORI.W D5               SHOULD FAIL
    ;MOVE.W #%0000110010000101,CUR_OP_CODE      ;CMPI.L D5               SHOULD PASS
    ;MOVE.W #%0000100000000101,CUR_OP_CODE      ;STATIC BTST. B D5       SHOULD FAIL
    ;MOVE.W #%0000100001000101,CUR_OP_CODE      ;STATIC BCHG .B D5       SHOULD FAIL
    ;MOVE.W #%0000100010000101,CUR_OP_CODE      ;STATIC BCL R D5         SHOULD PASS
    ;MOVE.W #%0000100011000101,CUR_OP_CODE      ;STATIC BS ET.B D5       SHOULD FAIL
    ;MOVE.W #%0000111100000101,CUR_OP_CODE      ;DYNAMIC BTST.B D7,D5    SHOULD FAIL
    ;MOVE.W #%0000111101000101,CUR_OP_CODE      ;DYNAMIC BCHG.B,D7,D5    SHOULD FAIL
    ;MOVE.W #%0000101110000111,CUR_OP_CODE      ;DYNAMIC BCLR.B D7,D5    SHOULD PASS
    ;MOVE.W #%0000111111000101,CUR_OP_CODE      ;DYNAMIC BSET.B D7,D5    SHOULD FAIL
    ;MOVE.W #%0000111111001101,CUR_OP_CODE      ;MOVEP.L MEM TO REG, A5  SHOULD FAIL, MADE A SPECIAL CASE FOR DYNAMIC BSET BIT SHIFTING
        
    ***GROUP 1 tests**** SUPPORTED: MOVE.B
    ;MOVE.W #%0001101000000111,CUR_OP_CODE       ;MOVE.B D5,D7           SHOULD PASS
    
    ***GROUP 2 tests**** SUPPORTED: MOVEA.L, MOVE.L
    ;MOVE.W #%0010101000000111,CUR_OP_CODE       ;MOVE.L D5,D7           SHOULD PASS
    ;MOVE.W #%0010101001000111,CUR_OP_CODE       ;MOVEA.L D5,D7          SHOULD PASS
        
    ***GROUP 3 tests**** SUPPORTED: MOVEA.W, MOVE.W
    ;MOVE.W #%0011101000000111,CUR_OP_CODE       ;MOVE.W D5,D7           SHOULD PASS
    ;MOVE.W #%0011101001000111,CUR_OP_CODE       ;MOVEA.W D5,D7          SHOULD PASS
    
    ****GROUP 4 tests**** SUPPORTED: LEA, JSR, RTS, NEG, MOVEM  
    ;MOVE.W #%0100000011000101,CUR_OP_CODE       ;MOVE_FROM_SR           SHOULD FAIL
    ;MOVE.W #%0100010011000101,CUR_OP_CODE       ;MOVE_TO_CCR            SHOULD FAIL
    ;MOVE.W #%0100011011000101,CUR_OP_CODE       ;MOVE_TO_SR             SHOULD FAIL
    ;MOVE.W #%0100000010000101,CUR_OP_CODE       ;NEGX                   SHOULD FAIL
    ;MOVE.W #%0100001010000101,CUR_OP_CODE       ;CLR                    SHOULD FAIL
    ;MOVE.W #%0100010001000101,CUR_OP_CODE       ;NEG                    SHOULD PASS
    ;MOVE.W #%0100011010000101,CUR_OP_CODE       ;NOT                    SHOULD FAIL
    ;MOVE.W #%0100100011000101,CUR_OP_CODE       ;EXT                    SHOULD FAIL
    ;MOVE.W #%0100100000000101,CUR_OP_CODE       ;NBCD                   SHOULD FAIL
    ;MOVE.W #%0100100001000101,CUR_OP_CODE       ;SWAP                   SHOULD FAIL
    ;MOVE.W #%0100100001000101,CUR_OP_CODE       ;PEA                    SHOULD FAIL
    ;MOVE.W #%0100101011111100,CUR_OP_CODE       ;ILLEGAL                SHOULD FAIL
    ;MOVE.W #%0100101011000101,CUR_OP_CODE       ;TAS                    SHOULD FAIL
    ;MOVE.W #%0100101010000101,CUR_OP_CODE       ;TST                    SHOULD FAIL
    ;MOVE.W #%0100111001000111,CUR_OP_CODE       ;TRAP                   SHOULD FAIL
    ;MOVE.W #%0100111001010101,CUR_OP_CODE       ;LINK                   SHOULD FAIL
    ;MOVE.W #%0100111001011101,CUR_OP_CODE       ;UNLK                   SHOULD FAIL
    ;MOVE.W #%0100111001101101,CUR_OP_CODE       ;MOVE_USP               SHOULD FAIL
    ;MOVE.W #%0100111001110000,CUR_OP_CODE       ;RESET                  SHOULD FAIL
    ;MOVE.W #%0100111001110001,CUR_OP_CODE       ;NOP                    SHOULD FAIL
    ;MOVE.W #%0100111001110010,CUR_OP_CODE       ;STOP                   SHOULD FAIL
    ;MOVE.W #%0100111001110011,CUR_OP_CODE       ;RTE                    SHOULD FAIL
    ;MOVE.W #%0100111001110101,CUR_OP_CODE       ;RTS                    SHOULD PASS
    ;MOVE.W #%0100111001110110,CUR_OP_CODE       ;TRAPV                  SHOULD FAIL
    ;MOVE.W #%0100111001110111,CUR_OP_CODE       ;RTR                    SHOULD FAIL
    ;MOVE.W #%0100111010000101,CUR_OP_CODE       ;JSR                    SHOULD PASS
    ;MOVE.W #%0100111011000101,CUR_OP_CODE       ;JMP                    SHOULD FAIL
    ;MOVE.W #$488E,CUR_OP_CODE                   ;MOVEM.W Reg to Mem,A6  SHOULD PASS
    ;MOVE.W #$4C8E,CUR_OP_CODE                   ;MOVEM.W Mem to Reg,A6  SHOULD PASS
    ;MOVE.W #$43CC,CUR_OP_CODE                   ;LEA A1,A6              SHOULD PASS
    ;MOVE.W #%0100000110000101,CUR_OP_CODE       ;CHK                    SHOULD FAIL
    ;MOVE.W #$4E75,CUR_OP_CODE                   ;RTS                    SHOULD PASS
    ;MOVE.W #$4E71,CUR_OP_CODE                   ;NOP                    SHOULD FAIL
    ;MOVE.W #$4415,CUR_OP_CODE                   ;NEG.L D5               SHOULD PASS
   
    *****GROUP 5 TESTS**** SUPPORTED: SUBQ
    ;MOVE.W #%0101110010000101,CUR_OP_CODE        ;ADDQ                  SHOULD FAIL
    ;MOVE.W #%0101110110000101,CUR_OP_CODE        ;SUBQ                  SHOULD PASS
    ;MOVE.W #%0101101011000101,CUR_OP_CODE        ;Scc (SPL)             SHOULD FAIL
    ;MOVE.W #%0101101011001101,CUR_OP_CODE         ;DBcc (DCPL)          SHOULD FAIL
       
    *****GROUP 6 TESTS********* SUPPORTED: BCS,BGE,BLT,BVC
    ; DISPLACEMENT, $00 is 16 bits, $FF is 32 bits
    ; DISPLACEMENT = Last 8 bits
    ;MOVE.W #%0110000001010101,CUR_OP_CODE   ;BRA                        SHOULD PASS
    ;MOVE.W #%0110000110101010,CUR_OP_CODE   ;BSR                        SHOULD FAIL
    ;MOVE.W #%0110010100000001,CUR_OP_CODE   ;BCS                        SHOULD PASS
    ;MOVE.W #%0110110001010100,CUR_OP_CODE   ;BGE                        SHOULD PASS
    ;MOVE.W #%0110110110101010,CUR_OP_CODE   ;BLT                        SHOULD PASS
    ;MOVE.W #%0110100001010100,CUR_OP_CODE   ;BVC                        SHOULD PASS
    
    *****GROUP 7 TESTS********** NONE SUPPORTED
    ;MOVE.W #%0111101011110000,CUR_OP_CODE   ;MOVEQ                      SHOULD FAIL
    
    *****GROUP 8 TESTS********** SUPPORTED: DIVS, OR
    ;MOVE.W #%1000101011000101,CUR_OP_CODE    ;DIVU                      SHOULD FAIL
    ;MOVE.W #%1000101111000110,CUR_OP_CODE    ;DIVS                      SHOULD PASS
    ;MOVE.W #%1000101100001111,CUR_OP_CODE    ;SBCD                      SHOULD FAIL
    ;MOVE.W #%1000110101000101,CUR_OP_CODE    ;OR                        SHOULD PASS
            
    *****GROUP 9 TESTS********** SUPPORTED: SUB
    ;MOVE.W #%1001101100000101,CUR_OP_CODE    ;SUB                       SHOULD PASS
    ;MOVE.W #%1001000110001101,CUR_OP_CODE    ;SUBX                      SHOULD FAIL
    ;MOVE.W #%1001101011001101,CUR_OP_CODE    ;SUBA                      SHOULD FAIL
    
    *****GROUP A TESTS********** NONE SUPPORTED
    
    *****GROUP B TESTS********** SUPPORTED: EOR, CMP
    *MOVE.W #%1011101101000110,CUR_OP_CODE    ;EOR                       SHOULD PASS
    *MOVE.W #%1011110101001101,CUR_OP_CODE    ;CMPM                      SHOULD FAIL
    *MOVE.W #%1011010001000101,CUR_OP_CODE    ;CMP                       SHOULD PASS
    *MOVE.W #%1011110011000101,CUR_OP_CODE    ;CMPA                      SHOULD FAIL
    
    *****GROUP C TESTS********** SUPPORTED: MULS
    ;MOVE.W #%1100101011000110,CUR_OP_CODE    ;MULU                      SHOULD FAIL
    ;MOVE.W #%1100101111000101,CUR_OP_CODE    ;MULS                      SHOULD PASS
    ;MOVE.W #%1100101100000101,CUR_OP_CODE    ;ABCD                      SHOULD FAIL
    ;MOVE.W #%1100101110001110,CUR_OP_CODE    ;EXG                       SHOULD FAIL
    ;MOVE.W #%1100101001000101,CUR_OP_CODE    ;AND                       SHOULD FAIL   
     
    *****GROUP D TESTS********** SUPPORTED: ADD, ADDA
    ;MOVE.W #%1101101101000101,CUR_OP_CODE    ;ADDX                      SHOULD FAIL
    ;MOVE.W #%1101101011001101,CUR_OP_CODE    ;ADDA                      SHOULD FAIL
    ;MOVE.W #%1101101001001101,CUR_OP_CODE    ;ADD                       SHOULD PASS
    
    *****GROUP E TESTS********** SUPPORTED: LSX, ASX, ROX
    ;MOVE.W #%1110000011000101,CUR_OP_CODE    ;ASR NO_ROT                SHOULD PASS
    ;MOVE.W #%1110000111000101,CUR_OP_CODE    ;ASL NO_ROT                SHOULD PASS
    ;MOVE.W #%1110001011000101,CUR_OP_CODE    ;LSR NO_ROT                SHOULD PASS
    ;MOVE.W #%1110001111000101,CUR_OP_CODE    ;LSL NO_ROT                SHOULD PASS
    ;MOVE.W #%1110010011000101,CUR_OP_CODE    ;ROXR NO_ROT               SHOULD FAIL
    ;MOVE.W #%1110010111000101,CUR_OP_CODE    ;ROXL NO_ROT               SHOULD FAIL
    ;MOVE.W #%1110011011000101,CUR_OP_CODE    ;ROR NO_ROT                SHOULD PASS
    ;MOVE.W #%1110011111000101,CUR_OP_CODE    ;ROL NO_ROT                SHOULD PASS    
    
    ;MOVE.W #%1110000001000101,CUR_OP_CODE    ;ASR                       SHOULD PASS
    ;MOVE.W #%1110000101000101,CUR_OP_CODE    ;ASL                       SHOULD PASS
    ;MOVE.W #%1110001001001101,CUR_OP_CODE    ;LSR                       SHOULD PASS
    ;MOVE.W #%1110001101001101,CUR_OP_CODE    ;LSL                       SHOULD PASS
    ;MOVE.W #%1110010001010101,CUR_OP_CODE    ;ROXR                      SHOULD FAIL
    ;MOVE.W #%1110010101010101,CUR_OP_CODE    ;ROXL                      SHOULD FAIL
    ;MOVE.W #%1110011001011101,CUR_OP_CODE    ;ROR                       SHOULD PASS
    ;MOVE.W #%1110011101011101,CUR_OP_CODE    ;ROL                       SHOULD PASS    
        
    
    *****GROUP F TESTS********** NONE SUPPORTED
    
    
    
************************************************************************************
* PRINTING BUFFER FUNCTION HAS BEEN FINISHED
* STATUS: 
* IDENTIFICATION FOR ALL OP CODES: 		DONE
* VALIDATION TESTING FOR ALL OP CODES: 	DONE
* PRINTING ALL OP CODES TO BUFFER: 		NOT DONE
* PRINTING SIZE BITS OF ALL OP CODES: 	NOT DONE
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
LOAD_OP_CODE:
    MOVE.W CUR_OP_CODE,D0
    MOVE.B #1,IS_VALID
    JSR OP_JSR_Routine      	   ;Use the JSR routine to identify the op code
	
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
    BNE CHECK_OP_ANDI          		;Check next routine


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

BIT_CHECK_MOVEP:
									;This is a special case check for MOVEP
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
    JSR     PRINT_OP_ORI            ;Print the OP code if equal    
    BRA     GROUP0_SUCCESS          ;Finish routine
    
CHECK_OP_CMPI:
    MOVE.W  CUR_OP_CODE,D0          ;Move current instruction set into D0
    ANDI.W  #$FF00,D0               ;Mask relevant bits to D0
    CMP.W   #$0C00,D0               ;Compare the appropriate masked bits   
    BNE     CHECK_OP_STATIC_BCLR    ;Branch to next comparison if not equal       
    JSR     PRINT_OP_CMPI           ;Print the OP code if equal
    BRA     GROUP0_SUCCESS          ;Finish routine
    
CHECK_OP_STATIC_BCLR:
    MOVE.W  CUR_OP_CODE,D0          ;Move current instruction set into D0
    ANDI.W  #$FF00,D0               ;Mask relevant bits to D0
    CMP.W   #$0800,D0               ;Compare the appropriate masked bits
    BNE     CHECK_OP_DYNAMIC_BCLR   ;Branch to next comparison if not equal
    JSR     PRINT_OP_STATIC_BCLR    ;Print the OP code if equal
    BRA     GROUP0_SUCCESS          ;Finish routine
    
CHECK_OP_DYNAMIC_BCLR:
    MOVE.W  CUR_OP_CODE,D0          ;Move current instruction set into D0
    ANDI.W  #$0180,D0   			;Mask relevant bits to D0
    CMP.W   #$0180,D0   			;Compare the appropriate masked bits
    BNE     GROUP0_INVALID          ;If not equal this must be an invalid OP code
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
    MOVEM.L (SP)+,D0-D1             ;Restore register
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
    BNE    CHECK_OP_NOP      		;Check next OP code
    
CHECK_OP_NOP:
    MOVE.W CUR_OP_CODE,D0   		;Move current instruction set into D0
    CMP.W  #$4E71,D0	     		;Compare the appropriate bits
    BEQ    GROUP4_INVALID 	 		;INVALID OP code found
    BNE    CHECK_OP_ILLEGAL  		;Check next OP code
    
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
    BNE    CHECK_OP_MOVE_FROM   	;Check next OP code_SR


*Unsupported OP codes to check that have partial static bits
CHECK_OP_MOVE_FROM_SR:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask relevant bits to D0
    CMP.W  #$40C0,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code found	
    BNE    CHECK_OP_MOVE_TO_CCR		;Check next OP code_SR
    
CHECK_OP_MOVE_TO_CCR:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask relevant bits to D0
    CMP.W  #$44C0,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code found
    BNE    CHECK_OP_MOVE_TO_SR		;Check next OP code_SR
    
CHECK_OP_MOVE_TO_SR:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask relevant bits to D0
    CMP.W  #$46C0,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code foun
    BNE    CHECK_OP_NEGX			;Check next OP code_S
    
CHECK_OP_NEGX:
    MOVE.W CUR_OP_CODE,D0   		 ;Move current instruction set into D0
    ANDI.W #$FF00,D0				;Mask relevant bits to D0
    CMP.W  #$4000,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code fou
    BNE    CHECK_OP_CLR				;Check next OP code_
    
CHECK_OP_CLR:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FF00,D0				;Mask relevant bits to D0
    CMP.W  #$4200,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code fo
    BNE    CHECK_OP_NOT				;Check next OP code
    
CHECK_OP_NOT:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FF00,D0				;Mask relevant bits to D0
    CMP.W  #$4600,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code f
    BNE    CHECK_OP_EXT				;Check next OP cod
    
CHECK_OP_EXT:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FF80,D0				;Mask relevant bits to D0
    CMP.W  #$4880,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code BIT_CHECK_EXT
    BNE    CHECK_OP_NBCD			;Check next OP cod

BIT_CHECK_EXT:    
    MOVE.W CUR_OP_CODE,D0    		;This is a special case to check against MOVEM
    MOVE.W #10,D1
    LSL.W  D1,D0
    LSR.W  D0,D0
    LSR.W  #3,D0
    CMP.W  %000,D0
    BEQ    GROUP4_INVALID  			;This means that this OP code is EXT
    BNE    CHECK_OP_MOVEM   	    ;This is the only other possibility 
    
CHECK_OP_NBCD:
    MOVE.W CUR_OP_CODE,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0			
    CMP.W  #$4800,D0
    BEQ    GROUP4_INVALID
    BNE    CHECK_OP_SWAP
    
CHECK_OP_SWAP:                  ; This must go before CHECK_OP PEA as first 3 nibbles can be equivalent
    MOVE.W CUR_OP_CODE,D0       ;Move current instruction set into D0
    ANDI.W #$FF48,D0
    CMP.W  #$4840,D0
    BEQ    GROUP4_INVALID
    BNE    CHECK_OP_PEA
 
CHECK_OP_PEA:               ; This must go after CHECK_OP_SWAP as first 3 nibbles can be equivalent
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FF40,D0
    CMP.W  #$4840,D0
    BEQ    GROUP4_INVALID
    BNE    CHECK_OP_TAS
    
CHECK_OP_TAS:
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FFC0,D0
    CMP.W  #$4AC0,D0
    BEQ    GROUP4_INVALID
    BNE    CHECK_OP_TST

CHECK_OP_TST:               ; This must go after CHECK_OP_TAS as first 2 nibbles are equivalent
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FF00,D0
    CMP.W  #$4A00,D0
    BEQ    GROUP4_INVALID
    BNE    CHECK_OP_TRAP
    
CHECK_OP_TRAP:
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FFF0,D0
    CMP.W  #$4E40,D0
    BEQ    GROUP4_INVALID
    BNE    CHECK_OP_LINK
    
CHECK_OP_LINK:
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FFF8,D0
    CMP.W  #$4E50,D0
    BEQ    GROUP4_INVALID
    BNE    CHECK_OP_UNLK

CHECK_OP_UNLK:
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FFF8,D0
    CMP.W  #$4E58,D0
    BEQ    GROUP4_INVALID
    BNE    CHECK_OP_MOVE_USP
    
CHECK_OP_MOVE_USP:
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$FFF0,D0
    CMP.W  #$4E60,D0
    BEQ    GROUP4_INVALID
    BNE    CHECK_OP_JMP

CHECK_OP_JMP:
     MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
     ANDI.W #$FFC0,D0
     CMP.W  #$4EC0,D0
     BEQ    GROUP4_INVALID
     BNE    CHECK_OP_CHK
     
CHECK_OP_CHK:
    MOVE.W  CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W  #$F1C0,D0
    CMP.W   #$4180,D0
    BEQ     INVALID_OP
    BNE     CHECK_OP_RTS

*Supported OP codes to check
CHECK_OP_RTS:
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    CMP.W  #$4E75,D0
    BNE    CHECK_OP_LEA
    JSR    PRINT_OP_RTS
    BRA    GROUP4_SUCCESS              ;Finish routine
 
CHECK_OP_LEA:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$F1C0,D0
    CMP.W  #$41C0,D0
    BNE    CHECK_OP_JSR
    JSR    PRINT_OP_LEA
    BRA    GROUP4_SUCCESS              ;Finish routine
 
CHECK_OP_JSR:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$FFC0,D0
    CMP.W  #$4E80,D0
    BNE    CHECK_OP_NEG
    JSR    PRINT_OP_JSR
    BRA    GROUP4_SUCCESS              ;Finish routine
    
CHECK_OP_NEG:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$FF00,D0
    CMP.W  #$4400,D0
    BNE    CHECK_OP_MOVEM
    JSR    PRINT_OP_NEG
    BRA    GROUP4_SUCCESS              ;Finish routine

    
**************** COME BACK TO FINISH UP SIZE **********************************
CHECK_OP_MOVEM:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$FB80,D0
    CMP.W  #$4880,D0
    BNE    INVALID_OP       ;If no code is found, it is invalid
    JSR    PRINT_OP_MOVEM_W
    BRA    GROUP4_SUCCESS
    
GROUP4_INVALID:
    JSR INVALID_OP

GROUP4_SUCCESS:
    MOVEM.L (SP)+,D0 
    RTS
* GROUP_5
********************************************************************************
* Supported OP code:
* SUBQ: $5, 11-9 DATA, 8 %1, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
* Unsupported OP codes: ADDQ, Scc, DBcc
* Validation checking:
* Check against, ADDQ, Scc, DBcc
********************************************************************************
C_GROUP_5:
    MOVEM.L D0,-(SP)         ;Save registers to stack
*Unsupported OP codes
CHECK_OP_DBcc:               ;These are ordered first due to checking bits 7-6
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F0C8,D0
    CMP.W  #$50C8,D0
    BEQ    GROUP5_INVALID
    BNE    CHECK_OP_Scc 

CHECK_OP_Scc:
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F0C0,D0 
    CMP.W  #$50C0,D0
    BEQ     GROUP5_INVALID
    BNE     CHECK_OP_ADDQ

CHECK_OP_ADDQ:
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F100,D0
    CMP.W  #$5000,D0
    BEQ    GROUP5_INVALID
    BNE    CHECK_OP_SUBQ

*Supported OP code   
CHECK_OP_SUBQ     
    MOVE.W  CUR_OP_CODE,D0  ;Actual check for SUBQ
    ANDI.W #$F100,D0        ;Bitmask check for SUBQ
    CMP.W  #$5100,D0        ;Compare the proper value
    BNE    GROUP5_INVALID       ;Else the operand is invalid
    JSR    PRINT_OP_SUBQ    ;If equal print it out
    BRA    GROUP5_SUCCESS   ;Finish routine
    
GROUP5_INVALID: 
    JSR INVALID_OP          ;INVALID OP has been found

GROUP5_SUCCESS:
    MOVEM.L (SP)+,D0        ;Restore registers from stack
    RTS                     ;Return to stack
    
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
    MOVEM.L D0,-(SP)        ;Save register to stack
*Unsupported OP code
CHECK_OP_BSR:
    MOVE.W  CUR_OP_CODE,D0
    ANDI.W  #$FF00,D0
    CMP.W   #$6100,D0
    BEQ     GROUP6_INVALID
    BNE     CHECK_OP_BRA
    
*Supported OP codes
CHECK_OP_BRA:
    MOVE.W  CUR_OP_CODE,D0   ;Move current instruction set into D0       
    ANDI.W  #$FF00,D0
    CMP.W   #$6000,D0
    BNE     CHECK_OP_BCS
    JSR     PRINT_OP_BRA
    BRA     GROUP6_SUCCESS
    
CHECK_OP_BCS:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$FF00,D0
    CMP.W  #$6500,D0 
    BNE    CHECK_OP_BGE
    JSR    PRINT_OP_BCS
    BRA    GROUP6_SUCCESS

    
CHECK_OP_BGE:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$FF00,D0
    CMP.W  #$6C00,D0 
    BNE    CHECK_OP_BLT
    JSR    PRINT_OP_BGE
    BRA    GROUP6_SUCCESS
    
    
CHECK_OP_BLT:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$FF00,D0
    CMP.W  #$6D00,D0 
    BNE    CHECK_OP_BVC
    JSR    PRINT_OP_BLT
    BRA    GROUP6_SUCCESS
    
CHECK_OP_BVC:
    MOVE.W CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W #$FF00,D0
    CMP.W  #$6800,D0 
    BNE    GROUP6_INVALID
    JSR    PRINT_OP_BVC
    BRA    GROUP6_SUCCESS
    
GROUP6_INVALID:
    JSR    INVALID_OP    
        
GROUP6_SUCCESS:
    MOVEM.L (SP)+,D0
    RTS
    
*GROUP_7
********************************************************************************
* Currently no OP codes here are supported. MOVEQ is the only code in this group
* Unsupported OP code: MOVEQ
********************************************************************************
C_GROUP_7:
    MOVEM.L D0,-(SP)        ;Save register to stack
    
CHECK_OP_MOVEQ
    MOVE.W CUR_OP_CODE,D0
    ANDI.W #$F100,D0
    CMP.W  #$7000,D0
    BNE    GROUP7_INVALID
    BEQ    GROUP7_SUCCESS
    
GROUP7_INVALID:
    JSR INVALID_OP
    
GROUP7_SUCCESS:    
    MOVEM.L (SP)+,D0
    RTS
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
    MOVE.W  CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W  #$F1C0,D0
    CMP.W   #$80C0,D0
    BEQ     GROUP8_INVALID
    BNE     CHECK_OP_SBCD 

CHECK_OP_SBCD:
    MOVE.W  CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W  #$F1F0,D0
    CMP.W   #$8100,D0
    BEQ     GROUP8_INVALID
    BNE     CHECK_OP_DIVS
    
*Supported OP codes
CHECK_OP_DIVS:
    MOVE.W  CUR_OP_CODE,D0   ;Move current instruction set into D0
    ANDI.W  #$F1C0,D0
    CMP.W   #$81C0,D0
    BEQ     PRINT_OP_DIVS
    BNE     CHECK_OP_OR
    
CHECK_OP_OR:              ;At this point only remaining $8 code is OR
    JSR     PRINT_OP_OR
    BRA     GROUP8_SUCCESS
GROUP8_INVALID:
     JSR    INVALID_OP
     
GROUP8_SUCCESS:
     MOVEM.L (SP)+,D0
     RTS
     
* GROUP_9                      
********************************************************************************
* Supported OP code:
* SUB: $9, 11-9 Reg, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* Unsupported OP codes: SUBX, SUBA
********************************************************************************
C_GROUP_9:
    MOVEM.L D0-D1,-(SP)     ;Save the registers
CHECK_OP_SUBA:             ;Check SUBA first as it has static bits
    MOVE.W  CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W  #$F0C0,D0
    CMP.W   #$90C0,D0
    BEQ     INVALID_OP
    BNE     CHECK_OP_SUBX

CHECK_OP_SUBX:
    MOVE.W  CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W  #$F130,D0
    CMP.W   #$9100,D0
    BEQ     BIT_CHECK_SUBX
    BNE     GROUP9_INVALID     ;Cannot be a valid OP code here
    
BIT_CHECK_SUBX:    
    MOVE.W  CUR_OP_CODE,D0      ;Move current instruction set into D0
    MOVE.W  #7,D1               ;Prepare a shift of 7 bits into D1
    LSL.W   D1,D0               ;Shift left 7 bits truncate 15-9 bits
    LSR.W   D1,D0               ;Reposition D0
    LSR.W   #4,D0               ;Truncate 4 right most bits to
    ANDI.W  #$FF18,D0           ;Compare remaining static bits
    CMP.W   #$0018,D0           ;If equal to this value it's SUBX
    BEQ     GROUP9_INVALID      ;INVALID OP code found
    BNE     CHECK_OP_SUB        ;Not can only be SUB here
    
CHECK_OP_SUB:                   ;At this point only remaining $9 is SUB
    JMP     PRINT_OP_SUB

GROUP9_INVALID:
    BRA     INVALID_OP
    
GROUP9_SUCCESS:
    MOVEM.L (SP)+,D0-D1         ;Restore registers
    RTS                         ;Return to stack

*GROUP_A
********************************************************************************
* Currently no OP codes here are supported. There are no current OP codes here.
********************************************************************************
C_GROUP_A:
    JSR INVALID_OP
    RTS
    
* GROUP_B                     
********************************************************************************
* Supported OP codes:
* EOR: $B, 11-9 Reg, 8 %1, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* CMP: $B, 11-9 Reg, 8 %0, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* The specific bit difference is listed 
* Unsupported OP codes: CMPM, CMPA
********************************************************************************
C_GROUP_B:
    MOVEM.L D0,-(SP)         ;Save current registers to stack
    
CHECK_OP_CMPM
    MOVE.W  CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W  #$F138,D0
    CMP.W   #$B108,D0
    BEQ     GROUPB_INVALID
    BNE     CHECK_OP_CMPA
    
CHECK_OP_CMPA:
    MOVE.W  CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W  #$F0C0,D0
    CMP.W   #$B0C0,D0
    BEQ     GROUPB_INVALID
    BNE     CHECK_OP_EOR
    
CHECK_OP_EOR:
    MOVE.W  CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W  #$F100,D0
    CMP.W   #$B100,D0
    BEQ     PRINT_OP_EOR
    BNE     CHECK_OP_CMP
    
CHECK_OP_CMP:
    MOVE.W  CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W  #$F100,D0
    CMP.W   #$B000,D0
    BEQ     PRINT_OP_CMP
    BNE     GROUPB_INVALID

GROUPB_INVALID:
    JSR     INVALID_OP           ;INVALID OP has been found 
 
GROUPB_SUCCESS:
    MOVEM.L (SP)+,D0         ;Restore registers from stack
    RTS                      ;Return to stack
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
    MOVE.W  CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W  #$F130,D0
    CMP.W   #$C100,D0
    BEQ     BIT_CHECK_EXG
    BNE     CHECK_OP_AND
                        
BIT_CHECK_EXG:                 ;Checks the OP mode bits 7-6 which cannot be 11 for EXG
    MOVE.W  CUR_OP_CODE,D0
    MOVE.W  #8,D1
    LSL.W   D1,D0
    LSR.W   D1,D0
    LSR.W   #6,D0
    ANDI.W  #$FFF3,D0
    CMP.W   #$0003,D0          ;This bit then equals MULS
    BEQ     CHECK_OP_MULS
    CMP.W   #$0000,D0          ;Second comparison to check if OP mode bit is valid
    BEQ     CHECK_OP_AND       ;If it's 0 it could be OP_AND
    BNE     GROUPC_INVALID         ;Otherwise it's EXG (01,10 op bits)
*Supported OP code
CHECK_OP_MULS:
    MOVE.W CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F1C0,D0
    CMP.W  #$C1C0,D0
    BEQ    PRINT_OP_MULS
    BNE    CHECK_OP_AND          ; OP_AND is completely dynamic outside of first nibble

*Odd completely dynamic unsupported OP code    
CHECK_OP_AND:                 ;This would be the only possible OP code left after CHECK_OP_MULS
    MOVE.W  CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W  #$F000,D0
    CMP.W   #$C000,D0
    BEQ     GROUPC_INVALID
    
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
    MOVEM.L D0,-(SP)        ;Save registers to stack
    
CHECK_OP_ADDX:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F130,D0
    CMP.W  #$D100,D0
    BEQ    GROUPD_INVALID
    BNE    CHECK_OP_ADDA

CHECK_OP_ADDA:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F0C0,D0
    CMP.W  #$D0C0,D0
    BEQ    PRINT_OP_ADDA
    BNE    CHECK_OP_ADD

CHECK_OP_ADD:
    JSR PRINT_OP_ADD        ;Only remaining OP in $D is ADD
    BRA GROUPD_SUCCESS
    
GROUPD_INVALID:
    JSR INVALID_OP
    
GROUPD_SUCCESS:
    MOVEM.L (SP)+,D0        ;Restore registers from stack
    RTS                     ;Return to stack
    
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
    JSR    PRINT_OP_ROR
    BRA    GROUPE_SUCCESS

CHECK_OP_ROL:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E118,D0
    BNE    CHECK_OP_LSR
    JSR    PRINT_OP_ROL
    BRA    GROUPE_SUCCESS
    
CHECK_OP_LSR:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E008,D0
    BNE    CHECK_OP_LSL
    JSR    PRINT_OP_LSR
    BRA    GROUPE_SUCCESS

CHECK_OP_LSL:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E108,D0
    BNE    CHECK_OP_ASR
    JSR    PRINT_OP_LSL
    BRA    GROUPE_SUCCESS

CHECK_OP_ASR:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E000,D0
    BNE    CHECK_OP_ASL
    JSR    PRINT_OP_ASR
    BRA    GROUPE_SUCCESS

CHECK_OP_ASL:
    MOVE CUR_OP_CODE,D0    ;Move current instruction set into D0
    ANDI.W #$F118,D0
    CMP.W  #$E100,D0
    BNE    GROUPE_INVALID      ;Last possible OP code
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
INVALID_OP:  ; Prints DATA for invalid op, THIS SHOULD BE SETTING THE IS_VALID BIT TO 0
    LEA P_INVALID_OP,A1
    MOVE.B #13,D0
    TRAP #15
    MOVE.B #0,IS_VALID
    RTS
    
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
PRINT_OP_STATIC_BCLR:
    LEA P_OP_STATIC_BCLR,A1
    JSR PRINT_OP
    RTS
PRINT_OP_DYNAMIC_BCLR:
    LEA P_OP_DYNAMIC_BCLR,A1
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
P_OP_STATIC_BCLR     DC.B    'BCLR',0
P_OP_DYNAMIC_BCLR     DC.B    'BCLR',0
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
