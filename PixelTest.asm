; Simple test for the NeoPixel peripheral

ORG 0
    LOADI  2
    OUT    PXL_A

    LOAD WHITE
    OUT    PXL_D
    
	IN PXL_D
	STORE VARTEMP

	LOADI 5
	OUT PXL_A
	
	LOAD VARTEMP
	AND SANSRED
	OUT PXL_D
	

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
PXL_A:     EQU &H0B0
PXL_D:     EQU &H0B1
WHITE: DW &HFFFF
SANSRED: DW &H0FFF
VARTEMP: DW 0