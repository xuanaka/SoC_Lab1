-- UpDownCounter.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UpDownCounter is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        up_down : in STD_LOGIC; -- 用於選擇加/減計數：'1'表示加，'0'表示減
        count : out STD_LOGIC_VECTOR (3 downto 0) -- 4-bit輸出，顯示計數結果
    );
end UpDownCounter;

architecture Behavioral of UpDownCounter is
    signal cnt : STD_LOGIC_VECTOR(3 downto 0) :="0000"; -- 初始計數值為0
begin
    process(clk, reset)
    begin
        if reset='1' then
            cnt<="0000"; -- 當 reset 被觸發時，計數歸零
        elsif rising_edge(clk) then
            if up_down='1' then -- 加計數
                if cnt="1001" then -- 當計數到9時
                    cnt<="0000"; -- 從頭開始計數
                else
                    cnt<=cnt+1; -- 正常加計數
                end if;
            else -- 減計數
                if cnt="0000" then -- 當計數到0時
                    cnt<="1001"; -- 回到9
                else
                    cnt<=cnt-1; -- 正常減計數
                end if;
            end if;
        end if;
    end process;
    count<=cnt; -- 將內部計數傳送到輸出
end Behavioral;
