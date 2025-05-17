`timescale 1ns / 1ps
module BRAM_32(
    input clk, 
    input write_en,                 
    input [4:0] write_addr,
    input [12:0] write_data,                      
    input read_en_0, input [4:0] read_addr_0, output reg [12:0] read_data_0,
    input read_en_1, input [4:0] read_addr_1, output reg [12:0] read_data_1,
    input read_en_2, input [4:0] read_addr_2, output reg [12:0] read_data_2,
    input read_en_3, input [4:0] read_addr_3, output reg [12:0] read_data_3,
    input read_en_4, input [4:0] read_addr_4, output reg [12:0] read_data_4,
    input read_en_5, input [4:0] read_addr_5, output reg [12:0] read_data_5,
    input read_en_6, input [4:0] read_addr_6, output reg [12:0] read_data_6,
    input read_en_7, input [4:0] read_addr_7, output reg [12:0] read_data_7,
    input read_en_8, input [4:0] read_addr_8, output reg [12:0] read_data_8,
    input read_en_9, input [4:0] read_addr_9, output reg [12:0] read_data_9,
    input read_en_10, input [4:0] read_addr_10, output reg [12:0] read_data_10,
    input read_en_11, input [4:0] read_addr_11, output reg [12:0] read_data_11,
    input read_en_12, input [4:0] read_addr_12, output reg [12:0] read_data_12,
    input read_en_13, input [4:0] read_addr_13, output reg [12:0] read_data_13,
    input read_en_14, input [4:0] read_addr_14, output reg [12:0] read_data_14,
    input read_en_15, input [4:0] read_addr_15, output reg [12:0] read_data_15,
    input read_en_16, input [4:0] read_addr_16, output reg [12:0] read_data_16,
    input read_en_17, input [4:0] read_addr_17, output reg [12:0] read_data_17
);
    reg [12:0] memory [0:31];
    always @(posedge clk) begin
        if (write_en) begin
            memory[write_addr] <= write_data; // 寫入資料到指定位址
        end
    end
    integer i;
    always @(posedge clk) begin
        read_data_0 <= 0;
        read_data_1 <= 0;
        read_data_2 <= 0;
        read_data_3 <= 0;
        read_data_4 <= 0;
        read_data_5 <= 0;
        read_data_6 <= 0;
        read_data_7 <= 0;
        read_data_8 <= 0;
        read_data_9 <= 0;
        read_data_10 <= 0;
        read_data_11 <= 0;
        read_data_12 <= 0;
        read_data_13 <= 0;
        read_data_14 <= 0;
        read_data_15 <= 0;
        read_data_16 <= 0;
        read_data_17 <= 0;
        if (read_en_0) begin
            read_data_0 <= memory[read_addr_0];
        end
        if (read_en_1) begin
            read_data_1 <= memory[read_addr_1];
        end
        if (read_en_2) begin
            read_data_2 <= memory[read_addr_2];
        end
        if (read_en_3) begin
            read_data_3 <= memory[read_addr_3];
        end
        if (read_en_4) begin
            read_data_4 <= memory[read_addr_4];
        end
        if (read_en_5) begin
            read_data_5 <= memory[read_addr_5];
        end
        if (read_en_6) begin
            read_data_6 <= memory[read_addr_6];
        end
        if (read_en_7) begin
            read_data_7 <= memory[read_addr_7];
        end
        if (read_en_8) begin
            read_data_8 <= memory[read_addr_8];
        end
        if (read_en_9) begin
            read_data_9 <= memory[read_addr_9];
        end
        if (read_en_10) begin
            read_data_10 <= memory[read_addr_10];
        end
        if (read_en_11) begin
            read_data_11 <= memory[read_addr_11];
        end
        if (read_en_12) begin
            read_data_12 <= memory[read_addr_12];
        end
        if (read_en_13) begin
            read_data_13 <= memory[read_addr_13];
        end
        if (read_en_14) begin
            read_data_14 <= memory[read_addr_14];
        end
        if (read_en_15) begin
            read_data_15 <= memory[read_addr_15];
        end
        if (read_en_16) begin
            read_data_16 <= memory[read_addr_16];
        end
        if (read_en_17) begin
            read_data_17 <= memory[read_addr_17];
        end
    end
endmodule