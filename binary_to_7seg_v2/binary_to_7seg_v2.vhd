LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.four_bit_binary_enum_pkg.ALL;



ENTITY binary_to_7seg_v2 IS
	PORT (
		clk			: IN	STD_LOGIC;
		binary_code : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		sgmt_select : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		seven_sgmt  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END binary_to_7seg_v2;



ARCHITECTURE Behavioral of binary_to_7seg_v2 is

	SIGNAL numbers	: decimals;

	COMPONENT binary_to_enum
		PORT (	binary_code : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
					digits      : OUT decimals
				);
	END COMPONENT;
	
BEGIN 

	-- Get numbers from binary code
	Conv : binary_to_enum PORT MAP (binary_code, numbers);

	PROCESS(clk)
		
		-- CLK is 50Mhz. Bit 17 = 2^(17-1) = 65536 rising edges
		-- (1s / 50x10^6) * 65536 = 0.0013s
		-- Meaning it takes 1.3ms to toggle
		VARIABLE counter	: UNSIGNED(16 DOWNTO 0) := (others => '0');
	
		BEGIN
		
		--Counter to toggle between 1st and 2nd sgmt_select
		IF rising_edge(clk) THEN
			
			counter := counter + 1;
			
			IF counter(16) = '0' THEN
				-- display digit 0
				sgmt_select <= NOT "0001";
				seven_sgmt <= NOT ENUM_BIT_VALUE(numbers(0));
			ELSE
				-- display digit 1
				sgmt_select <= NOT "0010";
				seven_sgmt <= NOT ENUM_BIT_VALUE(numbers(1));
			END IF;
		
		END IF;
				
			
	END PROCESS;
		
	-- map bit value of number to pins
	

END Behavioral;