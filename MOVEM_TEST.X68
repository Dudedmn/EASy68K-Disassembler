    
    ORG $9000
    ;MOVEM.W   D1-D4/A1-A7,-(A1)

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
