/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author:
 * Description:
 * Draw rectangle.
 */


`timescale 1 ns / 1 ps

module draw_rect_ctl (
    input  logic clk40MHz,
    input  logic rst,

    input  logic mouse_left,
    
    input  logic [11:0] mouse_xpos,
    input  logic [11:0] mouse_ypos,
    
    output logic [11:0] xpos,
    output logic [11:0] ypos
);

import vga_pkg::*;


/**
 * Local variables and signals
  */
logic [11:0] xpos_nxt;
logic [11:0] ypos_nxt;
logic reach_bottom = 0;

typedef enum bit [1:0]{
    IDLE = 2'b00,
    FALL = 2'b01,
    BOTTOM = 2'b10,
    BACK = 2'b11
} STATE;

STATE state, state_nxt;


/**
 * Internal logic
  */

always @(posedge clk40MHz) begin : outputs
    if(rst) begin
        xpos <= '0;
        ypos <= '0;
    end
    else begin
        xpos <= xpos_nxt;
        ypos <= ypos_nxt;
    end
end

always @(posedge clk40MHz) begin : write_state
    state <= state_nxt;
end

integer k = 0, k_nxt = 0;
shortint a = 0, a_nxt = 0;

always @(posedge clk40MHz) begin
    if(rst || state != FALL) begin
        k <= 0;
        a <= 0;
    end
    else begin
        k <= k_nxt;
        a <= a_nxt;
    end
end

always_comb begin : state_nxt_case
    case (state)
        IDLE: state_nxt = (mouse_left && mouse_ypos + 64 < 600) ? FALL : IDLE;
        FALL: state_nxt = reach_bottom ? BOTTOM : FALL;
        BOTTOM : state_nxt = mouse_left ? BACK : BOTTOM;
        BACK : state_nxt = (!mouse_left) ? IDLE : BACK;
        default: state_nxt = IDLE;
    endcase
end

always_comb begin
    case (state)
        IDLE: begin
            xpos_nxt = mouse_xpos;
            ypos_nxt = mouse_ypos;
            k_nxt = 0;
            a_nxt = '0;
            reach_bottom = '0;
        end

        FALL: begin
            if(ypos == 536) begin
                reach_bottom = '1;
                a_nxt = '0;
            end
            else begin
                reach_bottom = '0;
                a_nxt = a;
            end

            if(k < 400000) begin //10ms update
                ypos_nxt = ypos;
                xpos_nxt = xpos;
                k_nxt = k+1;
                
            end
            else begin
                xpos_nxt = xpos;
                ypos_nxt = (ypos + a >= 536) ? 536 : ypos + a;
                k_nxt = 0;
                a_nxt = a + 1;
                
            end
        end
        BOTTOM: begin
            xpos_nxt = xpos;
            ypos_nxt = ypos;
            k_nxt = '0;
            a_nxt = '0;
            reach_bottom = '1;
        end

        BACK: begin
            xpos_nxt = xpos;
            ypos_nxt = ypos;
            k_nxt = '0;
            a_nxt = '0;
            reach_bottom = '1;
        end
        
        default: begin
            xpos_nxt = mouse_xpos;
            ypos_nxt = mouse_ypos;
            k_nxt = '0;
            a_nxt = '0;
            reach_bottom = '0;
        end
    endcase
end

endmodule
