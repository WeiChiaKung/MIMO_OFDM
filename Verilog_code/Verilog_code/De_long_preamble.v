`timescale 1ns / 1ps
`include "header.vh"
module De_long_preamble(
    input clk,
    input rst,
    input input_valid,
    input fine_done,
    input [`FIXED_POINT_WIDTH-1:0]signal_real,
    input [`FIXED_POINT_WIDTH-1:0]signal_imag,
    input [7:0]fine_num,
    output reg out_vaild,
    output reg[`FIXED_POINT_WIDTH-1:0]output_real,
    output reg[`FIXED_POINT_WIDTH-1:0]output_imag
);
    wire [`FIXED_POINT_WIDTH-1:0]fifo_out_real,fifo_out_imag;
    reg [7:0]count;
    reg [8:0]out_count;
    reg find_start_done;
    wire [8:0]fifo_count_real,fifo_count_imag;
    wire full_real,full_imag;
    wire empty_real,empty_imag;
    wire fifo_out_valid_real,fifo_out_valid_imag;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            count <= 0;
            find_start_done <= 0;
        end
        else if(fine_done) begin
            count <= fine_num + 128;
            find_start_done <= 1;
        end   
    end
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            output_real <= 0;
            output_imag <= 0;
            out_vaild <= 0;
            out_count <= 0;
        end
        else if(find_start_done && fifo_out_valid_real && fifo_out_valid_imag) begin
            output_real <= fifo_out_real;
            output_imag <= fifo_out_imag;
            out_count <= out_count + 1;
            out_vaild <= 0;
            if(out_count >= count) begin
                output_real <= fifo_out_real;
                output_imag <= fifo_out_imag;
                out_vaild <= 1;
            end
        end
        else begin
            out_count <= 0;
            output_real <= 0;
            output_imag <= 0;
            out_vaild <= 0;
        end
    end
    FIFO_fine fifo_real(
        .clk(clk),                
        .rst(rst),                
        .w_en(input_valid),              
        .r_en(find_start_done),              
        .din(signal_real), 
        .dout(fifo_out_real), 
        .count(fifo_count_real), //data count in FIFO
        .r_valid(fifo_out_valid_real), //Read valid
        .full(full_real), //FIFO Full              
        .empty(empty_real) //FIFO Empty            
    );
    FIFO_fine fifo_imag(
        .clk(clk),                
        .rst(rst),                
        .w_en(input_valid),              
        .r_en(find_start_done),              
        .din(signal_imag), 
        .dout(fifo_out_imag), 
        .count(fifo_count_imag), //data count in FIFO
        .r_valid(fifo_out_valid_imag), //Read valid
        .full(full_imag), //FIFO Full              
        .empty(empty_imag) //FIFO Empty            
    );
endmodule
