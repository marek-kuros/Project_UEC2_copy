/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author:
 * Description:
 * Draw rectangle.
 */


`timescale 1 ns / 1 ps

module draw_rect (
    input  logic clk40MHz,
    input  logic rst,

    input  logic [11:0] rgb_pixel,
    output logic [11:0] pixel_addr,

    vga_if.out draw_rect_if,
    vga_if.in draw_bg_if,

    input logic [11:0] x_start,
    input logic [11:0] y_start
);

import vga_pkg::*;


/**
 * Local variables and signals
  */
 
logic [5:0] x_pixel_addr_nxt;
logic [5:0] y_pixel_addr_nxt;

logic [11:0] rgb_nxt = '0;

logic [10:0] x_size = 48;
logic [10:0] y_size = 64;

logic vsync_dly, vblnk_dly, hsync_dly, hblnk_dly;
logic [10:0] hcount_dly, vcount_dly;
logic [11:0] rgb_dly;

/**
 * Internal logic
  */ 
 always_ff @(posedge clk40MHz) begin : input_delay
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
        vcount_dly <= draw_bg_if.vcount;
        vsync_dly  <= draw_bg_if.vsync;
        vblnk_dly  <= draw_bg_if.vblnk;
        hcount_dly <= draw_bg_if.hcount;
        hsync_dly  <= draw_bg_if.hsync;
        hblnk_dly  <= draw_bg_if.hblnk;
        rgb_dly <= draw_bg_if.rgb;
    end
end

always_ff @(posedge clk40MHz) begin : output_values
    if (rst) begin
        
        draw_rect_if.vcount <= '0;
        draw_rect_if.vsync  <= '0;
        draw_rect_if.vblnk  <= '0;
        draw_rect_if.hcount <= '0;
        draw_rect_if.hsync <= '0;
        draw_rect_if.hblnk  <= '0;
        draw_rect_if.rgb <= '0;
    end 
    
    else begin   
        draw_rect_if.vcount <= vcount_dly;
        draw_rect_if.vsync  <= vsync_dly;
        draw_rect_if.vblnk  <= vblnk_dly;
        draw_rect_if.hcount <= hcount_dly;
        draw_rect_if.hsync  <= hsync_dly;
        draw_rect_if.hblnk  <= hblnk_dly;
        draw_rect_if.rgb <= rgb_nxt;
    end
end

always_comb begin : bg_comb_blk
    if (vblnk_dly || vblnk_dly) begin        
    rgb_nxt = 12'h0_0_0;                    
    end else begin                         
        if (vcount_dly >= y_start && hcount_dly >= x_start && 
            hcount_dly < (x_start + x_size) && vcount_dly < (y_start + y_size)) begin
            rgb_nxt = rgb_pixel;
        end
        else begin                              
        rgb_nxt = rgb_dly; 
        end
    end
end

always_comb begin
    y_pixel_addr_nxt = draw_bg_if.vcount - y_start;
    x_pixel_addr_nxt = draw_bg_if.hcount - x_start;
    pixel_addr = {y_pixel_addr_nxt, x_pixel_addr_nxt};
end

endmodule