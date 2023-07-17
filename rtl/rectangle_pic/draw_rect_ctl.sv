/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Marek
 * Description:
 * Module for drawing "racket".
 */


`timescale 1 ns / 1 ps

module draw_rect_ctl 
#(
    parameter logic [10:0] x_fix_position_player_1 = 0,
    parameter logic [10:0] x_fix_position_player_2 = 0,
    parameter logic [10:0] width = 0
) 
(
    input  logic clk65MHz,
    input  logic rst,
    
    //input  logic [11:0] mouse_xpos,
    input  logic [11:0] mouse_ypos,

    input  logic screen_idle,
    input  logic screen_single,
    //input  logic screen_multi,

    input  logic [9:0] input_pos,
    output logic [9:0] output_pos,

    vga_if.out draw_rect_if,
    vga_if.in draw_bg_if
);

import vga_pkg::*;

localparam y_size_of_racket = 80;

/**
 * Local variables and signals
  */
logic [11:0] rgb_nxt = '0;

/**
 * Internal logic
  */
always_ff @(posedge clk65MHz) begin : input_delay
    if (rst) begin
        draw_rect_if.vcount <= '0;
        draw_rect_if.vsync  <= '0;
        draw_rect_if.vblnk  <= '0;
        draw_rect_if.hcount <= '0;
        draw_rect_if.hsync  <= '0;
        draw_rect_if.hblnk  <= '0;
        draw_rect_if.rgb    <= '0;

        output_pos          <= '0;
    end
    else begin   
        draw_rect_if.vcount <= draw_bg_if.vcount;
        draw_rect_if.vsync  <= draw_bg_if.vsync;
        draw_rect_if.vblnk  <= draw_bg_if.vblnk;
        draw_rect_if.hcount <= draw_bg_if.hcount;
        draw_rect_if.hsync  <= draw_bg_if.hsync;
        draw_rect_if.hblnk  <= draw_bg_if.hblnk;
        draw_rect_if.rgb    <= rgb_nxt;

        output_pos          <= mouse_ypos[9:0];
    end
end

always_comb begin : player_1_racket
    if(screen_idle) begin
        rgb_nxt = draw_bg_if.rgb;
    end 
    else if(screen_single) begin
        //player 1 racket
        if((mouse_ypos >= 51 && mouse_ypos <= 717 - y_size_of_racket) && draw_bg_if.hcount > x_fix_position_player_1 && draw_bg_if.hcount < x_fix_position_player_1 + width &&
           draw_bg_if.vcount > mouse_ypos && draw_bg_if.vcount < mouse_ypos + y_size_of_racket) begin
            rgb_nxt = 12'hf_f_f;
        end
        else if((mouse_ypos < 51) &&
                (draw_bg_if.hcount > x_fix_position_player_1 && draw_bg_if.hcount < x_fix_position_player_1 + width &&
                draw_bg_if.vcount > 51 && draw_bg_if.vcount < 51 + y_size_of_racket)) begin
            rgb_nxt = 12'hf_f_f;
        end
        else if((mouse_ypos > 717 - y_size_of_racket) &&
                (draw_bg_if.hcount > x_fix_position_player_1 && draw_bg_if.hcount < x_fix_position_player_1 + width &&
                draw_bg_if.vcount > 717 - y_size_of_racket && draw_bg_if.vcount < 717)) begin
            rgb_nxt = 12'hf_f_f;
        end
        //player 2 racket (single mode)
        else if((mouse_ypos >= 51 && mouse_ypos <= 717 - y_size_of_racket) && draw_bg_if.hcount > x_fix_position_player_2 && draw_bg_if.hcount < x_fix_position_player_2 + width &&
            768 - draw_bg_if.vcount > mouse_ypos && 768 - draw_bg_if.vcount < mouse_ypos + y_size_of_racket) begin
            rgb_nxt = 12'hf_f_f;
        end
        else if((mouse_ypos < 51) &&
                (draw_bg_if.hcount > x_fix_position_player_2 && draw_bg_if.hcount < x_fix_position_player_2 + width &&
                768 - draw_bg_if.vcount > 51 && 768 - draw_bg_if.vcount < 51 + y_size_of_racket)) begin
            rgb_nxt = 12'hf_f_f;
        end
        else if((mouse_ypos > 717 - y_size_of_racket) &&
                (draw_bg_if.hcount > x_fix_position_player_2 && draw_bg_if.hcount < x_fix_position_player_2 + width &&
                768 - draw_bg_if.vcount > 717 - y_size_of_racket && 768 - draw_bg_if.vcount < 717)) begin
            rgb_nxt = 12'hf_f_f;
        end
        //background
        else begin
            rgb_nxt = draw_bg_if.rgb;
        end
    end
    else begin //rackets for multiplayer
        //player 1 racket
        if((mouse_ypos >= 51 && mouse_ypos <= 717 - y_size_of_racket) && draw_bg_if.hcount > x_fix_position_player_1 && draw_bg_if.hcount < x_fix_position_player_1 + width &&
           draw_bg_if.vcount > mouse_ypos && draw_bg_if.vcount < mouse_ypos + y_size_of_racket) begin
            rgb_nxt = 12'hf_f_f;
        end
        else if((mouse_ypos < 51) &&
                (draw_bg_if.hcount > x_fix_position_player_1 && draw_bg_if.hcount < x_fix_position_player_1 + width &&
                draw_bg_if.vcount > 51 && draw_bg_if.vcount < 51 + y_size_of_racket)) begin
            rgb_nxt = 12'hf_f_f;
        end
        else if((mouse_ypos > 717 - y_size_of_racket) &&
                (draw_bg_if.hcount > x_fix_position_player_1 && draw_bg_if.hcount < x_fix_position_player_1 + width &&
                draw_bg_if.vcount > 717 - y_size_of_racket && draw_bg_if.vcount < 717)) begin
            rgb_nxt = 12'hf_f_f;
        end
        //player 2 racket (miltiplayer mode)
        else if((input_pos >= 51 && input_pos <= 717 - y_size_of_racket) && draw_bg_if.hcount > x_fix_position_player_2 && draw_bg_if.hcount < x_fix_position_player_2 + width &&
                 draw_bg_if.vcount > input_pos && draw_bg_if.vcount < input_pos + y_size_of_racket) begin
            rgb_nxt = 12'hf_f_f;
        end
        else if((input_pos < 51) &&
                (draw_bg_if.hcount > x_fix_position_player_2 && draw_bg_if.hcount < x_fix_position_player_2 + width &&
                 draw_bg_if.vcount > 51 && draw_bg_if.vcount < 51 + y_size_of_racket)) begin
            rgb_nxt = 12'hf_f_f;
        end
        else if((input_pos > 717 - y_size_of_racket) &&
                (draw_bg_if.hcount > x_fix_position_player_2 && draw_bg_if.hcount < x_fix_position_player_2 + width &&
                 draw_bg_if.vcount > 717 - y_size_of_racket && draw_bg_if.vcount < 717)) begin
            rgb_nxt = 12'hf_f_f;
        end
        //background
        else begin
            rgb_nxt = draw_bg_if.rgb;
        end
    end
end

endmodule
