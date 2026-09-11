LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;
USE STD.env.stop;

ENTITY seven_sgmt_hex_multiplexer_tb IS
	
END ENTITY;


ARCHITECTURE behavior OF seven_sgmt_hex_multiplexer_tb IS

	COMPONENT seven_sgmt_hex_multiplexer
	
		PORT (
			clk_in						: IN STD_LOGIC := '0';
			num_segments_in			: IN INTEGER RANGE 1 TO 4 := 1;
			data_sgmt_0					: IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
			data_sgmt_1					: IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
			data_sgmt_2					: IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
			data_sgmt_3					: IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
			
			test_in						: IN STD_LOGIC := '0';
			
			sgmt_select_out			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
			sgmt_out						: OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0')
		);
		
	END COMPONENT;

	SIGNAL clk					: STD_LOGIC := '0';
	SIGNAL num_segments		: INTEGER RANGE 1 TO 4 := 4;
	SIGNAL test					: STD_LOGIC := '0';
	SIGNAL data_0				: STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010"; --A
	SIGNAL data_1				: STD_LOGIC_VECTOR(3 DOWNTO 0) := "1011"; --B
	SIGNAL data_2				: STD_LOGIC_VECTOR(3 DOWNTO 0) := "1100"; --C
	SIGNAL data_3				: STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101"; --D
	SIGNAL sgmt_select		: STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
	SIGNAL sgmt					: STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');

	BEGIN

	 C1: seven_sgmt_hex_multiplexer PORT MAP (
	
		clk_in => clk,
		num_segments_in => num_segments,
		data_sgmt_0 => data_0,
		data_sgmt_1 => data_1,
		data_sgmt_2 => data_2,
		data_sgmt_3 => data_3,
		test_in => test,
		sgmt_select_out => sgmt_select,
		sgmt_out =>	sgmt);

	clk <= NOT clk AFTER 10 ns;

	P1 : PROCESS(clk)
	
		VARIABLE clk_counter : UNSIGNED(16 DOWNTO 0) :=  (others => '0');
		VARIABLE next_step_counter : INTEGER RANGE 0 TO 8 := 0;
		VARIABLE l			: LINE;
		VARIABLE first_time : BOOLEAN := TRUE;
	
		BEGIN
		
			IF rising_edge(clk) THEN
				clk_counter := clk_counter + 1;
			END IF;
				
			IF rising_edge(clk) and clk_counter = 130000 THEN
				
				IF first_time THEN
					-- Step chain is still in INIT step
					WRITE(l, STRING'("---- Init of simulation ----"));
					WRITELINE(OUTPUT, l);
					WRITE(l, STRING'("Number of segments: " & TO_STRING(num_segments)));
					WRITELINE(OUTPUT, l);
					WRITE(l, STRING'("Test bit: " & TO_STRING(test)));
					WRITELINE(OUTPUT, l);
					WRITE(l, STRING'("Data_0 in is :" & TO_STRING(data_0)));
					WRITELINE(OUTPUT, l);
					WRITE(l, STRING'("Data_1 in is :" & TO_STRING(data_1)));
					WRITELINE(OUTPUT, l);
					WRITE(l, STRING'("Data_2 in is :" & TO_STRING(data_2)));
					WRITELINE(OUTPUT, l);
					WRITE(l, STRING'("Data_3 in is :" & TO_STRING(data_3)));
					WRITELINE(OUTPUT, l);
					WRITE(l, STRING'("---- Start of simulation ----"));
					WRITELINE(OUTPUT, l);
					first_time := FALSE;
				ELSE
				
					next_step_counter := next_step_counter + 1;
				
					WRITE(l, STRING'("clk counter at :" & TO_STRING(clk_counter)));
					WRITELINE(OUTPUT, l);
					
					WRITE(l, STRING'("next step counter :" & TO_STRING(next_step_counter)));
					WRITELINE(OUTPUT, l);
					
					WRITE(l, STRING'("Segment select is :" & TO_STRING(sgmt_select)));
					WRITELINE(OUTPUT, l);
					
					WRITE(l, STRING'("Segment out is :" & TO_STRING(NOT sgmt)));
					WRITELINE(OUTPUT, l);
				END IF;
				
				
				
				IF next_step_counter = 8 THEN
					stop;
				END IF;	
			END IF;
	
	
	END PROCESS P1;



END behavior;