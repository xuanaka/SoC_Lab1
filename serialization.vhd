library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Pingpong_gpio is
    port (
        i_clk   : in std_logic;                         -- 系統時鐘
        i_rst   : in std_logic;                         -- 同步重設
        i_btn   : in std_logic;                         -- 擊球按鈕輸入
        io_gpio : inout std_logic;                      -- GPIO 單線雙向傳輸
        o_led   : out std_logic_vector(7 downto 0)      -- 8 顆 LED 顯示球位置
    );
end entity;

architecture Behavioral of Pingpong_gpio is
    -- 定義有限狀態機型態
    type fsm_type is (RECEIVE, SEND, MOVE_R, MOVE_L);
    signal fsm          : fsm_type := RECEIVE;          -- 狀態機初始狀態：RECEIVE
    signal move         : std_logic_vector(9 downto 0) := "0000000001"; -- 球位置 (10 bits, 兩側保留1 bit)
    signal clk_div      : std_logic_vector(28 downto 0) := (others => '0'); -- 時脈除頻器
    signal slow_clk     : std_logic;                    -- 慢時鐘，用於球移動
    
    signal flag         : std_logic := '1';             -- 控制初次接收的旗標
    
    signal gpio_out     : std_logic := 'Z';             -- GPIO 輸出值 (預設高阻)
    signal gpio_in      : std_logic;                    -- GPIO 輸入值
    signal gpio_prev    : std_logic := '0';             -- 前一個 GPIO 輸入，用於邊緣偵測
    signal recv_edge    : std_logic := '0';             -- 偵測到 GPIO 上升沿

    signal send_pulse   : std_logic := '0';             -- 傳送脈衝
    signal pulse_counter: integer range 0 to 199 := 0;  -- 脈衝計數器 (控制發送時間)

begin
    -- LED 顯示對應球位置 (只取中間 8 bit 顯示)
    o_led <= move(8 downto 1);
    -- GPIO 雙向連接
    io_gpio <= gpio_out;
    gpio_in <= io_gpio;
    -- 慢時鐘取除頻器 bit22
    slow_clk <= clk_div(1);

    -- 時脈除頻器，產生慢時鐘
    process (i_clk, i_rst)
    begin
        if i_rst = '1' then
            clk_div <= (others => '0');
        elsif rising_edge(i_clk) then
            clk_div <= std_logic_vector(unsigned(clk_div) + 1);
        end if;
    end process;

    -- GPIO 上升沿偵測 (接收到對方 SEND)
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if gpio_in = '1' and gpio_prev = '0' then
                recv_edge <= '1'; -- 偵測到上升沿
            else
                recv_edge <= '0';
            end if;
            gpio_prev <= gpio_in;
        end if;
    end process;

    --FSM 狀態機控制
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            fsm <= RECEIVE;
            gpio_out <= 'Z';
        elsif rising_edge(i_clk) then
            case fsm is
                when RECEIVE =>
                    -- 收到對方發送的上升沿，開始往左移
                    if recv_edge = '1' then
                        fsm <= MOVE_L;
                    -- 自己發球 (球在初始位置且按鍵按下)
                    elsif (i_btn = '1') and (move = "0000000001") then
                        fsm <= MOVE_R;
                    end if;

                when MOVE_R =>
                    -- 移到最右邊，準備發送給對方
                    if move = "1000000000" then
                        fsm <= SEND;
                    end if;

                when SEND =>
                    -- 發送脈衝完成後回到接收狀態
                    if pulse_counter = 199 then
                        fsm <= RECEIVE;
                    end if;

                when MOVE_L =>
                    -- 球回到最左邊
                    if move = "0000000001" then
                        if flag = '0' then
                            fsm <= RECEIVE; -- 如果已經非首次接收，回到接收狀態
                        end if;
                    -- 擊球判斷
                    elsif (i_btn = '1') then
                        if move = "0000000010" then
                            fsm <= MOVE_R;  -- 擊球正確，改往右移
                        else
                            fsm <= RECEIVE; -- 擊球失敗，球重新開始
                        end if;
                    end if;

                when others =>
                    fsm <= RECEIVE;
            end case;
        end if;
    end process;

    -- 球位置移動邏輯
    process(slow_clk, i_rst)
    begin
        if i_rst = '1' then
            move <= "0000000001";
            flag <= '1';
        elsif rising_edge(slow_clk) then
            if fsm = RECEIVE then
                -- 接收狀態下確保球在邊界
                if (move = "0000000001") or (move = "1000000000") then
                    -- 保持不變
                else
                    move <= "0000000001"; -- 重置球位置
                end if;

            elsif fsm = MOVE_R then
                -- 球向右移動
                move <= move(8 downto 0) & move(9);

            elsif fsm = MOVE_L then
                -- 第一次接收到球，從最右開始
                if flag = '1' then
                    move <= "1000000000";
                    flag <= '0';
                end if;
                -- 球向左移動
                move <= move(0) & move(9 downto 1);
            end if;
        end if;
    end process;

    -- 發送脈衝控制，傳送控制
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            pulse_counter <= 0;
            send_pulse <= '0';
        elsif rising_edge(i_clk) then
            if fsm = SEND then
                if pulse_counter < 199 then
                    pulse_counter <= pulse_counter + 1;
                    send_pulse <= '1'; -- 發送中
                else
                    pulse_counter <= 0;
                    send_pulse <= '0'; -- 發送完成
                end if;
            else
                pulse_counter <= 0;
                send_pulse <= '0';
            end if;
        end if;
    end process;

    -- 控制 GPIO 輸出 (傳送狀態發送脈衝，其餘高阻)
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if fsm = SEND then
                gpio_out <= send_pulse;
            else
                gpio_out <= 'Z';
            end if;
        end if;
    end process;

end Behavioral;
