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

     output logic [1:0] who_won,

     output logic [10:0] x_pos_of_ball,
     output logic [10:0] y_pos_of_ball

 );

 //localparams
 localparam x_player2_bounce = 100;
 localparam x_player1_bounce = 923;
 localparam size_of_ball     = 15;
 localparam y_size_of_racket = 80;

 localparam speed_of_ball    = 3;

 //parameter logic [3:0] __|size_of_ball = 15|__
 //localparam y_size_of_racket = 80;
 
 //auxiliary flags and variables
 //flag
 logic fly_SW, fly_W, fly_NW, fly_NE, fly_E, fly_SE;
 logic fly_SW_nxt, fly_W_nxt, fly_NW_nxt, fly_NE_nxt, fly_E_nxt, fly_SE_nxt;

 logic reached_max;
 //variables
 logic [3:0] points_player_1_nxt = '0;
 logic [3:0] points_player_2_nxt = '0;

 logic [10:0] x_pos_of_ball_nxt;
 logic [10:0] y_pos_of_ball_nxt;

 logic [1:0] who_won_nxt; 

 integer x_speed, y_speed;
 //typedef for FSM

 typedef enum logic [2:0] {
    IDLE   = 3'b000,
    START  = 3'b001,
    FLY    = 3'b010,
    P_SCOR = 3'b011,
    WIN    = 3'b100   
    
 } STATE;

 STATE state, state_nxt;

 //tasks
 task check_if_ball_has_reached_racket(input logic screen_multi, logic [9:0] pos_player_1, logic [9:0] pos_player_2, output STATE state_out); //dir_of_f_L means direction of flight left to right
    begin
        if(screen_multi) begin //logic for multiplayer
            if(x_pos_of_ball >= x_player1_bounce - size_of_ball && (y_pos_of_ball + size_of_ball < pos_player_1 || y_pos_of_ball > pos_player_1 + y_size_of_racket)) begin //seems fine
                state_out = P_SCOR;
            end
            else if(x_pos_of_ball <= x_player2_bounce && (y_pos_of_ball + size_of_ball < pos_player_2 || y_pos_of_ball > pos_player_2 + y_size_of_racket)) begin //seems fine
                state_out = P_SCOR;
            end 
            else begin
                state_out = FLY;
            end
        end else begin // logic for single
            if(x_pos_of_ball >= x_player1_bounce - size_of_ball && (y_pos_of_ball + size_of_ball < pos_player_1 || y_pos_of_ball > pos_player_1 + y_size_of_racket)) begin
                state_out = P_SCOR;
            end 
            else if(x_pos_of_ball <= x_player2_bounce && (y_pos_of_ball + size_of_ball < 717 - pos_player_1 || y_pos_of_ball > 717 - pos_player_1 + y_size_of_racket)) begin
                state_out = P_SCOR;

            end
            // else if(pos_player_1 >= 717) begin
            //     if(y_pos_of_ball > y_size_of_racket + 51) begin
            //         state_out = P_SCOR;
            //     end else begin
            //         state_out = FLY;
            //     end
            // end
            // else if(pos_player_1 <= 51) begin
            //     if(y_pos_of_ball < 717) begin
            //         state_out = P_SCOR;
            //     end else begin
            //         state_out = FLY;
            //     end
            // end
            else begin
                state_out = FLY;
            end
        end
    end
 endtask

 task direction_of_bounce(input logic screen_multi, logic [9:0] pos_player_1, logic [9:0] pos_player_2, output logic fly_SW_nxt, fly_W_nxt, fly_NW_nxt, fly_NE_nxt, fly_E_nxt, fly_SE_nxt);
    begin
        {fly_SW_nxt, fly_W_nxt, fly_NW_nxt, fly_NE_nxt, fly_E_nxt, fly_SE_nxt} = '0;
        if(screen_multi) begin
            if(x_pos_of_ball >= x_player1_bounce - size_of_ball) begin
                if(y_pos_of_ball + size_of_ball >= pos_player_1 && y_pos_of_ball + size_of_ball < pos_player_1 + y_size_of_racket/3) begin
                    fly_NW_nxt = 1;
                end
                else if(y_pos_of_ball + size_of_ball >= pos_player_1 + y_size_of_racket/3 && y_pos_of_ball + size_of_ball < pos_player_1 + y_size_of_racket/2 + size_of_ball) begin
                    fly_W_nxt = 1;
                end
                else begin
                    fly_SW_nxt = 1;
                end
            end else begin
                if(y_pos_of_ball + size_of_ball >= pos_player_2 && y_pos_of_ball + size_of_ball < pos_player_2 + y_size_of_racket/3) begin
                    fly_NE_nxt = 1;
                end
                else if(y_pos_of_ball + size_of_ball >= pos_player_2 + y_size_of_racket/3 && y_pos_of_ball + size_of_ball < pos_player_2 + y_size_of_racket/2 + size_of_ball) begin
                    fly_E_nxt = 1;
                end
                else begin
                    fly_SE_nxt = 1;
                end
            end
        end else begin
            if(x_pos_of_ball >= x_player1_bounce - size_of_ball) begin
                if(y_pos_of_ball + size_of_ball >= pos_player_1 && y_pos_of_ball + size_of_ball < pos_player_1 + y_size_of_racket/3) begin
                    fly_NW_nxt = 1;
                end
                else if(y_pos_of_ball + size_of_ball >= pos_player_1 + y_size_of_racket/3 && y_pos_of_ball + size_of_ball < pos_player_1 + y_size_of_racket/2 + size_of_ball) begin
                    fly_W_nxt = 1;
                end
                else begin
                    fly_SW_nxt = 1;
                end
            end else begin
                if(y_pos_of_ball + size_of_ball >= 717 - pos_player_1 && y_pos_of_ball + size_of_ball < 717 - pos_player_1 + y_size_of_racket/3) begin
                    fly_NE_nxt = 1;
                end
                else if(y_pos_of_ball + size_of_ball >= 717 - pos_player_1 + y_size_of_racket/3 && y_pos_of_ball + size_of_ball < 717 - pos_player_1 + y_size_of_racket/2 + size_of_ball) begin
                    fly_E_nxt = 1;
                end
                else begin
                    fly_SE_nxt = 1;
                end
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

 always_ff @(posedge clk65MHz) begin : ff_for_flight_direction
     if(rst) begin
        {fly_SW, fly_W, fly_NW, fly_NE, fly_E, fly_SE} <= '0;
     end else begin
        {fly_SW, fly_W, fly_NW, fly_NE, fly_E, fly_SE} <= {fly_SW_nxt, fly_W_nxt, fly_NW_nxt, fly_NE_nxt, fly_E_nxt, fly_SE_nxt};
     end
 end

 always @(posedge clk65MHz) begin : ff_for_points_counter
     if(rst) begin
        points_player_1 <= '0;
        points_player_2 <= '0;
     end else begin
        points_player_1 <= points_player_1_nxt;
        points_player_2 <= points_player_2_nxt;
     end
 end

 always @(posedge clk65MHz) begin : ff_for_showing_winner
    if(rst) begin
        who_won <= '0;
    end else begin
        who_won <= who_won_nxt;
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
                        if(x_pos_of_ball <= x_player2_bounce || x_pos_of_ball >= x_player1_bounce - size_of_ball) begin
                            check_if_ball_has_reached_racket(screen_multi, pos_of_player_1, pos_of_player_2, state_nxt);
                        end
                        else begin
                            state_nxt = FLY;
                        end
                    end
            P_SCOR: begin
                        if(points_player_1 >= 10 || points_player_2 >= 10) begin // in order to uses the same screen for points make flag here
                            state_nxt = WIN;
                        end
                        else if(reached_max) begin
                            state_nxt = START;
                        end
                        else begin
                            state_nxt = P_SCOR;
                        end
                    end
            WIN:    state_nxt = serve ? IDLE : WIN;

            default: state_nxt = IDLE;
        endcase
    end
 end

 always_comb begin : action_for_states //seems fine
    reached_max = '0;
     case (state)
        IDLE:    begin
                    x_pos_of_ball_nxt = 11'd504;
                    y_pos_of_ball_nxt = 11'd376;
                 end
        START:   begin
                    x_pos_of_ball_nxt = 11'd504;
                    y_pos_of_ball_nxt = 11'd376;
                 end
        FLY:     begin
                    if(end_of_frame) begin
                        x_pos_of_ball_nxt = x_pos_of_ball + x_speed;
                        y_pos_of_ball_nxt = y_pos_of_ball + y_speed;
                    end else begin
                        x_pos_of_ball_nxt = x_pos_of_ball;
                        y_pos_of_ball_nxt = y_pos_of_ball;
                    end
                 end
        P_SCOR:  begin
            //glide to the end
                    if(end_of_frame) begin
                        if(x_pos_of_ball > 1022 - speed_of_ball || x_pos_of_ball < speed_of_ball + 1) begin
                            x_pos_of_ball_nxt = x_pos_of_ball;
                            y_pos_of_ball_nxt = y_pos_of_ball;
                            reached_max = 1;
                        end else begin
                            x_pos_of_ball_nxt = x_pos_of_ball + x_speed;
                            y_pos_of_ball_nxt = y_pos_of_ball + y_speed;
                            reached_max = '0;
                        end
                    end else begin
                        x_pos_of_ball_nxt = x_pos_of_ball;
                        y_pos_of_ball_nxt = y_pos_of_ball;
                    end
                 end
        WIN:     begin
                    x_pos_of_ball_nxt = x_pos_of_ball;
                    y_pos_of_ball_nxt = '0;
                 end

        default: begin
                    x_pos_of_ball_nxt = x_pos_of_ball;
                    y_pos_of_ball_nxt = y_pos_of_ball;
                 end
     endcase
 end

 always_comb begin  : set_direction_of_the_flight
    //hit upper bar
     if(y_pos_of_ball <= 51 && fly_NE && x_pos_of_ball > x_player2_bounce && x_pos_of_ball < x_player1_bounce) begin
        {fly_SW_nxt, fly_W_nxt, fly_NW_nxt, fly_NE_nxt, fly_E_nxt, fly_SE_nxt} = '0;
        fly_SE_nxt = 1;
     end
     else if(y_pos_of_ball <= 51 && fly_NW && x_pos_of_ball > x_player2_bounce && x_pos_of_ball < x_player1_bounce) begin
        {fly_SW_nxt, fly_W_nxt, fly_NW_nxt, fly_NE_nxt, fly_E_nxt, fly_SE_nxt} = '0;
        fly_SW_nxt = 1;
     end
    // hit lower bar
     else if(y_pos_of_ball >= 717 - size_of_ball && fly_SE && x_pos_of_ball > x_player2_bounce && x_pos_of_ball < x_player1_bounce) begin
        {fly_SW_nxt, fly_W_nxt, fly_NW_nxt, fly_NE_nxt, fly_E_nxt, fly_SE_nxt} = '0;
        fly_NE_nxt = 1;
     end
     else if(y_pos_of_ball >= 717 - size_of_ball && fly_SW && x_pos_of_ball > x_player2_bounce && x_pos_of_ball < x_player1_bounce) begin
        {fly_SW_nxt, fly_W_nxt, fly_NW_nxt, fly_NE_nxt, fly_E_nxt, fly_SE_nxt} = '0;
        fly_NW_nxt = 1;
     end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //hit racket

     else if(x_pos_of_ball >= x_player1_bounce && state_nxt == FLY) begin
        {fly_SW_nxt, fly_W_nxt, fly_NW_nxt, fly_NE_nxt, fly_E_nxt, fly_SE_nxt} = '0;
        direction_of_bounce(screen_multi, pos_of_player_1, pos_of_player_2, fly_SW_nxt, fly_W_nxt, fly_NW_nxt, fly_NE_nxt, fly_E_nxt, fly_SE_nxt);
     end
     else if(x_pos_of_ball <= x_player2_bounce && state_nxt == FLY) begin
        {fly_SW_nxt, fly_W_nxt, fly_NW_nxt, fly_NE_nxt, fly_E_nxt, fly_SE_nxt} = '0;
        direction_of_bounce(screen_multi, pos_of_player_1, pos_of_player_2, fly_SW_nxt, fly_W_nxt, fly_NW_nxt, fly_NE_nxt, fly_E_nxt, fly_SE_nxt);
     end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     //start

     else if(state == START) begin
        {fly_SW_nxt, fly_W_nxt, fly_NW_nxt, fly_NE_nxt, fly_E_nxt, fly_SE_nxt} = '0;
        fly_W_nxt = 1;
     end
     else begin
        {fly_SW_nxt, fly_W_nxt, fly_NW_nxt, fly_NE_nxt, fly_E_nxt, fly_SE_nxt} = {fly_SW, fly_W, fly_NW, fly_NE, fly_E, fly_SE};
     end
 end

 always_comb begin : set_speed //seems fine
    case(1'b1)
        fly_SW: begin
            x_speed = -speed_of_ball; y_speed = speed_of_ball; 
        end

        fly_W: begin
            x_speed = -speed_of_ball; y_speed = '0; 
        end

        fly_NW: begin
            x_speed = -speed_of_ball; y_speed = -speed_of_ball; 
        end

        fly_NE: begin
            x_speed = speed_of_ball; y_speed = -speed_of_ball; 
        end

        fly_E: begin
            x_speed = speed_of_ball; y_speed = '0; 
        end

        fly_SE: begin
            x_speed = speed_of_ball; y_speed = speed_of_ball; 
        end
        default: begin
            x_speed = '0; y_speed = '0;
        end
    endcase
end

 always_comb begin : comb_logic_for_points_and_winner_showing
    who_won_nxt = 0;
    if(state == IDLE || rst) begin
        points_player_1_nxt = '0;
        points_player_2_nxt = '0;
    end
    else if(state == P_SCOR && state_nxt == START) begin
        if((fly_SW || fly_W || fly_NW)) begin
            points_player_2_nxt = points_player_2 + 1'b1;
            points_player_1_nxt = points_player_1;
        end else begin
            points_player_1_nxt = points_player_1 + 1'b1;
            points_player_2_nxt = points_player_2;
        end
    end
    else if(state == WIN) begin
        points_player_1_nxt = points_player_1;
        points_player_2_nxt = points_player_2;
        if(points_player_1 > points_player_2) begin
            who_won_nxt = 2;
        end else begin
            who_won_nxt = 1;
        end
    end
    else begin 
        points_player_1_nxt = points_player_1;
        points_player_2_nxt = points_player_2;
    end
 end
 //_________\\
  always @* begin
    if(state == WIN)
        $display("current state %s", state);
  end
 
 
 always @* begin
    $display("points %b, %b, %d", points_player_1, points_player_2, who_won_nxt);
 end

 endmodule