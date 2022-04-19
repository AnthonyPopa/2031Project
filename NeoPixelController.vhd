-- WS2812 communication interface starting point for
-- ECE 2031 final project spring 2022.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

LIBRARY LPM;
USE LPM.LPM_COMPONENTS.ALL;


entity NeoPixelController is

	port(
		clk_10M   : in   std_logic;
		resetn    : in   std_logic;
		io_write  : in   std_logic ;
		cs_addr   : in   std_logic ;
		cs_data   : in   std_logic ;
		all_pxls	 : in	  std_logic;
		sda       : out  std_logic;
		io_bus   : inout   std_logic_vector(15 downto 0)
		
	); 

end entity;

architecture internals of NeoPixelController is
	
	-- Signals for the RAM read and write addresses 
	signal ram_read_addr, ram_write_addr : std_logic_vector(7 downto 0);
	-- RAM write enable
	signal ram_we : std_logic;

	-- Signals for data coming out of memory
	signal ram_read_data : std_logic_vector(23 downto 0);
	-- Signal to store the current output pixel's color data
	signal pixel_buffer : std_logic_vector(23 downto 0);

	-- Signal SCOMP will write to before it gets stored into memory
	signal ram_write_buffer : std_logic_vector(23 downto 0);
	
	--read signals and state
	signal rama_read_data : std_logic_vector(23 downto 0);
	signal rama_read_buffer : std_logic_vector(15 downto 0);
	signal ram_read_enable : std_logic;
	
	
	--Signal to act as the input after the LMP tristate switch 
	signal ibus : std_logic_vector(15 downto 0);

	-- RAM interface state machine signals
	type write_states is (idle, storing);
	signal wstate: write_states;
	type increment_states is (init, increment);
	signal istate: increment_states;
	
	

	
begin

	rama_read_buffer <= rama_read_data(15 downto 11) & rama_read_data(23 downto 18) & rama_read_data(7 downto 3);
	ram_read_enable <= '1' when (io_write = '0' and cs_data = '1') else '0';
	-- This is the RAM that will store the pixel data.
	-- It is dual-ported.  SCOMP will access port "A",
	-- and the NeoPixel controller will access port "B".
	pixelRAM : altsyncram
	GENERIC MAP (
		address_reg_b => "CLOCK0",
		clock_enable_input_a => "BYPASS",
		clock_enable_input_b => "BYPASS",
		clock_enable_output_a => "BYPASS",
		clock_enable_output_b => "BYPASS",
		indata_reg_b => "CLOCK0",
		init_file => "pixeldata.mif",
		intended_device_family => "Cyclone V",
		lpm_type => "altsyncram",
		numwords_a => 256,
		numwords_b => 256,
		operation_mode => "BIDIR_DUAL_PORT",
		outdata_aclr_a => "NONE",
		outdata_aclr_b => "NONE",
		outdata_reg_a => "UNREGISTERED",
		outdata_reg_b => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		read_during_write_mode_mixed_ports => "OLD_DATA",
		read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
		read_during_write_mode_port_b => "NEW_DATA_NO_NBE_READ",
		widthad_a => 8,
		widthad_b => 8,
		width_a => 24,
		width_b => 24,
		width_byteena_a => 1,
		width_byteena_b => 1,
		wrcontrol_wraddress_reg_b => "CLOCK0"
	)
	PORT MAP (
		address_a => ram_write_addr, -- This connects the RAM-internal address_a to the Neopixel signal
		address_b => ram_read_addr, --This connects the RAM-internal address_b to the Neopixel Signal ram_read_addr
		clock0 => clk_10M, -- this connects the RAM clock to the 10 Mhz clock of the Neopixel
		data_a => ram_write_buffer, -- this connects the RAM write port to the buffer signal that receives data from SCOMP
		data_b => x"000000", -- This says that data_b can be whatever. In that format of course
		wren_a => ram_we, -- write enable saying that we can put things into RAM. We connect this to wren_a because a is out data in port
		wren_b => '0', -- this signal is always '0' because we never want to write to b, only read
		q_b => ram_read_data, -- this will be our output signal. and is always connected to the ram_read_addr
		q_a => rama_read_data 
	);

	 BUS_Switcher: lpm_bustri
    GENERIC MAP (
      lpm_width => 16
    )
	 
    PORT MAP (
      enabledt => ram_read_enable, -- We need to create a signal for SCOMP to say that we are looking to read from the neopixels, that will be connected to enabledt so that the data can flow from data[] to tridata to iodata
      tridata  => io_bus, -- this ibus is really the iobus from SCOMP, so we will connect that to the tridata of the lpm IOBUS
		enabletr => io_write, -- 
		result => ibus, --ibus is the data insignal
		data => rama_read_buffer --obus is the data outsignal
    );

	-- This process implements the NeoPixel protocol by
	-- using several counters to keep track of clock cycles,
	-- which pixel is being written to, and which bit within
	-- that data is being written. This is really just the output block
	process (clk_10M, resetn) 
		-- protocol timing values (in 100s of ns)
		constant t1h : integer := 8; -- high time for '1'
		constant t0h : integer := 3; -- high time for '0'
		constant ttot : integer := 12; -- total bit time
		
		constant npix : integer := 256; -- the number of neopixels we want to control, must match the size of the memory to function properly

		-- which bit in the 24 bits is being sent
		variable bit_count   : integer range 0 to 31; 
		-- counter to count through the bit encoding as in give it enough time to send the signal
		variable enc_count   : integer range 0 to 31;
		-- counter for the reset pulse
		variable reset_count : integer range 0 to 1000;
		-- Counter for the current pixel
		variable pixel_count : integer range 0 to 255;
		
		--READ VARIABLES
		variable read_en2 : std_logic := '0';
		
	begin
	
		
		if resetn = '0' then --if the EXTERNAl reset is 0, then that means that SCOMP wants to reset the neopixel controller. When does SCOMP want to do that? We should consider this the default state for the neopixel controller.
			-- reset all counters
			bit_count := 23;
			enc_count := 0;
			reset_count := 1000;
			-- set sda inactive
			sda <= '0';
		
		elsif (rising_edge(clk_10M)) then --on the rising edge of the clock, execute the below, but only if the above if statement doesn't go
				-- This IF block controls the various counters. Enc_count controls the counting for a specific bit, bit_count ensures that we increment the pixel count once we pass all 24 bits, pixel_count does what is does.
				if reset_count /= 0 then -- in reset/end-of-frame period
					-- during reset period, ensure other counters are reset
					pixel_count := 0; --We reset the pixel count because we are now going to start at the 0th pixel upon reset
					bit_count := 23; --Because there are 24 bits, and this is a decrementing counter
					enc_count := 0; --still not really sure what this does
					-- decrement the reset count
					reset_count := reset_count - 1; -- We will apparently perform this block for 1000 clock edges, then we will
					-- load data from memory
					pixel_buffer <= ram_read_data;
				
				else -- not in reset period (i.e. currently sending data)
					-- handle reaching end of a bit
					if enc_count = (ttot-1) then -- is end of this bit?
						enc_count := 0;
						-- shift to next bit
						pixel_buffer <= pixel_buffer(22 downto 0) & '0'; --resetting output
						if bit_count = 0 then -- is end of this pixels's data? once this gets to zero, that means when have finished the 24 bits for a pixel, so we start over at 23
							bit_count := 23; -- start a new pixel
							pixel_buffer <= ram_read_data; -- when we start a new pixel, we want to read in the data for the pixel from RAM
							if pixel_count = npix-1 then -- is end of all pixels?
								-- begin the reset period
								reset_count := 1000;
							else
								pixel_count := pixel_count + 1; --increment up the pixel list
							end if;
						else -- if there is still bits left for this pixel
							-- if not end of this pixel's data, decrement count
							bit_count := bit_count - 1;
						end if;
					else --still inside a byte
						-- within a bit, count to achieve correct pulse widths
						enc_count := enc_count + 1;
					end if;
				end if;
			
			
				-- This IF block controls the RAM read address to step through pixels
				if reset_count /= 0 then --if we are in the reset pulse we don't want to read from RAM
					ram_read_addr <= x"00";
				elsif (bit_count = 1) AND (enc_count = 0) then --if we are on the 2nd to last bit, and it is ending, we want to increment the read address. 
					-- increment the RAM address as each pixel ends
					ram_read_addr <= ram_read_addr + 1;
				end if;
			
			
				-- This IF block controls sda to create signals that match the output that would be comprehensible to the neopixel. We shouldn't need to edit this at all. 
				if reset_count > 0 then
					-- sda is 0 during reset/latch
					sda <= '0';
				elsif 
					-- sda is 1 in the first part of a bit.
					-- Length of first part depends on if bit is 1 or 0
					( (pixel_buffer(23) = '1') and (enc_count < t1h) )
					or
					( (pixel_buffer(23) = '0') and (enc_count < t0h) )
					then sda <= '1';
				else
					sda <= '0';
				end if;
		end if;
	end process;
	
	
	
	process(clk_10M, resetn, cs_addr, all_pxls)
	
		variable all_pxls_addr : integer range 0 to 255;

	begin
		-- For this implementation, saving the memory address
		-- doesn't require anything special.  Just latch it when
		-- SCOMP sends it.
		if resetn = '0' then
			ram_write_addr <= x"00";
		elsif rising_edge(clk_10M) then
			-- If SCOMP is writing to the address register...
			if (io_write = '1') and (cs_addr='1') then --iowrite and cs_addr are the signals from SCOMP that dictate that 1) its writing 2) its writing the address
				ram_write_addr <= ibus(7 downto 0);
			elsif (all_pxls = '1') then --if the SCOMP is saying it wants to write to all the neopixels
				case istate is --right now, this gives us the ability to increment through all the neopixel addresses
				when init => 
					ram_write_addr <= x"00";
					istate <= increment;
				when increment =>
					if (ram_write_addr >= x"ff") then
						istate <= init;
					else
						ram_write_addr <= ram_write_addr + 1;
					end if;
				end case;
			end if;
		end if;
	
	
		-- The sequnce of events needed to store data into memory will be
		-- implemented with a state machine.
		-- Although there are ways to more simply connect SCOMP's I/O system
		-- to an altsyncram module, it would only work with under specific 
		-- circumstances, and would be limited to just simple writes.  Since
		-- you will probably want to do more complicated things, this is an
		-- example of something that could be extended to do more complicated
		-- things.
		-- Note that 'ram_we' is *not* implemented as a Moore output of this state
		-- machine, because Moore outputs are susceptible to glitches, and
		-- that's a bad thing for memory control signals.
		if resetn = '0' then
			wstate <= idle;
			ram_we <= '0';
			ram_write_buffer <= x"000000";
			-- Note that resetting this device does NOT clear the memory.
			-- Clearing memory would require cycling through each address
			-- and setting them all to 0.
		elsif rising_edge(clk_10M) then
			case wstate is --write state
			when idle =>
				if ((io_write = '1') and ((cs_data='1') or (all_pxls = '1'))) then
					if (all_pxls = '1') then
						ram_write_buffer <= ibus(10 downto 5) & "00" & ibus(15 downto 11) & "000" & ibus(4 downto 0) & "000"; --data in to the buffer
						ram_we <= '1';
						if (ram_write_addr > x"ff") then
							wstate <= storing;
						end if;
					else
						-- latch the current data into the temporary storage register,
						-- because this is the only time it'll be available.
						-- Convert RGB565 to 24-bit color
						ram_write_buffer <= ibus(10 downto 5) & "00" & ibus(15 downto 11) & "000" & ibus(4 downto 0) & "000";
						-- can raise ram_we on the upcoming transition, because data
						-- won't be stored until next clock cycle.
						ram_we <= '1';
						--Change state
						wstate <= storing;
					end if;
				end if;
			when storing =>
				-- All that's needed here is to lower ram_we.  The RAM will be
				-- storing data on this clock edge, so ram_we can go low at the
				-- same time.
				ram_we <= '0';
				wstate <= idle;
			when others =>
				wstate <= idle;
			end case;
		end if;
	end process;

	
	
end internals;
