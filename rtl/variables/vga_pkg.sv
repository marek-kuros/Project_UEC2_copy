/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Package with vga related constants.
 */

package vga_pkg;

// Parameters for VGA Display 800 x 600 @ 60fps using a 40 MHz clock;
localparam HOR_PIXELS = 1024;
localparam VER_PIXELS = 768;

localparam HOR_TOTAL_PIXEL_NUMBER = 1343;
localparam HOR_BLANK_START        = 1023;
localparam HOR_BLANK_TIME         = 320;
localparam HOR_SYNC_START         = 1047;
localparam HOR_SYNC_TIME          = 131;

localparam VER_TOTAL_PIXEL_NUMBER = 805;
localparam VER_BLANK_START        = 767;
localparam VER_BLANK_TIME         = 38;
localparam VER_SYNC_START         = 770;
localparam VER_SYNC_TIME          = 6;




// Add VGA timing parameters here and refer to them in other modules.

endpackage
