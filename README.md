# EASy68K-Disassembler
EASy68K-Disassembler made for CSS 422

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
- [ ] Flowcharting structuring
- [ ] Things to avoid for Disassembler Project
- [ ] Pass whole Disassembler as a test case

IO
- [ ] Documentation for Disassembler
- [ ] Passing instruction to OP
- [ ] Printing overall instruction
- [ ] Test demo program for all supported commands
- [ ] Validation testing for I/O
- [ ] Adhere to commenting format

OP Code
- [ ] Finish identification for all OP codes
- [ ] Load messages into buffer successfully
- [ ] Adhere to commenting format
- [ ] Validation testing for OP codes

EA
- [ ] Finish Trailing Bits
- [ ] Use OP code parsings successfully
- [ ] Adhere to commenting format

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
EA_SIZE - refers to current size of the CUR_OP_CODE (used for immediates as well)
G_BUFFER - good buffer to print to
L_BUFFER - bad buffer to print to

Registers:
A5: Starting Address
A6: Ending Address
A4: G_BUFFER
```
Display Tasks
```
<ADDRESS> <OPERAND> <EA> $<HEX VALUE>
Example:
1000 MOVEA.W A5,A1 $3CBC
Load Order
<ADDRESS> - OP person
<OPERAND> - OP person
<EA> - EA
$<HEX VALUE> - EA
```
