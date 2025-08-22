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

entity UART_RX_top is
  Port (SYS_CLK, UART_RX: in STD_LOGIC;
        SMG_DATA: out STD_LOGIC_VECTOR (7 downto 0);
        SCAN_SIG: out STD_LOGIC_VECTOR (5 downto 0);
        LED1,LED2: out STD_LOGIC);
end UART_RX_top;

architecture Behavioral of UART_RX_top is
component CLK_GEN
   Port (CLK_IN,EN,RESET: in STD_LOGIC;
         LOW_NUM, HIGH_NUM: natural;
         CLK_OUT : out  STD_LOGIC);
end component;
component SMG_x16_driver is
    Port (clk,en: in std_logic; NUM_16x: in STD_LOGIC_VECTOR(23 downto 0); 
          mask_dp: in STD_LOGIC_VECTOR(5 downto 0);
          SEG: out STD_LOGIC_VECTOR(7 downto 0); DIG: out STD_LOGIC_VECTOR(5 downto 0));
end component;
component receive_byte is
  Port (CLK,EN: in STD_LOGIC; TICKS_PER_BIT: in STD_LOGIC_VECTOR(7 downto 0);
        DOUT: out STD_LOGIC_VECTOR (7 downto 0); PARITY: out STD_LOGIC;
        RX:in STD_LOGIC; RDY: out STD_LOGIC);
end component;

signal receive_byte_ok: std_logic;
signal CLK, CLK_SMG: std_logic;
signal TICKS_PER_BIT: STD_LOGIC_VECTOR(7 downto 0);
signal uart_byte: std_logic_vector(7 downto 0):=x"EF";
signal parity_bit: std_logic;
begin
  CLK_GEN_1MHz_chip: CLK_GEN port map(SYS_CLK,'1','0',25,25,CLK);
  CLK_GEN_10kHz_chip: CLK_GEN port map(SYS_CLK,'1','0',2500,2500,CLK_SMG);
  RECEIVE_BYTE_chip: receive_byte port map(CLK,'1',conv_std_logic_vector(100,8),
                                           uart_byte,parity_bit,UART_RX,receive_byte_ok);
  SMG_x16_driver_chip: SMG_x16_driver port map(CLK_SMG, '1', x"0000"&uart_byte,
                                               "111111", SMG_DATA, SCAN_SIG);
  LED1<=receive_byte_ok; LED2<=parity_bit;
end Behavioral;
