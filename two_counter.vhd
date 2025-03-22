library IEEE; 
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity two_counter is
    port (
        i_clk    : in std_logic;
        i_rst    : in std_logic;
        o_count1 : out std_logic_vector(3 downto 0);
        o_count2 : out std_logic_vector(3 downto 0)
    );
end two_counter;

architecture Behavioral of two_counter is
    signal count1 : std_logic_vector(3 downto 0);
    signal count2 : std_logic_vector(3 downto 0);
    signal state  : std_logic;
begin

    o_count1 <= count1;
    o_count2 <= count2;

    FSM: process(i_clk, i_rst)
    begin
        if i_rst = '0' then
            state <= '0';
        elsif rising_edge(i_clk) then
            case state is
                when '0' =>
                    if count1 = "1111" then
                        state <= '1';
                    end if;
                when '1' =>
                    if count2 = "0000" then
                        state <= '0';
                    end if;
                when others =>
                    state <= '0';
            end case;
        end if;
    end process;

    counter1: process(i_clk, i_rst, state)
    begin
        if i_rst = '0' then
            count1 <= "0000";
        elsif rising_edge(i_clk) then
            case state is
                when '0' =>
                    count1 <= count1 + 1;
                when '1' =>
                    null; 
                when others =>
                    null;
            end case;
        end if;
    end process;

    counter2: process(i_clk, i_rst, state)
    begin
        if i_rst = '0' then
            count2 <= "1111";
        elsif rising_edge(i_clk) then
            case state is
                when '0' =>
                    null; 
                when '1' =>
                    count2 <= count2 - 1;
                when others =>
                    null;
            end case;
        end if;
    end process;

end Behavioral;
