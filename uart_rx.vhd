-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Marek Čupr (xcuprm01)
-- Date: 22. 4. 2023
-- Subject: INC - Project

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;                        -- signal clock
        RST      : in std_logic;                        -- reset clock
        DIN      : in std_logic;                        -- input bit
        DOUT     : out std_logic_vector(7 downto 0);    -- output (8 bits)
        DOUT_VLD : out std_logic                        -- data validation
    );
end entity;

-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    signal clk_cycle_cnt        : std_logic_vector(4 downto 0) := "00001";   -- clock cycle counter (0 - 24)
    signal clk_cycle_active     : std_logic := '0';                          -- check if 'clock cycle counter' is active
    signal bit_cnt              : std_logic_vector(3 downto 0) := "0000";    -- loaded bits counter (0 - 8) 
    signal data_recieve_active  : std_logic := '0';                          -- check if 'reading data' is active
    signal data_validate_active : std_logic := '0';                          -- check if 'validating data' is active

begin
    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        DIN => DIN,
        CLK_CYCLE_CNT => clk_cycle_cnt,
        CLK_CYCLE_ACTIVE => clk_cycle_active,
        BIT_CNT => bit_cnt,
        DATA_RECIEVE_ACTIVE => data_recieve_active,
        DATA_VALIDATE_ACTIVE => data_validate_active
    );

    -- PROCESS
    process (CLK) begin
        
        -- RESET
        if RST = '1' then
            DOUT_VLD <= '0';          -- set DOUT_VLD to '0' (so it's not undefined in the beginning)
            DOUT <= (others => '0');  -- reset DOUT to zero
            clk_cycle_cnt <= "00001"; -- reset clock cycle counter to one (reseting to zero wasn't reading from midbit ---> it was delayed) 
            bit_cnt <= "0000";        -- reset bit counter to zero

        -- RISING EDGE
        elsif rising_edge(CLK) then

            if clk_cycle_active = '0' then -- clock cycle counter not active (we are not counting clock cycles)
                clk_cycle_cnt <= "00001"; -- reset clock cycle counter to one (reseting to zero wasn't reading from midbit ---> it was delayed) 
            else  -- clock cycle counter active (we are counting clock cycles)
                clk_cycle_cnt <= clk_cycle_cnt + 1; -- clk_cycle_cnt++
            end if;

            DOUT_VLD <= '0'; -- set DOUT_VLD to '0'

            if bit_cnt = "1000" then -- we have read all the bits 
                if data_validate_active = '1' then -- we have recieved a stop bit (data validating is active)
                    bit_cnt <= "0000"; -- reset bit counter to zero
                    DOUT_VLD <= '1'; -- data validated correctly
                end if;
            end if;

            if data_recieve_active = '1' then -- we are recieving data (data recieving is active)
                if clk_cycle_cnt >= "10000" then -- clock cycle counter is >= 16
                    clk_cycle_cnt <= "00001"; -- reset clock cycle counter back to one (reseting to zero wasn't reading from midbit ---> it was delayed) 

                    -- LOAD BITS
                    case bit_cnt is
                        when "0000" => 
                            DOUT(0) <= DIN;    -- load input bit (DIN)
                            bit_cnt <= "0001"; -- bit_cnt++
                        when "0001" => 
                            DOUT(1) <= DIN;    -- load input bit (DIN)
                            bit_cnt <= "0010"; -- bit_cnt++
                        when "0010" => 
                            DOUT(2) <= DIN;    -- load input bit (DIN)
                            bit_cnt <= "0011"; -- bit_cnt++
                        when "0011" => 
                            DOUT(3) <= DIN;    -- load input bit (DIN)
                            bit_cnt <= "0100"; -- bit_cnt++
                        when "0100" => 
                            DOUT(4) <= DIN;    -- load input bit (DIN)
                            bit_cnt <= "0101"; -- bit_cnt++
                        when "0101" => 
                            DOUT(5) <= DIN;    -- load input bit (DIN)
                            bit_cnt <= "0110"; -- bit_cnt++
                        when "0110" => 
                            DOUT(6) <= DIN;    -- load input bit (DIN)
                            bit_cnt <= "0111"; -- bit_cnt++
                        when "0111" => 
                            DOUT(7) <= DIN;    -- load input bit (DIN)
                            bit_cnt <= "1000"; -- bit_cnt++
                        when others => null;   -- invalid input (should not happen)
                    end case;

                end if;
            end if;
        end if;
    end process; 
end architecture;
