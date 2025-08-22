--Copyright 2025 Andrey S. Ionisyan (anserion@gmail.com)
--Licensed under the Apache License, Version 2.0 (the "License");
--you may not use this file except in compliance with the License.
--You may obtain a copy of the License at
--    http://www.apache.org/licenses/LICENSE-2.0
--Unless required by applicable law or agreed to in writing, software
--distributed under the License is distributed on an "AS IS" BASIS,
--WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--See the License for the specific language governing permissions and
--limitations under the License.
------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.ALL, IEEE.STD_LOGIC_ARITH.ALL, ieee.std_logic_unsigned.all;

entity receive_byte is
  Port (CLK,EN: in STD_LOGIC; TICKS_PER_BIT: in STD_LOGIC_VECTOR(7 downto 0);
        DOUT: out STD_LOGIC_VECTOR (7 downto 0); PARITY: out STD_LOGIC;
        RX:in STD_LOGIC; RDY: out STD_LOGIC);
end receive_byte;

architecture Behavioral of receive_byte is
signal ready_reg: std_logic:='1'; signal parity_reg: std_logic:='0';
signal dout_reg:std_logic_vector(7 downto 0):=(others=>'0');
signal TICKS4_reg: STD_LOGIC_VECTOR(7 downto 0);
begin
  TICKS4_reg<="00"&TICKS_PER_BIT(7 downto 2); --div 4 operation
  RDY<=ready_reg; PARITY<=parity_reg; DOUT<=dout_reg;
  process(CLK)
    variable fsm: natural range 0 to 15:=0;
    variable cnt: natural range 0 to 255:=0;
    variable bits_cnt: natural range 0 to 7:=0;
  begin
    if rising_edge(CLK) and EN='1' then
       case fsm is
       when 0 => fsm:=1; ready_reg<='1'; dout_reg<=(others=>'0'); -- init
       when 1 => if RX='0' then fsm:=2; cnt:=0; ready_reg<='0'; end if; --catch start bit
       when 2 => if cnt=conv_integer(TICKS_PER_BIT) then fsm:=3; cnt:=0; else cnt:=cnt+1; end if; --latency
       when 3 => if cnt=conv_integer(TICKS4_reg) then fsm:=4; bits_cnt:=0; else cnt:=cnt+1; end if;
       when 4 => fsm:=5; cnt:=0; dout_reg(bits_cnt)<=RX; --catch bit with 1/4 shift after start
       when 5 => if cnt=conv_integer(TICKS_PER_BIT) then fsm:=6; else cnt:=cnt+1; end if; --latency
       when 6 => if bits_cnt=7 then fsm:=7; else fsm:=4; bits_cnt:=bits_cnt+1; end if;
       when 7 => fsm:=8; cnt:=0; parity_reg<=RX; ready_reg<='1'; --catch parity bit
       when 8 => if cnt=conv_integer(TICKS_PER_BIT) then fsm:=9; else cnt:=cnt+1; end if; --latency
       when 9 => if RX='1' then fsm:=1; end if; --catch stop bit
       when others => null;
       end case;
    end if;
  end process;
end Behavioral;
