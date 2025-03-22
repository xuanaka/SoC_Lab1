library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_changeupball is
end tb_changeupball;

architecture behavior of tb_changeupball is

    -- 信號定義
    signal i_clk    : std_logic := '0';          
    signal i_rst    : std_logic := '0';         
    signal i_bl     : std_logic := '0';  
    signal i_br     : std_logic := '0';  
    signal o_led    : std_logic_vector(7 downto 0);  

    -- 時間常數
    constant clk_period : time := 10 ns;  -- 設定時鐘週期為10ns

begin

    -- 實例化 changeupball 實體
    uut: entity work.changeupball
        port map (
            i_clk => i_clk,
            i_rst => i_rst,
            i_bl => i_bl,
            i_br => i_br,
            o_led => o_led
        );

    -- 時鐘生成
    clk_process :process
    begin
        i_clk <= '0';
        wait for clk_period/2;
        i_clk <= '1';
        wait for clk_period/2;
    end process;

    -- 測試序列
    stim_proc: process
    begin    
        -- 初始重置
        i_rst <= '1';
        wait for clk_period*2;
        i_rst <= '0';

        -- 模擬開始
        -- 第1輪移動
        wait for clk_period*10;
        i_bl <= '1';   -- 開始左移
        wait for clk_period*10;
        i_bl <= '0';   -- 停止左移
        wait for clk_period*10;

        -- 第2輪移動
        i_br <= '1';   -- 開始右移
        wait for clk_period*10;
        i_br <= '0';   -- 停止右移
        wait for clk_period*10;

        -- 模擬球碰撞邊界
        wait for clk_period*5;
        i_bl <= '1';   -- 左邊界
        wait for clk_period*10;
        i_bl <= '0';   -- 停止左邊界

        wait for clk_period*5;
        i_br <= '1';   -- 右邊界
        wait for clk_period*10;
        i_br <= '0';   -- 停止右邊界

        -- 測試結束
        wait for clk_period*10;
        assert false report "Test complete" severity note;
        wait;
    end process;

end behavior;
