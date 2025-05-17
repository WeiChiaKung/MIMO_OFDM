`timescale 1ns / 1ps
`include "header.vh"
module FIFO_coarse(
    input wire clk,                
    input wire rst,                
    input wire w_en,              
    input wire r_en,              
    input wire [`FIXED_POINT_WIDTH-1:0] din, 
    output reg [`FIXED_POINT_WIDTH-1:0] dout, 
    output reg [8:0] count, //data count in FIFO
    output reg r_valid, //Read valid
    output full, //FIFO Full              
    output empty //FIFO Empty            
);

    reg [`FIXED_POINT_WIDTH-1:0] fifo_mem[219:0];

    reg [8:0] w_ptr; // write pointer
    reg [8:0] r_ptr; // read pointer

    
    integer i;
    always @(posedge clk or posedge rst) begin
        // initialize FIFO
        if(rst) begin
            w_ptr <= 0;
            r_ptr <= 0;
            count <= 0;
            dout <= 0;
            r_valid <= 0;
            for (i = 0; i < `FIFO_DEPTH; i = i + 1) begin
                fifo_mem[i] <= 0;
            end
        end 
        else begin
            if(w_en && r_en && w_ptr != `FIFO_DEPTH-1 && r_ptr != `FIFO_DEPTH-1) begin
                fifo_mem[w_ptr] <= din;
                dout <= fifo_mem[r_ptr];
                r_valid <= 1;
                w_ptr <= w_ptr + 1;
                r_ptr <= r_ptr + 1;
                count <= count;  
            end
            else if(w_en && r_en && w_ptr == `FIFO_DEPTH-1 && r_ptr != `FIFO_DEPTH-1) begin
                fifo_mem[w_ptr] <= din;
                dout <= fifo_mem[r_ptr];
                r_valid <= 1;
                w_ptr <= 0;
                r_ptr <= r_ptr + 1;
                count <= count;  
            end
            else if(w_en && r_en && w_ptr != `FIFO_DEPTH-1 && r_ptr == `FIFO_DEPTH-1) begin
                fifo_mem[w_ptr] <= din;
                dout <= fifo_mem[r_ptr];
                r_valid <= 1;
                w_ptr <= w_ptr + 1;
                r_ptr <= 0;
                count <= count;  
            end
            else if(w_en && !full && w_ptr != `FIFO_DEPTH-1) begin
                fifo_mem[w_ptr] <= din; 
                w_ptr <= w_ptr + 1;    
                count <= count + 1;      
            end
            else if(w_en && !full && w_ptr == `FIFO_DEPTH-1) begin
                fifo_mem[w_ptr] <= din; 
                w_ptr <= 0;    
                count <= count + 1;      
            end
            else if(r_en && !empty && r_ptr != `FIFO_DEPTH-1) begin
                dout <= fifo_mem[r_ptr]; 
                r_valid <= 1;
                r_ptr <= r_ptr + 1;     
                count <= count - 1;       
            end
            else if(r_en && !empty && r_ptr == `FIFO_DEPTH-1) begin
                dout <= fifo_mem[r_ptr];
                r_valid <= 1; 
                r_ptr <= 0;     
                count <= count - 1;       
            end
            else begin
                fifo_mem[w_ptr] <= fifo_mem[w_ptr];
                dout <= fifo_mem[r_ptr];
                w_ptr <= w_ptr;
                r_ptr <= r_ptr;
                count <= count;
                r_valid <= 0;
            end      
        end
    end
    assign full = (count == `FIFO_DEPTH); 
    assign empty = (count == 0);
endmodule
