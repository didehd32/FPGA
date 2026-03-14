`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/13 12:25:05
// Design Name: 
// Module Name: piano
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


module piano(
    input clk_p,        // 200MHz Positive clock
    input clk_n,        // 200MHz Negative clock
    input [1:0] btn,
    input rst_n,
    output [3:0] led,
    output buz_o   // for piano // +3.3V
    );
    wire clk;  // buffer output
    reg [3:0] led_1;
    reg [3:0] led_2;
    reg [1:0] btn_1, btn_2;
    reg [19:0] count;   // 16bit counter
    reg [19:0] t_count; // Target counter
    reg buz_o_temp;

     // Change 차동 클락 -> 단일 클락
    IBUFDS clk_inst (
        .O(clk),        // 내부 로직으로 들어가는 단일 클락
        .I(clk_p),      // 외부에서 들어오는 P 클락
        .IB(clk_n)      // 외부에서 들어오는 N 클락
    );

// FF(Flip-Flop)
always@(posedge clk)
begin
    if(!rst_n) begin
        led_1 <= 4'b1111;
        led_2 <= 4'b1111;
        btn_1 <= 2'b11;
        btn_2 <= 2'b11;
    end
    else begin
        led_1 <= {2'b11, btn};
        led_2 <= led_1;
        btn_1 <= btn;
        btn_2 <= btn_1;
    end
end

// Define LED & btn & buzzer condition
always@(posedge clk)
begin
    if(!rst_n) begin
        t_count <= 0;
    end
    else begin
        case(btn_2)
        2'b11: begin
            t_count <= 20'd0;  // No sound
        end
        2'b10: begin
            t_count <= 20'd764467;  // 옥타브3_도(130.81Hz)
        end
        2'b01: begin
            t_count <= 20'd681059;  // 옥타브3_레(146.83Hz)
        end
        2'b00: begin
            t_count <= 20'd606759;  // 옥타브3_미(164.81Hz)
        end
        default t_count <= 20'd0;
        endcase
    end
end

always@(posedge clk)
begin
    if(!rst_n) begin
        count <= 20'd0;
        buz_o_temp <= 1'b0;
    end
    else if (t_count == 20'd0) begin
        buz_o_temp <= 1'b0;
        count <= 0;
    end
    else begin
        if(count >= t_count) begin
            buz_o_temp <= ~buz_o_temp;
            count <= 20'd0;
        end
        else begin
            count <= count + 20'd1;
        end
    end
end

// Real connection part
assign led = led_2;
assign buz_o = buz_o_temp;

endmodule
