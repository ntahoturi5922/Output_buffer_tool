library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity TX_CAPUTER is
port(
    clock: in std_logic;-- master clock possibly 156.25mhz
    reset: in std_logic;
    trig:  in std_logic;
    data:  in std_logic_vector(63 downto 0);

    clka:  in  std_logic;  -- axi read clock 100mhz
    addra: in  std_logic_vector(9 downto 0);
    ena:   in  std_logic;
    wea:   in  std_logic;
    dina:  in  std_logic_vector(31 downto 0);
    douta: out std_logic_vector(31 downto 0)  
  );
end TX_CAPUTER;

architecture behavior of TX_CAPUTER is

    signal reset_reg: std_logic;
    signal addr_reg: std_logic_vector(9 downto 0) := (others => '0');
    signal data_reg, data_delayed1, data_delayed2: std_logic_vector(31 downto 0);
    signal we_reg: std_logic;

    type state_type is (rst, wait4trig, store, wait4done);
    signal state: state_type;
    
    type data_write is (write1, write2);
    signal state_machine: data_write;
    
    component capture_registers
    port (
        clka:  in  std_logic;
        addra: in  std_logic_vector(9 downto 0);
        dina:  in  std_logic_vector(31 downto 0);
        ena:   in  std_logic;
        wea:   in  std_logic;
        douta: out std_logic_vector(31 downto 0);
        clkb:  in  std_logic;
        addrb: in  std_logic_vector(9 downto 0);
        dinb:  in  std_logic_vector(31 downto 0);
        web:   in  std_logic
    );
    end component;

begin

    data_delayed1 <= data(31 downto 0);
    data_delayed2 <= data(63 downto 32);

    fsm_proc: process(clock)
    begin
        if rising_edge(clock) then
            reset_reg <= reset;

            if (reset_reg = '1') then
                we_reg <= '0';
                state <= rst;
                addr_reg <= (others => '0');
            else
                case state is
                    when rst =>
                        state <= wait4trig;
                    when wait4trig =>
                        if (trig = '1') then
                            state <= store;
                            we_reg <= '1';
                            state_machine <= write1;
                        else
                            state <= wait4trig;
                            we_reg <= '0';
                            addr_reg <= (others => '0');
                        end if;
                    when store =>
                        case state_machine is
                            when write1 =>
                                data_reg <= data_delayed1;
                                state_machine <= write2;
                            when write2 =>
                                addr_reg <= std_logic_vector(unsigned(addr_reg) + 1);
                                data_reg <= data_delayed2;
                                state_machine <= write1;
                            when others =>
                                state_machine <= write1;
                        end case;
                        
                        if (addr_reg = "1111111111") then
                            state <= wait4done;
                            we_reg <= '0';
                        else
                            we_reg <= '1';
                        end if;
                    when wait4done =>
                        if (trig = '0') then
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
        clka => clka,
        addra => addra,
        dina => dina,
        ena => ena,
        wea => wea,
        douta => douta,

        clkb => clock,
        addrb => addr_reg,
        dinb => data_reg,
        web => we_reg
    );

end behavior;
