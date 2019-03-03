*-----------------------------------------------------------
* Title      :
* Written by : Daniel Yan
* Date       : 2/28/2019
* Description: Op code determining process guide through branches/groupings
  ORG $1000 ; Start at Address $1000
*CUR_OP_CODE DS.W 1  ; Current OP Code Word

START ; Start the op code routine


    MOVE.L #$08, D1
    JSR OP_JSR_Routine
*-----------------------------------------------------------
*First Nibble Values (15-12)
*Value                  Operations
*$0                     GROUP_0: ORI,BCLR,CMPI
*$1                     GROUP_1: MOVE.B                   
*$2                     GROUP_2: MOVE.L, MOVEA.L
*$3                     GROUP_3: MOVE.W, MOVEA.W
*$4                     GROUP_4: LEA,JSR,RTS,NEG
*$5                     GROUP_4: INVALID_OP
*$6                     GROUP_6: SUBQ,Bcc, BRA
*$7                     GROUP_7: INVALID_OP
*$8                     GROUP_8: DIVS, OR
*$9                     GROUP_7: SUB
*$A                     GROUP_A: INVALID_OP
*$B                     GROUP_B: EOR, CMP
*$C                     GROUP_C: MULS
*$D                     GROUP_D: ADD, ADDA
*$E                     GROUP_E: LSR, LSL, ASR, ASL, ROL, ROR
*$F                     GROUP_F: INVALID_OP

********************OPCode JSR Routines***************************************
* These valid operand codes refer to the basic supported operand codes
* Groups refer to the first nibble value that is supported by the operand
OP_JSR_Routine:
    MOVEM.L D0, -(SP) ;Backup register D0

GROUP_0:     ;$0| ORI, BCLR, CMPI                    
    CMP.B   #$0,D0
    BNE     GROUP_1
    JSR     C_GROUP_0
    BRA     OP_JSR_DONE
    
GROUP_1:     ;$1| MOVE.B
    CMP.B   #$1,D0
    BNE     GROUP_2
    JSR     C_GROUP_1
    BRA     OP_JSR_DONE

GROUP_2:     ;$2| MOVE.L, MOVEA.L
    CMP.B   #$2,D0
    BNE     GROUP_3
    JSR     C_GROUP_2
    BRA     OP_JSR_DONE

GROUP_3:     ;$3| MOVE.W, MOVEA.W
    CMP.B   #$3,D0
    BNE     GROUP_4
    JSR     C_GROUP_3
    BRA     OP_JSR_DONE

GROUP_4:     ;$4| LEA, JSR, RTS, NEG
    CMP.B   #$4,D0
    BNE     GROUP_5
    JSR     C_GROUP_4
    BRA     OP_JSR_DONE


GROUP_5:     ;$5| SUBQ
    CMP.B   #$5,D0
    BNE     GROUP_6
    JSR     C_GROUP_5
    BRA     OP_JSR_DONE


GROUP_6:     ;$6| Bcc, BRA
    CMP.B   #$6,D0
    BNE     GROUP_7
    JSR     C_GROUP_6
    BRA     OP_JSR_DONE


GROUP_7:     ;$7| Display: DATA, $WXYZ (Unsupported)
    CMP.B   #$7,D0
    BNE     GROUP_8
    JSR     C_GROUP_7
    BRA     OP_JSR_DONE


GROUP_8:     ;$8| DIVS, OR
    CMP.B   #$8,D0
    BNE     GROUP_9
    JSR     C_GROUP_8
    BRA     OP_JSR_DONE


GROUP_9:     ;$9| SUB
    CMP.B   #$9,D0
    BNE     GROUP_A
    JSR     C_GROUP_9
    BRA     OP_JSR_DONE


GROUP_A:     ;$A| Display: DATA, $WXYZ (Unsupported)
    CMP.B   #$A,D0
    BNE     GROUP_B
    JSR     C_GROUP_A
    BRA     OP_JSR_DONE


GROUP_B:     ;$B| EOR, CMP
    CMP.B   #$B,D0
    BNE     GROUP_C
    JSR     C_GROUP_B
    BRA     OP_JSR_DONE


GROUP_C:     ;$C| MULS
    CMP.B   #$C,D0
    BNE     GROUP_D
    JSR     C_GROUP_C
    BRA     OP_JSR_DONE


GROUP_D:     ;$D| ADD, ADDA
    CMP.B   #$D,D0
    BNE     GROUP_E
    JSR     C_GROUP_D
    BRA     OP_JSR_DONE


GROUP_E:     ;$E| LSR, LSL, ASR, ASL, ROL, ROR
    CMP.B   #$E,D0
    BNE     GROUP_F
    JSR     C_GROUP_E
    BRA     OP_JSR_DONE


GROUP_F:     ;$F| Display: DATA, $WXYZ (Unsupported)
    CMP.B   #$F,D0
    JSR     C_GROUP_F
    BRA     OP_JSR_DONE


OP_JSR_DONE:
         MOVEM.L (SP)+,D0 ;Recover register D0
         RTS             ;Return to stack
********************************************************************************

*******************JMP LABELS **************************************************
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
* ORI: $00, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
* CMPI: $0C, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
* BCLR: $0, 11-9 Register, 8-6 %110, 5-3 EA Mode, 2-0 EA Reg
********************************************************************************
C_GROUP_0:
    MOVEM.L D0-D1, -(SP) ; Backup registers
    
check_OP_ORI:
    MOVE.W D1,D0   ;Move current op code to D0
    CMP.W #$00, D0          ;Compare the current op code to ORI
    BNE check_OP_CMPI
    BEQ   PRINT_OP          ;[IN PROG] Print ORI
check_OP_CMPI:
    MOVE.W D1,D0
    CMP.W #$0C, D0   
    BNE check_OP_BCLR       
    BEQ   PRINT_OP
check_OP_BCLR:
    MOVE.W D1,D0
    CMP.W #$08,D0
    BEQ PRINT_OP
    BNE CG0_F
    BRA CG0_C
CG0_F:    
    BRA INVALID_OP    
CG0_C:
    MOVEM.L (SP)+,D0-D1 ; Restore registers
    RTS
* GROUP_1                      
********************************************************************************
* MOVE.B: $1, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
********************************************************************************
C_GROUP_1:

* GROUP_2
********************************************************************************
* MOVEA.L: $2, 11-9 DST Reg, 8-6 %001, 5-3 SRC Mode, 2-0 SRC Reg
* MOVE.L: $2, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
********************************************************************************
C_GROUP_2:

* GROUP_3
********************************************************************************
* MOVEA.W: $3, 11-9 DST Reg, 8-6 %001, 5-3 SRC Mode, 2-0 SRC Reg
* MOVE.W: $3, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
********************************************************************************
C_GROUP_3:

* GROUP_4
********************************************************************************
* LEA: $4, 11-9 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
* JSR: $4E, 7-6 %10, 5-3 EA Mode, 2-0 EA Reg 
* RTS: $4E75
* NEG: $44, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
********************************************************************************
C_GROUP_4:

* GROUP_5
********************************************************************************
* SUBQ: $5, 11-9 DATA, 8 %1, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
********************************************************************************
C_GROUP_5:

* GROUP_6
********************************************************************************
* BRA: $60, 7-0 8-Bit Displacement
* Bcc: $6, 11-8 Condition, 7-0 8-Bit Displacement
********************************************************************************
C_GROUP_6:

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

* GROUP_9                      
********************************************************************************
* SUB: $9, 11-9 Reg, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
********************************************************************************
C_GROUP_9:

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

* GROUP_C                     
********************************************************************************
* MULS: $C, 11-8 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
********************************************************************************
C_GROUP_C:


* GROUP_D                     
********************************************************************************
* ADD: $D, 11-9 Reg, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* ADDA: $D, 11- 9 Reg, 8-6 OPMODE, 7-6 %11, 5-3 EA Mode, 2-0 EA Reg
* The specific bit difference is listed out in the OPMODE field.
********************************************************************************
C_GROUP_D:

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

*GROUP_F
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
********************************************************************************
INVALID_OP:  ; Prints DATA for invalid op
    LEA P_INVALID_OP,A1
    MOVE.B #13,D0
    TRAP #15
    SIMHALT
PRINT_OP:   ;Prints current op code byte
    LEA OP_FOUND,A1
    MOVE.B #13,D0
    TRAP #15
    RTS
    
******************* END OF JMP LABELS ******************************************
P_INVALID_OP    DC.B    'DATA',0
OP_FOUND        DC.B    'Found OP',0 ; this should be taken out later
P_OP_ORI        DC.B    'ORI',0
P_OP_CMPI       DC.B    'CMPI',0
P_OP_BCLR       DC.B    'BCLR',0

    END START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
