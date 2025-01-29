library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    
    -- Stimulus process
    process
    begin
        -- Reset the system
        S_AXI_ARESETN <= '0';
        wait for 20 ns;
        S_AXI_ARESETN <= '1';
        trig <= '1';
        -- Write operation
        S_AXI_AWADDR <= x"00000000";   
		din <= x"deadbeefbabedada";
        S_AXI_AWVALID <= '1';
        S_AXI_WDATA <= x"DEADBEEF";
        S_AXI_WVALID <= '1';
        S_AXI_WSTRB <= "1111";
        
        wait for 20 ns;
       	trig <= '1';
        
        S_AXI_AWVALID <= '0';
        S_AXI_WVALID <= '0';
        S_AXI_BREADY <= '1';
        wait for 20 ns;
        S_AXI_BREADY <= '0';
        trig <= '1';
        -- Read operation
        S_AXI_ARADDR <= x"00000000";
        S_AXI_ARVALID <= '1';
        
        wait for 20 ns;
        S_AXI_ARVALID <= '0';
        S_AXI_RREADY <= '1'; 
		trig <= '1';
        wait for 20 ns;
        S_AXI_RREADY <= '0';
        
        -- Trigger signal
        trig <= '1';
        wait for 20 ns;
        trig <= '1';
        
        wait;
    end process;
    
end tb;
