*-----------------------------------------------------------
* Title      :
* Written by : Daniel Yan
* Date       : 2/28/2019
* Description: Op code determining process guide through branches/groupings
*-----------------------------------------------------------
*First Nibble Values (15-12)
*Value                  Operations
*$0                     GROUP_0: ORI,BCLR,CMPI
*$1                     MOVE.B                   
*$2                     GROUP_2: MOVE.L, MOVEA.L
*$3                     GROUP_3: MOVE.W, MOVEA.W
*$4                     GROUP_4: LEA,JSR,RTS,NEG
*$5                     INVALID_OP
*$6                     GROUP_6: SUBQ,Bcc, BRA
*$7                     INVALID_OP
*$8                     GROUP_8: DIVS, OR
*$9                     SUB
*$A                     INVALID_OP
*$B                     GROUP_B: EOR, CMP
*$C                     GROUP_C: MULS
*$D                     GROUP_D: ADD, ADDA
*$E                     GROUP_E: LSR, LSL, ASR, ASL, ROL, ROR
*$F                     INVALID_OP

********************JMP TABLE FOR OPERATIONS************************************
* These valid operand codes refer to the basic supported operand codes
* Groups refer to the first nibble value that is supported by the operand
Opcode_JMP_Table    JMP     GROUP_0     ;$0| ORI, BCLR, CMPI
                    JMP     OP_MOVE_B   ;$1| MOVE.B
                    JMP     GROUP_2     ;$2| MOVE.L, MOVEA.L
                    JMP     GROUP_3     ;$3| MOVE.W, MOVEA.W
                    JMP     GROUP_4     ;$4| LEA, JSR, RTS, NEG
                    JMP     OP_SUBQ     ;$5| SUBQ
                    JMP     GROUP_6     ;$6| Bcc, BRA
                    JMP     GROUP_8     ;$8| DIVS, OR
                    JMP     OP_SUB      ;$9| SUB
                    JMP     GROUP_B     ;$B| EOR, CMP
                    JMP     GROUP_C     ;$C| MULS
                    JMP     GROUP_D     ;$D| ADD, ADDA
                    JMP     GROUP_E     ;$E| LSR, LSL, ASR, ASL, ROL, ROR
                    JMP     INVALID_OP  ;$7, $A, $F -- Display: DATA, $WXYZ
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
GROUP_0

* OP_MOVE_B                      
********************************************************************************
* MOVE.B: $1, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
********************************************************************************
OP_MOVE_B

* GROUP_2
********************************************************************************
* MOVEA.L: $2, 11-9 DST Reg, 8-6 %001, 5-3 SRC Mode, 2-0 SRC Reg
* MOVE.L: $2, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
********************************************************************************
GROUP_2

* GROUP_3
********************************************************************************
* MOVEA.W: $3, 11-9 DST Reg, 8-6 %001, 5-3 SRC Mode, 2-0 SRC Reg
* MOVE.W: $3, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
********************************************************************************
GROUP_3

* GROUP_4
********************************************************************************
* LEA: $4, 11-9 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
* JSR: $4E, 7-6 %10, 5-3 EA Mode, 2-0 EA Reg 
* RTS: $4E75
* NEG: $44, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
********************************************************************************
GROUP_4

OP_SUBQ
********************************************************************************
* SUBQ: $5, 11-9 DATA, 8 %1, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
********************************************************************************

* GROUP_6
********************************************************************************
* BRA: $60, 7-0 8-Bit Displacement
* Bcc: $6, 11-8 Condition, 7-0 8-Bit Displacement
********************************************************************************
GROUP_6

* GROUP_8
********************************************************************************
* DIVS: $8, 11-9 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
* OR: $80, 7-6 Size, 5-3 EA Mode, 2-0 EA Register
********************************************************************************
GROUP_8

* OP_SUB                      
********************************************************************************
* SUB: $9, 11-9 Reg, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
********************************************************************************
OP_SUB

* GROUP_B                     
********************************************************************************
* EOR: $B, 11-9 Reg, 8 %1, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* CMP: $B, 11-9 Reg, 8 %0, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* The specific bit difference is listed 
********************************************************************************
GROUP_B

* GROUP_C                     
********************************************************************************
* MULS: $C, 11-8 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
********************************************************************************
GROUP_C


* GROUP_D                     
********************************************************************************
* ADD: $D, 11-9 Reg, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* ADDA: $D, 11- 9 Reg, 8-6 OPMODE, 7-6 %11, 5-3 EA Mode, 2-0 EA Reg
* The specific bit difference is listed out in the OPMODE field.
********************************************************************************
GROUP_D

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
GROUP_E


* INVALID_OP                     
********************************************************************************
* Any value that is not covered in the above groups would be considered invalid, 
* the following values in the first nibble would also indicate that the operand 
* codes is already invalid.
* $7, $A, $F -- Display DATA $WXYZ   
********************************************************************************
INVALID_OP  
******************* END OF JMP LABELS ******************************************

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
