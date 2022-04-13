; Simple test for the NeoPixel peripheral

ORG 0


		LOADI 3
		OUT PXL_A
		LOADI &HFFFF
		OUT RED
		LOADI 0
		OUT GREEN
		LOADI &HFFFF
		OUT BLUE
		
Loop:	IN Switches
		JZERO Loop
		
		LOADI 4
		OUT PXL_A
		LOADI &H000F
		OUT PXL_D
		LOAD  Test
		OUT PXL_D
		LOAD  Test1
		OUT PXL_D
		
Test:	DW &HF000
Test1:	DW &HF0F0

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
PXL_A:     EQU &H0B0
PXL_D:     EQU &H0B1
ALL_PXLS:  EQU &H0B2
RED:       EQU &H0B3
GREEN:     EQU &H0B4
BLUE:      EQU &H0B5