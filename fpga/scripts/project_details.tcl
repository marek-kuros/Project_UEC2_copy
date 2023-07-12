# Copyright (C) 2023  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# Project detiles required for generate_bitstream.tcl
# Make sure that project_name, top_module and target are correct.
# Provide paths to all the files required for synthesis and implementation.
# Depending on the file type, it should be added in the corresponding section.
# If the project does not use files of some type, leave the corresponding section commented out.

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  -- EDIT
set project_name project

# Top module name                               -- EDIT
set top_module top_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    constraints/top_vga_basys3.xdc
    constraints/clk_wiz_0.xdc
    constraints/clk_wiz_0_late.xdc
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {
    ../rtl/char_pic/char_rom_16x16.sv
    ../rtl/char_pic/draw_rect_char.sv
    ../rtl/display_timing/vga_timing.sv
    ../rtl/interface/vga_if.sv
    ../rtl/mouse_control/draw_mouse.sv
    ../rtl/rectangle_pic/draw_rect_ctl.sv
    ../rtl/synchronization/sync.sv
    ../rtl/top/top.sv
    ../rtl/variables/vga_pkg.sv
    ../rtl/background_pic/draw_bg.sv
    ../rtl/FSM/select_game_sm.sv
    rtl/top_basys3.sv
    
}

# Specify Verilog design files location         -- EDIT
set verilog_files {
    ../rtl/char_pic/font_rom.v
    ../rtl/clock/clk_wiz_0_clk_wiz.v
    ../rtl/clock/clk_wiz_0.v
}

# Specify VHDL design files location            -- EDIT
set vhdl_files {
   ../rtl/mouse_control/MouseCtl.vhd
   ../rtl/mouse_control/Ps2Interface.vhd
   ../rtl/mouse_control/MouseDisplay.vhd
}

# Specify files for a memory initialization     -- EDIT
set mem_files {
   ../rtl/rectangle/image_rom.data
   ../rtl/background_pic/ekran_startowy.dat
}
