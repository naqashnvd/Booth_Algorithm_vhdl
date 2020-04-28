library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity testbench is 

end entity;

architecture arch_testbench of testbench is
    
    component booth_multiplication is
        generic(
            bW:   in integer
        );
        port(
            --DATA I/O
            m:     in  std_logic_vector(bW-1 downto 0);
            r:   in  std_logic_vector(bW-1 downto 0);
            product:        out std_logic_vector(2*bW-1 downto 0);
            --CONTROL I/O
            CLK:    in  std_logic;
            nRST:   in  std_logic;
            LOAD:   in  std_logic;
            START:  in  std_logic;
            DONE:   out std_logic
        );
    end component;
    --bit Width
    constant bW: integer range 0 to 10:=10;
    --interconnect signals
    signal tb_m,tb_r: std_logic_vector(bW-1 downto 0):=(others=>'0');
    signal tb_product: std_logic_vector(2*bW-1 downto 0);
    signal tb_CLK,tb_nRST,tb_LOAD,tb_START,tb_DONE:    std_logic:='0';

    signal simulationActive: boolean:=true;
    signal Behavioral_Model_Done: boolean;

    signal actual_product: signed(2*bW-1 downto 0);
    --constants of clock period and the stored inputs and results
    constant CLK_PERIOD: time := 10 ps;
   
    begin
        --Clock Generator
        tb_CLK <= not tb_CLK after CLK_PERIOD / 2 when (simulationActive = true) else '0';

        dut:booth_multiplication
        generic map(
            bW=>bW
        )
        port map(
             --DATA I/O
             m=>tb_m,
             r=>tb_r,
             product=>tb_product,
             --CONTROL I/O
             CLK=>tb_CLK,
             nRST=>tb_nRST,
             LOAD=>tb_LOAD,
             START=>tb_START,
             DONE=>tb_DONE
        );
        
        testing:process is
        begin
            tb_nRST <= '0';
            wait for CLK_PERIOD;
            tb_nRST <= '1';
            wait for CLK_PERIOD;

            for i in 0 to (2*bW-1) loop
                for j in -2*bW+1 to 0 loop
                    --assert signals half a clock cycle before rising edge
                    wait until falling_edge(tb_CLK);
               
                    -- feeding correct inputs
                    tb_m <= std_logic_vector(to_signed(i, bW));
                    tb_r <= std_logic_vector(to_signed(j, bW));

                    -- actual product for testing
                    actual_product <= to_signed(i, bW) * to_signed(j, bW);

                    Behavioral_Model_Done <= false;
                    
                    --asserting Load
                    tb_LOAD <= '1';
                    wait until rising_edge(tb_CLK);
                    
                    -- deasserting LOAD after one clock cycle
                    wait for CLK_PERIOD/2;
                    tb_LOAD <= '0';

                    --asserting start
                    tb_START <= '1';
                    wait until rising_edge(tb_CLK);
                    
                    -- deasserting start after one clock cycle
                    wait for CLK_PERIOD/2;
                    tb_START <= '0';

                    --waiting for output to be ready
                    wait until rising_edge(tb_DONE); --DONE is the ready signal 

                    Behavioral_Model_Done <= true;
                    
                    wait for 5 ps;
                    
                    -- for checking 
                    assert (tb_product = std_logic_vector(actual_product)) report "Product not correct" severity error;
                end loop;
            end loop;

            simulationActive <= false;

        end process testing;

end arch_testbench;