*-----------------------------------------------------------
* Title      :Test File
* Written by : Fahad Alshehri
* Date       :
* Description:
*-----------------------------------------------------------

    ORG $9000
    ;ADDQ.B      #8,$8000
    ;AND.W       $00004900,D6   ;investigate
    
    MOVEQ.L     #122,D1    

    ADD.L   D2,D1
    
    ADD.W   D1,$8000
    
    ADD.B   (A2),D1
    
	ADD.W   D3,(A7)

    ADD.B   (A5)+,D7

    ADD.L   D4,(A3)+

    ADD.W   -(A1),D3  
	
	ADD.B   D1,-(A5)
   
    ADDA.L      #18,A7

    ADDA.W      #199,A5

    ADDA.L      D1,A2

    ADDA.W      D2,A1

    ADDA.W      A1,A2

    ADDA.L      A1,A6

    ADDA.W      (A1),A2

    ADDA.L      -(A1),A6

    ADDA.W      (A1)+,A2

    ADDA.W      #$8000,A4

    ADDA.L      #$8000,A4

    ADDA.W      A1,A2

    ADDA.L      A1,A6       

    ADDQ.B      #1,D6

    ADDQ.W      #2,D6

    ADDQ.L      #4,D6    

    ADDQ.W      #2,A2

    ADDQ.L      #4,A5    

    ADDQ.B      #1,(A3)

    ADDQ.W      #2,(A3)+

    ADDQ.L      #4,-(A3)

    ADDQ.W      #3,$4000

    AND.W       D0,D1

    AND.B       D0,D1

    AND.L       D7,D1

    AND.L       D2,$00004000

    AND.W       D3,$00014000

    AND.B       D1,$00011000

    AND.L       $00004000,D2

    AND.B       $00004A00,D1 

    AND.W       D1,(A3)

    AND.B      (A7),D7

    AND.W       D1,-(A3)

    AND.L      -(A7),D7

    AND.L      D1,(A3)+

    AND.W       (A7)+,D7

    DIVU         D1,D2

    DIVU         $00000011,D6

    DIVU         (A0),D0

    DIVU         -(A0),D0   

    DIVU         (A0)+,D0

    DIVU         $0001000,D1

    DIVU         $8000,D1

    BRA     $A100

    BRA     $A029

    *Negative 8 bit displacement
    BRA     $9F86

    BRA     $9FF4

    BRA     $A004

    
    *Positive 8 bit displacement
    BRA     $A029

    BRA     $A085

    BRA     $A010

    BRA     $A08F
   
    LSL.W     $00FF0000

    LSL.W     $20(a0)

    LSL.W    (a0)+

    LSL.W     -(a0)

    
    LSR.W     $00080000

    LSR.W     $20(a0)

    LSR.W    (a0)+

    LSR.W     -(a0)

    ASL.W     $230000

    ASL.W     $20(a0)

    ASL.W    (a0)+

    ASL.W     -(a0)
	
    ASR.W     $AA0000

    ASR.W     $20(a0)

    ASR.W    (a0)+

    ASR.W     -(a0)
    
    LSL.W     $4000
 
    MOVE.B      #19,(A1)

    MOVE.L      #12,-(A1)

    MOVE.W      #1982,(A1)+

    MOVE.B      #19,D3

    MOVE.L      #12,D2

    MOVE.W      #1982,D1

    MOVE.W      #$19AA,D1 
        
    MOVEA.L      #18,A7

    MOVEA.W      #199,A5

    MOVEA.L      D1,A2

    MOVEA.W      D2,A1

    MOVEA.W      A1,A2

    MOVEA.L      A1,A6

    MOVEA.W      (A1),A2

    MOVEA.L      -(A1),A6

    MOVEA.W      (A1)+,A2

    MOVEA.W     #19,A3

    MOVEA.L     #1944,A5

    MOVEA.W      A1,A2

    MOVEA.L      A1,A6

    MOVEM.W   A1-A7,-(A1)

    MOVEM.L   D1-D7,-(A1)

    MOVEM.W   A1/D7,-(A1)

    MOVEM.L   A1/D7,-(A1)

    MOVEM.W   A1-A7,(A1)
 
    MOVEQ.L     #122,D1

    MOVEQ.L     #11,D2

    MOVEQ.L     #111,D3

    MOVEQ.L     #101,D7

    MOVEQ.L     #12,D2

    MULS         D1,D2

    MULS         $00000011,D6

    MULS         (A1),D0

    MULS         -(A5),D2   

    MULS         (A0)+,D1

    MULS         $0001000,D4

    MULS         $8000,D3 

    NOT.B   D0

    NOT.W   D1

    NOT.L   D2

    NOT.B   (A0)

    NOT.W   -(A0)

    NOT.L   (A0)+ 

    NOT     $8000

    NOT.W   $4000
     
    OR.W       D0,D1

    OR.B       D0,D1

    OR.L       D7,D1

    OR.L       D2,$4000

    OR.W       D3,$00014000

    OR.B       D1,$00011000

    OR.L       $5000,D2

    OR.W       $6900,D6

    OR.B       $4A00,D1 

    OR.W       D1,(A3)

    OR.B      (A7),D7

    OR.W       D1,-(A3)

    OR.L      -(A7),D7

    OR.W       D1,(A3)+

    OR.L      (A7)+,D7 
        
    LSL.B   #2,D3

    LSL.W   #8,D2

    LSL.L   #7,D1

    LSR.B   D2,D3

    LSR.W   D1,D2

    LSR.L   D7,D1

    ASL.B   #2,D3

    ASL.W   #8,D2

    ASL.L   #7,D1

    ASR.B   D2,D3

    ASR.W   D1,D2

    ASL.L   D7,D1

    SUB.L   D2,D1

    SUB.W   D1,$8000

    SUB.B   (A2),D1

    SUB.W   D3,(A7)

    SUB.B   (A5)+,D7

    SUB.L   D4,(A3)+

    SUB.W   -(A1),D3

    SUB.B   D1,-(A5)
 
    LSL.W (A1)+         ;finished testing
    
    MULS.W (A0),D1      ;finished testing
    
    SUB.L D1,(A1)+      ;finished testing
    
    SUB.L D1,A1         ;finished testing
    
    SUB.L D1,(A1)       ;finished testing
    
    SUB.L D1,-(A1)      ;finished  testing
    
    SUB.W D1,A1         ;finished  testing
    
    ADDA.L D1,A2        ;finishtes testing

    LSR.L #$1,D1        ; CHECK THIS Prints #$1,A1 instead of #$,D1    
        
    SUBQ.B #$1,D1       ; CHECK THIS Prints #$2,D1 instead of #$1,D1
     
    LSL.B #3,D1         ; CHECK THIS Prints #3,A1 instead of #3,D1
    
    SUBQ.B #$1,D1       ; CHECK THIS Prints #$2,D1 instead of #$1,D1

    BCLR.L #$3,D1       ; CHECK THIS Prints #$57,D1 instead of #$3,D1
    
    ;LSR.W #$1,D1        ; This doesn't show up if it's placed right after BCLR    
    ;LSL.W #$1,D1        ; This doesn't show up if it's placed right after BCLR    
    
    ;ASL.B  D3,D5     
    ;ASR.W  D3,D5
    ORI.W #$2501, D1
     
    ROL.L  D3,D5     
   
    ROR.L  D3,D5     
    OR.L (SP),D2
    
    OR.W D1,(A0)+
    
    NOP
    
    RTS
    
    NOP
    
    RTS
    
    ORI.W #$2501, D1
    
    SUBQ.B  #1,D0
    
    SUBQ.W  #$2, D1
    
    SUBQ.L  #4,D2
    
    LEA     (A0),A0
    
    LEA     (A1),A0
    
    LEA     $0100,A0
    
    LEA     $9300,A0
    
    LEA     (A5),A0

    LEA     (A7),A0

    LEA     (A0),A7

    LEA     (A5),A7

    LEA     (A7),A7

    CLR.B     D0

    CLR.B     D7

    CLR.W     D0

    CLR.W     D7

    CLR.L     D0

    CLR.L     D7

    CLR.B     (A0)

    CLR.B     (A7)

    CLR.W     (A0)

    CLR.W     (A7)

    CLR.L     (A0)

    CLR.L     (A7)

    CLR.B     (A0)+

    CLR.B     (A7)+

    CLR.W     (A0)+

    CLR.W     (A7)+

    CLR.L     (A0)+

    CLR.L     (A7)+

    CLR.B     -(A0)

    CLR.B     -(A7)

    CLR.W     -(A0)

    CLR.W     -(A7)

    CLR.L     -(A0)

    CLR.L     -(A7)

    MOVE.B    D0,D1

    MOVE.B    D0,(A0)

    MOVE.B    D0,(A0)+

    MOVE.B    D0,-(A0)

    MOVE.B    (A0),D0

    MOVE.B    (A0),(A1)

    MOVE.B    (A0),(A1)+

    MOVE.B    (A0),-(A1)

    MOVE.B    (A0)+,D0

    MOVE.B    (A0)+,(A1)

    MOVE.B    (A0)+,(A1)+

    MOVE.B    (A0)+,-(A1)

    MOVE.B    -(A0),D0

    MOVE.B    -(A0),(A1)

    MOVE.B    -(A0),(A1)+

    MOVE.B    -(A0),-(A1)

    MOVE.W    D0,D1

    MOVE.W    D0,(A0)

    MOVE.W    D0,(A0)+

    MOVE.W    D0,-(A0)

    MOVE.W    A0,D0

    MOVE.W    A0,(A1)

    MOVE.W    A0,(A1)+

    MOVE.W    A0,-(A1)

    MOVE.W    (A0),D0

    MOVE.W    (A0),(A1)

    MOVE.W    (A0),(A1)+

    MOVE.W    (A0),-(A1)

    MOVE.W    (A0)+,D0

    MOVE.W    (A0)+,(A1)

    MOVE.W    (A0)+,(A1)+

    MOVE.W    (A0)+,-(A1)

    MOVE.W    -(A0),D0

    MOVE.W    -(A0),(A1)

    MOVE.W    -(A0),(A1)+

    MOVE.W    -(A0),-(A1)

    MOVE.L    D0,D1

    MOVE.L    D0,(A0)

    MOVE.L    D0,(A0)+

    MOVE.L    D0,-(A0)

    MOVE.L    A0,D0

    MOVE.L    A0,(A1)

    MOVE.L    A0,(A1)+

    MOVE.L    A0,-(A1)

    MOVE.L    (A0),D0

    MOVE.L    (A0),(A1)

    MOVE.L    (A0),(A1)+

    MOVE.L    (A0),-(A1)

    MOVE.L    (A0)+,D0

    MOVE.L    (A0)+,(A1)

    MOVE.L    (A0)+,(A1)+

    MOVE.L    (A0)+,-(A1)

    MOVE.L    -(A0),D0

    MOVE.L    -(A0),(A1)

    MOVE.L    -(A0),(A1)+

    MOVE.L    -(A0),-(A1)

    MOVEA.W    D0,A0

    MOVEA.W    A0,A0

    MOVEA.W    (A0),A0

    MOVEA.W    (A0)+,A0

    MOVEA.W    -(A0),A0

    MOVEA.L    D0,A0

    MOVEA.L    A0,A0

    MOVEA.L    (A0),A0

    MOVEA.L    (A0)+,A0

    MOVEA.L    -(A0),A0  

    ADD.B     D1,D2

    ADD.B     D1,(A1)

    ADD.B     D1,(A1)+

    ADD.B     D1,-(A1)

    ADD.B     (A1),D1

    ADD.B     (A1)+,D1

    ADD.B     -(A1),D1

    ADD.W     D1,D2

    ADD.W     D1,(A1)

    ADD.W     D1,(A1)+

    ADD.W     D1,-(A1)

    ADD.W     (A1),D1

    ADD.W     (A1)+,D1

    ADD.W     -(A1),D1

    ADD.L     D1,D2

    ADD.L     D1,(A1)

    ADD.L     D1,(A1)+

    ADD.L     D1,-(A1)

    ADD.L     (A1),D1

    ADD.L     (A1)+,D1

    ADD.L     -(A1),D1

    ADDA.W        D1,A2

    ADDA.W        (A1),A2

    ADDA.W        (A1)+,A2

    ADDA.W        -(A1),A2

    ADDA.L        D1,A2

    ADDA.L        (A1),A2

    ADDA.L        (A1)+,A2

    ADDA.L        -(A1),A2
   
    SUB.B     D1,D2

    SUB.B     D1,(A1)

    SUB.B     D1,(A1)+

    SUB.B     D1,-(A1)

    SUB.B     (A1),D1

    SUB.B     (A1)+,D1

    SUB.B     -(A1),D1

    SUB.W     D1,D2

    SUB.W     D1,A1

    SUB.W     D1,(A1)

    SUB.W     D1,(A1)+

    SUB.W     D1,-(A1)

    SUB.W     A1,D1

    SUB.W     (A1),D1

    SUB.W     (A1)+,D1

    SUB.W     -(A1),D1

    SUB.L     D1,D2

    SUB.L     D1,A1

    SUB.L     D1,(A1)

    SUB.L     D1,(A1)+

    SUB.L     D1,-(A1)

    SUB.L     A1,D1

    SUB.L     (A1),D1

    SUB.L     (A1)+,D1

    SUB.L     -(A1),D1    

    MULS.W    D0,D1

    MULS.W    (A0),D1

    MULS.W    -(A0),D1

    MULS.W    (A0)+,D1

    DIVS.W    D0,D1

    DIVS.W    (A0),D1

    DIVS.W    -(A0),D1

    DIVS.W    (A0)+,D1

    AND.B     D1,D2

    AND.B     D1,(A1)

    AND.B     D1,(A1)+

    AND.B     D1,-(A1)

    AND.B     (A1),D1

    AND.B     (A1)+,D1

    AND.B     -(A1),D1

    AND.W     D1,D2

    AND.W     D1,(A1)

    AND.W     D1,(A1)+

    AND.W     D1,-(A1)

    AND.W     (A1),D1

    AND.W     (A1)+,D1

    AND.W     -(A1),D1

    AND.L     D1,D2

    AND.L     D1,(A1)

    AND.L     D1,(A1)+

    AND.L     D1,-(A1)

    AND.L     (A1),D1

    AND.L     (A1)+,D1

    AND.L     -(A1),D1
    
    EOR.B      D1,D2
    
    EOR.B      D2,(A1)

    OR.B     D1,D2

    OR.B     D1,(A1)

    OR.B     D1,(A1)+

    OR.B     D1,-(A1)

    OR.B     (A1),D1

    OR.B     (A1)+,D1

    OR.B     -(A1),D1

    OR.W     D1,D2

    OR.W     D1,(A1)

    OR.W     D1,(A1)+

    OR.W     D1,-(A1)

    OR.W     (A1),D1

    OR.W     (A1)+,D1

    OR.W     -(A1),D1

    OR.L     D1,D2

    OR.L     D1,(A1)

    OR.L     D1,(A1)+

    OR.L     D1,-(A1)

    OR.L     (A1),D1

    OR.L     (A1)+,D1

    OR.L     -(A1),D1

    LSL.B     D1,D2

    LSL.W     D1,D2

    LSL.W     (A1)

    LSL.W     (A1)+

    LSL.W     -(A1)

    LSL.L     D1,D2

    LSR.B     D1,D2

    LSR.W     D1,D2

    LSR.W     (A1)

    LSR.W     (A1)+

    LSR.W     -(A1)

    LSR.L     D1,D2    

    ASR.B     D1,D2

    ASR.W     D1,D2

    ASR.W     (A1)

    ASR.W     (A1)+

    ASR.W     -(A1)

    ASR.L     D1,D2

    ASL.B     D1,D2

    ASL.W     D1,D2

    ASL.W     (A1)

    ASL.W     (A1)+

    ASL.W     -(A1)

    ASL.L     D1,D2

    ROL.B     D1,D2

    ROL.W     D1,D2

    ROL.W     (A1)

    ROL.W     (A1)+

    ROL.W     -(A1)

    ROL.L     D1,D2

    ROR.B     D1,D2

    ROR.W     D1,D2

    ROR.W     (A1)

    ROR.W     (A1)+

    ROR.W     -(A1)

    ROR.L     D1,D2    

    CMP.B    D0,D1

    CMP.B    (A0),D1

    CMP.B    -(A0),D1

    CMP.B    (A0)+,D1

    CMP.W    D0,D1

    CMP.W    A0,D1

    CMP.W    (A0),D1

    CMP.W    -(A0),D1

    CMP.W    (A0)+,D1

    CMP.L    D0,D1

    CMP.L    A0,D1

    CMP.L    (A0),D1

    CMP.L    -(A0),D1

    CMP.L    (A0)+,D1
    
    BRA       lss      

lss BCC.B     label1

    BCC.B     label2

    BGT.B     label1

    BGT.B     label2

    BLE.B     label1

    BLE.B     label2

    BCC.W     label1

    BCC.W     label2

    BCC.W     label3

    BGT.W     label1

    BGT.W     label2

    BGT.W     label3

    BLE.W     label1

    BLE.W     label2

    BLE.W     label3

    JSR       (A0)

    JSR       $1234

    JSR       $12345678

    JSR       label1

    JSR       label2

    JSR       label3

    NOP

label1
label2
label3

    RTS
    
    MOVEM.W   A1-A7,-(A1)

    MOVEM.L   D1-D7,-(A1)

    MOVEM.W   A1/D7,-(A1)

    MOVEM.L   A1/D7,-(A1)

    MOVEM.W   A1-A7,(A1)

    MOVEM.L   D1-D7,(A1)

    MOVEM.W   A1/D7,(A1)

    MOVEM.L   A1/D7,(A1)

    MOVEM.W   (A1)+,A1-A7

    MOVEM.L   (A1)+,D1-D7

    MOVEM.W   (A1)+,A1/D7

    MOVEM.L   (A1)+,A1/D7

    MOVEM.W   (A1),A1-A7

    MOVEM.L   (A1),D1-D7

    MOVEM.W   (A1),A1/D7

    MOVEM.L   (A1),A1/D7
    
    

    
 



















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
