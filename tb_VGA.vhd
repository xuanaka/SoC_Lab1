LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY vga_controller_tb IS
END vga_controller_tb;

ARCHITECTURE behavior OF vga_controller_tb IS
  -- 測試平台的信號定義
  SIGNAL pixel_clk : STD_LOGIC := '0';  -- 40MHz畫素時鐘
  SIGNAL i_reset   : STD_LOGIC := '1';  -- 非同步復位信號 (預設為有效)
  SIGNAL h_sync    : STD_LOGIC;         -- 水平同步信號
  SIGNAL v_sync    : STD_LOGIC;         -- 垂直同步信號
  SIGNAL o_red         : STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4-bit 紅色
  SIGNAL o_green         : STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4-bit 綠色
  SIGNAL o_blue         : STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4-bit 藍色

  -- 實例化vga_controller
  COMPONENT vga_controller IS
    GENERIC(
      h_pulse  : INTEGER := 128;
      h_bp     : INTEGER := 88;
      h_pixels : INTEGER := 800;
      h_fp     : INTEGER := 40;
      h_pol    : STD_LOGIC := '0';

      v_pulse  : INTEGER := 4;
      v_bp     : INTEGER := 23;
      v_pixels : INTEGER := 600;
      v_fp     : INTEGER := 1;
      v_pol    : STD_LOGIC := '1'
    );
    PORT(
      pixel_clk : IN  STD_LOGIC;
      i_reset   : IN  STD_LOGIC;
      h_sync    : OUT STD_LOGIC;
      v_sync    : OUT STD_LOGIC;
      o_red     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      o_green   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      o_blue    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
  END COMPONENT;

BEGIN
  -- 實例化vga_controller
  uut: vga_controller
    PORT MAP(
      pixel_clk => pixel_clk,
      i_reset   => i_reset,
      h_sync    => h_sync,
      v_sync    => v_sync,
      o_red     => o_red,
      o_green         => o_green,
      o_blue         => o_blue
    );

  -- 產生pixel_clk (40MHz)
  CLOCK_PROC: PROCESS
  BEGIN
    -- 40MHz時鐘 (每25ns翻轉一次)
    pixel_clk <= '0';
    WAIT FOR 12.5 ns;
    pixel_clk <= '1';
    WAIT FOR 12.5 ns;
  END PROCESS;

  -- 產生reset_n訊號
  RESET_PROC: PROCESS
  BEGIN
    -- 讓模組開始時先復位
    i_reset <= '0';
    WAIT FOR 20 ns;
    i_reset <= '1';  -- 解除復位
    WAIT FOR 1000 ns;
    -- 可以加入更多的測試流程
    WAIT;
  END PROCESS;

END behavior;
