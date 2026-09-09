LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;
USE STD.env.stop;
USE WORK.four_bit_binary_enum_pkg.ALL;

ENTITY binary_to_7seg_v2_tb IS

END binary_to_7seg_v2_tb;


ARCHITECTURE behavior OF binary_to_7seg_v2_tb IS

	COMPONENT binary_to_7seg_v2
	
		PORT (
	
			clk			: IN	STD_LOGIC;
			binary_code : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			sgmt_select : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			seven_sgmt  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
				);

	END COMPONENT;
	
	SIGNAL sgmt_select_out	:	STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
	SIGNAL seven_sgmt_out 	:	STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
	SIGNAL binary_in			:	STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '1');
	SIGNAL clk_in				:	STD_LOGIC := '0';
	
	TYPE Steps IS (INIT, CNT_UP, INC_BIN_CODE, DONE);
	SIGNAL Step_Chain : Steps := INIT;
				
	BEGIN
		
		TB: binary_to_7seg_v2 PORT MAP (
				clk => clk_in,
				binary_code => binary_in,
				sgmt_select => sgmt_select_out,
				seven_sgmt=> seven_sgmt_out);

				
		
		-- Generate clock signal
		clk_in <= NOT clk_in AFTER 10 ns;
			
		P1 : PROCESS(clk_in)
		
			VARIABLE clk_cnt				:	UNSIGNED(16 DOWNTO 0) := (others => '0'); --Counts clk signals to know when sgmt_select toggles between digits
			VARIABLE l       				:	LINE; --For printing
			VARIABLE first_time			:	BOOLEAN := TRUE;
			VARIABLE binary_in_int		:	INTEGER := 0;
			VARIABLE mltplx_done			:	BOOLEAN := TRUE;
			
			BEGIN
			
			
			IF rising_edge(clk_in) THEN
			
				CASE Step_Chain IS
				
					------------------------------------------------------
					WHEN INIT =>
						
						-- First time in this step
						IF first_time THEN
							write(l, STRING'(" -------- Start of test sequence -------- "));
							writeline(OUTPUT, l);
							write(l, STRING'(" Bit strings are negated as the dev. boards IO's are NC"));
							writeline(OUTPUT, l);
							first_Time := FALSE;
						END IF;
					
						-- Init vars
						clk_cnt := TO_UNSIGNED(0,17);
						binary_in_int := 0;
						
						
						-- Next step
						Step_Chain <= CNT_UP;
						first_Time := TRUE;
						
					------------------------------------------------------
					WHEN CNT_UP =>
					
						-- First time in this step
						IF first_time THEN
							write(l, STRING'("Counting clk signals for input: " & TO_STRING(binary_in_int)));
							writeline(OUTPUT, l);
							first_Time := FALSE;
							mltplx_done := FALSE;
						END IF;
						
						-- Count clock signals
							clk_cnt := clk_cnt + 1;
						
						IF (clk_cnt = 65536) THEN -- One count before multiplexing
							-- Current binary input
							write(l, STRING'("Binary input as int is: " & TO_STRING(binary_in_int) & " -- " & " as binary (neg): " & TO_STRING(NOT binary_in)));
							writeline(OUTPUT, l);
							-- Current segment select
							write(l, STRING'("clk_cnt is: " & TO_STRING(clk_cnt) & " Next clk signal toggels smgt_select. Seven segment select bitstring is (neg): " & TO_STRING( NOT sgmt_select_out)));
							writeline(OUTPUT, l);
							-- Current bit-string for the digit
							write(l, STRING'("Bit-string for digit one is (neg): " & TO_STRING(NOT seven_sgmt_out)));
							writeline(OUTPUT, l);
							
						ELSIF (clk_cnt = 0) AND NOT first_time THEN -- Multiplexing is done
							-- Current segment select
							write(l, STRING'("clk_cnt is: " & TO_STRING(clk_cnt) & " Counter overflow -> smgt_select was toggled. Seven segment select bitstring is (neg): " & TO_STRING(NOT sgmt_select_out)));
							writeline(OUTPUT, l);
							-- Current bit-string for the digit
							write(l, STRING'("Bit-string for digit zero is (neg): " & TO_STRING(NOT seven_sgmt_out)));
							writeline(OUTPUT, l);
							
							mltplx_done := TRUE;
						END IF;
						
						IF (clk_cnt = 65000) AND mltplx_done THEN
							-- Next step
							Step_Chain <= INC_BIN_CODE;
							first_Time := TRUE;
						END IF;
						
					------------------------------------------------------
					WHEN INC_BIN_CODE =>
					
						-- First time in this step
						IF first_time THEN
							write(l, STRING'(" ---- Increasing binary input to display next number ---- "));
							writeline(OUTPUT, l);
							first_Time := FALSE;
						END IF;
						
						binary_in_int := binary_in_int + 1;
						
						-- Next step
						IF (binary_in_int = 16) THEN
							Step_Chain <= DONE;
							first_Time := TRUE;
						ELSE
							binary_in <= NOT STD_LOGIC_VECTOR(TO_UNSIGNED(binary_in_int,4));
							Step_Chain <= CNT_UP;
							first_Time := TRUE;
						END IF;
					
					------------------------------------------------------
					WHEN DONE =>
					
						-- First time in this step
						IF first_time THEN
							write(l, STRING'("Testing done - stop simulation"));
							writeline(OUTPUT, l);
							first_Time := FALSE;
						END IF;
						
						stop; -- This stops the simulation
						
				END CASE;
				
			END IF;
			
		END PROCESS P1;


END behavior;


