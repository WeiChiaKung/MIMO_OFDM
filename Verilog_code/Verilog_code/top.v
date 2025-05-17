`timescale 1ns / 1ps
`include "header.vh"
module top(
    input clk,
    input rst,
    input input_valid,
    input weight_valid,
    input preamble_valid,
    input H_valid,
    input [`FIXED_POINT_WIDTH-1:0]signal0_real,
    input [`FIXED_POINT_WIDTH-1:0]signal0_imag,
    input [`FIXED_POINT_WIDTH-1:0]signal1_real,
    input [`FIXED_POINT_WIDTH-1:0]signal1_imag,
    input [`FIXED_POINT_WIDTH-1:0]signal2_real,
    input [`FIXED_POINT_WIDTH-1:0]signal2_imag,
    input [4:0] weight_addr,
    output output_valid,
    output reg [`FIXED_POINT_WIDTH-1:0]output_real,
    output reg [`FIXED_POINT_WIDTH-1:0]output_imag,
    output reg [`FIXED_POINT_WIDTH-1:0]output1_real,
    output reg [`FIXED_POINT_WIDTH-1:0]output1_imag,
    output reg [`FIXED_POINT_WIDTH-1:0]output2_real,
    output reg [`FIXED_POINT_WIDTH-1:0]output2_imag,
    output [3:0]output_num0,
    output [3:0]output_num1,
    output [3:0]output_num2,
    output [`FIXED_POINT_WIDTH-1:0]tao,
    output synchronization_valid
);   
    wire [4:0]coarse_num;
    wire [7:0]fine_num;
    wire coarse_done;
    wire fine_done;
    wire long_preamble_valid;
    wire long_preamble1_valid;
    wire long_preamble2_valid;
    wire [`FIXED_POINT_WIDTH-1:0]long_preamble_real;
    wire [`FIXED_POINT_WIDTH-1:0]long_preamble_imag;
    wire [`FIXED_POINT_WIDTH-1:0]long_preamble1_real;
    wire [`FIXED_POINT_WIDTH-1:0]long_preamble1_imag;
    wire [`FIXED_POINT_WIDTH-1:0]long_preamble2_real;
    wire [`FIXED_POINT_WIDTH-1:0]long_preamble2_imag;
    wire [`FIXED_POINT_WIDTH-1:0]tao_short;
    reg [9:0] fine_count;
    //Coarse Synchronization_Block
    Coarse_correlation coarse(
        .clk(clk),
        .rst(rst),
        .valid(input_valid),
        .signal_real(signal0_real),
        .signal_imag(signal0_imag),
        .tao(tao_short),
        .coarse_num(coarse_num),
        .coarse_done(coarse_done)
    );
    //Deprefix_Block
    De_short_preamble de_short_preamble0(
        .clk(clk),
        .rst(rst),
        .input_valid(input_valid),
        .coarse_done(coarse_done),
        .signal_real(signal0_real),
        .signal_imag(signal0_imag),
        .coarse_num(coarse_num),
        .out_vaild(long_preamble_valid),
        .output_real(long_preamble_real),
        .output_imag(long_preamble_imag)
    );
    //Deprefix_Block
    De_short_preamble de_short_preamble1(
        .clk(clk),
        .rst(rst),
        .input_valid(input_valid),
        .coarse_done(coarse_done),
        .signal_real(signal1_real),
        .signal_imag(signal1_imag),
        .coarse_num(coarse_num),
        .out_vaild(long_preamble1_valid),
        .output_real(long_preamble1_real),
        .output_imag(long_preamble1_imag)
    );
    //Deprefix_Block
    De_short_preamble de_short_preamble2(
        .clk(clk),
        .rst(rst),
        .input_valid(input_valid),
        .coarse_done(coarse_done),
        .signal_real(signal2_real),
        .signal_imag(signal2_imag),
        .coarse_num(coarse_num),
        .out_vaild(long_preamble2_valid),
        .output_real(long_preamble2_real),
        .output_imag(long_preamble2_imag)
    );
    wire [`FIXED_POINT_WIDTH-1:0]fine_preamble_real;
    wire [`FIXED_POINT_WIDTH-1:0]fine_preamble_imag;
    wire [`FIXED_POINT_WIDTH-1:0]De_prefix_real;
    wire [`FIXED_POINT_WIDTH-1:0]De_prefix_imag;
    wire [`FIXED_POINT_WIDTH-1:0]De_prefix1_real;
    wire [`FIXED_POINT_WIDTH-1:0]De_prefix1_imag;
    wire [`FIXED_POINT_WIDTH-1:0]De_prefix2_real;
    wire [`FIXED_POINT_WIDTH-1:0]De_prefix2_imag;
    wire De_prefix_valid;
    wire De_prefix1_valid;
    wire De_prefix2_valid;
    assign fine_preamble_real = (preamble_valid) ? signal0_real : long_preamble_real;
    assign fine_preamble_imag = (preamble_valid) ? signal0_imag : long_preamble_imag;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            fine_count <= 0;
        end 
        else begin
            if(long_preamble_valid) begin
                fine_count <= fine_count + 1;
            end
        end
    end
    Fine_correlation fine(
        .clk(clk),
        .rst(rst),
        .input_valid(long_preamble_valid && fine_count <= 128),
        .preamble_valid(preamble_valid),
        .signal_real(fine_preamble_real),
        .signal_imag(fine_preamble_imag),
        .tao(tao),
        .fine_num(fine_num),
        .fine_done(synchronization_valid)
    );
    De_long_preamble de_long_preamble0(
        .clk(clk),
        .rst(rst),
        .input_valid(long_preamble_valid),
        .fine_done(synchronization_valid),
        .signal_real(long_preamble_real),
        .signal_imag(long_preamble_imag),
        .fine_num(fine_num),
        .out_vaild(De_prefix_valid),
        .output_real(De_prefix_real),
        .output_imag(De_prefix_imag)
    );
     De_long_preamble de_long_preamble1(
        .clk(clk),
        .rst(rst),
        .input_valid(long_preamble1_valid),
        .fine_done(synchronization_valid),
        .signal_real(long_preamble1_real),
        .signal_imag(long_preamble1_imag),
        .fine_num(fine_num),
        .out_vaild(De_prefix1_valid),
        .output_real(De_prefix1_real),
        .output_imag(De_prefix1_imag)
    );
     De_long_preamble de_long_preamble2(
        .clk(clk),
        .rst(rst),
        .input_valid(long_preamble2_valid),
        .fine_done(synchronization_valid),
        .signal_real(long_preamble2_real),
        .signal_imag(long_preamble2_imag),
        .fine_num(fine_num),
        .out_vaild(De_prefix2_valid),
        .output_real(De_prefix2_real),
        .output_imag(De_prefix2_imag)
    );
    wire [`FIXED_POINT_WIDTH-1:0]FFT_real;
    wire [`FIXED_POINT_WIDTH-1:0]FFT_imag;
    wire [`FIXED_POINT_WIDTH-1:0]FFT_output_real;
    wire [`FIXED_POINT_WIDTH-1:0]FFT_output_imag;
    wire FFT_valid;
    wire FFT_output_valid;
    De_prefix de_prefix(
        .clk(clk),
        .rst(rst),
        .input_valid(De_prefix_valid),
        .signal_real(De_prefix_real),
        .signal_imag(De_prefix_imag),
        .out_valid(FFT_valid),
        .output_real(FFT_real),
        .output_imag(FFT_imag)
    );
    wire [`FIXED_POINT_WIDTH-1:0]FFT1_real;
    wire [`FIXED_POINT_WIDTH-1:0]FFT1_imag;
    wire [`FIXED_POINT_WIDTH-1:0]FFT1_output_real;
    wire [`FIXED_POINT_WIDTH-1:0]FFT1_output_imag;
    wire FFT1_valid;
    wire FFT1_output_valid;
    De_prefix de_prefix1(
        .clk(clk),
        .rst(rst),
        .input_valid(De_prefix1_valid),
        .signal_real(De_prefix1_real),
        .signal_imag(De_prefix1_imag),
        .out_valid(FFT1_valid),
        .output_real(FFT1_real),
        .output_imag(FFT1_imag)
    );
    wire [`FIXED_POINT_WIDTH-1:0]FFT2_real;
    wire [`FIXED_POINT_WIDTH-1:0]FFT2_imag;
    wire [`FIXED_POINT_WIDTH-1:0]FFT2_output_real;
    wire [`FIXED_POINT_WIDTH-1:0]FFT2_output_imag;
    wire FFT2_valid;
    wire FFT2_output_valid;
    De_prefix de_prefix2(
        .clk(clk),
        .rst(rst),
        .input_valid(De_prefix2_valid),
        .signal_real(De_prefix2_real),
        .signal_imag(De_prefix2_imag),
        .out_valid(FFT2_valid),
        .output_real(FFT2_real),
        .output_imag(FFT2_imag)
    );
    wire RAM_we;
    wire [17:0]read_en;
    wire [4:0] MIMO0_read_addr_0;
    wire [4:0] MIMO0_read_addr_1;
    wire [4:0] MIMO0_read_addr_2;
    wire [4:0] MIMO0_read_addr_3;
    wire [4:0] MIMO0_read_addr_4;
    wire [4:0] MIMO0_read_addr_5;
    wire [4:0] MIMO1_read_addr_0;
    wire [4:0] MIMO1_read_addr_1;
    wire [4:0] MIMO1_read_addr_2;
    wire [4:0] MIMO1_read_addr_3;
    wire [4:0] MIMO1_read_addr_4;
    wire [4:0] MIMO1_read_addr_5;
    wire [4:0] MIMO2_read_addr_0;
    wire [4:0] MIMO2_read_addr_1;
    wire [4:0] MIMO2_read_addr_2;
    wire [4:0] MIMO2_read_addr_3;
    wire [4:0] MIMO2_read_addr_4;
    wire [4:0] MIMO2_read_addr_5;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO0_read_data_real_0;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO0_read_data_real_1;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO0_read_data_real_2;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO0_read_data_real_3;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO0_read_data_real_4;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO0_read_data_real_5;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO0_read_data_imag_0;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO0_read_data_imag_1;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO0_read_data_imag_2;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO0_read_data_imag_3;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO0_read_data_imag_4;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO0_read_data_imag_5;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO1_read_data_real_0;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO1_read_data_real_1;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO1_read_data_real_2;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO1_read_data_real_3;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO1_read_data_real_4;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO1_read_data_real_5;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO1_read_data_imag_0;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO1_read_data_imag_1;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO1_read_data_imag_2;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO1_read_data_imag_3;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO1_read_data_imag_4;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO1_read_data_imag_5;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO2_read_data_real_0;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO2_read_data_real_1;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO2_read_data_real_2;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO2_read_data_real_3;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO2_read_data_real_4;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO2_read_data_real_5;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO2_read_data_imag_0;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO2_read_data_imag_1;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO2_read_data_imag_2;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO2_read_data_imag_3;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO2_read_data_imag_4;
    wire [`FIXED_POINT_WIDTH-1:0] MIMO2_read_data_imag_5;
    assign RAM_we = (input_valid)? 0 : weight_valid;
    //wire [`FIXED_POINT_WIDTH-1+7:0]tao;
    //wire synchronization_valid;
    
    
    
    //Weight_BRAM
    BRAM_32 RAM_real(
        .clk(clk),                    
        .write_en(RAM_we),            
        .write_addr(weight_addr), 
        .write_data(signal0_real),     
        .read_en_0(read_en[0]), .read_addr_0(MIMO0_read_addr_0), .read_data_0(MIMO0_read_data_real_0),
        .read_en_1(read_en[1]), .read_addr_1(MIMO0_read_addr_1), .read_data_1(MIMO0_read_data_real_1),
        .read_en_2(read_en[2]), .read_addr_2(MIMO0_read_addr_2), .read_data_2(MIMO0_read_data_real_2),
        .read_en_3(read_en[3]), .read_addr_3(MIMO0_read_addr_3), .read_data_3(MIMO0_read_data_real_3),
        .read_en_4(read_en[4]), .read_addr_4(MIMO0_read_addr_4), .read_data_4(MIMO0_read_data_real_4),
        .read_en_5(read_en[5]), .read_addr_5(MIMO0_read_addr_5), .read_data_5(MIMO0_read_data_real_5),
        .read_en_6(read_en[6]), .read_addr_6(MIMO1_read_addr_0), .read_data_6(MIMO1_read_data_real_0),
        .read_en_7(read_en[7]), .read_addr_7(MIMO1_read_addr_1), .read_data_7(MIMO1_read_data_real_1),
        .read_en_8(read_en[8]), .read_addr_8(MIMO1_read_addr_2), .read_data_8(MIMO1_read_data_real_2),
        .read_en_9(read_en[9]), .read_addr_9(MIMO1_read_addr_3), .read_data_9(MIMO1_read_data_real_3),
        .read_en_10(read_en[10]), .read_addr_10(MIMO1_read_addr_4), .read_data_10(MIMO1_read_data_real_4),
        .read_en_11(read_en[11]), .read_addr_11(MIMO1_read_addr_5), .read_data_11(MIMO1_read_data_real_5),
        .read_en_12(read_en[12]), .read_addr_12(MIMO2_read_addr_0), .read_data_12(MIMO2_read_data_real_0),
        .read_en_13(read_en[13]), .read_addr_13(MIMO2_read_addr_1), .read_data_13(MIMO2_read_data_real_1),
        .read_en_14(read_en[14]), .read_addr_14(MIMO2_read_addr_2), .read_data_14(MIMO2_read_data_real_2),
        .read_en_15(read_en[15]), .read_addr_15(MIMO2_read_addr_3), .read_data_15(MIMO2_read_data_real_3),
        .read_en_16(read_en[16]), .read_addr_16(MIMO2_read_addr_4), .read_data_16(MIMO2_read_data_real_4),
        .read_en_17(read_en[17]), .read_addr_17(MIMO2_read_addr_5), .read_data_17(MIMO2_read_data_real_5)
    );
    BRAM_32 RAM_imag(
        .clk(clk),                    
        .write_en(RAM_we),            
        .write_addr(weight_addr), 
        .write_data(signal0_imag),     
        .read_en_0(read_en[0]), .read_addr_0(MIMO0_read_addr_0), .read_data_0(MIMO0_read_data_imag_0),
        .read_en_1(read_en[1]), .read_addr_1(MIMO0_read_addr_1), .read_data_1(MIMO0_read_data_imag_1),
        .read_en_2(read_en[2]), .read_addr_2(MIMO0_read_addr_2), .read_data_2(MIMO0_read_data_imag_2),
        .read_en_3(read_en[3]), .read_addr_3(MIMO0_read_addr_3), .read_data_3(MIMO0_read_data_imag_3),
        .read_en_4(read_en[4]), .read_addr_4(MIMO0_read_addr_4), .read_data_4(MIMO0_read_data_imag_4),
        .read_en_5(read_en[5]), .read_addr_5(MIMO0_read_addr_5), .read_data_5(MIMO0_read_data_imag_5),
        .read_en_6(read_en[6]), .read_addr_6(MIMO1_read_addr_0), .read_data_6(MIMO1_read_data_imag_0),
        .read_en_7(read_en[7]), .read_addr_7(MIMO1_read_addr_1), .read_data_7(MIMO1_read_data_imag_1),
        .read_en_8(read_en[8]), .read_addr_8(MIMO1_read_addr_2), .read_data_8(MIMO1_read_data_imag_2),
        .read_en_9(read_en[9]), .read_addr_9(MIMO1_read_addr_3), .read_data_9(MIMO1_read_data_imag_3),
        .read_en_10(read_en[10]), .read_addr_10(MIMO1_read_addr_4), .read_data_10(MIMO1_read_data_imag_4),
        .read_en_11(read_en[11]), .read_addr_11(MIMO1_read_addr_5), .read_data_11(MIMO1_read_data_imag_5),
        .read_en_12(read_en[12]), .read_addr_12(MIMO2_read_addr_0), .read_data_12(MIMO2_read_data_imag_0),
        .read_en_13(read_en[13]), .read_addr_13(MIMO2_read_addr_1), .read_data_13(MIMO2_read_data_imag_1),
        .read_en_14(read_en[14]), .read_addr_14(MIMO2_read_addr_2), .read_data_14(MIMO2_read_data_imag_2),
        .read_en_15(read_en[15]), .read_addr_15(MIMO2_read_addr_3), .read_data_15(MIMO2_read_data_imag_3),
        .read_en_16(read_en[16]), .read_addr_16(MIMO2_read_addr_4), .read_data_16(MIMO2_read_data_imag_4),
        .read_en_17(read_en[17]), .read_addr_17(MIMO2_read_addr_5), .read_data_17(MIMO2_read_data_imag_5)
    );
    
    //FFT enable 
    reg FFT_en;
    reg FFT1_en;
    reg FFT2_en;
    reg [9:0]input_count,output_count;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            input_count <= 0;
            output_count <= 0;
        end 
        else begin
            if(FFT_valid)
                input_count <= input_count + 1;
            if(FFT_output_valid)
                output_count <= output_count + 1;
        end
    end
    always @(*) begin
        if(output_count < 122 && input_count == 128) begin //if input done FFT still need to work
            FFT_en = 1;
            FFT1_en = 1;
            FFT2_en = 1;
        end
        else begin
            FFT_en = FFT_valid;
            FFT1_en = FFT1_valid;
            FFT2_en = FFT2_valid;
        end
    end
    
    //FFT block
    FFT_64point fft(
        .clk(clk),
        .weight_real_0(MIMO0_read_data_real_0), .weight_imag_0(MIMO0_read_data_imag_0),
        .weight_real_1(MIMO0_read_data_real_1), .weight_imag_1(MIMO0_read_data_imag_1),
        .weight_real_2(MIMO0_read_data_real_2), .weight_imag_2(MIMO0_read_data_imag_2),
        .weight_real_3(MIMO0_read_data_real_3), .weight_imag_3(MIMO0_read_data_imag_3),
        .weight_real_4(MIMO0_read_data_real_4), .weight_imag_4(MIMO0_read_data_imag_4),
        .weight_real_5(MIMO0_read_data_real_5), .weight_imag_5(MIMO0_read_data_imag_5),
        .input_real(FFT_real),
        .input_imag(FFT_imag),
        .in_valid(FFT_en),
        .rst(rst),
        .weight_en_0(read_en[0]), .weight_addr_0(MIMO0_read_addr_0),
        .weight_en_1(read_en[1]), .weight_addr_1(MIMO0_read_addr_1),
        .weight_en_2(read_en[2]), .weight_addr_2(MIMO0_read_addr_2),
        .weight_en_3(read_en[3]), .weight_addr_3(MIMO0_read_addr_3),
        .weight_en_4(read_en[4]), .weight_addr_4(MIMO0_read_addr_4),
        .weight_en_5(read_en[5]), .weight_addr_5(MIMO0_read_addr_5),
        .output_real(FFT_output_real),
        .output_imag(FFT_output_imag),
        .out_valid(FFT_output_valid)
    );
    FFT_64point fft1(
        .clk(clk),
        .weight_real_0(MIMO1_read_data_real_0), .weight_imag_0(MIMO1_read_data_imag_0),
        .weight_real_1(MIMO1_read_data_real_1), .weight_imag_1(MIMO1_read_data_imag_1),
        .weight_real_2(MIMO1_read_data_real_2), .weight_imag_2(MIMO1_read_data_imag_2),
        .weight_real_3(MIMO1_read_data_real_3), .weight_imag_3(MIMO1_read_data_imag_3),
        .weight_real_4(MIMO1_read_data_real_4), .weight_imag_4(MIMO1_read_data_imag_4),
        .weight_real_5(MIMO1_read_data_real_5), .weight_imag_5(MIMO1_read_data_imag_5),
        .input_real(FFT1_real),
        .input_imag(FFT1_imag),
        .in_valid(FFT1_en),
        .rst(rst),
        .weight_en_0(read_en[6]), .weight_addr_0(MIMO1_read_addr_0),
        .weight_en_1(read_en[7]), .weight_addr_1(MIMO1_read_addr_1),
        .weight_en_2(read_en[8]), .weight_addr_2(MIMO1_read_addr_2),
        .weight_en_3(read_en[9]), .weight_addr_3(MIMO1_read_addr_3),
        .weight_en_4(read_en[10]), .weight_addr_4(MIMO1_read_addr_4),
        .weight_en_5(read_en[11]), .weight_addr_5(MIMO1_read_addr_5),
        .output_real(FFT1_output_real),
        .output_imag(FFT1_output_imag),
        .out_valid(FFT1_output_valid)
    );
    FFT_64point fft2(
        .clk(clk),
        .weight_real_0(MIMO2_read_data_real_0), .weight_imag_0(MIMO2_read_data_imag_0),
        .weight_real_1(MIMO2_read_data_real_1), .weight_imag_1(MIMO2_read_data_imag_1),
        .weight_real_2(MIMO2_read_data_real_2), .weight_imag_2(MIMO2_read_data_imag_2),
        .weight_real_3(MIMO2_read_data_real_3), .weight_imag_3(MIMO2_read_data_imag_3),
        .weight_real_4(MIMO2_read_data_real_4), .weight_imag_4(MIMO2_read_data_imag_4),
        .weight_real_5(MIMO2_read_data_real_5), .weight_imag_5(MIMO2_read_data_imag_5),
        .input_real(FFT2_real),
        .input_imag(FFT2_imag),
        .in_valid(FFT2_en),
        .rst(rst),
        .weight_en_0(read_en[12]), .weight_addr_0(MIMO2_read_addr_0),
        .weight_en_1(read_en[13]), .weight_addr_1(MIMO2_read_addr_1),
        .weight_en_2(read_en[14]), .weight_addr_2(MIMO2_read_addr_2),
        .weight_en_3(read_en[15]), .weight_addr_3(MIMO2_read_addr_3),
        .weight_en_4(read_en[16]), .weight_addr_4(MIMO2_read_addr_4),
        .weight_en_5(read_en[17]), .weight_addr_5(MIMO2_read_addr_5),
        .output_real(FFT2_output_real),
        .output_imag(FFT2_output_imag),
        .out_valid(FFT2_output_valid)
    );
    //Scramble
    //Scramble need 2 memory to buffer the FFT output
    localparam WRITE_A = 1'b0;
    localparam WRITE_B = 1'b1;
    localparam READ_IDLE = 3'b000;
    localparam READ_A = 3'b001;
    localparam READ_A_wait = 3'b010;
    localparam READ_B = 3'b011;
    localparam READ_B_wait = 3'b100;
    reg write_state;
    reg [5:0] write_count;
    wire [5:0] write_addr_A, write_addr_B;
    reg write_done;
    
    reg [2:0] read_state;
    reg [6:0] read_count;
    reg read_en_1;
    reg [5:0] read_addr_A, read_addr_B;
    wire [`FIXED_POINT_WIDTH-1:0] read_data_real1, read_data_real2, read_data1_real1, read_data1_real2, read_data2_real1, read_data2_real2;
    wire [`FIXED_POINT_WIDTH-1:0] read_data_imag1, read_data_imag2, read_data1_imag1, read_data1_imag2, read_data2_imag1, read_data2_imag2;
    assign write_addr_A = {write_count[0],write_count[1],write_count[2],write_count[3],write_count[4],write_count[5]};
    assign write_addr_B = {write_count[0],write_count[1],write_count[2],write_count[3],write_count[4],write_count[5]};
    //Scramble RAM 1
    BRAM_64 bram_real1(
        .clk(clk),
        .write_en(FFT_output_valid && (write_state == WRITE_A)),  
        .write_addr(write_addr_A),
        .write_data(FFT_output_real),
        .read_en(read_en_1 && (read_state == READ_A)),   
        .read_addr(read_addr_A),
        .read_data(read_data_real1)
    );

    BRAM_64 bram_imag1(
        .clk(clk),
        .write_en(FFT_output_valid && (write_state == WRITE_A)),   
        .write_addr(write_addr_A),
        .write_data(FFT_output_imag),
        .read_en(read_en_1 && (read_state == READ_A)),    
        .read_addr(read_addr_A),
        .read_data(read_data_imag1)
    );

    //Scramble RAM2
    BRAM_64 bram_real2(
        .clk(clk),
        .write_en(FFT_output_valid && (write_state == WRITE_B)),   
        .write_addr(write_addr_B),
        .write_data(FFT_output_real),
        .read_en(read_en_1 && (read_state == READ_B)),   
        .read_addr(read_addr_B),
        .read_data(read_data_real2)
    );
    BRAM_64 bram_imag2(
        .clk(clk),
        .write_en(FFT_output_valid && (write_state == WRITE_B)),   
        .write_addr(write_addr_B),
        .write_data(FFT_output_imag),
        .read_en(read_en_1 && (read_state == READ_B)),   
        .read_addr(read_addr_B),
        .read_data(read_data_imag2)
    );
    
    //Scramble RAM 1
    BRAM_64 bram1_real1(
        .clk(clk),
        .write_en(FFT1_output_valid && (write_state == WRITE_A)),  
        .write_addr(write_addr_A),
        .write_data(FFT1_output_real),
        .read_en(read_en_1 && (read_state == READ_A)),   
        .read_addr(read_addr_A),
        .read_data(read_data1_real1)
    );

    BRAM_64 bram1_imag1(
        .clk(clk),
        .write_en(FFT1_output_valid && (write_state == WRITE_A)),   
        .write_addr(write_addr_A),
        .write_data(FFT1_output_imag),
        .read_en(read_en_1 && (read_state == READ_A)),    
        .read_addr(read_addr_A),
        .read_data(read_data1_imag1)
    );

    //Scramble RAM2
    BRAM_64 bram1_real2(
        .clk(clk),
        .write_en(FFT1_output_valid && (write_state == WRITE_B)),   
        .write_addr(write_addr_B),
        .write_data(FFT1_output_real),
        .read_en(read_en_1 && (read_state == READ_B)),   
        .read_addr(read_addr_B),
        .read_data(read_data1_real2)
    );
    BRAM_64 bram1_imag2(
        .clk(clk),
        .write_en(FFT1_output_valid && (write_state == WRITE_B)),   
        .write_addr(write_addr_B),
        .write_data(FFT1_output_imag),
        .read_en(read_en_1 && (read_state == READ_B)),   
        .read_addr(read_addr_B),
        .read_data(read_data1_imag2)
    );
    
    //Scramble RAM 1
    BRAM_64 bram2_real1(
        .clk(clk),
        .write_en(FFT2_output_valid && (write_state == WRITE_A)),  
        .write_addr(write_addr_A),
        .write_data(FFT2_output_real),
        .read_en(read_en_1 && (read_state == READ_A)),   
        .read_addr(read_addr_A),
        .read_data(read_data2_real1)
    );

    BRAM_64 bram2_imag1(
        .clk(clk),
        .write_en(FFT2_output_valid && (write_state == WRITE_A)),   
        .write_addr(write_addr_A),
        .write_data(FFT2_output_imag),
        .read_en(read_en_1 && (read_state == READ_A)),    
        .read_addr(read_addr_A),
        .read_data(read_data2_imag1)
    );

    //Scramble RAM2
    BRAM_64 bram2_real2(
        .clk(clk),
        .write_en(FFT2_output_valid && (write_state == WRITE_B)),   
        .write_addr(write_addr_B),
        .write_data(FFT2_output_real),
        .read_en(read_en_1 && (read_state == READ_B)),   
        .read_addr(read_addr_B),
        .read_data(read_data2_real2)
    );
    BRAM_64 bram2_imag2(
        .clk(clk),
        .write_en(FFT2_output_valid && (write_state == WRITE_B)),   
        .write_addr(write_addr_B),
        .write_data(FFT2_output_imag),
        .read_en(read_en_1 && (read_state == READ_B)),   
        .read_addr(read_addr_B),
        .read_data(read_data2_imag2)
    );
    // write (FSM)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            write_state <= WRITE_A;
            write_done <= 0;
            write_count <= 0;
        end else begin
            case (write_state)
                WRITE_A: begin
                    write_done <= 0;
                    if (FFT_output_valid) begin
                        write_count <= write_count + 1;
                        if (write_count == 63) begin
                            write_done <= 1;
                            write_state <= WRITE_B;
                            write_count <= 0;
                        end
                    end
                end
                WRITE_B: begin
                    write_done <= 0;
                    if (FFT_output_valid) begin
                        write_count <= write_count + 1;
                        if (write_count == 63) begin
                            write_done <= 1;
                            write_state <= WRITE_A;
                            write_count <= 0;
                        end
                    end
                end
            endcase
        end
    end
    reg out_valid;
    // Read (FSM)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            read_state <= READ_IDLE;
            read_en_1 <= 0;
            read_addr_A <= 0;
            read_addr_B <= 0;
            read_count <= 0;
            output_real <= 0;
            output_imag <= 0;
            out_valid <= 0;
        end else begin
            case (read_state)
                READ_IDLE: begin
                    out_valid <= 0;
                    if (write_done) begin
                        if (write_state == WRITE_A) begin
                            read_state <= READ_B;
                        end else begin
                            read_state <= READ_A;
                        end
                        read_en_1 <= 1;
                        read_count <= 0;
                    end
                end
                READ_A: begin
                    if (read_en_1) begin
                        read_addr_A <= read_addr_A + 1;
                        read_count <= read_count + 1;
                        out_valid <= 1;
                        if (read_count == 64) begin
                            read_en_1 <= 0;
                            read_state <= READ_IDLE;
                            read_addr_A <= 0;
                            out_valid <= 0;
                            read_count <= 0;
                        end
                        else if(read_count < 64 && write_done) begin
                            read_state <= READ_A_wait;
                        end
                    end
                end
                READ_A_wait: begin
                    if (read_en_1) begin
                        read_addr_A <= read_addr_A + 1;
                        read_count <= read_count + 1;
                        out_valid <= 1;
                        if (read_count == 64) begin
                            read_en_1 <= 1;
                            read_state <= READ_B;
                            read_addr_A <= 0;
                            out_valid <= 0;
                            read_count <= 0;
                        end
                    end
                end
                READ_B: begin
                    if (read_en_1) begin
                        read_addr_B <= read_addr_B + 1;
                        read_count <= read_count + 1;
                        out_valid <= 1;
                        if (read_count == 64) begin
                            read_en_1 <= 0;
                            read_state <= READ_IDLE;
                            read_addr_B <= 0;
                            out_valid <= 0;
                            read_count <= 0;
                        end
                        else if(read_count < 64 && write_done) begin
                            read_state <= READ_B_wait;
                        end
                    end
                end
                READ_B_wait: begin
                    if (read_en_1) begin
                        read_addr_B <= read_addr_B + 1;
                        read_count <= read_count + 1;
                        out_valid <= 1;
                        if (read_count == 64) begin
                            read_en_1 <= 1;
                            read_state <= READ_A;
                            read_addr_B <= 0;
                            out_valid <= 0;
                            read_count <= 0;
                        end
                    end
                end
                default: begin
                    out_valid <= 0;
                    read_en_1 <= 0;
                    read_count <= 0;
                    read_addr_A <= 0;
                    read_addr_B <= 0;
                    read_state <= READ_IDLE; 
                end
            endcase
        end
    end
    always@(*) begin
        if(read_state == READ_A) begin
            output_real = read_data_real1;
            output_imag = read_data_imag1;
            output1_real = read_data1_real1;
            output1_imag = read_data1_imag1;
            output2_real = read_data2_real1;
            output2_imag = read_data2_imag1;
         end
         else if(read_state == READ_B) begin
            output_real = read_data_real2;
            output_imag = read_data_imag2;
            output1_real = read_data1_real2;
            output1_imag = read_data1_imag2;
            output2_real = read_data2_real2;
            output2_imag = read_data2_imag2;
         end
         else begin
            output_real = 0;
            output_imag = 0;
            output1_real = 0;
            output1_imag = 0;
            output2_real = 0;
            output2_imag = 0;
         end
    end
    
    wire QR_valid;
    wire signed [`FIXED_POINT_WIDTH-1:0] output_R [0:35];
    wire signed [`FIXED_POINT_WIDTH-1:0] output_Q [0:35];
    QR_decomposition qr_inst (
        .clk(clk),
        .rst(rst),
        .input_data(signal0_real),
        .input_valid(H_valid),
        .output_R0(output_R[0]),
        .output_R1(output_R[1]),
        .output_R2(output_R[2]),
        .output_R3(output_R[3]),
        .output_R4(output_R[4]),
        .output_R5(output_R[5]),
        .output_R6(output_R[6]),
        .output_R7(output_R[7]),
        .output_R8(output_R[8]),
        .output_R9(output_R[9]),
        .output_R10(output_R[10]),
        .output_R11(output_R[11]),
        .output_R12(output_R[12]),
        .output_R13(output_R[13]),
        .output_R14(output_R[14]),
        .output_R15(output_R[15]),
        .output_R16(output_R[16]),
        .output_R17(output_R[17]),
        .output_R18(output_R[18]),
        .output_R19(output_R[19]),
        .output_R20(output_R[20]),
        .output_R21(output_R[21]),
        .output_R22(output_R[22]),
        .output_R23(output_R[23]),
        .output_R24(output_R[24]),
        .output_R25(output_R[25]),
        .output_R26(output_R[26]),
        .output_R27(output_R[27]),
        .output_R28(output_R[28]),
        .output_R29(output_R[29]),
        .output_R30(output_R[30]),
        .output_R31(output_R[31]),
        .output_R32(output_R[32]),
        .output_R33(output_R[33]),
        .output_R34(output_R[34]),
        .output_R35(output_R[35]),
        .output_Q0(output_Q[0]),
        .output_Q1(output_Q[1]),
        .output_Q2(output_Q[2]),
        .output_Q3(output_Q[3]),
        .output_Q4(output_Q[4]),
        .output_Q5(output_Q[5]),
        .output_Q6(output_Q[6]),
        .output_Q7(output_Q[7]),
        .output_Q8(output_Q[8]),
        .output_Q9(output_Q[9]),
        .output_Q10(output_Q[10]),
        .output_Q11(output_Q[11]),
        .output_Q12(output_Q[12]),
        .output_Q13(output_Q[13]),
        .output_Q14(output_Q[14]),
        .output_Q15(output_Q[15]),
        .output_Q16(output_Q[16]),
        .output_Q17(output_Q[17]),
        .output_Q18(output_Q[18]),
        .output_Q19(output_Q[19]),
        .output_Q20(output_Q[20]),
        .output_Q21(output_Q[21]),
        .output_Q22(output_Q[22]),
        .output_Q23(output_Q[23]),
        .output_Q24(output_Q[24]),
        .output_Q25(output_Q[25]),
        .output_Q26(output_Q[26]),
        .output_Q27(output_Q[27]),
        .output_Q28(output_Q[28]),
        .output_Q29(output_Q[29]),
        .output_Q30(output_Q[30]),
        .output_Q31(output_Q[31]),
        .output_Q32(output_Q[32]),
        .output_Q33(output_Q[33]),
        .output_Q34(output_Q[34]),
        .output_Q35(output_Q[35]),
        .output_valid(QR_valid)
    );
    reg Detect_en;
    reg [9:0]in_count,out_count;
    wire Detect_out_valid;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            in_count <= 0;
            out_count <= 0;
        end 
        else begin
            if(out_valid)
                in_count <= in_count + 1;
            if(Detect_out_valid)
                out_count <= out_count + 1;
        end
    end
    always @(*) begin
        if(out_count < 128 && in_count == 128) begin //if input done FFT still need to work
            Detect_en = 1;
        end
        else begin
            Detect_en = out_valid;
        end
    end
    assign output_valid = (out_count <= 127) ? Detect_out_valid : 0;
    Detect detect_inst (
        .clk(clk),
        .rst(rst),
        .input_valid(Detect_en),
        .R_valid(QR_valid),
        .Q_valid(QR_valid),
        .signal0_real(output_real),
        .signal0_imag(output_imag),
        .signal1_real(output1_real),
        .signal1_imag(output1_imag),
        .signal2_real(output2_real),
        .signal2_imag(output2_imag),
        .output_R0(output_R[0]),
        .output_R1(output_R[1]),
        .output_R2(output_R[2]),
        .output_R3(output_R[3]),
        .output_R4(output_R[4]),
        .output_R5(output_R[5]),
        .output_R6(output_R[6]),
        .output_R7(output_R[7]),
        .output_R8(output_R[8]),
        .output_R9(output_R[9]),
        .output_R10(output_R[10]),
        .output_R11(output_R[11]),
        .output_R12(output_R[12]),
        .output_R13(output_R[13]),
        .output_R14(output_R[14]),
        .output_R15(output_R[15]),
        .output_R16(output_R[16]),
        .output_R17(output_R[17]),
        .output_R18(output_R[18]),
        .output_R19(output_R[19]),
        .output_R20(output_R[20]),
        .output_R21(output_R[21]),
        .output_R22(output_R[22]),
        .output_R23(output_R[23]),
        .output_R24(output_R[24]),
        .output_R25(output_R[25]),
        .output_R26(output_R[26]),
        .output_R27(output_R[27]),
        .output_R28(output_R[28]),
        .output_R29(output_R[29]),
        .output_R30(output_R[30]),
        .output_R31(output_R[31]),
        .output_R32(output_R[32]),
        .output_R33(output_R[33]),
        .output_R34(output_R[34]),
        .output_R35(output_R[35]),
        .output_Q0(output_Q[0]),
        .output_Q1(output_Q[1]),
        .output_Q2(output_Q[2]),
        .output_Q3(output_Q[3]),
        .output_Q4(output_Q[4]),
        .output_Q5(output_Q[5]),
        .output_Q6(output_Q[6]),
        .output_Q7(output_Q[7]),
        .output_Q8(output_Q[8]),
        .output_Q9(output_Q[9]),
        .output_Q10(output_Q[10]),
        .output_Q11(output_Q[11]),
        .output_Q12(output_Q[12]),
        .output_Q13(output_Q[13]),
        .output_Q14(output_Q[14]),
        .output_Q15(output_Q[15]),
        .output_Q16(output_Q[16]),
        .output_Q17(output_Q[17]),
        .output_Q18(output_Q[18]),
        .output_Q19(output_Q[19]),
        .output_Q20(output_Q[20]),
        .output_Q21(output_Q[21]),
        .output_Q22(output_Q[22]),
        .output_Q23(output_Q[23]),
        .output_Q24(output_Q[24]),
        .output_Q25(output_Q[25]),
        .output_Q26(output_Q[26]),
        .output_Q27(output_Q[27]),
        .output_Q28(output_Q[28]),
        .output_Q29(output_Q[29]),
        .output_Q30(output_Q[30]),
        .output_Q31(output_Q[31]),
        .output_Q32(output_Q[32]),
        .output_Q33(output_Q[33]),
        .output_Q34(output_Q[34]),
        .output_Q35(output_Q[35]),
        .output_num0(output_num0),
        .output_num1(output_num1),
        .output_num2(output_num2),
        .output_valid(Detect_out_valid)
    );
    
   
endmodule
