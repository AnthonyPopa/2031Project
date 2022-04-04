; Simple test for the NeoPixel peripheral

ORG 0
    LOADI  3
    OUT    PXL_A
Loop:
    IN     Switches
	SHIFT  5
    OUT    PXL_D
    JUMP   Loop

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
PXL_A:     EQU &H0B0
PXL_D:     EQU &H0B1