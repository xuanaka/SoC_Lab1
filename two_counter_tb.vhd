library IEEE;
use IEEE.std_logic_1164.all;

entity tb_two_counter is
end tb_two_counter;

architecture Behavioral of tb_two_counter is


    signal i_clk    : std_logic := '0';
    signal i_rst    : std_logic := '0';
    signal o_count1 : std_logic_vector(3 downto 0);
    signal o_count2 : std_logic_vector(3 downto 0);

    component two_counter
        port (
            i_clk    : in std_logic;
            i_rst    : in std_logic;
            o_count1 : out std_logic_vector(3 downto 0);
            o_count2 : out std_logic_vector(3 downto 0)
        );
    end component;

begin

    uut: two_counter
        port map (
            i_clk    => i_clk,
            i_rst    => i_rst,
            o_count1 => o_count1,
            o_count2 => o_count2
        );


    clk_process: process
    begin
        while true loop
            i_clk <= '0';
            wait for 5 ns;
            i_clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    stimulus_process: process
    begin
        i_rst <= '0';
        wait for 20 ns; 
        i_rst <= '1';

        wait for 500 ns;

        wait;
    end process;

end Behavioral;
