library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
USE work.altera_drums.all;
use std.textio.all;

entity part1_tb is
end entity;

architecture tb of part1_tb is

component part1 IS
   PORT ( 
CLOCK_50, CLOCK_27, RESET, AUD_DACLRCK   : IN    STD_LOGIC;
low_RESET :in std_logic;
    load_ram : in std_logic;
          AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT  : IN    STD_LOGIC;
          I2C_SDAT                      : INOUT STD_LOGIC;
          I2C_SCLK, AUD_DACDAT, AUD_XCK : OUT   STD_LOGIC;
          --lt_hit : in std_logic;
	  --rt_hit : IN STD_LOGIC;

--SIMULATION
lt_hit_sim, rt_hit_sim : OUT STD_LOGIC;
			 
			 --pins for de2lcd
          LCD_RS, LCD_E, LCD_ON, RESET_LED, SEC_LED        : OUT    STD_LOGIC;
          LCD_RW                        : BUFFER STD_LOGIC;
          DATA_BUS                : INOUT    STD_LOGIC_VECTOR(7 DOWNTO 0);
			 
			 
			 --Forcing write ready
			 write_ready_forced : in std_logic;
			 
			------------------------------------------------------------------------------------
			 --flash reader signals
			 --Address
			-- FL_addr : out std_logic_vector(22 downto 0);
			 --Data
			-- FL_dq : in std_logic_vector(7 downto 0);
			 --Chip Enable
			-- FL_ce : out std_logic;
			 --output enable
			-- FL_oe : out std_logic;
			 --ready/busy
			-- FL_ready : in std_logic;
			 --write enable
			-- FL_wr_en : out std_logic; -- set always high because we never want to write over it
			 --------------------------------------------------------------------------------------
			 
			 --Sound Connect
			 scl_lt : out std_logic;
			 sda_lt : inout std_logic;
			 
			 scl_rt : out std_logic;
			 sda_rt : inout std_logic;
			 
-- SIMULATION
lt_signal, rt_signal : OUT std_logic_vector(23 downto 0);

--SIMULATION
X_ACC_rt_sim, Y_ACC_rt_sim,Z_ACC_rt_sim, X_ACC_lt_sim, Y_ACC_lt_sim,Z_ACC_lt_sim : IN std_logic_vector(15 downto 0)
  );
end component part1;


signal AUD_DACLRCK , AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT  : STD_LOGIC;
signal I2C_SDAT                      :  STD_LOGIC;
signal I2C_SCLK, AUD_DACDAT, AUD_XCK :  STD_LOGIC;

signal lt_hit_sim, rt_hit_sim : STD_LOGIC;
signal lt_signal, rt_signal : std_logic_vector(23 downto 0);


signal write_ready_forced : std_logic := '1';


	signal CLOCK : std_logic :='0';
	signal HOLD_CLK: std_logic := '0';
	constant period : time := 2500 ns; --operating at 400kHz

	signal RESET, low_RESET: std_logic; --beat_en_tb, 
	--signal intensity_tb : std_logic_vector(1 downto 0);
     	signal sensor_xR, sensor_yR, sensor_zR : std_logic_vector(15 downto 0); 
	signal sensor_xL, sensor_yL, sensor_zL : std_logic_vector(15 downto 0); 

begin

    
part1_map : part1 port map (
			CLOCK_50 => CLOCK, CLOCK_27 => CLOCK, RESET => RESET, 
                        low_RESET => low_RESET,
			AUD_DACLRCK => AUD_DACLRCK,
			load_ram => '1',
                        AUD_ADCLRCK => AUD_ADCLRCK, 
			AUD_BCLK => AUD_BCLK, 
			AUD_ADCDAT => AUD_ADCDAT,
                        I2C_SDAT => I2C_SDAT,
                        I2C_SCLK => I2C_SCLK, 
			AUD_DACDAT => AUD_DACDAT, 
			AUD_XCK => AUD_XCK,

                        lt_hit_sim => lt_hit_sim,
                        rt_hit_sim => rt_hit_sim,

			write_ready_forced => write_ready_forced,
			lt_signal => lt_signal, 
			rt_signal => rt_signal,
X_ACC_rt_sim => sensor_xR, 
Y_ACC_rt_sim => sensor_yR, 
Z_ACC_rt_sim => sensor_zR,  
X_ACC_lt_sim => sensor_xL,  
Y_ACC_lt_sim => sensor_yL, 
Z_ACC_lt_sim => sensor_ZL
          );
	

clk_process : process is
	begin
		CLOCK <= '0';
		wait for (period/2);
		CLOCK <= '1';
		wait for (period/2);
		if(HOLD_CLK = '1') then
			wait;
		end if;
end process clk_process;

    
  doing_it:  process is
     variable sensor_x_temp, sensor_y_temp, sensor_z_temp : integer;
     variable my_line : line;

     file infile1: text open read_mode is "x.txt";
     file infile2: text open read_mode is "y.txt";
     file infile3: text open read_mode is "z.txt";
     file outfile: text open write_mode is "result.out";
      
    begin
	RESET <= '1';
        low_RESET <= '0';
	wait for (period*5); 
 	RESET <= '0';
 	low_RESET <= '1';
	wait for (period*5); 

      while not (endfile(infile1)) loop


       readline(infile1, my_line);
       read(my_line, sensor_x_temp);
       sensor_xR <= std_logic_vector(to_signed(sensor_x_temp, 16));
sensor_xL <= std_logic_vector(to_signed(sensor_x_temp, 16));

       readline(infile2, my_line);
       read(my_line, sensor_y_temp);
       sensor_yR <= std_logic_vector(to_signed(sensor_y_temp, 16)); 
sensor_yL <= std_logic_vector(to_signed(sensor_x_temp, 16));

       readline(infile3, my_line);
       read(my_line, sensor_z_temp);
       sensor_zR <= std_logic_vector(to_signed(sensor_z_temp, 16)); 
sensor_zL <= std_logic_vector(to_signed(sensor_x_temp, 16));

wait for (period); 

	 write(my_line, sensor_xR);
	 write(my_line, sensor_yR);
	 write(my_line, sensor_zR);
	 write(my_line, string'(" right beat?"));
	 write(my_line, rt_hit_sim);
         writeline (outfile, my_line);



      end loop;
	
      HOLD_CLK <= '1';
	wait;
   -- file_close(infile);
   -- file_close(outfile);
      
  end process doing_it;
    
   
end architecture tb;