`timescale 1ns / 1ns

module disp_hex_mux_tb;

  // Testbench parameters and signals
  parameter N = 18;
  logic clk, reset;
  logic [3:0] hex0, hex1, hex2, hex3, dp_in;
  logic [3:0] an;
  logic [7:0] sseg;
  int pass_cnt = 0; // Updated the counter variable name to pass_cnt

  // Instantiate the DUT (Design Under Test)
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

  // Generate clock (default frequency 50 MHz)
  always #5 clk = ~clk;

  // Initialize testbench
  initial begin
    clk = 0;
    reset = 1;
    hex0 = 0; hex1 = 0; hex2 = 0; hex3 = 0;
    dp_in = 0;
    #10 reset = 0; // Deactivate reset

    $display("-----------------------------");
    $display("        TEST SUMMARY         ");

    // Test 1 - Display number 0x0 (decimal 0)
      hex0 = 0; hex1 = 0; hex2 = 0; hex3 = 0;
      dp_in = 0;
      #100;
      if (sseg === 7'b1000000)
        pass_cnt++; // Increment the pass_cnt variable
      else
        $display("Test 1 failed. Expected: 7'b1000000, Received: %b", sseg);

    // Test 2 - Display number 0x7 (decimal 7)
      hex0 = 7; hex1 = 0; hex2 = 0; hex3 = 0;
      dp_in = 0;
      #100;
      if (sseg === 7'b1111000)
        pass_cnt++; // Increment the pass_cnt variable
      else
        $display("Test 2 failed. Expected: 7'b1111000, Received: %b", sseg);

    // Test 3 - Display number 4'hf (decimal 15)
      hex0 = 0; hex1 = 0; hex2 = 0; hex3 = 4'hf;
      dp_in = 0;
      #100;
      if (sseg === 7'b0001110)
        pass_cnt++; // Increment the pass_cnt variable
      else
        $display("Test 3 failed. Expected: 7'b0001110, Received: %b", sseg);

    // Additional test: Display number 4'h5 with decimal point
      hex0 = 4'h5; hex1 = 0; hex2 = 0; hex3 = 0;
      dp_in = 4'b0001;
      #100;
      if (sseg === 7'b0010010)
        pass_cnt++; // Increment the pass_cnt variable
      else
        $display("5 with decimal point Test failed. Expected: 7'b0010010, Received: %b", sseg);

    // Boundary Tests
    // Maximum values for each hexadecimal digit (4'hf)
      hex0 = 4'hf; hex1 = 4'hf; hex2 = 4'hf; hex3 = 4'hf;
      dp_in = 0;
      #100;
      if (sseg === 7'b1111110)
        pass_cnt++; // Increment the pass_cnt variable
      else
        $display("Maximum values for each hex dig failed. Expected: 7'b1111110, Received: %b", sseg);


    // Maximum values for decimal points (activation)
      hex0 = 4'ha; hex1 = 4'hb; hex2 = 4'hc; hex3 = 4'hd;
      dp_in = 4'b1111;
      #100;
      if (sseg === 7'b0001111)
        pass_cnt++; // Increment the pass_cnt variable
      else
        $display("Maximum decimal points failed. Expected: 7'b0001111, Received: %b", sseg);

    // Minimum values for decimal points (deactivation)
      hex0 = 4'ha; hex1 = 4'hb; hex2 = 4'hc; hex3 = 4'hd;
      dp_in = 4'b0000;
      #100;
      if (sseg === 7'b0000110)
        pass_cnt++; // Increment the pass_cnt variable
      else
        $display("Minimum decimal points failed. Expected: 7'b0000110, Received: %b", sseg);

    // Summary of test results
      $display("Number of test cases passed: %d", pass_cnt);
      $display("-----------------------------");
      $finish;
  end

endmodule
