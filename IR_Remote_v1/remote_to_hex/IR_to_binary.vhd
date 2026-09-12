-- ========================================================
-- ENTITY 1: IR to binary 
-- ========================================================
-- IR receiver to 32bit binary code (Standard NEC protocol)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY IR_to_binary IS

	PORT (
		clk_in			:	IN		STD_LOGIC := '0';
		IR_signal		:	IN		STD_LOGIC := '0';
		binary_out		:	OUT	STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0')
	);
	
	
END ENTITY;

ARCHITECTURE behavior OF IR_to_binary IS

	-- COMPONENT DECLARATION ----------------------------------------
	-- SIGNALS & TYPE DECLARATION -----------------------------------
	TYPE STEP IS (INIT, WAIT_4_START_1, WAIT_4_START_2, WAIT_4_PULSE_1, WAIT_4_PULSE_2, ASSIGN_LOG_VAL, DONE, ERROR);
	SIGNAL step_chain : STEP := INIT;
	SIGNAL step_chain_old : STEP := INIT;
	
	
	
	BEGIN
	-- COMPONENT CALL -----------------------------------------------
	-- LOGIC --------------------------------------------------------
	
		P1 : PROCESS(clk_in)
		
			VARIABLE IR_local						: STD_LOGIC := '0';
			VARIABLE index							: INTEGER RANGE 0 TO 32 := 0;
			VARIABLE first_time					: BOOLEAN := TRUE;
			VARIABLE address, cmd				: STD_LOGIC_VECTOR (7 DOWNTO 0) := (others => '0');
			VARIABLE address_neg, cmd_neg		: STD_LOGIC_VECTOR (7 DOWNTO 0) := (others => '0');
			VARIABLE count_pulse					: BOOLEAN := FALSE;
			VARIABLE cycle_counter				: INTEGER RANGE 0 TO 500000 := 0;
			-- clk is 50MHZ -> 1s / 50Mhz = 0,00000002 is duration between to clk signals
			-- If we need to wait 9ms then this is equivalent to 0,009s / 0,00000002 = 450'000 cycles
			-- 4,5ms		-> 0,0045s / 0,00000002		= 225'000 cycles
			-- 2,25ms	-> 0,00225s / 0,00000002	= 112'500 cycles - Duration of logical 1
			-- 1,125ms	-> 0,001125s / 0,00000002	= 56'250 cycles - Duration of logical 0
			-- 1,7ms		-> 0,0017s / 0,00000002		= 85'000 cycles - Threshold between logical 0 and logical 1
			VARIABLE timeout_counter			: INTEGER RANGE 0 TO 950000 := 0;		
			-- 18ms		-> 0,018s / 0,00000002		= 900'000 cycles		
			VARIABLE done_counter			: INTEGER RANGE 0 TO 25000500 := 0;		
			-- 2s			-> 2s / 0,00000002			= 25'000'000 cycles	
			
			VARIABLE IR_prev         : STD_LOGIC := '1'; 
			VARIABLE IR_falling_edge : BOOLEAN   := FALSE;
			VARIABLE IR_rising_edge  : BOOLEAN   := FALSE;
			
			BEGIN
			
			IF rising_edge(clk_in) THEN
				
				IR_local := NOT IR_signal;

				-- build falling edge to use in step chain
				IR_falling_edge := (IR_prev = '1' AND IR_local = '0');
				-- build rising edge to use in step chain
				IR_rising_edge := (IR_prev = '0' AND IR_local = '1');
				 -- Update history for the next clock cycle
				IR_prev := IR_local;
				
				-- step chain timeout
				IF (step_chain = step_chain_old) AND (step_chain /= INIT) AND (step_chain /= DONE) THEN
					timeout_counter := timeout_counter + 1;
					IF timeout_counter >= 900000 THEN
						step_chain <= ERROR;
						first_time := TRUE;
					END IF;
				ELSE
					timeout_counter := 0;
				END IF;
			
				CASE step_chain IS
				
					------------------------------------------------
					-- Initialize step chain ------
					WHEN INIT =>
						
						IF first_time THEN
							index := 0;
							cycle_counter := 0;
							address		:= (others => '0');
							address_neg	:= (others => '0');
							cmd			:= (others => '0');
							cmd_neg		:= (others => '0');
							binary_out	<= (others => '0');
							count_pulse := FALSE;
							first_time := FALSE;
							step_chain_old <= step_chain;
						END IF;
						
						-- next step
						IF IR_rising_edge THEN
							first_time := TRUE;
							step_chain <= WAIT_4_START_1;
						END IF;
					
					------------------------------------------------
					-- Wait for the start signal -> 9ms burst ------
					WHEN WAIT_4_START_1 =>
					
						IF first_time THEN
							cycle_counter := 0;
							first_time := FALSE;
							step_chain_old <= step_chain;
						END IF;
						
						IF IR_local = '1' THEN
							-- count cycles
							cycle_counter := cycle_counter + 1;
							
							 -- next step
							IF cycle_counter >= 400000 THEN
								first_time := TRUE;
								step_chain <= WAIT_4_START_2;
							END IF;
								
						ELSE
							first_time := TRUE;
							step_chain <= INIT;
						END IF;
					
					------------------------------------------------
					-- Wait for the start signal -> 4.5ms silence after 9ms burst ------
					WHEN WAIT_4_START_2 =>
					
						IF first_time THEN
							cycle_counter := 0;
							first_time := FALSE;
							step_chain_old <= step_chain;
						END IF;
						
						IF IR_local = '0' THEN
							-- count cycles
							cycle_counter := cycle_counter + 1;
							
							 -- next step
							IF cycle_counter >= 200000 THEN
								first_time := TRUE;
								step_chain <= WAIT_4_PULSE_1;
							END IF;
								
						END IF;
					
					------------------------------------------------
					-- Wait for first burst that initiates sending of logical 0 or logical 1
					-- First a 560µs burst is send then silence
					-- If pulse = burst + silence = 1,125ms -> logical 0
					-- If pulse = burst + silence = 2,25ms -> logical 1
					WHEN WAIT_4_PULSE_1 =>
						
						IF first_time THEN
							cycle_counter := 0;						
							first_time := FALSE;
							step_chain_old <= step_chain;
						END IF;
						
						-- next step
						IF IR_rising_edge THEN
							step_chain <= WAIT_4_PULSE_2;
							first_time := TRUE;
						END IF;
						
					------------------------------------------------
					-- Count duration of pulse to evaluate bit
					-- (burst + silence) <= 1,7ms -> log.0
					-- (burst + silence) > 1,7ms -> log.1
					WHEN WAIT_4_PULSE_2 =>
					
						IF first_time THEN
							cycle_counter := 0;
							count_pulse := TRUE;
							first_time := FALSE;
							step_chain_old <= step_chain;
						END IF;
					
						-- next step
						IF IR_rising_edge THEN -- Start of next bit
							count_pulse := FALSE;
							first_time := TRUE;
							step_chain <= ASSIGN_LOG_VAL;
						ELSIF count_pulse THEN
							cycle_counter := cycle_counter + 1;
						END IF;
					
					
					------------------------------------------------
					-- Evaluate bit and assign to appropiate data
					WHEN ASSIGN_LOG_VAL =>
					
						IF first_time THEN
							first_time := FALSE;
							step_chain_old <= step_chain;
						END IF;
						
						-- logical 0
						IF cycle_counter <= 85000 THEN 
							IF index <= 7 THEN
								address(index) := '0';
							ELSIF (index >= 8) AND (index <= 15) THEN
								address_neg(index - 8) := '0';
							ELSIF (index >= 16) AND (index <= 23) THEN
								cmd(index - 16) := '0';
							ELSE
								cmd_neg(index - 24) := '0';
							END IF;
								
						-- logical 1
						ELSE
							IF index <= 7 THEN
								address(index) := '1';
							ELSIF (index >= 8) AND (index <= 15) THEN
								address_neg(index - 8) := '1';
							ELSIF (index >= 16) AND (index <= 23) THEN
								cmd(index - 16) := '1';
							ELSE
								cmd_neg(index - 24) := '1';
							END IF;
							
						END IF;
						
						-- next step
						index := index + 1;
						IF index <= 31 THEN
							-- Data not complete. Get next bit
							first_time := TRUE;
							step_chain <= WAIT_4_PULSE_2;
						ELSE
							-- Data complete. Done
							first_time := TRUE;
							step_chain <= DONE;
						END IF;
					
					------------------------------------------------
					-- Done.
					WHEN DONE =>
					
						IF first_time THEN
						
							first_time := FALSE;
							step_chain_old <= step_chain;
							
							done_counter := 0;
						
							 -- Concatenate data
							 binary_out <= address & address_neg & cmd & cmd_neg;
							
						END IF;
						
						done_counter := done_counter + 1;
						-- next step
						IF done_counter > 25000000 THEN
							step_chain <= INIT;
							first_time := TRUE;
						END IF;
					
					------------------------------------------------
					-- Error step
					WHEN ERROR =>
					
						IF first_time THEN
							first_time := FALSE;
							step_chain_old <= step_chain;
						END IF;
						
						address 		:= "11111111";
						address_neg := "00000000";
						cmd 			:= "11111111";
						cmd_neg 		:= "00000000";
					
					
						-- next step
						step_chain <= DONE;
						first_time := FALSE;
						
					------------------------------------------------
					-- Should never be here
					WHEN OTHERS =>
					
						-- next step
						step_chain <= ERROR;
						first_time := TRUE;
				
				END CASE;
				
			END IF;
		
		END PROCESS P1;
	
END behavior;