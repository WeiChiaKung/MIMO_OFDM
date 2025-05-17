`timescale 1ns / 1ps
`include "header.vh"
module QR_decomposition(
    input clk,
    input rst,
    input signed[`FIXED_POINT_WIDTH-1:0]input_data,
    input input_valid,
    output [`FIXED_POINT_WIDTH-1:0]output_R0,
    output [`FIXED_POINT_WIDTH-1:0]output_R1,
    output [`FIXED_POINT_WIDTH-1:0]output_R2,
    output [`FIXED_POINT_WIDTH-1:0]output_R3,
    output [`FIXED_POINT_WIDTH-1:0]output_R4,
    output [`FIXED_POINT_WIDTH-1:0]output_R5,
    output [`FIXED_POINT_WIDTH-1:0]output_R6,
    output [`FIXED_POINT_WIDTH-1:0]output_R7,
    output [`FIXED_POINT_WIDTH-1:0]output_R8,
    output [`FIXED_POINT_WIDTH-1:0]output_R9,
    output [`FIXED_POINT_WIDTH-1:0]output_R10,
    output [`FIXED_POINT_WIDTH-1:0]output_R11,
    output [`FIXED_POINT_WIDTH-1:0]output_R12,
    output [`FIXED_POINT_WIDTH-1:0]output_R13,
    output [`FIXED_POINT_WIDTH-1:0]output_R14,
    output [`FIXED_POINT_WIDTH-1:0]output_R15,
    output [`FIXED_POINT_WIDTH-1:0]output_R16,
    output [`FIXED_POINT_WIDTH-1:0]output_R17,
    output [`FIXED_POINT_WIDTH-1:0]output_R18,
    output [`FIXED_POINT_WIDTH-1:0]output_R19,
    output [`FIXED_POINT_WIDTH-1:0]output_R20,
    output [`FIXED_POINT_WIDTH-1:0]output_R21,
    output [`FIXED_POINT_WIDTH-1:0]output_R22,
    output [`FIXED_POINT_WIDTH-1:0]output_R23,
    output [`FIXED_POINT_WIDTH-1:0]output_R24,
    output [`FIXED_POINT_WIDTH-1:0]output_R25,
    output [`FIXED_POINT_WIDTH-1:0]output_R26,
    output [`FIXED_POINT_WIDTH-1:0]output_R27,
    output [`FIXED_POINT_WIDTH-1:0]output_R28,
    output [`FIXED_POINT_WIDTH-1:0]output_R29,
    output [`FIXED_POINT_WIDTH-1:0]output_R30,
    output [`FIXED_POINT_WIDTH-1:0]output_R31,
    output [`FIXED_POINT_WIDTH-1:0]output_R32,
    output [`FIXED_POINT_WIDTH-1:0]output_R33,
    output [`FIXED_POINT_WIDTH-1:0]output_R34,
    output [`FIXED_POINT_WIDTH-1:0]output_R35,
    output [`FIXED_POINT_WIDTH-1:0]output_Q0,
    output [`FIXED_POINT_WIDTH-1:0]output_Q1,
    output [`FIXED_POINT_WIDTH-1:0]output_Q2,
    output [`FIXED_POINT_WIDTH-1:0]output_Q3,
    output [`FIXED_POINT_WIDTH-1:0]output_Q4,
    output [`FIXED_POINT_WIDTH-1:0]output_Q5,
    output [`FIXED_POINT_WIDTH-1:0]output_Q6,
    output [`FIXED_POINT_WIDTH-1:0]output_Q7,
    output [`FIXED_POINT_WIDTH-1:0]output_Q8,
    output [`FIXED_POINT_WIDTH-1:0]output_Q9,
    output [`FIXED_POINT_WIDTH-1:0]output_Q10,
    output [`FIXED_POINT_WIDTH-1:0]output_Q11,
    output [`FIXED_POINT_WIDTH-1:0]output_Q12,
    output [`FIXED_POINT_WIDTH-1:0]output_Q13,
    output [`FIXED_POINT_WIDTH-1:0]output_Q14,
    output [`FIXED_POINT_WIDTH-1:0]output_Q15,
    output [`FIXED_POINT_WIDTH-1:0]output_Q16,
    output [`FIXED_POINT_WIDTH-1:0]output_Q17,
    output [`FIXED_POINT_WIDTH-1:0]output_Q18,
    output [`FIXED_POINT_WIDTH-1:0]output_Q19,
    output [`FIXED_POINT_WIDTH-1:0]output_Q20,
    output [`FIXED_POINT_WIDTH-1:0]output_Q21,
    output [`FIXED_POINT_WIDTH-1:0]output_Q22,
    output [`FIXED_POINT_WIDTH-1:0]output_Q23,
    output [`FIXED_POINT_WIDTH-1:0]output_Q24,
    output [`FIXED_POINT_WIDTH-1:0]output_Q25,
    output [`FIXED_POINT_WIDTH-1:0]output_Q26,
    output [`FIXED_POINT_WIDTH-1:0]output_Q27,
    output [`FIXED_POINT_WIDTH-1:0]output_Q28,
    output [`FIXED_POINT_WIDTH-1:0]output_Q29,
    output [`FIXED_POINT_WIDTH-1:0]output_Q30,
    output [`FIXED_POINT_WIDTH-1:0]output_Q31,
    output [`FIXED_POINT_WIDTH-1:0]output_Q32,
    output [`FIXED_POINT_WIDTH-1:0]output_Q33,
    output [`FIXED_POINT_WIDTH-1:0]output_Q34,
    output [`FIXED_POINT_WIDTH-1:0]output_Q35,
    output reg output_valid
    );
    localparam state_input = 2'b00;
    localparam state_compute = 2'b01;
    localparam state_output = 2'b10;
    reg [4:0] cnt;
    reg [2:0] i_cnt;
    reg [5:0] i_index;
    reg [2:0] j_cnt;
    reg [5:0] j_index;
    reg [2:0] k_cnt;
    reg [5:0] k_index1;
    reg [5:0] k_index2;
    reg signed[`FIXED_POINT_WIDTH-1:0] H [0:35];
    reg signed[`FIXED_POINT_WIDTH-1:0] Q_T [0:35];
    reg signed[`FIXED_POINT_WIDTH-1:0] Hvalue_i;
    reg signed[`FIXED_POINT_WIDTH-1:0] Hvalue_j;
    reg signed[`FIXED_POINT_WIDTH-1:0] Qvalue_i;
    reg signed[`FIXED_POINT_WIDTH-1:0] Qvalue_j;
    wire signed[`FIXED_POINT_WIDTH-1:0] V_x_in;
    wire signed[`FIXED_POINT_WIDTH-1:0] V_y_in;
    wire signed[`FIXED_POINT_WIDTH-1:0] Hvalue_i_temp;
    wire signed[`FIXED_POINT_WIDTH-1:0] Hvalue_j_temp;
    wire signed[`FIXED_POINT_WIDTH-1:0] Qvalue_i_temp;
    wire signed[`FIXED_POINT_WIDTH-1:0] Qvalue_j_temp;
    wire signed[`FIXED_POINT_WIDTH-1:0] Hvalue_i_out;
    wire signed[`FIXED_POINT_WIDTH-1:0] Hvalue_j_out;
    wire signed[`FIXED_POINT_WIDTH-1:0] Qvalue_i_out;
    wire signed[`FIXED_POINT_WIDTH-1:0] Qvalue_j_out;
    reg [1:0]state;
    reg signed[`FIXED_POINT_WIDTH-1:0] init_Hvalue_i_out;
    reg signed[`FIXED_POINT_WIDTH-1:0] init_Hvalue_j_out;
    wire signed[16:0] degree;
    wire rotate_temp;
    reg rotate;
    assign V_x_in = (k_cnt > 0) ? init_Hvalue_i_out : ((H[i_index][`FIXED_POINT_WIDTH-1] == 1) ? -H[i_index] : H[i_index]);
    assign V_y_in = (k_cnt > 0) ? init_Hvalue_j_out : ((H[i_index][`FIXED_POINT_WIDTH-1] == 1) ? -H[j_index] : H[j_index]);
    assign rotate_temp = (H[i_index][`FIXED_POINT_WIDTH-1] == 1) ? 1 : 0;
    assign Hvalue_i_out = (H[i_index][`FIXED_POINT_WIDTH-1] == 1 && k_cnt == 0) 
                          ? -Hvalue_i_temp 
                          : ((H[i_index][`FIXED_POINT_WIDTH-1] == 0 && k_cnt == 0) 
                             ? Hvalue_i_temp 
                             : ((rotate == 1) 
                                ? -Hvalue_i_temp 
                                : Hvalue_i_temp));
    
    assign Hvalue_j_out = (k_cnt == i_cnt) 
                          ? 0 
                          : (H[i_index][`FIXED_POINT_WIDTH-1] == 1 && k_cnt == 0) 
                            ? -Hvalue_j_temp 
                            : (H[i_index][`FIXED_POINT_WIDTH-1] == 0 && k_cnt == 0) 
                              ? Hvalue_j_temp 
                              : (rotate == 1) 
                                ? -Hvalue_j_temp 
                                : Hvalue_j_temp;
    
    assign Qvalue_i_out = (H[i_index][`FIXED_POINT_WIDTH-1] == 1 && k_cnt == 0) 
                          ? -Qvalue_i_temp 
                          : ((H[i_index][`FIXED_POINT_WIDTH-1] == 0 && k_cnt == 0) 
                             ? Qvalue_i_temp 
                             : ((rotate == 1) 
                                ? -Qvalue_i_temp 
                                : Qvalue_i_temp));
    
    assign Qvalue_j_out = (H[i_index][`FIXED_POINT_WIDTH-1] == 1 && k_cnt == 0) 
                          ? -Qvalue_j_temp 
                          : ((H[i_index][`FIXED_POINT_WIDTH-1] == 0 && k_cnt == 0) 
                             ? Qvalue_j_temp 
                             : ((rotate == 1) 
                                ? -Qvalue_j_temp 
                                : Qvalue_j_temp));
    CORDIC_V_mode cordic_v_inst (
        .x(V_x_in),
        .y(V_y_in),
        .input_degree(17'd0),
        .output_degree(degree)
    );
    CORDIC_R_mode cordic_r_inst (
        .x(H[k_index1]),
        .y(H[k_index2]),
        .input_degree(-degree),
        .output_x(Hvalue_i_temp),
        .output_y(Hvalue_j_temp)
    );
    CORDIC_R_mode cordic_r_inst1 (
        .x(Q_T[k_index1]),
        .y(Q_T[k_index2]),
        .input_degree(-degree),
        .output_x(Qvalue_i_temp),
        .output_y(Qvalue_j_temp)
    );
    reg [5:0]i_index_temp,j_index_temp;
    always@(*) begin
        i_index_temp = i_cnt * 6;
        j_index_temp = j_cnt * 6;
        i_index = i_index_temp + i_cnt;
        j_index = j_index_temp + i_cnt;
        k_index1 = i_index_temp + k_cnt;
        k_index2 = j_index_temp + k_cnt;
    end
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 36; i = i + 1) begin
                H[i] <= 13'b0;
                if(i == 0 || i == 7 || i == 14 || i == 21 || i == 28 || i == 35) begin
                    Q_T[i] <= 13'b0001000000000;
                end
                else begin
                    Q_T[i] <= 0;
                end
            end
            state <= state_input;
            cnt <= 0;
            i_cnt <= 0;
            j_cnt <= 1;
            k_cnt <= 0;
            output_valid <= 0;
            init_Hvalue_i_out <= 0;
            init_Hvalue_j_out <= 0;
            rotate <= 0;
        end 
        else begin
            output_valid <= 0;
            if(input_valid && state == state_input && cnt<3) begin
                H[cnt*2] <= input_data; 
                H[cnt*2 + 7] <= input_data;
                cnt <= cnt + 1;
            end
            else if(input_valid && state == state_input && cnt<6) begin
                H[cnt*2 + 6] <= input_data; 
                H[cnt*2 + 13] <= input_data;
                cnt <= cnt + 1;
            end
            else if(input_valid && state == state_input && cnt<9) begin
                H[cnt*2 + 12] <= input_data; 
                H[cnt*2 + 19] <= input_data;
                cnt <= cnt + 1;
            end
            else if(input_valid && state == state_input && cnt<12) begin
                H[(cnt-9)*2+1] <= -input_data; 
                H[(cnt-9)*2+6] <= input_data;
                cnt <= cnt + 1;
            end
            else if(input_valid && state == state_input && cnt<15) begin
                H[(cnt-9)*2+7] <= -input_data; 
                H[(cnt-9)*2+12] <= input_data;
                cnt <= cnt + 1;
            end
            else if(input_valid && state == state_input && cnt<18) begin
                H[(cnt-9)*2+13] <= -input_data; 
                H[(cnt-9)*2+18] <= input_data;
                cnt <= cnt + 1;
            end
            else if(cnt==18 && state == state_input) begin
                state <= state_compute;
            end
            else if(state == state_compute && j_cnt <= 5 && k_cnt == 0) begin
                H[k_index1] <= Hvalue_i_out;
                H[k_index2] <= Hvalue_j_out;
                Q_T[k_index1] <= Qvalue_i_out;
                Q_T[k_index2] <= Qvalue_j_out;
                rotate <= rotate_temp;
                init_Hvalue_i_out <= V_x_in;
                init_Hvalue_j_out <= V_y_in;
                k_cnt <= k_cnt + 1;
            end
            else if(state == state_compute && j_cnt < 5 && k_cnt <5) begin
                H[k_index1] <= Hvalue_i_out;
                H[k_index2] <= Hvalue_j_out;
                Q_T[k_index1] <= Qvalue_i_out;
                Q_T[k_index2] <= Qvalue_j_out;
                k_cnt <= k_cnt + 1;
            end
            else if(state == state_compute && j_cnt < 5 &&  k_cnt == 5) begin
                H[k_index1] <= Hvalue_i_out;
                H[k_index2] <= Hvalue_j_out;
                Q_T[k_index1] <= Qvalue_i_out;
                Q_T[k_index2] <= Qvalue_j_out;
                k_cnt <= 0;
                j_cnt <= j_cnt + 1;
            end
            else if(state == state_compute && j_cnt == 5 &&  k_cnt < 5) begin
                H[k_index1] <= Hvalue_i_out;
                H[k_index2] <= Hvalue_j_out;
                Q_T[k_index1] <= Qvalue_i_out;
                Q_T[k_index2] <= Qvalue_j_out;
                k_cnt <= k_cnt + 1;
            end
            else if(state == state_compute && j_cnt == 5 &&  k_cnt == 5) begin
                H[k_index1] <= Hvalue_i_out;
                H[k_index2] <= Hvalue_j_out;
                Q_T[k_index1] <= Qvalue_i_out;
                Q_T[k_index2] <= Qvalue_j_out;
                k_cnt <= 0;
                i_cnt <= i_cnt + 1;
                j_cnt <= i_cnt + 2;
            end
            else if(state == state_compute && j_cnt == 6) begin
                state <= state_output;
                cnt <= 0;
                i_cnt <= 0;
                j_cnt <= 1;
                k_cnt <= 0;
            end
            else if(state == state_output) begin
                output_valid <= 1;
            end
        end
    end
    assign output_R0 = H[0];
    assign output_R1 = H[1];
    assign output_R2 = H[2];
    assign output_R3 = H[3];
    assign output_R4 = H[4];
    assign output_R5 = H[5];
    assign output_R6 = H[6];
    assign output_R7 = H[7];
    assign output_R8 = H[8];
    assign output_R9 = H[9];
    assign output_R10 = H[10];
    assign output_R11 = H[11];
    assign output_R12 = H[12];
    assign output_R13 = H[13];
    assign output_R14 = H[14];
    assign output_R15 = H[15];
    assign output_R16 = H[16];
    assign output_R17 = H[17];
    assign output_R18 = H[18];
    assign output_R19 = H[19];
    assign output_R20 = H[20];
    assign output_R21 = H[21];
    assign output_R22 = H[22];
    assign output_R23 = H[23];
    assign output_R24 = H[24];
    assign output_R25 = H[25];
    assign output_R26 = H[26];
    assign output_R27 = H[27];
    assign output_R28 = H[28];
    assign output_R29 = H[29];
    assign output_R30 = H[30];
    assign output_R31 = H[31];
    assign output_R32 = H[32];
    assign output_R33 = H[33];
    assign output_R34 = H[34];
    assign output_R35 = H[35];

    assign output_Q0 = Q_T[0];
    assign output_Q1 = Q_T[1];
    assign output_Q2 = Q_T[2];
    assign output_Q3 = Q_T[3];
    assign output_Q4 = Q_T[4];
    assign output_Q5 = Q_T[5];
    assign output_Q6 = Q_T[6];
    assign output_Q7 = Q_T[7];
    assign output_Q8 = Q_T[8];
    assign output_Q9 = Q_T[9];
    assign output_Q10 = Q_T[10];
    assign output_Q11 = Q_T[11];
    assign output_Q12 = Q_T[12];
    assign output_Q13 = Q_T[13];
    assign output_Q14 = Q_T[14];
    assign output_Q15 = Q_T[15];
    assign output_Q16 = Q_T[16];
    assign output_Q17 = Q_T[17];
    assign output_Q18 = Q_T[18];
    assign output_Q19 = Q_T[19];
    assign output_Q20 = Q_T[20];
    assign output_Q21 = Q_T[21];
    assign output_Q22 = Q_T[22];
    assign output_Q23 = Q_T[23];
    assign output_Q24 = Q_T[24];
    assign output_Q25 = Q_T[25];
    assign output_Q26 = Q_T[26];
    assign output_Q27 = Q_T[27];
    assign output_Q28 = Q_T[28];
    assign output_Q29 = Q_T[29];
    assign output_Q30 = Q_T[30];
    assign output_Q31 = Q_T[31];
    assign output_Q32 = Q_T[32];
    assign output_Q33 = Q_T[33];
    assign output_Q34 = Q_T[34];
    assign output_Q35 = Q_T[35];
endmodule