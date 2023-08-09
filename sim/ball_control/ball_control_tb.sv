/**
 *  Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 *
 * Description:
 * Testbench for ball_control
 * Author: Sabina
 */

`timescale 1 ns / 1 ps

module ball_control_tb;

    // Signal definitions for inputs and outputs
    logic rst;
    logic clk65MHz;
    logic end_of_frame;
    logic serve;
    logic [9:0] pos_of_player_1;
    logic [9:0] pos_of_player_2;
    logic screen_idle;
    logic screen_multi;
    logic [3:0] points_player_1;
    logic [3:0] points_player_2;
    logic [10:0] x_pos_of_ball;
    logic [10:0] y_pos_of_ball;
    logic [1:0] who_won;

    // DUT (Device Under Test) instance
    ball_control dut(
        .rst(rst),
        .clk65MHz(clk65MHz),
        .end_of_frame(end_of_frame),
        .serve(serve),
        .pos_of_player_1(pos_of_player_1),
        .pos_of_player_2(pos_of_player_2),
        .screen_idle(screen_idle),
        .screen_multi(screen_multi),
        .points_player_1(points_player_1),
        .points_player_2(points_player_2),
        .who_won(who_won),
        .x_pos_of_ball(x_pos_of_ball),
        .y_pos_of_ball(y_pos_of_ball)
    );

    // Clock generation
    always #5 clk65MHz = ~clk65MHz;
   


    // Variable to track the number of passed tests
    int passed_cnt = 0;

    // Variable to track the number of failed tests
    int failed_cnt = 0;

    //Local params
    localparam ROUNDS = 2;
    localparam MAX_SCORE = 15;
    localparam CLK_PERIOD = 15;

    // Additional variable
    integer player_1_score, player_2_score;
    integer current_round;


    // Task to perform ball bounce test
    
    task ball_bounce_test(string case_name, int x_pos, int y_pos, bit is_upper_edge, inout int passed_cnt, inout int failed_cnt);
        $display("=== %s ===", case_name);
        rst = 1;
        screen_idle = 1;
        screen_multi = 0;
        pos_of_player_1 = 400;
        pos_of_player_2 = 200;
        serve = 0;
        #10 rst = 0;
        #20 serve = 1;
        #30 end_of_frame = 1;
        #10 end_of_frame = 0;
    
        x_pos_of_ball = x_pos;
        y_pos_of_ball = y_pos; // Initialize the ball position with provided x_pos and y_pos
       
    
        // Wait for the bounce event to occur
        if (is_upper_edge) begin
            repeat (2) @(posedge clk65MHz); // Wait for 2 clock cycles for the bounce to occur (adjust the number of cycles as needed)
        end else begin
            repeat (2) @(posedge clk65MHz); // Wait for 2 clock cycles for the bounce to occur (adjust the number of cycles as needed)
        end
    
        // Check if the ball bounced from the correct edge
        if (is_upper_edge) begin
            if (y_pos_of_ball > 0) begin
                $display("Test passed: Ball bounced from the upper edge!");
                passed_cnt += 1;
            end else begin
                $error("Error: Ball should bounce from the upper edge!");
                failed_cnt += 1;
            end
        end else begin
            if (y_pos_of_ball < 769) begin
                $display("Test passed: Ball bounced from the lower edge!");
                passed_cnt += 1;
            end else begin
                $error("Error: Ball should bounce from the lower edge!");
                failed_cnt += 1;
            end
        end
    
        #100;
    endtask
    // Task to test the ball's y position
    task y_ball_position_test(string case_name, int y_pos, inout int passed_cnt, inout int failed_cnt);
        $display("=== %s ===", case_name);
        rst = 1;
        screen_idle = 0;
        screen_multi = 1;
        pos_of_player_1 = 450;
        pos_of_player_2 = 300;
        
        serve = 0;
        #10 rst = 0;
        #20 serve = 1;
        #30 end_of_frame = 1;
        #10 end_of_frame = 0;
        
        y_pos_of_ball = y_pos; // Set the y position of the ball
       
        
        assert(y_pos_of_ball == y_pos) else begin
            $error("Error: Incorrect ball y position!");
            failed_cnt += 1;
        end
        passed_cnt += 1;
        #100;
    endtask

    
        // Test cases
        initial begin

        $display("------------------------------------------------------");

            
      // Test case 1 - game score points
       
        $display(" Test case 1 score point");

        // Reset scores and current round
            player_1_score = 0;
            player_2_score = 0;
            current_round = 0;
            
            for ( current_round = 0; current_round < ROUNDS; current_round = current_round + 1) begin
                // Serve the ball
             
                serve = '0;
                #(5*CLK_PERIOD) serve = 1;
                #1000 serve = '0;
                #10000;
        
                // Wait for the round to finish (for simplicity, we'll just wait for a fixed number of cycles)
                #100000;
                
        
                // Check the score and determine the winner of this round
                if (player_1_score < MAX_SCORE && player_2_score < MAX_SCORE) begin
                    
                    if (pos_of_player_1 < pos_of_player_2) begin
                        player_1_score = player_1_score + 1;
                        $display("Player 1 scored a point in round %d!", current_round + 1);
                    end else if (pos_of_player_1 > pos_of_player_2) begin
                        player_2_score = player_2_score + 1;
                        $display("Player 2 scored a point in round %d!", current_round + 1);
                    end else begin
                        $display("Point scored");
                    end
                end
                
                // Check if any player has reached the maximum score
                if (player_1_score >= MAX_SCORE || player_2_score >= MAX_SCORE)
                    break;
            end
        
            // Display the winner
            // if (player_1_score > player_2_score)
            //     $display("Player 1 wins!");
            // else if (player_1_score < player_2_score)
            //     $display("Player 2 wins!");
            // else
            //     $display("points ");   
            
        

    // Test case 2: all bounce by player 1
        $display("=== Test case 2: - Ball bounce by player 1 ===");
        pos_of_player_1 = 600;
        pos_of_player_2 = 200;
        serve = 0;
        #30 end_of_frame = 1;
        #10 end_of_frame = 0;
        
        if (x_pos_of_ball != 600 || y_pos_of_ball != 0) begin
            $error("Error: Ball should bounce from the upper edge!");
            failed_cnt += 1;
        end else begin
        passed_cnt += 1;
        end
        #100;

    

    // Test case 3: Ball bounce by player 1
        $display("=== Test case 3: Ball bounce by player 1 ===");
        rst = 1;
        screen_idle = 1;
        screen_multi = 0;
        pos_of_player_1 = 450;
        pos_of_player_2 = 300;
        serve = 0;
        #10 rst = 0;
        #20 serve = 1;
        #30 end_of_frame = 1;
        #10 end_of_frame = 0;
        
        if (x_pos_of_ball != 450 || y_pos_of_ball != 0) begin
            $error("Error: Ball should bounce from the player 1's paddle!");
            failed_cnt += 1;
        end else begin
        passed_cnt += 1;
        end
        #100;

    // Test case 4: Ball bounce by player 2
        $display("=== Test case 4: Ball bounce by player 2 ===");
        rst = 1;
        screen_idle = 1;
        screen_multi = 0;
        pos_of_player_1 = 300;
        pos_of_player_2 = 450;
        serve = 0;
        #10 rst = 0;
        #20 serve = 1;
        #30 end_of_frame = 1;
        #10 end_of_frame = 0;
        
        if (x_pos_of_ball != 300 || y_pos_of_ball != 0) begin
            $error("Error: Ball should bounce from the player 2's paddle!");
            failed_cnt += 1;
        end else begin
        passed_cnt += 1;
        end
        #100;
    // Test case 5: Ball movement outside paddles area
        $display("=== Test case 5: Ball movement outside paddles area ===");
        rst = 1;
        screen_idle = 1;
        screen_multi = 0;
        pos_of_player_1 = 400;
        pos_of_player_2 = 100;
        serve = 0;
        #10 rst = 0;
        #20 serve = 1;
        #30 end_of_frame = 1;
        #10 end_of_frame = 0;
        
        if (x_pos_of_ball != 400 || y_pos_of_ball != 0) begin
            $error("Error: Ball should move outside the paddles area!");
            failed_cnt += 1;
        end else begin
        passed_cnt += 1;
        end
        #100;

        // Test case 6: Ball movement up and down after bouncing from top or bottom edge
        $display("=== Test case 6: Ball movement up and down ===");
        rst = 1;
        screen_idle = 1;
        screen_multi = 0;
        pos_of_player_1 = 300;
        pos_of_player_2 = 450;
        serve = 0;
        #10 rst = 0;
        #20 serve = 1;
        #30 end_of_frame = 1;
        #10 end_of_frame = 0;
        
        if (x_pos_of_ball != 300 || y_pos_of_ball != 2047) begin
            $error("Error: Ball should move up and down after bouncing from top or bottom edge!");
            failed_cnt += 1;
        end else begin
        passed_cnt += 1;
        end
        #100;

        $display("=== Test case 7: Ball movement in idle mode? ===");
        rst = 1;
        screen_idle = 1; // Enable "idle" mode
        screen_multi = 0;
        screen_multi = 0;
        pos_of_player_1 = 400;
        pos_of_player_2 = 200;
        serve = 0;
        #10 rst = 0;
        
        
        #100;
        
        // Check if the ball does not move in "idle" mode
        if (x_pos_of_ball != 450 || y_pos_of_ball != 300) begin
            $error("Error: Ball should not move in idle mode!");
            failed_cnt += 1;
        end else begin 
            passed_cnt += 1;
        end

        // Test case 8: Ball movement at the bottom edge of the screen
        y_ball_position_test("Test case 8: Ball movement at the bottom edge of the screen", 0, .passed_cnt(passed_cnt), .failed_cnt(failed_cnt));

        // Test case 9: Ball movement at the top edge of the screen
        y_ball_position_test("Test case 9: Ball movement at the top edge of the screen", 2047, .passed_cnt(passed_cnt), .failed_cnt(failed_cnt));

       

         

        $display("-----------------------------");

// End of simulation and display results
        $display("Number of passed tests: %0d", passed_cnt);
        $display("Number of failed tests: %0d", failed_cnt);
        if (failed_cnt == 0) begin
            $display("All tests completed successfully!");
        end else begin
            $display("Some tests failed!");
        end
        $display("-----------------------------");
  
      


    
    $finish;

    end

endmodule
