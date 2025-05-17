`timescale 1ns / 1ps
`include "header.vh"

module tb;

    // Parameters
    parameter integer DATA_WIDTH = 13;
    parameter integer DATA_DEPTH = 500;
    parameter integer OUTPUT_DEPTH = 128; // Number of outputs
    parameter integer OUTPUT_BITS = 512; // Total 1-bit outputs

    // Inputs to the DUT
    reg clk;
    reg rst;
    reg input_valid;
    reg weight_valid;
    reg preamble_valid;
    reg H_valid;
    reg [4:0] weight_addr;
    reg [DATA_WIDTH-1:0] signal0_real;
    reg [DATA_WIDTH-1:0] signal0_imag;
    reg [DATA_WIDTH-1:0] signal1_real;
    reg [DATA_WIDTH-1:0] signal1_imag;
    reg [DATA_WIDTH-1:0] signal2_real;
    reg [DATA_WIDTH-1:0] signal2_imag;
    wire output_valid;
    wire [DATA_WIDTH-1:0] output_real;
    wire [DATA_WIDTH-1:0] output_imag;
    wire [DATA_WIDTH-1:0] output1_real;
    wire [DATA_WIDTH-1:0] output1_imag;
    wire [DATA_WIDTH-1:0] output2_real;
    wire [DATA_WIDTH-1:0] output2_imag;
    wire [3:0] output_num0;
    wire [3:0] output_num1;
    wire [3:0] output_num2;
    wire synchronization_valid;

    // Test data
    reg [DATA_WIDTH-1:0] real_mem [0:DATA_DEPTH-1];
    reg [DATA_WIDTH-1:0] imag_mem [0:DATA_DEPTH-1];
    reg [DATA_WIDTH-1:0] real_mem1 [0:DATA_DEPTH-1];
    reg [DATA_WIDTH-1:0] imag_mem1 [0:DATA_DEPTH-1];
    reg [DATA_WIDTH-1:0] real_mem2 [0:DATA_DEPTH-1];
    reg [DATA_WIDTH-1:0] imag_mem2 [0:DATA_DEPTH-1];
    reg [DATA_WIDTH-1:0] out_real [0:OUTPUT_DEPTH-1];
    reg [DATA_WIDTH-1:0] out_imag [0:OUTPUT_DEPTH-1];
    reg [DATA_WIDTH-1:0] out1_real [0:OUTPUT_DEPTH-1];
    reg [DATA_WIDTH-1:0] out1_imag [0:OUTPUT_DEPTH-1];
    reg [DATA_WIDTH-1:0] out2_real [0:OUTPUT_DEPTH-1];
    reg [DATA_WIDTH-1:0] out2_imag [0:OUTPUT_DEPTH-1];
    reg [DATA_WIDTH-1:0] real_weight [0:31];
    reg [DATA_WIDTH-1:0] imag_weight [0:31];
    reg [DATA_WIDTH-1:0] real_preamble [0:63];
    reg [DATA_WIDTH-1:0] imag_preamble [0:63];
    reg signed[DATA_WIDTH-1:0] H0_real [0:2];
    reg signed[DATA_WIDTH-1:0] H0_imag [0:2];
    reg signed[DATA_WIDTH-1:0] H1_real [0:2];
    reg signed[DATA_WIDTH-1:0] H1_imag [0:2];
    reg signed[DATA_WIDTH-1:0] H2_real [0:2];
    reg signed[DATA_WIDTH-1:0] H2_imag [0:2];
    reg [12:0] Tao [0:79];
    reg expected_mem [0:OUTPUT_BITS-1]; // Memory array to hold 1024 binary values
    reg expected_mem1 [0:OUTPUT_BITS-1]; // Memory array to hold 1024 binary values
    reg expected_mem2 [0:OUTPUT_BITS-1]; // Memory array to hold 1024 binary values
    reg [0:OUTPUT_BITS-1] output_mem;   // Stored 1-bit outputs
    reg [0:OUTPUT_BITS-1] output_mem1;   // Stored 1-bit outputs
    reg [0:OUTPUT_BITS-1] output_mem2;   // Stored 1-bit outputs
    integer error_count = 0;            // Error counter
    wire [12:0]tao;

    // Clock generation
    always #5 clk = ~clk;

    // DUT instantiation
    top dut (
        .clk(clk),
        .rst(rst),
        .input_valid(input_valid),
        .weight_valid(weight_valid),
        .preamble_valid(preamble_valid),
        .H_valid(H_valid),
        .signal0_real(signal0_real),
        .signal0_imag(signal0_imag),
        .signal1_real(signal1_real),
        .signal1_imag(signal1_imag),
        .signal2_real(signal2_real),
        .signal2_imag(signal2_imag),
        .weight_addr(weight_addr),
        .output_valid(output_valid),
        .output_real(output_real),
        .output_imag(output_imag),
        .output1_real(output1_real),
        .output1_imag(output1_imag),
        .output2_real(output2_real),
        .output2_imag(output2_imag),
        .output_num0(output_num0),
        .output_num1(output_num1),
        .output_num2(output_num2),
        .tao(tao),
        .synchronization_valid(synchronization_valid)
    );

    // Variables for counting out_valid
    reg [31:0] valid_count;  // Change to reg type
    integer output_index = 0;
    reg [31:0] tao_count;

    // Testbench initialization
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        weight_valid = 0;
        input_valid = 0;
        signal0_real = 0;
        signal0_imag = 0;
        signal1_real = 0;
        signal1_imag = 0;
        signal2_real = 0;
        signal2_imag = 0;
        valid_count = 0;
        preamble_valid = 0;
        H_valid = 0;

        // Load test data
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/input0_real_binary.txt", real_mem);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/input0_imag_binary.txt", imag_mem);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/input1_real_binary.txt", real_mem1);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/input1_imag_binary.txt", imag_mem1);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/input2_real_binary.txt", real_mem2);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/input2_imag_binary.txt", imag_mem2);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/weight_real_binary.txt", real_weight);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/weight_imag_binary.txt", imag_weight);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/long_preamble_real_binary.txt", real_preamble);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/long_preamble_imag_binary.txt", imag_preamble);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/H0_real_binary.txt", H0_real);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/H0_imag_binary.txt", H0_imag);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/H1_real_binary.txt", H1_real);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/H1_imag_binary.txt", H1_imag);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/H2_real_binary.txt", H2_real);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/H2_imag_binary.txt", H2_imag);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/random_numbers0.txt", expected_mem);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/random_numbers1.txt", expected_mem1);
        $readmemb("D:/DCIC_Verilog/DCIC_final_project/DCIC_final_project.srcs/sim_1/new/random_numbers2.txt", expected_mem2);

        // Reset
        #10 rst = 0;

        // Simulate weight loading
        weight_valid = 1;
        for (integer i = 0; i < 32; i = i + 1) begin
            signal0_real = real_weight[i];
            signal0_imag = imag_weight[i];
            weight_addr = i;
            #10; // Wait for one clock cycle
        end
        weight_valid = 0;
        
        preamble_valid = 1;
        for (integer i = 0; i < 64; i = i + 1) begin
            signal0_real = real_preamble[i];
            signal0_imag = imag_preamble[i];
            #10; // Wait for one clock cycle
        end
        preamble_valid = 0;
        
        H_valid = 1;
        for (integer i = 0; i < 3; i = i + 1) begin
            signal0_real = H0_real[i];
            #10; // Wait for one clock cycle
        end
        for (integer i = 0; i < 3; i = i + 1) begin
            signal0_real = H1_real[i];
            #10; // Wait for one clock cycle
        end
        for (integer i = 0; i < 3; i = i + 1) begin
            signal0_real = H2_real[i];
            #10; // Wait for one clock cycle
        end
        for (integer i = 0; i < 3; i = i + 1) begin
            signal0_real = H0_imag[i];
            #10; // Wait for one clock cycle
        end
        for (integer i = 0; i < 3; i = i + 1) begin
            signal0_real = H1_imag[i];
            #10; // Wait for one clock cycle
        end
        for (integer i = 0; i < 3; i = i + 1) begin
            signal0_real = H2_imag[i];
            #10; // Wait for one clock cycle
        end
        H_valid = 0;

        // Simulate input signals
        input_valid = 1;
        for (integer i = 0; i < DATA_DEPTH; i = i + 1) begin
            signal0_real = real_mem[i];
            signal0_imag = imag_mem[i];
            signal1_real = real_mem1[i];
            signal1_imag = imag_mem1[i];
            signal2_real = real_mem2[i];
            signal2_imag = imag_mem2[i];
            #10; // Wait for one clock cycle
        end
        input_valid = 0;
        
        // Wait for out_valid to trigger the finish condition
        wait(valid_count >= OUTPUT_DEPTH); // Wait until all outputs are collected
        #50; // Extra delay to ensure all outputs are processed
        
        // Compare stored outputs with expected data
        
        for (integer i = 0; i < OUTPUT_BITS; i = i + 1) begin
            if (output_mem[i] !== expected_mem[i]) begin
                error_count = error_count + 1; // Increment error count if mismatch
            end
            if (output_mem1[i] !== expected_mem1[i]) begin
                error_count = error_count + 1; // Increment error count if mismatch
            end
            if (output_mem2[i] !== expected_mem2[i]) begin
                error_count = error_count + 1; // Increment error count if mismatch
            end
            $display("%5d | %b         | %b         | %b          | %b           | %b          | %b",
                 i, output_mem[i], expected_mem[i], output_mem1[i], expected_mem1[i], output_mem2[i], expected_mem2[i]);
        end
        

        // Print error rate
        $display("Total Errors: %0d out of %0d", error_count, OUTPUT_BITS*3);
        $display("Error Rate: %f%%", (error_count * 100.0) / OUTPUT_BITS/3);
        $writememb("Tao_output.txt", Tao);
        $writememb("out_real.txt", out_real);
        $writememb("out_imag.txt", out_imag);
        
        $finish; // End simulation
    end
    
    // Monitor out_valid signal and store outputs
    always @(posedge clk or posedge rst) begin
        
        if (rst) begin
            valid_count <= 0; // Reset valid_count when rst is high
            output_index <= 0; // Reset output index
        end else if (output_valid) begin
            valid_count <= valid_count + 1; // Increment valid_count when out_valid is high
            // Store output_num into 1-bit output_mem
            output_mem[output_index * 4 + 0] <= output_num0[0];
            output_mem[output_index * 4 + 1] <= output_num0[1];
            output_mem[output_index * 4 + 2] <= output_num0[2];
            output_mem[output_index * 4 + 3] <= output_num0[3];
            output_mem1[output_index * 4 + 0] <= output_num1[0];
            output_mem1[output_index * 4 + 1] <= output_num1[1];
            output_mem1[output_index * 4 + 2] <= output_num1[2];
            output_mem1[output_index * 4 + 3] <= output_num1[3];
            output_mem2[output_index * 4 + 0] <= output_num2[0];
            output_mem2[output_index * 4 + 1] <= output_num2[1];
            output_mem2[output_index * 4 + 2] <= output_num2[2];
            output_mem2[output_index * 4 + 3] <= output_num2[3];
            out_real[output_index] <= output_real;
            out_imag[output_index] <= output_imag;
            output_index <= output_index + 1; // Increment output index
        end
        
        if (rst) begin
            tao_count <= 0; // Reset valid_count when rst is high
        end
        else if(synchronization_valid) begin
            Tao[tao_count] <= tao;
            tao_count <= tao_count + 1;
        end
    end
    // Monitor outputs
    initial begin
        $monitor("Time: %0d, out_valid: %b, valid_count: %0d, output_num: %b", 
                  $time, output_valid, valid_count, output_num0);
    end
    
    endmodule
