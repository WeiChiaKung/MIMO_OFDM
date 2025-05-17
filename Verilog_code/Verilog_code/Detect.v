`timescale 1ns / 1ps
`include "header.vh"
module Detect(
    input clk,
    input rst,
    input input_valid,
    input R_valid,
    input Q_valid,
    input signed[`FIXED_POINT_WIDTH-1:0]signal0_real,
    input signed[`FIXED_POINT_WIDTH-1:0]signal0_imag,
    input signed[`FIXED_POINT_WIDTH-1:0]signal1_real,
    input signed[`FIXED_POINT_WIDTH-1:0]signal1_imag,
    input signed[`FIXED_POINT_WIDTH-1:0]signal2_real,
    input signed[`FIXED_POINT_WIDTH-1:0]signal2_imag,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R0,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R1,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R2,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R3,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R4,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R5,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R6,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R7,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R8,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R9,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R10,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R11,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R12,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R13,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R14,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R15,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R16,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R17,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R18,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R19,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R20,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R21,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R22,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R23,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R24,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R25,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R26,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R27,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R28,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R29,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R30,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R31,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R32,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R33,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R34,
    input signed [`FIXED_POINT_WIDTH-1:0]output_R35,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q0,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q1,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q2,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q3,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q4,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q5,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q6,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q7,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q8,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q9,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q10,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q11,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q12,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q13,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q14,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q15,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q16,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q17,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q18,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q19,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q20,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q21,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q22,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q23,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q24,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q25,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q26,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q27,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q28,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q29,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q30,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q31,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q32,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q33,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q34,
    input signed [`FIXED_POINT_WIDTH-1:0]output_Q35,
    output [3:0]output_num0,
    output [3:0]output_num1,
    output [3:0]output_num2,
    output reg output_valid
    );
    wire signed[`FIXED_POINT_WIDTH-1:0] y_temp [0:5];
    reg signed[`FIXED_POINT_WIDTH-1+9:0] x_temp [0:5];
    reg signed[`FIXED_POINT_WIDTH-1:0] x [0:5];
    reg signed[`FIXED_POINT_WIDTH-1:0] y [0:35];
    mult_accum_6 mult (
        .in1(signal0_real),
        .in2(output_Q0),
        .in3(signal0_imag),
        .in4(output_Q1),
        .in5(signal1_real),
        .in6(output_Q2),
        .in7(signal1_imag),
        .in8(output_Q3),
        .in9(signal2_real),
        .in10(output_Q4),
        .in11(signal2_imag),
        .in12(output_Q5),
        .result(y_temp[0])
    );

    mult_accum_6 mult1 (
        .in1(signal0_real),
        .in2(output_Q6),
        .in3(signal0_imag),
        .in4(output_Q7),
        .in5(signal1_real),
        .in6(output_Q8),
        .in7(signal1_imag),
        .in8(output_Q9),
        .in9(signal2_real),
        .in10(output_Q10),
        .in11(signal2_imag),
        .in12(output_Q11),
        .result(y_temp[1])
    );

    mult_accum_6 mult2 (
        .in1(signal0_real),
        .in2(output_Q12),
        .in3(signal0_imag),
        .in4(output_Q13),
        .in5(signal1_real),
        .in6(output_Q14),
        .in7(signal1_imag),
        .in8(output_Q15),
        .in9(signal2_real),
        .in10(output_Q16),
        .in11(signal2_imag),
        .in12(output_Q17),
        .result(y_temp[2])
    );

    mult_accum_6 mult3 (
        .in1(signal0_real),
        .in2(output_Q18),
        .in3(signal0_imag),
        .in4(output_Q19),
        .in5(signal1_real),
        .in6(output_Q20),
        .in7(signal1_imag),
        .in8(output_Q21),
        .in9(signal2_real),
        .in10(output_Q22),
        .in11(signal2_imag),
        .in12(output_Q23),
        .result(y_temp[3])
    );

    mult_accum_6 mult4 (
        .in1(signal0_real),
        .in2(output_Q24),
        .in3(signal0_imag),
        .in4(output_Q25),
        .in5(signal1_real),
        .in6(output_Q26),
        .in7(signal1_imag),
        .in8(output_Q27),
        .in9(signal2_real),
        .in10(output_Q28),
        .in11(signal2_imag),
        .in12(output_Q29),
        .result(y_temp[4])
    );

    mult_accum_6 mult5 (
        .in1(signal0_real),
        .in2(output_Q30),
        .in3(signal0_imag),
        .in4(output_Q31),
        .in5(signal1_real),
        .in6(output_Q32),
        .in7(signal1_imag),
        .in8(output_Q33),
        .in9(signal2_real),
        .in10(output_Q34),
        .in11(signal2_imag),
        .in12(output_Q35),
        .result(y_temp[5])
    );
    wire signed[12:0] x_temp_new [0:5];
    reg signed[12:0] x_stage1[0:3];
    reg signed[12:0] x_stage2[0:1];
    reg [3:0] num2[0:2];
    reg [3:0] num1[0:1];
    reg [3:0] num0;
    reg [8:0] cnt;
    wire [3:0] output_num2_temp,output_num1_temp,output_num0_temp;
    always@(*) begin
        x_temp[5] = (y[5]<<<9)/output_R35;
        x_temp[4] = (y[4] - ((x_temp[5] * output_R29) >>> 9)<<<9)/output_R28;
        x_temp[3] = (y[9] - ((x[1] * output_R23 + x[0] * output_R22) >>> 9)<<<9)/output_R21;
        x_temp[2] = (y[8] - ((x[1] * output_R17 + x[0] * output_R16 + x_temp[3] * output_R15) >>> 9)<<<9)/output_R14;
        x_temp[1] = (y[13] - ((x_stage1[1] * output_R11 + x_stage1[0] * output_R10 + x[3] * output_R9 + x[2] * output_R8) >>> 9)<<<9)/output_R7;
        x_temp[0] = (y[12] - ((x_stage1[1] * output_R5 + x_stage1[0] * output_R4 + x[3] * output_R3 + x[2] * output_R2 + x_temp[1] * output_R1) >>> 9)<<<9)/output_R0;
    end
    QAM_demap qam_0(
        .real_part(x_temp[4]), // Input real part of constellation point
        .imag_part(x_temp[5]), // Input imaginary part of constellation point
        .out_real(x_temp_new[0]), // Output 4-bit demapped QAM symbol
        .out_imag(x_temp_new[1]), // Output 4-bit demapped QAM symbol
        .demapped_bits(output_num2_temp) // Output 4-bit demapped QAM symbol
    );
    QAM_demap qam_1(
        .real_part(x_temp[2]), // Input real part of constellation point
        .imag_part(x_temp[3]), // Input imaginary part of constellation point
        .out_real(x_temp_new[2]), // Output 4-bit demapped QAM symbol
        .out_imag(x_temp_new[3]), // Output 4-bit demapped QAM symbol
        .demapped_bits(output_num1_temp) // Output 4-bit demapped QAM symbol
    );
    QAM_demap qam_2(
        .real_part(x_temp[0]), // Input real part of constellation point
        .imag_part(x_temp[1]), // Input imaginary part of constellation point
        .out_real(x_temp_new[4]), // Output 4-bit demapped QAM symbol
        .out_imag(x_temp_new[5]), // Output 4-bit demapped QAM symbol
        .demapped_bits(output_num0_temp) // Output 4-bit demapped QAM symbol
    );
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for(i = 0 ; i<36 ; i=i+1)begin
                y[i] <= 0;
            end
            x[0] <= 0;
            x[1] <= 0;
            x[2] <= 0;
            x[3] <= 0;
            x[4] <= 0;
            x[5] <= 0;
            x_stage1[0] <= 0;
            x_stage1[1] <= 0;
            x_stage1[2] <= 0;
            x_stage1[3] <= 0;
            x_stage2[0] <= 0;
            x_stage2[1] <= 0;
            cnt <= 0;
        end
        else begin
            if(input_valid) begin
                cnt <= cnt + 1;
                y[0] <= y_temp[0];
                y[1] <= y_temp[1];
                y[2] <= y_temp[2];
                y[3] <= y_temp[3];
                y[4] <= y_temp[4];
                y[5] <= y_temp[5];
                for(i = 0 ; i<30 ; i=i+1) begin
                    y[i+6] <= y[i];
                end
                x[0] <= x_temp_new[0];
                x[1] <= x_temp_new[1];
                x_stage1[0] <= x[0];
                x_stage1[1] <= x[1];
                x_stage2[0] <= x_stage1[0];
                x_stage2[1] <= x_stage1[1];
                x[2] <= x_temp_new[2];
                x[3] <= x_temp_new[3];
                x_stage1[2] <= x[2];
                x_stage1[3] <= x[3];
                x[4] <= x_temp_new[4];
                x[5] <= x_temp_new[5];
            end
        end
    end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            num2[0] <= 0;
            num2[1] <= 0;
            num2[2] <= 0;
            num1[0] <= 0;
            num1[1] <= 0;
            num0 <= 0;
            output_valid <= 0;
        end
        else begin
            output_valid <= 0;
            if(cnt >= 3 && input_valid) begin
                output_valid <= 1;
                num2[0] <= output_num2_temp;
                num2[1] <= num2[0];
                num2[2] <= num2[1];
                num1[0] <= output_num1_temp;
                num1[1] <= num1[0];
                num0 <= output_num0_temp;
            end
            else if(cnt >= 1 && input_valid) begin
                num2[0] <= output_num2_temp;
                num2[1] <= num0[0];
                num2[2] <= num0[1];
                num1[0] <= output_num1_temp;
                num1[1] <= num1[0];
                num0 <= output_num0_temp;
            end
        end
    end
    assign output_num2 = num2[2];
    assign output_num1 = num1[1];
    assign output_num0 = num0;
endmodule
