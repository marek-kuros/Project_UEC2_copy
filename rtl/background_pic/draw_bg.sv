/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background.
 */


`timescale 1 ns / 1 ps

module draw_bg(
    input  logic clk40MHz,
    input  logic rst,

    vga_if_no_rgb.bg_in timing_if,
    vga_if.out draw_bg_if
);

import vga_pkg::*;


/**
 * Local variables and signals
 */

logic [11:0] rgb_nxt = '0;
/**
 * Internal logic
 */

always_ff @(posedge clk40MHz) begin : bg_ff_blk
    if (rst) begin
        
        draw_bg_if.vcount <= '0;
        draw_bg_if.vsync  <= '0;
        draw_bg_if.vblnk  <= '0;
        draw_bg_if.hcount <= '0;
        draw_bg_if.hsync  <= '0;
        draw_bg_if.hblnk  <= '0;
        
        draw_bg_if.rgb    <= '0;
    end else begin
        
        draw_bg_if.vcount <= timing_if.vcount;
        draw_bg_if.vsync  <= timing_if.vsync ;
        draw_bg_if.vblnk  <= timing_if.vblnk ;
        draw_bg_if.hcount <= timing_if.hcount;
        draw_bg_if.hsync  <= timing_if.hsync;
        draw_bg_if.hblnk  <= timing_if.hblnk;
        
        draw_bg_if.rgb    <= rgb_nxt;
    end
end

always_comb begin : bg_comb_blk
    if (timing_if.vblnk || timing_if.hblnk) begin             // Blanking region:
        rgb_nxt = 12'h0_0_0;                    // - make it it black.
    end else begin                              // Active region:
        if (timing_if.vcount == 0)                     // - top edge:
            rgb_nxt = 12'hf_f_0;                // - - make a yellow line.
        else if (timing_if.vcount == VER_PIXELS - 1)   // - bottom edge:
            rgb_nxt = 12'hf_0_0;                // - - make a red line.
        else if (timing_if.hcount == 0)                // - left edge:
            rgb_nxt = 12'h0_f_0;                // - - make a green line.
        else if (timing_if.hcount == HOR_PIXELS - 1)   // - right edge:
            rgb_nxt = 12'h0_0_f;                // - - make a blue line.
        
        else if(timing_if.vcount >= 150 && timing_if.vcount < 250 && timing_if.hcount > 125 && timing_if.hcount < 255) rgb_nxt = 12'h0_0_f; // top bar of m
        else if(timing_if.vcount >= 225 && timing_if.vcount < 550 && ((timing_if.hcount > 100 && timing_if.hcount < 150)||(timing_if.hcount > 175 && timing_if.hcount < 205)||(timing_if.hcount > 230 && timing_if.hcount < 280))) rgb_nxt =  12'h0_0_f; // legs of m
        else if(timing_if.vcount >= 150 && timing_if.vcount < 550 && timing_if.hcount > 300 && timing_if.hcount < 350) rgb_nxt =  12'h0_0_f; // vertical bar for k
        else if(timing_if.vcount >= 375 && timing_if.vcount < 425 && timing_if.hcount >= 350 && timing_if.hcount < 475) rgb_nxt = 12'h0_0_f; // horiznotal bar for k
        else if(timing_if.vcount >= 400 && timing_if.vcount < 550 && timing_if.hcount > 450 && timing_if.hcount < 500) rgb_nxt =  12'h0_0_f; //leg for k
        else if(timing_if.vcount >= 150 && timing_if.vcount < 270 && timing_if.hcount > 450 && timing_if.hcount < 500) rgb_nxt =  12'h0_0_f; // \
        else if(timing_if.vcount >= 270 && timing_if.vcount < 350 && timing_if.hcount > 400 && timing_if.hcount < 450) rgb_nxt =  12'h0_0_f; //  - k right part 
        else if(timing_if.vcount >= 350 && timing_if.vcount < 375 && timing_if.hcount >= 350 && timing_if.hcount < 400) rgb_nxt =  12'h0_0_f; // /


        else                                    // The rest of active display pixels:
            rgb_nxt = 12'h8_8_8;                // - fill with gray.
    end
end

endmodule
