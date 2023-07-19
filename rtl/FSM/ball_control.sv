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
     //input  logic screen_single,
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
 logic fly_SW = '0, fly_W = 1, fly_NW = '0, fly_NE  = '0, fly_E = '0, fly_SE = '0;
 //variables
 logic [10:0] x_pos_of_ball_nxt;
 logic [10:0] y_pos_of_ball_nxt;

 byte x_speed, y_speed;
 //typedef for FSM

 typedef enum logic [2:0] {
    IDLE   = 3'b000,
    START  = 3'b001,
    FLY    = 3'b010,
    P_SCOR = 3'b011   
    
 } STATE;

 STATE state, state_nxt;

 //tasks
 task check_if_ball_has_reached_racket(input logic screen_multi, right_half, logic [9:0] pos_player, output STATE state_out); //dir_of_f_L means direction of flight left to right
    begin
        if(screen_multi) begin //logic for multiplayer
            if(y_pos_of_ball + size_of_ball < pos_player || y_pos_of_ball > pos_player + y_size_of_racket) begin //seems fine
                state_out = P_SCOR;
            end 
            else begin
                state_out = FLY;
                if(right_half) begin
                    fly_E = '0;
                    fly_W = 1'b1;
                end else begin
                    fly_E = 1'b1;
                    fly_W = '0;
                end
            end
        end else begin // logic for single
            if(y_pos_of_ball + size_of_ball < pos_player || y_pos_of_ball > pos_player + y_size_of_racket) begin
                state_out = P_SCOR;
            end 
            else if(y_pos_of_ball + size_of_ball < 717 - pos_player || y_pos_of_ball > 717 - pos_player + y_size_of_racket) begin
                state_out = P_SCOR;
            end
            else if(pos_player >= 717) begin
                if(y_pos_of_ball > y_size_of_racket + 51) begin
                    state_out = P_SCOR;
                end else begin
                    state_out = FLY;
                end
            end
            else if(pos_player <= 51) begin
                if(y_pos_of_ball < 717) begin
                    state_out = P_SCOR;
                end else begin
                    state_out = FLY;
                end
            end
            else begin
                state_out = FLY;
            end
        end
    end
 endtask

 /*********************************************************************/
 
 always_ff @(posedge clk65MHz) begin : ff_for_states
     if(rst) begin
        state <= IDLE;
     end else begin
        state <= state_nxt;
     end
 end

 always_ff @(posedge clk65MHz) begin : ff_for_position_outputs
     if(rst) begin
        x_pos_of_ball <= 11'd510;
        y_pos_of_ball <= 11'd377;
     end else begin
        x_pos_of_ball <= x_pos_of_ball_nxt;
        y_pos_of_ball <= y_pos_of_ball_nxt;
     end
 end

 always_comb begin : state_selector
    if(screen_idle) begin
       state_nxt = IDLE;
    end
    else begin
        case (state)
            IDLE:   state_nxt = screen_idle ? IDLE : START;
            START:  state_nxt = serve ? FLY : START;
            
            FLY:    begin
                        if(x_pos_of_ball < x_player2_bounce) begin
                            check_if_ball_has_reached_racket(screen_multi, '0, pos_of_player_2, state_nxt);
                        end
                        else if(x_pos_of_ball > x_player1_bounce - size_of_ball) begin
                            check_if_ball_has_reached_racket(screen_multi, 1'b1, pos_of_player_1, state_nxt);
                        end else begin
                            state_nxt = FLY;
                        end
                    end
            P_SCOR: state_nxt = START;

            default: state_nxt = IDLE;
        endcase
    end
 end

 always_comb begin : action_for_states
     case (state)
        IDLE:    begin
                    x_pos_of_ball_nxt = 11'd511;
                    y_pos_of_ball_nxt = 11'd376;
                 end
        START:   begin
                    x_pos_of_ball_nxt = 11'd510;
                    y_pos_of_ball_nxt = 11'd377;
                 end
        FLY:     begin
                    if(end_of_frame) begin
                        if(fly_E)
                            x_speed = 1;
                            else
                            x_speed = -1;
                        x_pos_of_ball_nxt = x_pos_of_ball + x_speed;
                        y_pos_of_ball_nxt = y_pos_of_ball + y_speed;
                    end else begin
                        x_pos_of_ball_nxt = x_pos_of_ball;
                        y_pos_of_ball_nxt = y_pos_of_ball;
                    end
                 end
        P_SCOR:  begin
                    x_pos_of_ball_nxt = x_pos_of_ball;
                    y_pos_of_ball_nxt = y_pos_of_ball;
                 end

        default: begin
                    x_pos_of_ball_nxt = x_pos_of_ball;
                    y_pos_of_ball_nxt = y_pos_of_ball;
                 end
     endcase
 end

//  always_comb begin
//     case(1'b1)
//         fly_SW: begin
//             x_speed = -1; y_speed = 1; 
//         end

//         fly_W: begin
//             x_speed = -1; y_speed = 0; 
//         end

//         fly_NW: begin
//             x_speed = -1; y_speed = -1; 
//         end

//         fly_NE: begin
//             x_speed = 1; y_speed = -1; 
//         end

//         fly_E: begin
//             x_speed = 1; y_speed = 0; 
//         end

//         fly_SE: begin
//             x_speed = 1; y_speed = 1; 
//         end
//         default: begin
//             x_speed = 1; y_speed = 0;
//         end
//     endcase
// end

 //_________\\
 always @* begin
    $display("current state %s", state);
 end

 endmodule