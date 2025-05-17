`timescale 1ns / 1ps
module QAM_demap(
    input wire signed [21:0] real_part, // Input real part of constellation point
    input wire signed [21:0] imag_part, // Input imaginary part of constellation point
    output reg [12:0] out_real, // Output 4-bit demapped QAM symbol
    output reg [12:0] out_imag, // Output 4-bit demapped QAM symbol
    output reg [3:0] demapped_bits // Output 4-bit demapped QAM symbol
);
    wire signed[21:0]mid;
    wire signed[12:0]l;
    wire signed[12:0]s;
    assign mid = 22'b00000000000101000011;
    assign l = 13'b0000111100101;
    assign s = 13'b0000010100001;
    always@(*) begin
        if (real_part <= -mid && imag_part >= mid) begin
            demapped_bits = 4'b0000; 
            out_real = -l;
            out_imag = l;
        end
        else if (real_part <= -mid && imag_part < mid && imag_part >= 0) begin
            demapped_bits = 4'b0001;
            out_real = -l;
            out_imag = s;
        end
        else if (real_part <= -mid && imag_part < 0 && imag_part >= -mid) begin
            demapped_bits = 4'b0011;
            out_real = -l;
            out_imag = -s;
        end
        else if (real_part <= -mid && imag_part < -mid) begin
            demapped_bits = 4'b0010;
            out_real = -l;
            out_imag = -l;
        end
        else if (real_part > -mid && real_part <= 0 && imag_part >= mid) begin
            demapped_bits = 4'b0100; 
            out_real = -s;
            out_imag = l;
        end
        else if (real_part > -mid && real_part <= 0 && imag_part < mid && imag_part >= 0) begin
            demapped_bits = 4'b0101; 
            out_real = -s;
            out_imag = s;
        end
        else if (real_part > -mid && real_part <= 0 && imag_part < 0 && imag_part >= -mid) begin
            demapped_bits = 4'b0111;
            out_real = -s;
            out_imag = -s;
        end
        else if (real_part > -mid && real_part <= 0 && imag_part < -mid) begin
            demapped_bits = 4'b0110; 
            out_real = -s;
            out_imag = -l;
        end
        else if (real_part > 0 && real_part <= mid && imag_part >= mid) begin
            demapped_bits = 4'b1100; 
            out_real = s;
            out_imag = l;
        end
        else if (real_part > 0 && real_part <= mid && imag_part < mid && imag_part >= 0) begin
            demapped_bits = 4'b1101;
            out_real = s;
            out_imag = s;
        end
        else if (real_part > 0 && real_part <= mid && imag_part < 0 && imag_part >= -mid) begin
            demapped_bits = 4'b1111;
            out_real = s;
            out_imag = -l;
        end
        else if (real_part > 0 && real_part <= mid && imag_part < -mid) begin
            demapped_bits = 4'b1110; 
            out_real = s;
            out_imag = -s;
        end
        else if (real_part > mid && imag_part >= mid) begin
            demapped_bits = 4'b1000; 
            out_real = l;
            out_imag = l;
        end
        else if (real_part > mid && imag_part < mid && imag_part >= 0) begin
            demapped_bits = 4'b1001;
            out_real = l;
            out_imag = s; 
        end
        else if (real_part > mid && imag_part < 0 && imag_part >= -mid) begin
            demapped_bits = 4'b1011;
            out_real = l;
            out_imag = -s;
        end
        else if (real_part > mid && imag_part < -mid) begin
            demapped_bits = 4'b1010; 
            out_real = l;
            out_imag = -l;
        end
        else begin
            demapped_bits = 4'b0000;
            out_real = -l;
            out_imag = l;
        end
    end

endmodule
