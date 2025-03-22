library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA is
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
                o_v_sync   : OUT STD_LOGIC              -- 垂直同步信號輸出
	);
end VGA;

architecture Behavior of VGA is
    constant H_TOTAL : INTEGER := H_RES + H_FP  + H_SYNC + H_BP ;
    constant V_TOTAL : INTEGER := V_RES + V_FP + V_SYNC + V_BP ;
    signal   h_count : INTEGER range 0 to H_TOTAL - 1 := 0;
    signal   v_count : INTEGER range 0 to V_TOTAL - 1 := 0;
    signal   pixel_clk : STD_LOGIC := '0';     -- 50MHz 像素時鐘
    signal   clk_div   : STD_LOGIC := '0';      -- 臨時信號，用於時鐘分頻
begin

    -- 時鐘分頻器：將100MHz時鐘降頻至50MHz
    process (i_clk, i_rst)
    begin
        if i_rst = '1' then
            clk_div <= '0';
            pixel_clk <= '0';
        elsif rising_edge(i_clk) then
            clk_div <= not clk_div;       -- 切換clk_div信號
            pixel_clk <= clk_div;     -- 將pixel_clk設為clk_div的輸出
        end if;
    end process;

    -- 水平計數器 (h_count)
    process (pixel_clk, i_rst)
    begin
        if i_rst = '1' then
            h_count <= 0;
        elsif rising_edge(pixel_clk) then
            if h_count < H_TOTAL - 1 then
                h_count <= h_count + 1;
            else
                h_count <= 0;
            end if;
        end if;
    end process;

    -- 垂直計數器 (v_count)
    process (pixel_clk, i_rst)
    begin
        if i_rst = '1' then
            v_count <= 0;
        elsif rising_edge(pixel_clk) then
            if h_count = H_TOTAL - 1 then  -- 當水平計數器回到0時，垂直計數器增加
                if v_count < V_TOTAL - 1 then
                    v_count <= v_count + 1;
                else
                    v_count <= 0;
                end if;
            end if;
        end if;
    end process;

    -- 水平同步信號生成
    process (h_count)
    begin
        if i_rst = '1' then
            o_h_sync <= NOT H_POL;
        elsif h_count < H_RES + H_FP or h_count >= H_RES + H_FP + H_SYNC then
            o_h_sync <= NOT H_POL ;
        else
            o_h_sync <= H_POL ;
        end if;
    end process;

    -- 垂直同步信號生成
    process (v_count)
    begin
        if i_rst = '1' then
            o_v_sync <= NOT V_POL;
        elsif v_count < V_RES + V_FP or v_count >= V_RES + V_FP + V_SYNC then
            o_v_sync <= NOT V_POL;
        else
            o_v_sync <= V_POL;
        end if;
    end process;

    -- RGB顏色輸出設置
    process (h_count, v_count)
    begin
        if i_rst = '1' then
            o_red   <= "0000";
            o_green <= "0000";
            o_blue  <= "0000";
        
        elsif (v_count - 300) * (v_count - 300) + (h_count - 400) * (h_count - 400) < 100 * 100 then
             o_red   <= "0000";  
             o_green <= "1111";  
             o_blue  <= "1111";  
        
        elsif h_count < H_RES and v_count < V_RES then
             o_red   <= "1111"; 
             o_green <= "1111"; 
             o_blue  <= "1111"; 
        
         -- 如果(v_count, h_count)位于?形?，??制?色?形
         
        else
            o_red   <= (others => '0');
            o_green <= (others => '0');
            o_blue  <= (others => '0');
        end if;
    end process;

end Behavior;
