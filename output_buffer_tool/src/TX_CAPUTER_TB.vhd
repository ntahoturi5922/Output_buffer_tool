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
	signal dina : std_logic_vector (31 downto 0):= x"00000000";
    signal STOP_CAP   : std_logic := '0';
    signal read_clk: std_logic :='0';
    --signal write_clk: std_logic :='0';
    signal empty: std_logic :='0';
    signal full: std_logic :='0';
    signal start_read:std_logic :='0';
    signal fifo_data_out:std_logic_vector (31 downto 0):=x"00000000";
	--signal address: std_logic_vector (5 downto 0);
    -- Signal to observe the output
    
	signal data_in       : std_logic_vector(63 downto 0):=x"0000000000000000";  
	signal addra : std_logic_vector (14 downto 0):= "000000000000000";
	signal ena: std_logic:='0';
	signal web: std_logic:='0';
	signal wea: std_logic:='0';
	signal address1:  std_logic_vector (14 downto 0):="000000000000000";   
	signal address2:  std_logic_vector (14 downto 0):="000000000000000";
	signal addrb: std_logic_vector (14 downto 0):= "000000000000000";
	signal dinb: std_logic_vector (31 downto 0):=x"00000000";
    signal data1:   std_logic_vector(31 downto 0):=x"00000000"; 
	signal data2:	 std_logic_vector(31 downto 0):=x"00000000";
    -- Constants
    constant CLK_PERIOD : time := 6.4 ns; -- 156.5 MHz
    constant RCLK_PERIOD : time := 10 ns; -- 100 MHz
    constant WCLK_PERIOD : time := 10 ns; -- 100 MHz
	type state_machine is (write_reg1, write_reg2);
	signal state: state_machine	;
	signal write_cnt: integer range 0 to 31 :=0;
	signal done_write: std_logic:='0'  ;  
	
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
    clka      => read_clk,
    addra    => addra,-- 1k x 32 R/W axi
    dina    =>dina,
    ena    =>  ena,	
	data_in  =>	data_in,
	trig       => trig,
    wea    => wea ,
    douta    => fifo_data_out,
	reset    =>	 reset,
    clkb    => clock,
    addrb    => addrb, -- 2k x 16 writeonly spybuff
    dinb    =>	dinb,
    web    =>  web
	--address1    =>  address1 ,
	--address2    => address2,
	
   -- data1    => data1,-- captured data from the tx line
	--data2    =>	 data2
  --
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
	
	
	
	
	
   process (clock,reset)
begin
        if reset = '1' then		   --- here we are in reset
			done_write <= '0';
			write_cnt <= 0;
        elsif rising_edge (clock) then	 --- getting out of reset	
				done_write <= '1';
                state <= write_reg1; 
				write_cnt <= 0;	
					case state is
						when write_reg1  =>
							dinb <= data1;	
							addrb <= address1;
							write_cnt <= write_cnt +1 ; 
							if write_cnt = write_cnt then  
								state <=  write_reg2;
							else
								state <=  write_reg1;
							end if;
							
						when write_reg2  =>
							dinb <= data2;	
							addrb <= address2;
							write_cnt <= write_cnt +1 ; 
							if write_cnt = write_cnt then  
								state <=  write_reg1;
							else
								state <=  write_reg2;
							end if;							
					end case;
         end if;	
					
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
		ena <='0'; 
		wea <='1';
		--address<= "000000"	;
		wait for 10 ns 	;
		
		
		data_in <= X"beefbaba00000000";	
		ena <='0'; 
		wea <='1';
		--address<= "000001";
		wait for 10 ns	;
		
		data_in <= X"00000000cafebabe";	
		ena <='0'; 
		wea <='1';		
		--address<= "000010";
		wait for 10 ns	;
		
		data_in <= X"babecafe00000000";	
		ena <='0'; 
		wea <='1';	
		web <= '1';
		
		--address<= "000011";
		wait for 10 ns	;
		
		data_in <= X"00000000deadbeef";	 
		ena <='0'; 
		wea <='1';	  
		
		wait for 10 ns	;
								
		data_in <= X"beefdead00000000";	 
		ena <='0'; 
		wea <='1';	
		
		--address<= "000110";
		wait for 10 ns	  ;
		
		data_in <= X"00000000dadabeef";	
		ena <='1'; 
		wea <='0'; 
		
		--address<= "000101";
		wait for 30 ns	; 
		ena <='1'; 
		wea <='0';
 		addra <= "000000000000100" ;
		wait for 30 ns	;
		ena <='1'; 
		wea <='0';
		addra <= "000000000001000" ;
		wait for 30 ns	;  
		ena <='1'; 
		wea <='0';
		addra <= "000000000001100" ;
		wait for 30 ns	;

        -- Stop capture
        STOP_CAP <= '0';
        wait for 50 ns;
        trig <= '0'; 
		ena <='0'; 
		wea <='0';
        -- Stop simulation
        wait;
    end process;

end behavior;
