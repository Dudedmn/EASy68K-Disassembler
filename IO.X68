*-----------------------------------------------------------
* Title      : Fahad Alshehri I/O
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    

* Put variables and constants here
    LEA HOME_0, A1
    JSR PRINT_HOME
    LEA HOME_1, A1
    JSR PRINT_HOME
    LEA HOME_2, A1
    JSR PRINT_HOME
    LEA HOME_3, A1
    JSR PRINT_HOME

    
PRINT_HOME
    MOVE.B #13, D0 * 
    TRAP   #15    * Executes whatever in D0
    RTS

*DONE_PRINTING
   *LEA DONE, A1
   * JSR  PRINT_PRINTING
   * SIMHALT
    
 
* The homepage in the dissasembler 
HOME_0      DC.B        $0D, $0A, $0D, $0A, $0
HOME_1       DC.B           '   /*************************************************************************\',$0
HOME_2      DC.B           '   |                   Welcome to the Motorola 68000 Disassembler            |',$0
HOME_3      DC.B           '   |                                                                         |',$0
HOME_4      DC.B           '   |                                                                         |',$0
HOME_5      DC.B           '   |                                                                         |',$0

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
