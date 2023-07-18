/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Marek Kuros
 * Description:
 * ball control FSM module
 */

 `timescale 1 ns / 1 ps

 module ball_control(
     input  logic rst,
     input  logic clk65MHz,

     input  logic end_of_frame,
     input  logic serve,
     
     input  logic [9:0] pos_of_player_1,
     input  logic [9:0] pos_of_player_2,

     input  logic screen_idle,
     input  logic screen_single,
     input  logic screen_multi,

     output logic [3:0] points_player_1,
     output logic [3:0] points_player_2,

     output logic [10:0] x_pos_of_ball,
     output logic [10:0] y_pos_of_ball

 );

 //localparams
 localparam x_player2_bounce = 100;
 localparam x_player1_bounce = 923;
 localparam size_of_ball     = 15;
 localparam y_size_of_racket = 80;

 //parameter logic [3:0] __|size_of_ball = 15|__
 //localparam y_size_of_racket = 80;
 
 //auxiliary flags and variables
 //flag
 logic fly_SW, fly_W, fly_NW, fly_NE, fly_E, fly_SE;
 //variables

 //typedef for FSM

 typedef enum logic [2:0] {
    IDLE   = 3'b000,
    START  = 3'b001,
    FLY    = 3'b010,
    P_SCOR = 3'b011   
    
 } STATE;

 STATE state, state_nxt;

 //tasks
 task check_if_ball_has_reached_racket(input logic [9:0] pos_player_1, pos_player_2, output STATE state_out);
    begin
        if(y_pos_of_ball + size_of_ball < pos_player_1 || y_pos_of_ball > pos_player_1 + y_size_of_racket) begin
            state_out = P_SCOR;
        end 
        else if(y_pos_of_ball + size_of_ball < pos_player_2 || y_pos_of_ball > pos_player_2 + y_size_of_racket) begin
            state_out = P_SCOR;
        end
        else begin
            state_out = FLY;
        end

    end
 endtask
 
 always_ff @(posedge clk65MHz) begin
     if(rst) begin
        state <= IDLE;
     end else begin
        state <= state_nxt;
     end
 end

 always_comb begin : state_selector
    if(screen_idle) begin
       state_nxt = IDLE;
    end
    else begin
        case (state)
            IDLE:   state_nxt = START;
            START:  state_nxt = serve ? FLY : START;
            
            FLY:    begin
                        if(x_pos_of_ball < x_player2_bounce || x_pos_of_ball > x_player1_bounce - size_of_ball) begin
                            check_if_ball_has_reached_racket(points_player_1, points_player_2, state_nxt);
                        end else begin
                            state_nxt = FLY;
                        end
            end
        endcase
    end
 end

 endmodule