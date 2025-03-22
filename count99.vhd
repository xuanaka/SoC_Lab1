library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Dual4DigitCounter is
    Port (
        clk        : in  STD_LOGIC;                      -- 時鐘訊號
        reset      : in  STD_LOGIC;                      -- 重置訊號
        enable1    : in  STD_LOGIC;                      -- 第一計數器啟動訊號
        enable2    : in  STD_LOGIC;                      -- 第二計數器啟動訊號
        up1        : in  STD_LOGIC;                      -- 第一計數器方向，高為加，低為減
        up2        : in  STD_LOGIC;                      -- 第二計數器方向，高為加，低為減
        start1     : in  INTEGER range 0 to 9999;        -- 第一計數器起始值
        end1       : in  INTEGER range 0 to 9999;        -- 第一計數器結束值
        start2     : in  INTEGER range 0 to 9999;        -- 第二計數器起始值
        end2       : in  INTEGER range 0 to 9999;        -- 第二計數器結束值
        count1     : out INTEGER range 0 to 9999;        -- 第一計數器當前值
        count2     : out INTEGER range 0 to 9999         -- 第二計數器當前值
    );
end Dual4DigitCounter;

architecture Behavioral of Dual4DigitCounter is
    signal current_count1 : INTEGER range 0 to 9999; -- 第一計數器內部值
    signal current_count2 : INTEGER range 0 to 9999; -- 第二計數器內部值
begin
    process(clk, reset)
    begin
        if reset = '1' then
            -- 重置兩個計數器為各自的起始值
            current_count1 <= start1;
            current_count2 <= start2;
        elsif rising_edge(clk) then
            -- 第一計數器邏輯
            if enable1 = '1' then
                if up1 = '1' then
                    if current_count1 + 1 > end1 then
                        current_count1 <= start1; -- 回到起始值
                    else
                        current_count1 <= current_count1 + 1;
                    end if;
                else
                    if current_count1 - 1 < start1 then
                        current_count1 <= end1; -- 回到結束值
                    else
                        current_count1 <= current_count1 - 1;
                    end if;
                end if;
            end if;

            -- 第二計數器邏輯
            if enable2 = '1' then
                if up2 = '1' then
                    if current_count2 + 1 > end2 then
                        current_count2 <= start2; -- 回到起始值
                    else
                        current_count2 <= current_count2 + 1;
                    end if;
                else
                    if current_count2 - 1 < start2 then
                        current_count2 <= end2; -- 回到結束值
                    else
                        current_count2 <= current_count2 - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- 輸出計數值
    count1 <= current_count1;
    count2 <= current_count2;
end Behavioral;
