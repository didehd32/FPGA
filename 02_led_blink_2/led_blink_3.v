`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/11 18:21:46
// Design Name: 
// Module Name: led_blink_3
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


module led_blink_3(
    // input sys_clk,  // Define system clock
    input sys_clk_p,        // 200MHz Positive clock
    input sys_clk_n,        // 200MHz Negative clock
    input rst_n,    // Reset button
    (* mark_debug = "true" *) output reg [3:0] led    // output leds
    );
    wire  sys_clk;  // buffer output
    (* mark_debug = "true" *) reg[31:0] timer_cnt;    // Define Local variable (32 bit counter)

    // Change 차동 클락 -> 단일 클락
    IBUFDS clk_inst (
        .O(sys_clk),        // 내부 로직으로 들어가는 단일 클락
        .I(sys_clk_p),      // 외부에서 들어오는 P 클락
        .IB(sys_clk_n)      // 외부에서 들어오는 N 클락
    );
always@(posedge sys_clk or negedge rst_n)   // while loop

// Define contition
begin
    if (!rst_n) // If board is in reset state,
    begin
        led <= 4'd0;    // 4 leds are 0
        timer_cnt <= 32'd0; // 32 counters are 0
    end
    else if (timer_cnt >= 32'd199_999_999)   // Due to 200MHz
    begin
        led <= ~led;    // Opposite current state
        timer_cnt <= 32'd0;
    end
    else
    begin
        led <= led; // Contain default state
        timer_cnt <= timer_cnt + 32'd1; // Increase 1 count
    end
end
endmodule
