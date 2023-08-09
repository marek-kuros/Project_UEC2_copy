/**
 *  Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 *
 * Description:
 * Testbench for draw_rect_ctl 
 * Author: Sabina
 */
`timescale 1ns/1ps

module draw_rect_ctl_tb;

    // Inputs
    logic clk65MHz;
    logic rst;
    logic [11:0] mouse_ypos;
    logic screen_idle;
    logic screen_single;
    logic [9:0] input_pos;
    


    import vga_pkg::*;

    vga_if draw_rect_if();
    vga_if draw_bg_if();

    // Instantiate the unit under test
    draw_rect_ctl #(
        .x_fix_position_player_1(0),
        .x_fix_position_player_2(0),
        .width(0)
    ) dut (
        .clk65MHz(clk65MHz),
        .rst(rst),
        .mouse_ypos(mouse_ypos),
        .screen_idle(screen_idle),
        .screen_single(screen_single),
        .input_pos(input_pos),
        .output_pos(output_pos),
        .draw_rect_if(draw_rect_if.out),
        .draw_bg_if(draw_bg_if.in)
    );

    // Clock generation
    logic clk;
    always #5 clk = ~clk;
    
    initial begin
        clk65MHz = 0;
        rst = 1;
        mouse_ypos = 0;
        screen_idle = 0;
        screen_single = 0;
        input_pos = 0;
        
        #10 rst = 0;  // Deassert reset
        
        $display("-----------------------------");

        // Test scenario
        #20 screen_idle = 1;
        assert(screen_idle);
        $display("Chenge mode  on screen_idle");
        
        #30 screen_idle = 0; 
        #30 screen_single = 1; 
        assert(!screen_idle && screen_single);
        $display("Chenge mode on screen_single");

        #40 mouse_ypos = 100;
        assert(mouse_ypos == 100);
        $display("Set up mouse_ypos on 100");

        #50 mouse_ypos = 200;
        assert(mouse_ypos == 200);
        $display("Set up mouse_ypos on 200");

        #60 screen_single = 1;
        assert(!screen_idle && screen_single);
        $display("Change on mode screen_single");

        #70 mouse_ypos = 300;
        assert(mouse_ypos == 300);
        $display("Set up mouse_ypos on 300");

        #80 mouse_ypos = 400;
        assert(mouse_ypos == 400);
        $display("Set up mouse_ypos on 400");

        #90 screen_idle = 1;  
        assert(screen_idle);
        $display("Change na mode screen_idle");
        
        $display("-----------------------------");
   
        
        #100 $finish;
    end

    always @(posedge clk) begin
        clk65MHz <= ~clk65MHz;
    end

endmodule
