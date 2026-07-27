LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY binary_to_7seg_v1_tb IS
END binary_to_7seg_v1_tb;

ARCHITECTURE testbench OF binary_to_7seg_v1_tb IS

	-- Declare component
    COMPONENT binary_to_7seg_v1
        PORT(
            dp_switch   : IN  STD_LOGIC_VECTOR(3 downto 0);
            sgmt_select : OUT STD_LOGIC_VECTOR(3 downto 0);
            seven_sgmt  : OUT STD_LOGIC_VECTOR(7 downto 0)
        );
    END COMPONENT;
	 
	 -- Signals to handle component I/O & print
	 SIGNAL dp_switch_in : STD_LOGIC_VECTOR(3 downto 0);
    SIGNAL sgmt_select_out : STD_LOGIC_VECTOR(3 downto 0);
    SIGNAL seven_sgmt_out : STD_LOGIC_VECTOR(7 downto 0);

BEGIN

	T1: binary_to_7seg_v1 PORT MAP(
			dp_switch => dp_switch_in,
			sgmt_select => sgmt_select_out,
			seven_sgmt => seven_sgmt_out);

   tb_1 : PROCESS 
	BEGIN	
    
        FOR i IN 0 TO 9 LOOP
		  
				-- Input change of component. Buttons and dips are low active -> Inverse
				dp_switch_in <= NOT STD_LOGIC_VECTOR(TO_UNSIGNED(i,4));
		  
				WAIT FOR 10 NS;
		  
				-- Print input and output
            REPORT	"i: " & TO_STRING(i) &
							"  // Binary IN: " & TO_STRING(NOT dp_switch_in) &
							--"  // Select OUT: " & TO_STRING(NOT sgmt_select_out) &
							"  // Segment OUT: " & TO_STRING(NOT seven_sgmt_out);
							
				WAIT FOR 10 NS;
        
        END LOOP;
		  
        WAIT; --Terminate
        
    END PROCESS tb_1;

END testbench;