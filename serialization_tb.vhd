library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Pingpong_tb is
end entity;

architecture sim of Pingpong_tb is
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal btn1      : std_logic := '0';
    signal btn2      : std_logic := '0';
    signal gpio_wire : std_logic;
    signal led1      : std_logic_vector(7 downto 0);
    signal led2      : std_logic_vector(7 downto 0);

    -- 宣告一次即可
    component Pingpong_gpio
        port (
            i_clk   : in std_logic;
            i_rst   : in std_logic;
            i_btn   : in std_logic;
            io_gpio : inout std_logic;
            o_led   : out std_logic_vector(7 downto 0)
        );
    end component;

begin

    -- 時鐘產生
    clk_process: process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- 左邊板
    U1: Pingpong_gpio
        port map (
            i_clk   => clk,
            i_rst   => rst,
            i_btn   => btn1,
            io_gpio => gpio_wire,
            o_led   => led1
        );

    -- 右邊板
    U2: Pingpong_gpio
        port map (
            i_clk   => clk,
            i_rst   => rst,
            i_btn   => btn2,
            io_gpio => gpio_wire,
            o_led   => led2
        );

    -- 測試腳本
    stim_proc: process
    begin
        wait for 50 ns;
        rst <= '0';

        -- 左邊按鍵發球
        wait for 100 ns;
        btn1 <= '1';
        wait for 20 ns;
        btn1 <= '0';

        -- 等球到右邊擊球
        wait for 750 ns;
        btn2 <= '1';
        wait for 20 ns;
        btn2 <= '0';

        -- 等球回左邊擊球
        wait for 1000 ns;
        btn1 <= '1';
        wait for 20 ns;
        btn1 <= '0';

        -- 模擬結束
        wait for 5000 ns;
        assert false report "Simulation End" severity note;
        wait;
    end process;

end architecture;
