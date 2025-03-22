library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Test_Dual4DigitCounter is
end Test_Dual4DigitCounter;

architecture Behavioral of Test_Dual4DigitCounter is
    -- 宣告元件
    component Dual4DigitCounter
        Port (
            clk        : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            enable1    : in  STD_LOGIC;
            enable2    : in  STD_LOGIC;
            up1        : in  STD_LOGIC;
            up2        : in  STD_LOGIC;
            start1     : in  INTEGER range 0 to 9999;
            end1       : in  INTEGER range 0 to 9999;
            start2     : in  INTEGER range 0 to 9999;
            end2       : in  INTEGER range 0 to 9999;
            count1     : out INTEGER range 0 to 9999;
            count2     : out INTEGER range 0 to 9999
        );
    end component;

    -- 測試訊號
    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '0';
    signal enable1  : STD_LOGIC := '1';
    signal enable2  : STD_LOGIC := '1';
    signal up1      : STD_LOGIC := '1';
    signal up2      : STD_LOGIC := '0';
    signal start1   : INTEGER := 3;
    signal end1     : INTEGER := 8;
    signal start2   : INTEGER := 7;
    signal end2     : INTEGER := 15;
    signal count1   : INTEGER range 0 to 9999;
    signal count2   : INTEGER range 0 to 9999;

begin
    -- 實例化雙計數器
    UUT: Dual4DigitCounter
        Port map (
            clk        => clk,
            reset      => reset,
            enable1    => enable1,
            enable2    => enable2,
            up1        => up1,
            up2        => up2,
            start1     => start1,
            end1       => end1,
            start2     => start2,
            end2       => end2,
            count1     => count1,
            count2     => count2
        );

    -- 產生時鐘訊號
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- 測試過程
    stim_proc: process
    begin
        -- 初始化，啟動計數
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- 測試第一計數器加計數
        up1 <= '1';
        enable1 <= '1';
        wait for 100 ns;
        up1 <= '0';

        -- 測試第二計數器減計數
        up2 <= '0';
        enable2 <= '1';
        wait for 100 ns;

        -- 測試重置
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        
        wait for 50 ns;
        up1 <= '1';
        up2 <= '1';
        
        -- 停止模擬
        wait;
    end process;
end Behavioral;
