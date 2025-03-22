library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_pingpang is
end tb_pingpang;

architecture sim of tb_pingpang is

    -- Component declaration
    component pingpang
        port (
            i_clk    : in std_logic;
            i_rst    : in std_logic;
            i_bl     : in std_logic;
            i_br     : in std_logic;
            o_led    : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Testbench signals
    signal i_clk   : std_logic := '0';
    signal i_rst   : std_logic := '0';
    signal i_bl    : std_logic := '0';
    signal i_br    : std_logic := '0';
    signal o_led   : std_logic_vector(7 downto 0);

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: pingpang
        port map (
            i_clk => i_clk,
            i_rst => i_rst,
            i_bl  => i_bl,
            i_br  => i_br,
            o_led => o_led
        );

    -- Clock generation process
    clk_process: process
    begin
        while true loop
            i_clk <= '0';
            wait for clk_period / 2;
            i_clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Reset the system
        i_rst <= '1';
        wait for clk_period * 5;
        i_rst <= '0';

        -- Test case 1: Transition from state "000" to "001"
        i_br <= '1';
        wait for clk_period * 20;

        -- Test case 2: Transition to state "100" with i_bl = '1' and shift_reg /= "10000000"
        i_br <= '0';
        i_bl <= '1';
        wait for clk_period * 20;

        -- Test case 3: Transition to state "010" with i_br = '1' and shift_reg = "00000001"
        i_bl <= '0';
        i_br <= '1';
        wait for clk_period * 20;

        -- Test case 4: Increment RP and return to "000" after RP >= "1001"
        for i in 0 to 10 loop
            i_br <= '1';
            wait for clk_period * 10;
        end loop;
        i_br <= '0';

        -- Test case 5: Increment LP and return to "000" after LP >= "1001"
        for i in 0 to 10 loop
            --i_bl <= '1';
            wait for clk_period * 10;
        end loop;
        --i_bl <= '0';

        -- Stop simulation
        wait for 1 ms;
        wait;
    end process;

end sim;