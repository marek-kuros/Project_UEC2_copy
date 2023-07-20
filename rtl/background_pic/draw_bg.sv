/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background.
 */


`timescale 1 ns / 1 ps

module draw_bg
    #(
        parameter H_start = 80,
        parameter H_pixel_no = 863,
        parameter V_start = 80,
        parameter V_pixel_no = 607
    )
    (
        input  logic clk65MHz,
        input  logic rst,    
        
        // input  logic screen_idle,
        input  logic screen_single,
        input  logic screen_multi,

        vga_if_no_rgb.bg_in timing_if,
        vga_if.out draw_bg_if
);

import vga_pkg::*;

/**
 * Local variables and signals
 */

// reg [11:0] rom [560448:0];

// initial $readmemh("../../rtl/background_pic/ekran_startowy.dat", rom);

logic [11:0] rgb_nxt = '0;
/**
 * Internal logic
 */
/*task for different screen appearance
 * 
*/
task IdleScreen(input logic [10:0] vcount, hcount); 
    if (vcount == 0)                     // - top edge:
        rgb_nxt = 12'hf_f_0;                // - - make a yellow line.
    else if (vcount == VER_PIXELS - 1)   // - bottom edge:
        rgb_nxt = 12'hf_0_0;                // - - make a red line.
    else if (hcount == 0)                // - left edge:
        rgb_nxt = 12'h0_f_0;                // - - make a green line.
    else if (hcount == HOR_PIXELS - 1)   // - right edge:
        rgb_nxt = 12'h0_0_f;                // - - make a blue line.
    else if (vcount < V_start + V_pixel_no &&  hcount < H_start + H_pixel_no &&
            vcount >= V_start &&  hcount >= H_start)                                   // The rest of active display pixels:
        rgb_nxt = 12'h5_5_5;                // - fill with gray.
    else
        rgb_nxt = 12'h0_2_f; 
endtask

task GameScreen(input logic [10:0] vcount, hcount); 
    //upper and lower bar
    if(vcount < 51 || vcount > 717) begin
        rgb_nxt = 12'hf_f_f;
    end
    else if(hcount > 505 && hcount < 517) begin
        rgb_nxt = 12'hf_f_f;
    end
    else begin
        rgb_nxt = 12'h0_2_f;
    end
endtask

always_ff @(posedge clk65MHz) begin : bg_ff_blk
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
    end else begin                          // Active region:
        if(screen_single || screen_multi) begin
            GameScreen(timing_if.vcount, timing_if.hcount);
        end else begin
            IdleScreen(timing_if.vcount, timing_if.hcount);
        end
    end
end

endmodule
