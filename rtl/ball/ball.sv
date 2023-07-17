/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Marek
 * Description:
 * Module for drawing ball.
 */


 `timescale 1 ns / 1 ps

 module draw_ball
 #(
     parameter logic [3:0] size_of_ball = 15
 ) 
 (
     input  logic clk65MHz,
     input  logic rst,
     
     //input  logic [11:0] mouse_xpos,

     input  logic screen_idle,
     //input  logic screen_single,
     //input  logic screen_multi,
 
     input  logic [10:0] x_pos_of_ball,
     input  logic [10:0] y_pos_of_ball,
 
     vga_if.out draw_ball_if,
     vga_if.in  draw_rect_if
 );
 
 import vga_pkg::*;
 
 /**
  * Local variables and signals
   */
 logic [11:0] rgb_nxt = '0;
 
 /**
  * Internal logic
   */
 always_ff @(posedge clk65MHz) begin : input_delay
     if (rst) begin
         draw_ball_if.vcount <= '0;
         draw_ball_if.vsync  <= '0;
         draw_ball_if.vblnk  <= '0;
         draw_ball_if.hcount <= '0;
         draw_ball_if.hsync  <= '0;
         draw_ball_if.hblnk  <= '0;
         draw_ball_if.rgb    <= '0;
     end
     else begin   
         draw_ball_if.vcount <= draw_rect_if.vcount;
         draw_ball_if.vsync  <= draw_rect_if.vsync;
         draw_ball_if.vblnk  <= draw_rect_if.vblnk;
         draw_ball_if.hcount <= draw_rect_if.hcount;
         draw_ball_if.hsync  <= draw_rect_if.hsync;
         draw_ball_if.hblnk  <= draw_rect_if.hblnk;
         draw_ball_if.rgb    <= rgb_nxt;
     end
 end

 always_comb begin
    if(screen_idle) begin
        rgb_nxt = draw_rect_if.rgb;
    end else begin
        if(draw_rect_if.vcount > y_pos_of_ball && draw_rect_if.vcount <= y_pos_of_ball + size_of_ball &&
           draw_rect_if.hcount > x_pos_of_ball && draw_rect_if.hcount <= x_pos_of_ball + size_of_ball) begin
                rgb_nxt = 12'hf_f_f;
           end else begin
                rgb_nxt = draw_rect_if.rgb;
           end
    end
 end
 
 endmodule
 