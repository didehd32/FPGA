`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/17 15:56:05
// Design Name: 
// Module Name: burst
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

module burst(
    input clk_p,        // 200MHz Positive clock
    input clk_n,        // 200MHz Negative clock
    input rst_n,
    //input [31:0] delay_i,      // python input
    output [1:0] buz_o
    );

    wire clk;  // buffer output
    reg [19:0] count_1 = 20'd0;   // 20bit counter
    reg [19:0] count_2 = 20'd0;   // 20bit counter
    reg buz_o_temp_0;
    reg buz_o_temp_1;

    reg [31:0] freq_1 = 32'd20_000_000;     // buzzer 1 delay (0.1s)
    reg [31:0] freq_2 = 32'd2_000_000;     // buzzer 1 delay (0.01s)
    reg [31:0] freq_1_t = 0;     // delay timer for buzzer 1
    reg [31:0] freq_2_t = 0;     // delay timer for buzzer 2
    reg [2:0] beep_count_1 = 0;   // temp value : 5 cycle for buzzer 1
    reg [3:0] beep_count_2 = 0;   // temp value : 10 cycle for buzzer 2
    reg freq_on_1;
    reg freq_on_2;
    reg [31:0] prt_t = 32'd1_000_000_000;   // PRT timer for buzzers (5s)
    reg [31:0] prt_cnt = 0;                 // count PRT timer

     // Change 차동 클락 -> 단일 클락
    IBUFDS clk_inst (
        .O(clk),        // 내부 로직으로 들어가는 단일 클락
        .I(clk_p),      // 외부에서 들어오는 P 클락
        .IB(clk_n)      // 외부에서 들어오는 N 클락
    );

// Define PRT for all buzzers
always @(posedge clk) begin
    if (!rst_n) begin
        prt_cnt <= 0;
    end
    else begin
        if (prt_cnt >= prt_t - 1) begin
            prt_cnt <= 0;
        end
        else begin
            prt_cnt <= prt_cnt + 1;
        end
    end
end

// Define buzzer 1 condition
always @(posedge clk)
begin
    if (!rst_n) begin
        freq_1_t <= 0;
        beep_count_1 <= 0;
        freq_on_1 <= 0;
    end
    else begin
        if (prt_cnt == 0) begin
            beep_count_1 <= 3'd5; // burst 5 times for buzzer 1
            freq_1_t <= 0;
            freq_on_1 <= 1'b1;
        end
        else if (beep_count_1 > 0) begin  // progress burst for buzzer 1
            if (freq_1_t >= freq_1) begin
                freq_1_t <= 0;
                freq_on_1 <= ~freq_on_1;
                if (freq_on_1 == 1'b1) begin
                    beep_count_1 <= beep_count_1 - 1;
                end
            end
            else begin
                freq_1_t <= freq_1_t + 1;
            end
        end
        else begin
            freq_on_1 <= 0;
            freq_1_t <= 0;
        end
    end
end

// Define buzzer 2 condition
always @(posedge clk)
begin
    if (!rst_n) begin
        freq_2_t <= 0;
        beep_count_2 <= 0;
        freq_on_2 <= 0;
    end
    else begin
        if (prt_cnt == 0) begin
            beep_count_2 <= 4'd10; // burst 10 times for buzzer 2
            freq_2_t <= 0;
            freq_on_2 <= 1'b1;
        end
        else if (beep_count_2 > 0) begin  // progress burst for buzzer 2
            if (freq_2_t >= freq_2) begin
                freq_2_t <= 0;
                freq_on_2 <= ~freq_on_2;
                if (freq_on_2 == 1'b1) begin
                    beep_count_2 <= beep_count_2 - 1;
                end
            end
            else begin
                freq_2_t <= freq_2_t + 1;
            end
        end
        else begin
            freq_on_2 <= 0;
            freq_2_t <= 0;
        end
    end
end

always@(posedge clk)
begin
    if(!rst_n) begin
        count_1 <= 20'd0;
        buz_o_temp_0 <= 0;
    end
    else if (freq_on_1 == 1'b1) begin
        if(count_1 >= 20'd764467) begin // 옥타브3_도(130.81Hz)
            buz_o_temp_0 <= ~buz_o_temp_0;
            count_1 <= 20'd0;
        end
        else begin
            count_1 <= count_1 + 20'd1;
        end
    end
    else begin
        buz_o_temp_0 <= 0;
        count_1 <= 0;
    end
end

always@(posedge clk)
begin
    if(!rst_n) begin
        count_2 <= 20'd0;
        buz_o_temp_1 <= 0;
    end
    else if (freq_on_2 == 1'b1) begin
        if(count_2 >= 20'd681059) begin // 옥타브3_레(146.83Hz)
            buz_o_temp_1 <= ~buz_o_temp_1;
            count_2 <= 20'd0;
        end
        else begin
            count_2 <= count_2 + 20'd1;
        end
    end
    else begin
        buz_o_temp_1 <= 0;
        count_2 <= 0;
    end
end

// Real connection part
assign buz_o[0] = buz_o_temp_0;
assign buz_o[1] = buz_o_temp_1;

endmodule