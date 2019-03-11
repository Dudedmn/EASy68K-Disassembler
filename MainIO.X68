*--------------------------------------------------------------------------
* Title      : Disassembler Skeleton 
* Written by : You, and you should change all default comments
* Date       : 3/9/2019 
* TEAM REEE Denny, Daniel, Fahad
* 
* Description: This code contains a method for you to use
* with your Disassembler project IO, and a short demo of 
* how to call this method in the body of the "START" code.
* 
* Hints and Tips:
*   -Follow the code commenting convention here for file & method headers
*   -Don't rename this file name (Main.X68)
*   -Don't reorg the start address ($1000)
*   -Don't rename or edit the IO method I've provided you with here
*   -Don't rename the config.cfg file or change the file format: 
*    <Long_StartAddress>\CR\LF
*    <Long_EndAddress>\CR\LF<EOF>
*---------------------------------------------------------------------------
    ORG    $1000    *Don't change this; see hints and tips above
*---------------------------------------------------------------------------

*declare the variable startaddr with size 1 long
CURRENTADDR   DS.L        1                       * The starting address to decode from


START:
    ***********************************************************
    * Code demo for printing strings to console & file is here
    * Pay close attention to:
    *   (1) the detailed comments, 
    *   (2) how to build a (Callee-Saved) method
    *   (3) how to call that method using JSR (return with RTS)
    ***********************************************************
   
    LEA MAIN_CONSOLE, A1
    JSR TrapTask13
    
    
    ******************************************
    **
    **     ___         ___        /  __  
    **    |__  | |    |__     |  /  /  \  
    **    |    | |___ |___    | /   \__/ 
    **                           
    **
    ** This is the beggnining of the code for reading from files
    ******************************************


    ;Open config.cfg (trap subtasks 50-59) (this is an IO responsibility if 3 team members)
    

; Display description
        lea     description,A1          ; location of text to display
        move.b  #14,D0                  ; trap task #14, displays null terminated string at (A1)
        trap    #15                     ; perform task
; Attempt to open file for input
        lea     fileName,A1             ; name of file to open
        move.b  #51,D0                  ; trap task #51, open existing file
        trap    #15                     ; perform task
        move.l  D1,fileID               ; save file ID

; Read string from file
        lea     string,A1               ; location of string buffer
        move.l  fileID,D1               ; file ID of file to read from
        clr.l   D2
        move.w  #SIZE,D2                ; number of bytes to read
        move.b  #53,D0                  ; trap task #53, read from file
        trap    #15                     ; perform task
; Close file when finished
        move.b  #56,D0                  ; trap task #56, close file, D1 contains fileID
        trap    #15                     ; perform task
; Display result label
        lea     result,A1               ; location of text to display
        move.b  #14,D0                  ; trap task #14, displays null terminated string at (A1)
        trap    #15                     ; perform task
; Display string
        lea     string,A1               ; location of text to display
        move.w  #SIZE,D1                ; max characters to display
        move.b  #0,D0                   ; trap task #0, displays string
        trap    #15                     ; perform task
; Display success message
        lea     success,A1              ; location of text to display
        move.b  #14,D0                  ; trap task #14, displays null terminated string at (A1)
        trap    #15                     ; perform task
    
    


    ;load start and end address as longs
    ; Start Address is in A5     
    LEA string, A1
    JSR AsciiToHex     ;  example of how to convert ascii to hex
    MOVE.L D7, A5
    
    ; End Address is in A6
    ADDA.L #2, A1
    JSR AsciiToHex
    MOVE.L D7, A6
    
    
    ;loop from start to end, printing out the instruction or DATA if not recognized 
    ;   use my method below (printStringToFileAndConsole) to print out the individual instruction (or DATA)
    
    ;TODO : validate start and ending address 

mainloop    CMPA.L A5, A6
            BLT DONE
            
            *clear both buffers 
            
            MOVE.W (A5)+, CUR_OP_CODE
            
            *you call the opcode subroutine 
            
            *if the opcode is valid, you print the G.BUFFER
            *if not, you print  DATA $XXXX $ADDRESS 
            
            
            
            BRA mainLoop


DONE

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
    RTS                                             * Exit subroutine


**************************************************************************
* ClearBuffer
***********************************************************************
* Clears the given buffer by filling it with NULL. By default it will fill 80
* bytes from the buffer pointer with NULL, so make sure the buffer reserves
* that many bytes. The default can be changed.
*
**
* @param Arg_ClearBuffer_Buffer     Pointer to buffer
* @param Arg_ClearBuffer_Length     Byte length of buffer, default 80
* @branch _ClearBuffer_Loop         Buffer loop
* @branch _ClearBuffer_End          Subroutine end
*****************************************************************************
Arg_ClearBuffer_Buffer  DS.L    1
Arg_ClearBuffer_Length  DC.L    80

ClearBuffer:            DS.W    0
    MOVEM.L     D0-D1/A0, -(SP)             * Backup registers to stack
    MOVEA.L     Arg_ClearBuffer_Buffer, A0  * Load buffer address
    MOVE.L      Arg_ClearBuffer_Length, D0  * Load buffer length
    CLR.L       D1                          * Clear counter
    
_ClearBuffer_Loop
    CMP.L       D0, D1                      * If counter >= length
    BGE         _ClearBuffer_End            * Finish subroutine
    
    CLR.B       (A0)+                       * Clear current character in buffer
    ADDQ        #1, D1                      * Increment counter
    BRA         _ClearBuffer_Loop           * Loop back
    
_ClearBuffer_End
    MOVEM.L     (SP)+, D0-D1/A0             * Restore registers from stack
    RTS                                     * Exit subroutine


    SIMHALT


CUR_OP_CODE DS.W 1    


*********************************************************************************
* Method Name: TrapTask13
* Description: Creates a file if none exists, and appends bytes to that file
*   while also echoing the written bytes to the screen.  You shouldn't need to
*   change this code.
*
* Calling Convention: Callee-Saved 
*
* Preconditions & Method Input:
*   A1 points to the null-terminated buffer to write (newline will be added for you)
*
* Postconditions & Output:
*   ALL files that were previously open will be CLOSED (FileIDs will be invalid)
*   See 'Output.txt' in directory for the results, also piped to the console
*
*
*  A2 holds a pointer to null terminated string to write (input)
*  A3 points to the null-terminated file name
*  D3 holds the number of bytes already in the file to write
*
*  D5 holds number of bytes to write
********************************************************************************
toSave REG D0-D5/A2-A3
TrapTask13:
    *******************************************************************
    * Method initialization, regsiter spilling, parameter saving, etc.
    *******************************************************************
    MOVEM.L toSave, -(SP)   ;  Callee-Saved, so save and restore     
      
    MOVEA.L A1, A2 ; save this buffer to write
    LEA outFilename, A3  ; save this for later, too
      
    move #50,d0   
    trap #15 ; close all files, suggested to begin any IO 
    *******************************************************************
    * End Method Init
    *******************************************************************

    ******************************************************************************************
    * Calculate the number of bytes to write by searching for the null in the target buffer A0
    ******************************************************************************************
    CLR.L D5 *D5 is now the number of bytes to write
nullLoop:
    MOVE.B (A1)+, D0
    CMPI.B #0,D0  * compare to null
    BEQ findNullLoopDone
    ADDI.W #1, D5
    BRA nullLoop
    
findNullLoopDone:
    MOVEA.L A3, A1 * reset A1 so it points to the file to write to (to open, next)
    
    ;check if file exists, and open with task 51 if so, otherwise 52
    ;(precondition here is A1 points to the null-terminated filename )
    MOVE.B #51, D0      ;open file (task 51 is existing, 52 is new)
    trap #15
      
    if.w D0 <NE> #0 then.s         ; if file error (404, not found)
        MOVE.B #52, D0             ; open new file (52 is new)
        trap #15
    endi
    
    ********************************************************************************************************* 
    * Seek to END of FILE by counting the number of bytes, closing, reopening, then seeking.
    *    (first, count number of bytes already in the file to obtain seek position)
    *********************************************************************************************************
    Clr.L D3   ;TODO: reg save, D3 is now our count of bytes read
    MOVE.L #1, D2 ; read one byte at a time
    LEA byteRead, A1
    
countLoop:
    MOVE.B #53, D0 ; try to read one byte (TODO: move out of loop)
    trap #15
    
    CMPI.W #1,D0  ;1 == EOF
    BEQ countDone
    ADDI #1, D3
    BRA countLoop
    
countDone:    
    * close this file
     move #56,d0  
     trap #15 
     
     * reopen the target file
     MOVE.L A3,A1
     MOVE #51, D0
     trap #15
     
    * seek to right position, then continue with writing
    MOVE.L D3, D2 ; move the number of bytes found in the file to D2
    MOVE #55, D0  ; position file task
    trap #15

    ******************************************************************************
    * Actually write the buffer to the file, after caculating the number of bytes 
    *  to write and after seeking to the right location in the file for append
    ******************************************************************************

    MOVE.L D5, D2 ; restore this for the actually writing the buffer 
    ; assumes A0 hasnt changed since handed to this method      
    MOVEA.L A2, A1 ; load the address of the buffer we want to write to disk
    ; assumes file ID is still stored in D1.L  
    MOVE.B #54, D0 ; subtask 54 is write to open file (append, or?), assumes D2 holds # of bytes
    trap #15

    ; add a newline to the file output
    LEA NEWLINE, A1
    MOVE.B #54, D0 
    MOVE.B #2,D2  ; kills # of bytes to write from input param
    trap #15
    
    ; finally, close only this file
    MOVE.B #56, D0 ; close file task
    trap #15
  
    ; report to screen
    MOVEA.L A2, A1 ; load the address of the buffer we want to write to disk & screen
    MOVE.B #13, D0
    trap #15
      
    ; restore context
    MOVEM.L (SP)+, toSave
    
    RTS
    
    
*----------------------------------------------------------------------------------
* Method Name: AsciiToHex
* Written by : Berger, Modified by Nash
* Date       : 3/1/2019
* Description: Converts chars '0'-'9' and 'a'-'f' to 0-9,a-F
*              Transforms/unpacks 8 chars (8b each) pointed to by A1 into 
*              its (4b each) equivalent hex value 
*  
*  Preconditions & Input
*       A1 (input) points to a memory buffer holding 8 ascii chars (not null-terminated) 
*       This function calls another function (strip_ascii)
*
*  Postconditions & Output
*       D7 (output) holds the converted value 
*       Caller-Saved : D0 is temp, D6 is a loop var
*----------------------------------------------------------------------------------
AsciiToHexRegList REG D0,D6
AsciiToHex     
    MOVEM.L asciiToHexRegList, -(SP)  *save context
    CLR.L D7 * clear our return value
    MOVE.L #8, D6 ; and set up our loop counter

chrLoop
    MOVE.B (A1)+,D0 * Get the first byte
    jsr strip_ascii * Get rid of the ascii code    
    OR.W D0,D7 * Load the bits into D7
    
    subI.B #1,D6  *decrement our loop variable
    BEQ chrDone   *skip shifting if we are done
    
    ASL.L #4,D7 * shift left 4 bits to prepare for next byte
    BRA chrLoop

chrDone
    MOVEM.L (SP)+,asciiToHexRegList 
    RTS


**********************************************************************
* SUBROUTINE: strip_ascii
* remove the ascii code from the digits 0-9,a-f, or A-F
* Input Parameters: <D0> = ascii code
*
* Return parameters: D0.B = number 0...F, returned as 00...0F
* Registers used internally: D0
* Assumptions: D0 contains $30-$39, $41-$46 or $61-66
*
***********************************************************************
strip_ascii
      CMP.B #$39,D0 * Is it in range of 0-9?
      BLE sub30 * Its a number
      CMP.B #$46,D0 * Is is A...F?
      BLE sub37 * Its A...F
      SUB.B #$57,D0 * Its a...f
      BRA ret_sa * Go back
sub37 SUB.B #$37,D0 * Strip 37
      BRA ret_sa * Go back
sub30 SUB.B #$30,D0 * Strip 30
ret_sa RTS * Go back


MAIN_CONSOLE:
   
      DC.B '============================================================',CR,LF
      DC.B '||                                                        ||',CR,LF
      DC.B '||   #####      ###    ##   ##                            ||',CR,LF
      DC.B '||  ##        ##   ##  ## ##                              ||',CR,LF
      DC.B '|| ## ####     #####   ####                               ||',CR,LF
      DC.B '|| ##    ##  ##    ##  ####                               ||',CR,LF
      DC.B '|| ##    ##  ##    ##  ## ##                              ||',CR,LF
      DC.B '||  #####     ######   ##  ##                             ||',CR,LF
      DC.B '||                                                        ||',CR,LF
      DC.B '||   Daniel Yan, Fahad Alshehri, Denny Park               ||',CR,LF
      DC.B '============================================================',CR,LF,0
    
* Required variables and constants go here for your Disassembler
CR                  EQU $0D
LF                  EQU $0A
NEWLINE             DC.B CR,LF,0  
outFilename         DC.B 'Output.txt',0
byteRead            DS.B 1
ascii_val           DC.B $31,$41,$30,$30,$31,$41,$30,$30 * Test value $1A001A00

* Variables and constants
CR              EQU     $D              ; ASCII code for carriage return
LF              EQU     $A              ; ASCII code for line feed
SIZE            EQU     20             ; Max string size
description     DC.B    'Demonstrates reading a string from a file. ',CR,LF,CR,LF,0
result          DC.B    'The string read from the file is:',CR,LF,0
fileName        DC.B    'Config.cfg',0   ; name of text file
errorFile       DC.B    'A file error occurred.',CR,LF,0
success         DC.B    'File read complete.',CR,LF,0
string          DS.B    SIZE            ; I/O buffer
strSize         DS.W    1               ; Size if input string
fileID          DS.L    1               ; File ID



   END    START        ; last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
