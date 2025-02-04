library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;



entity OUT_SPY_BUFF_TB is
end OUT_SPY_BUFF_TB;

architecture tb of OUT_SPY_BUFF_TB is
    
    component OUT_SPY_BUFF
    port(
        clock: in std_logic;
        trig: in std_logic;
        din: in std_logic_vector(63 downto 0);
        S_AXI_ACLK: in std_logic;
        S_AXI_ARESETN: in std_logic;
        S_AXI_AWADDR: in std_logic_vector(31 downto 0);
        S_AXI_AWPROT: in std_logic_vector(2 downto 0);
        S_AXI_AWVALID: in std_logic;
        S_AXI_AWREADY: out std_logic;
        S_AXI_WDATA: in std_logic_vector(31 downto 0);
        S_AXI_WSTRB: in std_logic_vector(3 downto 0);
        S_AXI_WVALID: in std_logic;
        S_AXI_WREADY: out std_logic;
        S_AXI_BRESP: out std_logic_vector(1 downto 0);
        S_AXI_BVALID: out std_logic;
        S_AXI_BREADY: in std_logic;
        S_AXI_ARADDR: in std_logic_vector(31 downto 0);
        S_AXI_ARPROT: in std_logic_vector(2 downto 0);
        S_AXI_ARVALID: in std_logic;
        S_AXI_ARREADY: out std_logic;
        S_AXI_RDATA: out std_logic_vector(31 downto 0);
        S_AXI_RRESP: out std_logic_vector(1 downto 0);
        S_AXI_RVALID: out std_logic;
        S_AXI_RREADY: in std_logic
    );
    end component;	 
	
	
	
	
	
	
    component TX_CAPUTER
    port(
    clock: in std_logic; -- master clock --156.5MHZ
    reset: in std_logic; -- active high reset asyn -- only when reset this module works
    trig:  in std_logic; -- trigger pulse sync to clock  -- from the trigger module	 
	Data_in: in std_logic_vector (63 downto 0); -- this is the data that we capture and divide it into 2 32 bit data to write to memory 
	
    data1:  out std_logic_vector(31 downto 0); -- captured data from the tx line
	data2:	out std_logic_vector(31 downto 0)
    );
    end component;	
	
	
	
	
	
	
	
    
    signal clock: std_logic := '0';
    signal trig: std_logic := '0';
    signal din: std_logic_vector(63 downto 0) := (others => '0');
    signal S_AXI_ACLK: std_logic := '0';
    signal S_AXI_ARESETN: std_logic := '0';
    signal S_AXI_AWADDR: std_logic_vector(31 downto 0) := (others => '0');
    signal S_AXI_AWPROT: std_logic_vector(2 downto 0) := (others => '0');
    signal S_AXI_AWVALID: std_logic := '0';
    signal S_AXI_AWREADY: std_logic;
    signal S_AXI_WDATA: std_logic_vector(31 downto 0) := (others => '0');
    signal S_AXI_WSTRB: std_logic_vector(3 downto 0) := (others => '0');
    signal S_AXI_WVALID: std_logic := '0';
    signal S_AXI_WREADY: std_logic;
    signal S_AXI_BRESP: std_logic_vector(1 downto 0);
    signal S_AXI_BVALID: std_logic;
    signal S_AXI_BREADY: std_logic := '0';
    signal S_AXI_ARADDR: std_logic_vector(31 downto 0) := (others => '0');
    signal S_AXI_ARPROT: std_logic_vector(2 downto 0) := (others => '0');
    signal S_AXI_ARVALID: std_logic := '0';
    signal S_AXI_ARREADY: std_logic;
    signal S_AXI_RDATA: std_logic_vector(31 downto 0);
    signal S_AXI_RRESP: std_logic_vector(1 downto 0);
    signal S_AXI_RVALID: std_logic;
    signal S_AXI_RREADY: std_logic := '0';
    signal cap_data1,cap_data2: std_logic_vector (31 downto 0); 
	signal reset: std_logic;
begin
    -- DUT instantiation
    uut: OUT_SPY_BUFF
    port map(
        clock => clock,
        trig => trig,
        din => din,
        S_AXI_ACLK => S_AXI_ACLK,
        S_AXI_ARESETN => S_AXI_ARESETN,
        S_AXI_AWADDR => S_AXI_AWADDR,
        S_AXI_AWPROT => S_AXI_AWPROT,
        S_AXI_AWVALID => S_AXI_AWVALID,
        S_AXI_AWREADY => S_AXI_AWREADY,
        S_AXI_WDATA => S_AXI_WDATA,
        S_AXI_WSTRB => S_AXI_WSTRB,
        S_AXI_WVALID => S_AXI_WVALID,
        S_AXI_WREADY => S_AXI_WREADY,
        S_AXI_BRESP => S_AXI_BRESP,
        S_AXI_BVALID => S_AXI_BVALID,
        S_AXI_BREADY => S_AXI_BREADY,
        S_AXI_ARADDR => S_AXI_ARADDR,
        S_AXI_ARPROT => S_AXI_ARPROT,
        S_AXI_ARVALID => S_AXI_ARVALID,
        S_AXI_ARREADY => S_AXI_ARREADY,
        S_AXI_RDATA => S_AXI_RDATA,
        S_AXI_RRESP => S_AXI_RRESP,
        S_AXI_RVALID => S_AXI_RVALID,
        S_AXI_RREADY => S_AXI_RREADY
    );
	
	

    
reset <= not S_AXI_ARESETN	;
    -- Clock process
    process
    begin
        while true loop
            clock <= '0';
            wait for 3.2 ns;
            clock <= '1';
            wait for 3.2 ns;
        end loop;
    end process;
    
    S_AXI_ACLK_process: process
    begin
        while true loop
            S_AXI_ACLK <= '0';
            wait for 5 ns;
            S_AXI_ACLK <= '1';
            wait for 5 ns;
        end loop;
    end process;  
	
	
     trig <= '1'; 
    aximaster_proc: process		
  
procedure axipoke( constant addr: in std_logic_vector;
                   constant data: in std_logic_vector ) is
begin
    wait until rising_edge(S_AXI_ACLK);
    S_AXI_AWADDR <= addr;
    S_AXI_AWVALID <= '1';
    din <= data;
    S_AXI_WVALID <= '1';
    S_AXI_BREADY <= '1';
    S_AXI_WSTRB <= "1111";	
	--trig <= '1';
    wait until (rising_edge(S_AXI_ACLK) and S_AXI_AWREADY='1' and S_AXI_WREADY='1');
    S_AXI_AWADDR <= addr;
    S_AXI_AWVALID <= '0';
    din <= data;
    S_AXI_AWVALID <= '0';
    S_AXI_WSTRB <= "0000";	
	--trig <= '1';
    wait until (rising_edge(S_AXI_ACLK) and S_AXI_BVALID='1');
    S_AXI_BREADY <= '0';	  
	--trig <= '1';
end procedure axipoke;

procedure axipeek( constant addr: in std_logic_vector ) is
begin
    wait until rising_edge(S_AXI_ACLK);
    S_AXI_ARADDR <= addr;
    S_AXI_ARVALID <= '1';
    S_AXI_RREADY <= '1';	 
	--trig <= '1';
    wait until (rising_edge(S_AXI_ACLK) and S_AXI_ARREADY='1');
    S_AXI_ARADDR <=  addr;
    S_AXI_ARVALID <= '0';	
	--trig <= '1';
    wait until (rising_edge(S_AXI_ACLK) and S_AXI_RVALID='1');
    S_AXI_RREADY <= '0';
	--trig <= '1';
end procedure axipeek;

begin

wait for 500ns;
S_AXI_ARESETN <= '1'; -- release AXI reset
 -- poking
wait for 500ns;
axipoke(addr => X"0004", data => X"0000000000005050"); -- data to sent to first DAC U50
wait for 500ns;
axipoke(addr => X"0008", data => X"0000000000005353"); -- data to sent to middle DAC U53
wait for 500ns;
axipoke(addr => X"000C", data => X"000000000000DAC5"); -- data to sent to last DAC U5

wait for 500ns;
axipoke(addr => X"0000", data => X"00000000DEADBEEF");  -- write anything to CTRL register... GO!
-- peeking



wait for 500ns;
axipeek(addr => X"0004");
wait for 500ns;
axipeek(addr => X"0008"); -- data to sent to middle DAC U53
wait for 500ns;
axipeek(addr => X"000C"); -- data to sent to last DAC U5

wait for 500ns;
axipeek(addr => X"0000");  -- write anything to CTRL register... GO!

wait;


wait;
end process aximaster_proc;


    
end tb;
