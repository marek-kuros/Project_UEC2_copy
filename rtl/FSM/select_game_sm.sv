/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Marek Kuros
 * Description:
 * .select_game_sm
 */

`timescale 1 ns / 1 ps

module select_game_sm(
    input  logic rst,
    input  logic clk65MHz,
    
    input  logic [1:0] sw,

    output logic screen_idle,
    output logic screen_single,
    output logic screen_multi
);

/*
 * sw 0 is used to choose singleplayer
 * sw 1 is used for multiplayer
 * in case of both sw = 1 screen goes idle
*/ 

logic screen_idle_nxt, screen_single_nxt, screen_multi_nxt;

always_ff @(posedge clk65MHz) begin
    if(rst) begin
        screen_idle   <= 1;
        screen_single <= '0;
        screen_multi  <= '0;
    end else begin
        screen_idle   <= screen_idle_nxt; 
        screen_single <= screen_single_nxt;
        screen_multi  <= screen_multi_nxt;
    end
end

always_comb begin
    screen_idle_nxt = '0;
    screen_single_nxt = '0;
    screen_multi_nxt = '0;
    if(!sw[0] && !sw[1]) begin
        screen_idle_nxt = 1;
    end
    else if(sw[0] && !sw[1]) begin
        screen_single_nxt = 1;
    end
    else if(!sw[0] && sw[1]) begin
        screen_multi_nxt = 1;
    end
    else begin
        screen_idle_nxt = 1;
    end
end

endmodule