library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.textio.all;

entity Beat_Generator_TB is
	port(
  		clk: in std_logic;
		rst: in std_logic;
  		X_coordinate : in std_logic_vector (15 downto 0);
		Y_coordinate : in std_logic_vector (15 downto 0);
		Z_coordinate : in std_logic_vector (15 downto 0);
		beat_en: out std_logic;
  		beat_intensity: out std_logic_vector (1 downto 0));

end entity Beat_Generator_TB;

architecture behavioral of Beat_Generator_TB is
  
component Beat_Generator is
	port(
  		clk: in std_logic;
		rst: in std_logic;
  		X_coordinate : in std_logic_vector (15 downto 0);
		Y_coordinate : in std_logic_vector (15 downto 0);
		Z_coordinate : in std_logic_vector (15 downto 0);
		beat_en: out std_logic;
  		beat_intensity: out std_logic_vector (1 downto 0));
end component Beat_Generator;


	signal CLOCK_tb : std_logic :='0';
	signal HOLD_CLK: std_logic := '0';
	constant period : time := 2500 ns; --operating at 400kHz

	signal beat_en_tb, RESET_tb : std_logic;
	signal intensity_tb : std_logic_vector(1 downto 0);
     	signal sensor_x, sensor_y, sensor_z : std_logic_vector(15 downto 0); 

begin

  div_map : Beat_Generator port map 
  	(
  		clk => CLOCK_tb,
		rst => RESET_tb,
  		X_coordinate => sensor_x,
		Y_coordinate => sensor_y,
		Z_coordinate => sensor_z,
		beat_en => beat_en_tb,
  		beat_intensity => intensity_tb);

clk_process : process is
	begin
		CLOCK_tb <= '0';
		wait for (period/2);
		CLOCK_tb <= '1';
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
     file outfile: text open write_mode is "beat_result.out";
      
    begin
	RESET_tb <= '0';
	wait for (period*5); 
 	RESET_tb <= '1';
	wait for (period*5); 


      while not (endfile(infile1)) loop


       readline(infile1, my_line);
       read(my_line, sensor_x_temp);
       sensor_x <= std_logic_vector(to_signed(sensor_x_temp, 16));

       readline(infile2, my_line);
       read(my_line, sensor_y_temp);
       sensor_y <= std_logic_vector(to_signed(sensor_y_temp, 16)); 

       readline(infile3, my_line);
       read(my_line, sensor_z_temp);
       sensor_z <= std_logic_vector(to_signed(sensor_z_temp, 16)); 

wait for (period); 

	 write(my_line, sensor_x);
	 write(my_line, sensor_y);
	 write(my_line, sensor_z);
	 write(my_line, string'(" beat?"));
	 write(my_line, beat_en_tb);
	-- write(my_line, intensity_tb);
         writeline (outfile, my_line);


      end loop;
	
      HOLD_CLK <= '1';
	wait;
   -- file_close(infile);
   -- file_close(outfile);
      
  end process doing_it;

end architecture behavioral; 
