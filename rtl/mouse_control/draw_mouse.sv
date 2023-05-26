/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author:
 * Description:
 * Draw rectangle.
 */


`timescale 1 ns / 1 ps

module draw_mouse (
    input  logic clk40MHz,
    input  logic rst,

    vga_if.out draw_mouse_if,
    vga_if.in draw_rect_if,

    input logic [11:0] x_start,
    input logic [11:0] y_start

);

import vga_pkg::*;
logic [11:0] rgb_nxt;


MouseDisplay u_MouseDisplay(
    .pixel_clk(clk40MHz),
    .xpos(x_start),
    .ypos(y_start),
    .enable_mouse_display_out(),

    .hcount(draw_rect_if.hcount),
    .vcount(draw_rect_if.vcount),
    .rgb_in(draw_rect_if.rgb),
    .rgb_out(rgb_nxt),
    .blank(draw_rect_if.vblnk || draw_rect_if.hblnk)
);


/**
 * Local variables and signals
  */

always_ff @(posedge clk40MHz) begin : bg_ff_blk
if (rst) begin
    
    draw_mouse_if.vcount <= '0;
    draw_mouse_if.vsync  <= '0;
    draw_mouse_if.vblnk  <= '0;
    draw_mouse_if.hcount <= '0;
    draw_mouse_if.hsync  <= '0;
    draw_mouse_if.hblnk  <= '0;
    
    draw_mouse_if.rgb    <= '0;
end else begin
    
    draw_mouse_if.vcount <= draw_rect_if.vcount;
    draw_mouse_if.vsync  <= draw_rect_if.vsync;
    draw_mouse_if.vblnk  <= draw_rect_if.vblnk;
    draw_mouse_if.hcount <= draw_rect_if.hcount;
    draw_mouse_if.hsync  <= draw_rect_if.hsync;
    draw_mouse_if.hblnk  <= draw_rect_if.hblnk;
    
    draw_mouse_if.rgb    <= rgb_nxt;
end
end

endmodule