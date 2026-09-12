-- ========================================================
-- ENTITY 1: IR remote to hex on 7seg 
-- ========================================================
-- Evaluates IR signal from IR remote (Standard NEC protocol) and outputs received data
-- on 2-digit 7seg display
-- By changing the dip switch configuration either cmd, cmd_inv, address or address_inv can be displayed

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY remote_to_hex IS

	PORT(
	
		clk_in			:	IN		STD_LOGIC := '0'; -- Clock signal 50MHz
		IR_signal_in	:	IN		STD_LOGIC := '0'; -- IR signal from receiver
		dip_sw_in		:	IN		STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); -- 4bit string from dip switches
		sgmt_out			:	OUT	STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); -- 8bit string for segments of display
		sgmt_select		:	OUT	STD_LOGIC_VECTOR(3 downto 0) := (others => '0')  -- 4bit string to toggle between displays

	);

END remote_to_hex;


ARCHITECTURE behavior OF remote_to_hex IS

	-- COMPONENT DECLARATION ----------------------------------------
	COMPONENT seven_sgmt_hex_multiplexer
	
		PORT (
		clk_in						: IN STD_LOGIC := '0';
		num_displays_in			: IN INTEGER RANGE 1 TO 4 := 1; 
		data_sgmt_0					: IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
		data_sgmt_1					: IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
		data_sgmt_2					: IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
		data_sgmt_3					: IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
		test_in						: IN STD_LOGIC := '0';
		sgmt_select_out			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
		sgmt_out						: OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0')
		);
		
	END COMPONENT;
	
	COMPONENT IR_to_binary
	
		PORT (
			clk_in			:	IN		STD_LOGIC := '0';
			IR_signal		:	IN		STD_LOGIC := '0';
			binary_out		:	OUT	STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0')
		);
		
	END COMPONENT;
	

	-- SIGNALS DECLARATION ------------------------------------------
	SIGNAL data						:	STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
	SIGNAL binary_in_8b			:	STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
	
		
	-- BEGIN ARCHITECTURE -------------------------------------------
	BEGIN
	
	-- COMPONENT CALL ------------------------------
	C1: IR_to_binary 
		PORT MAP (
				clk_in => clk_in,
				IR_signal => IR_signal_in,
				binary_out => data
		);
		
	C2: seven_sgmt_hex_multiplexer
		PORT MAP(
			clk_in  => clk_in,
			num_displays_in => 2,
			data_sgmt_0 => binary_in_8b(3 DOWNTO 0),
			data_sgmt_1 => binary_in_8b(7 DOWNTO 4),
			data_sgmt_2 => "0000",
			data_sgmt_3 => "0000",
			test_in => '0',
			sgmt_select_out => sgmt_select,
			sgmt_out => sgmt_out
	);

	-- LOGIC ----------------------------------------
	P1 : PROCESS(clk_in)
				
		BEGIN
		
			IF rising_edge(clk_in) THEN
					
				-- Select data to display via dip switches
				IF (NOT dip_sw_in) = "0000" THEN
					-- cmd negated
					binary_in_8b <= data(7 DOWNTO 0);
					
				ELSIF (NOT dip_sw_in) = "0001" THEN
					-- cmd 
					binary_in_8b <= data(15 DOWNTO 8);

				ELSIF (NOT dip_sw_in) = "0010" THEN
					-- address negated
					binary_in_8b <= data(23 DOWNTO 16);
					
				ELSIF (NOT dip_sw_in) = "0100" THEN
					-- address
					binary_in_8b <= data(31 DOWNTO 24);
					
				ELSE
					binary_in_8b <= "11111111";
				END IF;
				
			END IF;
				
	END PROCESS P1;
	
END behavior;