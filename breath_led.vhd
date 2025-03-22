library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all; 
use IEEE.std_logic_unsigned.all;

entity breath_led is
    Port (
        i_clk : in std_logic;          -- 時鐘輸入
        i_rst : in std_logic;          -- 重置信號
        o_led : out std_logic          -- LED 輸出
    );
end breath_led;

architecture Behavioral of breath_led is
    -- 信號定義
    signal count1  : std_logic_vector(7 downto 0); 
    signal count2  : std_logic_vector(7 downto 0); 
    signal fsm1_state   : std_logic; --SW
    signal fsm2_state :  std_logic;	
    signal upbnd1 :  std_logic_vector(7 downto 0)  := "11111110";  --254
    signal upbnd2 :  std_logic_vector(7 downto 0)  := "00000001";  --1
    signal clk_div : std_logic_vector(23 downto 0) := (others => '0');
begin

    -- 輸出 LED 信號
    o_led <= fsm2_state;
	
	--除頻
    process (i_clk, i_rst)
    begin
        if i_rst = '0' then
            clk_div <= (others => '0');
        elsif rising_edge(i_clk) then
            clk_div <= clk_div + 1;
        end if;
    end process;

    -- 狀態機1
    FSM1: process( i_clk, i_rst) 
    begin 
        if i_rst = '0' then 
            fsm1_state <= '1'; 
        elsif rising_edge(i_clk) then 
            case fsm1_state is 
                when '0' => 
                    if upbnd1 = "11111110" then 
                        fsm1_state <= '1'; 
                    end if; 
                when '1' => 
                    if upbnd1 = "00000001" then 
                        fsm1_state <= '0'; 
                    end if; 
                when others => 
                    null; 
            end case;   
        end if; 
    end process; 
 
    -- upbnd1
    process( clk_div, i_rst, fsm1_state) 
    begin 
        if i_rst = '0' then 
            upbnd1 <= "00000001"; 
        elsif rising_edge(clk_div(5)) then 
            case fsm1_state is 
                when '0' => 
                    upbnd1 <= upbnd1 + 1; 
                when '1' => 
                    upbnd1 <= upbnd1 - 1;
                when others => 
                    null; 
            end case; 
        end if; 
    end process; 
 
    -- upbnd2
    process( clk_div, i_rst, fsm1_state) 
    begin 
        if i_rst = '0' then 
            upbnd2 <= "00000001"; 
        elsif rising_edge(clk_div(5)) then 
            case fsm1_state is 
                when '0' => 
                    upbnd2 <= upbnd2 - 1;
                when '1' => 
                    upbnd2 <= upbnd2 + 1; 
                when others => 
                    null; 
            end case; 
        end if;
     end process;

    -- 狀態機2
    FSM2: process( i_clk, i_rst, fsm2_state) 
    begin 
        if i_rst = '0' then 
            fsm2_state <= '0'; 
        elsif rising_edge(i_clk) then 
            case fsm2_state is 
                when '0' => 
                    if count1 = "00000000" then 
                        fsm2_state <= '1'; 
                    end if; 
                when '1' => 
                    if count2 = "00000000" then 
                        fsm2_state <= '0'; 
                    end if; 
                when others => 
                    null; 
            end case;   
        end if; 
    end process; 
 
    -- 計數器 1
    counter1: process( clk_div, i_rst, fsm2_state) 
    begin 
        if i_rst = '0' then 
            count1 <= upbnd1; 
        elsif rising_edge(clk_div(0)) then 
            case fsm2_state is 
                when '0' => 
                    count1 <= count1 - 1; 
                when '1' => 
                    count1 <= upbnd1;
                when others => 
                    null; 
            end case; 
        end if; 
    end process; 
 
    -- 計數器 2
    counter2: process( clk_div, i_rst, fsm2_state) 
    begin 
        if i_rst = '0' then 
            count2 <= upbnd2; 
        elsif rising_edge(clk_div(0)) then 
            case fsm2_state is 
                when '0' => 
                    count2 <= upbnd2;
                when '1' => 
                    count2 <= count2 - 1; 
                when others => 
                    null; 
            end case; 
        end if;       
    end process; 

end Behavioral;
