LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE four_bit_binary_enum_pkg IS

    TYPE decimal_enum  IS (ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, 
                       EIGHT, NINE);
    
    TYPE decimals IS ARRAY (1 DOWNTO 0) OF decimal_enum;	 
	 
	 -- To directly assign bit logic for respective number using enumeration
	 TYPE decimal_enum_table_t IS ARRAY (decimal_enum) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	 
	 CONSTANT ENUM_BIT_VALUE : decimal_enum_table_t := (	ZERO		=> "00111111",
																			ONE		=> "00000110", 
																			TWO		=> "01011011",
																			THREE		=> "01001111",
																			FOUR		=> "01100110",
																			FIVE		=> "01101101",
																			SIX		=> "01111101",
																			SEVEN		=> "00000111",
																			EIGHT		=> "01111111",
																			NINE		=> "01101111");
		
END PACKAGE four_bit_binary_enum_pkg;