library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity booth_multiplication is
    generic(
        bW:   in integer:= 4
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

end entity;


architecture arch_booth_multiplication of booth_multiplication is

    --states of the State Machine
    type states is 
      (
        state_idle, --This state waits for the Start
        state_busy, --This State Acutally compute the product
        state_done --This state comes when result is ready
      );

    signal p_state: states := state_idle;
    signal n_state: states := state_idle;

    signal reg_m:  std_logic_vector(bW-1 downto 0);
    signal reg_r:std_logic_vector(bW-1 downto 0);

    signal temp_prod:    signed(2*bW downto 0);
    signal busy:    std_logic;

    signal count:integer;


begin
    -- load
    loading:process(CLK,nRST,LOAD)begin
        if(nRST = '0')then
            reg_m <= (others => '0');
            reg_r <= (others => '0');

        elsif(rising_edge(CLK))then
            if(LOAD = '1') then
                reg_m <= m;
                reg_r <= r;
            end if;
       end if;
    end process loading;

    --Combinational of FSM
    state_comb:process(p_state,START,count)begin
        case(p_state) is
            when state_idle=>
                if(START = '1')then
                    n_state <= state_busy;
                else 
                    n_state <= state_idle;
                end if; 
            when state_busy=>
                    if(count = 1) then -- stoping condition
                        n_state <= state_done;
                    else
                        n_state <= state_busy;
                    end if;              
            when state_done=> n_state <= state_idle;                             
            when others=> n_state <= state_idle;
        end case;
    end process state_comb;
    --Sequential of FSM
    state_seq:process(CLK,nRST)begin
        if(nRST = '0') then
            p_state <= state_idle;
        elsif rising_edge(CLK) then
            p_state <= n_state;
        end if;
    end process state_seq;
     
    --Busy will trigger the Data Path
    busy <= '1' when (p_state = state_busy) else '0';

    --Data path of Booth's Algorithm
    dataPath:process(CLK,nRST)
      variable b_rs:    signed(2*bW downto 0); --before shifting temperory wire
    begin
        if(nRST = '0') then
            temp_prod(0) <= '0'; 
            temp_prod(bW downto 1) <= signed(reg_r(bW-1 downto 0)); 
            temp_prod(2*bW downto bW+1) <= to_signed(0, bW); 
            b_rs := temp_prod;
            count <= bW; 
        elsif rising_edge(CLK) then
            if(busy = '1') then --busy is the condition to get start 
                if(temp_prod(1 downto 0) = "00")then
                    b_rs := temp_prod;
                    temp_prod <= shift_right(signed(b_rs),1);
                elsif(temp_prod(1 downto 0) = "11") then
                    b_rs := temp_prod;
                    temp_prod <= shift_right(signed(b_rs),1);
                elsif(temp_prod(1 downto 0) = "01")then
                    b_rs(2*bW downto bW+1) := temp_prod(2*bW downto bW+1) + signed(reg_m);
                    b_rs(bW downto 0) := temp_prod(bW downto 0);
                    temp_prod <= shift_right(b_rs,1);
                elsif(temp_prod(1 downto 0) = "10")then
                    b_rs(2*bW downto bW+1) := temp_prod(2*bW downto bW+1) + signed( not reg_m) + 1;
                    b_rs(bW downto 0) := temp_prod(bW downto 0);
                    temp_prod <= shift_right(b_rs,1);
                else 
                    b_rs := temp_prod;
                    temp_prod <= shift_right(signed(b_rs),1);
                end if;
                count <= count - 1;       
            else 
                temp_prod(0) <= '0';
                temp_prod(bW downto 1) <= signed(reg_r(bW-1 downto 0)); 
                temp_prod(2*bW downto bW+1) <= to_signed(0, bW); 
                b_rs := temp_prod;
                count <= bW; 
            end if;
        end if;

    end process dataPath;


    DONE <= '1' when (p_state = state_done) else '0';
    product <= std_logic_vector(temp_prod(2*bW downto 1)) when (p_state = state_done) else (others=>'0');

end arch_booth_multiplication;


