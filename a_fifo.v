`timescale 1ns/1ps
module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4   // Depth = 2^ADDR_WIDTH (e.g., 16 entries)
)(
    // Write Domain
    input  wire                  w_clk,
    input  wire                  w_rst_n,
    input  wire                  w_inc,
    input  wire [DATA_WIDTH-1:0] w_data,
    output wire                  w_full,

    // Read Domain
    input  wire                  r_clk,
    input  wire                  r_rst_n,
    input  wire                  r_inc,
    output wire [DATA_WIDTH-1:0] r_data,
    output wire                  r_empty
);
/*---------------Write code below this line---------------*/
    reg [DATA_WIDTH-1:0] depth [0:15];
    reg [4:0] r_ptr_b, w_ptr_b;
    wire [4:0] w_ptr_g, r_ptr_g;
    reg [4:0] sync_2_w_ptr_g, sync_1_w_ptr_g, sync_2_r_ptr_g, sync_1_r_ptr_g;

    assign w_ptr_g = w_ptr_b ^ (w_ptr_b >> 1);
    assign r_ptr_g = r_ptr_b ^ (r_ptr_b >> 1);

    assign w_full = (w_ptr_g == {(~sync_2_r_ptr_g[4:3]),(sync_2_r_ptr_g[2:0])});
    assign r_empty = (r_ptr_g == sync_2_w_ptr_g);

    always @(posedge w_clk or negedge w_rst_n) begin
        if(!w_rst_n) begin
            sync_1_r_ptr_g <= 0;
            sync_2_r_ptr_g <= 0;
            w_ptr_b <= 0;
        end else begin
            sync_1_r_ptr_g <= r_ptr_g;
            sync_2_r_ptr_g <= sync_1_r_ptr_g;
            if((!w_full) && w_inc ) w_ptr_b <= w_ptr_b + 1;
        end
    end

    always @(posedge r_clk or negedge r_rst_n) begin
        if(!r_rst_n) begin
            sync_1_w_ptr_g <= 0;
            sync_2_w_ptr_g <= 0;
            r_ptr_b <= 0;
        end else begin
            sync_1_w_ptr_g <= w_ptr_g;
            sync_2_w_ptr_g <= sync_1_w_ptr_g;
            if((!r_empty) && r_inc ) r_ptr_b <= r_ptr_b + 1;
        end
    end

    always @(posedge w_clk ) begin
        if(!w_full && w_inc) begin
            depth[w_ptr_b[3:0]] <= w_data;
        end
    end

    assign r_data = depth[r_ptr_b[3:0]];

endmodule