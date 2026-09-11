LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


-- ========================================================
-- ENTITY 1: 7-Segment Decoder (4bit to 7seg)
-- ========================================================
ENTITY hex_decoder IS 
	PORT(
		binary_in_4b   : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
		seven_sgmt_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END hex_decoder;

ARCHITECTURE mapping OF hex_decoder IS 
	
	BEGIN

	P1 : PROCESS(binary_in_4b)
			
		BEGIN
			
			CASE binary_in_4b IS
				WHEN "0001" => seven_sgmt_out <= NOT "00000110"; -- ONE 
				WHEN "0010" => seven_sgmt_out <= NOT "01011011"; -- TWO 
				WHEN "0011" => seven_sgmt_out <= NOT "01001111"; -- THREE 
				WHEN "0100" => seven_sgmt_out <= NOT "01100110"; -- FOUR 
				WHEN "0101" => seven_sgmt_out <= NOT "01101101"; -- FIVE 
				WHEN "0110" => seven_sgmt_out <= NOT "01111101"; -- SIX 
				WHEN "0111" => seven_sgmt_out <= NOT "00000111"; -- SEVEN 
				WHEN "1000" => seven_sgmt_out <= NOT "01111111"; -- EIGHT 
				WHEN "1001" => seven_sgmt_out <= NOT "01101111"; -- NINE 
				WHEN "1010" => seven_sgmt_out <= NOT "01110111"; -- A
				WHEN "1011" => seven_sgmt_out <= NOT "01111100"; -- b
				WHEN "1100" => seven_sgmt_out <= NOT "00111001"; -- C
				WHEN "1101" => seven_sgmt_out <= NOT "01011110"; -- d
				WHEN "1110" => seven_sgmt_out <= NOT "01111001"; -- E
				WHEN "1111" => seven_sgmt_out <= NOT "01110001"; -- F
				WHEN OTHERS => seven_sgmt_out <= NOT "00111111"; -- ZERO 
			END CASE;
			
	END PROCESS;
	
END mapping;
