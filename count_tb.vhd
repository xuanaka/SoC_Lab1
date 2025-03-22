-- UpDownCounter_tb.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UpDownCounter_tb is
end UpDownCounter_tb;

architecture Behavioral of UpDownCounter_tb is

    -- 設置信號來模擬 UpDownCounter 的輸入與輸出
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal up_down : STD_LOGIC := '1'; -- 初始設置為上數
    signal count : STD_LOGIC_VECTOR (3 downto 0);

    -- 引用被測模組
    component UpDownCounter
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            up_down : in STD_LOGIC;
            count : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

begin
    -- 實例化被測模組
    uut: UpDownCounter Port map (
        clk=>clk,
        reset=>reset,
        up_down=>up_down,
        count=>count
    );

    -- 時鐘過程，每 10 ns 切換一次時鐘，模擬 100 MHz 時鐘
    clk_process :process
    begin
        clk<='0';
        wait for 10 ns;
        clk<='1';
        wait for 10 ns;
    end process;

    -- 測試過程
    stim_proc: process
    begin
        -- 重設計數器
        reset<='1';
        wait for 20 ns;
        reset<='0';

        -- 測試上數功能
        up_down<='1';
        wait for 200 ns; -- 等待一段時間觀察計數變化

        -- 測試下數功能
        up_down<='0';
        wait for 100 ns; -- 等待一段時間觀察計數變化
        -- 完成測試
        wait;
    end process;

end Behavioral;
