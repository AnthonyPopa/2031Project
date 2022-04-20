;read modify write functionality

ORG 0

		LOADI 10
		OUT PXL_A
		LOAD COLOR
		OUT PXL_D
		
		IN PXL_D
		STORE TEMP
		LOADI 15
		OUT PXL_A
		
		LOAD TEMP
		OUT PXL_D
	
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
RUN: 	   EQU &H0B6
RAINBOW:   EQU &H0B7
COLOR: DW &H97EE
TEMP: 