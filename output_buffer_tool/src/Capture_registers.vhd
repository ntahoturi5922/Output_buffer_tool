library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity capture_registers is
port(
    clka:  in std_logic;
    addra: in std_logic_vector( 14 downto 0); -- 1k x 32 R/W axi
    dina:  in std_logic_vector(31 downto 0);
    ena:   in std_logic;
    wea:   in std_logic;
    douta: out std_logic_vector(31 downto 0);
	reset: in std_logic;
    clkb:  in std_logic;
    addrb: in std_logic_vector(14 downto 0); -- 2k x 16 writeonly spybuff
    dinb:  in std_logic_vector(31 downto 0);
    web:   in std_logic;
	--address1: in std_logic_vector (14 downto 0);   
	--address2: in std_logic_vector (14 downto 0);
	trig: in std_logic;
    --data1:  in std_logic_vector(31 downto 0); -- captured data from the tx line
	--data2:	in std_logic_vector(31 downto 0)
  	data_in :in std_logic_vector (63 downto 0)  
  );
end capture_registers;

architecture behavior of capture_registers is	 

type state_machine is (write_reg1, write_reg2);
signal state: state_machine	;
signal write_cnt: integer range 0 to 31 :=0;
signal done_write: std_logic:='0'  ;
signal cap_data1,cap_data2: std_logic_vector (31 downto 0);
signal cap_addr1,cap_addr2: std_logic_vector (14 downto 0);




signal ADDRARDADDR, ADDRBWRADDR: std_logic_vector(14 downto 0);
signal wea_i: std_logic_vector(3 downto 0);

signal DINBDIN: std_logic_vector(31 downto 0);




begin  
	
wea_i <= "1111" when ( wea='1' ) else "0000";	
	  
    capture_componet: entity work.TX_CAPUTER
        port map (
            clock      => clkb,
            reset      => reset,
            trig       => trig,
			
    		Data_in  =>	data_in,
            --STOP_CAP   => STOP_CAP,
            address1    =>   cap_addr1 ,
			address2    => 	cap_addr2,
	
    		data1    =>   cap_data1,
			data2    => cap_data2
        );
	


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

process (clkb,reset)
begin
        if reset = '1' then		   --- here we are in reset
			done_write <= '0';
			write_cnt <= 0;
        elsif rising_edge (clkb) then	 --- getting out of reset	
				done_write <= '1';
                state <= write_reg1; 
				write_cnt <= 0;	
					case state is
						when write_reg1  =>
							DINBDIN <= cap_data1;	
							ADDRBWRADDR <= cap_addr1;
							write_cnt <= write_cnt +1 ; 
							if write_cnt = write_cnt then  
								state <=  write_reg2;
							else
								state <=  write_reg1;
							end if;
							
						when write_reg2  =>
							DINBDIN <= cap_data2;	
							ADDRBWRADDR <= cap_addr1;
							write_cnt <= write_cnt +1 ; 
							if write_cnt = write_cnt then  
								state <=  write_reg1;
							else
								state <=  write_reg2;
							end if;							
					end case;
         end if;	
					
    end process;

  ADDRARDADDR <=  	addra;
   
   end behavior;