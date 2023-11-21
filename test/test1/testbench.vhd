-- testbench.vhd: Basic UART RX side simulation testing
-- Author(s): Lukas Kekely (ikekely@fit.vutbr.cz)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;



entity testbench1 is
end entity;



architecture TB of testbench1 is

    constant baudrate : natural := 9600;
    constant clkrate : natural := baudrate*16;
    constant clk_period : time := 1 sec / clkrate;
    constant baud_period : time := clk_period*16;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal din : std_logic := '1';
    signal dout : std_logic_vector(7 downto 0);
    signal dout_vld : std_logic;
    signal dout_exp : std_logic_vector(7 downto 0);
    signal dout_error : std_logic;
    signal running : boolean := true;
    type generator_state is (IDLE, START, D0, D1, D2, D3, D4, D5, D6, D7, STOP);
    signal din_state : generator_state := IDLE;

begin

    -- Tested module
    DUT: entity work.UART_RX
    port map (
        CLK => clk,
        RST => rst,
        DIN => din,
        DOUT => dout,
        DOUT_VLD => dout_vld
    );
    
    -- Clock generator
    clk_process: process
    begin
        while running loop
            wait for clk_period/2;
            clk <= not clk;
        end loop;
        wait;
    end process;
    
    -- Output monitoring and reporting
    dout_process: process(clk)
        file output : text open write_mode is "work/sim/test1_output.txt";
        variable row : line;
    begin
        if rising_edge(clk) then
            if dout_vld = '1' and rst = '0' then
                write(row, dout, right, 8);
                writeline(output, row);
            end if;
        end if;
    end process;
    
    -- Main testbench process
    test: process
        file input : text open read_mode is "test1/input.txt";
        variable row : line;
        variable val : std_logic_vector(7 downto 0);
        -- Auxilary procedure for byte sending and DIN generation
        procedure send_byte(constant byte_in : in std_logic_vector(7 downto 0)) is
        begin
            din <= '0'; -- START bit
            din_state <= START;
            wait for baud_period;
            dout_exp <= byte_in;
            din_state <= D0;
            for i in 0 to 7 loop  -- 8x DATA bit
                din <= byte_in(i);
                wait for baud_period;
                din_state <= generator_state'val(generator_state'pos(din_state)+1);
            end loop;
            din <= '1'; -- STOP bit
            din_state <= STOP;
            wait for baud_period;
            din_state <= IDLE;
        end send_byte;
    begin
        wait for clk_period*5;
        rst <= '0';
        wait for clk_period*5;
        while not endfile(input) loop
            readline(input, row);
            read(row, val);
            send_byte(val);
            wait for clk_period*25;
        end loop;
        running <= false;
        wait;
    end process;
    
    dout_error <= '0' when dout = dout_exp else dout_vld;
    
end architecture;
