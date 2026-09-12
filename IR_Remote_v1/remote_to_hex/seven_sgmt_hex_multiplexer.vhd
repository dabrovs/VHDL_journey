-- ========================================================
-- ENTITY 1: 7-Segment Multiplexer
-- ========================================================
-- 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY seven_sgmt_hex_multiplexer IS

	PORT (
		clk_in						: IN STD_LOGIC := '0';
		num_displays_in			: IN INTEGER RANGE 1 TO 4 := 1; -- How many digits should be displayed?
		data_sgmt_0					: IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0'); -- 4bit hex code for display/digit 0
		data_sgmt_1					: IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0'); -- 4bit hex code for display/digit 1
		data_sgmt_2					: IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0'); -- 4bit hex code for display/digit 2
		data_sgmt_3					: IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0'); -- 4bit hex code for display/digit 3
		test_in						: IN STD_LOGIC := '0';
		
		sgmt_select_out			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0'); -- 4bit string to choose which digit to display
		sgmt_out						: OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0')	-- 8bit string for the segments of the display
	
	);
	
END seven_sgmt_hex_multiplexer;


ARCHITECTURE behavior OF seven_sgmt_hex_multiplexer IS

	COMPONENT hex_decoder

		PORT(
			binary_in_4b	:	IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
			seven_sgmt_out	:	OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	
	END COMPONENT;

	TYPE STEPS IS (INIT, DIGIT_0, DIGIT_1, DIGIT_2, DIGIT_3);
	SIGNAL step_chain : STEPS := INIT;
	SIGNAL hex_decoder_in : STD_LOGIC_VECTOR (3 DOWNTO 0) := (others => '0');

	BEGIN
	
	C1 : hex_decoder
		PORT MAP (
			binary_in_4b => hex_decoder_in,
			seven_sgmt_out => sgmt_out
		);

	P1 : PROCESS(clk_in)

	VARIABLE counter : UNSIGNED(16 DOWNTO 0) := (others => '0');

		BEGIN
		
			IF rising_edge(clk_in) THEN
				counter := counter + 1;
				
				-- clk is 50Mhz. Meaning 1s / 50'000'000 = 0,00000002 signals/s
				-- counter MSB (1 1111 1111 1111 1111) = 131.071
				-- counting takes 131.071 * 0,00000002 = 0,00262 = 2.6ms
				IF (counter = 131071) THEN
			
					CASE step_chain IS
					
						WHEN INIT =>
							
							sgmt_select_out	<= (others => '0');
							hex_decoder_in		<= (others => '0');
						
							--next step by counter and initial value of next_step
							step_chain <= DIGIT_0;
						
						WHEN DIGIT_0 =>
						
							
							sgmt_select_out	<= "1110";
							
							IF test_in = '1' THEN
							-- For testing
								hex_decoder_in		<= "0001"; -- converted to 1 
							ELSE
							-- Normal operation
								hex_decoder_in		<= data_sgmt_0;
							END IF;
							
							-- next step
							IF num_displays_in >= 2 THEN
								step_chain <= DIGIT_1;
							ELSE
								step_chain <= DIGIT_0;
							END IF;
						
						
						WHEN DIGIT_1 =>
						
							sgmt_select_out	<= "1101";
		
							IF test_in = '1' THEN
							-- For testing
								hex_decoder_in		<= "0010"; -- converted to 2
							ELSE
							-- Normal operation
								hex_decoder_in		<= data_sgmt_1;
							END IF;
							
							-- next step
							IF num_displays_in >= 3 THEN
								step_chain <= DIGIT_2;
							ELSE
								step_chain <= DIGIT_0;
							END IF;
						
						WHEN DIGIT_2 =>
						
							sgmt_select_out	<= "1011";
							
							IF test_in = '1' THEN
							-- For testing
								hex_decoder_in		<= "0011"; -- converted to 3
							ELSE
							-- Normal operation
								hex_decoder_in		<= data_sgmt_2;
							END IF;
							
							-- next step
							IF num_displays_in >= 4 THEN
								step_chain <= DIGIT_3;
							ELSE
								step_chain <= DIGIT_0;
							END IF;
						
						WHEN DIGIT_3 =>
						
							sgmt_select_out	<= "0111";
							
							IF test_in = '1' THEN
							-- For testing
								hex_decoder_in		<= "0100"; -- converted to 4
							ELSE
							-- Normal operation
								hex_decoder_in		<= data_sgmt_3;
							END IF;
							
							-- next step
							step_chain <= DIGIT_0;
						
						WHEN OTHERS =>
						
							step_chain <= INIT;
					
					
					END CASE;
				
				END IF;
			
			END IF;
		
	
	END PROCESS P1;
	
	
	
END behavior;


					
					