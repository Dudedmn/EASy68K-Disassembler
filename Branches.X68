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
*$5                     Unknown
*$6                     GROUP_6: SUBQ,Bcc, BRA
*$7                     Unknown
*$8                     GROUP_7: DIVS, OR
*$9                     SUB
*$A                     Unknown
*$B                     EOR
*$C                     GROUP_C: CMP, MULS
*$D                     GROUP_D: ADD, ADDA
*$E                     GROUP_E: LSR, LSL, ASR, ASL, ROL, ROR
*$F                     Unknown
*%0001 001000010000
*%LEA <an> 111 <xn><mode> -> <an><xn><mode> -> binary
*Need to bitmask (AND, OR, XOR) or bitshift to determine subgroupings
*Reading a starting and ending address are on a word boundary, even passes
*Bit masking

*Checking   0101
*AND        0010
*RESULT     0000


*GROUP_0
*Value                  Operations
*$0                     ORI
*$1                     
*$2
*$3
*$4
*$5
*$6
*$7
*$8                     BCLR
*$9
*$A
*$B
*$C                     CMPI
*$D
*$E
*$F


*GROUP_2
*Value                  Operations
*8-6 bitmask address    MOVEA.L address mode:(001)
*8-6 bitmask address    MOVE.L  
*Everything else is DATA


*GROUP_3
*Value                  Operations



*GROUP_4
*Value                  Operations
*GROUP_6
*Value                  Operations
*GROUP_7
*Value                  Operations
*GROUP_C
*Value                  Operations
*GROUP_D
*Value                  Operations
*GROUP_E
*Value                  Operations


*Second Nibble Values (11-8)
*Value                  Operations
*$0                     ORI
*$1
*$2
*$3
*$4
*$5
*$6
*$7
*$8                     BCLR
*$9
*$A
*$B
*$C                     CMPI
*$D
*$E
*$F
*Third Nibble Values (7-4)
*Value                  Operations
*$0
*$1
*$2
*$3
*$4
*$5
*$6
*$7
*$8
*$9
*$A
*$B
*$C
*$D
*$E
*$F
*Fourth Nibble Values (3-0)
*Value                  Operations
*$0
*$1
*$2
*$3
*$4
*$5
*$6
*$7
*$8
*$9
*$A
*$B
*$C
*$D
*$E
*$F


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
