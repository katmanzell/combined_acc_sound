LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;

PACKAGE altera_drums IS

----------------------------
--       CONSTANTS        --
----------------------------
constant SOUND_BIT_WIDTH : integer := 24;

----------------------------
-- COMPONENT DECLARATIONS --
----------------------------
    
-- ***** Sound Selector *****
    -- selects next sound sample to feed FIFOs based on drum hit
    
--		COMPONENT top IS
--		Port (
--				clk : in std_logic;
--				scl : out std_logic;
--				sda : inout std_logic;
--				rst_n : in std_logic;
--				X_Accel : in std_logic_vector(15 downto 0);
--				Y_Accel : in std_logic_vector(15 downto 0);
--				Z_Accel : in std_logic_vector(15 downto 0);
--				flag : out std_logic
--	);
--	end component top;
	
	Component Accelerometer_Reader is
	port (
	clk : in std_logic;
	scl : out std_logic;
	sda : inout std_logic;
	rst_n : in std_logic;
	X_Accel : out std_logic_vector(15 downto 0);
	Y_Accel : out std_logic_vector(15 downto 0);
	Z_Accel : out std_logic_vector(15 downto 0)
);
	end component Accelerometer_Reader;
	
	
	component Beat_Generator is
	port (
	clk : in std_logic;
	rst : in std_logic;
	X_coordinate : in std_logic_vector(15 downto 0);
	Y_coordinate : in std_logic_vector(15 downto 0);
	Z_coordinate : in std_logic_vector(15 downto 0);
	beat_en : out std_logic;
	beat_intensity : out std_logic_vector(1 downto 0)
);
 end component Beat_Generator;
	
	
	component scale_clock is
  port (
    clk_50Mhz : in  std_logic;
    rst       : in  std_logic;
    clk_Hz   : out std_logic);
end component scale_clock;
	
	component de2lcd IS
	PORT(reset, clk_50Mhz				: IN	STD_LOGIC;
		 LCD_RS, LCD_E, LCD_ON, RESET_LED, SEC_LED		: OUT	STD_LOGIC;
		 LCD_RW						: BUFFER STD_LOGIC;
		 DATA_BUS				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0));
END component de2lcd;
	
	
	component flash_to_bram IS
  PORT ( 
          CLOCK_50, RESET : IN STD_LOGIC;
			 load_ram : in std_logic;
			 
			 ------------------------------------------------------------------------------------
			 --flash reader signals
			 --Address
			 FL_addr : out std_logic_vector(22 downto 0);
			 
			 --Data
			 FL_dq : in std_logic_vector(7 downto 0);
			 
			 --Chip Enable
			 FL_ce : out std_logic;
			 
			 --output enable
			 FL_oe : out std_logic;
			 
			 --ready/busy
			 FL_ready : in std_logic;
			 
			 --write enable
			 FL_wr_en : out std_logic; -- set always high because we never want to write over it
			 --------------------------------------------------------------------------------------

			 rt_dout : out std_logic_vector(23 downto 0);
			 rt_raddr : in std_logic_vector(14 downto 0);
			 
          lt_dout : out std_logic_vector(23 downto 0);
			 lt_raddr : in std_logic_vector(14 downto 0)
			 
			 
			 
			 
        );
END component flash_to_bram;
	
	
	component block_ram IS
  PORT ( 
          CLOCK_50 : IN STD_LOGIC;

          dout : out std_logic_vector(23 downto 0);
			 
			 din : in std_logic_vector(23 downto 0);
			 
			 wr_en : in std_logic;
			 
			 waddr : in std_logic_vector(14 downto 0);
			 
			 raddr : in std_logic_vector(14 downto 0)
			 
        );
END component block_ram;

	
	
	
	
	COMPONENT Sound_Connect IS
		PORT (
				clk : in std_logic;    
				rst_n : in std_logic;  
				beat : out std_logic;
				beat_int : out std_logic_vector(1 downto 0);
				scl : out std_logic;
				sda : inout std_logic
			);
	end COMPONENT Sound_Connect;
	 
	 
	 
	 
    COMPONENT sound_selector IS
      PORT ( 
              CLOCK_50 : IN STD_LOGIC;
              RESET : IN STD_LOGIC;
    
              -- SPIKE DETECTOR
              lt_hit, rt_hit : IN STD_LOGIC;
              --lt_vol, rt_vol : IN STD_LOGIC_VECTOR(1 downto 0);
    
			--flash address
--			FL_addr : out std_logic_vector(22 downto 0);
--			 
--			 --Data
--			 FL_dq : in std_logic_vector(7 downto 0);
--			 
--			 --Chip Enable
--			 FL_ce : out std_logic;
--			 
--			 --output enable
--			 FL_oe : out std_logic;
--			 
--			 --ready/busy
--			 FL_ready : in std_logic;
--			 
--			 --write enable
--			 FL_wr_en : out std_logic; -- set always high because we never want to write over it
	      lt_addr : OUT STD_LOGIC_VECTOR(14 downto 0);
	      rt_addr : OUT STD_LOGIC_VECTOR(14 downto 0);


              -- FIFOS
              lt_full : IN STD_LOGIC;
              lt_sound : OUT STD_LOGIC_VECTOR( SOUND_BIT_WIDTH-1 downto 0 );
              lt_wr_en : OUT STD_LOGIC;
              
              rt_full : IN STD_LOGIC;
              rt_sound : OUT STD_LOGIC_VECTOR( SOUND_BIT_WIDTH-1 downto 0 );
              rt_wr_en : OUT STD_LOGIC
            );
    END COMPONENT sound_selector;
    
--***** Audio Controller *****
    -- pulls from FIFO and communicates with Wolfson Audio Codec
    COMPONENT audio_controller IS
       PORT ( 
              -- CODEC & BOARD SIGNALS
              CLOCK_50, CLOCK_27, AUD_DACLRCK   : IN    STD_LOGIC;
              AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT  : IN    STD_LOGIC;
              RESET                                : IN    STD_LOGIC;
              I2C_SDAT                      : INOUT STD_LOGIC;
              I2C_SCLK, AUD_DACDAT, AUD_XCK : OUT   STD_LOGIC;
              
              -- FIFO SIGNALS
              lt_fifo_dout : IN std_logic_vector(23 downto 0);
              lt_fifo_rd_en : OUT std_logic;
              lt_fifo_empty : IN std_logic;
              rt_fifo_dout : IN std_logic_vector(23 downto 0);
              rt_fifo_rd_en : OUT std_logic;
              rt_fifo_empty : IN std_logic;
				  
				  --forcing write ready
				  write_ready_forced : in std_logic;
    
              -- SIMULATION SIGNALS
              lt_signal, rt_signal : OUT std_logic_vector(23 downto 0)
              );
    END COMPONENT audio_controller;
    
--***** FIFO *****
    COMPONENT fifo IS
       GENERIC(
          constant FIFO_DATA_WIDTH : integer := 24;
          constant FIFO_BUFFER_SIZE : integer := 1024
       );
       PORT (
          signal rd_clk : in std_logic;
          signal wr_clk : in std_logic;
          signal reset : in std_logic;
          signal rd_en : in std_logic;
          signal wr_en : in std_logic;
          signal din : in std_logic_vector ((FIFO_DATA_WIDTH - 1) downto 0);
          signal dout : out std_logic_vector ((FIFO_DATA_WIDTH - 1) downto 0);
          signal full : out std_logic;
          signal empty : out std_logic
       );
    END COMPONENT fifo;
    

END altera_drums;

PACKAGE BODY altera_drums IS
    
END altera_drums;