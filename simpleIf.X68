*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START                  ; first instruction of program

        MOVE.W  #3, D2 ; d2 is y
        MOVE.W  #3, D3 ; d3 is x
if      CMP.W D2,D3
        BNE DONE

        LEA equal,A1
        MOVE.B #13,D0
        TRAP #15
* Put program code here
DONE
    MOVE.L #1, D3
    MOVE.L #5, D5 ; D5 is loop variable
LOOP
    MOVE.B D3,D1
    MOVE.B #3,D0
    TRAP #15
    
    ASL #1, D3 ; multiply by 2 (shifting left)
    
    SUBI.B #1,D5
    BNE LOOP

disassembler
    LEA testCode,A3 ;A3 as teh start of the code
    MOVE.B #3,D5 ; d5 is loop var
disLOOP
    MOVE.W (A3)+,D3 ; d3 is the opcode word
    CMPI.W #$4E75,D3 ; check if the input is rts
    BNE skip1
    *print rts
    LEA rtsMSG,A1
    MOVE.B #13,D0
    TRAP #15
    MOVE.B #1, D6 ;set d6 to a value for 'data'
nopCheck *if nop    
    CMPI.W #$4E71,D3 ; chieck if the input is nop
    BNE skip2
    *print nop
    LEA nopMSG,A1
    MOVE.B #13,D0
    TRAP #15
    MOVE.B #1,D6
    
dataCheck    *print data is D6 is set
    CMPI.W #1,D6
    BNE skip3
    LEA dataMSG,A1
    MOVE.B #13,D0
    TRAP #15
    MOVE.B #0,D6 *reset DATA
    
    *if this is an if statement, print if
skip1    *if this is rts
    SUBI.B #1,D5
    BNE nopCheck
skip2   *if this is NOP
    SUBI.B #1,D5
    BNE dataCheck    
skip3
    SUBI.B #1,D5
    BNE disLoop
     
testCode  
          NOP
          RTS
          RTS
          NOP
          RTS
    SIMHALT
* Put variables and constants here
equal DC.B  'Equals',0
rtsMSG DC.B 'RTS',0
nopMSG DC.B 'NOP',0
dataMSG DC.B 'DATA',0
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
