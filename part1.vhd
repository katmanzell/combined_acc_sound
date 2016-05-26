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
			 
			 rt_hit : IN STD_LOGIC;
			 
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
			 scl : out std_logic;
			 sda : inout std_logic;
			 
			 -- debug
			 hit_happened : out std_logic;
			 
          -- SIMULATION
          lt_signal, rt_signal : OUT std_logic_vector(23 downto 0)
          );
END part1;

ARCHITECTURE Behavior OF part1 IS
 
   signal lt_sin_addr, rt_sin_addr : integer := 0;
   signal left_data_out, right_data_out : std_logic_vector(23 downto 0);
   signal lt_sin_out, rt_sin_out : std_logic_vector(23 downto 0);
   signal left_full, right_full, left_empty, right_empty, lt_wr_en, rt_wr_en, lt_read_en, rt_read_en : std_logic;
   signal lt_raddr, rt_raddr : std_logic_vector(14 downto 0);
 
	signal lt_hit : std_logic;
 
BEGIN

lt_signal <= lt_sin_out;
rt_signal <= rt_sin_out;


--not_rese
hit_detect : process(lt_hit, rt_hit, RESET)
begin
	if (RESET = '1') then
		hit_happened <= '0';
	elsif (lt_hit = '1') then
		hit_happened <= '1';
	end if;
end process;

sound_connect_map : Sound_Connect PORT map (
				clk => CLOCK_50,
				rst_n => low_RESET,
				beat => lt_hit,
				--beat_int 
				scl => scl,
				sda => sda
			);
	
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
			 rt_dout => rt_sin_out,
			 rt_raddr => rt_raddr, -- from sound selector)
          lt_dout => lt_sin_out,
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
          --lt_sound => lt_sin_out,
          lt_wr_en => lt_wr_en,
          lt_addr => lt_raddr,
          rt_full => right_full,
          --rt_sound => rt_sin_out,
			 
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
