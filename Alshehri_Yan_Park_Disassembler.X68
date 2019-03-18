**--------------------------------------------------------------------------
* Title      : Disassembler in Motorola 68k
* Written by : TEAM REEE Denny, Daniel, Fahad
* Date       : 3/17/2019 
* 
* 
* Description: This disassembler reverse assembles or decompiles a given
* test program (with validity checking) from their machine code hex
* equivalents to outputting them onto a console file and a log.
*
* This disassembler will print out <MEMORY ADDRESS> <OPERAND> <EA MODE/REG>
* If the identified code is valid.
*
* This disassembler will print out <MEMORY ADDRESS> DATA $<INVALID HEX>
* If the identified code is invalid.
*---------------------------------------------------------------------------
    ORG    $1000    
*---------------------------------------------------------------------------
G_BUFFER        DS.B    80			;Used to print out the needed letters to the buffer
B_BUFFER        DS.B    80			;Bad buffer used to load bad data
CUR_OP_CODE     DS.W    1			;Used to determine the current 4 hex OP code
IS_VALID        DS.B    1			;Validity bit to check if a code is valid or not
						;1 = valid, 0 = invalid

START:						;Start of the program

    LEA MAIN_CONSOLE, A1			;Loads the main message into A1
    JSR TrapTask13			       ;Prints message out to console and log

    
    
    ******************************************
    **
    **     ___         ___        /  __  
    **    |__  | |    |__     |  /  /  \  
    **    |    | |___ |___    | /   \__/ 
    **                           
    **
    ** This is the beginning of the code for reading from files
    ******************************************
* Attempt to open file for input
        LEA     fileName,A1                    ;Name of file to open
        MOVE.B  #51,D0                         ;Trap task #51, open existing file
        TRAP    #15                            ;Perform task
        MOVE.L  D1,fileID                      ;Save file ID

* Read string from file
        LEA     IO_BUFFER,A1                   ;Location of string buffer
        MOVE.L  fileID,D1                      ;File ID of file to read from
        CLR.L   D2
        MOVE.W  #SIZE,D2                       ;Number of bytes to read
        MOVE.B  #53,D0                         ;Trap task #53, read from file
        TRAP    #15                            ;Perform task
* Close file when finished
        MOVE.B  #56,D0                         ;Trap task #56, close file, D1 contains fileID
        TRAP    #15                            ;Perform task


*Load start and end address as longs
*Start Address is in A5     
    LEA IO_BUFFER, A1				;Load string or IO buffer to A1
    JSR AsciiToHex     				;Convert ASCII to Hex
    MOVE.L D7, A5					;Loop counter prep
    
*End Address is in A6
    ADDA.L #2, A1					;Add #2 to A1
    JSR AsciiToHex					;Convert ASCII to Hex
    MOVE.L D7, A6					;Loop counter prep
    
VALIDATE_START_ADDRESS				;Validates starting address
    MOVE.L A5, D0					;Move stating address to D0
*----------------------------------------------------------------------------------
* Method Name: VALIDATE_POSITIVE_ADDRESS
* Description: Checks if the start address is positive it then branches
*              to validate if the address in the Config.cfg file is even
*
*  Preconditions & Input of a start address that is even
*       A1 (input) points to a memory buffer holding 8 ASCII chars (not null-terminated) 
*       This function calls another function (strip_ascii)
*
*  Postconditions & Output
*   
*----------------------------------------------------------------------------------
VALIDATE_POSITIVE_ADDRESS
    MOVE.L A5, D0					;Move starting address to D0
    ANDI.L #$80000000, D0  			;Checking if the start address address is positive
    CMP.L #0, D0					;Compare 0 to D0
    BEQ VALIDATE_EVEN				;Check if the address is even
    
    LEA INVALID_ADDRES_MESSAGE, A1	       ;Load INVALID message to A1
    JSR TrapTask13                             ;Use Nash's Console Output
    BRA DONE						;Finish routine

VALIDATE_END_POS
    MOVE.L A6, D0					;Move ending address to D0
    ANDI.L #$80000000, D0			       ;Checking if the end address address is positive
    CMP.L #0, D0					;Compare address to 0
    BEQ VALIDATE_EVEN				;Check if the end address is even
    
    LEA INVALID_ADDRES_MESSAGE, A1	       ;Load INVALID message to A1
    JSR TrapTask13                             ;Use Nash's Console Output      
    BRA DONE						;Finish routine
    
VALIDATE_EVEN
    MOVE.L A5, D0					;MOVE STARTING ADDRESS TO D0
    ANDI.L #$00000001,D0			       ;Bitmask 1 a single bit to D0
    CMP.L #0, D0					;Check if even
    BEQ MAIN_LOOP					;Go to the main loop if even
*Handle odd addresses
    LEA INVALID_ADDRES_MESSAGE, A1	       ;Load INVALID message to A1
    JSR TrapTask13                             ;Use Nash's Console Output
    BRA DONE						;Finish routine
            


*Comments are shifted if variable names get too long
MAIN_LOOP									;Main loop to run each instruction
	     LEA G_BUFFER,A4        					;Point G_BUFFER to A4
    
            CMPA.L A5, A6							;Compare Starting to ending address
            BLT DONE							;If it's less then stop the loop
            
*Clear both buffers 
            MOVE.L #G_BUFFER, CLEAR_BUFFER_POINTER      		;Point the clear pointer to G_BUFFER
            JSR CLEAR_BUFFER						;Clear the buffer
            
            MOVE.L #B_BUFFER, CLEAR_BUFFER_POINTER      		;Point the clear pointer to B_BUFFER
            JSR CLEAR_BUFFER						;Clear the buffer
            
*Add address to both buffers
            
            MOVE.L A5, NUMBER_TO_CONVERT				;The current address is stored to A5, we need to convert it to load it in the buffers.
            MOVE.B #8, CHARNUM_TO_CONVERT				;This specifies the number of characters that needs to be converted.
            JSR CONVERT_HEX_TO_STRING					;Convert hex to string
            
            MOVE.L #CONVERTED_HEX_STRING, STRING_BUFFER_POINTER	;Prepare the string buffer with the converted hex string
            MOVE.L #G_BUFFER, BUFFER_POINTER			       ;Point G_BUFFER to the print buffer
            JSR AddStrToBuffer						;Add the string to the print buffer
    
            MOVE.W (A5)+, CUR_OP_CODE					;Read the current opcode
            JMP OP_JSR_Routine						;Run main OP code routine

*********************************
*Checks if its valid print or invalid
* @pre checks invalid
* @post Branches to the respective branch
************************************
check_print
            CMP.B #1,IS_VALID						;Check if IS_VALID is set to 1
            BEQ   print_instruction					;If it's valid do print_instruction
            BNE   print_data						;If it's invalid do print_data
            
print_instruction								;Prints the data in G_BUFFER
*Print the opcode if valid
            LEA G_BUFFER,A1						;Points A1 to G_BUFFER
            JSR TrapTask13							;Use Nash's console output
            BRA MAIN_LOOP							;Go back to the main loop
 
*Otherwise print data
print_data  
            MOVE.L A5, NUMBER_TO_CONVERT					;The current address is stored to A5, we need to convert it to load it in the buffers.
            MOVE.B #8, CHARNUM_TO_CONVERT					;This specifies the number of characters that needs to be converted.
            JSR CONVERT_HEX_TO_STRING						;Convert the hex to string
            MOVE.L #CONVERTED_HEX_STRING, STRING_BUFFER_POINTER		;Point the string buffer to the converted hex
            
            MOVE.L #B_BUFFER, BUFFER_POINTER					;Prepare the string buffer with the valid data
            JSR AddStrToBuffer							;Add the string to the print buffer
*Add bad data to bad buffer
            MOVE.L #P_INVALID_OP, STRING_BUFFER_POINTER			;Prepare the string buffer with the invalid data
            JSR AddStrToBuffer							;Add the string to the print buffer
            
            MOVE.W CUR_OP_CODE, NUMBER_TO_CONVERT				;The current address is stored to A5, we need to convert it to load it in the buffers.
            MOVE.B #8, CHARNUM_TO_CONVERT					;This specifies the number of characters that needs to be converted.
            JSR CONVERT_HEX_TO_STRING 						;Convert the hex to string
            
            MOVE.L #CONVERTED_HEX_STRING, STRING_BUFFER_POINTER		;Prepare the string buffer with the converted hex string
            JSR AddStrToBuffer							;Add the converted hex to buffer
            
            LEA B_BUFFER,A1							;Point A1 to the bad buffer
            JSR TrapTask13								;Use Nash's console output
            BRA MAIN_LOOP								;Go back to the main loop


DONE											;We're finished at this point reading all the files
            SIMHALT									;Halt the simulation
            
**
* AddStrToBuffer
*****************************************************************************
* Description: Adds the a defined string constant into a buffer to print out
* Places a NULL terminating string to start with a default buffer length of 80.
*
* If the buffer length is exceeded, where length was improperly specified or no
* NULL terminating string was found, return 1, else return 0 for success.
*
* Additional Constants/Subroutines used:
* STRING_BUFFER_POINTER					;String pointer
* BUFFER_POINTER						;Buffer pointer
* BUFFER_POINTER_LENGTH					;Buffer length, 80 chars by default
* BUFFER_ADD_SUCCESS					;0 = success, 1 = failure
* FIND_NULL_IN_BUFFER					;Find NULL in buffer with a loop
* STRING_BUFFER_ADD_LOOP					;Add a string to the buffer with a loop
* STRING_ADD_SUCCESS				       ;Routine to run when string is added successfully
* BUFFER_LENGTH_FAIL					;Routine to run when buffer length is exceeded
* BUFFER_STRING_END						;Subroutine is finished
*****************************************************************************
* Constant definitions:
STRING_BUFFER_POINTER	DS.L    1
BUFFER_POINTER		DS.L    1
BUFFER_POINTER_LENGTH	DC.L    80
BUFFER_ADD_SUCCESS		DS.B    1

AddStrToBuffer:           DS.W    0                   ;Reserve a word
    MOVEM.L     D0-D1/A0-A1, -(SP)  			;Save registers to stack
    
    MOVE.L      STRING_BUFFER_POINTER,A0		;Load string pointer to A0
    MOVE.L      BUFFER_POINTER, A1			;Load buffer pointer to A1
    MOVE.L      BUFFER_POINTER_LENGTH, D0		;Load buffer length to D0
    CLR.W       BUFFER_ADD_SUCCESS			;Clear any prior success bit
    CLR.L       D1						;Clear any prior loop counts

STRING_BUFFER_LOOP
    CMPI.B      #0, (A1)					;Check if buffer char is NULL or not
    BEQ         STRING_BUFFER_ADD_LOOP			;If a 0 is found, start adding string(s) to the buffer
    
    CMP.L       D0, D1					;Check if the counter is more than the max length
    BGE         BUFFER_LENGTH_EXCEEDED			;Exceeded the length
    
    ADDQ.L      #1, A1					;Increment to the next character
    ADDQ.B      #1, D1					;Increment loop counter
    BRA         STRING_BUFFER_LOOP			;Loop back again
    
STRING_BUFFER_ADD_LOOP
    CMPI.B      #0, (A0)				       ;Check is the string char is NULL
    BEQ         STRING_ADD_SUCCESS			;String has been added successfully
    
    CMP.B       D0, D1					;Check if the counter is more than the max length
    BGE         BUFFER_LENGTH_EXCEEDED			;Exceeded the length
    
    MOVE.B      (A0)+,(A1)+				;Add string to the buffer
    ADDQ.B      #1, D1					;Increment loop counter
    ADDQ.W      #1, A4					;Increment G_BUFFER counter
    BRA         STRING_BUFFER_ADD_LOOP			;Loop back again

STRING_ADD_SUCCESS
    MOVE.B      #0,(A1)					;Place NULL terminating 0 at the end
    BRA         BUFFER_STRING_END				;Finish subroutine

BUFFER_LENGTH_EXCEEDED
    MOVE.W      #1, BUFFER_ADD_SUCCESS			;BUFFER failed to add

BUFFER_STRING_END
    MOVEM.L     (SP)+, D0-D1/A0-A1			;Restore registers from stack
    RTS                  					;Return to stack
**************************************************************************
* CLEAR_BUFFER
*****************************************************************************
* Description: Clears the defined buffer area with NULL terminating 0s
* The default size is 80 bytes
*
* Additional Constants/Subroutines used:
* CLEAR_BUFFER_POINTER					;Buffer pointer
* CLEAR_BUFFER_LENGTH					;Length of buffer, default 80 bytes
* CLEAR_BUFFER_LOOP						;Buffer loop
* CLEAR_BUFFER_END						;Finish subroutine
*****************************************************************************
* Constant definitions:
CLEAR_BUFFER_POINTER	DS.L    1
CLEAR_BUFFER_LENGTH		DC.L    80

CLEAR_BUFFER:			DS.W    0                  ;Reserve a word
    MOVEM.L     D0-D1/A0, -(SP)				;Save registers to stack
    MOVEA.L     CLEAR_BUFFER_POINTER, A0		;Load buffer address to A0
    MOVE.L      CLEAR_BUFFER_LENGTH, D0			;Load buffer length to D0
    CLR.L       D1						;Clear any prior loop counter
    
CLEAR_BUFFER_LOOP
    CMP.L       D0, D1					;Check if the counter is more than the max length
    BGE         CLEAR_BUFFER_END				;Finish subroutine
    
    CLR.B       (A0)+					;Clear current character in clear buffer
    ADDQ        #1, D1					;Increment loop counter
    BRA         CLEAR_BUFFER_LOOP				;Loop back again
    
CLEAR_BUFFER_END
    MOVEM.L     (SP)+, D0-D1/A0				;Restore registers from stack
    RTS							;Return to stack


**
* CONVERT_HEX_TO_STRING
*****************************************************************************
* Description: Converts a given number to a hexadecimal string by the specified 
* length. A null terminating string is added after (0). Conversion starts from the
* rightmost bit.
*
* Default length of conversion is 8, but can be changed.

* Additional Constants/Subroutines used:
* NUMBER_TO_CONVERT						;Number to convert
* CHARNUM_TO_CONVERT					;Character numbers to convert, valid range is 0-8
* CONVERTED_HEX_STRING					;Converted hexadecimal character string
* CHECK_POSITIVE_LENGTH					;Routine to check for positive length
* CHECK_VALID_LENGTH					;Routine to check for valid length
* DIGIT_LOOP							;Looping through each digit
* CONVERT_TO_HEX_LETTER					;Routine to convert to hex letter
* ADD_CHAR_TO_STRING					;Adds a character to the string
*****************************************************************************
* Constant definitions:
NUMBER_TO_CONVERT		DS.L	1
CHARNUM_TO_CONVERT		DC.B	8
CONVERTED_HEX_STRING	DS.B	9

CONVERT_HEX_TO_STRING:	DS.W	0	              ;Reserve a word		
    MOVEM.L     D0-D3/A0-A1, -(SP)			;Save registers to stack
    CLR.L       D1						;Clear any prior number from D1
    CLR.L       D0						;Clear any prior number from D0
    MOVE.L      NUMBER_TO_CONVERT, D0			;Load number to D0
    MOVE.B      CHARNUM_TO_CONVERT, D1			;Load length to D1
    MOVEA.L     #CONVERTED_HEX_STRING, A0		;Load string address to convert
    
    CMPI.B      #1, D1					;Check if D1 is one or not
    BGE         CHECK_POSITIVE_LENGTH			;Check the length of the number
    MOVEQ       #1, D1					;Move number 1 to D1 otherwise
    
CHECK_POSITIVE_LENGTH					;Checks the positive length
    CMPI.B      #8, D1					;Check if the length is 8 or not
    BLE         CHECK_VALID_LENGTH			;If it's less find and check the length
    MOVEQ       #8, D1					;Move number 8 into the length
    
CHECK_VALID_LENGTH						;Checks to see if the length is valid
    MOVEA.L     A0, A1					;A0 contains start number, A1 contains current number
    ADDA.W      D1, A1					;Go to the last digit
    CLR.B       (A1)					;Make the last digit NULL or 0
    MOVEQ       #$0F,D2					;Bitmask last hex or nibble
    
DIGIT_LOOP
    MOVE.B      D0, D3					;Get 2 hex chars from number
    AND.B       D2, D3					;Mask to get last hex char
    
    CMPI.B      #9, D3					;Check if the value is over 9
    BGT         CONVERT_TO_HEX_LETTER			;If so, it must be a letter, convert the letter
    
    ADDI.B      #'0', D3				       ;Get the ASCII value for 0-9
    BRA         ADD_CHAR_TO_STRING			;Add char to the string

CONVERT_TO_HEX_LETTER
    SUBI.B      #10, D3					;Subtract 10 first to get correct ASCII
    ADDI.B      #'A', D3					;Get the ASCII value for letters A-F

ADD_CHAR_TO_STRING
    MOVE.B      D3, -(A1)					;Add char to string and decrement pointer
    LSR.L       #4, D0					;Shift the 4 bits to the right
    CMPA.L      A0, A1					;Check if the current pointer is greater than starting string
    BGT         DIGIT_LOOP				       ;If so, loop back
    CLR.L  NUMBER_TO_CONVERT                          ;Clear any prior number  
    
    MOVEM.L     (SP)+, D0-D3/A0-A1		       ;Restore registers from stack
    RTS							;Finish subroutine


******************************************* START OF NASH CODE ******************	
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
    * Method initialization, register spilling, parameter saving, etc.
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
    * Actually write the buffer to the file, after calculating the number of bytes 
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
******************************************* END OF NASH CODE ********************
MAIN_CONSOLE                                                            ;Main print message
   
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
CR				EQU $0D						;Carriage return
LF				EQU $0A					       ;Line feed
NEWLINE			DC.W CR,LF,0  					;Make a new line
outFilename		DC.B 'DisassemblerOutput.txt',0				;Output file
byteRead 		DS.B 1								;Read a byte
ascii_val		DC.B $31,$41,$30,$30,$31,$41,$30,$30			;Test value $1A001A00

* Variables and constants
SIZE			EQU     20							;Max string size
fileName		DC.B    'Config.cfg',0					;Name of text file
IO_BUFFER		DS.B    SIZE            			        	;Variable for IO buffer
fileID			DS.L    1               					;Variable for File ID
INVALID_ADDRES_MESSAGE DC.W 'Invalid Hex Address' ,CR,LF,0			;Invalid message print

    INCLUDE "OP_Code_Routines.x68"						;OP role code to include
    INCLUDE "EA_FINAL.x68"							;EA role code to include
    INCLUDE "MOVEM_TEST.x68"								;Test program to include
    
    
   END    START									;Last line of program







*~Font name~Courier New~
*~Font size~15~
*~Tab type~1~
*~Tab size~4~
