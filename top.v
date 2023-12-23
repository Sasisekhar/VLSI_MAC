`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.12.2023 16:39:42
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


module top(
    input wire clk,     // Clock input
    input wire rst,     // Reset input
    input wire rx,      // UART receive line
    input wire display_sel,
    output reg [6:0] Seven_Seg,    // 7-segment display output
    output reg digit_1,
    output reg digit_2,
    output reg digit_3,
    output reg digit_4
);

// Internal signals
wire [7:0] uart_data;

reg [7:0] first_byte;  // Register to store the first byte
reg [7:0] second_byte; // Register to store the second byte

wire [6:0] dig_1;
wire [6:0] dig_2;
wire [6:0] dig_3;
wire [6:0] dig_4;

wire ready;

wire en;
assign en = 1'b1;

// Instantiate UART Receiver
Uart8 uart0 (
    .clk(clk),
    .rxEn(en),
    .rx(rx),
    .out(uart_data),
    .rxDone(ready)
);

reg [1 : 0] byte_sel = 2'b0;
reg [7 : 0] a = 8'b0;
reg [7 : 0] b = 8'b0;

reg mac_en = 1'b0;
wire [15 : 0] mac_out;

assign rx_ready = ready;
assign mac_enable = mac_en;

reg [31 : 0] clk_divide;
reg [8 : 0] counter;
reg [1 : 0] display;

wire [15 : 0] display_data;

assign display_data = (display_sel)? mac_out : {a, b}; 

MAC mac0(
    .clk(clk),
    .rst(rst),
    .en(mac_en),
    .B(a),
    .C(b),
    .A(mac_out)
);

// Instantiate 7-Segment Display Driver
seg7_display disp0 (
    .binary_in(display_data[3 : 0]), // Assuming we're only displaying the lower 4 bits
    .seg(dig_1)
);

// Instantiate 7-Segment Display Driver
seg7_display disp1 (
    .binary_in(display_data[7 : 4]), // Assuming we're only displaying the lower 4 bits
    .seg(dig_2)
);

// Instantiate 7-Segment Display Driver
seg7_display disp2 (
    .binary_in(display_data[11 : 8]), // Assuming we're only displaying the lower 4 bits
    .seg(dig_3)
);

// Instantiate 7-Segment Display Driver
seg7_display disp4 (
    .binary_in(display_data[15 : 12]), // Assuming we're only displaying the lower 4 bits
    .seg(dig_4)
);
 
always @(posedge clk) begin

    if(mac_en) begin
        mac_en <= 1'b0;
    end else if(rst) begin
        mac_en <= 1'b0;
        clk_divide <= 1'b0;
        byte_sel <= 1'b0;
    end else if(ready) begin
        case(byte_sel)
            1'b0: begin
                        if(uart_data != b) begin
                            a = uart_data;
                            byte_sel <=1'b1;
                        end
                    end
            1'b1:  begin
                        if(uart_data != a) begin
                            b = uart_data;
                            mac_en <= 1'b1;
                            byte_sel <= 1'b0;
                        end
                    end
        endcase
    end
end

always @(posedge clk) begin
    if(rst) begin
        counter <= 8'b0;
        display <= 0;
    end else if(counter == 8'hFF) begin
        counter <= 8'b0;
        
        case(display)
            2'b00: begin
                        digit_4 <= 1'b1;
                        digit_3 <= 1'b0;
                        digit_2 <= 1'b0;
                        digit_1 <= 1'b0;
                        Seven_Seg <= dig_1;
                    end
            2'b01: begin
                        digit_4 <= 1'b0;
                        digit_3 <= 1'b1;
                        digit_2 <= 1'b0;
                        digit_1 <= 1'b0;
                        Seven_Seg <= dig_2;
                    end         
            2'b10: begin
                        digit_4 <= 1'b0;
                        digit_3 <= 1'b0;
                        digit_2 <= 1'b1;
                        digit_1 <= 1'b0;
                        Seven_Seg <= dig_3;
                    end
            2'b11: begin
                        digit_4 <= 1'b0;
                        digit_3 <= 1'b0;
                        digit_2 <= 1'b0;
                        digit_1 <= 1'b1;
                        Seven_Seg <= dig_4;
                    end
        endcase
            
        display <= display + 2'b1;
        
    end else begin
        counter <= counter + 8'b1;
    end
end

endmodule

