`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Sasisekhar Mangalam Govind
// 
// Create Date: 27.10.2023 00:37:33
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MAC(
    input clk,
    input rst,
    input en,
    input [7:0] B,
    input [7:0] C,
    output [15:0] A
    );
    
    wire [15:0] product;
    reg [15:0] accumulator;
    
    hardware_multiplier mult_0 (
        .a(B),
        .b(C),
        .clk(clk),
        .nreset(~rst),
        .r(product)
    );
    
    always @(posedge clk) begin
        if(rst) begin
            accumulator = 0;
        end
        else begin
            accumulator <= (en)? accumulator + product : accumulator;
        end
    end
    
    assign A = accumulator;
    
endmodule

