*-----------------------------------------------------------
* Title      :Test File
* Written by : Fahad Alshehri
* Date       :
* Description:
*-----------------------------------------------------------

    ORG $3000

    NOP

    RTS

    NOP

    RTS
    
    ORI.W #$2501, D1
   
    SUBQ.B  #1,D0
    
    SUBQ.W  #$2, D1
    
    SUBQ.L  #4,D2

    LEA     (A0),A0
    
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
