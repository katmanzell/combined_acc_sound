LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_signed.all;
USE work.altera_drums.all;
USE work.sounds.all;
use ieee.numeric_std.all;

ENTITY block_ram IS
  PORT ( 
          CLOCK_50 : IN STD_LOGIC;

          dout : out std_logic_vector(23 downto 0);
			 
			 din : in std_logic_vector(23 downto 0);
			 
			 wr_en : in std_logic;
			 
			 waddr : in std_logic_vector(14 downto 0);
			 
			 raddr : in std_logic_vector(14 downto 0)
			 
        );
END ENTITY block_ram;

ARCHITECTURE behavioral OF block_ram IS

type mem_type is array(0 to 32768) of std_logic_vector(23 downto 0);

signal mem : mem_type;
signal rd_addr : std_logic_vector(14 downto 0);


begin


dout <= mem(conv_integer(rd_addr));

process (CLOCK_50)

begin

	if(rising_edge(CLOCK_50)) then
	
		rd_addr <= raddr;
		
		if(wr_en = '1') then
			mem(conv_integer(waddr)) <= din;
		end if;
	end if;
end process;

end behavioral;







