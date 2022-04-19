; Simple test for the NeoPixel peripheral

ORG 0
    
START:			IN Switches
				OR Down
				JZERO Continue
				JUMP Start
				
Continue:		IN SWITCHES
				OR Down
				JPOS Test
				JUMP Continue
				
TEST:			IN SWITCHES
				SUB test1
				JZERO Rainbow
				IN SWITCHES
				SUB test2
				JZERO Running
				IN SWITCHES
				SUB test3
				JZERO BIT16
				IN SWITCHES
				SUB test4
				JZERO BIT24
				IN SWITCHES
				SUB test5
				JZERO ALLPIXL
				IN SWITCHES
				SUB test6
				JZERO Read_T
				IN SWITCHES
				SUB test7
				JZERO RainbowALL
				JUMP TEST
				
RainbowALL:		OUT RAINBOW_D
				IN Switches
				OR Down
				JZERO Start
				JUMP RainbowALL
				
				
Running:		LOAD BIT_C_16
				OUT RUN
				IN Switches
				OR Down
				JZERO Start
				JUMP Running
				
BIT16:			LOADI 4
				OUT PXL_A
				LOAD BIT_c_16
				OUT PXL_D
				JUMP Start
				
BIT24:			LOAD BIT_r_24
				OUT RED
				LOAD BIT_g_24
				OUT GREEN
				LOAD BIT_b_24
				OUT BLUE
				JUMP Start
				
ALLPIXL:	   	LOAD COLOR1
				OUT  ALL_PXLS
				IN Switches
				OR Down
				JZERO Start
				JUMP ALLPIXL
				
Read_T:			
			    JUMP Start
				
Rainbow:		OUT RAINBOW_T
				IN Switches
				OR Down
				JZERO Start
				JUMP Rainbow				



; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
PXL_A:     EQU &H0B0
PXL_D:     EQU &H0B1
ALL_PXLS:  EQU &H0B2
RAINBOW_D: EQU &H0B8
RAINBOW_T: EQU &H0B7
RUN:       EQU &H0B6
RED:       EQU &H0B3
GREEN:     EQU &H0B4
BLUE:      EQU &H0B5
READ:      EQU &H0B9
test1:     DW &B1000000000
test2:     DW &B0100000000
test3:     DW &B0010000000
test4:     DW &B0001000000
test5:     DW &B0000100000
test6:     DW &B0000010000
test7:     DW &B0000001000
down:      DW &B0000000000
COLOR1:    DW &HFFFF
BIT_r_24:  DW &H44
BIT_g_24:  DW &HEC
BIT_b_24:  DW &HF2
BIT_C_16:  DW &H97EE


