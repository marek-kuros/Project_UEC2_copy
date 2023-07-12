/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2023  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * The project top module.
 */

`timescale 1 ns / 1 ps

module top
     (
    input  logic clk65MHz,
    input  logic clk100MHz,
    
    inout  logic ps2_clk,
    inout  logic ps2_data,

    input  logic [15:0] sw,

    input  logic rst,
    output logic vs,
    output logic hs,
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b
);


/**
 * Local variables and signals
 */

//wire [11:0] address; //additional wires for draw rect module lab_4
// wire [11:0] rgb_pixel;

wire [11:0] x_start, y_start;
logic [11:0] /*x_ff,*/ y_ff;

//wire left, left_sync;
// wire [11:0] x_out_ff;
// wire [11:0] y_out_ff;

wire [10:0] addr;
wire [7:0] char_pixel;

wire [7:0] char_xy;
wire [3:0] char_line;

wire screen_idle, screen_single, screen_multi;

 /**
 * Signals assignments
 */

assign vs = draw_rect_char_if.vsync;
assign hs = draw_rect_char_if.hsync;
assign {r,g,b} = draw_rect_char_if.rgb;

/**
 * Submodules instances
 */

 logic clk50;

always_ff @(posedge clk100MHz) begin
    clk50 <= ~clk50;
end

vga_if_no_rgb timing_if();
vga_if draw_bg_if();
vga_if draw_rect_if();
vga_if draw_mouse_if();
vga_if draw_rect_char_if();
vga_if sync_if();

vga_timing u_vga_timing (
    .clk65MHz,
    .rst,
    .timing_if(timing_if.tim_out)
);

draw_bg u_draw_bg (
    .clk65MHz,
    .rst,

    // .screen_idle(screen_idle),
    .screen_single(screen_single),
    .screen_multi(screen_multi),

    .timing_if(timing_if.bg_in),
    .draw_bg_if(draw_bg_if.out)
);

// draw_rect u_draw_rect(
//     .clk65MHz,
//     .rst,

//     .x_start(x_out_ff),
//     .y_start(y_out_ff),

//     .pixel_addr(address),
//     .rgb_pixel(rgb_pixel),

//     .draw_bg_if(sync_if.in),
//     .draw_rect_if(draw_rect_if.out)
// );

MouseCtl u_MouseCtl(
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .xpos(x_start),
    .ypos(y_start),
    .zpos(),
    .left(/*left*/),
    .middle(),
    .right(),
    .new_event(),
    .value(),
    .setx(),
    .sety(),
    .setmax_x(),
    .setmax_y(),
    .clk(clk100MHz),
    .rst(rst)
);

// draw_mouse u_draw_mouse(
//     .clk65MHz,
//     .rst,

//     // .x_start(x_ff),
//     // .y_start(y_ff),

//     //.enable_mouse_display_out(),

//     .draw_rect_if(draw_rect_if.in),
//     .draw_mouse_if(draw_mouse_if.out)
// );

sync u_sync(
    .clk50,
    .clk65MHz,
    .clk100MHz,
    .rst,

    .left_in(/*left*/),
    .left_out(/*left_sync*/),

    .draw_bg_if(draw_bg_if.in),
    .sync_if(sync_if.out),

    .xpos(x_start),
    .ypos(y_start),
    .xpos_out(/*x_ff*/),
    .ypos_out(y_ff)
);

// image_rom u_image_rom(
//     .clk(clk65MHz),
//     .address(address),
//     .rgb(rgb_pixel)
// );

draw_rect_ctl #(
    .x_fix_position(923),
    .width(15)
)u_draw_rect_ctl 
(
    .rst(rst),
    .clk65MHz(clk65MHz),

    //.mouse_xpos(x_ff),
    .mouse_ypos(y_ff),

    .screen_idle(screen_idle),

    .draw_bg_if(sync_if.in),
    .draw_rect_if(draw_rect_if.out)

);

draw_rect_char #(
    .x_of_box(280),
    .y_of_box(200)
)u_draw_rect_char
(
    .rst(rst),
    .clk65MHz(clk65MHz),
    .draw_mouse_if(draw_rect_if.in),
    .draw_rect_char_if(draw_rect_char_if.out),

    .screen_idle(screen_idle),
    // .screen_single(screen_single),
    // .screen_multi(screen_multi),

    .char_xy(char_xy),
    .char_line(char_line),
    .char_pixel(char_pixel)
);

font_rom u_font_rom(
    .clk(clk65MHz),
    .addr(addr),
    .char_line_pixels(char_pixel)
);

char_rom_16x16 u_char_rom_16x16(
    .char_xy(char_xy),
    .char_line(char_line),
    .char_code(addr)
);

select_game_sm u_select_game_sm(
    .clk65MHz,
    .rst,
    .sw,

    .screen_idle(screen_idle),
    .screen_single(screen_single),
    .screen_multi(screen_multi)
);

endmodule