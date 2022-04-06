; Simple test for the NeoPixel peripheral

ORG 0
    LOADI  &HFFFF
    OUT    ALL_PXLS


; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
PXL_A:     EQU &H0B0
PXL_D:     EQU &H0B1
ALL_PXLS:  EQU &H0B2