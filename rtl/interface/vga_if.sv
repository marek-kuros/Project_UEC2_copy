/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Marek Kuros
 * Description:
 * Interface connecting similar signals.
 */

interface vga_if;

    logic [10:0] vcount;
    logic [10:0] hcount;
    logic vsync;
    logic vblnk;
    logic hsync;
    logic hblnk;
    logic [11:0] rgb;

    modport in(input vcount, hcount, vsync, vblnk, hsync, hblnk, rgb);
    modport out(output vcount, hcount, vsync, vblnk, hsync, hblnk, rgb);

endinterface

interface vga_if_no_rgb;

    logic [10:0] vcount;
    logic [10:0] hcount;
    logic vsync;
    logic vblnk;
    logic hsync;
    logic hblnk;

    modport tim_out(output vcount, hcount, vsync, vblnk, hsync, hblnk);
    modport bg_in(input vcount, hcount, vsync, vblnk, hsync, hblnk);
endinterface