library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pp_game is
    port (
                i_clk      : IN STD_LOGIC;              -- 100MHz時鐘輸入
		        i_rst      : IN STD_LOGIC;              -- 重置信號
		        i_sw_l     : IN STD_LOGIC;
		        i_sw_r     : IN STD_LOGIC;
                o_red      : OUT STD_LOGIC_VECTOR(3 downto 0);  -- 紅色信號輸出
                o_green    : OUT STD_LOGIC_VECTOR(3 downto 0);  -- 綠色信號輸出
                o_blue     : OUT STD_LOGIC_VECTOR(3 downto 0);  -- 藍色信號輸出
                h_sync   : OUT STD_LOGIC;             -- 水平同步信號輸出
                v_sync   : OUT STD_LOGIC              -- 垂直同步信號輸出
    );
end pp_game;

architecture Behavioral of pp_game is
component VGA  --VGA 是你自己另外設計的一個模組，用來產生圖像。
     generic(
                H_RES     : INTEGER  := 800;
                H_FP      : INTEGER  := 56;
                H_SYNC    : INTEGER  := 120;
                H_BP      : INTEGER  := 64;
                H_POL     : STD_LOGIC := '1';
	
                V_RES     : INTEGER  := 600;
                V_FP      : INTEGER  := 37;
                V_SYNC    : INTEGER  := 6;
                V_BP      : INTEGER  := 23;
                V_POL     : STD_LOGIC := '1'
    );
     port (
                i_clk      : IN STD_LOGIC;              -- 100MHz時鐘輸入
		        i_rst      : IN STD_LOGIC;              -- 重置信號
                o_red      : OUT STD_LOGIC_VECTOR(3 downto 0);  -- 紅色信號輸出
                o_green    : OUT STD_LOGIC_VECTOR(3 downto 0);  -- 綠色信號輸出
                o_blue     : OUT STD_LOGIC_VECTOR(3 downto 0);  -- 藍色信號輸出
                o_h_sync   : OUT STD_LOGIC;             -- 水平同步信號輸出
                o_v_sync   : OUT STD_LOGIC;              -- 垂直同步信號輸出
                bar_l_x    : IN INTEGER;
                bar_l_y    : IN INTEGER;
                bar_r_x    : IN INTEGER;
                bar_r_y    : IN INTEGER;
                circle_center_x : IN INTEGER;
                circle_center_y : IN INTEGER
    );
end component;

signal bar_l_x    : INTEGER := 0;
signal bar_l_y    : INTEGER RANGE 0 TO 480 := 0;
signal bar_r_x    : INTEGER := 785;
signal bar_r_y    : INTEGER RANGE 0 TO 480 := 0;
signal bar_dy     : INTEGER := 10;
signal circle_center_x : INTEGER RANGE -10 TO 800 := 0;
signal circle_center_y : INTEGER RANGE -10 TO 600 := 0;
signal ball_dx    : INTEGER := 2;
signal ball_dy    : INTEGER := 2;
signal ball_state : std_logic_vector (1 downto 0);
signal div_clk    : std_logic := '0';
signal counter    : std_logic_vector(24 downto 0);
constant BALL_RADIUS : INTEGER := 10;

begin
    -- 降速產生 div_clk
    process (i_clk, i_rst)
    begin
        if i_rst = '1' then
            counter <= (others => '0');
            div_clk <= '0';
        elsif rising_edge(i_clk) then
            counter <= counter + 1;
            div_clk <= counter(20);  -- 調整速度用
        end if;
    end process;
    
    -- 球拍移動控制
    process(i_clk, div_clk, i_rst)
    begin
        if i_rst = '1' then
            bar_r_y <= 0;
        elsif rising_edge(div_clk) then
            -- 右邊球拍
            if (i_sw_r = '1' and bar_r_y < 480) then
                bar_r_y <= bar_r_y + bar_dy;
            elsif (i_sw_r = '0' and bar_r_y > 0) then
                bar_r_y <= bar_r_y - bar_dy;
            end if;

            -- 左邊球拍
            if (i_sw_l = '1' and bar_l_y < 480) then
                bar_l_y <= bar_l_y + bar_dy;
            elsif (i_sw_l = '0' and bar_l_y > 0) then
                bar_l_y <= bar_l_y - bar_dy;
            end if;
        end if;
    end process;

    -- 球移動 & 邊界碰撞邏輯（包括球拍反彈）
process(i_clk, i_rst, div_clk)
begin
    if i_rst = '1' then
        ball_dx <= 2;
        ball_dy <= 2;
        circle_center_x <= 400;
        circle_center_y <= 300;  -- 球的初始位置在畫面中心
        ball_state <= "11";
    elsif rising_edge(div_clk) then    
        case ball_state is
            when "00" =>  -- 右下
                circle_center_x <= circle_center_x + ball_dx;
                circle_center_y <= circle_center_y + ball_dy;

                -- 碰到最下邊界
                if (circle_center_y + BALL_RADIUS) >= 600 then
                    ball_state <= "01";  
                -- 碰到右邊球拍
                elsif (circle_center_x + BALL_RADIUS) >= bar_r_x and
                      circle_center_y >= bar_r_y and 
                      circle_center_y <= bar_r_y + 100 then
                    ball_state <= "10";  
                -- 碰到最右邊界，回到中心
                elsif (circle_center_x + BALL_RADIUS) >= 800 then
                    circle_center_x <= 400; -- 回到中心
                    circle_center_y <= 300; -- 回到中心
                    ball_dx <= 2;           -- 設置球的運動方向
                    ball_dy <= 2;
                    ball_state <= "11";     -- 改變球的運動方向
                end if;

            when "01" =>  -- 右上
                circle_center_x <= circle_center_x + ball_dx;
                circle_center_y <= circle_center_y - ball_dy;

                -- 碰到最上邊界
                if (circle_center_y - BALL_RADIUS) <= 0 then
                    ball_state <= "00";  
                -- 碰到右邊球拍
                elsif (circle_center_x + BALL_RADIUS) >= bar_r_x and
                      circle_center_y >= bar_r_y and 
                      circle_center_y <= bar_r_y + 100 then
                    ball_state <= "11";  
                -- 碰到最右邊界，回到中心
                elsif (circle_center_x + BALL_RADIUS) >= 800 then
                    circle_center_x <= 400; -- 回到中心
                    circle_center_y <= 300; -- 回到中心
                    ball_dx <= 2;           -- 設置球的運動方向
                    ball_dy <= 2;
                    ball_state <= "10";     -- 改變球的運動方向
                end if;

            when "10" =>  -- 左下
                circle_center_x <= circle_center_x - ball_dx;
                circle_center_y <= circle_center_y + ball_dy;

                -- 碰到最下邊界
                if (circle_center_y + BALL_RADIUS) >= 600 then
                    ball_state <= "11";  
                -- 碰到左邊球拍
                elsif (circle_center_x - BALL_RADIUS) <= bar_l_x + 15 and
                      circle_center_y >= bar_l_y and 
                      circle_center_y <= bar_l_y + 100 then
                    ball_state <= "00";  
                -- 碰到最左邊界，回到中心
                elsif (circle_center_x - BALL_RADIUS) <= 0 then
                    circle_center_x <= 400; -- 回到中心
                    circle_center_y <= 300; -- 回到中心
                    ball_dx <= 2;           -- 設置球的運動方向
                    ball_dy <= 2;
                    ball_state <= "01";     -- 改變球的運動方向
                end if;

            when "11" =>  -- 左上
                circle_center_x <= circle_center_x - ball_dx;
                circle_center_y <= circle_center_y - ball_dy;

                -- 碰到最上邊界
                if (circle_center_x - BALL_RADIUS) <= bar_l_x + 15 and
                      circle_center_y >= bar_l_y and 
                      circle_center_y <= bar_l_y + 100 then
                    ball_state <= "01";  
                -- 碰到最上邊界
                elsif (circle_center_y - BALL_RADIUS) <= 0 then
                    ball_state <= "10";  
                -- 碰到最左邊界，回到中心
                elsif (circle_center_x - BALL_RADIUS) <= 0 then
                    circle_center_x <= 400; -- 回到中心
                    circle_center_y <= 300; -- 回到中心
                    ball_dx <= 2;           -- 設置球的運動方向
                    ball_dy <= 2;
                    ball_state <= "01";     -- 改變球的運動方向
                end if;

            when others =>
                -- 沒變化
                circle_center_x <= circle_center_x;
                circle_center_y <= circle_center_y;
        end case;
    end if;
end process;


    -- VGA 實體化
    VGA_inst : VGA
        PORT MAP (
            i_clk        => i_clk,
            i_rst        => i_rst,
            bar_r_x      => bar_r_x,
            bar_r_y      => bar_r_y,
            bar_l_x      => bar_l_x,
            bar_l_y      => bar_l_y,
            circle_center_x => circle_center_x,
            circle_center_y => circle_center_y,
            o_red        => o_red , 
            o_green      => o_green,
            o_blue       => o_blue ,
            o_h_sync     => h_sync,
            o_v_sync     => v_sync
        );
end Behavioral;
