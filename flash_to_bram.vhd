LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_signed.all;
USE work.altera_drums.all;
USE work.sounds.all;
use ieee.numeric_std.all;

ENTITY flash_to_bram IS
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
END ENTITY flash_to_bram;

ARCHITECTURE behavioral OF flash_to_bram IS

signal rt_wr_en : std_logic;
signal lt_wr_en : std_logic;
signal fl_data : std_logic_vector(23 downto 0); 
signal rt_wr_addr, lt_wr_addr : std_logic_vector(14 downto 0);

constant MAX : integer := 32768;

begin


blockram_rt_map : block_ram port map (
													CLOCK_50 => CLOCK_50,
													dout => rt_dout,
													din => fl_data,
													wr_en => rt_wr_en,
													waddr => rt_wr_addr,
													raddr => rt_raddr
												);

												
blockram_lt_map : block_ram port map (
													CLOCK_50 => CLOCK_50,
													dout => lt_dout,
													din => fl_data,
													wr_en => lt_wr_en,
													waddr => lt_wr_addr,
													raddr => lt_raddr
												);
												

proc : process (CLOCK_50, RESET, load_ram)

variable	addr_inc : integer := 0;
variable byte_count : integer := 0;
variable flash_data : std_logic_vector(23 downto 0);
	begin
	-- come back 
	if(RESET = '1') then
		FL_addr <= (others => '0');
		FL_wr_en <= '1';
		FL_ce <= '1';
		FL_oe <= '0';
	
		addr_inc := 0;
	
	elsif(rising_edge(CLOCK_50)) then
		
		-- add fifo wr signals to sync with data read
		if(load_ram = '1' and addr_inc < MAX) then
	
			FL_addr <= std_logic_vector(to_unsigned(addr_inc, FL_addr'length));
			
			--if(FL_ready = '1') then
					--data <= FL_dq;
			--end if;
			
			lt_wr_en <= '0';
			rt_wr_en <= '0';
			if(byte_count = 1) then
				flash_data(23 downto 16) := FL_dq;
			elsif(byte_count = 2) then 
				flash_data(15 downto 8) := FL_dq;
			elsif(byte_count = 3) then
				flash_data(7 downto 0) := FL_dq;
			elsif(byte_count = 4) then
				lt_wr_en <= '1';
				rt_wr_en <= '1';
				fl_data <= flash_data; 
				byte_count := 0;
			end if;	
			
			byte_count := byte_count + 1;
			addr_inc := addr_inc + 1;
			FL_ce <= '0';
		else
			FL_ce <= '1';
			addr_inc := 0;
			
		end if;
--	else
---		FL_ce <= '1';
		
	end if;
		
end process;

end architecture behavioral;




