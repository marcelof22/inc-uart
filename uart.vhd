-- uart.vhd: UART controller - receiving part
-- Author(s): Marcel Feiler
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is --nemenit!!!
port(	
    CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
	DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is

signal outer: std_logic;
signal pocet: integer := 0;
signal index: integer := 0;
signal correct: std_logic;
signal citac: std_logic;

begin

	FSM: entity work.UART_FSM(behavioral)
	port map (
		CLK 	    => CLK,
		RST 	    => RST,
		OUTER 	    => outer,
		DIN	    	=> DIN,
		POCET		=> pocet,
		CORRECT		=> correct,
		CITAC 	 	=> citac
	);


	process(CLK) begin
		if rising_edge(CLK) then

			if outer = '1' or citac = '1' then
				pocet <= pocet + 1;
			end if;


			if correct = '1' then
				DOUT_VLD <= '0';
				correct <= '0';
			end if;


			if pocet >= 23 then
		 		DOUT(index) <= DIN;
				index <= index + 1;
				pocet <= 0;
			end if;


			if (RST = '0' and citac = '1' and pocet >= 15) then
				pocet <= 0;
				DOUT(index) <= DIN;
				index <= index + 1;
			end if;


			if (RST = '0' and citac = '1' and index >= 8) then
				correct <= '1';
				index <= 0;
				DOUT_VLD <= '1';
			end if;

			--ked budem mat v DOUT vsetkych 8 bitov tak DOUT_VLD = 1 ale hned potom ho dam na 0 (len 1 clock bude 1, potom 0)
			--ak pocet >= 23 tak vynulovat pocet - preco? lebo zmena stavu z firstbit na otherbit
			-- v stave other bit mi staci nulovat counter po 16
		end if;

	end process;

end behavioral;
