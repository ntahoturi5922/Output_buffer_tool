library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;	



entity TB_TX_CAPUTER is
-- No ports for a testbench
end TB_TX_CAPUTER;



architecture behavior of TB_TX_CAPUTER is

    -- Signals to drive the inputs
    signal clock      : std_logic := '0';
    signal reset      : std_logic := '0';
    signal trig       : std_logic := '0';

    signal STOP_CAP   : std_logic := '0';
    signal read_clk: std_logic :='0';
    --signal write_clk: std_logic :='0';
    signal empty: std_logic :='0';
    signal full: std_logic :='0';
    signal start_read:std_logic :='0';
    signal fifo_data_out:std_logic_vector (31 downto 0):=x"00000000";
	--signal address: std_logic_vector (5 downto 0);
    -- Signal to observe the output
    signal data       : std_logic_vector(31 downto 0):=x"00000000";
	signal data_in       : std_logic_vector(63 downto 0):=x"0000000000000000";  
	
	
	signal address1:  std_logic_vector (5 downto 0):="000000";   
	signal address2:  std_logic_vector (5 downto 0):="000000";
	
    signal data1:   std_logic_vector(31 downto 0):=x"00000000"; 
	signal data2:	 std_logic_vector(31 downto 0):=x"00000000";
    -- Constants
    constant CLK_PERIOD : time := 10 ns; -- 156.5 MHz
    constant RCLK_PERIOD : time := 10 ns; -- 100 MHz
    constant WCLK_PERIOD : time := 10 ns; -- 100 MHz

begin

    -- Instantiate the Unit Under Test (UUT)
    uut1: entity work.TX_CAPUTER
        port map (
            clock      => clock,
            reset      => reset,
            trig       => trig,
			
    		Data_in  =>	data_in,
            --STOP_CAP   => STOP_CAP,
            address1    =>   address1 ,
			address2    => 	address2,
	
    		data1    =>   data1,
			data2    => data2
        );
        
    uut2: entity work.capture_registers
port map(
	--clock_write => write_clk, -- master clock --200MHZ	
	clock_read=> read_clk, -- master clock --100MHZ
    reset => reset,-- active high reset asyn -- only when reset this module works
    trig => trig,-- trigger pulse sync to clock  -- from the trigger module	 
	STOP_CAP => STOP_CAP,   -- stop capture when fifo is full and disable clock 
	Start_read  => start_read,-- this signal goes high when registers are full
    data => data-- captured data from the tx line
	--data_out => fifo_data_out--- data to read	  
	--EMPTY => empty -- this sighnal goes high when fifo has been finished to be read and is ok to 
	-- to triger again. 
	--FULL =>full
  
  );

    -- Clock generation process
    clk_process: process
    begin
        while true loop
            clock <= '0';
            wait for CLK_PERIOD / 2;
            clock <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;


    Rclk_process: process
    begin
        while true loop
            read_clk <= '0';
            wait for RCLK_PERIOD / 2;
            read_clk <= '1';
            wait for RCLK_PERIOD / 2;
        end loop;
    end process;
    
       

    -- Stimulus process
    stimulus_process: process
    begin
        -- Reset the UUT
        reset <= '1';
        wait for 10 ns;
        reset <= '0';

        -- Wait for some clock cycles
        wait for 20 ns;

        -- Apply trigger
        trig <= '1';
        wait for 10 ns;
        trig <= '0';
		STOP_CAP <= '0';
        -- Simulate TX_CAP_P and TX_CAP_N toggling
		data_in <= X"00000000bababeef";
		--address<= "000000"	;
		wait for 10 ns 	;
		
		
		data_in <= X"beefbaba00000000";
		--address<= "000001";
		wait for 10 ns	;
		
		data_in <= X"00000000cafebabe";
		--address<= "000010";
		wait for 10 ns	;
		
		data_in <= X"babecafe00000000";
		--address<= "000011";
		wait for 10 ns	;
		
		data_in <= X"00000000deadbeef";
		--address<= "000100";
		wait for 10 ns	;
								
		data_in <= X"beefdead00000000";
		--address<= "000110";
		wait for 10 ns	  ;
		
		data_in <= X"00000000dadabeef";
		--address<= "000101";
		wait for 10 ns	;

        -- Stop capture
        STOP_CAP <= '0';
        wait for 10 ns;
        trig <= '0';
        -- Stop simulation
        wait;
    end process;

end behavior;
