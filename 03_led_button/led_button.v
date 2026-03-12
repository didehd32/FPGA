`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/12 14:44:05
// Design Name: 
// Module Name: led_button
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


module led_button(
    input clk_p,        // 200MHz Positive clock
    input clk_n,        // 200MHz Negative clock
    input [1:0] btn,
    output [1:0] led
    );
    wire  clk;  // buffer output
    reg [1:0] led_1;
    reg [1:0] led_2;
    
     // Change 차동 클락 -> 단일 클락
    IBUFDS clk_inst (
        .O(clk),        // 내부 로직으로 들어가는 단일 클락
        .I(clk_p),      // 외부에서 들어오는 P 클락
        .IB(clk_n)      // 외부에서 들어오는 N 클락
    );

always@(posedge clk)
begin
    led_1 <= btn;
end

always@(posedge clk)
begin
    led_2 <= led_1;
end

assign led = led_2;
endmodule
