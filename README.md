# EASy68K-Disassembler
EASy68K-Disassembler made for CSS 422
This disassembles or reverse compiles a given set of machine code to Assembly Machine Code (ASM).    
To do so, we take input commands from a test file (such as *MOVEA.W A5,A6*) which is input through our disassmbler as raw hex value equivalents through predefined Motorola 68K Handbook opcodes and disassembled into the respective command.

An example would be given an input of *NOP* from teh testing value, the inputted hex equivalent value in memory would be *$4E71*, which is viewable within the memory view of the EASy68K simulator. After it's inputted, the value is then read by our disassembler to then output into a console window and log file as the command *NOP*.

As such our disassembler follows the following steps:
1. Validate testing file
2. Read input from test file
3. Validate input from test file, mark input as bad if invalid
4. If valid, translate hex equivalent value in memory to ASCII equivalent values
5. Output good or bad value to console window and log file

For more thorough steps please refer to our documentation files.
# Team REEE
## Members
+ Daniel Yan &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- OP role
+ Fahad Alshehri - IO role
+ Denny Park &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- EA role

# Tools Used
+ **EASy68K Simulator**
+ **Visual Studio Code**

# References
+ **GoldenCrystal 68K opcodes**
+ **Motorola 68K Handbook**

# Commenting Format
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
# Global Constants and Registers
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
# Display Tasks
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
