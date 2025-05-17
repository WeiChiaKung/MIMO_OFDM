module mult_accum_6 (
    input signed [12:0] in1,  
    input signed [12:0] in2,
    input signed [12:0] in3,
    input signed [12:0] in4,
    input signed [12:0] in5,
    input signed [12:0] in6,
    input signed [12:0] in7,
    input signed [12:0] in8,
    input signed [12:0] in9,
    input signed [12:0] in10,
    input signed [12:0] in11,
    input signed [12:0] in12,
    output signed [12:0] result 
);
    wire signed [25:0] mult1, mult2, mult3, mult4, mult5, mult6, result_temp, result_temp_neg;
    
    assign mult1 = in1 * in2;
    assign mult2 = in3 * in4;
    assign mult3 = in5 * in6;
    assign mult4 = in7 * in8;
    assign mult5 = in9 * in10;
    assign mult6 = in11 * in12;

    // ¥[Á`­¼¿n
    assign result_temp = mult1 + mult2 + mult3 + mult4 + mult5 + mult6;
    assign result_temp_neg = -result_temp;
    assign result = (result_temp[25] == 1)?~(result_temp_neg[21:9]-1):result_temp[21:9];

endmodule

