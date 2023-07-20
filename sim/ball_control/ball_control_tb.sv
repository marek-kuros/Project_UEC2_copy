`timescale 1 ns / 1 ps

module ball_control_tb;
    import vga_pkg::*;

    //parameters
    localparam CLK_PERIOD = 15;

    //variables

    logic clk, rst, end_of_frame, serve, screen_idle, screen_multi;

    logic [9:0] pos_of_player_1, pos_of_player_2;
    logic [10:0] x_pos_of_ball, y_pos_of_ball;

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD) clk = ~clk;
    end

    initial begin
        rst = 1'b0;
        #(2*CLK_PERIOD) rst = 1'b1;
        rst = 1'b1;
        #(2*CLK_PERIOD) rst = 1'b0;
    end
    
    initial begin
        serve = '0;
        #(5*CLK_PERIOD) serve = 1;
        #100 serve = '0;
    end

    //assign block
    assign screen_idle = 0;
    assign screen_multi = 1;
    assign end_of_frame = 1;

    assign pos_of_player_1 = 10'd377;
    assign pos_of_player_2 = 10'd377;
    
    //assign serve = 1;


    ball_control dut(
        .rst(rst),
        .clk65MHz(clk),

        .end_of_frame(end_of_frame),
        .serve(serve),

        .pos_of_player_1(pos_of_player_1),
        .pos_of_player_2(pos_of_player_2),

        .screen_idle(screen_idle),
        .screen_multi(screen_multi),

        .points_player_1(),
        .points_player_2(),

        .x_pos_of_ball(x_pos_of_ball),
        .y_pos_of_ball(y_pos_of_ball)
    );

//always #1000000 $finish;

always @* $display("x of ball %d, y of ball %d", x_pos_of_ball, y_pos_of_ball);

endmodule