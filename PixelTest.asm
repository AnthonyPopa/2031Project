; Simple test for the NeoPixel peripheral

ORG 0

    LOADI  3
	OUT    PXL_A

    LOAD BLUE
    OUT    PXL_D
	
	IN PXL_D
	STORE VARTEMP
	
	LOADI 6
	OUT PXL_A
	
	LOAD VARTEMP
	OUT PXL_D
	
	

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
PXL_A:     EQU &H0B0
PXL_D:     EQU &H0B1
BLUE: DW &B0000000000011111
SANSRED: DW &H0FFF
ADDBLUE: DW &H0020
VARTEMP: DW 0
ROMP2: DW 0