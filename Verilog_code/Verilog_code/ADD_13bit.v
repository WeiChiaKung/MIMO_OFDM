`timescale 1ns / 1ps
`include "header.vh"
module ADD_13bit(
    input signed [`FIXED_POINT_WIDTH-1:0] a_real,  
    input signed [`FIXED_POINT_WIDTH-1:0] a_imag,  
    input signed [`FIXED_POINT_WIDTH-1:0] b_real,  
    input signed [`FIXED_POINT_WIDTH-1:0] b_imag,  
    output signed [`FIXED_POINT_WIDTH-1:0] result_real,  
    output signed [`FIXED_POINT_WIDTH-1:0] result_imag
    );
    wire signed [`FIXED_POINT_WIDTH:0] temp_real, temp_imag;
    assign temp_real = a_real + b_real;
    assign temp_imag = a_imag + b_imag;
    assign result_real = temp_real[`FIXED_POINT_WIDTH-1:0]; //truncate
    assign result_imag = temp_imag[`FIXED_POINT_WIDTH-1:0]; //truncate
endmodule
