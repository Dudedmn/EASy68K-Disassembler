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
    ORG    $9000    
*---------------------------------------------------------------------------
G_BUFFER_1        DS.B    80			;Used to print out the needed letters to the buffer
B_BUFFER_1        DS.B    80			;Bad buffer used to load bad data
CUR_OP_CODE_1     DS.W    1			;Used to determine the current 4 hex OP code
IS_VALID_1        DS.B    1			;Validity bit to check if a code is valid or not
						;1 = valid, 0 = invalid

;START:						;Start of the program

    LEA MAIN_CONSOLE_1, A1			;Loads the main message into A1
    JSR TrapTask13_1			       ;Prints message out to console and log

    
    
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
        LEA     fileName_1,A1                    ;Name of file to open
        MOVE.B  #51,D0                         ;Trap task #51, open existing file
        TRAP    #15                            ;Perform task
        MOVE.L  D1,fileID_1                      ;Save file ID

* Read string from file
        LEA     IO_BUFFER_1,A1                   ;Location of string buffer
        MOVE.L  fileID_1,D1                      ;File ID of file to read from
        CLR.L   D2
        MOVE.W  #SIZE_1,D2                       ;Number of bytes to read
        MOVE.B  #53,D0                         ;Trap task #53, read from file
        TRAP    #15                            ;Perform task
* Close file when finished
        MOVE.B  #56,D0                         ;Trap task #56, close file, D1 contains fileID_1
        TRAP    #15                            ;Perform task


*Load start and end address as longs
*Start Address is in A5     
    LEA IO_BUFFER_1, A1				;Load string or IO buffer to A1
    JSR AsciiToHex_1     				;Convert ASCII to Hex
    MOVE.L D7, A5					;Loop counter prep
    
*End Address is in A6
    ADDA.L #2, A1					;Add #2 to A1
    JSR AsciiToHex_1					;Convert ASCII to Hex
    MOVE.L D7, A6					;Loop counter prep
    
VALIDATE_START_ADDRESS_1				;Validates starting address
    MOVE.L A5, D0					;Move stating address to D0
*----------------------------------------------------------------------------------
* Method Name: VALIDATE_POSITIVE_ADDRESS_1
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
VALIDATE_POSITIVE_ADDRESS_1
    MOVE.L A5, D0					;Move starting address to D0
    ANDI.L #$80000000, D0  			;Checking if the start address address is positive
    CMP.L #0, D0					;Compare 0 to D0
    BEQ VALIDATE_EVEN_1				;Check if the address is even
    
    LEA INVALID_ADDRES_MESSAGE_1, A1	       ;Load INVALID message to A1
    JSR TrapTask13_1                             ;Use Nash's Console Output
    BRA DONE_1						;Finish routine

VALIDATE_END_POS_1
    MOVE.L A6, D0					;Move ending address to D0
    ANDI.L #$80000000, D0			       ;Checking if the end address address is positive
    CMP.L #0, D0					;Compare address to 0
    BEQ VALIDATE_EVEN_1				;Check if the end address is even
    
    LEA INVALID_ADDRES_MESSAGE_1, A1	       ;Load INVALID message to A1
    JSR TrapTask13_1                             ;Use Nash's Console Output      
    BRA DONE_1						;Finish routine
    
VALIDATE_EVEN_1
    MOVE.L A5, D0					;MOVE STARTING ADDRESS TO D0
    ANDI.L #$00000001,D0			       ;Bitmask 1 a single bit to D0
    CMP.L #0, D0					;Check if even
    BEQ MAIN_LOOP_1					;Go to the main loop if even
*Handle odd addresses
    LEA INVALID_ADDRES_MESSAGE_1, A1	       ;Load INVALID message to A1
    JSR TrapTask13_1                             ;Use Nash's Console Output
    BRA DONE_1						;Finish routine
            


*Comments are shifted if variable names get too long
MAIN_LOOP_1									;Main loop to run each instruction
	     LEA G_BUFFER_1,A4        					;Point G_BUFFER_1 to A4
    
            CMPA.L A5, A6							;Compare Starting to ending address
            BLT DONE_1							;If it's less then stop the loop
            
*Clear both buffers 
            MOVE.L #G_BUFFER_1, CLEAR_BUFFER_1_POINTER_1      		;Point the clear pointer to G_BUFFER_1
            JSR CLEAR_BUFFER_1						;Clear the buffer
            
            MOVE.L #B_BUFFER_1, CLEAR_BUFFER_1_POINTER_1      		;Point the clear pointer to B_BUFFER_1
            JSR CLEAR_BUFFER_1						;Clear the buffer
            
*Add address to both buffers
            
            MOVE.L A5, NUMBER_TO_CONVERT_1				;The current address is stored to A5, we need to convert it to load it in the buffers.
            MOVE.B #8, CHARNUM_TO_CONVERT_1				;This specifies the number of characters that needs to be converted.
            JSR CONVERT_HEX_TO_STRING_1					;Convert hex to string
            
            MOVE.L #CONVERTED_HEX_STRING_1, STRING_BUFFER_1_POINTER_1	;Prepare the string buffer with the converted hex string
            MOVE.L #G_BUFFER_1, BUFFER_POINTER_1			       ;Point G_BUFFER_1 to the print buffer
            JSR AddStrToBuffer_1						;Add the string to the print buffer
    
            MOVE.W (A5)+, CUR_OP_CODE_1					;Read the current opcode
            JMP OP_JSR_Routine_1						;Run main OP code routine

*********************************
*Checks if its valid print or invalid
* @pre checks invalid
* @post Branches to the respective branch
************************************
check_print
            CMP.B #1,IS_VALID_1						;Check if IS_VALID_1 is set to 1
            BEQ   print_instruction					;If it's valid do print_instruction
            BNE   print_data						;If it's invalid do print_data
            
print_instruction								;Prints the data in G_BUFFER_1
*Print the opcode if valid
            LEA G_BUFFER_1,A1						;Points A1 to G_BUFFER_1
            JSR TrapTask13_1							;Use Nash's console output
            BRA MAIN_LOOP_1							;Go back to the main loop
 
*Otherwise print data
print_data  
            MOVE.L A5, NUMBER_TO_CONVERT_1					;The current address is stored to A5, we need to convert it to load it in the buffers.
            MOVE.B #8, CHARNUM_TO_CONVERT_1					;This specifies the number of characters that needs to be converted.
            JSR CONVERT_HEX_TO_STRING_1						;Convert the hex to string
            MOVE.L #CONVERTED_HEX_STRING_1, STRING_BUFFER_1_POINTER_1		;Point the string buffer to the converted hex
            
            MOVE.L #B_BUFFER_1, BUFFER_POINTER_1					;Prepare the string buffer with the valid data
            JSR AddStrToBuffer_1							;Add the string to the print buffer
*Add bad data to bad buffer
            MOVE.L #P_INVALID_OP, STRING_BUFFER_1_POINTER_1			;Prepare the string buffer with the invalid data
            JSR AddStrToBuffer_1							;Add the string to the print buffer
            
            MOVE.W CUR_OP_CODE_1, NUMBER_TO_CONVERT_1				;The current address is stored to A5, we need to convert it to load it in the buffers.
            MOVE.B #8, CHARNUM_TO_CONVERT_1					;This specifies the number of characters that needs to be converted.
            JSR CONVERT_HEX_TO_STRING_1 						;Convert the hex to string
            
            MOVE.L #CONVERTED_HEX_STRING_1, STRING_BUFFER_1_POINTER_1		;Prepare the string buffer with the converted hex string
            JSR AddStrToBuffer_1							;Add the converted hex to buffer
            
            LEA B_BUFFER_1,A1							;Point A1 to the bad buffer
            JSR TrapTask13_1								;Use Nash's console output
            BRA MAIN_LOOP_1								;Go back to the main loop


DONE_1											;We're finished at this point reading all the files
            SIMHALT									;Halt the simulation
            
**
* AddStrToBuffer_1
*****************************************************************************
* Description: Adds the a defined string constant into a buffer to print out
* Places a NULL terminating string to start with a default buffer length of 80.
*
* If the buffer length is exceeded, where length was improperly specified or no
* NULL terminating string was found, return 1, else return 0 for success.
*
* Additional Constants/Subroutines used:
* STRING_BUFFER_1_POINTER_1					;String pointer
* BUFFER_POINTER_1						;Buffer pointer
* BUFFER_POINTER_1_LENGTH					;Buffer length, 80 chars by default
* BUFFER_ADD_SUCCESS_1					;0 = success, 1 = failure
* FIND_NULL_IN_BUFFER					;Find NULL in buffer with a loop
* STRING_BUFFER_1_ADD_LOOP					;Add a string to the buffer with a loop
* STRING_ADD_SUCCESS				       ;Routine to run when string is added successfully
* BUFFER_LENGTH_FAIL					;Routine to run when buffer length is exceeded
* BUFFER_STRING_END						;Subroutine is finished
*****************************************************************************
* Constant definitions:
STRING_BUFFER_1_POINTER_1	DS.L    1
BUFFER_POINTER_1		DS.L    1
BUFFER_POINTER_1_LENGTH	DC.L    80
BUFFER_ADD_SUCCESS_1		DS.B    1

AddStrToBuffer_1:           DS.W    0                   ;Reserve a word
    MOVEM.L     D0-D1/A0-A1, -(SP)  			;Save registers to stack
    
    MOVE.L      STRING_BUFFER_1_POINTER_1,A0		;Load string pointer to A0
    MOVE.L      BUFFER_POINTER_1, A1			;Load buffer pointer to A1
    MOVE.L      BUFFER_POINTER_1_LENGTH, D0		;Load buffer length to D0
    CLR.W       BUFFER_ADD_SUCCESS_1			;Clear any prior success bit
    CLR.L       D1						;Clear any prior loop counts

STRING_BUFFER_1_LOOP
    CMPI.B      #0, (A1)					;Check if buffer char is NULL or not
    BEQ         STRING_BUFFER_1_ADD_LOOP			;If a 0 is found, start adding string(s) to the buffer
    
    CMP.L       D0, D1					;Check if the counter is more than the max length
    BGE         BUFFER_LENGTH_EXCEEDED_1			;Exceeded the length
    
    ADDQ.L      #1, A1					;Increment to the next character
    ADDQ.B      #1, D1					;Increment loop counter
    BRA         STRING_BUFFER_1_LOOP			;Loop back again
    
STRING_BUFFER_1_ADD_LOOP
    CMPI.B      #0, (A0)				       ;Check is the string char is NULL
    BEQ         STRING_ADD_SUCCESS			;String has been added successfully
    
    CMP.B       D0, D1					;Check if the counter is more than the max length
    BGE         BUFFER_LENGTH_EXCEEDED_1			;Exceeded the length
    
    MOVE.B      (A0)+,(A1)+				;Add string to the buffer
    ADDQ.B      #1, D1					;Increment loop counter
    ADDQ.W      #1, A4					;Increment G_BUFFER_1 counter
    BRA         STRING_BUFFER_1_ADD_LOOP			;Loop back again

STRING_ADD_SUCCESS
    MOVE.B      #0,(A1)					;Place NULL terminating 0 at the end
    BRA         BUFFER_STRING_END				;Finish subroutine

BUFFER_LENGTH_EXCEEDED_1
    MOVE.W      #1, BUFFER_ADD_SUCCESS_1			;BUFFER failed to add

BUFFER_STRING_END
    MOVEM.L     (SP)+, D0-D1/A0-A1			;Restore registers from stack
    RTS                  					;Return to stack
**************************************************************************
* CLEAR_BUFFER_1
*****************************************************************************
* Description: Clears the defined buffer area with NULL terminating 0s
* The default size is 80 bytes
*
* Additional Constants/Subroutines used:
* CLEAR_BUFFER_1_POINTER_1					;Buffer pointer
* CLEAR_BUFFER_1_LENGTH_1					;Length of buffer, default 80 bytes
* CLEAR_BUFFER_1_LOOP						;Buffer loop
* CLEAR_BUFFER_1_END						;Finish subroutine
*****************************************************************************
* Constant definitions:
CLEAR_BUFFER_1_POINTER_1	DS.L    1
CLEAR_BUFFER_1_LENGTH_1		DC.L    80

CLEAR_BUFFER_1:			DS.W    0                  ;Reserve a word
    MOVEM.L     D0-D1/A0, -(SP)				;Save registers to stack
    MOVEA.L     CLEAR_BUFFER_1_POINTER_1, A0		;Load buffer address to A0
    MOVE.L      CLEAR_BUFFER_1_LENGTH_1, D0			;Load buffer length to D0
    CLR.L       D1						;Clear any prior loop counter
    
CLEAR_BUFFER_1_LOOP
    CMP.L       D0, D1					;Check if the counter is more than the max length
    BGE         CLEAR_BUFFER_1_END				;Finish subroutine
    
    CLR.B       (A0)+					;Clear current character in clear buffer
    ADDQ        #1, D1					;Increment loop counter
    BRA         CLEAR_BUFFER_1_LOOP				;Loop back again
    
CLEAR_BUFFER_1_END
    MOVEM.L     (SP)+, D0-D1/A0				;Restore registers from stack
    RTS							;Return to stack


**
* CONVERT_HEX_TO_STRING_1
*****************************************************************************
* Description: Converts a given number to a hexadecimal string by the specified 
* length. A null terminating string is added after (0). Conversion starts from the
* rightmost bit.
*
* Default length of conversion is 8, but can be changed.

* Additional Constants/Subroutines used:
* NUMBER_TO_CONVERT_1						;Number to convert
* CHARNUM_TO_CONVERT_1					;Character numbers to convert, valid range is 0-8
* CONVERTED_HEX_STRING_1					;Converted hexadecimal character string
* CHECK_POSITIVE_LENGTH					;Routine to check for positive length
* CHECK_VALID_LENGTH					;Routine to check for valid length
* DIGIT_LOOP							;Looping through each digit
* CONVERT_TO_HEX_LETTER					;Routine to convert to hex letter
* ADD_CHAR_TO_STRING					;Adds a character to the string
*****************************************************************************
* Constant definitions:
NUMBER_TO_CONVERT_1		DS.L	1
CHARNUM_TO_CONVERT_1		DC.B	8
CONVERTED_HEX_STRING_1	DS.B	9

CONVERT_HEX_TO_STRING_1:	DS.W	0	              ;Reserve a word		
    MOVEM.L     D0-D3/A0-A1, -(SP)			;Save registers to stack
    CLR.L       D1						;Clear any prior number from D1
    CLR.L       D0						;Clear any prior number from D0
    MOVE.L      NUMBER_TO_CONVERT_1, D0			;Load number to D0
    MOVE.B      CHARNUM_TO_CONVERT_1, D1			;Load length to D1
    MOVEA.L     #CONVERTED_HEX_STRING_1, A0		;Load string address to convert
    
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
    CLR.L  NUMBER_TO_CONVERT_1                          ;Clear any prior number  
    
    MOVEM.L     (SP)+, D0-D3/A0-A1		       ;Restore registers from stack
    RTS							;Finish subroutine


******************************************* START OF NASH CODE ******************	
*********************************************************************************
* Method Name: TrapTask13_1
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
TrapTask13_1:
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
* Method Name: AsciiToHex_1
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
asciiToHexRegList_1HexRegList REG D0,D6
AsciiToHex_1     
    MOVEM.L asciiToHexRegList_1HexRegList, -(SP)  *save context
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
    MOVEM.L (SP)+,asciiToHexRegList_1HexRegList 
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
MAIN_CONSOLE_1                                                            ;Main print message
   
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
SIZE_1			EQU     20							;Max string size
fileName_1		DC.B    'Config.cfg',0					;Name of text file
IO_BUFFER_1		DS.B    SIZE_1            			        	;Variable for IO buffer
fileID_1			DS.L    1               					;Variable for File ID
INVALID_ADDRES_MESSAGE_1 DC.W 'Invalid Hex Address' ,CR,LF,0			;Invalid message print

    ;INCLUDE "OP_Code_Routines.x68"						;OP role code to include
    ;INCLUDE "EA_Integrated.x68"							;EA role code to include
    ;INCLUDE "MOVEM_TEST.x68"								;Test program to include
*-----------------------------------------------------------
* Title      : OP Code routines for Disassembler
* Written by : Daniel Yan
* Date       : 2/28/2019, Updated 3/17/2019

* Description: Disassembler routines to identify any valid
* OP code dependent on current supported list.
*------------------------------------------------------------
OP_SIZE_1         DS.B    1   ;This constant refers to the size of the current OP code 
MNEMONIC        DS.B    1   ;Constant for EA, first 4 bits (15-12) of a 4 hex OP code
FIRST_3         DS.B    1   ;Constant for EA, 3 bits (11-9) of a 4 hex OP code
SECOND_3        DS.B    1   ;Constant for EA, 3 bits (8-6) of a 4 hex OP code
THIRD_3         DS.B    1   ;Constant for EA, 3 bits (5-3) of a 4 hex OP code
FOURTH_3        DS.B    1   ;Constant for EA, 3 bits (2-0) of a 4 hex OP code

************************************************************************************
*First Nibble Values (15-12)
*Value                  Operations
*$0                     GROUP_0: ORI,BCLR (static and dynamic),CMPI 
*$1                     GROUP_1: MOVE.B                             
*$2                     GROUP_2: MOVE.L, MOVEA.L                    
*$3                     GROUP_3: MOVE.W, MOVEA.W                    
*$4                     GROUP_4: LEA,JSR,RTS,NEG,MOVEM              
*$5                     GROUP_5: SUBQ                               
*$6                     GROUP_6: Bcc(BCS,BGE,BLT,BVC), BRA          
*$7                     GROUP_7: INVALID_OP                         
*$8                     GROUP_8: DIVS, OR                           
*$9                     GROUP_9: SUB                                
*$A                     GROUP_A: INVALID_OP                         
*$B                     GROUP_B: EOR, CMP                           
*$C                     GROUP_C: MULS                               
*$D                     GROUP_D: ADD, ADDA                          
*$E                     GROUP_E: LSR, LSL, ASR, ASL, ROL, ROR       
*$F                     GROUP_F: INVALID_OP                         

* OP_JSR_Routine_1
**********************************************************************************
* Description: Catalog all supported OP codes into groupings based on their hex
* values. Sort the supported OP codes by looking at the first nibble for their
* grouping value. Call underlying subroutines for further identification of the
* op code.
*
* Registers used: A6,D0,D1 
*
* Precondition: Instruction set (size Word) has been loaded in the appropriate
* address to be parsed and read.

* Postcondition: OP code has been identified as either valid or invalid. If it is
* valid, it is stored into A6 and EA parsing methods are called to pass needed
* information to EA. If invalid, DATA output will be utilized to indicate so.
**********************************************************************************
* These valid operand codes refer to the basic supported operand codes
* Groups refer to the first nibble value that is supported by the operand

OP_JSR_Routine_1:
    MOVEM.L D0-D1, -(SP)           ;Backup registers D0 and D1 by pushing it on the Stack
    MOVE.W CUR_OP_CODE_1,D0		   ;Move current instruction set to D0
    MOVE.B #1,IS_VALID_1			   ;Set IS_VALID_1 bit to 1 by default
    MOVE.L #12, D1                 ;Prepare bit shift left for D1   
    LSR.L   D1,D0                  ;Shift 12 bits to only get first 4 bits for D0

GROUP_0:                		   ;$0| ORI, BCLR (static and dynamic), CMPI                  
    CMP.B   #$0,D0                 ;Compare first nibble
    BNE     GROUP_1                ;If first nibble value isn't $0, branch to next
    JSR     C_GROUP_0              ;Jump to group 0 checking if nibble value is $0
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished
    
GROUP_1:                		   ;$1| MOVE.B
    CMP.B   #$1,D0                 ;Compare first nibble
    BNE     GROUP_2                ;If first nibble value isn't $1, branch to next
    JSR     C_GROUP_1              ;Jump to group 1 checking if nibble value is $1
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished

GROUP_2:                		   ;$2| MOVE.L, MOVEA.L
    CMP.B   #$2,D0                 ;Compare first nibble
    BNE     GROUP_3                ;If first nibble value isn't $2, branch to next
    JSR     C_GROUP_2              ;Jump to group 2 checking if nibble value is $2
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished

GROUP_3:                		   ;$3| MOVE.W, MOVEA.W
    CMP.B   #$3,D0                 ;Compare first nibble
    BNE     GROUP_4                ;If first nibble value isn't $3, branch to next
    JSR     C_GROUP_3              ;Jump to group 3 checking if nibble value is $3
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished

GROUP_4:                		   ;$4| LEA, JSR, RTS, NEG, MOVEM
    CMP.B   #$4,D0                 ;Compare first nibble
    BNE     GROUP_5                ;If first nibble value isn't $4, branch to next
    JSR     C_GROUP_4              ;Jump to group 4 checking if nibble value is $4
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished


GROUP_5:                		   ;$5| SUBQ
    CMP.B   #$5,D0                 ;Compare first nibble
    BNE     GROUP_6                ;If first nibble value isn't $5, branch to next
    JSR     C_GROUP_5              ;Jump to group 5 checking if nibble value is $5
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished


GROUP_6:                		   ;$6| Bcc (BCS,BGE,BLT,BVC) BRA
    CMP.B   #$6,D0                 ;Compare first nibble
    BNE     GROUP_7                ;If first nibble value isn't $6, branch to next
    JSR     C_GROUP_6              ;Jump to group 6 checking if nibble value is $6
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished


GROUP_7:                		   ;$7| Display: DATA, $WXYZ (Unsupported)
    CMP.B   #$7,D0                 ;Compare first nibble
    BNE     GROUP_8                ;If first nibble value isn't $7, branch to next
    JSR     C_GROUP_7              ;Jump to group 7 checking if nibble value is $7
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished


GROUP_8:                		   ;$8| DIVS, OR
    CMP.B   #$8,D0                 ;Compare first nibble
    BNE     GROUP_9                ;If first nibble value isn't $8, branch to next
    JSR     C_GROUP_8              ;Jump to group 8 checking if nibble value is $8
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished


GROUP_9:                		   ;$9| SUB
    CMP.B   #$9,D0                 ;Compare first nibble
    BNE     GROUP_A                ;If first nibble value isn't $9, branch to next
    JSR     C_GROUP_9              ;Jump to group 9 checking if nibble value is $9
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished


GROUP_A:                		   ;$A| Display: DATA, $WXYZ (Unsupported)
    CMP.B   #$A,D0                 ;Compare first nibble
    BNE     GROUP_B                ;If first nibble value isn't $A, branch to next
    JSR     C_GROUP_A              ;Jump to group A checking if nibble value is $A
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished


GROUP_B:                		   ;$B| EOR, CMP
    CMP.B   #$B,D0                 ;Compare first nibble
    BNE     GROUP_C                ;If first nibble value isn't $B, branch to next
    JSR     C_GROUP_B              ;Jump to group B checking if nibble value is $B
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished


GROUP_C:                		   ;$C| MULS
    CMP.B   #$C,D0                 ;Compare first nibble
    BNE     GROUP_D                ;If first nibble value isn't $C, branch to next
    JSR     C_GROUP_C              ;Jump to group C checking if nibble value is $C
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished


GROUP_D:                		   ;$D| ADD, ADDA
    CMP.B   #$D,D0                 ;Compare first nibble
    BNE     GROUP_E                ;If first nibble value isn't $D, branch to next
    JSR     C_GROUP_D              ;Jump to group D checking if nibble value is $D
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished


GROUP_E:               			   ;$E| LSR, LSL, ASR, ASL, ROL, ROR
    CMP.B   #$E,D0                 ;Compare first nibble
    BNE     GROUP_F                ;If first nibble value isn't $E, branch to next
    JSR     C_GROUP_E              ;Jump to group E checking if nibble value is $E
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished


GROUP_F:                		   ;$F| Display: DATA, $WXYZ (Unsupported)
    CMP.B   #$F,D0                 ;Compare first nibble
    JSR     C_GROUP_F              ;Jump to group F checking if nibble value is $F
    BRA     OP_JSR_DONE_1            ;Finish subroutine once checking is finished


OP_JSR_DONE_1:					   ;This subroutine is only called when identification has been finished
         MOVEM.L (SP)+,D0-D1       ;Recover register D0
         CMP.B #1,IS_VALID_1		   ;Checks if the IS_VALID_1 bit is valid or not
         BEQ    main_EA            ;This runs EA's routines after OP code portion is finished
         BNE    check_print		   ;If not valid, skip EA routine and call IO
**********************************************************************************    
* FIND_2_BIT_SIZE_1_7_TO_6
**********************************************************************************
* Description: For OP codes with 2 bit size fields, the 2 relevant bits (7-6) will 
* be parsed and moved to the appropriate registers.
*
* Registers used: D0,D1
*
* Precondition: OP code has been identified with 2 size bit field for CUR_OP_CODE_1.
*
* Postcondition: 2 bit size field has been isolated and stored into OP_SIZE_1.
**********************************************************************************
FIND_2_BIT_SIZE_1_7_TO_6:         ;Move the 2 bit size field relevant register
    MOVEM.L  D0-D1,-(SP)        ;Save all changed registers
    MOVE.W   CUR_OP_CODE_1,D0     ;Move current OP code into D0
    MOVE.W   #8,D1              ;Prepare 8 bit shift to D1
    LSL.W    D1,D0              ;Truncate to find the 2 size bits
    LSR.W    D1,D0              ;Reposition the bits
    MOVE.W   #6,D1              ;Prepare 6 bit shift to D1
    LSR.W    D1,D0              ;Truncate to shift 2 bits to a byte
    MOVE.B   D0,OP_SIZE_1         ;Move 2 size bits into OP_SIZE_1
    MOVEM.L (SP)+,D0-D1         ;Restore registers
    RTS                         ;Return to stack
**********************************************************************************

* FIND_1_BIT_SIZE_1_6
**********************************************************************************
* Description: For OP codes with 1 bit size fields, the 1 relevant bit 6 will 
* be parsed and moved to the appropriate registers.
* This particular size parsing is used for MOVEM
*
* Registers used: D0,D1
*
* Precondition: OP code has been identified with 1 size bit field for CUR_OP_CODE_1.
*
* Postcondition: 1 bit size field has been isolated and stored into OP_SIZE_1.
**********************************************************************************
FIND_1_BIT_SIZE_1_6:              ;Move the 1 bit size field relevant register
    MOVEM.L  D0-D1,-(SP)        ;Save all changed registers
    MOVE.W   CUR_OP_CODE_1,D0     ;Move current OP code into D0
    MOVE.W   #9,D1              ;Prepare 9 bit shift to D1
    LSL.W    D1,D0              ;Truncate to find the size bit
    LSR.W    D1,D0              ;Reposition the bits
    MOVE.W   #6,D1              ;Prepare 6 bit shift to D1
    LSR.W    D1,D0              ;Truncate to shift 1 bit to a byte
    MOVE.B   D0,OP_SIZE_1         ;Move 1 size bit into OP_SIZE_1
    MOVEM.L (SP)+,D0-D1         ;Restore registers
    RTS                         ;Return to stack
**********************************************************************************

* FIND_1_BIT_SIZE_1_8
**********************************************************************************
* Description: For OP codes with 1 bit size fields, the 1 relevant bit 8 will 
* be parsed and moved to the appropriate registers.
* This particular size parsing is used for ADDA
*
* Registers used: D0,D1
*
* Precondition: OP code has been identified with 1 size bit field for CUR_OP_CODE_1.
*
* Postcondition: 1 bit size field has been isolated and stored into OP_SIZE_1.
*
**********************************************************************************
FIND_1_BIT_SIZE_1_8:         ;Move the 1 bit size field relevant register
    MOVEM.L  D0-D1,-(SP)        ;Save all changed registers
    MOVE.W   CUR_OP_CODE_1,D0     ;Move current OP code into D0
    MOVE.W   #7,D1              ;Prepare 7 bit shift to D1
    LSL.W    D1,D0              ;Truncate to find the 1 size bit
    LSR.W    D1,D0              ;Reposition the bits
    MOVE.W   #8,D1              ;Prepare 8 bit shift to D1
    LSR.W    D1,D0              ;Truncate to shift 1 bit to a byte
    MOVE.B   D0,OP_SIZE_1         ;Move 1 size bit into OP_SIZE_1
    MOVEM.L (SP)+,D0-D1         ;Restore registers
    RTS                         ;Return to stack
**********************************************************************************

* MOVE_AND_MOVEA_PARSE_EA
**********************************************************************************
* Description: Special parsing for the SRC and DST Mode/Reg for MOVE/MOVE
*
* Registers used: A6,D0,D1,D7,D6,D5,D4
*
* Precondition: OP code has been identified with either MOVE or MOVEA
*
* Postcondition: Store all relevant EA bits into associated register.
* This particular routine is not Callee saved as it needs to change D7 and D6
**********************************************************************************
MOVE_AND_MOVEA_PARSE_EA:     ;Move the 3 bit dynamic register bits to proper register
    MOVE.W CUR_OP_CODE_1,D0    ;Move current OP code into D0
    MOVE.W  #10,D1           ;Prepare 10 bit shift to D1
    LSL.W   D1,D0            ;Truncate to find the last 6 bits
    LSR.W   D1,D0            ;Shift back to get the proper 6 bits
    MOVE.W  D0,D7            ;Move last 6 bits into D7, SRC REG MODE
    MOVE.W  #3,D1            ;Prepare 3 bit shift into D1
    LSR.W   D1,D7            ;Shift 3 bits off D7 to obtain EA Mode
    MOVE.W  D7,D5            ;Move the 'upper' 3 bits into D6
    MOVE.W  #13,D1           ;Prepare 13 bit shift into D1
    LSL.W   D1,D0            ;Shift D0 left 13 bits to reposition current 3 bits
    LSR.W   D1,D0            ;Shift D0 right 13 bits to reposition current 3 bits
    MOVE.W  D0,D4            ;Move the 'lower' 3 bits into D7
	
****MOVING_SOURCE***********
    MOVE.W CUR_OP_CODE_1,D0    ;Move current OP code into D0     
    MOVE.W  #4,D1            ;Prepare 4 bit shift to D1
    LSL.W   D1,D0            ;Truncate to find bits 11-6
    LSR.W   D1,D0            ;Reposition bits
    MOVE.W  #6,D1            ;Prepare 6 bit shift to D1
    LSR.W   D1,D0            ;Truncate the SRC Reg/Mode bits
    MOVE.W  #3,D1            ;Prepare a 3 bit shift to D1 for DST Reg/Mode
    MOVE.W  D0,D6            ;Copy over the current 6 bits to D6
    LSR.W   D1,D0            ;Truncate DST Mode  
    MOVE.W  D0,D7            ;Move DST Reg to D7
    MOVE.W  #13,D1             
    LSL.W   D1,D6            ;Truncate 13 bits in D6
    LSR.W   D1,D6            ;Reposition D6
                             ;D6 now contains the DST Reg
    RTS                      ;Return to stack
**********************************************************************************
********** EA Parsing ************************************************************
*PARSE_EA_CONSTANT_BITS
**********************************************************************************
* Definition: Uses CUR_OP_CODE_1 to shift the proper bits into the global constants
* used for EA (MNEMONIC,FIRST_3,SECOND_3,THIRD_3,FOURTH_3. Where MNEMONIC refers
* to the first 4 bits of CUR_OP_CODE_1 (15-12), FIRST_3 refers to the first group
* of 3 bits (11-9), SECOND_3 refers to the second group of 3 bits (8-6), THIRD_3
* refers to the third group of 3 bits (5-3), and FOURTH_3 refers to the fourth
* group of 3 bits (2-0). Shifts CUR_OP_CODE_1 bits to initialize constants.
*
* Registers used: D0,D1
*
* Precondition: CUR_OP_CODE_1 has been set with an 4 hex instruction set
* 
* Postcondition: MNEMONIC, FIRST_3, SECOND_3, THIRD_3, FOURTH_3 have been set
* to the corresponding values.
**********************************************************************************
PARSE_EA_CONSTANT_BITS:
	MOVEM.L D0-D1,-(SP)			;Save register to stack
    *MNEMONIC SHIFT
    MOVE.W CUR_OP_CODE_1,D0       ;Load in current instruction set into D0
    MOVE.W #12,D1               ;Prepare a bit shift of 12 into D1
    LSR.W D1,D0                 ;Shift 12 bits from D0 right
    MOVE.B D0,MNEMONIC          ;Set MNEMONIC to D0
    *FIRST_3 SHIFT
    MOVE.W #9,D1                ;Prepare a bit shift of 9 into D1
    MOVE.W CUR_OP_CODE_1,D0       ;Load in current instruction set into D
    LSL.W #4,D0                 ;Shift out bits 15-12 in D0
    LSR.W #4,D0                 ;Reposition D0
    LSR.W  D1,D0                ;Shift D0 9 bits right
    MOVE.B D0,FIRST_3           ;Set FIRST_3 to D0
    *SECOND_3 SHIFT
    MOVE.W CUR_OP_CODE_1,D0       ;Load in current instruction set into D
    LSL.W #7,D0                 ;Shift out bits 15-9 in D0
    LSR.W #7,D0                 ;Reposition D0
    LSR.W #6,D0                 ;Shift D0 6 bits right
    MOVE.B D0,SECOND_3          ;Set SECOND_3 to D0
    *THIRD_3 SHIFT
    MOVE.W CUR_OP_CODE_1,D0       ;Load in current instruction set into D
    LSR.W #3,D0                 ;Shift D0 3 bits right
    MOVE.W #13,D1               ;Prepare a 13 bit shift into D1
    LSL.W D1,D0                 ;Truncate first 13 bits of D0
    LSR.W D1,D0                 ;Reposition D0
    MOVE.B D0,THIRD_3           ;Set THIRD_3 to D0
    *FOURTH_3 SHIFT
    MOVE.W CUR_OP_CODE_1,D0       ;Load in current instruction set into D
    LSL.W D1,D0                 ;Grab the fourth 3-bit group
    LSR.W D1,D0                 ;Shift D0 back into position
    MOVE.B D0,FOURTH_3          ;Set FOURTH_3 to Do
	MOVEM.L (SP)+,D0-D1			;Restore registers
    RTS                         ;Return to stack
**********************************************************************************
********** End of EA Parsing *****************************************************

*******************JMP LABELS ****************************************************
* Labeling for group codes will be in the following format

* <JMP Label Name>
********************************************************************************
* Checking List Order (If more than one value)
* Operand1 - $<nibble value>, a-b <specifier>, c-d <specifier> ...
* Operand2 - $<nibble value>, a-b <specifier>, c-d <specifier> ...

* Where a-b will refer to the bit corresponding bit value in the instruction
* format, and a specifier will be attached such as Size, EA Mode, SRC Reg, etc
* to clarify what a specific bit range means.
* Checking order refers to what order the checks will be performed in. 
* Any other code outside of the listed supported ones will be routed toINVALID_OP.
********************************************************************************

********************************************************************************
* Global Field Descriptions
* Size Field: Byte = 00 Word = 01 Long = 10
* EA Mode: Refer to EA Address Modes
* EA Reg: 3-bit input that is mapped to the respective binary value
********************************************************************************

* GROUP_0                      
********************************************************************************
* Description: Checks for the following listed OP codes to be present or not
* Supported OP codes:
* ORI: $00, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
* CMPI: $0C, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
* Dynamic BCLR: $0, 11-9 Register, 8-6 %110, 5-3 EA Mode, 2-0 EA Reg
* Static BCLR: $01, 7-6 10, 5-3 EA Mode, 2-0 EA Reg
*
* Register(s) used: D0
*
* Precondition: First nibble has been identified as $0
*
* Postcondition: Parses proper OP code with a nibble value of $0 or finds an
* invalid OP code.
* 
* Unsupported OP codes:
* ORI_TO_CCR, ORI_TO_SR, ANDI_TO_CCR, ANDI_TO_SR, ANDI, SUBI, ADDI, EORI_TO_CCR
* EORI_TO_SR, EORI, STATIC_BTST, STATIC_BCHG, STATIC_BSET, DYNAMIC_BTST,
* DYNAMIC_BCHG, DYNAMIC_BSET, MOVEP 
********************************************************************************
C_GROUP_0:
    MOVEM.L D0-D1, -(SP)        	;Backup registers
	
*Unsupported OP codes that are fully static in bits
CHECK_OP_ORI_TO_CCR:
    MOVE.W CUR_OP_CODE_1,D0      		;Move current instruction set into D0
    CMP.W #$003C,D0            		;Compare the direct full bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_ORI_TO_SR     		;Check next routine
    
CHECK_OP_ORI_TO_SR:
    MOVE.W CUR_OP_CODE_1,D0      		;Move current instruction set into D0
    CMP.W #$007C,D0            		;Compare the direct full bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_ANDI_TO_CCR   		;Check next routine
    
CHECK_OP_ANDI_TO_CCR:
    MOVE.W CUR_OP_CODE_1,D0      		;Move current instruction set into D0
    CMP.W #$023C,D0            		;Compare the direct full bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_ANDI_TO_SR    		;Check next routine
    
CHECK_OP_ANDI_TO_SR:
    MOVE.W CUR_OP_CODE_1,D0      		;Move current instruction set into D0
    CMP.W #$027C,D0            		;Compare the direct full bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_EORI_TO_CCR          		;Check next routine

CHECK_OP_EORI_TO_CCR:
    MOVE.W CUR_OP_CODE_1,D0      		;Move current instruction set into D0
    CMP.W #$0A3C,D0            		;Compare the direct full bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_EORI_TO_SR    		;Check next routine
    
CHECK_OP_EORI_TO_SR:
    MOVE.W CUR_OP_CODE_1,D0      		;Move current instruction set into D0
    CMP.W #$0A7C,D0            		;Compare the direct full bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_ANDI          		;Check next routine
    
*Unsupported OP codes to check with partial static bits
CHECK_OP_ANDI:
    MOVE.W CUR_OP_CODE_1,D0      		;Move current instruction set into D0
    ANDI.W #$FF00,D0           		;Mask relevant bits to D0
    CMP.W #$0200,D0            		;Compare the appropriate masked bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_SUBI          		Check next routine
    
CHECK_OP_SUBI:
    MOVE.W CUR_OP_CODE_1,D0      		;Move current instruction set into D0
    ANDI.W #$FF00,D0           		;Mask relevant bits to D0
    CMP.W #$0400,D0            		;Compare the appropriate masked bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_ADDI          		;Check next routine

CHECK_OP_ADDI:
    MOVE.W CUR_OP_CODE_1,D0      		;Move current instruction set into D0
    ANDI.W #$FF00,D0           		;Mask relevant bits to D0
    CMP.W #$0600,D0            		;Compare the appropriate masked bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_EORI          		;Check next routine 

CHECK_OP_EORI:
    MOVE.W CUR_OP_CODE_1,D0      		;Move current instruction set into D0
    ANDI.W #$FF00,D0           		;Mask relevant bits to D0
    CMP.W #$0A00,D0            		;Compare the appropriate masked bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_STATIC_BTST   		;Check next routine
    
CHECK_OP_STATIC_BTST:
    MOVE.W CUR_OP_CODE_1,D0      		;Move current instruction set into D0
    ANDI.W #$FFC0,D0           		;Mask relevant bits to D0
    CMP.W #$0800,D0            		;Compare the appropriate masked bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_STATIC_BCHG   		;Check next routine
    
CHECK_OP_STATIC_BCHG:
    MOVE.W CUR_OP_CODE_1,D0   	    ;Move current instruction set into D0
    ANDI.W #$FFC0,D0        	    ;Mask relevant bits to D0
    CMP.W #$0840,D0         	    ;Compare the appropriate masked bits
    BEQ GROUP0_INVALID         		;INVALID OP code found
    BNE CHECK_OP_STATIC_BSET   		;Check next routine

CHECK_OP_STATIC_BSET:
    MOVE.W CUR_OP_CODE_1,D0   	    ;Move current instruction set into D0
    ANDI.W #$FFC0,D0        	    ;Mask relevant bits to D0
    CMP.W #$08C0,D0         	    ;Compare the appropriate masked bits
    BEQ GROUP0_INVALID      	    ;INVALID OP code found   
    BNE CHECK_OP_DYNAMIC_BTST  		;Check next routine

CHECK_OP_DYNAMIC_BTST:
    MOVE.W CUR_OP_CODE_1,D0   	    ;Move current instruction set into D0
    ANDI.W #$F1C0,D0        	    ;Mask relevant bits to D0
    CMP.W #$0100,D0         	    ;Compare the appropriate masked bits
    BEQ GROUP0_INVALID      	    ;INVALID OP code found
    BNE CHECK_OP_DYNAMIC_BCHG  		;Check next routine

CHECK_OP_DYNAMIC_BCHG:
    MOVE.W CUR_OP_CODE_1,D0       	;Move current instruction set into D0
    ANDI.W #$F1C0,D0            	;Mask relevant bits to D0
    CMP.W #$0140,D0             	;Compare the appropriate masked bits 
    BEQ GROUP0_INVALID          	;INVALID OP code found
    BNE CHECK_OP_DYNAMIC_BSET   	;Check next routine
    
CHECK_OP_DYNAMIC_BSET:

    MOVE.W  CUR_OP_CODE_1,D0      	;Move current instruction set into D0
    ANDI.W  #$F1C0,D0           	;Mask relevant bits to D0
    CMP.W   #$01C0,D0           	;Compare the appropriate masked bits 
    BEQ     BIT_CHECK_MOVEP     	;Check special case for MOVEP
    BNE     CHECK_OP_MOVEP      	;Check next routine

BIT_CHECK_MOVEP:								;This is a special case check for MOVEP
    MOVE.W  CUR_OP_CODE_1,D0      	;Move current instruction set into D0
    MOVE.W  #10,D1              	;Prepare a 10-bit shift
    LSL.W   D1,D0               	;Shift out 10 bits left 
    LSR.W   D1,D0               	;Reposition D0 for last 6 bits
    LSR.W   #3,D0               	;Shift out 3 bits right, D0 contains bits 5-3
    CMP.W   #$1,D0              	;Compare bits to D0
    BEQ     CHECK_OP_MOVEP      	;If bits are $1 then it's addressing, goto MOVEP
    BNE     GROUP0_INVALID      	;If not then it's DYNAMIC_BSET which is invalid
	
CHECK_OP_MOVEP:
    MOVE.W CUR_OP_CODE_1,D0       	;Move current instruction set into D0
    ANDI.W #$F138,D0            	;Mask relevant bits to D0
    CMP.W #$0108,D0             	;Compare the appropriate masked bits
    BEQ INVALID_OP              	;INVALID OP code found
    BNE CHECK_OP_ORI            	;Check next routine

*Supported OP code checks
CHECK_OP_ORI:
    MOVE.W  CUR_OP_CODE_1,D0          ;Move current instruction set into D0
    ANDI.W  #$FF00,D0               ;Mask relevant bits to D0
    CMP.W   #$0000,D0               ;Compare the appropriate masked bits     
    BNE     CHECK_OP_CMPI           ;Branch to next comparison if not equal
    JSR     FIND_2_BIT_SIZE_1_7_TO_6
    JSR     PRINT_OP_ORI            ;Print the OP code if equal    
    BRA     GROUP0_SUCCESS          ;Finish routine
    
CHECK_OP_CMPI:
    MOVE.W  CUR_OP_CODE_1,D0          ;Move current instruction set into D0
    ANDI.W  #$FF00,D0               ;Mask relevant bits to D0
    CMP.W   #$0C00,D0               ;Compare the appropriate masked bits   
    BNE     CHECK_OP_STATIC_BCLR    ;Branch to next comparison if not equal       
    JSR     FIND_2_BIT_SIZE_1_7_TO_6
    JSR     PRINT_OP_CMPI           ;Print the OP code if equal
    BRA     GROUP0_SUCCESS          ;Finish routine
    
CHECK_OP_STATIC_BCLR:
    MOVE.W  CUR_OP_CODE_1,D0          ;Move current instruction set into D0
    ANDI.W  #$FF00,D0               ;Mask relevant bits to D0
    CMP.W   #$0800,D0               ;Compare the appropriate masked bits
    BNE     CHECK_OP_DYNAMIC_BCLR   ;Branch to next comparison if not equal
    JSR     FIND_2_BIT_SIZE_1_7_TO_6
    JSR     PRINT_OP_STATIC_BCLR    ;Print the OP code if equal
    BRA     GROUP0_SUCCESS          ;Finish routine
    
CHECK_OP_DYNAMIC_BCLR:
    MOVE.W  CUR_OP_CODE_1,D0          ;Move current instruction set into D0
    ANDI.W  #$0180,D0   			;Mask relevant bits to D0
    CMP.W   #$0180,D0   			;Compare the appropriate masked bits
    BNE     GROUP0_INVALID          ;If not equal this must be an invalid OP code
    JSR     FIND_2_BIT_SIZE_1_7_TO_6
    JSR     PRINT_OP_DYNAMIC_BCLR   ;Print the OP code if equal
    BRA     GROUP0_SUCCESS          ;Finish routine

GROUP0_INVALID:                     ;Checks have been finished, invalid OP code has been found
    JSR INVALID_OP                  ;INVALID OP code found
GROUP0_SUCCESS:                     ;Checks have been finished,a valid OP code has been found
    MOVEM.L (SP)+,D0-D1             ;Restore registers
    RTS                             ;Return to stack
    
* GROUP_1                      
********************************************************************************
* Description: Checks for the following OP code to be present or not.
* Supported OP code:
* MOVE.B: $1, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
*
* Register(s) used: D0,D1
*
* Precondition: First nibble has been identified as $1
*
* Postcondition: Parses proper OP code with a nibble value of $1 or finds an
* invalid OP code.********************************************************************************
C_GROUP_1:
    MOVEM.L D0-D1,-(SP)             ;Save registers to stack

CHECK_OP_MOVE_B:
    MOVE.W  CUR_OP_CODE_1,D0          ;Move current instruction set into D0          
    ANDI.W  #$F000,D0               ;Mask relevant bits to D0
    CMP.W   #$1000,D0               ;Compare the appropriate masked bits 
    BNE     GROUP1_INVALID          ;Invalid OP code has been found
    JSR     PRINT_OP_MOVEB          ;Print the OP code if equal
    BRA     GROUP1_SUCCESS          ;Finish routine
    
GROUP1_INVALID:
    JSR INVALID_OP                  ;Invalid OP code found
GROUP1_SUCCESS:
    MOVEM.L (SP)+,D0-D1             ;Restore register
    RTS                             ;Return to stack
* GROUP_2
********************************************************************************
* Description: Checks for the following list of OP codes to be present or not.
* Supported OP codes:
* MOVEA.L: $2, 11-9 DST Reg, 8-6 %001, 5-3 SRC Mode, 2-0 SRC Reg
* MOVE.L: $2, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
*
* Register(s) used: D0,D1,D2
*
* Precondition: First nibble has been identified as $2
*
* Postcondition: Parses proper OP code with a nibble value of $2 or finds an
* invalid OP code.********************************************************************************
C_GROUP_2:
    MOVEM.L D0-D2,-(SP)             ;Save registers to stack

CHECK_OP_MOVEA_L:
    MOVE.W CUR_OP_CODE_1,D0           ;Move current instruction set into D0  
    ANDI.W #$F000,D0                ;Mask relevant bits to D0
    CMP.W #$2000,D0                 ;Compare the appropriate masked bits
    JMP FIND_MOVEA_L_DIFFERENCE     ;Branch always to check 
    
FIND_MOVEA_L_DIFFERENCE:            ;Finds difference between MOVEA and MOVE
    MOVE.W   CUR_OP_CODE_1,D0         ;Move current OP code into D0
    MOVE.W   #7,D1                  ;Prepare 7 bit shift to D1
    LSL.W    D1,D0                  ;Truncate to find the 3 address mode bits
    LSR.W    D1,D0                  ;Reposition the bits
    MOVE.W   #6,D1                  ;Prepare 6 bit shift to D1
    LSR.W    D1,D0                  ;Truncate to shift 3 bits to a register
    MOVE.W   D0,D2                  ;Move 3 address mode bits into D6
    CMP.W   #$1,D2                  ;Check if the address mode value is MOVEA
    BNE     CHECK_OP_MOVE_L         ;Branch if not equal to check MOVE
    JSR     PRINT_OP_MOVEA_L        ;Print the OP code if it's a match
    BRA     GROUP2_SUCCESS          ;Finish routine
    
    
CHECK_OP_MOVE_L:
    MOVE.W CUR_OP_CODE_1,D0           ;Move current instruction set into D0
    ANDI.W #$F000,D0                ;Mask relevant bits to D0
    CMP.W #$2000,D0                 ;Compare the appropriate masked bits
    BNE GROUP2_INVALID              ;If not equal, OP code is invalid
    JSR PRINT_OP_MOVE_L             ;Print out MOVE.L
    BRA GROUP2_SUCCESS              ;Finish routine
    
GROUP2_INVALID:    
    JSR INVALID_OP                  ;Invalid OP code found
GROUP2_SUCCESS:
    MOVEM.L (SP)+,D0-D2             ;Restore register
    RTS                             ;Return to stack
* GROUP_3
********************************************************************************
* Description: Checks for the following list of OP codes to be present or not.
* Supported OP codes:
* MOVEA.W: $3, 11-9 DST Reg, 8-6 %001, 5-3 SRC Mode, 2-0 SRC Reg
* MOVE.W: $3, 11-9 DST Reg, 8-6 DST Mode, 5-3 SRC Mode, 2-0 SRC Reg
*
* Register(s) used: D0,D1,D2
*
* Precondition: First nibble has been identified as $3
*
* Postcondition: Parses proper OP code with a nibble value of $3 or finds an
* invalid OP code.
********************************************************************************
C_GROUP_3:
    MOVEM.L D0-D2,-(SP)			    ;Save registers to stack
	
CHECK_OP_MOVEA_W:
    MOVE.W   CUR_OP_CODE_1,D0        ;Move current instruction set into D0
    ANDI.W   #$F000,D0			   ;Mask relevant bits to D0
    CMP.W    #$3000,D0			   ;Compare the appropriate masked bits
    JMP      FIND_MOVEA_W_DIFF	   ;Custom routine to differentiate MOVE and MOVEA

    
FIND_MOVEA_W_DIFF:      		   ;Finds difference between MOVEA and MOVE
    MOVE.W   CUR_OP_CODE_1,D0        ;Move current instruction set into D0
    MOVE.W   #7,D1          	   ;Prepare 7 bit shift to D1
    LSL.W    D1,D0          	   ;Truncate to find the 3 address mode bits
    LSR.W    D1,D0          	   ;Reposition the bits
    MOVE.W   #6,D1          	   ;Prepare 6 bit shift to D1
    LSR.W    D1,D0          	   ;Truncate to shift 3 bits to a register
    MOVE.W   D0,D2          	   ;Move 3 address mode bits into D6
    CMP.W    #$1,D2          	   ;Check if the address mode value is MOVEA
    BNE      CHECK_OP_MOVE_W	   ;If bits do not match, try MOVE 
    JSR      PRINT_OP_MOVEA_W  	   ;Print the OP code if it's a match
    BRA      GROUP3_SUCCESS		   ;Finish routine
    
CHECK_OP_MOVE_W:
    MOVE.W   CUR_OP_CODE_1,D0    	   ;Move current instruction set into D0
    ANDI.W   #$F000,D0			   ;Mask relevant bits to D0
    CMP.W    #$3000,D0			   ;Compare the appropriate masked bits
    BNE      GROUP3_INVALID        ;INVALID OP code found
    JSR      PRINT_OP_MOVE_W	   ;Print the OP code if it's a match
    BRA      GROUP3_SUCCESS        ;Finish routine
    
GROUP3_INVALID:
    JSR INVALID_OP				   ;INVALID OP code found
GROUP3_SUCCESS:
    MOVEM.L (SP)+,D0-D2 		   ;Restore registers from stack
    RTS							   ;Return to stack

* GROUP_4
********************************************************************************
* Description: Checks for the following list of OP codes to be present or not.
* Supported OP codes:
* LEA: $4, 11-9 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
* JSR: $4E, 7-6 %10, 5-3 EA Mode, 2-0 EA Reg 
* RTS: $4E75
* NEG: $44, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
* MOVEM: $4, 11 %1, 10 %D, 9-7 %001, 6 S, 5-3 EA Mode, 2-0 EA Reg
* %D = 0 , Register to Memory, 1 Memory to Register
*
* Register(s) used: D0
*
* Precondition: First nibble has been identified as $4
*
* Postcondition: Parses proper OP code with a nibble value of $4 or finds an
* invalid OP code. 
*
* Unsupported OP codes: MOVE_FROM_SR, MOVE_TO_CCR, MOVE_TO_SR, NEGX, CLR, NOT
* EXT, NBCD, SWAP, PEA, ILLEGAL, TAS, TST, TRAP, LINK, UNLK, MOVE_USP, RESET,
* NOP, STOP, RTE, TRAPV, RTR, JMP, CHK
********************************************************************************
C_GROUP_4:
    MOVE.L  D0,-(SP)         	;Save registers
	
*Unsupported OP codes to check that are full static bits
CHECK_OP_STOP:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    CMP.W  #$4E72,D0	     		;Compare the appropriate bits
    BEQ    GROUP4_INVALID    		;INVALID OP code found
    BNE    CHECK_OP_RESET    		;Check next OP code
    
CHECK_OP_RESET:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    CMP.W  #$4E70,D0	     		;Compare the appropriate bits
    BEQ    GROUP4_INVALID	 		;INVALID OP code found
    BNE    CHECK_OP_ILLEGAL         ;Check next OP code
        
CHECK_OP_ILLEGAL:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    CMP.W  #$4AFC,D0	     		;Compare the appropriate bits
    BEQ    GROUP4_INVALID	 		;INVALID OP code found
    BNE    CHECK_OP_RTE      		;Check next OP code
    
CHECK_OP_RTE:    
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    CMP.W #$4E73,D0	         		;Compare the appropriate bits
    BEQ   GROUP4_INVALID	 		;INVALID OP code found
    BNE   CHECK_OP_TRAPV     		;Check next OP code
    
CHECK_OP_TRAPV:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    CMP.W  #$4E76,D0	     		;Compare the appropriate bits
    BEQ    GROUP4_INVALID	 		;INVALID OP code found
    BNE    CHECK_OP_RTR      		;Check next OP code
    
CHECK_OP_RTR:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    CMP.W #$4E77,D0	     	 		;Compare the appropriate bits
    BEQ    GROUP4_INVALID	 		;INVALID OP code found
    BNE    CHECK_OP_MOVE_FROM_SR   	;Check next OP code


*Unsupported OP codes to check that have partial static bits
CHECK_OP_MOVE_FROM_SR:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask relevant bits to D0
    CMP.W  #$40C0,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code found	
    BNE    CHECK_OP_MOVE_TO_CCR		;Check next OP code
    
CHECK_OP_MOVE_TO_CCR:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask relevant bits to D0
    CMP.W  #$44C0,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code found
    BNE    CHECK_OP_MOVE_TO_SR		;Check next OP code
    
CHECK_OP_MOVE_TO_SR:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask relevant bits to D0
    CMP.W  #$46C0,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code found
    BNE    CHECK_OP_NEGX			;Check next OP code
    
CHECK_OP_NEGX:
    MOVE.W CUR_OP_CODE_1,D0   		 ;Move current instruction set into D0
    ANDI.W #$FF00,D0				;Mask relevant bits to D0
    CMP.W  #$4000,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code found
    BNE    CHECK_OP_CLR				;Check next OP code
    
CHECK_OP_CLR:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$FF00,D0				;Mask relevant bits to D0
    CMP.W  #$4200,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code found
    BNE    CHECK_OP_NOT				;Check next OP code
    
CHECK_OP_NOT:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$FF00,D0				;Mask relevant bits to D0
    CMP.W  #$4600,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code found
    BNE    CHECK_OP_EXT				;Check next OP code
    
CHECK_OP_EXT:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$FFB8,D0				;Mask relevant bits to D0
    CMP.W  #$4880,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code BIT_CHECK_EXT
    BNE    CHECK_OP_NBCD			;Check next OP code

BIT_CHECK_EXT:    
    MOVE.W CUR_OP_CODE_1,D0    		;This is a special case to check against MOVEM
    MOVE.W #10,D1					;Prepare a 10 bit shift into D1
    LSL.W  D1,D0					;Shift D0 left 10 bits
    LSR.W  D0,D0					;Reposition D0
    LSR.W  #3,D0					;Shift D0 3 bits
    CMP.W  %000,D0					;Check the specific bits needed to differentiate EXT
    BEQ    GROUP4_INVALID  			;This means that this OP code is EXT
    BNE    MOVEM_BIT_SIZE_1_CHECK  	;This is the only other possibility 
    
CHECK_OP_NBCD:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask relevant bits to D0			
    CMP.W  #$4800,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_SWAP			;Check next OP code
    
CHECK_OP_SWAP:                  	; This must go before CHECK_OP PEA as first 3 nibbles can be equivalent
    MOVE.W CUR_OP_CODE_1,D0       	;Move current instruction set into D0
    ANDI.W #$FFF8,D0				;Mask relevant bits to D0
    CMP.W  #$4840,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_PEA				;Check next OP code
 
CHECK_OP_PEA:               		;This must go after CHECK_OP_SWAP as first 3 nibbles can be equivalent
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask relevant bits to D0
    CMP.W  #$4840,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_TAS				;Check next OP code
    
CHECK_OP_TAS:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask relevant bits to D0
    CMP.W  #$4AC0,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_TST				;Check next OP code

CHECK_OP_TST:               		;This must go after CHECK_OP_TAS as first 2 nibbles are equivalent
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$FF00,D0				;Mask relevant bits to D0
    CMP.W  #$4A00,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_TRAP			;Check next OP code
    
CHECK_OP_TRAP:
    MOVE.W CUR_OP_CODE_1,D0		    ;Move current instruction set into D0
    ANDI.W #$FFF0,D0				;Mask relevant bits to D0
    CMP.W  #$4E40,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_LINK			;Check next OP code
    
CHECK_OP_LINK:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$FFF8,D0				;Mask relevant bits to D0
    CMP.W  #$4E50,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_UNLK			;Check next OP code

CHECK_OP_UNLK:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$FFF8,D0				;Mask relevant bits to D0
    CMP.W  #$4E58,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_MOVE_USP	    ;Check next OP
    
CHECK_OP_MOVE_USP:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$FFF0,D0				;Mask relevant bits to D0
    CMP.W  #$4E60,D0				;Compare the appropriate masked bits
    BEQ    GROUP4_INVALID			;INVALID OP code
    BNE    CHECK_OP_JMP				;Check next OP

CHECK_OP_JMP:
     MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
     ANDI.W #$FFC0,D0				;Mask relevant bits to D0
     CMP.W  #$4EC0,D0				;Compare the appropriate masked bits
     BEQ    GROUP4_INVALID			;INVALID OP code
     BNE    CHECK_OP_CHK			;Check next OP code
     
CHECK_OP_CHK:
    MOVE.W  CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W  #$F1C0,D0				;Mask relevant bits to D0
    CMP.W   #$4180,D0				;Compare the appropriate masked bits
    BEQ     INVALID_OP				;INVALID OP code
    BNE     CHECK_OP_NOP			;Check next OP code

*Supported OP codes to check
CHECK_OP_NOP:                       ;While this code is not in the supported docs, Nash covered it in class and expects it to be implemented
    MOVE.W CUR_OP_CODE_1,D0   		;Move current instruction set into D0
    CMP.W  #$4E71,D0	     		;Compare the appropriate bits
    BNE    CHECK_OP_RTS       		;Check next OP code
    JSR    PRINT_OP_NOP             ;Print out OP code
    BRA    GROUP4_SUCCESS           ;Finish routine
    
CHECK_OP_RTS:
    MOVE.W CUR_OP_CODE_1,D0		    ;Move current instruction set into D0
    CMP.W  #$4E75,D0				;Mask exact bits for RTS	
    BNE    CHECK_OP_LEA				;If it's equal check next code
    JSR    PRINT_OP_RTS				;Print out OP code
    BRA    GROUP4_SUCCESS           ;Finish routine
 
CHECK_OP_LEA:
    MOVE.W CUR_OP_CODE_1,D0   		;Move current instruction set into D0
    ANDI.W #$F1C0,D0				;Mask appropriate bits
    CMP.W  #$41C0,D0				;Compare masked bits
    BNE    CHECK_OP_JSR				;Check next OP code
    JSR    PRINT_OP_LEA				;Print out OP code
    BRA    GROUP4_SUCCESS           ;Finish routine
 
CHECK_OP_JSR:
    MOVE.W CUR_OP_CODE_1,D0  			;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask appropriate bits
    CMP.W  #$4E80,D0				;Compare masked bits
    BNE    CHECK_OP_NEG				;Check next OP code
    JSR    PRINT_OP_JSR				;Print out OP code
    BRA    GROUP4_SUCCESS           ;Finish routine
    
CHECK_OP_NEG:
    MOVE.W CUR_OP_CODE_1,D0   		;Move current instruction set into D0
    ANDI.W #$FF00,D0				;Mask appropriate bits
    CMP.W  #$4400,D0				;Compare masked bits
    BNE    MOVEM_BIT_SIZE_1_CHECK		;Check next OP code
    JSR    FIND_2_BIT_SIZE_1_7_TO_6	;Find size field
    JSR    PRINT_OP_NEG				;Print out OP code
    BRA    GROUP4_SUCCESS           ;Finish routine
    
MOVEM_BIT_SIZE_1_CHECK:
    MOVE.W CUR_OP_CODE_1,D0           ;Move current instruction set into D0
    JSR    FIND_1_BIT_SIZE_1_6        ;Parse size for bit 6
    CMP.B  #%0,OP_SIZE_1              ;Check size bit
    BEQ    CHECK_OP_MOVEM_W         ;If 0 it's a word
    BNE    CHECK_OP_MOVEM_L         ;If 1 it's a long

*Special checking for MOVEM sizes
CHECK_OP_MOVEM_W:
    MOVE.W CUR_OP_CODE_1,D0   		;Move current instruction set into D0
    ANDI.W #$FB80,D0				;Mask appropriate bits
    CMP.W  #$4880,D0				;Compare masked bits
    BNE    GROUP4_INVALID           ;INVALID OP code is found
    JSR    PRINT_OP_MOVEM_W         ;PRINT OP code
    BRA    GROUP4_SUCCESS           ;Finish routine
    
CHECK_OP_MOVEM_L:
    MOVE.W CUR_OP_CODE_1,D0   		;Move current instruction set into D0
    ANDI.W #$FB80,D0				;Mask appropriate bits
    CMP.W  #$4880,D0				;Compare masked bits
    BNE    GROUP4_INVALID           ;INVALID OP code is found
    JSR    PRINT_OP_MOVEM_L         ;Print OP code
    BRA    GROUP4_SUCCESS           ;Finish routine    
    
GROUP4_INVALID:
    JSR INVALID_OP					;INVALID op code has been found, set IS_VALID_1 to 0

GROUP4_SUCCESS:
    MOVEM.L (SP)+,D0 				;Restore saved registers
    RTS								;Return to stack
* GROUP_5
********************************************************************************
* Description: CHecks for the following list of OP codes to be present or not.
* Supported OP code:
* SUBQ: $5, 11-9 DATA, 8 %1, 7-6 Size, 5-3 EA Mode, 2-0 EA Reg
*
* Register(s) used: D0
*
* Precondition: First nibble has been identified as $5
*
* Postcondition: Parses proper OP code with a nibble value of $5 or finds an
* invalid OP code. 
*
* Unsupported OP codes: ADDQ, Scc, DBcc
********************************************************************************
C_GROUP_5:
    MOVEM.L D0,-(SP)         		;Save registers to stack
*Unsupported OP codes
CHECK_OP_DBcc:               		;These are ordered first due to checking bits 7-6
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$F0C8,D0		 		;Mask appropriate bits
    CMP.W  #$50C8,D0				;Compare appropriate masked bits
    BEQ    GROUP5_INVALID			;INVALID op code found
    BNE    CHECK_OP_Scc 			;Check next OP code

CHECK_OP_Scc:
    MOVE.W CUR_OP_CODE_1,D0   		;Move current instruction set into D0
    ANDI.W #$F0C0,D0 				;Mask appropriate bits
    CMP.W  #$50C0,D0				;Compare appropriate masked bits
    BEQ     GROUP5_INVALID			;INVALID OP code found
    BNE     CHECK_OP_ADDQ			;Check next OP code

CHECK_OP_ADDQ:
    MOVE.W CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$F100,D0				;Mask appropriate bits
    CMP.W  #$5000,D0				;Compare appropriate masked bits
    BEQ    GROUP5_INVALID			;INVALID OP code found
    BNE    CHECK_OP_SUBQ			;Check next OP code

*Supported OP code   
CHECK_OP_SUBQ     
    MOVE.W  CUR_OP_CODE_1,D0  		;Actual check for SUBQ
    ANDI.W #$F100,D0        		;Bitmask check for SUBQ
    CMP.W  #$5100,D0        		;Compare the proper value
    BNE    GROUP5_INVALID       	;Else the operand is invalid
    JSR    FIND_2_BIT_SIZE_1_7_TO_6	;Find size bit to print
    JSR    PRINT_OP_SUBQ    		;If equal print it out
    BRA    GROUP5_SUCCESS   		;Finish routine
    
GROUP5_INVALID: 
    JSR INVALID_OP          		;INVALID OP has been found, set IS_VALID_1 to 0
GROUP5_SUCCESS:
    MOVEM.L (SP)+,D0        		;Restore registers from stack
    RTS                     		;Return to stack
    
* GROUP_6
********************************************************************************
* Description: Checks for the following list of OP codes to be present or not.
* Supported OP codes
* BRA: $60, 7-0 8-Bit Displacement
* Bcc: $6, 11-8 Condition, 7-0 8-Bit Displacement
*   Branch: <Condition>   
*   BCS: %0101  		
*   BGE: %1100		
*   BLT: %1101	
*   BVC: %1000
*
* Register(s) used: D0,D1,D2
*
* Precondition: First nibble has been identified as $6
*
* Postcondition: Parses proper OP code with a nibble value of $6 or finds an
* invalid OP code.
*
* Unsupported OP codes: BSR,BGT,BCC,BEQ,BHI,BMI,BNE,BPL
********************************************************************************
C_GROUP_6:
    MOVEM.L D0,-(SP)        	;Save register to stack
*Unsupported OP code
CHECK_OP_BSR:
    MOVE.W  CUR_OP_CODE_1,D0		    ;Move current instruction set to D0
    ANDI.W  #$FF00,D0			    ;Mask appropriate bits
    CMP.W   #$6100,D0			    ;Compare masked bits
    BEQ     GROUP6_INVALID		    ;INVALID OP code found
    BNE     CHECK_OP_BGT		    ;Check next OP code
    
CHECK_OP_BGT:
    MOVE.W CUR_OP_CODE_1,D0   	    ;Move current instruction set into D0
    ANDI.W #$FF00,D0			    ;Mask appropriate bits
    CMP.W  #$6E00,D0 			    ;Compare masked bits
    BEQ    GROUP6_INVALID           ;INVALID OP code found
    BNE    CHECK_OP_BCC             ;Check next OP code

CHECK_OP_BCC:
    MOVE.W CUR_OP_CODE_1,D0   	    ;Move current instruction set into D0
    ANDI.W #$FF00,D0			    ;Mask appropriate bits
    CMP.W  #$6400,D0 			    ;Compare masked bits
    BEQ    GROUP6_INVALID           ;INVALID OP code found
    BNE    CHECK_OP_BEQ             ;Check next OP code 

CHECK_OP_BEQ:
    MOVE.W CUR_OP_CODE_1,D0   	    ;Move current instruction set into D0
    ANDI.W #$FF00,D0			    ;Mask appropriate bits
    CMP.W  #$6700,D0 			    ;Compare masked bits
    BEQ    GROUP6_INVALID           ;INVALID OP code found
    BNE    CHECK_OP_BHI             ;Check next OP code

CHECK_OP_BHI:
    MOVE.W CUR_OP_CODE_1,D0   	    ;Move current instruction set into D0
    ANDI.W #$FF00,D0			    ;Mask appropriate bits
    CMP.W  #$6200,D0 			    ;Compare masked bits
    BEQ    GROUP6_INVALID           ;INVALID OP code found
    BNE    CHECK_OP_BLS             ;Check next OP code

CHECK_OP_BLS:
    MOVE.W CUR_OP_CODE_1,D0   	    ;Move current instruction set into D0
    ANDI.W #$FF00,D0			    ;Mask appropriate bits
    CMP.W  #$6300,D0 			    ;Compare masked bits
    BEQ    GROUP6_INVALID           ;INVALID OP code found
    BNE    CHECK_OP_BMI             ;Check next OP code

CHECK_OP_BMI:
    MOVE.W CUR_OP_CODE_1,D0   	    ;Move current instruction set into D0
    ANDI.W #$FF00,D0			    ;Mask appropriate bits
    CMP.W  #$6B00,D0 			    ;Compare masked bits
    BEQ    GROUP6_INVALID           ;INVALID OP code found
    BNE    CHECK_OP_BNE             ;Check next OP code

CHECK_OP_BNE:
    MOVE.W CUR_OP_CODE_1,D0   	    ;Move current instruction set into D0
    ANDI.W #$FF00,D0			    ;Mask appropriate bits
    CMP.W  #$6600,D0 			    ;Compare masked bits
    BEQ    GROUP6_INVALID           ;INVALID OP code found
    BNE    CHECK_OP_BPL             ;Check next OP code    

CHECK_OP_BPL:
    MOVE.W CUR_OP_CODE_1,D0   	    ;Move current instruction set into D0
    ANDI.W #$FF00,D0			    ;Mask appropriate bits
    CMP.W  #$6A00,D0 			    ;Compare masked bits
    BEQ    GROUP6_INVALID           ;INVALID OP code found
    BNE    CHECK_OP_BRA             ;Check next OP code 


*Supported OP codes
CHECK_OP_BRA:
    MOVE.W  CUR_OP_CODE_1,D0  	    ;Move current instruction set into D0       
    ANDI.W  #$FF00,D0			    ;Mask appropriate bits
    CMP.W   #$6000,D0			    ;Compare masked bits
    BNE     CHECK_OP_BCS		    ;Check next OP code
    JSR     PRINT_OP_BRA		    ;Print out OP code
    BRA     GROUP6_SUCCESS		    ;Finish routine
    
CHECK_OP_BCS:
    MOVE.W CUR_OP_CODE_1,D0   	    ;Move current instruction set into D0
    ANDI.W #$FF00,D0			    ;Mask appropriate bits
    CMP.W  #$6500,D0 			    ;Compare masked bits
    BNE    CHECK_OP_BGE			    ;Check next OP code
    JSR    PRINT_OP_BCS			    ;Print out OP code
    BRA    GROUP6_SUCCESS		    ;Finish routine

    
CHECK_OP_BGE:
    MOVE.W CUR_OP_CODE_1,D0	   	    ;Move current instruction set into D0
    ANDI.W #$FF00,D0			    ;Mask appropriate bits
    CMP.W  #$6C00,D0 			    ;Compare masked bits
    BNE    CHECK_OP_BLT			    ;Check next OP code
    JSR    PRINT_OP_BGE			    ;Print out OP code
    BRA    GROUP6_SUCCESS		    ;Finish routine
    
    
CHECK_OP_BLT:
    MOVE.W CUR_OP_CODE_1,D0   	    ;Move current instruction set into D0
    ANDI.W #$FF00,D0			    ;Mask appropriate bits
    CMP.W  #$6D00,D0 			    ;Compare masked bits
    BNE    CHECK_OP_BVC			    ;Check next OP code
    JSR    PRINT_OP_BLT			    ;Print out OP code
    BRA    GROUP6_SUCCESS		    ;Finish routine
    
CHECK_OP_BVC:
    MOVE.W CUR_OP_CODE_1,D0   	    ;Move current instruction set into D0
    ANDI.W #$FF00,D0			    ;Mask appropriate bits
    CMP.W  #$6800,D0 			    ;Compare masked bits
    BNE    GROUP6_INVALID		    ;Check next OP code
    JSR    PRINT_OP_BVC			    ;Print out OP code
    BRA    GROUP6_SUCCESS		    ;Finish routine
    
GROUP6_INVALID:
    JSR    INVALID_OP    		    ;INVALID OP code found, set IS_VALID_1 to 0
GROUP6_SUCCESS:
    MOVEM.L (SP)+,D0			    ;Restore registers from stack
    RTS							    ;Return from stack
    
*GROUP_7
********************************************************************************
* Description: Checks if the following OP code is present or not.
* Currently no OP codes here are supported. MOVEQ is the only code in this group
* Register(s) used: D0
*
* Precondition: First nibble has been identified as $7
*
* Postcondition: Identifies it's MOVEQ and sets IS_VALID_1 to 0
*
* Unsupported OP code: MOVEQ
********************************************************************************
C_GROUP_7:
    MOVEM.L D0,-(SP)        	    ;Save register to stack
*Unsupported OP code
CHECK_OP_MOVEQ
    MOVE.W  CUR_OP_CODE_1,D0		    ;Move current instruction set to D0
    ANDI.W  #$F100,D0			    ;Mask appropriate bits
    CMP.W   #$7000,D0			    ;Compare masked bits
    BRA     GROUP7_INVALID		    ;INVALID OP code found

GROUP7_INVALID:
    JSR 	INVALID_OP				;INVALID OP code found, set IS_VALID_1 to 0
GROUP7_SUCCESS:    
    MOVEM.L (SP)+,D0			    ;Restore registers from stack
    RTS							    ;Return from stack
* GROUP_8
********************************************************************************
* Description: Checks the following list of OP codes to be present or not.
* Supported OP code:
* DIVS: $8, 11-9 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
* OR: $80, 7-6 Size, 5-3 EA Mode, 2-0 EA Register
* Register(s) used: D0
*
* Precondition: First nibble has been identified as $8
*
* Postcondition: Parses proper OP code with a nibble value of $8 or finds an
* invalid OP code.
*
* Unsupported OP codes: DIVU, SBCD
********************************************************************************
C_GROUP_8:
    MOVEM.L D0,-(SP)
*Unsupported OP codes
CHECK_OP_DIVU:
    MOVE.W  CUR_OP_CODE_1,D0   		;Move current instruction set into D0
    ANDI.W  #$F1C0,D0				;Mask appropriate bits
    CMP.W   #$80C0,D0				;Compare masked bits
    BEQ     GROUP8_INVALID			;INVALID OP code found
    BNE     CHECK_OP_SBCD 			;Check next OP code

CHECK_OP_SBCD:
    MOVE.W  CUR_OP_CODE_1,D0   		;Move current instruction set into D0
    ANDI.W  #$F1F0,D0				;Mask appropriate bits
    CMP.W   #$8100,D0				;Compare masked bits
    BEQ     GROUP8_INVALID			;INVALID OP code found
    BNE     CHECK_OP_DIVS			;Check next OP code
    
*Supported OP codes
CHECK_OP_DIVS:
    MOVE.W  CUR_OP_CODE_1,D0   		;Move current instruction set into D0
    ANDI.W  #$F1C0,D0				;Mask appropriate bits
    CMP.W   #$81C0,D0				;Compare masked bits
    BNE     CHECK_OP_OR				;Check next OP code
    JSR     PRINT_OP_DIVS			;OP Code found
    BRA     GROUP8_SUCCESS			;Finish routine
	
CHECK_OP_OR:              			;At this point only remaining $8 code is OR
    JSR     FIND_2_BIT_SIZE_1_7_TO_6	;Finding size bit to print out
    JSR     PRINT_OP_OR				;Print out OR
    BRA     GROUP8_SUCCESS			;Finish routine
GROUP8_INVALID:
     JSR     INVALID_OP				;INVALID OP code found, set IS_VALID_1 to 0
GROUP8_SUCCESS:
     MOVEM.L (SP)+,D0				;Restore register from stack
     RTS							;Return to stack
     
* GROUP_9                      
********************************************************************************
* Description: Checks the if the following OP code is present or not.
* Supported OP code:
* SUB: $9, 11-9 Reg, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
*
* Register(s) used: D0,D1
*
* Precondition: First nibble has been identified as $9
*
* Postcondition: Parses proper OP code with a nibble value of $9 or finds an
* invalid OP code.
*
* Unsupported OP codes: SUBX, SUBA
********************************************************************************
C_GROUP_9:
    MOVEM.L D0-D1,-(SP)     		;Save the registers
*Unsupported OP codes
CHECK_SIZE_1_BIT_FOR_SUB:
    JSR     FIND_2_BIT_SIZE_1_7_TO_6  ;Find the size bits in 7-6
    CMP.B   #%11,OP_SIZE_1            ;If the bits are %11, it has to be SUBA
    BEQ     CHECK_OP_SUBA           ;If the bits equal it must be SUBA
    BNE     CHECK_OP_SUBX           ;If the bits are not equal it could be SUBX
    
CHECK_OP_SUBA:             			;Check SUBA first as it has static bits
    MOVE.W  CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W  #$F0C0,D0				;Mask appropriate bits
    CMP.W   #$90C0,D0				;Compare masked bits
    BEQ     GROUP9_INVALID		    ;INVALID OP has been found
    BNE     CHECK_OP_SUBX			;Check next OP

CHECK_OP_SUBX:
    MOVE.W  CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W  #$F130,D0				;Mask appropriate bits
    CMP.W   #$9100,D0				;Compare masked bits
    BRA     BIT_CHECK_SUBX			;Checking if this code is SUBX through bit shifts
    
BIT_CHECK_SUBX:    
    MOVE.W  CUR_OP_CODE_1,D0      	;Move current instruction set into D0
    MOVE.W  #7,D1               	;Prepare a shift of 7 bits into D1
    LSL.W   D1,D0               	;Shift left 7 bits truncate 15-9 bits
    LSR.W   D1,D0               	;Reposition D0
    LSR.W   #4,D0               	;Truncate 4 right most bits to
    ANDI.W  #$FF13,D0           	;Compare remaining static bits
    CMP.W   #$0010,D0           	;If equal to this value it's SUBX
    BEQ     GROUP9_INVALID      	;INVALID OP code found
    BNE     CHECK_OP_SUB        	;Not can only be SUB here
    
*Supported OP code 
CHECK_OP_SUB:                   	;At this point only remaining $9 is SUB
    JSR     FIND_2_BIT_SIZE_1_7_TO_6	;Find the size bit to print out
    JSR     PRINT_OP_SUB			;Print out SUB
    BRA     GROUP9_SUCCESS			;Finish routine
    
GROUP9_INVALID:
     JSR     INVALID_OP				;INVALID OP code found, set IS_VALID_1 to 0
GROUP9_SUCCESS: 
    MOVEM.L (SP)+,D0-D1         	;Restore registers
    RTS                         	;Return to stack

*GROUP_A
********************************************************************************
* Description: One of the few groups where there are no OP codes at all.
* Currently no OP codes here are supported. There are no current OP codes here.
* Register(s) used: None
*
* Precondition: First nibble has been identified as $A
*
* Postcondition: Sets IS_VALID_1 to 0 as there are no OP codes here
********************************************************************************
C_GROUP_A:
    JSR INVALID_OP					;INVALID OP code found, set IS_VALID_1 to 0
    RTS								;Return to stack
    
* GROUP_B                     
********************************************************************************
* Description: Checks if the following list of OP codes is present or not.
* Supported OP codes:
* EOR: $B, 11-9 Reg, 8 %1, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* CMP: $B, 11-9 Reg, 8 %0, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* The specific bit difference is listed 
*
* Register(s) used: D0
*
* Precondition: First nibble has been identified as $B
*
* Postcondition: Parses proper OP code with a nibble value of $B or finds an
* invalid OP code.
*
* Unsupported OP codes: CMPM, CMPA
********************************************************************************
C_GROUP_B:
    MOVEM.L D0,-(SP)         		;Save current registers to stack
*Unsupported OP codes    
CHECK_OP_CMPM
    MOVE.W  CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W  #$F138,D0				;Mask appropriate bits
    CMP.W   #$B108,D0				;Compare masked bits
    BEQ     GROUPB_INVALID			;INVALID OP found
    BNE     CHECK_OP_CMPA			;Check next OP
    
CHECK_OP_CMPA:
    MOVE.W  CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W  #$F0C0,D0				;Mask appropriate bits
    CMP.W   #$B0C0,D0				;Compare masked bits
    BEQ     GROUPB_INVALID			;INVALID OP found
    BNE     CHECK_OP_EOR			;Check next OP

*Supported OP codes    
CHECK_OP_EOR:
    MOVE.W  CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W  #$F100,D0				;Mask appropriate bits
    CMP.W   #$B100,D0				;Compare masked bits
    BNE     CHECK_OP_CMP			;Check next OP 
    JSR     FIND_2_BIT_SIZE_1_7_TO_6	;Find size bit field to print out size
    JSR     PRINT_OP_EOR			;Print out OP code
    BRA     GROUPB_SUCCESS			;Finish routine
    
CHECK_OP_CMP:
    MOVE.W  CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W  #$F100,D0				;Mask appropriate bits
    CMP.W   #$B000,D0				;Compare masked bits
    BNE     GROUPB_INVALID			;INVALID OP code found
    JSR     FIND_2_BIT_SIZE_1_7_TO_6	;Find size bit field to print out size
    JSR     PRINT_OP_CMP			;Print out OP code
    BRA     GROUPB_SUCCESS			;Finish routine
    
GROUPB_INVALID:
    JSR     INVALID_OP           	;INVALID OP has been found, set IS_VALID_1 to 0
GROUPB_SUCCESS:
    MOVEM.L (SP)+,D0         		;Restore registers from stack
    RTS                      		;Return to stack
* GROUP_C                     
********************************************************************************
* Description: Checks if the following list of OP codes is present or not.
* Supported OP code:
* MULS: $C, 11-8 Reg, 8-6 %111, 5-3 EA Mode, 2-0 EA Reg
* Note: EXG OP mode has to be 01000, 01001, 10001, as such can never be 11 for
* bits 7-6
*
* Register(s) used: D0,D1
*
* Precondition: First nibble has been identified as $C
*
* Postcondition: Parses proper OP code with a nibble value of $C or finds an
* invalid OP code.
*
* Unsupported OP codes: MULU, ABCD, EXG, AND
********************************************************************************
C_GROUP_C:
*Unsupported OP codes
    MOVEM.L D0-D1,-(SP)
    
CHECK_OP_MULU:
    MOVE.W  CUR_OP_CODE_1,D0			;Move current instruction set into D0
    ANDI.W  #$F1C0,D0				;Mask appropriate bits
    CMP.W   #$C0C0,D0				;Compare masked bits
    BEQ     GROUPC_INVALID			;INVALID OP code found
    BNE     CHECK_OP_ABCD			;Check next OP code
 
CHECK_OP_ABCD:
    MOVE.W  CUR_OP_CODE_1,D0			;Move current instruction set into D0
    ANDI.W  #$F1F0,D0				;Mask appropriate bits
    CMP.W   #$C100,D0				;Compare masked bits
    BEQ     GROUPC_INVALID			;INVALID OP code found
    BNE     CHECK_OP_EXG			;Check next OP code
 
CHECK_OP_EXG:
    BRA     BIT_CHECK_EXG			;Always do bit check here
                        
BIT_CHECK_EXG:						;Checks the OP mode bits 7-6 which cannot be 11 for EXG
    MOVE.W  CUR_OP_CODE_1,D0			;Move current instruction set into D0
    MOVE.W  #7,D1					;Prepare a bit shift of 7 into D1
    LSL.W   D1,D0					;Shift D0 to 7 bits
    LSR.W   D1,D0					;Reposition D0
    LSR.W   #4,D0					;Shift D0 4 bits right
    ANDI.W  #$FF83,D0				;Mask appropriate bits
    CMP.W   #$0010,D0				;Bit mask static EXG bits
    BEQ     GROUPC_INVALID			;If this equals, then OP must be EXG
    BNE     CHECK_OP_MULS			;Otherwise it's MULS
*Supported OP code
CHECK_OP_MULS:
    MOVE.W CUR_OP_CODE_1,D0			;Move current instruction set into D0
    ANDI.W #$F1C0,D0				;Mask appropriate bits
    CMP.W  #$C1C0,D0				;Compare masked bits
    BNE    CHECK_OP_AND				;OP_AND is completely dynamic outside of first nibble
    JSR    PRINT_OP_MULS			;Print OP code
    BRA    GROUPC_SUCCESS			;Finish routine
	
*Odd completely dynamic unsupported OP code    
CHECK_OP_AND:						;This would be the only possible OP code left after CHECK_OP_MULS
    MOVE.W  CUR_OP_CODE_1,D0			;Move current instruction set into D0
    ANDI.W  #$F000,D0				;Mask appropriate bits
    CMP.W   #$C000,D0				;Compare masked bits
    BRA    GROUPC_INVALID    		;INVALID OP code found
    
GROUPC_INVALID:
    JSR     INVALID_OP				;Set IS_VALID_1 to 0
    
GROUPC_SUCCESS:
    MOVEM.L (SP)+,D0-D1				;Restore registers from stack
    RTS								;Return to stack
    
* GROUP_D                     
********************************************************************************
* Description: Checks if the following list of OP codes is present or not.
* Supported OP codes:
* ADD: $D, 11-9 Reg, 8-6 OPMODE, 5-3 EA Mode, 2-0 EA Reg
* ADDA: $D, 11- 9 Reg, 8-6 OPMODE, 7-6 %11, 5-3 EA Mode, 2-0 EA Reg
* The specific bit difference is listed out in the OPMODE field.
*
* Register(s) used: D0
*
* Precondition: First nibble has been identified as $D
*
* Postcondition: Parses proper OP code with a nibble value of $D or finds an
* invalid OP code.
*
* Unsupported: ADDX
********************************************************************************
C_GROUP_D:
    MOVEM.L D0,-(SP)        		;Save registers to stack
*Unsupported OP codes
BIT_SIZE_1_CHECK
    MOVE    CUR_OP_CODE_1,D0          ;Move current instruction set into D0
    JSR     FIND_2_BIT_SIZE_1_7_TO_6  ;Specific size bit checking to see if it's 11
    CMP.B   #%11,OP_SIZE_1            ;If it's %11 it cannot be ADDX and is either ADDA or ADD
    BEQ     CHECK_OP_ADDA           ;If it's equal check ADDA
    BNE     CHECK_OP_ADDX           ;If it's not equal check ADDX
    
CHECK_OP_ADDX:
    MOVE    CUR_OP_CODE_1,D0
    ANDI.W #$F130,D0				;Mask appropriate bits
    CMP.W  #$D100,D0				;Compare masked bits
    BEQ    GROUPD_INVALID			;INVALID OP code found
    BNE    CHECK_OP_ADD 			;Check next OP code
    
*Supported OP codes
CHECK_OP_ADD:
    JSR PRINT_OP_ADD        		;Only remaining OP in $D is ADD at this point
    BRA GROUPD_SUCCESS              ;Finish routine

CHECK_OP_ADDA:
    MOVE    CUR_OP_CODE_1,D0    		;Move current instruction set into D0
    ANDI.W #$F0C0,D0				;Mask applicable bits
    CMP.W  #$D0C0,D0				;Compare masked bits
    BNE    CHECK_OP_ADD				;Check next OP code
    JSR    FIND_1_BIT_SIZE_1_8		;Size bit to print
    JSR    PRINT_OP_ADDA			;Print out OP code
    BRA    GROUPD_SUCCESS			;Finish routine
    
GROUPD_INVALID:
    JSR INVALID_OP                  ;INVALID OP code found
GROUPD_SUCCESS:
    MOVEM.L (SP)+,D0        		;Restore registers from stack
    RTS                     		;Return to stack
    
* GROUP_E                     
********************************************************************************
* Description: Check if the following list of OP codes is present or not.
* Supported:
* LSR: $E, 11-9 Count/Reg, 8 %0, 7-6 Size, 5 i/r, 4-3 %01, 2-0 Reg
* LSL: $E, 11-9 Count/Reg, 8 %1, 7-6 Size, 5 i/r, 4-3 %01, 2-0 Reg
* ASR: $E, $0, 8 %0, 7-6 %11, 5-3 EA Mode, 2-0 EA reg
* ASL: $E, $0, 8 %1, 7-6 %11, 5-3 EA Mode, 2-0 EA reg
* ROR: $E, 11-9 Count/Reg, 8 %0, 7-6 Size, 5 i/r, 4-3 %11, 2-0 Reg
* ROL: $E, 11-9 Count/Reg, 8 %1, 7-6 Size, 5 i/r, 4-3 %11, 2-0 Reg
* Count/Reg for LSR/LSL refers to shift count, where 0 = shift count of 8, 1-7 
* refers to the respective value when i/r = 0. If i/r = 1, data register in the 
* Count/Reg field specifies the shift count.  
* For directional bit at 8, R = 0, L = 1
* Count/Reg for ROR/ROL specifies rotate count instead of shift count.
*
* Split into ROT and NO_ROT groups first to make identifying easier.
*
* Register(s) used: D0
*
* Precondition: First nibble has been identified as $E
*
* Postcondition: Parses proper OP code with a nibble value of $E or finds an
* invalid OP code.
*
* Unsupported: ROXL, ROXR
********************************************************************************
C_GROUP_E:
    MOVEM.L D0,-(SP)
*Unsupported OP codes
CHECK_OP_ROXR_NO_ROT:
    MOVE CUR_OP_CODE_1,D0    			;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask appropriate bits
    CMP.W  #$E4C0,D0				;Compare masked bits
    BEQ    GROUPE_INVALID			;INVALID OP code
    BNE    CHECK_OP_ROXL_NO_ROT		;Check next OP code

CHECK_OP_ROXL_NO_ROT:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask appropriate bits
    CMP.W  #$E5C0,D0				;Compare masked bits
    BEQ    GROUPE_INVALID			;INVALID OP code
    BNE    CHECK_OP_ROR_NO_ROT		;Check next OP code

*Supported OP codes
CHECK_OP_ROR_NO_ROT:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask appropriate bits
    CMP.W  #$E6C0,D0				;Compare masked bits
    BNE    CHECK_OP_ROL_NO_ROT		;Check next OP code
    JSR    PRINT_OP_ROR				;Print out OP code
    BRA    GROUPE_SUCCESS			;Finish routine
    
CHECK_OP_ROL_NO_ROT:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask appropriate bits
    CMP.W  #$E7C0,D0				;Compare masked bits
    BNE    CHECK_OP_LSR_NO_ROT		;Check next OP code
    JSR    PRINT_OP_ROL				;Print out OP code
    BRA    GROUPE_SUCCESS			;Finish routine
 
CHECK_OP_LSR_NO_ROT:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask appropriate bits
    CMP.W  #$E2C0,D0				;Compare masked bits
    BNE    CHECK_OP_LSL_NO_ROT		;Check next OP code
    JSR    PRINT_OP_LSR				;Print out OP code
    BRA    GROUPE_SUCCESS			;Finish routine

CHECK_OP_LSL_NO_ROT:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask appropriate bits
    CMP.W  #$E3C0,D0				;Compare masked bits
    BNE    CHECK_OP_ASR_NO_ROT		;Check next OP code
    JSR    PRINT_OP_LSL				;Print out OP code
    BRA    GROUPE_SUCCESS			;Finish routine

CHECK_OP_ASR_NO_ROT:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask appropriate bits
    CMP.W  #$E0C0,D0				;Compare masked bits
    BNE    CHECK_OP_ASL_NO_ROT		;Check next OP code
    JSR    PRINT_OP_ASR				;Print out OP code
    BRA    GROUPE_SUCCESS			;Finish routine
            
CHECK_OP_ASL_NO_ROT:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$FFC0,D0				;Mask appropriate bits
    CMP.W  #$E1C0,D0				;Compare masked bits
    BNE    CHECK_OP_ROXR			;Check next OP code
    JSR    PRINT_OP_ASL				Print out OP code
    BRA    GROUPE_SUCCESS			;Finish routine

*Unsupported OP codes
CHECK_OP_ROXR:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$F118,D0				;Mask appropriate bits
    CMP.W  #$E010,D0				;Compare masked bits
    BEQ    GROUPE_INVALID			;INVALID OP code found
    BNE    CHECK_OP_ROXL			;Check next OP code
    
CHECK_OP_ROXL:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$F118,D0				;Mask appropriate bits
    CMP.W  #$E110,D0				;Compare masked bits
    BEQ    GROUPE_INVALID			;INVALID OP code found
    BNE    CHECK_OP_ROR				;Check next OP code
    
*Supported OP codes
CHECK_OP_ROR:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$F118,D0				;Mask appropriate bits
    CMP.W  #$E018,D0				;Compare masked bits
    BNE    CHECK_OP_ROL				;Check next OP code
    JSR    FIND_2_BIT_SIZE_1_7_TO_6	;Parse size bits
    JSR    PRINT_OP_ROR				;Print out OP code
    BRA    GROUPE_SUCCESS			;Finish routine

CHECK_OP_ROL:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$F118,D0				;Mask appropriate bits
    CMP.W  #$E118,D0				;Compare masked bits
    BNE    CHECK_OP_LSR				;Check next OP code
    JSR    FIND_2_BIT_SIZE_1_7_TO_6	;Parse size field
    JSR    PRINT_OP_ROL				;Print out OP code
    BRA    GROUPE_SUCCESS			;Finish routine
    
CHECK_OP_LSR:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$F118,D0				;Mask appropriate bits
    CMP.W  #$E008,D0				;Compare masked bits
    BNE    CHECK_OP_LSL				;Check next OP code
    JSR    FIND_2_BIT_SIZE_1_7_TO_6	;Parse size field
    JSR    PRINT_OP_LSR				;Print out OP code
    BRA    GROUPE_SUCCESS			;Finish routine

CHECK_OP_LSL:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$F118,D0				;Mask appropriate bits
    CMP.W  #$E108,D0				;Compare masked bits
    BNE    CHECK_OP_ASR				;Check next OP code
    JSR    FIND_2_BIT_SIZE_1_7_TO_6	;Parse size field
    JSR    PRINT_OP_LSL				;Print out OP code
    BRA    GROUPE_SUCCESS			;Finish routine

CHECK_OP_ASR:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$F118,D0				;Mask appropriate bits
    CMP.W  #$E000,D0				;Compare masked bits
    BNE    CHECK_OP_ASL				;Check next OP code
    JSR    FIND_2_BIT_SIZE_1_7_TO_6	;Parse size field
    JSR    PRINT_OP_ASR				;Print out OP code
    BRA    GROUPE_SUCCESS			;Finish routine

CHECK_OP_ASL:
    MOVE CUR_OP_CODE_1,D0				;Move current instruction set into D0
    ANDI.W #$F118,D0				;Mask appropriate bits
    CMP.W  #$E100,D0				;Compare masked bits
    BNE    GROUPE_INVALID			;Last possible OP code
    JSR    FIND_2_BIT_SIZE_1_7_TO_6	;Parse size field
    JSR    PRINT_OP_ASL				;Print out OP code
    BRA    GROUPE_SUCCESS			;Finish routine

GROUPE_INVALID:
    JSR     INVALID_OP				;Set IS_VALID_1 to 0
GROUPE_SUCCESS:
    MOVEM.L (SP)+,D0				;Restore registers from stack
    RTS								;Return to stack
* GROUP_F
********************************************************************************
* Description: One of the few groups that have no OP codes
* Currently no OP codes here are supported. There are no OP codes here
*
* Register(s) used: None
*
* Precondition: Identified nibble value is $F
*
* Postcondition: IS_VALID_1 is set to 0 as there are no OP codes here
********************************************************************************
C_GROUP_F:
    JSR 	INVALID_OP				;Set IS_VALID_1 to 0
    RTS								;Return to stack
    
* INVALID_OP                     
********************************************************************************
* Description: Finds any value that is not covered in the above supported groups 
* and considers it invalid 
* The following values in the first nibble would also indicate that the 
* operand codes is already invalid: $7, $A, $F.
* For unsupported OP codes, display <MEMORY ADDRESS> DATA $<INVALID HEX>   
*
* Register(s) used: None
*
* Precondition: INVALID OP code has been found
*
* Postcondition: IS_VALID_1 is set to 0
********************************************************************************
INVALID_OP:							; ONLY SETS IS_VALID_1 TO 0
    MOVE.B #0,IS_VALID_1				;Sets IS_VALID_1 to 0
    RTS								;Return to stack

********************** PRINTING ROUTINES **************************************
* Description: These routines are to print the associated op codes, by placing
* them in the appropriate area to the buffer
*
* Registers used: D0,D1,D2,D3,A0,A1
*
* Precondition: The relevant opcode has been identified correctly.
*
* Postcondition: Prints out the associated opcode to the buffer.
*******************************************************************************

* Prints the loaded item into G_BUFFER_1
PRINT_TO_BUFFER:
    MOVE.L #G_BUFFER_1, BUFFER_POINTER_1
    JSR AddStrToBuffer_1
    RTS
    
****************************** GROUP 0 **************************************** 
PRINT_OP_ORI:
    MOVE.L #P_OP_ORI, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_CMPI:
    MOVE.L #P_OP_CMPI, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_STATIC_BCLR:
    MOVE.L #P_OP_BCLR, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
	
PRINT_OP_DYNAMIC_BCLR:
    MOVE.L #P_OP_BCLR, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
******************************* END OF GROUP 0 ********************************

****************************** GROUP 1 ****************************************    
PRINT_OP_MOVEB:
    MOVE.L #P_OP_MOVEB, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS
******************************* END OF GROUP 1 ********************************
    
****************************** GROUP 2 **************************************** 
PRINT_OP_MOVEA_L:
    MOVE.L #P_OP_MOVEA_L, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS
PRINT_OP_MOVE_L:
    MOVE.L #P_OP_MOVE_L, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS
******************************* END OF GROUP 2 ********************************
    
****************************** GROUP 3 ****************************************    
PRINT_OP_MOVEA_W:
    MOVE.L #P_OP_MOVEA_W, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS
PRINT_OP_MOVE_W:
    MOVE.L #P_OP_MOVE_W, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS
******************************* END OF GROUP 3 ********************************

****************************** GROUP 4 ****************************************
PRINT_OP_JSR:
    MOVE.L #P_OP_JSR, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS
PRINT_OP_RTS:
    MOVE.L #P_OP_RTS, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS
PRINT_OP_NOP:
    MOVE.L #P_OP_NOP, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS
PRINT_OP_LEA:
    MOVE.L #P_OP_LEA, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_NEG:
    MOVE.L #P_OP_NEG, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_MOVEM_W:
    MOVE.L #P_OP_MOVEM_W, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS
PRINT_OP_MOVEM_L:
    MOVE.L #P_OP_MOVEM_L, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS
******************************* END OF GROUP 4 ********************************
    
****************************** GROUP 5 ****************************************
PRINT_OP_SUBQ:
    MOVE.L #P_OP_SUBQ, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
******************************* END OF GROUP 5 ********************************

****************************** GROUP 6 ****************************************
PRINT_OP_BCS:
    MOVE.L #P_OP_BCS, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_BGE:
    MOVE.L #P_OP_BGE, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_BLT:
    MOVE.L #P_OP_BLT, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_BVC:
    MOVE.L #P_OP_BVC, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_BRA:
    MOVE.L #P_OP_BRA, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
******************************* END OF GROUP 6 ********************************

****************************** GROUP 7 ****************************************
* No currently supported OP codes to print here.
******************************* END OF GROUP 7 ********************************

****************************** GROUP 8 ****************************************
PRINT_OP_DIVS:
    MOVE.L #P_OP_DIVS, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS
PRINT_OP_OR:
    MOVE.L #P_OP_OR, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
******************************* END OF GROUP 8 ********************************

****************************** GROUP 9 ****************************************
PRINT_OP_SUB:
    MOVE.L #P_OP_SUB, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
******************************* END OF GROUP 9 ********************************

****************************** GROUP A ****************************************
* No currently supported OP codes to print here.
******************************* END OF GROUP A ********************************

****************************** GROUP B ****************************************
PRINT_OP_EOR:
    MOVE.L #P_OP_EOR, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_CMP:
    MOVE.L #P_OP_CMP, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
******************************* END OF GROUP B ********************************

****************************** GROUP C ****************************************
PRINT_OP_MULS:
    MOVE.L #P_OP_MULS, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS
******************************* END OF GROUP C ********************************

****************************** GROUP D ****************************************
PRINT_OP_ADD:
    MOVE.L #P_OP_ADD, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_ADDA:
    MOVE.L #P_OP_ADDA, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1_ADDA
    RTS

******************************* END OF GROUP D ********************************

****************************** GROUP E ****************************************
PRINT_OP_LSL:
    MOVE.L #P_OP_LSL, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_LSR:
    MOVE.L #P_OP_LSR, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_ASR:
    MOVE.L #P_OP_ASR, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_ASL:
    MOVE.L #P_OP_ASL, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_ROL:
    MOVE.L #P_OP_ROL, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
PRINT_OP_ROR:
    MOVE.L #P_OP_ROR, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    JSR PRINT_OP_SIZE_1
    RTS
******************************* END OF GROUP E ********************************

****************************** GROUP F ****************************************
* No currently supported OP codes to print here.
******************************* END OF GROUP F ********************************

****************************** SIZE_1 PRINTS ************************************
PRINT_SIZE_1_BYTE:
    MOVE.L #P_SIZE_1_B, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS    

PRINT_SIZE_1_WORD:
    MOVE.L #P_SIZE_1_W, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS
    
PRINT_SIZE_1_LONG:
    MOVE.L #P_SIZE_1_L, STRING_BUFFER_1_POINTER_1
    JSR PRINT_TO_BUFFER
    RTS

PRINT_OP_SIZE_1:						;Prints current OP code byte size if applicable
    CMP.B  #%00,OP_SIZE_1				;Checks for byte size
    BEQ    PRINT_SIZE_1_BYTE			;Print .B to buffer
    CMP.B  #%01,OP_SIZE_1				;Check for word size
    BEQ    PRINT_SIZE_1_WORD			;Print .W to buffer
    CMP.B  #%10,OP_SIZE_1				;Check for long size
    BEQ    PRINT_SIZE_1_LONG			;Print .L to buffer
    RTS
    
PRINT_OP_SIZE_1_ADDA:					;Special  print for ADDA
    CMP.B #%0,OP_SIZE_1				;Checks if the OP_SIZE_1 is 0
    BEQ    PRINT_SIZE_1_WORD			;If it is the size is word
    BNE    PRINT_SIZE_1_LONG			;If it's not the size is long
    
******************* END OF SIZE_1 PRINTS ****************************************

******************* END OF PRINTING ROUTINES **********************************

******************* END OF JMP LABELS *****************************************

******************* DATA CONSTANT PRINTS **************************************
* Formatting is as follows: P_OP_<OPCODE>, where P = Print, OP = Operation,
* <OPCODE> is any valid operand

P_INVALID_OP    DC.B    '   DATA   $',0
P_SIZE_1_B        DC.B    '.B ',0
P_SIZE_1_W        DC.B    '.W ',0
P_SIZE_1_L        DC.B    '.L ',0
P_OP_ORI        DC.B    '   ORI',0
P_OP_CMPI       DC.B    '   CMPI',0
P_OP_BCLR     	DC.B    '   BCLR',0
P_OP_MOVEB      DC.B    '   MOVE.B ',0
P_OP_MOVEA_L    DC.B    '   MOVEA.L ',0 
P_OP_MOVE_L     DC.B    '   MOVE.L ',0
P_OP_MOVEA_W    DC.B    '   MOVEA.W ',0
P_OP_MOVE_W     DC.B    '   MOVE.W ',0
P_OP_MOVEM_W    DC.B    '   MOVEM.W ',0
P_OP_MOVEM_L    DC.B    '   MOVEM.L ',0
P_OP_LEA        DC.B    '   LEA',0
P_OP_JSR        DC.B    '   JSR',0
P_OP_NOP        DC.B    '   NOP',0
P_OP_RTS        DC.B    '   RTS',0
P_OP_NEG        DC.B    '   NEG',0
P_OP_SUBQ       DC.B    '   SUBQ',0
P_OP_BRA        DC.B    '   BRA',0
P_OP_BCS        DC.B    '   BCS',0
P_OP_BGE        DC.B    '   BGE',0
P_OP_BLT        DC.B    '   BLT',0
P_OP_BVC        DC.B    '   BVC',0
P_OP_DIVS       DC.B    '   DIVS.W ',0
P_OP_OR         DC.B    '   OR',0
P_OP_SUB        DC.B    '   SUB',0
P_OP_EOR        DC.B    '   EOR',0
P_OP_CMP        DC.B    '   CMP',0
P_OP_MULS       DC.B    '   MULS.W ',0
P_OP_ADDA       DC.B    '   ADDA',0
P_OP_ADD        DC.B    '   ADD',0
P_OP_LSR        DC.B    '   LSR',0
P_OP_LSL        DC.B    '   LSL',0
P_OP_ASR        DC.B    '   ASR',0
P_OP_ASL        DC.B    '   ASL',0
P_OP_ROR        DC.B    '   ROR',0
P_OP_ROL        DC.B    '   ROL',0
***************** END OF DATA CONSTANT PRINTS ***********************************

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* MESSAGE VARIABLES ******************************

* ASCII values for respective characters

ADDRESS         DC.B    $41
DATA            DC.B    $44

PTHSIS_OPEN     DC.B    $28
PTHSIS_CLSD     DC.B    $29
HEX_SIGN        DC.B    $24
IMMDTE_VALU     DC.B    $23
PLUS_SIGN       DC.B    $2B
MINUS_SIGN      DC.B    $2D

COMMA           DC.B    $2C
SPACE           DC.B    $20
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
* Essential VARIABLE. KEEP THIS
TRAILING_SIZE_1   DS.W    1 * Size of any immediate or
                          * address values. Immediate or address
                          * value of a BYTE is still processed as
                          * WORD because the trailing bytes
                          * are represented as a word regardless.
                          * $1 = BYTE, $2 = WORD, $4 = LONG
						  
X				DS.B	1
Y				DS.B	1 * always X -> Y
X_COUNTER		DS.B	1
Y_COUNTER		DS.B	1
FIRST_X			DS.B	1 * 0: it is first X
						  * 1: it is second X
FIRST_Y			DS.B	1 * 0: it is first Y
						  * 1: it is second Y
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

* EXECUTION **************************************
main_EA:
    JSR PARSE_EA_CONSTANT_BITS    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



* RULES BEFORE EXECUTION
*
* G_BUFFER_1 should be loaded in A4
*
* READING FROM START_ADDRESS should be loaded in A5
*
* ALL variables should have the same name with daniel's
*
* CUR_OP_CODE_1, MNEMONIC, FIRST_3, etc should have values already.




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;      
* ESSENTIAL EXECUTION PORTION. DO NOT ERASE ******

    JSR     CHECK_XXXX
EXT                        * Main EXT alias to finish routine
    JMP check_print 
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

* CHECK_MNEMONIC FUNCTIONS ***************
* <EA>
**********************************************************************************
* Description: Checks the mnemonic starting from XXXX
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
CHECK_XXXX:
    CMPI.B  #$8, MNEMONIC
    BLT     CHECK_0XXX
    JMP     CHECK_1XXX

* <EA>
**********************************************************************************
* Description: Checks the mnemonic starting from 0XXX
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
CHECK_0XXX:
    CMPI.B  #$4, MNEMONIC
    BLT     CHECK_00XX
    JMP     CHECK_01XX

* <EA>
**********************************************************************************
* Description: Checks the mnemonic starting from 1XXX
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
CHECK_1XXX:
    CMPI.B  #$8, MNEMONIC
    BEQ     LOAD_1000
    CMPI.B  #$9, MNEMONIC
    BEQ     LOAD_1001
    CMPI.B  #$B, MNEMONIC
    BEQ     LOAD_1011
    CMPI.B  #$C, MNEMONIC
    BEQ     LOAD_1100
    CMPI.B  #$D, MNEMONIC
    BEQ     LOAD_1101
    CMPI.B  #$E, MNEMONIC
    BEQ     LOAD_1110
    
    JMP     INVALID
    
    RTS

* <EA>
**********************************************************************************
* Description: Checks the mnemonic starting from 00XX
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
CHECK_00XX:
    CMPI.B  #$1, MNEMONIC
    BLT     LOAD_0000
    BGE     LOAD_00XX

* <EA>
**********************************************************************************
* Description: Checks the mnemonic starting from 01XX
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
CHECK_01XX:
    CMPI.B  #%0100, MNEMONIC
    BEQ     LOAD_0100
    CMPI.B  #%0101, MNEMONIC
    BEQ     LOAD_0101
    CMPI.B  #%0110, MNEMONIC
    BEQ     LOAD_0110
    RTS

**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (HIGHEST LEVEL) ************

* <EA>
**********************************************************************************
* Description: Once the mnemonic is 1110, it is either ASd, LSd, or ROd.
*
* Registers used: Whether if it is ASd, LSd, or ROd, they all share the same
*                 EA algorithm. D5 for calculation, A2 and A3 for returning from subbranches.
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_1110:
            MOVEA.L #0, A2
            MOVEA.L #0, A3
            CLR.L   D5
    
            MOVE.B  SECOND_3, D5
            ANDI.B  #%011, D5
    
            CMPI.B  #%11, D5
            BEQ     MYBE_ASd_1
            BNE     MYBE_ASd_2

***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***111111111 ASd <ea> 111111111***
MYBE_ASd_1  CMPI.B  #%000, FIRST_3
            BEQ     ASd_1
            CMPI.B  #%001, FIRST_3
            BEQ     ASd_1 * LSd
            CMPI.B  #%011, FIRST_3
            BEQ     ASd_1 * ROd
            JMP     INVALID

ASd_1       CMPI.B  #%111, THIRD_3
            BNE     MOVEON  
            CMPI.B  #%100, FOURTH_3
            BEQ     INVALID

MOVEON      MOVEA.W #ASd_1_BACK, A3           
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_1_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_1_L

ASd_1_BACK  MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS
***111111111 ASd <ea> 111111111***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***

***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***111111111 ASd X, Y 11111111***
MYBE_ASd_2  CLR.L   D5

            MOVE.B  THIRD_3, D5
            ANDI.B  #%011, D5
            CMPI.B  #%10, D5
            BNE     ASd_2 * or LSd or ROd
            BEQ     INVALID
            
ASd_2       CLR.L   D5

            MOVE.B  THIRD_3, D5
            ANDI.B  #%100, D5
            CMPI.B  #%100, D5
            BEQ     ASd_2_REG
            BNE     ASd_2_IMD
            
***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***222222222 ASd #<data>, Dy 222222222***
ASd_2_IMD   MOVEA.W #ASd_2_IMD_B, A2
            CMPI.B  #%000, FIRST_3
            BEQ     LOAD_8
            BNE     LOAD_FIRST3
            
LOAD_8      MOVE.B  #8, D4
            JMP     LOAD_IMMDTE

LOAD_FIRST3 MOVE.B  FIRST_3, D4
            JMP     LOAD_IMMDTE

ASd_2_IMD_B JSR     LOAD_COMMA_SPACE

            MOVE.B  #%000, D3
            MOVE.B  FOURTH_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS
***222222222 ASd #<data>, Dy 222222222***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***

***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***222222222 ASd Dx, Dy 222222222***
ASd_2_REG   MOVE.B  #%000, D3
            MOVE.B  FIRST_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE
            
            MOVE.B  #%000, D3
            MOVE.B  FOURTH_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS
***222222222 ASd Dx, Dy 222222222***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***

***111111111 ASd X, Y 111111111***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***


* <EA>
**********************************************************************************
* Description: Once the mnemonic is 0110, it is either BRA or Bcc.
*
* Registers used: Whether if it is BRA or Bcc, in terms of EA, both instructions
*                 share the same EA algorithm. D4 for the displacement, D5 for calculation,
*                 D6 for checking the current opcode, A2 and A3 for returning from subbranches.
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_0110:
            MOVEA.L #0, A2
            MOVEA.L #0, A3
            CLR.L   D5
            CLR.L   D6
            CLR.L   D4

            CMPI.B  #%000, FIRST_3
            BEQ     MYBE_BRA
            BNE     NOT_BRA
MYBE_BRA    CMPI.B  #%100, SECOND_3
            BLT     BRA
            BGE     NOT_BRA
            
NOT_BRA     MOVE.B  FIRST_3, D5
            ASL.B   #1, D5
            MOVE.B  SECOND_3, D6
            ASR.B   #2, D6
            ADD.B   D6, D5
            
            CMPI.B  #%0101, D5
            BEQ     BRA * CS
            CMPI.B  #%1000, D5
            BEQ     BRA * VC
            CMPI.B  #%1100, D5
            BEQ     BRA * GE
            CMPI.B  #%1101, D5
            BEQ     BRA * LT
            
            JMP     INVALID
            
            
BRA         CLR.L   D5
            CLR.L   D6

            MOVE.W  A5, D5 * D5 has $1002 (Starting + MNEMONICS)
            MOVE.W  CUR_OP_CODE_1, D6
            ANDI.W  #$00FF, D6 * D6 now has $E
            CMPI.B  #$00, D6
            BEQ     BRA_WORD * word. there is 4 hex trailing bits (word)

            CMPI.B  #$FF, D6
            BEQ     BRA_BYTE
            CMPI.B  #$FE, D6
            BEQ     BRA_BYTE

            JMP     INVALID
            
***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***111111111 BRA_BYTE 111111111***
BRA_BYTE    CMPI.B  #$FE, D6
            BEQ     DOWN_ZERO
            CMPI.B  #$FF, D6
            BEQ     DOWN_ONE
            
            JMP     INVALID
            
DOWN_ZERO   SUBI.B  #$2, D5 * D5 has $1000 (Starting)
            JMP     BRA_BYTE2
            
DOWN_ONE    SUBI.B  #$1, D5 * D5 has $1001 (Starting + 1)
            JMP     BRA_BYTE2
            
BRA_BYTE2   MOVE.W  #BRA_BYTE3, A2
            MOVE.W  D5, D4
            JMP     LOAD_ABS_SHORT
BRA_BYTE3   JSR     LOAD_NEW_LINE
            RTS
***111111111 BRA_BYTE 111111111***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***

***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***111111111 BRA_WORD 111111111***
BRA_WORD    MOVE.W  (A5)+, D4 * D4 now has $000E

            CMPI.L  #$8000, D4
            BGE     NEG_WORD
            BLT     POS_WORD
            
***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***222222222 BRA_WORD_POSITIVE 222222222***
POS_WORD    MOVE.W  #BRA_WORD_BK, A2
            ADD.W   D5, D4 * D4 now has $100E
            JMP     LOAD_ABS_SHORT
BRA_WORD_BK JSR     LOAD_NEW_LINE
            RTS
***222222222 BRA_WORD_POSITIVE 222222222***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***

***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***222222222 BRA_WORD_NEGATIVE 222222222***
NEG_WORD    MOVE.W  #BRA_WRD_BK2, A2
            NEG     D4
            
            CMP.L   D5, D4 * $4002 vs DISPLACEMENT
            BGT     INVALID
            
            SUB.W   D4, D5 * D5 now has $1000 - 2cmp'ed $000E
            MOVE.W  D5, D4
            JMP     LOAD_ABS_SHORT
BRA_WRD_BK2 JSR     LOAD_NEW_LINE
            RTS
***222222222 BRA_WORD_NEGATIVE 222222222***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***

***111111111 BRA_WORD 111111111***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***


* <EA>
**********************************************************************************
* Description: Once the mnemonic is 1001, it is either ADD or ADDA.
*
* Registers used: If ADDA, D3 for SRC/DST mod, D2 for SRC/DST reg, A3 to get back from the subbranch, D1 for size calculation.
*                 If ADD, basically recycling the algorithm for DIVS/OR
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_1101:
            CMPI.B  #%011, SECOND_3
            BEQ     ADDA
            CMPI.B  #%111, SECOND_3
            BEQ     ADDA
            
            JMP     LOAD_1000
            
ADDA        MOVEA.W #ADDA_BACK, A3
            CLR.L   D1
            MOVE.B  SECOND_3, D1
            ANDI.B  #%100, D1
            
            CMPI.B  #%000, D1
            BEQ     SIZE_1_W
            CMPI.B  #%100, D1
            BEQ     SIZE_1_L
            
ADDA_BACK   MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2

            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE
            
            MOVE.B  #%001, D3
            MOVE.B  FIRST_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS

* <EA>
**********************************************************************************
* Description: Once the mnemonic is 1001, it is MULS.
*
* Registers used: X. Basically recycling the algorithm for DIVS/OR
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_1100:
    JMP     LOAD_1000
    
* <EA>
**********************************************************************************
* Description: Once the mnemonic is 1001, it is either EOR or CMP.
*
* Registers used: X. Basically recycling the algorithm for DIVS/OR
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_1011:
    JMP     LOAD_1000


* <EA>
**********************************************************************************
* Description: Once the mnemonic is 1001, it is SUB.
*
* Registers used: X. Basically recycling the algorithm for DIVS/OR
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_1001:
    JMP     LOAD_1000


* <EA>
**********************************************************************************
* Description: Once the mnemonic is 1000, it is either DIVS or OR.
*
* Registers used: D3 for SRC/DST mod, D2 for SRC/DST reg, A3 to get back from the subbranch.
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_1000:
            CLR.L   D3
            CLR.L   D2
            MOVEA.L #0, A3
            
            CMPI.B  #%111, SECOND_3
            BEQ     DIVS
            
            CMPI.B  #%011, SECOND_3
            BEQ     INVALID
            
***vvvvvvvvvvvvvvvvvvv***
            CMPI.B  #%100, SECOND_3
            BLT     DIR_0 * direction bit 0
            BGE     DIR_1 * direction bit 1
            
DIR_0       CLR.L   D1
            MOVE.B  SECOND_3, D1
            ANDI.B  #%011, D1
    
            MOVEA.W #OR_BACK, A3
            CMPI.B  #%00, D1
            BEQ     SIZE_1_B
            CMPI.B  #%01, D1
            BEQ     SIZE_1_W
            CMPI.B  #%10, D1
            BEQ     SIZE_1_L
            
OR_BACK     MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2

            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE
            
            MOVE.B  #%000, D3
            MOVE.B  FIRST_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS
            
DIR_1       MOVE.B  #%000, D3
            MOVE.B  FIRST_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE
            
            CLR.L   D1
            MOVE.B  SECOND_3, D1
            ANDI.B  #%011, D1
    
            MOVEA.W #OR_BACK2, A3
            CMPI.B  #%00, D1
            BEQ     SIZE_1_B
            CMPI.B  #%01, D1
            BEQ     SIZE_1_W
            CMPI.B  #%10, D1
            BEQ     SIZE_1_L
            
OR_BACK2    MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2

            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS    
***^^^^^^^^^^^^^^^^^^^***
            
***vvvvvvvvvvvvvvvvvvv***
DIVS        MOVEA.W #DIVS_BACK, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_1_W
            CMPI.B  #%001, FOURTH_3
            BEQ     INVALID
            CMPI.B  #%100, FOURTH_3
            BEQ     SIZE_1_W
            
DIVS_BACK   MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2

            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE

            MOVE.B  #%000, D3
            MOVE.B  FIRST_3, D2

            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS
***^^^^^^^^^^^^^^^^^^^***


* <EA>
**********************************************************************************
* Description: Once the mnemonic is 0101, it is SUBQ
*
* Registers used: D4 to load the data within the EA bits, and A2 to come back
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_0101:
            CLR.L   D3
            CLR.L   D2
            MOVEA.L #0, A3

            CMPI.B  #%111, FIRST_3
            BLE     MYBE_SUBQ1
            JMP     INVALID
            
MYBE_SUBQ1  CMPI.B  #%011, SECOND_3
            BGT     MYBE_SUBQ2
            JMP     INVALID

MYBE_SUBQ2  CMPI.B  #%111, SECOND_3
            BLT     SUBQ
            JMP     INVALID

SUBQ        ADDI.B  #%1, FIRST_3
            MOVE.B  FIRST_3, D4
            
            MOVEA.W #SUBQ_SAVED, A2
            JMP     LOAD_IMMDTE
            
SUBQ_SAVED  JSR     LOAD_COMMA_SPACE

            MOVEA.W #SUBQ_BACK, A3
            CMPI.B  #%100, SECOND_3
            BEQ     SIZE_1_B
            CMPI.B  #%101, SECOND_3
            BEQ     SIZE_1_W
            CMPI.B  #%110, SECOND_3
            BEQ     SIZE_1_L
            
SUBQ_BACK   MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2

            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS

* <EA>
**********************************************************************************
* Description: Once the mnemonic is 0100, it is either NEG, RTS, JSR, MOVEM, or LEA.
*
* Registers used: D3 for SRC/DST mod, D2 for SRC/DST reg, A3 to get back from the subbranch,
*                 D5, D4 for BCLR, D6 for recognizing MOVEM
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_0100:
            CLR.L   D3
            CLR.L   D2
            MOVEA.L #0, A3

            CMPI.B  #%010, FIRST_3
            BEQ     MYBE_NEG
            BNE     NOT_NEG
MYBE_NEG    CMPI.B  #%011, SECOND_3
            BLT     NEG

NOT_NEG     CMPI.B  #%111, FIRST_3
            BEQ     MYBE_RTS1
            BNE     NOT_RTS
MYBE_RTS1   CMPI.B  #%001, SECOND_3
            BEQ     MYBE_RTS2
            BNE     NOT_RTS
MYBE_RTS2   CMPI.B  #%110, THIRD_3
            BEQ     MYBE_RTS3
            BNE     NOT_RTS
MYBE_RTS3   CMPI.B  #%101, FOURTH_3
            BEQ     RTS
            CMPI.B  #%001, FOURTH_3 
            BEQ     RTS * It's actually NOP but it's the same shit in EA perspective
            
NOT_RTS     CMPI.B  #%111, FIRST_3
            BEQ     MYBE_JSR
            BNE     NOT_JSR
MYBE_JSR    CMPI.B  #%010, SECOND_3
            BEQ     JSR

NOT_JSR     CLR.L   D6
            MOVE.B  FIRST_3, D6
            ANDI.B  #%101, D6 * Making %1X0 -> %100
            CMPI.B  #%100, D6
            BEQ     MYBE_MOVEM
            BNE     NOT_MOVEM
            
MYBE_MOVEM  MOVE.B  SECOND_3, D6
            ANDI.B  #%110, D6
            CMPI.B  #%010, D6
            BEQ     MOVEM
            
NOT_MOVEM   CMPI.B  #%111, SECOND_3
            BEQ     LEA
            
            JMP     INVALID

NEG:
            MOVEA.W #NEG_BACK, A3
            CMPI.B  #%000, SECOND_3
            BEQ     SIZE_1_B
            CMPI.B  #%001, SECOND_3
            BEQ     SIZE_1_W
            CMPI.B  #%010, SECOND_3
            BEQ     SIZE_1_L
            
NEG_BACK    MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2

            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS
            
RTS:
            JSR     LOAD_NEW_LINE
            RTS

JSR:
            MOVEA.W #JSR_BACK, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_1_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_1_L
            
JSR_BACK    MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS

MOVEM:
            JSR     FUK_MOVEM
            JSR     LOAD_NEW_LINE
            RTS
    
LEA:
            MOVEA.W #LEA_BACK, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_1_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_1_L
            CMPI.B  #%100, FOURTH_3
            BEQ     INVALID 
            
LEA_BACK    MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE
            
            MOVE.B  #%001, D3
            MOVE.B  FIRST_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS 

FUK_MOVEM:  * Functional Utilization of Knowledge in MOVEM
			CLR.L	D4
			CLR.L	D5
			CLR.L	D6
			MOVEA.L	#0, A3
			
			MOVE.B	FIRST_3, D6
			ANDI.B	#%010, D6
			CMPI.B	#%010, D6
			BEQ		MOVEM_POST
			BNE		MOVEM_PRE

MOVEM_POST	CMPI.B	#%011, THIRD_3
			BEQ		MOVEM_POST2
			CMPI.B	#%010, THIRD_3
			BEQ		MOVEM_POST2
			CMPI.B	#%111, THIRD_3
			BEQ		MOVEM_POST3
			JMP		INVALID

MOVEM_POST2	MOVE.B	THIRD_3, D3
			MOVE.B	FOURTH_3, D2
			JSR		LOAD_EA
			JSR		LOAD_COMMA_SPACE

			JSR		MOVEM_PARSE
            RTS

MOVEM_POST3	* see if new displacement doesnt exceed END_ADDRESS
			CLR.L	D6
			MOVE.W	A5, D6
			ADDI.B	#2, D6
			CMP.W	A6, D6
			BGT		INVALID
			
			* push A5 pointer +2
			ADDA.W	#2, A5
			CMPI.B	#%000, FOURTH_3
			BEQ		MOVEM_POSTW
			CMPI.B	#%001, FOURTH_3
			BEQ		MOVEM_POSTL
			JMP		INVALID
			
MOVEM_POSTW * see if new displacement doesnt exceed END_ADDRESS
			CLR.L	D6
			MOVE.W	A5, D6
			ADDI.B	#2, D6
			CMP.W	A6, D6
			BGT		INVALID
			
			* munch 2
			MOVE.W  #$2, TRAILING_SIZE_1
			MOVE.B	THIRD_3, D3
			MOVE.B	FOURTH_3, D2
			JSR		LOAD_EA
			JSR		LOAD_COMMA_SPACE
			
			* push back -4
			SUBA.W	#4, A5
			JSR		MOVEM_PARSE
			* push 2
			ADDA.W	#2, A5
			RTS

MOVEM_POSTL * see if new displacement doesnt exceed END_ADDRESS
			CLR.L	D6
			MOVE.W	A5, D6
			ADDI.B	#2, D6
			CMP.W	A6, D6
			BGT		INVALID			
			
			* munch 4
			MOVE.W  #$4, TRAILING_SIZE_1
			MOVE.B	THIRD_3, D3
			MOVE.B	FOURTH_3, D2
			JSR		LOAD_EA
			JSR		LOAD_COMMA_SPACE

			* push back -6
			SUBA.W	#6, A5
			JSR		MOVEM_PARSE
			* push 4
			ADDA.W	#4, A5
			RTS

MOVEM_PRE	JSR		MOVEM_PARSE
			JSR		LOAD_COMMA_SPACE

			MOVEA.W #MOVEM_PRE_B, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_1_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_1_L
            JMP     INVALID
			
MOVEM_PRE_B	CMPI.B	#%000, THIRD_3
			BEQ		INVALID
			CMPI.B	#%011, THIRD_3
			BEQ		INVALID
			CMPI.B	#%001, THIRD_3
			BEQ		INVALID
			
			MOVE.B	THIRD_3, D3
			MOVE.B	FOURTH_3, D2
			
			JSR		LOAD_EA
			JSR		LOAD_NEW_LINE
			RTS
			
MOVEM_PARSE:
			CLR.L	D4
			MOVE.W	(A5)+, D4 * D4 has $00FF
						
			CMPI.B	#%100, THIRD_3
			BNE		A_TO_D
			BEQ		D_TO_A

A_TO_D		MOVE.B	#%001, X * X = A
			MOVE.B	#%000, Y * Y = D
			MOVE.B	#$8, X_COUNTER * start from 8
			MOVE.B	#$8, Y_COUNTER * start from 8
			MOVE.B	#0, FIRST_X
			MOVE.B	#0, FIRST_Y

			JMP		GO_A_TO_D
			
D_TO_A		MOVE.B	#%000, X * X = D
			MOVE.B	#%001, Y * Y = A
			MOVE.B	#$FF, X_COUNTER * start from -1
			MOVE.B	#$FF, Y_COUNTER * start from -1
			MOVE.B	#0, FIRST_X
			MOVE.B	#0, FIRST_Y
			
			JMP		GO_D_TO_A

***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***111111111 MOVEM D->A 111111111***
GO_D_TO_A	ROL.W	#1, D4
			MOVE.W	D4, D5
			ANDI.W	#$1, D5
			
			CMPI.B	#7, X_COUNTER
			BGE		ADD_Y
			BLT		ADD_X
			
ADD_X		ADDI.B	#1, X_COUNTER
			JMP		KEEP_GOING0

ADD_Y		ADDI.B	#1, Y_COUNTER
            MOVE.B  #8, X_COUNTER
			JMP		KEEP_GOING0
			
KEEP_GOING0	CMPI.W	#$1, D5
			BEQ		BIT_ON
			BNE		KEEP_GOING
			
BIT_ON		CMPI.B	#8, X_COUNTER
			BNE		ITS_X
			BEQ		MYBE_Y
			
ITS_X		MOVE.B	X, D3 * LOAD[XX_COUNTER]
			MOVE.B	X_COUNTER, D2
			JSR		LOAD_EA
			CMPI.B	#0, FIRST_X
			BEQ		FST_X
			BNE		SND_X

FST_X		MOVE.B  #$2D, (A4)+ * LOAD '-'
			MOVE.B	#1, FIRST_X * FIRST_X = 1
			JMP		KEEP_GOING
			
SND_X		SUBA.W	#2, A4 * push back G_BUFFER_1 pointer by 2
			JMP		KEEP_GOING

MYBE_Y		CMPI.B	#8, Y_COUNTER
			BNE		ITS_Y
			BEQ		KEEP_GOING

ITS_Y		CMPI.B	#0, FIRST_Y
			BEQ		FST_Y1
ITS_Y_BACK	MOVE.B	Y, D3 * LOAD[YY_COUNTER]
			MOVE.B	Y_COUNTER, D2
			JSR		LOAD_EA
			CMPI.B	#0, FIRST_Y
			BEQ		FST_Y2
			BNE		SND_Y

FST_Y1		CMPI.B	#1, FIRST_X
			BNE		SKIP_HERE
			;ADDA.W	#2, A4 * push G_BUFFER_1 pointer by 2
						
			MOVE.B	#$20, (A4)+
			MOVE.B	#$20, (A4)+

			MOVE.B  #$2F, (A4)+ * LOAD '/'
SKIP_HERE	JMP		ITS_Y_BACK

FST_Y2		MOVE.B  #$2D, (A4)+ * LOAD '-'
			MOVE.B	#1, FIRST_Y * FIRST_Y = 1
			JMP		KEEP_GOING

SND_Y		SUBA.W	#2, A4 * push back G_BUFFER_1 pointer by 2
			JMP		KEEP_GOING

KEEP_GOING	CMPI.B	#8, Y_COUNTER
			BNE		GO_D_TO_A
			
			ADDA.W	#2, A4 * push G_BUFFER_1 pointer by 2
			RTS
***111111111 MOVEM D->A 111111111***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***


***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***111111111 MOVEM A->D 111111111***
GO_A_TO_D	ROL.W	#1, D4
			MOVE.W	D4, D5
			ANDI.W	#$1, D5
			
			CMPI.B	#0, X_COUNTER
			BGT     SUBTRACT_X  
			BLE 	SUBTRACT_Y  
			
SUBTRACT_X	SUBI.B	#1, X_COUNTER
			JMP		KEEP_GOING1

SUBTRACT_Y	SUBI.B	#1, Y_COUNTER
            MOVE.B  #$FF, X_COUNTER
			JMP		KEEP_GOING1
			
KEEP_GOING1	CMPI.W	#$1, D5
			BEQ		BIT_ON2
			BNE		KEEP_GOING2
			
BIT_ON2		CMPI.B	#$FF, X_COUNTER
			BNE		ITS_X2
			BEQ		MYBE_Y2
			
ITS_X2		MOVE.B	X, D3 * LOAD[XX_COUNTER]
			MOVE.B	X_COUNTER, D2
			JSR		LOAD_EA
			CMPI.B	#0, FIRST_X
			BEQ		FST_X2
			BNE		SND_X2

FST_X2		MOVE.B  #$2D, (A4)+ * LOAD '-'
			MOVE.B	#1, FIRST_X * FIRST_X = 1
			JMP		KEEP_GOING2
			
SND_X2		SUBA.W	#2, A4 * push back G_BUFFER_1 pointer by 2
			JMP		KEEP_GOING2

MYBE_Y2		CMPI.B	#$FF, Y_COUNTER
			BNE		ITS_Y2
			BEQ		KEEP_GOING2

ITS_Y2		CMPI.B	#0, FIRST_Y
			BEQ		FST_Y3
ITS_Y2_BACK	MOVE.B	Y, D3 * LOAD[YY_COUNTER]
			MOVE.B	Y_COUNTER, D2
			JSR		LOAD_EA
			CMPI.B	#0, FIRST_Y
			BEQ		FST_Y4
			BNE		SND_Y2

FST_Y3		CMPI.B	#1, FIRST_X
			BNE		SKIP_HERE2
			;ADDA.W	#2, A4 * push G_BUFFER_1 pointer by 2
			
			MOVE.B	#$20, (A4)+
			MOVE.B	#$20, (A4)+
			
			MOVE.B  #$2F, (A4)+ * LOAD '/'
SKIP_HERE2	JMP		ITS_Y2_BACK

FST_Y4		MOVE.B  #$2D, (A4)+ * LOAD '-'
			MOVE.B	#1, FIRST_Y * FIRST_Y = 1
			JMP		KEEP_GOING2

SND_Y2		SUBA.W	#2, A4 * push back G_BUFFER_1 pointer by 2
			JMP		KEEP_GOING2

KEEP_GOING2	CMPI.B	#$FF, Y_COUNTER
			BNE		GO_A_TO_D   
			
			ADDA.W	#2, A4 * push G_BUFFER_1 pointer by 2
			RTS
***111111111 MOVEM A->D 111111111***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***



* <EA>
**********************************************************************************
* Description: Once the mnemonic is 0000, it is either BCLR, CMPI, ORI, or Dynamic BCLR.
*
* Registers used: D3 for SRC/DST mod, D2 for SRC/DST reg, A3 to get back from the subbranch,
*                 D5, D4 for BCLR
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_0000:
            CLR.L   D3
            CLR.L   D2
            MOVEA.L #0, A3

            CMPI.B  #%000, FIRST_3
            BEQ     MYBE_ORI
            BNE     NOT_ORI
MYBE_ORI    CMPI.B  #%011, SECOND_3
            BLT     ORI_CMPI            

NOT_ORI     CMPI.B  #%110, FIRST_3
            BEQ     MYBE_CMPI
            BNE     NOT_CMPI
MYBE_CMPI   CMPI.B  #%011, SECOND_3
            BLT     ORI_CMPI
            
NOT_CMPI    CMPI.B  #%100, FIRST_3
            BEQ     MYBE_BCLR
            BNE     NOT_BCLR
MYBE_BCLR   CMPI.B  #%010, SECOND_3
            BEQ     BCLR

NOT_BCLR    CMPI.B  #%110, SECOND_3
            BEQ     DYNMC_BCLR
            
            JMP     INVALID
            
***vvvvvvvvvvvvvvvvvvv***
ORI_CMPI    MOVEA.W #BACK, A3
            CMPI.B  #%000, SECOND_3
            BEQ     SIZE_1_B
            CMPI.B  #%001, SECOND_3
            BEQ     SIZE_1_W
            CMPI.B  #%010, SECOND_3
            BEQ     SIZE_1_L

BACK        MOVE.B  #%111, D3
            MOVE.B  #%100, D2
            
            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE
            
            MOVEA.W #BACK2, A3   
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_1_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_1_L
            CMPI.B  #%100, FOURTH_3 
            BEQ     INVALID 

BACK2       MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2
        
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS
***^^^^^^^^^^^^^^^^^^^***

***vvvvvvvvvvvvvvvvvvv***
BCLR        CLR.L   D5
            CLR.L   D4
            MOVEA.L #0, A2

            MOVE.W  A6, D5
            SUB.W   A5, D5
            CMPI.W  #$2, D5
            BLT     INVALID

            MOVE.W  (A5)+, D4
            CLR.L   D4
            MOVE.W  (A5)+, D4
            ANDI.W  #$00FF, D4
            MOVEA.L #BACK4, A2
            JMP     LOAD_IMMDTE
            
BACK4       JSR     LOAD_COMMA_SPACE
            
            MOVEA.W #BACK3, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_1_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_1_L
            CMPI.B  #%100, FOURTH_3 
            BEQ     INVALID 

BACK3       MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2

            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE

            RTS
***^^^^^^^^^^^^^^^^^^^***

***vvvvvvvvvvvvvvvvvvv***
DYNMC_BCLR  MOVE.B  #%000, D3
            MOVE.B  FIRST_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE

            MOVEA.W #BACK5, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_1_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_1_L
            CMPI.B  #%100, FOURTH_3 
            BEQ     INVALID 
            
BACK5       MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            
            RTS
***^^^^^^^^^^^^^^^^^^^***

* <EA>
**********************************************************************************
* Description: Once the mnemonic is 00XX, it is either MOVE or MOVEA. Checks the 3-bit bundles and
*              the size of immediate/address values if necessary.
*
* Registers used: D3 for SRC/DST mod, D2 for SRC/DST reg, A3 to get back from the subbranch
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_00XX:
        CLR.L   D3
        CLR.L   D2
        MOVEA.L #0, A3
        
        MOVEA.W #GOO, A3
        CMPI.B  #%0011, MNEMONIC
        BEQ     SIZE_1_W
        CMPI.B  #%0010, MNEMONIC
        BEQ     SIZE_1_L

GOO     MOVE.B  THIRD_3, D3
        MOVE.B  FOURTH_3, D2
    
        JSR     LOAD_EA
        JSR     LOAD_COMMA_SPACE
    
        MOVEA.W #GOO2, A3
        CMPI.B  #%000, FIRST_3
        BEQ     SIZE_1_W
        CMPI.B  #%001, FIRST_3
        BEQ     SIZE_1_L
    
GOO2    MOVE.B  SECOND_3, D3
        MOVE.B  FIRST_3, D2
            
        JSR     LOAD_EA
        JSR     LOAD_NEW_LINE
    
        RTS
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (HIGH LEVEL) ***************

* <EA>
**********************************************************************************
* Description: Checks the SRC/DST mod
*
* Registers used: A2 for branching back from subbranches
*
* Precondition: D3 for SRC/DST mod
*
* Postcondition: X
**********************************************************************************
LOAD_EA:
        MOVEA.W #SAVED, A2 * remember to come back!

        CMPI    #%111, D3
        BLT     LOAD_LT_111
        BGE     LOAD_GE_111
    
SAVED   RTS

* <EA>
**********************************************************************************
* Description: Checks the SRC/DST mod where it is not immediate/address value
*
* Registers used: X
*
* Precondition: D3 for SRC/DST mod
*
* Postcondition: X
**********************************************************************************
LOAD_LT_111:
    CMPI    #%000, D3 * e.g. D3
    BEQ     LOAD_DATA_REGISTER
    CMPI    #%001, D3 * e.g. A3
    BEQ     LOAD_ADDR_REGISTER
    CMPI    #%010, D3 * e.g. (A3)
    BEQ     LOAD_ADDRESS
    CMPI    #%011, D3 * e.g. (A3)+
    BEQ     LOAD_ADDRESS_W_POST_INC
    CMPI    #%100, D3 * e.g. -(A3)
    BEQ     LOAD_ADDRESS_W_PRE_DEC
    
    JMP     INVALID
    
* <EA>
**********************************************************************************
* Description: Checks the SRC/DST mod where it is immediate/address value
*
* Registers used: D5 for SUB.W, D4 for immediate/address value extraction
*
* Precondition: A5 for START_ADDRESS iteration, TRAILING_SIZE_1 for size of the immediate/address value
*
* Postcondition: IS_INVALID flag set if EA bit not valid
**********************************************************************************
LOAD_GE_111:
            CLR.L   D5
            CLR.L   D4

            MOVE.W  A6, D5
            SUB.W   A5, D5
            CMP.W   TRAILING_SIZE_1, D5
            BLT     INVALID

            CMPI.W  #$1, TRAILING_SIZE_1
            BEQ     CHUMP_BYTE
            CMPI.W  #$2, TRAILING_SIZE_1
            BEQ     CHUMP_WORD
            CMPI.W  #$4, TRAILING_SIZE_1
            BEQ     CHUMP_LONG

CHUMP_BYTE  MOVE.W  (A5)+, D4 * Minimum 4 hex (e.g. MOVE.B #1, $2 = XXXX 0001 0002)
            JMP     GO

CHUMP_WORD  MOVE.W  (A5)+, D4
            JMP     GO
            
CHUMP_LONG  MOVE.L  (A5)+, D4
            JMP     GO

GO          CMPI    #%000, D2
            BEQ     LOAD_ABS_SHORT
            CMPI    #%001, D2
            BEQ     LOAD_ABS_LONG
            CMPI    #%100, D2
            BEQ     LOAD_IMMDTE
    
            JMP     INVALID
* <EA>
**********************************************************************************
* Description: Puts in the proper value in TRAILING_SIZE_1 based on the immediate/address value size
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: Set up TRAILING_SIZE_1
**********************************************************************************
TRAILING_HELPER:            
SIZE_1_B  MOVE.W  #$2, TRAILING_SIZE_1
        JMP     (A3)

SIZE_1_W  MOVE.W  #$2, TRAILING_SIZE_1
        JMP     (A3)
        
SIZE_1_L  MOVE.W  #$4, TRAILING_SIZE_1
        JMP     (A3)
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (INTERMEDIATE LEVEL) *******

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. D3 in G_BUFFER_1
*
* Registers used: D0 for actually loading
*
* Precondition: D2 for SRC/DST reg
*
* Postcondition: X
**********************************************************************************
LOAD_DATA_REGISTER:
    CLR.L   D0
    
    JSR     LOAD_D
    MOVE.B  D2, D0
    JSR     LOAD_NUM
    JMP     (A2)

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. A3 in G_BUFFER_1
*
* Registers used: D0 for actually loading
*
* Precondition: D2 for SRC/DST reg
*
* Postcondition: X
**********************************************************************************
LOAD_ADDR_REGISTER:
    CLR.L   D0

    JSR     LOAD_A
    MOVE.B  D2, D0
    JSR     LOAD_NUM
    JMP     (A2)

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. (A3) in G_BUFFER_1
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_ADDRESS:
    JSR     LOAD_PTHSIS_OPEN
    JSR     LOAD_ADDR_REGISTER
    JSR     LOAD_PTHSIS_CLSD
    JMP     (A2)

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. (A3)+ in G_BUFFER_1
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_ADDRESS_W_POST_INC:
    JSR     LOAD_ADDRESS
    JSR     LOAD_PLUS_SIGN
    JMP     (A2)

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. -(A3) in G_BUFFER_1
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_ADDRESS_W_PRE_DEC:
    JSR     LOAD_MINUS_SIGN
    JSR     LOAD_ADDRESS
    JMP     (A2)

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. $1234 in G_BUFFER_1
*
* Registers used: D0 for actually loading
*
* Precondition: D4 for immediate/address value  
*
* Postcondition: X
**********************************************************************************
LOAD_ABS_SHORT:
    CLR.L   D0

    JSR     LOAD_HEX_SIGN
    MOVE.W  D4, D0
    JSR     LOAD_BYTES
    JMP     (A2)

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. $12345678 in G_BUFFER_1
*
* Registers used: D0 for actually loading
*
* Precondition: D4 for immediate/address value  
*
* Postcondition: X
**********************************************************************************
LOAD_ABS_LONG:
    CLR.L   D0

    JSR     LOAD_HEX_SIGN
    MOVE.L  D4, D0
    JSR     LOAD_BYTES
    JMP     (A2)

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. #$1234 in G_BUFFER_1
*
* Registers used: X
*
* Precondition: X 
*
* Postcondition: X
**********************************************************************************
LOAD_IMMDTE:
    JSR     LOAD_IMMDTE_VALU
    JMP     LOAD_ABS_LONG

**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (LOW LEVEL) ****************

* <EA>
**********************************************************************************
* Description: Shifts the hex to the left and loads from the left-most hex to G_BUFFER_1 in ASCII
*
* Registers used: D5 for the loop counter, D1 for loop assist
*
* Precondition: D0 for the immediate/address value  
*
* Postcondition: X
**********************************************************************************
LOAD_BYTES:
        CLR.L   D5
        CLR.L   D1

        MOVE.L  D0, D1
        MOVE.B  #8, D5
LOOP    CMPI    #0, D5
        BGT     ROTATE
        RTS
    
ROTATE  ROL.L   #$04, D1
        MOVE.B  D1, D0
        ANDI.L  #$0000000F, D0
        JSR     LOAD_NUM
        SUBI    #1, D5
        JMP     LOOP        

* <EA>
**********************************************************************************
* Description: Loads ASCII for CR, LF 
*
* Registers used: D0 for actually loading
*
* Precondition: CR, LF 
*
* Postcondition: X
**********************************************************************************
LOAD_NEW_LINE:
    ;CLR.L   D0

    ;MOVE.B  CR, D0
    ;JSR     LOAD_THIS_SHIT
    ;MOVE.B  LF, D0
    ;JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for ', ' 
*
* Registers used: D0 for actually loading
*
* Precondition: COMMA, SPACE
*
* Postcondition: X
**********************************************************************************
LOAD_COMMA_SPACE:
    CLR.L   D0

    MOVE.B  COMMA, D0
    JSR     LOAD_THIS_SHIT
    MOVE.B  SPACE, D0
    JSR     LOAD_THIS_SHIT
    
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for D 
*
* Registers used: D0 for actually loading
*
* Precondition: DATA
*
* Postcondition: X
**********************************************************************************
LOAD_D:
    CLR.L   D0

    MOVE.B  DATA, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for A
*
* Registers used: D0 for actually loading
*
* Precondition: ADDRESS
*
* Postcondition: X
**********************************************************************************
LOAD_A:
    CLR.L   D0

    MOVE.B  ADDRESS, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for (
*
* Registers used: D0 for actually loading
*
* Precondition: PTHSIS_OPEN
*
* Postcondition: X
**********************************************************************************
LOAD_PTHSIS_OPEN:
    CLR.L   D0

    MOVE.B  PTHSIS_OPEN, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for )
*
* Registers used: D0 for actually loading
*
* Precondition: PTHSIS_CLSD
*
* Postcondition: X
**********************************************************************************
LOAD_PTHSIS_CLSD:
    CLR.L   D0

    MOVE.B  PTHSIS_CLSD, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for $
*
* Registers used: D0 for actually loading
*
* Precondition: HEX_SIGN
*
* Postcondition: X
**********************************************************************************
LOAD_HEX_SIGN:
    CLR.L   D0

    MOVE.B  HEX_SIGN, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for #
*
* Registers used: D0 for actually loading
*
* Precondition: IMMDTE_VALU
*
* Postcondition: X
**********************************************************************************
LOAD_IMMDTE_VALU:
    CLR.L   D0

    MOVE.B  IMMDTE_VALU, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for +
*
* Registers used: D0 for actually loading
*
* Precondition: PLUS_SIGN
*
* Postcondition: X
**********************************************************************************
LOAD_PLUS_SIGN:
    CLR.L   D0

    MOVE.B  PLUS_SIGN, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for -
*
* Registers used: D0 for actually loading
*
* Precondition: MINUS_SIGN
*
* Postcondition: X
**********************************************************************************
LOAD_MINUS_SIGN:
    CLR.L   D0

    MOVE.B  MINUS_SIGN, D0
    JSR     LOAD_THIS_SHIT
    RTS
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (LOWEST LEVEL) *************
* <EA>
**********************************************************************************
* Description: Loads the hex value from D0 to G_BUFFER_1 in ASCII. SHIT stands for        
*               Specially-Heeded I/O Target
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_THIS_SHIT:
    MOVE.B  D0, (A4)+
    RTS

* <EA>
**********************************************************************************
* Description: Adds $30 to a number in D0 to make it a hex. If the number is greater
*              than 9 (A~F), then adds $37. Then moves the hex value from D0 to G_BUFFER_1 in ASCII
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_NUM:
    CMPI.B  #$9, D0
    BGT     GT
    BLE     LE
    
GT  ADDI.B  #$37, D0 * A~F
    JMP     END
LE  ADDI.B  #$30, D0 * 0~9
    JMP     END

END MOVE.B  D0, (A4)+
    RTS

* <EA>
**********************************************************************************
* Description: Execution goes here if even one of the EA bit is invalid. Flags the invalid-bit and
*              entirely exits the EA process.
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
INVALID:
            MOVE.B  #%0, IS_VALID_1
            JMP     EXT
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
   ;END    START									;Last line of program





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
