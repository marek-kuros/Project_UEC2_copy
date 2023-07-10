/**
 *  Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Testbench for vga_timing module.
 */

`timescale 1 ns / 1 ps

module vga_timing_tb;

import vga_pkg::*;

vga_if_no_rgb timing_if();

/**
 *  Local parameters
 */

localparam CLK_PERIOD = 25;     // 40 MHz


/**
 * Local variables and signals
 */

logic clk;
logic rst;

wire [10:0] vcount, hcount;
wire        vsync,  hsync;
wire        vblnk,  hblnk;

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
                       rst = 1'b1;
    #(2.00*CLK_PERIOD) rst = 1'b0;
end


/**
 * Dut placement
 */

vga_timing dut(
    .clk65MHz(clk),
    .rst,
    
    .timing_if
);

/**
 * Tasks and functions
 */

 // Here you can declare tasks with immediate assertions (assert).
assert property(
    @(posedge clk && $realtime > (1.25*CLK_PERIOD)) (timing_if.hcount >= 1047 && timing_if.hcount < 1047+131) |=> timing_if.hsync == 1
);

assert property(
    @(posedge clk && $realtime > (1.25*CLK_PERIOD)) (timing_if.hcount >= 1023 && timing_if.hcount < 1343) |=> timing_if.hblnk == 1
);

assert property(
    @(posedge clk && $realtime > (1.25*CLK_PERIOD)) (timing_if.vcount == 767 && timing_if.hcount == 1343) |=> timing_if.vblnk == 1
);

assert property(
    @(posedge clk && $realtime > (1.25*CLK_PERIOD)) (timing_if.hcount == 1343 && timing_if.vcount >= 770 && timing_if.vcount < 770 + 6) |=> timing_if.vsync == 1
);

    
/**
 * Assertions
*/

always @(posedge clk) begin
    @(!rst && $realtime > (1.25*CLK_PERIOD));
    assert (timing_if.vcount < 628)
    else $error("the value of vcount is hihger than 628");

    assert (timing_if.hcount < 1056)
    else $error("the value of hcounter is hihger than 1056");
end

// Here you can declare concurrent assertions (assert property).

 

initial begin
    @(posedge rst);
    @(negedge rst);

    wait (timing_if.vsync == 1'b0);
    @(negedge timing_if.vsync)
    @(negedge timing_if.vsync)

    $finish;
end

endmodule
