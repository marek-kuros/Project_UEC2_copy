/**
 *  Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 *
 * Description:
 * Testbench for vga_timing module.
 */

`timescale 1 ns / 1 ps

module draw_rect_ctl_tb;

import vga_pkg::*;

/**
 *  Local parameters
 */

localparam CLK_PERIOD = 25;     // 40 MHz


/**
 * Local variables and signals
 */

logic clk;
logic rst;
logic mouse_lefb;

logic [11:0] xpos_out;

logic [11:0] ypos_out;



/**
 * Clock generation
 */

initial begin
    clk = 1'b0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

/**
 * Reset generation
 */

initial begin
                       rst = 1'b0;
    #(1.25*CLK_PERIOD) rst = 1'b1;
    #1                 rst = 1'b0;
end

//mouse click
initial begin
            mouse_lefb = 1'b0;
    #100    mouse_lefb = 1'b1;
    #10     mouse_lefb = 1'b0;
    #4_000_000_00     mouse_lefb = 1'b1; 
    #4_000_100_00     mouse_lefb = 1'b0;
end

/**
 * Dut placement
 */

draw_rect_ctl dut(
    .clk65MHz(clk),
    .rst(rst),
    
    .mouse_xpos('0),
    .mouse_ypos('0),
    .mouse_left(mouse_lefb),

    .xpos(xpos_out),
    .ypos(ypos_out)
);

/**
 * Tasks and functions
 */

 // Here you can declare tasks with immediate assertions (assert).
   
/**
 * Assertions
*/

always @* begin
    $strobe("xpos = %d  ypos = %d   mouse = %d", xpos_out, ypos_out, mouse_lefb);
    if($realtime > 4_500_100_00 && ypos_out == 0) begin
        $write("%c[1;34m",27);
        $display("picture came back to mouse");
        $write("%c[0m",27);
    end
end

always begin
    #1_000_000_000 $finish;
end


endmodule
