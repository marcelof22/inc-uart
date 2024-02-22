-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): Marcel Feiler
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK : in std_logic;
   RST : in std_logic;
   OUTER : out std_logic := '0';
   DIN : in std_logic;
   POCET : in integer;
   CORRECT : in std_logic := '0';
   CITAC : out std_logic := '0'
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is

type stavy is (hladam_startbit, first_bit, other_bit, stop_bit);
signal stav: stavy:=hladam_startbit;

begin
	OUTER <= '1' when (stav = other_bit or stav = first_bit) else '0';
	CITAC <= '1' when (stav = other_bit) else '0';

	process(CLK) begin
		--zistim kedy sa zmeni stav, pockam kym sa RST zmeni na 0
		if RST = '1' then stav<=hladam_startbit;

		else
			case stav is

				when hladam_startbit => if DIN = '0' then stav <= first_bit; end if;


				when first_bit => if POCET >= 23 then stav <= other_bit; end if;


				when other_bit => if CORRECT = '1' then stav <= stop_bit; end if;


				when stop_bit => if DIN = '1' then stav <= hladam_startbit; end if;


				when others => NULL; end case;


		end if;

	end process;

end behavioral;
