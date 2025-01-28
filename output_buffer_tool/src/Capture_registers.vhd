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



component xpm_memory_spram
   generic (
      ADDR_WIDTH_A: integer := 6;              -- DECIMAL
      AUTO_SLEEP_TIME: integer :=  0;           -- DECIMAL
      BYTE_WRITE_WIDTH_A : integer :=  32;       -- DECIMAL
      CASCADE_HEIGHT: integer :=  0;            -- DECIMAL
      ECC_BIT_RANGE:string:= "7:0";         -- String
      ECC_MODE :string:= "no_ecc";           -- String
      ECC_TYPE :string:= "none";             -- String
      IGNORE_INIT_SYNTH: integer := 0;         -- DECIMAL
      MEMORY_INIT_FILE :string:= "none";     -- String
      MEMORY_INIT_PARAM :string:= "0";       -- String
      MEMORY_OPTIMIZATION :string:= "true";  -- String
      MEMORY_PRIMITIVE :string:= "auto";     -- String
      MEMORY_SIZE :  integer := 2048;            -- DECIMAL
      MESSAGE_CONTROL: integer := 0;           -- DECIMAL
      RAM_DECOMP :string:= "auto";           -- String
      READ_DATA_WIDTH_A: integer := 32;        -- DECIMAL
      READ_LATENCY_A: integer := 2;            -- DECIMAL
      READ_RESET_VALUE_A :string:= "0";      -- String
      RST_MODE_A :string:= "SYNC";           -- String
      SIM_ASSERT_CHK:integer := 0;           -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      USE_MEM_INIT: integer := 1;              -- DECIMAL
      USE_MEM_INIT_MMI:integer := 0;          -- DECIMAL
      WAKEUP_TIME :string:= "disable_sleep"; -- String
      WRITE_DATA_WIDTH_A: integer := 32;       -- DECIMAL
      WRITE_MODE_A :string:= "read_first";   -- String
      WRITE_PROTECT: integer := 1              -- DECIMAL
   );
   port (
      dbiterra: out std_logic;             -- 1-bit output: Status signal to indicate double bit error occurrence
                                        -- on the data output of port A.

      douta : out std_logic_vector (31 downto 0);                   -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
      sbiterra: out std_logic;             -- 1-bit output: Status signal to indicate single bit error occurrence
                                        -- on the data output of port A.

      addra : in std_logic_vector (5 downto 0);                   -- ADDR_WIDTH_A-bit input: Address for port A write and read operations.
      clka  : in std_logic;                     -- 1-bit input: Clock signal for port A.
      dina : in std_logic_vector ;                     -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
      ena : in std_logic;                       -- 1-bit input: Memory enable signal for port A. Must be high on clock
                                        -- cycles when read or write operations are initiated. Pipelined
                                        -- internally.

      injectdbiterra : in std_logic; -- 1-bit input: Controls double bit error injection on input data when
                                        -- ECC enabled (Error injection capability is not available in
                                        -- "decode_only" mode).

      injectsbiterra : in std_logic; -- 1-bit input: Controls single bit error injection on input data when
                                        -- ECC enabled (Error injection capability is not available in
                                        -- "decode_only" mode).

      regcea : in std_logic;                 -- 1-bit input: Clock Enable for the last register stage on the output
                                        -- data path.

      rsta : in std_logic;                     -- 1-bit input: Reset signal for the final port A output register
                                        -- stage. Synchronously resets output port douta to the value specified
                                        -- by parameter READ_RESET_VALUE_A.

      sleep : in std_logic;                   -- 1-bit input: sleep signal to enable the dynamic power saving feature.
      wea : in std_logic                        -- WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                                        -- for port A input data port dina. 1 bit wide when word-wide writes
                                        -- are used. In byte-wide write configurations, each bit controls the
                                        -- writing one byte of dina to address addra. For example, to
                                        -- synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                                        -- is 32, wea would be 4'b0010.

   );
end component;



begin
wren <= '1' when   trig ='1' else '0';	  

STOP_CAP <= '0';	


-- XPM_MEMORY instantiation template for Single Port RAM configurations
-- Refer to the targeted device family architecture libraries guide for XPM_MEMORY documentation
-- =======================================================================================================================

-- Parameter usage table, organized as follows:
-- +---------------------------------------------------------------------------------------------------------------------+
-- | Parameter name       | Data type          | Restrictions, if applicable                                             |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Description                                                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- +---------------------------------------------------------------------------------------------------------------------+
-- | ADDR_WIDTH_A         | Integer            | Range: 1 - 20. Default value = 6.                                       |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify the width of the port A address port addra, in bits.                                                        |
-- | Must be large enough to access the entire memory from port A, i.e. &gt;= $clog2(MEMORY_SIZE/[WRITE|READ]_DATA_WIDTH_A).|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | AUTO_SLEEP_TIME      | Integer            | Range: 0 - 15. Default value = 0.                                       |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify the number of clka cycles to auto-sleep, if feature is available in architecture.                           |
-- |                                                                                                                     |
-- | 0 - Disable auto-sleep feature                                                                                      |
-- | 3-15 - Number of auto-sleep latency cycles                                                                          |
-- |                                                                                                                     |
-- | Do not change from the value provided in the template instantiation.                                                |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | BYTE_WRITE_WIDTH_A   | Integer            | Range: 1 - 4608. Default value = 32.                                    |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | To enable byte-wide writes on port A, specify the byte width, in bits.                                              |
-- |                                                                                                                     |
-- | 8- 8-bit byte-wide writes, legal when WRITE_DATA_WIDTH_A is an integer multiple of 8                                |
-- | 9- 9-bit byte-wide writes, legal when WRITE_DATA_WIDTH_A is an integer multiple of 9                                |
-- |                                                                                                                     |
-- | Or to enable word-wide writes on port A, specify the same value as for WRITE_DATA_WIDTH_A.                          |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | CASCADE_HEIGHT       | Integer            | Range: 0 - 64. Default value = 0.                                       |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | 0- No Cascade Height, Allow Vivado Synthesis to choose.                                                             |
-- | 1 or more - Vivado Synthesis sets the specified value as Cascade Height.                                            |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | ECC_BIT_RANGE        | String             | Default value = 7:0.                                                    |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | This parameter is only used by synthesis. Specify the ECC bit range on the provided data.                           |
-- | "7:0" - it specifies lower 8 bits are ECC bits.                                                                     |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | ECC_MODE             | String             | Allowed values: no_ecc, both_encode_and_decode, decode_only, encode_only. Default value = no_ecc.|
-- |---------------------------------------------------------------------------------------------------------------------|
-- |                                                                                                                     |
-- |   "no_ecc" - Disables ECC                                                                                           |
-- |   "encode_only" - Enables ECC Encoder only                                                                          |
-- |   "decode_only" - Enables ECC Decoder only                                                                          |
-- |   "both_encode_and_decode" - Enables both ECC Encoder and Decoder                                                   |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | ECC_TYPE             | String             | Allowed values: none, ECCHSIAO32-7, ECCHSIAO64-8, ECCHSIAO128-9, ECCH32-7, ECCH64-8. Default value = none.|
-- |---------------------------------------------------------------------------------------------------------------------|
-- | This parameter is only used by synthesis. Specify the algorithm used to generate the ecc bits outside the XPM Memory.|
-- | XPM Memory does not performs ECC operation with this parameter.                                                     |
-- |                                                                                                                     |
-- |   "none" - No ECC                                                                                                   |
-- |   "ECCH32-7" - 32 bit ECC Hamming algorithm is used                                                                 |
-- |   "ECCH64-8" - 64 bit ECC Hamming algorithm is used                                                                 |
-- |   "ECCHSIAO32-7" - 32 bit ECC HSIAO algorithm is used                                                               |
-- |   "ECCHSIAO64-8" - 64 bit ECC HSIAO algorithm is used                                                               |
-- |   "ECCHSIAO128-9" - 128 bit ECC HSIAO algorithm is used                                                             |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | IGNORE_INIT_SYNTH    | Integer            | Range: 0 - 1. Default value = 0.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | 0 - Initiazation file if specified will applies for both simulation and synthesis                                   |
-- | 1 - Initiazation file if specified will applies for only simulation and will ignore for synthesis                   |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | MEMORY_INIT_FILE     | String             | Default value = none.                                                   |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify "none" (including quotes) for no memory initialization, or specify the name of a memory initialization file-|
-- | Enter only the name of the file with .mem extension, including quotes but without path (e.g. "my_file.mem").        |
-- | File format must be ASCII and consist of only hexadecimal values organized into the specified depth by              |
-- | narrowest data width generic value of the memory. Initialization of memory happens through the file name specified only when parameter|
-- | MEMORY_INIT_PARAM value is equal to "".                                                                             |
-- | When using XPM_MEMORY in a project, add the specified file to the Vivado project as a design source.                |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | MEMORY_INIT_PARAM    | String             | Default value = 0.                                                      |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify "" or "0" (including quotes) for no memory initialization through parameter, or specify the string          |
-- | containing the hex characters. Enter only hex characters with each location separated by delimiter (,).             |
-- | Parameter format must be ASCII and consist of only hexadecimal values organized into the specified depth by         |
-- | narrowest data width generic value of the memory.For example, if the narrowest data width is 8, and the depth of    |
-- | memory is 8 locations, then the parameter value should be passed as shown below.                                    |
-- | parameter MEMORY_INIT_PARAM = "AB,CD,EF,1,2,34,56,78"                                                               |
-- | Where "AB" is the 0th location and "78" is the 7th location.                                                        |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | MEMORY_OPTIMIZATION  | String             | Allowed values: true, false. Default value = true.                      |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify "true" to enable the optimization of unused memory or bits in the memory structure. Specify "false" to      |
-- | disable the optimization of unused memory or bits in the memory structure.                                          |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | MEMORY_PRIMITIVE     | String             | Allowed values: auto, block, distributed, mixed, ultra. Default value = auto.|
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Designate the memory primitive (resource type) to use.                                                              |
-- |                                                                                                                     |
-- |   "auto"- Allow Vivado Synthesis to choose                                                                          |
-- |   "distributed"- Distributed memory                                                                                 |
-- |   "block"- Block memory                                                                                             |
-- |   "ultra"- Ultra RAM memory                                                                                         |
-- |   "mixed"- Mixed memory                                                                                             |
-- |                                                                                                                     |
-- | NOTE: There may be a behavior mismatch if Block RAM or Ultra RAM specific features, like ECC or Asymmetry, are selected with MEMORY_PRIMITIVE set to "auto".|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | MEMORY_SIZE          | Integer            | Range: 2 - 150994944. Default value = 2048.                             |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify the total memory array size, in bits.                                                                       |
-- | For example, enter 65536 for a 2kx32 RAM.                                                                           |
-- |                                                                                                                     |
-- |   When ECC is enabled and set to "encode_only", then the memory size has to be multiples of READ_DATA_WIDTH_A       |
-- |   When ECC is enabled and set to "decode_only", then the memory size has to be multiples of WRITE_DATA_WIDTH_A      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | MESSAGE_CONTROL      | Integer            | Range: 0 - 1. Default value = 0.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify 1 to enable the dynamic message reporting such as collision warnings, and 0 to disable the message reporting|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | RAM_DECOMP           | String             | Allowed values: auto, area, power. Default value = auto.                |
-- |---------------------------------------------------------------------------------------------------------------------|
-- |  Specifies the decomposition of the memory.                                                                         |
-- |  "auto" - Synthesis selects default.                                                                                |
-- |  "power" - Synthesis selects a strategy to reduce switching activity of RAMs and maps using widest configuration possible.|
-- |  "area" - Synthesis selects a strategy to reduce RAM resource count.                                                |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | READ_DATA_WIDTH_A    | Integer            | Range: 1 - 4608. Default value = 32.                                    |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify the width of the port A read data output port douta, in bits.                                               |
-- | The values of READ_DATA_WIDTH_A and WRITE_DATA_WIDTH_A must be equal.                                               |
-- | When ECC is enabled and set to "encode_only", then READ_DATA_WIDTH_A has to be multiples of 72-bits.                |
-- | When ECC is enabled and set to "decode_only" or "both_encode_and_decode", then READ_DATA_WIDTH_A has to be          |
-- | multiples of 64-bits.                                                                                               |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | READ_LATENCY_A       | Integer            | Range: 0 - 100. Default value = 2.                                      |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify the number of register stages in the port A read data pipeline. Read data output to port douta takes this   |
-- | number of clka cycles.                                                                                              |
-- |                                                                                                                     |
-- | To target block memory, a value of 1 or larger is required- 1 causes use of memory latch only; 2 causes use of      |
-- | output register.                                                                                                    |
-- | To target distributed memory, a value of 0 or larger is required- 0 indicates combinatorial output.                 |
-- | Values larger than 2 synthesize additional flip-flops that are not retimed into memory primitives.                  |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | READ_RESET_VALUE_A   | String             | Default value = 0.                                                      |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify the reset value of the port A final output register stage in response to rsta input port is assertion.      |
-- | Since this parameter is a string, you must specify the hex values inside double quotes. For example,                |
-- | If the read data width is 8, then specify READ_RESET_VALUE_A = "EA";                                                |
-- | When ECC is enabled, then reset value is not supported.                                                             |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | RST_MODE_A           | String             | Allowed values: SYNC, ASYNC. Default value = SYNC.                      |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Describes the behaviour of the reset                                                                                |
-- |                                                                                                                     |
-- |   "SYNC" - when reset is applied, synchronously resets output port douta to the value specified by parameter READ_RESET_VALUE_A|
-- |   "ASYNC" - when reset is applied, asynchronously resets output port douta to zero                                  |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | SIM_ASSERT_CHK       | Integer            | Range: 0 - 1. Default value = 0.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | 0- Disable simulation message reporting. Messages related to potential misuse will not be reported.                 |
-- | 1- Enable simulation message reporting. Messages related to potential misuse will be reported.                      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | USE_MEM_INIT         | Integer            | Range: 0 - 1. Default value = 1.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify 1 to enable the generation of below message and 0 to disable generation of the following message completely.|
-- | "INFO - MEMORY_INIT_FILE and MEMORY_INIT_PARAM together specifies no memory initialization.                         |
-- | Initial memory contents will be all 0s."                                                                            |
-- | NOTE: This message gets generated only when there is no Memory Initialization specified either through file or      |
-- | Parameter.                                                                                                          |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | USE_MEM_INIT_MMI     | Integer            | Range: 0 - 1. Default value = 0.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify 1 to expose this memory information to be written out in the MMI file.                                      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | WAKEUP_TIME          | String             | Allowed values: disable_sleep, use_sleep_pin. Default value = disable_sleep.|
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify "disable_sleep" to disable dynamic power saving option, and specify "use_sleep_pin" to enable the           |
-- | dynamic power saving option                                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | WRITE_DATA_WIDTH_A   | Integer            | Range: 1 - 4608. Default value = 32.                                    |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify the width of the port A write data input port dina, in bits.                                                |
-- | The values of WRITE_DATA_WIDTH_A and READ_DATA_WIDTH_A must be equal.                                               |
-- | When ECC is enabled and set to "encode_only" or "both_encode_and_decode", then WRITE_DATA_WIDTH_A must be           |
-- | multiples of 64-bits.                                                                                               |
-- | When ECC is enabled and set to "decode_only", then WRITE_DATA_WIDTH_A must be multiples of 72-bits.                 |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | WRITE_MODE_A         | String             | Allowed values: read_first, no_change, write_first. Default value = read_first.|
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write mode behavior for port A output data port, douta.                                                             |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | WRITE_PROTECT        | Integer            | Range: 0 - 1. Default value = 1.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Default value is 1, means write is protected through enable and write enable and hence the LUT is placed before the memory. This is the default behaviour to access memory.|
-- | When 0, disables write protection. Write enable (WE) directly connected to memory.                                  |
-- | NOTE: Disable this option only if the advanced users can guarantee that the write enable (WE) cannot be given without enable (EN).|
-- +---------------------------------------------------------------------------------------------------------------------+

-- Port usage table, organized as follows:
-- +---------------------------------------------------------------------------------------------------------------------+
-- | Port name      | Direction | Size, in bits                         | Domain  | Sense       | Handling if unused     |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Description                                                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- +---------------------------------------------------------------------------------------------------------------------+
-- | addra          | Input     | ADDR_WIDTH_A                          | clka    | NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Address for port A write and read operations.                                                                       |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | clka           | Input     | 1                                     | NA      | Rising edge | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Clock signal for port A.                                                                                            |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | dbiterra       | Output    | 1                                     | clka    | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Status signal to indicate double bit error occurrence on the data output of port A.                                 |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | dina           | Input     | WRITE_DATA_WIDTH_A                    | clka    | NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Data input for port A write operations.                                                                             |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | douta          | Output    | READ_DATA_WIDTH_A                     | clka    | NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Data output for port A read operations.                                                                             |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | ena            | Input     | 1                                     | clka    | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Memory enable signal for port A.                                                                                    |
-- | Must be high on clock cycles when read or write operations are initiated. Pipelined internally.                     |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | injectdbiterra | Input     | 1                                     | clka    | Active-high | Tie to 1'b0            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in  |
-- | "decode_only" mode).                                                                                                |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | injectsbiterra | Input     | 1                                     | clka    | Active-high | Tie to 1'b0            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in  |
-- | "decode_only" mode).                                                                                                |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | regcea         | Input     | 1                                     | clka    | Active-high | Tie to 1'b1            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Clock Enable for the last register stage on the output data path.                                                   |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | rsta           | Input     | 1                                     | clka    | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Reset signal for the final port A output register stage.                                                            |
-- | Synchronously resets output port douta to the value specified by parameter READ_RESET_VALUE_A.                      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | sbiterra       | Output    | 1                                     | clka    | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Status signal to indicate single bit error occurrence on the data output of port A.                                 |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | sleep          | Input     | 1                                     | NA      | Active-high | Tie to 1'b0            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | sleep signal to enable the dynamic power saving feature.                                                            |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | wea            | Input     | WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A | clka    | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are used.                     |
-- | In byte-wide write configurations, each bit controls the writing one byte of dina to address addra.                 |
-- | For example, to synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.   |
-- +---------------------------------------------------------------------------------------------------------------------+


-- xpm_memory_spram : In order to incorporate this function into the design,
--       VHDL       : the following instance declaration needs to be placed
--     instance     : in the body of the design code.  The instance name
--   declaration    : (xpm_memory_spram_inst) and/or the port declarations after the
--       code       : "=>" declaration maybe changed to properly reference and
--                  : connect this function to the design.  All inputs and outputs
--                  : must be connected.

--     Library      : In addition to adding the instance declaration, a use
--   declaration    : statement for the UNISIM.vcomponents library needs to be
--       for        : added before the entity declaration.  This library
--      Xilinx      : contains the component declarations for all Xilinx
--    primitives    : primitives and points to the models that will be used
--                  : for simulation.

--  Please reference the appropriate libraries guide for additional information on the XPM modules.

--  Copy the following two statements and paste them before the
--  Entity declaration, unless they already exist.


-- <-----Cut code below this line and paste into the architecture body---->

   -- xpm_memory_spram: Single Port RAM
   -- Xilinx Parameterized Macro, version 2024.1

   xpm_memory_spram_inst : xpm_memory_spram
   generic map (
      ADDR_WIDTH_A => 6,              -- DECIMAL
      AUTO_SLEEP_TIME => 0,           -- DECIMAL
      BYTE_WRITE_WIDTH_A => 32,       -- DECIMAL
      CASCADE_HEIGHT => 0,            -- DECIMAL
      ECC_BIT_RANGE => "7:0",         -- String
      ECC_MODE => "no_ecc",           -- String
      ECC_TYPE => "none",             -- String
      IGNORE_INIT_SYNTH => 0,         -- DECIMAL
      MEMORY_INIT_FILE => "none",     -- String
      MEMORY_INIT_PARAM => "0",       -- String
      MEMORY_OPTIMIZATION => "true",  -- String
      MEMORY_PRIMITIVE => "auto",     -- String
      MEMORY_SIZE => 2048,            -- DECIMAL
      MESSAGE_CONTROL => 0,           -- DECIMAL
      RAM_DECOMP => "auto",           -- String
      READ_DATA_WIDTH_A => 32,        -- DECIMAL
      READ_LATENCY_A => 2,            -- DECIMAL
      READ_RESET_VALUE_A => "0",      -- String
      RST_MODE_A => "SYNC",           -- String
      SIM_ASSERT_CHK => 0,            -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      USE_MEM_INIT => 1,              -- DECIMAL
      USE_MEM_INIT_MMI => 0,          -- DECIMAL
      WAKEUP_TIME => "disable_sleep", -- String
      WRITE_DATA_WIDTH_A => 32,       -- DECIMAL
      WRITE_MODE_A => "read_first",   -- String
      WRITE_PROTECT => 1              -- DECIMAL
   )
   port map (
      dbiterra => open,             -- 1-bit output: Status signal to indicate double bit error occurrence
                                        -- on the data output of port A.

      douta => data_out_reg,                   -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
      sbiterra => open,             -- 1-bit output: Status signal to indicate single bit error occurrence
                                        -- on the data output of port A.

      addra => addra,                   -- ADDR_WIDTH_A-bit input: Address for port A write and read operations.
      clka => clock_read,                     -- 1-bit input: Clock signal for port A.
      dina => data,                     -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
      ena => '1',                       -- 1-bit input: Memory enable signal for port A. Must be high on clock
                                        -- cycles when read or write operations are initiated. Pipelined
                                        -- internally.

      injectdbiterra => '1', -- 1-bit input: Controls double bit error injection on input data when
                                        -- ECC enabled (Error injection capability is not available in
                                        -- "decode_only" mode).

      injectsbiterra => '1', -- 1-bit input: Controls single bit error injection on input data when
                                        -- ECC enabled (Error injection capability is not available in
                                        -- "decode_only" mode).

      regcea => '1',                 -- 1-bit input: Clock Enable for the last register stage on the output
                                        -- data path.

      rsta => reset,                     -- 1-bit input: Reset signal for the final port A output register
                                        -- stage. Synchronously resets output port douta to the value specified
                                        -- by parameter READ_RESET_VALUE_A.

      sleep => '0',                   -- 1-bit input: sleep signal to enable the dynamic power saving feature.
      wea => wren                        -- WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                                        -- for port A input data port dina. 1 bit wide when word-wide writes
                                        -- are used. In byte-wide write configurations, each bit controls the
                                        -- writing one byte of dina to address addra. For example, to
                                        -- synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                                        -- is 32, wea would be 4'b0010.

   );


   data_out <= 	 data_out_reg;	  

   
   
   end behavior;