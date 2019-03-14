*-----------------------------------------------------------
* Title      : I/O Test File
* Written by : 
* Date       : Fahad Alshehri
* Description: Test file for io.X68
*-----------------------------------------------------------

Test_IO_Start:
    * Prompt user for length
    MOVE.L      #Const_LengthPrompt, Arg_Print_Str
    JSR         Print
    JSR         Input
    
    * Convert length to number
    MOVE.L      #Ret_Input_Str, Arg_HexStrToNum_Str
    JSR         HexStrToNum
    MOVE.L      Ret_HexStrToNum_Num, D0
    
    * If < 1, make 1
    CMPI.B      #1, D0
    BGE         PosNum
    MOVEQ       #1, D0
    BRA         ValidLength
    
PosNum
    * If > 8, make 8
    CMPI.B      #8, D0
    BLE         ValidLength
    MOVEQ       #8, D0
    
ValidLength
    * Store length
    MOVE.B      D0, Arg_NumToHexStr_Length
    
    * Prompt addresses
    JSR         PromptAddress
    
    MOVEA.L     Ret_PromptAddress_StartAddr, A0
    MOVEA.L     Ret_PromptAddress_EndAddr, A1
    
    * Clear buffer
    MOVE.L      #Buffer, Arg_ClearBuffer_Buffer
    JSR         ClearBuffer
    
    * Add start addr msg to buffer
    MOVE.L      #Const_StartAddrMsg, Arg_AddStrToBuffer_String
    MOVE.L      #Buffer, Arg_AddStrToBuffer_Buffer
    JSR         AddStrToBuffer
    
    * Convert start addr to hex
    MOVE.L      A0, Arg_NumToHexStr_Num
    JSR         NumToHexStr
    * then add to buffer
    MOVE.L      #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
    MOVE.L      #Buffer, Arg_AddStrToBuffer_Buffer
    JSR         AddStrToBuffer
    
    * Print buffer
    MOVE.L      #Buffer, Arg_Print_Str
    JSR         PrintLn
    
    * Clear buffer
    MOVE.L      #Buffer, Arg_ClearBuffer_Buffer
    JSR         ClearBuffer
    
    * Add end addr msg to buffer
    MOVE.L      #Const_EndAddrMsg, Arg_AddStrToBuffer_String
    MOVE.L      #Buffer, Arg_AddStrToBuffer_Buffer
    JSR         AddStrToBuffer
    
    * Convert end addr to hex
    MOVE.L      A1, Arg_NumToHexStr_Num
    JSR         NumToHexStr
    * then add to buffer
    MOVE.L      #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
    JSR         AddStrToBuffer
    
    * Clear buffer
    MOVE.L      #Buffer, Arg_Print_Str
    JSR         PrintLn
    
    * Wait for user to press enter
    JSR         WaitForEnter
    
    * Prompt user to start over
    MOVE.L      #Const_TryAgain, Arg_Print_Str
    JSR         Print
    JSR         Input
    
    CMPI.B      #'y', Ret_Input_Str
    BRA         Test_IO_Start
    

    SIMHALT

Buffer              DS.B    80
Const_LengthPrompt  DC.B    'Enter a str length (1-8): ', 0
Const_StartAddrMsg  DC.B    'Start address: $', 0
Const_EndAddrMsg    DC.B    'End address: $', 0
StartAddr           DS.B    9
EndAddr             DS.B    9
Const_TryAgain      DC.B    'Start over? (y/n) ',0

    INCLUDE "io.X68"


    END    Test_IO_Start




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
