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
    input clk,
    input rst_n,
    input [31:0] delay_i,   // python input
    input is_delay_i,       // python input
    input [31:0] prt_t_i,   // python input
    input is_prt_i,         // python input
    output [1:0] buz_o
    );

    reg [19:0] count_1 = 20'd0;   // 20bit counter
    reg [19:0] count_2 = 20'd0;   // 20bit counter
    reg buz_o_temp_0;
    reg buz_o_temp_1;
    
    reg [31:0] delay_count = 32'd0;   // python delay counter

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

// Define delay input from python
always @(posedge clk) begin
    if (!rst_n) begin
        delay_count <= 0;
    end
    else begin
        if (is_delay_i) begin
            delay_count <= delay_i; 
        end
        else if (delay_count > 0) begin
            delay_count <= delay_count - 1;
        end
    end
end

always @(posedge clk) begin
    if (!rst_n) begin
        prt_t <= 32'd1_000_000_000; // 리셋 시 기본 5초로 초기화
    end
    else if (is_prt_i) begin
        prt_t <= prt_t_i;           // 파이썬 명령이 들어오면 값 덮어쓰기!
    end
end

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
        if (beep_count_1 > 0) begin  // progress burst for buzzer 1
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
        else if (prt_cnt == 0 && prt_cnt == 0) begin
            beep_count_1 <= 3'd5; // burst 5 times for buzzer 1
            freq_1_t <= 0;
            freq_on_1 <= 1'b1;
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
        if (beep_count_2 > 0) begin
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
        else if (prt_cnt == 0) begin
            beep_count_2 <= 4'd10; // burst 10 times for buzzer 2
            freq_2_t <= 0;
            freq_on_2 <= 1'b1;
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
    else if (delay_count == 0) begin
        if (freq_on_1 == 1'b1) begin
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
end

always@(posedge clk)
begin
    if(!rst_n) begin
        count_2 <= 20'd0;
        buz_o_temp_1 <= 0;
    end
    else begin
        if (freq_on_2 == 1'b1) begin
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
end

// Real connection part
assign buz_o[0] = (delay_count > 0) ? 1'b0 : buz_o_temp_0;
assign buz_o[1] = buz_o_temp_1;

endmodule