-- IO DECODER for SCOMP
-- This eliminates the need for a lot of AND decoders or Comparators 
--    that would otherwise be spread around the top-level BDF

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY IO_DECODER IS

  PORT
  (
    IO_ADDR       : IN STD_LOGIC_VECTOR(10 downto 0);
    IO_CYCLE      : IN STD_LOGIC;
    SWITCH_EN     : OUT STD_LOGIC;
    LED_EN        : OUT STD_LOGIC;
    TIMER_EN      : OUT STD_LOGIC;
    HEX0_EN       : OUT STD_LOGIC;
    HEX1_EN       : OUT STD_LOGIC;
    PXL_A_EN      : OUT STD_LOGIC;
    PXL_D_EN      : OUT STD_LOGIC;
<<<<<<< Updated upstream
	 ALL_PXLS		: OUT STD_LOGIC
=======
	 ALL_PXLS		: OUT STD_LOGIC;
	 BIT24_R       : OUT STD_LOGIC;
	 BIT24_G       : OUT STD_LOGIC;
	 BIT24_B       : OUT STD_LOGIC;
	 RUN_PXL			: OUT STD_LOGIC;
	 RAINBOW			: OUT STD_LOGIC
>>>>>>> Stashed changes
  );

END ENTITY;

ARCHITECTURE a OF IO_DECODER IS

  SIGNAL  ADDR_INT  : INTEGER RANGE 0 TO 2047;
  
begin

  ADDR_INT <= TO_INTEGER(UNSIGNED(IO_ADDR));
        
  SWITCH_EN    <= '1' WHEN (ADDR_INT = 16#000#) and (IO_CYCLE = '1') ELSE '0';
  LED_EN       <= '1' WHEN (ADDR_INT = 16#001#) and (IO_CYCLE = '1') ELSE '0';
  TIMER_EN     <= '1' WHEN (ADDR_INT = 16#002#) and (IO_CYCLE = '1') ELSE '0';
  HEX0_EN      <= '1' WHEN (ADDR_INT = 16#004#) and (IO_CYCLE = '1') ELSE '0';
  HEX1_EN      <= '1' WHEN (ADDR_INT = 16#005#) and (IO_CYCLE = '1') ELSE '0';
  PXL_A_EN     <= '1' WHEN (ADDR_INT = 16#0B0#) and (IO_CYCLE = '1') ELSE '0';
  PXL_D_EN     <= '1' WHEN (ADDR_INT = 16#0B1#) and (IO_CYCLE = '1') ELSE '0';
  ALL_PXLS		<= '1' WHEN (ADDR_INT = 16#0B2#) and (IO_CYCLE = '1') ELSE '0';
<<<<<<< Updated upstream
=======
  BIT24_R   	<= '1' WHEN (ADDR_INT = 16#0B3#) and (IO_CYCLE = '1') ELSE '0';
  BIT24_G		<= '1' WHEN (ADDR_INT = 16#0B4#) and (IO_CYCLE = '1') ELSE '0';
  BIT24_B		<= '1' WHEN (ADDR_INT = 16#0B5#) and (IO_CYCLE = '1') ELSE '0';
  RUN_PXL		<= '1' WHEN (ADDR_INT = 16#0B6#) and (IO_CYCLE = '1') ELSE '0';
  RAINBOW		<= '1' WHEN (ADDR_INT = 16#0B7#) and (IO_CYCLE = '1') ELSE '0';
>>>>>>> Stashed changes
	
 
END a;
