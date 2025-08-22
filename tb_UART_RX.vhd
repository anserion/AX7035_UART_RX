LIBRARY ieee; 
use IEEE.STD_LOGIC_1164.ALL, IEEE.STD_LOGIC_ARITH.ALL, ieee.std_logic_unsigned.all;
ENTITY tb_UART_RX IS
END tb_UART_RX;
ARCHITECTURE behavior OF tb_UART_RX IS 
    COMPONENT UART_RX_top
    Port (SYS_CLK, UART_RX: in STD_LOGIC;
          SMG_DATA: out STD_LOGIC_VECTOR (7 downto 0);
          SCAN_SIG: out STD_LOGIC_VECTOR (5 downto 0);
          LED1,LED2: out STD_LOGIC);
    END COMPONENT;
   --Inputs
   signal SYS_CLK: std_logic := '0';
   signal UART_RX: std_logic := '1';
 	--Outputs
   signal LED1,LED2: std_logic;
   signal SMG_DATA: STD_LOGIC_VECTOR (7 downto 0);
   signal SCAN_SIG: STD_LOGIC_VECTOR (5 downto 0);
   -- Clock period definitions
   constant SYS_CLK_period : time := 20 ns;
   -- others
   signal clk_cnt: natural:=0;
BEGIN
   uut: UART_RX_top PORT MAP (SYS_CLK,UART_RX,SMG_DATA,SCAN_SIG,LED1,LED2);
   -- Clock process definitions
   SYS_CLK_process :process
   begin
		SYS_CLK <= '0'; wait for SYS_CLK_period/2;
		SYS_CLK <= '1'; wait for SYS_CLK_period/2;
      clk_cnt<=clk_cnt+1;
   end process;
   -- Stimulus process
   stim_proc: process
   begin		
      wait for SYS_CLK_period;
      if clk_cnt=100000 then UART_RX<='1'; end if;
      if clk_cnt=200000 then UART_RX<='0'; end if; --start bit
      if clk_cnt=300000 then UART_RX<='1'; end if; --0
      if clk_cnt=400000 then UART_RX<='0'; end if; --1
      if clk_cnt=500000 then UART_RX<='1'; end if; --2
      if clk_cnt=600000 then UART_RX<='1'; end if; --3
      if clk_cnt=700000 then UART_RX<='0'; end if; --4
      if clk_cnt=800000 then UART_RX<='1'; end if; --5
      if clk_cnt=900000 then UART_RX<='1'; end if; --6
      if clk_cnt=1000000 then UART_RX<='0'; end if; --7
      if clk_cnt=1100000 then UART_RX<='1'; end if; --parity even
      if clk_cnt=1200000 then UART_RX<='1'; end if; --stop bit
      if clk_cnt=1300000 then wait; end if;
   end process;
END;