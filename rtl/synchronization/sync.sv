/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Marek Kuros
 * Description:
 * Module for overcomming timing violations.
 */
module sync(
    input logic rst,
    input logic clk65MHz,
    input logic clk50,
    input logic clk100MHz,

    vga_if.in draw_bg_if,
    vga_if.out sync_if,

    input logic left_in,
    output logic left_out,

    input logic [11:0] xpos,
    input logic [11:0] ypos,
    output logic [11:0] xpos_out,
    output logic [11:0] ypos_out
);

logic [11:0] xpos1, xpos2;
logic [11:0] ypos1 = '0, ypos2 = '0;
logic left1, left2;

always_ff @(posedge clk100MHz) begin
    xpos1 <= xpos;
    ypos1 <= ypos;
    left1 <= left_in;
end

always_ff @(posedge clk50) begin
    xpos2 <= xpos1;
    ypos2 <= ypos1;
    left2 <= left1;    
end

always_ff @(posedge clk65MHz) begin
    if(!rst) begin
        xpos_out <= xpos2;
        ypos_out <= ypos2;

        left_out <= left2;

        sync_if.hblnk  <= draw_bg_if.hblnk;
        sync_if.hcount <= draw_bg_if.hcount;
        sync_if.hsync  <= draw_bg_if.hsync;
        sync_if.vblnk  <= draw_bg_if.vblnk;
        sync_if.vcount <= draw_bg_if.vcount;
        sync_if.vsync  <= draw_bg_if.vsync;
        sync_if.rgb    <= draw_bg_if.rgb;
    end
    else begin
        xpos_out <= '0;
        ypos_out <= '0;

        left_out <= '0;
  
        sync_if.hblnk  <= '0;
        sync_if.hcount <= '0;
        sync_if.hsync  <= '0;  
        sync_if.vblnk  <= '0;
        sync_if.vcount <= '0;
        sync_if.vsync  <= '0;
        sync_if.rgb    <= '0;
    end
end
endmodule