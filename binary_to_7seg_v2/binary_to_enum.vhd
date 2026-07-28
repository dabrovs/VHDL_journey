/*
This module takes 4 bit binary code and outputs
the digit_0 and digit_1 as decimal_enum
Example
Binary: 0010 -> digit_1 = ZERO,	digit_0 = TWO --> 02 
Binary: 1011 -> digit_1 = ONE,	digit_0 = ONE --> 11 
*/


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.four_bit_binary_enum_pkg.ALL;


ENTITY binary_to_enum IS
	PORT (
		binary_code : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		digits      : OUT decimals
	);
END binary_to_enum;


ARCHITECTURE Behavioral OF binary_to_enum IS

	SIGNAL neg_bin_code : STD_LOGIC_VECTOR(3 DOWNTO 0);
	
BEGIN
		
	neg_bin_code <= NOT binary_code;

	PROCESS(neg_bin_code)
	BEGIN
		CASE neg_bin_code IS
		
			WHEN "0001" => digits(1) <= ZERO;		digits(0) <= ONE;			-- 01
			WHEN "0010" => digits(1) <= ZERO;		digits(0) <= TWO;			-- 02
			WHEN "0011" => digits(1) <= ZERO;		digits(0) <= THREE;		-- 03
			WHEN "0100" => digits(1) <= ZERO;		digits(0) <= FOUR;		-- 04
			WHEN "0101" => digits(1) <= ZERO;		digits(0) <= FIVE;		-- 05
			WHEN "0110" => digits(1) <= ZERO;		digits(0) <= SIX;			-- 06
			WHEN "0111" => digits(1) <= ZERO;		digits(0) <= SEVEN;		-- 07
			WHEN "1000" => digits(1) <= ZERO;		digits(0) <= EIGHT;		-- 08
			WHEN "1001" => digits(1) <= ZERO;		digits(0) <= NINE;		-- 09
			WHEN "1010" => digits(1) <= ONE;			digits(0) <= ZERO;		-- 10
			WHEN "1011" => digits(1) <= ONE;			digits(0) <= ONE;			-- 11
			WHEN "1100" => digits(1) <= ONE;			digits(0) <= TWO;			-- 12
			WHEN "1101" => digits(1) <= ONE;			digits(0) <= THREE;		-- 13
			WHEN "1110" => digits(1) <= ONE;			digits(0) <= FOUR;		-- 14
			WHEN "1111" => digits(1) <= ONE;			digits(0) <= FIVE;		-- 15
			               
			WHEN OTHERS => digits(1) <= ZERO;		digits(0) <= ZERO;		-- 00
			
		END CASE;
	END PROCESS;

END Behavioral;