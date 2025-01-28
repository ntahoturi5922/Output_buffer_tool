library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
library unisim;
use unisim.vcomponents.all;

entity capture_registers is
port(
	--clock_write: in std_logic; -- master clock --200MHZ	
	clock_read: in std_logic; -- master clock --100MHZ
    reset: in std_logic; -- active high reset asyn -- only when reset this module works
    trig:  in std_logic; -- trigger pulse sync to clock  -- from the trigger module	 
	STOP_CAP: out std_logic;   -- stop capture when fifo is full and disable clock 
	Start_read: in std_logic;   -- this signal goes high when registers are full
    data:  in std_logic_vector(31 downto 0); -- captured data from the tx line
	data_out: out std_logic_vector (31 downto 0) --- data to read	  
	--EMPTY: out std_logic;   -- this sighnal goes high when fifo has been finished to be read and is ok to 
	-- to triger again. 
	--FULL: out std_logic
  
  );
end capture_registers;

architecture behavior of capture_registers is	 








signal data_out_reg: std_logic_vector(31 downto 0); ----------- signals goes here
signal wren: std_logic;
signal ren: std_logic;	 
signal register_empty: std_logic;	   
signal register_full: std_logic; 
signal addra: std_logic_vector (5 downto 0):="000000";




begin  
	
	
wren <= '1' when   trig ='1' else '0';	  

STOP_CAP <= '0';	


SPY_RAM_inst : RAMB36E2
generic map (
 CASCADE_ORDER_A => "NONE",
 CASCADE_ORDER_B => "NONE",
 CLOCK_DOMAINS => "INDEPENDENT",
 SIM_COLLISION_CHECK => "ALL",
 DOA_REG => 0,
 DOB_REG => 0,
 ENADDRENA => "FALSE",
 ENADDRENB => "FALSE",
 EN_ECC_PIPE => "FALSE",
 EN_ECC_READ => "FALSE",
 EN_ECC_WRITE => "FALSE",
 INIT_A => X"000000000",
 INIT_B => X"000000000",
 INIT_FILE => "NONE",
 IS_CLKARDCLK_INVERTED => '0',
 IS_CLKBWRCLK_INVERTED => '0',
 IS_ENARDEN_INVERTED => '0',
 IS_ENBWREN_INVERTED => '0',
 IS_RSTRAMARSTRAM_INVERTED => '0',
 IS_RSTRAMB_INVERTED => '0',
 IS_RSTREGARSTREG_INVERTED => '0',
 IS_RSTREGB_INVERTED => '0',
 RDADDRCHANGEA => "FALSE",
 RDADDRCHANGEB => "FALSE",
 READ_WIDTH_A => 36,
 READ_WIDTH_B => 18,
 WRITE_WIDTH_A => 36,
 WRITE_WIDTH_B => 18,
 RSTREG_PRIORITY_A => "RSTREG",
 RSTREG_PRIORITY_B => "RSTREG",
 SRVAL_A => X"000000000",
 SRVAL_B => X"000000000",
 SLEEP_ASYNC => "FALSE",
 WRITE_MODE_A => "NO_CHANGE",
 WRITE_MODE_B => "NO_CHANGE"
)
port map (
 CASDOUTA => open, 
 CASDOUTB => open, 
 CASDOUTPA => open, 
 CASDOUTPB => open, 
 CASOUTDBITERR => open, 
 CASOUTSBITERR => open, 
 DBITERR => open, 
 ECCPARITY => open, 
 RDADDRECC => open, 
 SBITERR => open, 
 CASDIMUXA => '0', 
 CASDIMUXB => '0', 
 CASDINA => X"00000000", 
 CASDINB => X"00000000", 
 CASDINPA => "0000", 
 CASDINPB => "0000", 
 CASDOMUXA => '0', 
 CASDOMUXB => '0', 
 CASDOMUXEN_A => '0', 
 CASDOMUXEN_B => '0', 
 CASINDBITERR => '0', 
 CASINSBITERR => '0', 
 CASOREGIMUXA => '0', 
 CASOREGIMUXB => '0', 
 CASOREGIMUXEN_A => '0', 
 CASOREGIMUXEN_B => '0', 
 ECCPIPECE => '0', 
 INJECTDBITERR => '0', 
 INJECTSBITERR => '0',

	-- Port A: AXI R/W access 1k x 36 

 CLKARDCLK => clka,
 ADDRARDADDR => ADDRARDADDR, -- 15 bits
 ADDRENA => '0',
 ENARDEN => ena,
 REGCEAREGCE => '1',
 RSTRAMARSTRAM => '0',
 RSTREGARSTREG => '0',
 SLEEP => '0',
 WEA => wea_i,
 DINADIN => dina, -- 32 bits
 DINPADINP => "0000", -- parity not used
 DOUTADOUT => douta, -- 32 bits
 DOUTPADOUTP => open,

	-- Port B: spy buffer logic, write only, 2k x 18

 CLKBWRCLK => clkb, 
 ADDRBWRADDR => ADDRBWRADDR, -- 15 bits
 ADDRENB => '0', 
 ENBWREN => web, -- when this port is enabled, write
 REGCEB => '0', 
 RSTRAMB => '0', 
 RSTREGB => '0', 
 WEBWE => "11111111",
 DINBDIN => DINBDIN, -- always 32 bits
 DINPBDINP => "0000", 
 DOUTBDOUT => open, 
 DOUTPBDOUTP => open 

);



   data_out <= 	 data_out_reg;	  

   
   
   end behavior;