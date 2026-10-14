module tb_a_fifo;
    reg w_clk, r_clk;
    reg w_rst_n, r_rst_n;
    reg w_inc, r_inc;
    reg [7:0] w_data;

    initial begin
        $dumpfile("a_fifo.vcd");
        $dumpvars(0,
        w_clk,
        r_clk,
        w_rst_n,
        r_rst_n,
        dut.w_data,
        dut.w_ptr_b,
        dut.w_full,
        dut.w_inc,
        dut.r_data,
        dut.r_ptr_b,
        dut.r_empty,
        dut.r_inc,
        dut.sync_1_w_ptr_g,
        dut.sync_2_w_ptr_g,
        dut.sync_1_r_ptr_g,
        dut.sync_2_r_ptr_g
        );
    end

    wire       w_full;
    wire [7:0] r_data;
    wire       r_empty;

    async_fifo #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(4)
    ) dut (
        .w_clk(w_clk),
        .w_rst_n(w_rst_n),
        .w_inc(w_inc),
        .w_data(w_data),
        .w_full(w_full),

        .r_clk(r_clk),
        .r_rst_n(r_rst_n),
        .r_inc(r_inc),
        .r_data(r_data),
        .r_empty(r_empty)
    );

    initial begin
        w_clk = 0;
        forever #10 w_clk = ~w_clk;
    end

    initial begin
        r_clk = 0;
        #2;                          
        forever #12 r_clk = ~r_clk;  
    end

    task feed_data;
    integer i;
    begin
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge w_clk) begin
                if (!w_full) begin
                    w_data <= my_vector[i];
                    w_inc  <= 1;
                end else begin
                    w_inc  <= 0;
                end
            end
        end
        @(posedge w_clk);
        w_inc <= 0;
    end
    endtask


    task receive_data;
    integer j;
    begin
        for (j = 0; j < 16; j = j + 1) begin
            @(posedge r_clk) begin
                if (!r_empty) begin
                    r_inc            <= 1;
                    captured_data[j] <= r_data; 
                    $display("Read [%0d] = 0x%0h", j, r_data);
                end else begin
                    r_inc <= 0;
                end
            end
        end
        @(posedge r_clk);
        r_inc <= 0;
        end
    endtask

    reg [7:0] my_vector [0:15];
    reg [7:0] captured_data [0:15];

    initial begin
        integer k;
        for (k = 0; k < 16; k = k + 1) begin
            my_vector[k] = k + 1;
        end

        w_rst_n = 0;
        r_rst_n = 0;
        w_inc   = 0;
        r_inc   = 0;
        #40;
        w_rst_n = 1;
        r_rst_n = 1;

        feed_data();      
        wait (!r_empty);
        receive_data();  

        #100;
        $finish;
    end


endmodule
