; Simple test for the NeoPixel peripheral

ORG 0
    
Loop:
		LOADI  &HF00F
		OUT    fade_c

DelayAC:
	STORE  DelayTime   ; Save the desired delay
	OUT    Timer       ; Reset the timer
		


; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
PXL_A:     EQU &H0B0
PXL_D:     EQU &H0B1
ALL_PXLS:  EQU &H0B2
fade_c:    EQU &H0B3

Color: 
Diff: 	   DW &H0100
DelayTime:  DW 0