LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- ========================================================
-- ENTITY 1: 7-Segment Decoder
-- ========================================================
ENTITY hex_decoder IS 
	PORT(
		binary_in      : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
		seven_sgmt_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END hex_decoder;

ARCHITECTURE mapping OF hex_decoder IS 
	
	BEGIN

	P1 : PROCESS(binary_in)
	
		VARIABLE binary_in_neg : STD_LOGIC_VECTOR (3 DOWNTO 0) := (others => '0');
		
		BEGIN
		
			binary_in_neg := NOT binary_in;
			
			CASE binary_in_neg IS
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


-- ========================================================
-- ENTITY 2: Multiplexer 
-- ========================================================
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY binary_to_hex IS 
	PORT(
		clk                   : IN  STD_LOGIC;
		binary_in             : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
		seven_sgmt_select_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		seven_sgmt_out        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END binary_to_hex;

ARCHITECTURE behavior OF binary_to_hex IS

	SIGNAL binary_in_8bit    : STD_LOGIC_VECTOR (7 DOWNTO 0) := (others => '0');
	SIGNAL binary_in_divided : STD_LOGIC_VECTOR (3 DOWNTO 0) := (others => '0');

	COMPONENT hex_decoder 
        PORT (
            binary_in      : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
            seven_sgmt_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
	END COMPONENT;
				
BEGIN
				
	C1 : hex_decoder
		PORT MAP (
			binary_in      => binary_in_divided, 
			seven_sgmt_out => seven_sgmt_out
		);
				
	P2 : PROCESS(clk)
	
		VARIABLE counter : UNSIGNED(16 DOWNTO 0) := (others => '0');
		
		BEGIN
		
		IF rising_edge(clk) THEN
		
			-- CLK is 50Mhz. Bit 17 = 2^(17-1) = 65536 rising edges
			-- (1s / 50x10^6) * 65536 = 0.0013s
			-- Meaning it takes 1.3ms to toggle
			counter := counter + 1;
			
         -- Pad 4-bit input to 8 bits as preparation for IR com
			binary_in_8bit <= "1111" & binary_in;
			
			IF counter(16) = '0' THEN
				-- display digit 0
				seven_sgmt_select_out <= NOT "0001";
				binary_in_divided     <= binary_in_8bit(3 DOWNTO 0);
			ELSE
				-- display digit 1
				seven_sgmt_select_out <= NOT "0010";
				binary_in_divided     <= binary_in_8bit(7 DOWNTO 4);
			END IF;
			
		END IF;
		
	END PROCESS;
				
END behavior;