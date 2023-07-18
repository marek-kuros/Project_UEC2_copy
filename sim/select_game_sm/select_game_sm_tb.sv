/**
 *  Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 *
 * Description:
 * Testbench for vga_timing module.
 * Author: Sabina
 */

 `timescale 1 ns / 1 ps

 module select_game_sm_tb;
  
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
     logic [15:0] in;
     logic idle;
     logic single;
     logic multi;
     logic [31:0] ok_cnt = 32'd0;
     logic [31:0] error_cnt = 32'd0;
     
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
     select_game_sm dut (
         .clk65MHz(clk),
         .rst(rst),
         .sw(in),
         .screen_idle(idle),
         .screen_single(single),
         .screen_multi(multi)
     ); 
      
     always @(posedge clk) begin
         in[0] = 1;
         in[1] = 0;
             
         if (single != 1) begin
             $display("Test failed! For active sw, 0 should be single-mode");
             error_cnt = error_cnt + 1;
         end else begin
             ok_cnt = ok_cnt + 1;
         end
 
         in[0] = 0;
         in[1] = 1;
           
         if (multi != 1) begin
             $display("Test failed! For active sw, 1 should be multi-mode");
             error_cnt = error_cnt + 1;
         end else begin 
             ok_cnt = ok_cnt + 1;
         end
 
         in[0] = 1;
         in[1] = 1;
            
         if (idle != 1) begin
             $display("Test failed! For active sw, 0 and sw 1 should be idle-mode");
             error_cnt = error_cnt + 1;
         end else begin 
             ok_cnt = ok_cnt + 1;
         end
 
         in[0] = 0;
         in[1] = 0;
             
         if (idle != 1) begin
             $display("Test failed! For not active sw, 0 and sw 1 should be idle-mode");
             error_cnt = error_cnt + 1;
         end else begin 
             ok_cnt = ok_cnt + 1;
         end
            
         $display("____________________________________");
         $display("Result: passed %d, error %d", ok_cnt, error_cnt);
         
         if (ok_cnt == 4) begin
             $display("All tests passed!");
         end else begin
             $display("Some tests failed!");
         end
         
         $stop;
     end
  
 endmodule