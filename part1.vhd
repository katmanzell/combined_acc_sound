LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
USE work.altera_drums.all;

ENTITY part1 IS
   PORT ( CLOCK_50, CLOCK_27, RESET, AUD_DACLRCK   : IN    STD_LOGIC;

    low_RESET : in std_logic;

    load_ram : in std_logic;
          AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT  : IN    STD_LOGIC;
          I2C_SDAT                      : INOUT STD_LOGIC;
          I2C_SCLK, AUD_DACDAT, AUD_XCK : OUT   STD_LOGIC;
          --lt_hit : in std_logic;
			 
			 --rt_hit : IN STD_LOGIC;
			 
			 --pins for de2lcd
          LCD_RS, LCD_E, LCD_ON, RESET_LED, SEC_LED        : OUT    STD_LOGIC;
          LCD_RW                        : BUFFER STD_LOGIC;
          DATA_BUS                : INOUT    STD_LOGIC_VECTOR(7 DOWNTO 0);
			 
			 
			 --Forcing write ready
			 write_ready_forced : in std_logic;
			 
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
			 
			 --Sound Connect
			 scl_lt : out std_logic;
			 sda_lt : inout std_logic;
			 
			 scl_rt : out std_logic;
			 sda_rt : inout std_logic;
			 
			 -- debug
			 hit_happened : out std_logic;
			 
			 beat_int : out std_logic_vector(1 downto 0);
			 
          -- SIMULATION
          lt_signal, rt_signal : OUT std_logic_vector(23 downto 0)
          );
END part1;

ARCHITECTURE Behavior OF part1 IS
	-- ACCEL
	
	signal clk_scale : std_logic;
	signal X_ACC_lt : std_logic_vector(15 downto 0);
	signal Y_ACC_lt : std_logic_vector(15 downto 0);
	signal Z_ACC_lt : std_logic_vector(15 downto 0);
	signal beat_int_lt : std_logic_vector(1 downto 0);
	signal X_ACC_rt : std_logic_vector(15 downto 0);
	signal Y_ACC_rt : std_logic_vector(15 downto 0);
	signal Z_ACC_rt : std_logic_vector(15 downto 0);
	signal beat_int_rt : std_logic_vector(1 downto 0);
	
	-- SOUND
 
   signal lt_sin_addr, rt_sin_addr : integer := 0;
   signal left_data_out, right_data_out : std_logic_vector(23 downto 0);
   signal lt_sin_out, rt_sin_out : std_logic_vector(23 downto 0);
   signal left_full, right_full, left_empty, right_empty, lt_wr_en, rt_wr_en, lt_read_en, rt_read_en : std_logic;
   signal lt_raddr, rt_raddr : std_logic_vector(14 downto 0);
 
	signal lt_hit : std_logic;
	signal rt_hit : std_logic;
 
BEGIN

lt_signal <= lt_sin_out;
rt_signal <= rt_sin_out;

-- ACCEL COMPONENTS

scale_clock_map : scale_clock port map (
	clk_50Mhz => CLOCK_50,
	rst => low_RESET,
	clk_Hz => clk_scale
);


-- Left

Beat_Generator_lt_map : Beat_Generator port map (
	clk => clk_scale,
	rst => low_RESET,
	X_coordinate => X_ACC_lt,
	Y_coordinate => Y_Acc_lt,
	Z_coordinate => Z_Acc_lt,
	beat_en => lt_hit,
	beat_intensity => beat_int_lt
);

Accelerometer_Reader_lt_map : Accelerometer_Reader port map (
	clk => CLOCK_50,
	scl => scl_lt,
	sda => sda_lt,
	rst_n => low_RESET,
	X_Accel => X_Acc_lt,
	Y_Accel => Y_Acc_lt,
	Z_Accel => Z_Acc_lt
);

-- Right

Beat_Generator_rt_map : Beat_Generator port map (
	clk => clk_scale,
	rst => low_RESET,
	X_coordinate => X_ACC_rt,
	Y_coordinate => Y_Acc_rt,
	Z_coordinate => Z_Acc_rt,
	beat_en => rt_hit,
	beat_intensity => beat_int_rt
);

Accelerometer_Reader_rt_map : Accelerometer_Reader port map (
	clk => CLOCK_50,
	scl => scl_rt,
	sda => sda_rt,
	rst_n => low_RESET,
	X_Accel => X_Acc_rt,
	Y_Accel => Y_Acc_rt,
	Z_Accel => Z_Acc_rt
);

-- SOUND COMPONENTS

--hit_detect : process(lt_hit, rt_hit, RESET)
--begin
--	if (RESET = '1') then
--		hit_happened <= '0';
--	elsif (lt_hit = '1') then
--		hit_happened <= '1';
--	end if;
--end process;

de2lcd_map : de2lcd port map (
    reset => low_RESET, 
    clk_50Mhz => CLOCK_50, 
    LCD_RS => LCD_RS,
    LCD_E => LCD_E,
    LCD_ON => LCD_ON,
    RESET_LED =>RESET_LED,
    SEC_LED =>SEC_LED,
    LCD_RW =>LCD_RW,
    DATA_BUS =>DATA_BUS);

			
		--hit_happened <= lt_hit;	
	
flash_to_bram_map : flash_to_bram port map(
			CLOCK_50 => CLOCK_50,
			RESET => RESET,
			 load_ram => load_ram,
			 FL_addr => FL_addr,
			 FL_dq => FL_dq,
			 FL_ce => FL_ce,
			 FL_oe => FL_oe,
			 FL_ready => FL_ready,
			 FL_wr_en => FL_wr_en,
			 --rt_dout => rt_sin_out,
			 rt_raddr => rt_raddr, -- from sound selector)
          --lt_dout => lt_sin_out,
			 lt_raddr => lt_raddr
); -- fix up sound selector ports - get rid of flash stuff we arent using. bypass data in ports
			 

			 
			 

fifo_left_map : fifo 
           generic map ( FIFO_DATA_WIDTH => 24, 
               FIFO_BUFFER_SIZE => 1536)
           port map   ( rd_clk => CLOCK_50,
               wr_clk => CLOCK_50,
               reset => RESET,
               rd_en => lt_read_en,
               wr_en => lt_wr_en,
               din => lt_sin_out,
               dout => left_data_out,
               full => left_full,
               empty => left_empty);

fifo_right_map : fifo
            generic map ( FIFO_DATA_WIDTH => 24, 
               FIFO_BUFFER_SIZE => 1536)
            port map      ( rd_clk => CLOCK_50,
                wr_clk => CLOCK_50,
                reset => RESET,
                rd_en => rt_read_en,
                wr_en => rt_wr_en,
                din => rt_sin_out,
                dout => right_data_out,
                full => right_full,
                empty => right_empty);                                 
                                   
audio_controller_map : audio_controller port map (CLOCK_50 => CLOCK_50,
                  CLOCK_27 => CLOCK_27,
                  AUD_DACLRCK => AUD_DACLRCK,
                  AUD_ADCLRCK => AUD_ADCLRCK,
                  AUD_BCLK => AUD_BCLK,
                  AUD_ADCDAT => AUD_ADCDAT,
                  RESET => RESET,
                  I2C_SDAT => I2C_SDAT,
                  I2C_SCLK => I2C_SCLK,
                  AUD_DACDAT => AUD_DACDAT,
                  AUD_XCK => AUD_XCK,
                  lt_fifo_dout => left_data_out,
                  lt_fifo_rd_en => lt_read_en,
                  lt_fifo_empty => left_empty,
                  rt_fifo_dout => right_data_out,
                  rt_fifo_rd_en => rt_read_en,
                  rt_fifo_empty => right_empty,
                  --lt_signal => lt_signal,
                  --rt_signal => rt_signal
						write_ready_forced => write_ready_forced
						);

sound_select_map : sound_selector port map (
          CLOCK_50 => CLOCK_50,
          RESET => RESET,
          lt_hit => lt_hit, 
			 rt_hit => rt_hit,
          --lt_vol => lt_vol, rt_vol => rt_vol,
          lt_full => left_full,
          lt_sound => lt_sin_out,
          lt_wr_en => lt_wr_en,
          lt_addr => lt_raddr,
          rt_full => right_full,
          rt_sound => rt_sin_out,
			 
			 --FL_addr => FL_addr,
			 --FL_dq => FL_dq,
			 --FL_ce => FL_ce,
			 --FL_oe => FL_oe,
			 --FL_wr_en => FL_wr_en,
			 --FL_ready => FL_ready,
			 
          rt_wr_en => rt_wr_en,
          rt_addr => rt_raddr
   );
						
  
END Behavior;
