# EASy68K-Disassembler
EASy68K-Disassembler made for CSS 422
This disassembles or reverse compiles a given set of code. So we take input commands as a test file (say MOVEA.W A5,A6) and disassemble it to machine code then print it out.
# Team REEE
## Members
+ Daniel Yan
+ Fahad Alshehri
+ Denny Park
# Week 1 
- [X] Make a meetup schedule
- [X] Define roles for each person
- [X] Start to learn Assembly 68k
# Week 2
- [X] Print out NOP and RTS based on binary value inputs
- [X] Start EA skeleton for addressing modes
- [X] Start I/O systems for conversions in display and File I/O
- [X] Finish JMP Table for support operands
- [X] Finish Subroutines for parsing bits in operands which needs masking or shifting
# Week 3
- [X] Finish EA addressing modes for all basic supported EA modes
- Big overhaul in terms of tasks
# Week 4
ALL
- [X] Things to avoid for Disassembler Project
- [X] Pass whole Disassembler as a test case, WIP
IO
- [X] Documentation for Disassembler
- [x] Passing instruction to OP
- [x] Printing overall instruction
- [X] Test demo program for all supported commands
- [X] Validation testing for I/O
- [X] Adhere to commenting format
- [X] Flowchart for major routines
- [ ] Ported all Gdoc documentation to Word
OP Code
- [X] Finish identification for all OP codes (supported and unsupported)
- [X] Load messages into buffer successfully
- [X] Finish up comments for all lines and methods, WIP up to $E
- [X] Validation testing for ALL OP codes
- [X] Finished current integration tests
- [X] Flowchart for major routines
- [X] Finished documentation for role
EA
- [x] Finish Trailing Bits
- [X] Use OP code parsings successfully
- [x] Adhere to commenting format
- [X] Flowchart for major routines
- [ ] Finished MOVEM

Commenting Format
```
* <YOUR_ROUTINE_NAME_HERE>
**********************************************************************************
* Description:
*
* Registers used: 
*
* Precondition: 
*
* Postcondition: 
**********************************************************************************

Comments for every line ; Like this
```
Global Constants and Registers
```
Constants:
CUR_OP_CODE - refers to current 16 bit instruction set
OP_SIZE - refers to current size of the CUR_OP_CODE (used for immediates as well)
G_BUFFER - good buffer to print to
B_BUFFER - bad buffer to print to
IS_VALID - Flag set to determine if it's a valid code. 0 is invalid, 1 is valid code.

FOR EA:
MNEMONIC - First 4 op code bits   (15-12)
FIRST_3 - First '3' bits          (11-9)
SECOND_3 - Second '3' bits        (8-6)
THIRD_3 - Third '3' bits          (5-2)
FOURTH_3 - Fourth '3' bits        (2-0)

Registers:
A5: Starting Address
A6: Ending Address
A4: G_BUFFER
```
Display Tasks
```
All loads are done to G_BUFFER
<ADDRESS> <OPERAND> <EA> 
Example:
1000 MOVEA.W A5,A1
Load Order
<ADDRESS> - OP person
<OPERAND> - OP person
<EA> - EA
$<HEX VALUE> - EA
IO then puts a null terminating string '0' to print out the G_BUFFER.
```
For a BAD operand, the following will be printed to the B_BUFFER
```
<ADDRESS> DATA $<HEX VALUE>
Example:
1000 DATA $FFFF
```


File Header commenting format
```
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
```
