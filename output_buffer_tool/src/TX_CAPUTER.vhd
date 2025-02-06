

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;										   																				   

entity TX_CAPUTER is
port(
    clock: in std_logic; -- master clock
    reset: in std_logic; -- active high reset async
    trig:  in std_logic; -- trigger pulse sync to clock
    data:  in std_logic_vector(63 downto 0); -- afe data sync to clock

    clka:  in  std_logic;
    addra: in  std_logic_vector(9 downto 0); -- 1k x 32 R/W
	ena:   in  std_logic;
	wea:   in  std_logic;
	dina:  in  std_logic_vector(31 downto 0);
    douta: out std_logic_vector(31 downto 0)  
  );
end TX_CAPUTER;

architecture behavior of TX_CAPUTER is

    signal reset_reg: std_logic;
    signal addr_reg: std_logic_vector(9 downto 0):="0000000000";
    signal data_reg, data_delayed1,data_delayed2: std_logic_vector(31 downto 0);
    signal we_reg:   std_logic;

    type state_type is (rst, wait4trig, store, wait4done);
    signal state: state_type; 
	
    type data_write is (write1, write2);
    signal state_machine: data_write;  
	
	component capture_registers
	port (
			clka:  in  std_logic;
			addra: in  std_logic_vector( 9 downto 0); -- 1k x 32 R/W axi
	        dina:  in  std_logic_vector(31 downto 0);
	        ena:   in  std_logic;
	        wea:   in  std_logic;
	        douta: out std_logic_vector(31 downto 0);
	        clkb:  in  std_logic;
	        addrb: in  std_logic_vector(9 downto 0); -- 2k x 16 writeonly spybuff
	        dinb:  in  std_logic_vector(31 downto 0);
	        web:   in  std_logic
		);
	end component;

begin

 data_delayed1 <= data (31 downto 0);
 data_delayed2 <= data (63 downto 32);
    -- FSM to wait for trigger pulse and drive addr_reg (write pointer) and we_reg

    fsm_proc: process(clock)
    begin
        if rising_edge(clock) then

            reset_reg <= reset; -- assume reset is async to square it up here

            if (reset_reg='1') then
                we_reg   <= '0';
                state    <= rst;
            else
                

                case state is
                    when rst =>
                        state <= wait4trig;
                    when wait4trig =>
                        if (trig='1') then
                            state <= store;
                            we_reg <= '1';
                        else
                            state <= wait4trig;
                            we_reg <= '0';
                            addr_reg <= (others=>'0');
                        end if;
                    when store =>
                        if (addr_reg="1111111111") then
                            state <= wait4done;
                            we_reg <= '0';
                        else
                            state <= store;	
							 state_machine <= write1;
							case state_machine is
								when  write1=>
									data_reg <= data_delayed2;
                            		addr_reg <= std_logic_vector(unsigned(addr_reg) + 1);
                            		we_reg <= '1'; 
									state_machine <=   write2;
								when write2=> 	
									data_reg <= data_delayed1;
                            		addr_reg <= std_logic_vector(unsigned(addr_reg) + 1);
                            		we_reg <= '1'; 
									state <=   store;
								when others =>
								state_machine <= write1;	
							end case;
                        end if;
                    when wait4done =>
                        if (trig='0') then
                            state <= wait4trig;
                        else
                            state <= wait4done;
                        end if;
                    when others => 
                        state <= rst;    
    
                end case;
            end if;
        end if;
    end process fsm_proc;

	spyram_inst: capture_registers
	port map(
		clka => clka, -- Port A R/W access from AXI master, 2k x 32
		addra => addra,
		dina => dina,
		ena => ena,
		wea => wea,
		douta => douta,

		clkb => clock, -- Port B written to by THIS logic
		addrb => addr_reg, -- 10 bit write address
		dinb => data_reg,
		web => we_reg
	);

end behavior;
