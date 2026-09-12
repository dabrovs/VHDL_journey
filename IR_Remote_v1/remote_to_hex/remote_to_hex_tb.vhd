	LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;
	USE IEEE.NUMERIC_STD.ALL;
	USE STD.TEXTIO.ALL;
	USE STD.ENV.stop;


	ENTITY remote_to_hex_tb IS


	END ENTITY;


	ARCHITECTURE behavior OF remote_to_hex_tb IS


		-- COMPONENT DECLARATION ----------------------------------------
		COMPONENT remote_to_hex
			PORT (
			
				clk_in			:	IN		STD_LOGIC := '0'; -- Clock signal 50MHz
				IR_signal_in	:	IN		STD_LOGIC := '0'; -- IR signal from receiver
				dip_sw_in		:	IN		STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); -- 4bit string from dip switches
				sgmt_out			:	OUT	STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); -- 8bit string for segments of display
				sgmt_select		:	OUT	STD_LOGIC_VECTOR(3 downto 0) := (others => '0')  -- 4bit string to toggle between displays
				
			);
		END COMPONENT;


		-- SIGNALS DECLARATION ------------------------------------------
		SIGNAL clk						:	STD_LOGIC := '0';
		SIGNAL IR_signal				:	STD_LOGIC := '1';
		SIGNAL dip_sw					:	STD_LOGIC_VECTOR(3 downto 0) := ("1110"); -- cmd
		SIGNAL sgmt_sel				:	STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
		SIGNAL sgmt						:	STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
		TYPE STEP IS (INIT, SEND_START_0, SEND_START_1, GET_BIT, SEND_0, SEND_1, DONE);
		SIGNAL step_chain	: STEP := INIT;
			
		-- BEGIN ARCHITECTURE -------------------------------------------
		BEGIN
		
		-- 50MHz clock signal
		clk <= NOT clk AFTER 10 ns;
		
		-- COMPONENT CALL ------------------------------
		C1: remote_to_hex 
			PORT MAP (
				clk_in => clk,
				IR_signal_in => IR_signal,
				dip_sw_in => dip_sw,
				sgmt_out => sgmt,
				sgmt_select => sgmt_sel
			);
			
		P1: PROCESS(clk)
		
			-- Data variables 
			VARIABLE cmd_data		: STD_LOGIC_VECTOR(7 DOWNTO 0) := ("10101011"); -- A - B
			VARIABLE addr_data	: STD_LOGIC_VECTOR(7 DOWNTO 0) := ("11001101"); -- C - D
			VARIABLE data_all		: STD_LOGIC_VECTOR(31 DOWNTO 0)		:= ("00000000000000000000000000000000");
			
			-- Step chain variables
			VARIABLE first_time	: BOOLEAN := TRUE;
			VARIABLE clk_cnt		: INTEGER RANGE 0 TO 500000 := 0;
			VARIABLE index			: INTEGER RANGE 0 TO 32 := 0; -- Index var for data array
			-- clk is 50MHZ -> 1s / 50Mhz = 0,00000002 is duration between to clk signals
			-- Start signal is 9ms burst followed by 4,5ms silence
			-- 9ms		-> 0,009s / 0,00000002 = 450'000 cycles
			-- 4,5ms		-> 0,0045s / 0,00000002		= 225'000 cycles
			CONSTANT burst_start			: INTEGER := 450000;
			CONSTANT silence_start		: INTEGER := 225000;
			-- Every bit starts with a 560µs burst and then silence
			-- if burst + silce = 2,25ms -> logical 1
			-- if burst + silce = 1,125ms -> logical 0	
			-- 560µs		-> 0,00056s / 0,00000002	= 28'000 cycles
			-- 1,125ms	-> 0,001125s / 0,00000002	= 56'250 cycles
			-- 2,25ms	-> 0,00225s / 0,00000002	= 112'500 cycles
			CONSTANT burst_bit			: INTEGER := 28000;
			CONSTANT silence_bit_0		: INTEGER := 28250; -- 56'250 - 28'000 = 28'250
			CONSTANT silence_bit_1		: INTEGER := 84500; -- 112'500 - 28'000 = 84'500
			VARIABLE data_eval_cnt		: INTEGER RANGE 0 TO 5 := 0;
			VARIABLE digit_0_printed	: BOOLEAN := FALSE;
			VARIABLE digit_1_printed	: BOOLEAN := FALSE;
			
			-- Text output variables
			VARIABLE l : LINE;
		
			BEGIN
			
			
			IF rising_edge(clk) THEN
			
			
				CASE step_chain IS
					
					----------------------------------------------------------------------
					WHEN INIT => 
					
						clk_cnt := 0;						
						data_all := (NOT cmd_data) & cmd_data & (NOT addr_data) &  addr_data; -- LSB is right!!
					

						WRITE(l, STRING'("---- Init of simulation -----" ) );
						WRITELINE(OUTPUT,l);
												
						WRITE(l, STRING'("All data send by IR signal: " & TO_STRING(data_all) ) );
						WRITELINE(OUTPUT,l);
						
						WRITE(l, STRING'("Cmd send by IR signal: " & TO_STRING(cmd_data) ) );
						WRITELINE(OUTPUT,l);
						
						WRITE(l, STRING'("Cmd_inv send by IR signal: " & TO_STRING(NOT cmd_data) ) );
						WRITELINE(OUTPUT,l);
						
						WRITE(l, STRING'("Address send by IR signal: " & TO_STRING(addr_data) ) );
						WRITELINE(OUTPUT,l);
						
						WRITE(l, STRING'("Address_inv send by IR signal: " & TO_STRING(NOT addr_data) ) );
						WRITELINE(OUTPUT,l);
						
						WRITE(l, STRING'("Segment select at first time  (neg): " & TO_STRING(sgmt_sel) ) );
						WRITELINE(OUTPUT,l);
						
						WRITE(l, STRING'("Segment out at first time  (neg): " & TO_STRING(sgmt) ) );
						WRITELINE(OUTPUT,l);
						
						WRITE(l, STRING'("Expected hex code for cmd_data = AB" ) );
						WRITELINE(OUTPUT,l);
						WRITE(l, STRING'("Digit 1 = A = 01110111 or 10001000(neg)" ) );
						WRITELINE(OUTPUT,l);
						WRITE(l, STRING'("Digit 0 = B = 01111100 or 10000011(neg)" ) );
						WRITELINE(OUTPUT,l);
						
						WRITE(l, STRING'("Expected hex code for addr_data = CD" ) );
						WRITELINE(OUTPUT,l);
						WRITE(l, STRING'("Digit 1 = C = 00111001 or 11000110(neg)" ) );
						WRITELINE(OUTPUT,l);
						WRITE(l, STRING'("Digit 0 = d = 01011110 or 10100001(neg)" ) );
						WRITELINE(OUTPUT,l);
									
					
						-- next step
						step_chain <= SEND_START_0;
						first_time := TRUE;
					
					----------------------------------------------------------------------
					WHEN SEND_START_0 =>
					-- We need to send 9ms burst and then 4,5ms silence
					-- Here we send the burst
					-- 0,009s / 0,00000002 = 450'000 cycles
					
						-- fist cycle in step
						IF first_time THEN
							clk_cnt := 0;
							IR_signal <= '0'; -- Signal is low active
							IF data_eval_cnt >= 2 THEN
								dip_sw <= "1011"; -- Address
							END IF;
							first_time := FALSE;
						END IF;
						
						-- count cycles
						IF IR_signal = '0' THEN
							clk_cnt := clk_cnt + 1;
						END IF;
						
						-- next step
						IF clk_cnt >= burst_start THEN -- 9ms over 
							step_chain <= SEND_START_1;
							first_time := TRUE;
						END IF;
					
					----------------------------------------------------------------------
					WHEN SEND_START_1 =>
					-- We need to send 9ms burst and then 4,5ms silence
					-- Here we send the 4,5ms silence
					-- 0,0045s / 0,00000002 = 225'000 cycles
					
						-- fist cycle in step
						IF first_time THEN
							clk_cnt := 0;
							IR_signal <= '1'; -- Signal is low active
							first_time := FALSE;
						END IF;
						
						-- count cycles
						IF IR_signal = '1' THEN
							clk_cnt := clk_cnt + 1;
						END IF;
						
						-- next step
						IF clk_cnt >= silence_start THEN -- 9ms over 
							index := 0;
							step_chain <= GET_BIT;
							first_time := TRUE;
						END IF;
						
					
					----------------------------------------------------------------------
					WHEN GET_BIT =>
					-- We loop through the data array and send each bit accordingly
					-- Here we get the bit and send the burst before going to the according step to send 0 or 1
					-- When data is transmitted we have to send one additional burst for the last bit
					
						-- fist cycle in step
						IF first_time THEN
							clk_cnt := 0;
							IR_signal <= '0'; -- Signal is low active
							first_time := FALSE;
						END IF;
					
						-- count cycles
						IF IR_signal = '0' THEN -- Signal is low active
							clk_cnt := clk_cnt + 1;
						END IF;
						
						-- next step
						IF clk_cnt >= burst_bit THEN

							IF index <= 31 THEN -- send bit
							
								IF data_all(index) = '1' THEN
									step_chain <= SEND_1;
									first_time := TRUE;
								ELSE
									step_chain <= SEND_0;
									first_time := TRUE;
								END IF;
								
							ELSE -- All bits send. Done
								step_chain <= DONE;
								first_time := TRUE;
							END IF;
							
		
						END IF;
						
						
					----------------------------------------------------------------------
					WHEN SEND_0 =>
					
						-- fist cycle in step
						IF first_time THEN
							clk_cnt := 0;
							IR_signal <= '1'; -- Signal is low active
							first_time := FALSE;
						END IF;
					
						-- count cycles
						IF IR_signal = '1' THEN -- Signal is low active
							clk_cnt := clk_cnt + 1;
						END IF;
						
						-- next step
						IF clk_cnt >= silence_bit_0 THEN
							index := index + 1;
							step_chain <= GET_BIT;						
							first_time := TRUE;
						END IF;
					
					----------------------------------------------------------------------
					WHEN SEND_1 =>
					
						-- fist cycle in step
						IF first_time THEN
							clk_cnt := 0;
							IR_signal <= '1'; -- Signal is low active
							first_time := FALSE;
						END IF;
					
						-- count cycles
						IF IR_signal = '1' THEN -- Signal is low active
							clk_cnt := clk_cnt + 1;
						END IF;
						
						-- next step
						IF clk_cnt >= silence_bit_1 THEN
							index := index + 1;
							step_chain <= GET_BIT;						
							first_time := TRUE;
						END IF;
					
					----------------------------------------------------------------------
					WHEN DONE =>
					
						-- fist cycle in step
						IF first_time THEN
							clk_cnt := 0;
							IR_signal <= '1'; -- Signal is low active
													
							data_eval_cnt := data_eval_cnt + 1;
							digit_0_printed := FALSE;
							digit_1_printed := FALSE;
							
							WRITE(l, STRING'("----- data eval count ------: " & TO_STRING(data_eval_cnt) ) );
							WRITELINE(OUTPUT,l);
							
							
							first_time := FALSE;
						END IF;
						
						
						IF clk_cnt <= 250000 THEN
							clk_cnt := clk_cnt + 1; --give remote_to_hex.vhd some time to eval last bit.
						ELSIF data_eval_cnt <= 4 THEN
														
							IF (sgmt_sel = "1110") AND NOT digit_0_printed THEN
								
								WRITE(l, STRING'("Dip switch selection is (neg): " & TO_STRING(dip_sw) ) );
								WRITELINE(OUTPUT,l);
								
								WRITE(l, STRING'("Segment select (neg): " & TO_STRING(sgmt_sel) ) );
								WRITELINE(OUTPUT,l);
								
								WRITE(l, STRING'("Segment out (neg): " & TO_STRING(sgmt)) );
								WRITELINE(OUTPUT,l);
								
								digit_0_printed := TRUE;
							
							ELSIF (sgmt_sel = "1101") AND NOT digit_1_printed THEN
							
							
								WRITE(l, STRING'("Dip switch selection is (neg): " & TO_STRING(dip_sw) ) );
								WRITELINE(OUTPUT,l);
								
								WRITE(l, STRING'("Segment select (neg): " & TO_STRING(sgmt_sel) ) );
								WRITELINE(OUTPUT,l);
								
								WRITE(l, STRING'("Segment out (neg): " & TO_STRING(sgmt) ) );
								WRITELINE(OUTPUT,l);
								
								digit_1_printed := TRUE;
								
							ELSIF digit_0_printed AND digit_1_printed THEN
								
								first_time := TRUE;
								step_chain <= SEND_START_0;
								
							END IF;
							
						ELSE
							
							stop;
							
						END IF;					
							
						
					----------------------------------------------------------------------
					WHEN OTHERS =>
						
						step_chain <= INIT;
						
				END CASE;
				
			END IF;
			
			
			
		END PROCESS P1;
		
		

	END behavior;
