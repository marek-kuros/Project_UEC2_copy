/**
 *  Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 *
 * Description:
 * Testbench ror disp_hex_mux
 * Author: Sabina
 */

`timescale 1ns / 1ps 
module disp_hex_mux_tb;

   // Input signals
   logic clk;
   logic reset;
   logic [3:0] hex3, hex2, hex1, hex0; // Hex digits
   logic [3:0] dp_in; // 4 decimal points

   // Output signals
   logic [3:0] an; // Enable 1-out-of-4 activated low
   logic [7:0] sseg; // LED segments

   // Instance of the tested module (DUT - Design Under Test)
   disp_hex_mux dut (
      .clk(clk),
      .reset(reset),
      .hex3(hex3),
      .hex2(hex2),
      .hex1(hex1),
      .hex0(hex0),
      .dp_in(dp_in),
      .an(an),
      .sseg(sseg)
   );

   // Clock generator
   always #(10) clk = ~clk; // Assuming 100 MHz clock

   // Reset generator
   initial begin
      reset = 1;
      #100; // Wait a few clock cycles
      reset = 0;
   end

   // Test logic
   initial begin
      logic [6:0] expected_sseg;
      logic [3:0] hex_in;
      int pass_cnt;
      int fail_cnt;
      int total_cnt;
      $display("--------Start of the test---------");

      // Test case
      for (int h3 = 0; h3 <= 1; h3++) begin 
         for (int h2 = 0; h2 <= 9; h2++) begin 
            for (int h1 = 0; h1 <= 1; h1++) begin
               for (int h0 = 0; h0 <= 9; h0++) begin
                  for (int dp = 0; dp <= 0; dp++) begin
                     hex3 = h3;
                     hex2 = h2;
                     hex1 = h1;
                     hex0 = h0;
                     dp_in = dp;
                     #1000; // Wait for a while


                     // Derive 'hex_in' from hex digit signals
                     
                     assign hex_in = {hex3, hex2, hex1, hex0};

                     // Expected output
                     case(hex_in)
                        4'h0: expected_sseg = 7'b1000000;
                        4'h1: expected_sseg = 7'b1111001;
                        4'h2: expected_sseg = 7'b0100100;
                        4'h3: expected_sseg = 7'b0110000;
                        4'h4: expected_sseg = 7'b0011001;
                        4'h5: expected_sseg = 7'b0010010;
                        4'h6: expected_sseg = 7'b0000010;
                        4'h7: expected_sseg = 7'b1111000;
                        4'h8: expected_sseg = 7'b0000000;
                        4'h9: expected_sseg = 7'b0010000;
                        4'ha: expected_sseg = 7'b0001000;
                        4'hb: expected_sseg = 7'b0000011;
                        4'hc: expected_sseg = 7'b1000110;
                        4'hd: expected_sseg = 7'b0100001;
                        4'he: expected_sseg = 7'b0000110;
                        default: expected_sseg = 7'b0001110; //4'hf
                     endcase

                     // Compare sseg output values
                     if (sseg === expected_sseg) begin
                         $display("Combination %02d:%02d - Test Result: PASSED", (h3 * 10 + h2), (h1 * 10 + h0));
                         pass_cnt = pass_cnt + 1;
                     end else begin
                         $display("Combination %02d:%02d - Test Result: FAILED, Expected: %b, Received: %b", (h3 * 10 + h2), (h1 * 10 + h0), expected_sseg, sseg);
                         fail_cnt = fail_cnt + 1;
                     end
                     total_cnt = total_cnt + 1;

                  end
               end 
            end
         end
      end

      // Test finished
      $display("___________________________");
      $display("End of the test.");
      $display("Total tests: %d", total_cnt);
      $display("Pass tests: %d", pass_cnt);
      $display("Fail tests: %d", fail_cnt);
      
      $finish;
   end

endmodule


