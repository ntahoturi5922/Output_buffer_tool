library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library unisim;
--use unisim.vcomponents.all;

entity TX_CAPUTER is
port(
    clock: in std_logic; -- master clock --156.5MHZ
    reset: in std_logic; -- active high reset asyn -- only when reset this module works
    trig:  in std_logic; -- trigger pulse sync to clock  -- from the trigger module	 
	Data_in: in std_logic_vector (63 downto 0); -- this is the data that we capture and divide it into 2 32 bit data to write to memory 
	address1: out std_logic_vector (14 downto 0);   
	address2: out std_logic_vector (14 downto 0);
	
    data1:  out std_logic_vector(31 downto 0); -- captured data from the tx line
	data2:	out std_logic_vector(31 downto 0)
  
  );
end TX_CAPUTER;

architecture behavior of TX_CAPUTER is	 

type state_machines is ( capture_reg1, capture_reg2);
signal data_reg1: std_logic_vector (31 downto 0):= x"00000000"; --- signal to buffer data 1	 
signal data_reg2: std_logic_vector (31 downto 0):= x"00000000";--- signal to buffer data 2	
 
signal addr_reg1: std_logic_vector (14 downto 0);
signal addr_reg2: std_logic_vector (14 downto 0);
signal STOP_CAP:  std_logic;   -- stop capture when fifo is full and disable clock
signal addr_cnt  : integer range 0 to 4096 := 0;
signal capturing: std_logic := '0';	   
signal state: state_machines; 
begin

    process(clock, reset)
    begin
        if reset = '1' then		   --- here we are in reset
            data_reg1 <= (others => '0'); 
			data_reg2 <= (others => '0');
			addr_reg1 <= (others => '0');
			addr_reg2 <= (others => '0');
            addr_cnt  <= 0;
            capturing <= '0';
			STOP_CAP <= '1';
        elsif rising_edge(clock) then	 --- getting out of reset	
			STOP_CAP<= '0';
            if STOP_CAP = '0' then	  -- wait for the stop capturing signal to go low
                if trig = '1' then		--- wait for the trigger from the triger module
                    capturing <= '1';  -- Start capturing
                end if;
                state <= capture_reg1; 
                if capturing = '1' then	
					case state is
						when capture_reg1  =>
							data_reg1 <= Data_in (63 downto 32);	
							addr_reg1 <=  std_logic_vector(to_unsigned(addr_cnt,15));
							addr_cnt <= addr_cnt + 4 ; 
							if addr_cnt < 2048 then  
								state <=  capture_reg2;
							else
								STOP_CAP <= '1';
								capturing <= '0';
							end if;
							
						when capture_reg2	=>	
							data_reg2 <= Data_in (31 downto 0);
							addr_reg2 <=  std_logic_vector(to_unsigned(addr_cnt,15));
							addr_cnt <= addr_cnt + 4 ;	
							
							if addr_cnt < 2048 then  
								state <=  capture_reg1;
							else
								STOP_CAP <= '1';
								capturing <= '0';
							end if;							
					end case;
                end if;	
					
            end if;
        end if;
    end process;

	address1 <= addr_reg1;   
	address2 <= addr_reg2;
	
    data1 <= data_reg1; -- captured data from the tx line
	data2 <= data_reg2;    

end behavior;