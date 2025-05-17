`timescale 1ns / 1ps
`include "header.vh"
module De_prefix(
    input clk,
    input rst,
    input input_valid,
    input [`FIXED_POINT_WIDTH-1:0]signal_real,
    input [`FIXED_POINT_WIDTH-1:0]signal_imag,
    output out_valid,
    output [`FIXED_POINT_WIDTH-1:0]output_real,
    output [`FIXED_POINT_WIDTH-1:0]output_imag
);
    reg [6:0]prefix_count;
    assign output_real = signal_real;
    assign output_imag = signal_imag;
    assign out_valid = (prefix_count<16) ? 0 : 1; 
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            prefix_count <= 0;
        end
        else if(input_valid) begin
            prefix_count <= prefix_count + 1;
            if(prefix_count == 79) begin
                prefix_count <= 0;
            end
        end   
        else begin
            prefix_count <= 0;
        end
    end
endmodule
