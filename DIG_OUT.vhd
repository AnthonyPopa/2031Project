-- DIG_OUT.VHD (a peripheral module for SCOMP)
-- 2006.10.08
--
-- This module drives digital outputs like LEDs and latches data on the rising edge of CS.


LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE LPM.LPM_COMPONENTS.ALL;


ENTITY DIG_OUT IS
  PORT(
    CS          : IN  STD_LOGIC;
    RESETN      : IN  STD_LOGIC;
    DATA        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    IO_DATA     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END DIG_OUT;


ARCHITECTURE a OF DIG_OUT IS
  BEGIN
    PROCESS (RESETN, CS)
      BEGIN
        IF (RESETN = '0') THEN
          DATA <= x"0000";
        ELSIF (RISING_EDGE(CS)) THEN
          DATA <= IO_DATA;
        END IF;
      END PROCESS;
  END a;

