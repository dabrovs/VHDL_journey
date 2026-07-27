LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

/* This module takes an binary input and displays it as decimal on a seven segment display
	First test. Therefore simply digits 0-9. 
	Buttons/Dip switches and segments are low active. That is why we inverse for readibility
*/

ENTITY binary_to_7seg_v1 is
	PORT (
				dp_switch : IN STD_LOGIC_VECTOR(3 downto 0);
				
				sgmt_select : OUT STD_LOGIC_VECTOR(3 downto 0);
				seven_sgmt : OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END binary_to_7seg_v1;


ARCHITECTURE Behavioral of binary_to_7seg_v1 is
	SIGNAL neg_dp_switch : STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL seven_sgmt_logic: STD_LOGIC_VECTOR(7 downto 0);

BEGIN
	
	neg_dp_switch <= NOT dp_switch; --If we push a button we want to display it -> Inverse to high active
	sgmt_select <= NOT "0001";	--First display from RIGHT
	

	PROCESS(neg_dp_switch)
	
		BEGIN
			-- One
			IF neg_dp_switch = "0001" THEN
				seven_sgmt_logic <= "00000110";
			
			-- Two
			ELSIF neg_dp_switch = "0010" THEN
				seven_sgmt_logic <= "01011011";
			
			-- Three
			ELSIF neg_dp_switch = "0011" THEN
				seven_sgmt_logic <= "01001111";
				
			-- Four
			ELSIF neg_dp_switch = "0100" THEN
				seven_sgmt_logic <= "01100110";
			
			-- Five
			ELSIF neg_dp_switch = "0101" THEN
				seven_sgmt_logic <= "01101101";
			
			-- Six
			ELSIF neg_dp_switch = "0110" THEN
				seven_sgmt_logic <= "01111101";
			
			-- Seven
			ELSIF neg_dp_switch = "0111" THEN
				seven_sgmt_logic <= "00000111";
			
			-- Eight
			ELSIF neg_dp_switch = "1000" THEN
				seven_sgmt_logic <= "01111111";
			
			-- Nine
			ELSIF neg_dp_switch = "1001" THEN
				seven_sgmt_logic <= "01101111";
			
			-- Zero
			ELSE
				seven_sgmt_logic <= "00111111";
			END IF;		
	END PROCESS;
	
	seven_sgmt <= NOT seven_sgmt_logic;

END Behavioral;

