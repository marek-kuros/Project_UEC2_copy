/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Marek Kuros
 * Description:
 * Draw letters.
 */


`timescale 1 ns / 1 ps

module draw_rect_char
#(
    parameter logic [10:0] x_of_box = 0,
    parameter logic [10:0] y_of_box = 0
)
(
    input  logic clk65MHz,
    input  logic rst,

    input  logic screen_idle,

    vga_if.out draw_rect_char_if,
    vga_if.in draw_mouse_if,

    output logic [7:0] char_xy,
    output logic [3:0] char_line,
    input  logic [7:0] char_pixel
);

import vga_pkg::*;


/**
 * Local variables and signals
  */

logic [11:0] rgb_nxt = '0;

logic [11:0] width_of_letter = 8, height_of_letter = 16;

logic vsync_dly, vblnk_dly, hsync_dly, hblnk_dly;
logic [10:0] hcount_dly, vcount_dly;
logic [11:0] rgb_dly;


//
logic [7:0] char_xy_nxt = '0;
logic [3:0] char_line_nxt = '0;
/**
 * Internal logic
  */ 
 always_ff @(posedge clk65MHz) begin : input_signals
    if (rst) begin
        vcount_dly <= '0;
        vsync_dly  <= '0;
        vblnk_dly  <= '0;
        hcount_dly <= '0;
        hsync_dly  <= '0;
        hblnk_dly  <= '0;
        rgb_dly <= '0;
    end 

    else begin   
        vcount_dly <= draw_mouse_if.vcount;
        vsync_dly  <= draw_mouse_if.vsync;
        vblnk_dly  <= draw_mouse_if.vblnk;
        hcount_dly <= draw_mouse_if.hcount;
        hsync_dly  <= draw_mouse_if.hsync;
        hblnk_dly  <= draw_mouse_if.hblnk;
        rgb_dly <= draw_mouse_if.rgb;
    end
end

always_ff @(posedge clk65MHz) begin : output_signals
    if (rst) begin
        
        draw_rect_char_if.vcount <= '0;
        draw_rect_char_if.vsync  <= '0;
        draw_rect_char_if.vblnk  <= '0;
        draw_rect_char_if.hcount <= '0;
        draw_rect_char_if.hsync <= '0;
        draw_rect_char_if.hblnk  <= '0;
        draw_rect_char_if.rgb <= '0;
    end 
    
    else begin   
        draw_rect_char_if.vcount <= vcount_dly;
        draw_rect_char_if.vsync  <= vsync_dly;
        draw_rect_char_if.vblnk  <= vblnk_dly;
        draw_rect_char_if.hcount <= hcount_dly;
        draw_rect_char_if.hsync  <= hsync_dly;
        draw_rect_char_if.hblnk  <= hblnk_dly;
        draw_rect_char_if.rgb <= rgb_nxt;
    end
end

always_comb begin : bg_comb_blk
    if (draw_rect_char_if.vblnk || draw_rect_char_if.hblnk) begin        
        rgb_nxt = 12'h0_0_0;                    
    end else begin 
        if(screen_idle) begin
            if(draw_rect_char_if.vcount >= y_of_box && draw_rect_char_if.vcount < y_of_box + 256 &&
            draw_rect_char_if.hcount >= x_of_box && draw_rect_char_if.hcount < x_of_box + 128) begin                       
                if(char_pixel[3'b111-draw_rect_char_if.hcount[2:0]+x_of_box[2:0]]) begin
                    rgb_nxt = 12'b0_0_0;
                end
                else begin
                    rgb_nxt = rgb_dly;
                end
            end
            else begin
                rgb_nxt = rgb_dly;    
            end
        end
        else begin
            rgb_nxt = rgb_dly; 
        end
    end
end

always_ff @(posedge clk65MHz) begin: ff_for_array
    if(rst) begin
        char_xy <= '0;
        char_line <= '0;
    end
    else begin
        char_xy <= char_xy_nxt;
        char_line <= char_line_nxt;
    end
end

always_comb begin
case(draw_mouse_if.hcount - x_of_box)
    4'd0:  char_xy_nxt[3:0] = 0;
    1*width_of_letter: char_xy_nxt[3:0] = 1;
    2*width_of_letter: char_xy_nxt[3:0] = 2;
    3*width_of_letter: char_xy_nxt[3:0] = 3;
    4*width_of_letter: char_xy_nxt[3:0] = 4;
    5*width_of_letter: char_xy_nxt[3:0] = 5;
    6*width_of_letter: char_xy_nxt[3:0] = 6;
    7*width_of_letter: char_xy_nxt[3:0] = 7;
    8*width_of_letter: char_xy_nxt[3:0] = 8;
    9*width_of_letter: char_xy_nxt[3:0] = 9;
    10*width_of_letter: char_xy_nxt[3:0] = 10;
    11*width_of_letter: char_xy_nxt[3:0] = 11;
    12*width_of_letter: char_xy_nxt[3:0] = 12;
    13*width_of_letter: char_xy_nxt[3:0] = 13;
    14*width_of_letter: char_xy_nxt[3:0] = 14;
    15*width_of_letter: char_xy_nxt[3:0] = 15;
    default: char_xy_nxt = char_xy;
endcase

case(draw_mouse_if.vcount - y_of_box)
    4'd0:  char_xy_nxt[7:4] = 0;
    1*height_of_letter: char_xy_nxt[7:4] = 1;
    2*height_of_letter: char_xy_nxt[7:4] = 2;
    3*height_of_letter: char_xy_nxt[7:4] = 3;
    4*height_of_letter: char_xy_nxt[7:4] = 4;
    5*height_of_letter: char_xy_nxt[7:4] = 5;
    6*height_of_letter: char_xy_nxt[7:4] = 6;
    7*height_of_letter: char_xy_nxt[7:4] = 7;
    8*height_of_letter: char_xy_nxt[7:4] = 8;
    9*height_of_letter: char_xy_nxt[7:4] = 9;
    10*height_of_letter: char_xy_nxt[7:4] = 10;
    11*height_of_letter: char_xy_nxt[7:4] = 11;
    12*height_of_letter: char_xy_nxt[7:4] = 12;
    13*height_of_letter: char_xy_nxt[7:4] = 13;
    14*height_of_letter: char_xy_nxt[7:4] = 14;
    15*height_of_letter: char_xy_nxt[7:4] = 15;
    default: char_xy_nxt[7:4] = char_xy[7:4];
endcase
end

always_comb begin
    char_line_nxt = draw_rect_char_if.vcount[3:0] - y_of_box[3:0];
end

endmodule