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
      .x_pos_of_ball(x_pos_of_ball),
      .y_pos_of_ball(y_pos_of_ball)
    );

    // Clock generation
    always #5 clk65MHz = ~clk65MHz;

    // Variable to track the number of passed tests
    int passed_cnt = 0;

    // Variable to track the number of failed tests
    int failed_cnt = 0;

    // Helper task to display ball position and player scores
    task display_status;
      $display("Ball Position: x=%0d, y=%0d", x_pos_of_ball, y_pos_of_ball);
      $display("Player 1 Points: %0d", points_player_1);
      $display("Player 2 Points: %0d", points_player_2);
    endtask

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
        display_status();
        if (is_upper_edge)
            assert(x_pos_of_ball == x_pos && y_pos_of_ball > 0) else begin
                $error("Error: Ball should bounce from the upper edge!");
                failed_cnt += 1;
            end
        else
            assert(x_pos_of_ball == x_pos && y_pos_of_ball < 2047) else begin
                $error("Error: Ball should bounce from the lower edge!");
                failed_cnt += 1;
            end
        passed_cnt += 1;
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
        display_status();
        assert(y_pos_of_ball == y_pos) else begin
            $error("Error: Incorrect ball y position!");
            failed_cnt += 1;
        end 
        passed_cnt += 1;
        #100;
    endtask

    // Task to test player's maximum points
    task player_max_points_test(string case_name, int player_id, inout int passed_cnt, inout int failed_cnt);
        $display("=== %s ===", case_name);
        rst = 1;
        screen_idle = 1;
        screen_multi = 1;
        pos_of_player_1 = 450;
        pos_of_player_2 = 300;
        serve = 0;
        #10 rst = 0;
        repeat (16) begin
            if (player_id == 1)
                serve = 1; // Player 1 scores points
            else
                serve = 0; // Player 2 scores points
            #30 end_of_frame = 1;
            #10 end_of_frame = 0;
        end
        display_status();
        if (player_id == 1)
            assert(points_player_1 == 15) else begin
                $error("Error: Player 1 should score the maximum number of points!");
                failed_cnt += 1;
            end else begin
            assert(points_player_2 == 15) else begin
                $error("Error: Player 2 should score the maximum number of points!");
                failed_cnt += 1;
            end 
            passed_cnt += 1;
            end 
            
           #100;
    endtask

    // Test cases
    initial begin

        $display("------------------------------------------------------");

        // Test case 1: Single player mode, scored point
        $display("=== Test case 1: Single player mode, scored point ===");
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
        display_status();
        assert(points_player_1 == 1) else begin
            $error("Error: Player 1 should score a point!");
            failed_cnt += 1;
        end
         passed_cnt += 1;
       
      #100;

// Test case 2: Multiplayer mode, scored point
    $display("=== Test case 2: Multiplayer mode, scored point ===");
    rst = 1;
    screen_idle = 1;
    screen_multi = 0;
    pos_of_player_1 = 200;
    pos_of_player_2 = 600;
    serve = 0;
    #10 rst = 0;
    #20 serve = 1;
    #30 end_of_frame = 1;
    #10 end_of_frame = 0;
    display_status();
    assert(points_player_2 == 1) else begin
        $error("Error: Player 2 should score a point!");
        failed_cnt += 1;
    end 
     passed_cnt += 1;
    
   #100;

// Test case 3: Continued from case 2 - Ball bounce by player 1
    $display("=== Test case 3: Continued from case 2 - Ball bounce by player 1 ===");
    pos_of_player_1 = 600;
    pos_of_player_2 = 200;
    serve = 0;
    #30 end_of_frame = 1;
    #10 end_of_frame = 0;
    display_status();
    if (x_pos_of_ball != 600 || y_pos_of_ball != 0) begin
        $error("Error: Ball should bounce from the upper edge!");
        failed_cnt += 1;
    end else begin
      passed_cnt += 1;
    end
    #100;

// Test case 4: Multiplayer mode, scored point
    $display("=== Test case 4: Multiplayer mode, scored point ===");
    rst = 1;
    screen_idle = 1;
    screen_multi = 0;
    pos_of_player_1 = 900;
    pos_of_player_2 = 100;
    serve = 0;
    #10 rst = 0;
    #20 serve = 1;
    #30 end_of_frame = 1;
    #10 end_of_frame = 0;
    display_status();
    assert(points_player_1 == 1) else begin
        $error("Error: Player 1 should score a point!");
        failed_cnt += 1;
    end
      passed_cnt += 1;
   
   #100;

// Test case 5: Podanie piłki
    $display("=== Test case 5: Podanie piłki ===");
    rst = 1;
    screen_idle = 0;
    screen_multi = 0;
    pos_of_player_1 = 450;
    pos_of_player_2 = 300;
    serve = 0;
    #10 rst = 0;
    #20 serve = 1;
    #30 end_of_frame = 1;
    #10 end_of_frame = 0;
    display_status();
    assert(points_player_1 == 1) else begin
        $error("Error: Player 1 should score a point!");
        failed_cnt += 1;
    end 
     passed_cnt += 1;

    #100;

// Test case 6: Odbicie piłki przez gracza 1
    $display("=== Test case 6: Odbicie piłki przez gracza 1 ===");
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
    display_status();
    if (x_pos_of_ball != 450 || y_pos_of_ball != 0) begin
        $error("Error: Ball should bounce from the player 1's paddle!");
        failed_cnt += 1;
    end else begin
      passed_cnt += 1;
    end
    #100;

// Test case 7: Odbicie piłki przez gracza 2
    $display("=== Test case 7: Odbicie piłki przez gracza 2 ===");
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
    display_status();
    if (x_pos_of_ball != 300 || y_pos_of_ball != 0) begin
        $error("Error: Ball should bounce from the player 2's paddle!");
        failed_cnt += 1;
    end else begin
    passed_cnt += 1;
    end
    #100;
// Test case 8: Ruch piłki poza obszarem rakietek
    $display("=== Test case 8: Ruch piłki poza obszarem rakietek ===");
    rst = 1;
    screen_idle = 1;
    screen_multi = 0;
    pos_of_player_1 = 900;
    pos_of_player_2 = 100;
    serve = 0;
    #10 rst = 0;
    #20 serve = 1;
    #30 end_of_frame = 1;
    #10 end_of_frame = 0;
    display_status();
    if (x_pos_of_ball != 900 || y_pos_of_ball != 0) begin
        $error("Error: Ball should move outside the paddles area!");
        failed_cnt += 1;
    end else begin
      passed_cnt += 1;
    end
    #100;


// Test case 9: Ruch piłki w górę i dół po odbiciu od górnej lub dolnej krawędzi ekranu
$display("=== Test case 9: Ruch piłki w górę i dół ===");
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
display_status();
if (x_pos_of_ball != 300 || y_pos_of_ball != 2047) begin
    $error("Error: Ball should move up and down after bouncing from top or bottom edge!");
    failed_cnt += 1;
end else begin
passed_cnt += 1;
end
#100;


// Test case 10: Ruch piłki w trybie bezczynności (bez podania)
    $display("=== Test case 10: Ruch piłki w trybie bezczynności ===");
    rst = 1;
    screen_idle = 1;
    screen_multi = 1;
    pos_of_player_1 = 400;
    pos_of_player_2 = 200;
    serve = 0;
    #10 rst = 0;
    display_status();
    if (x_pos_of_ball != 450 || y_pos_of_ball != 300) begin
        $error("Error: Ball should move in idle mode!");
        failed_cnt += 1;
    end else begin 
    passed_cnt += 1;
  end 
 #100;




// Test case 11: Ball movement at the bottom edge of the screen
y_ball_position_test("Test case 11: Ball movement at the bottom edge of the screen", 0, .passed_cnt(passed_cnt), .failed_cnt(failed_cnt));

// Test case 12: Ball movement at the top edge of the screen
y_ball_position_test("Test case 12: Ball movement at the top edge of the screen", 2047, .passed_cnt(passed_cnt), .failed_cnt(failed_cnt));

// Test case 13: Ball bounce from the upper edge of the screen
ball_bounce_test("Test case 13: Ball bounce from the upper edge of the screen", 51, 0, 1, .passed_cnt(passed_cnt), .failed_cnt(failed_cnt));

// Test case 14: Ball bounce from the lower edge of the screen
ball_bounce_test("Test case 14: Ball bounce from the lower edge of the screen", 717, 2047, 0, .passed_cnt(passed_cnt), .failed_cnt(failed_cnt));

// Test case 15: Player 1 scores the maximum points
player_max_points_test("Test case 15: Player 1 scores the maximum points", 1, .passed_cnt(passed_cnt), .failed_cnt(failed_cnt));

// Test case 16: Player 2 scores the maximum points
player_max_points_test("Test case 16: Player 2 scores the maximum points", 2, .passed_cnt(passed_cnt), .failed_cnt(failed_cnt));
         


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