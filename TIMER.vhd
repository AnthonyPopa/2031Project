-- TIMER.VHD (a peripheral module for SCOMP)
-- 2003.04.24
--
-- Timer returns a 16 bit counter value with a resolution of the CLOCK period.
-- Writing any value to timer resets to 0x0000, but the timer continues to run.
-- The counter value rolls over to 0x0000 after a clock tick at 0xFFFF.

LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE LPM.LPM_COMPONENTS.ALL;


ENTITY TIMER IS
	PORT(CLOCK,
		RESETN,
		CS,
		IO_WRITE : IN    STD_LOGIC;
		IO_DATA  : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END TIMER;


ARCHITECTURE a OF TIMER IS
	SIGNAL COUNT     : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL IO_COUNT  : STD_LOGIC_VECTOR(15 DOWNTO 0); -- a stable copy of the count for the IO
	SIGNAL IO_OUT    : STD_LOGIC;

	BEGIN
	
	-- Use LPM function to create bidirection I/O data bus
	IO_BUS: lpm_bustri
	GENERIC MAP (
		lpm_width => 16
	)
	PORT MAP (
		data     => IO_COUNT,
		enabledt => IO_OUT,
		tridata  => IO_DATA
	);


	IO_OUT <= (CS AND NOT(IO_WRITE));


	PROCESS (CLOCK, RESETN, CS, IO_WRITE)
	BEGIN
		IF (RESETN = '0' OR (CS AND IO_WRITE) = '1') THEN
			COUNT <= x"0000";
		ELSIF (rising_edge(CLOCK)) THEN
			COUNT <= COUNT + 1;
		END IF;
	END PROCESS;
	
	-- Don't change IO_COUNT if an IO operation is occuring
	PROCESS (CS, COUNT, IO_COUNT)
	BEGIN
		IF CS = '0' THEN
			IO_COUNT <= COUNT;
		ELSE
			IO_COUNT <= IO_COUNT;
		END IF;
	END PROCESS;

END a;

