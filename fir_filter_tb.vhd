library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity fir_filter_tb is
end entity fir_filter_tb;

architecture sim of fir_filter_tb is

    -- Component under test
    component fir_filter_873tap is
        port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            sample_in   : in  STD_LOGIC_VECTOR(15 downto 0);
            valid_in    : in  STD_LOGIC;
            sample_out  : out STD_LOGIC_VECTOR(15 downto 0);
            valid_out   : out STD_LOGIC
        );
    end component;

    signal clk        : STD_LOGIC := '0';
    signal reset       : STD_LOGIC := '1';
    signal sample_in    : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal valid_in     : STD_LOGIC := '0';
    signal sample_out    : STD_LOGIC_VECTOR(15 downto 0);
    signal valid_out    : STD_LOGIC;

    constant CLK_PERIOD : time := 20 ns;  -- 50 MHz clock

    -- File handles
    file input_file    : text open read_mode is "test_input_q15.txt";
    file expected_file  : text open read_mode is "expected_output_q15.txt";
	file actual_output_file : text open write_mode is "actual_output_q15.txt";


begin

    -- Instantiate the filter under test
    uut: fir_filter_873tap
        port map (
            clk        => clk,
            reset      => reset,
            sample_in   => sample_in,
            valid_in    => valid_in,
            sample_out  => sample_out,
            valid_out   => valid_out
        );

    -- Clock generation: toggle every half period, forever
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus + comparison process
    stimulus_process: process
        variable input_line, expected_line : line;
        variable input_val, expected_val : integer;
        variable sample_count : integer := 0;
        variable errors : integer := 0;
		variable output_line : line;
		variable prev_expected : integer := 0;
		variable first_sample : boolean := true;
    begin
        -- Reset pulse
        reset <= '1';
        wait for CLK_PERIOD * 5;
        reset <= '0';
        wait for CLK_PERIOD * 2;
		
		
		
        while not endfile(input_file) loop
            -- Read one input sample
            readline(input_file, input_line);
            read(input_line, input_val);

            -- Drive the sample into the filter
            sample_in <= std_logic_vector(to_signed(input_val, 16));
            valid_in <= '1';
            wait for CLK_PERIOD;
            valid_in <= '0';

            -- Wait for valid_out to go high (filter finishes 873 MAC cycles)
            wait until valid_out = '1';
			
			write(output_line, to_integer(signed(sample_out)));
			writeline(actual_output_file, output_line);

            -- Read corresponding expected value and compare
            readline(expected_file, expected_line);
			read(expected_line, expected_val);

			if not first_sample then
				if sample_count >= 436 then
					if abs(to_integer(signed(sample_out)) - prev_expected) > 5 then
						errors := errors + 1;
						report "Mismatch at sample " & integer'image(sample_count) &
							   ": got " & integer'image(to_integer(signed(sample_out))) &
							   ", expected " & integer'image(prev_expected)
							   severity warning;
					end if;
				end if;
			else
				first_sample := false;
			end if;

			prev_expected := expected_val;
            sample_count := sample_count + 1;
            wait for CLK_PERIOD;
        end loop;

        report "Simulation complete. Total samples: " & integer'image(sample_count) &
               ", Errors: " & integer'image(errors)
               severity note;

        wait;  -- stop simulation
    end process;

end architecture sim;