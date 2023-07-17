/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Vga timing controller.
 */
`timescale 1 ns / 1 ps

module vga_timing (
    input  logic clk65MHz,
    input  logic rst,

    output logic end_of_frame,
    
    vga_if_no_rgb.tim_out timing_if
);

import vga_pkg::*;

// Add your signals and variables here.

// Add your code here.
/**
 * Local variables and signals
 */
logic [10:0] vcount_nxt = '0;
logic [10:0] hcount_nxt = '0;
logic hblnk_nxt = '0, hsync_nxt = '0, vsync_nxt = '0, vblnk_nxt = '0;

logic end_of_frame_nxt = '0;

// Describe the actual circuit for the assignment.
// Video timing controller set for 800x600@60fps
// using a 40 MHz pixel clock per VESA spec.

always_ff @(posedge clk65MHz) begin
    if(rst) begin
        timing_if.vcount <= '0;
        timing_if.hcount  <= '0;
        timing_if.hblnk  <= '0;
        timing_if.hsync  <= '0;
        timing_if.vblnk  <= '0;
        timing_if.vsync  <= '0;

        end_of_frame     <= '0;
    end
    else begin
        timing_if.vcount <= vcount_nxt;
        timing_if.hcount <= hcount_nxt;
        timing_if.hblnk <= hblnk_nxt;
        timing_if.hsync <= hsync_nxt;
        timing_if.vblnk <= vblnk_nxt;
        timing_if.vsync <= vsync_nxt;

        end_of_frame    <= end_of_frame_nxt;
    end
end

always_comb begin
    if(timing_if.hcount < HOR_TOTAL_PIXEL_NUMBER) begin
        hcount_nxt = timing_if.hcount + 1;
    end
    else begin
        hcount_nxt = 0;
    end
    
    if(timing_if.hcount == HOR_TOTAL_PIXEL_NUMBER && timing_if.vcount < VER_TOTAL_PIXEL_NUMBER) begin
        vcount_nxt = timing_if.vcount + 1;
    end
    else if(timing_if.hcount == HOR_TOTAL_PIXEL_NUMBER && timing_if.vcount == VER_TOTAL_PIXEL_NUMBER) begin
        vcount_nxt = 0;
    end
    else begin
        vcount_nxt = timing_if.vcount;
    end

    if(timing_if.hcount >= HOR_SYNC_START && timing_if.hcount < HOR_SYNC_START + HOR_SYNC_TIME) begin
        hsync_nxt = 1;
    end
    else begin
        hsync_nxt = 0;
    end
   
    if(timing_if.hcount >= HOR_BLANK_START && timing_if.hcount < HOR_BLANK_START + HOR_BLANK_TIME) begin
        hblnk_nxt = 1;
    end
    else begin
        hblnk_nxt = 0;
    end

    if(timing_if.vcount == VER_BLANK_START && timing_if.hcount == HOR_TOTAL_PIXEL_NUMBER) begin
        vblnk_nxt = 1;
    end
    else if(timing_if.vcount == VER_BLANK_START +  VER_BLANK_TIME && timing_if.hcount == HOR_TOTAL_PIXEL_NUMBER) begin
        vblnk_nxt = 0;
    end
    else begin
        vblnk_nxt = timing_if.vblnk;
    end
    
    if(timing_if.hcount == HOR_TOTAL_PIXEL_NUMBER) begin
        if(timing_if.vcount >= VER_SYNC_START && timing_if.vcount < VER_SYNC_START + VER_SYNC_TIME) begin 
            vsync_nxt = 1;
        end
        else begin
            vsync_nxt = 0;
        end  
    end
    else begin
        vsync_nxt = timing_if.vsync;
    end

    if(timing_if.hcount == HOR_TOTAL_PIXEL_NUMBER && timing_if.vcount == VER_PIXELS) begin
        end_of_frame_nxt = 1;
    end else begin
        end_of_frame_nxt = 0;
    end    
end

endmodule
