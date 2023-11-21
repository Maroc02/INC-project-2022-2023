-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Marek Čupr (xcuprm01)
-- Date: 22. 4. 2023
-- Subject: INC - Project

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_RX_FSM is
    port(
       CLK                   : in std_logic;                     -- signal clock
       RST                   : in std_logic;                     -- reset clock
       DIN                   : in std_logic;                     -- input bit
       CLK_CYCLE_CNT         : in std_logic_vector(4 downto 0);  -- clock cycle counter (0 - 24)
       CLK_CYCLE_ACTIVE      : out std_logic;                    -- check if 'clock cycle counter' is active (if we are at WAIT_FOR_RIST_BIT or READ_DATA state)
       BIT_CNT               : in std_logic_vector(3 downto 0);  -- bit counter (reading 8 bits in total)
       DATA_RECIEVE_ACTIVE   : out std_logic;                    -- check if 'reading data' is active (if we are at READ_DATA state)  
       DATA_VALIDATE_ACTIVE  : out std_logic                     -- check if 'validating data' is active (if we are at VALIDATE_DATA state)
    );
end entity;

architecture behavioral of UART_RX_FSM is
    type fsm_states is (NOT_ACTIVE, WAIT_FOR_FIRST_BIT, READ_DATA, WAIT_FOR_STOP_BIT, VALIDATE_DATA);  -- define all the FSM states
    signal current_state : fsm_states := NOT_ACTIVE;  -- set current_state to NOT_ACTIVE ('default' state)

begin

    -- ACTIVATING PORTS
    CLK_CYCLE_ACTIVE <= '0' when current_state = NOT_ACTIVE or current_state = VALIDATE_DATA else '1'; -- counting clock cycles only in WAIT_FOR_FIRST_BIT, READ_DATA and WAIT_FOR_STOP_BIT states
    DATA_VALIDATE_ACTIVE <= '1' when current_state = VALIDATE_DATA else '0'; -- becomes 1 when we start validating data (after we recieve 'stop-bit')
    DATA_RECIEVE_ACTIVE <= '1' when current_state = READ_DATA else '0'; -- becomes 1 when we start reading bits (after we recieve 'first-bit')

    -- PROCESS
    process(CLK) begin

        -- RESET
        if RST = '1' then
            current_state <= NOT_ACTIVE; -- reset to 'default' state
            
        -- RISING EDGE
        elsif rising_edge(CLK) then

            -- HANDLE STATES
            case current_state is
                when NOT_ACTIVE => 
                    if DIN = '0' then -- 0 is a start bit
                        current_state <= WAIT_FOR_FIRST_BIT; -- change to next state
                    end if;
                when WAIT_FOR_FIRST_BIT =>
                    if CLK_CYCLE_CNT = "10111" then -- wait 23 clock cycles (to sample mid-bit)
                        current_state <= READ_DATA; -- change to next state
                    end if;
                when READ_DATA =>
                    if BIT_CNT = "1000" then -- read 8 bits of data
                        current_state <= WAIT_FOR_STOP_BIT; -- change to next state 
                    end if;
                when WAIT_FOR_STOP_BIT =>
                    if DIN = '1' then -- 1 is a stop bit
                        if CLK_CYCLE_CNT = "01111" then -- validate data mid-stopbit
                            current_state <= VALIDATE_DATA; -- change to next state
                        end if;
                    end if;
                when VALIDATE_DATA =>
                    current_state <= NOT_ACTIVE; -- go back to 'default' state
                when others => null; -- invalid option (should not happen)
            end case;

        end if;
    end process;
end architecture;
