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
 * Modified even more by:
 * Marek
 *
 * Description:
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */

 `timescale 1 ns / 1 ps

 module top_basys3(
     input  wire clk,
     input  wire btnC,

     input  wire btnR,

     output wire Vsync,

     inout  wire PS2Clk,
     inout  wire PS2Data,
     
     input  wire [1:0] sw,
     input  wire [7:1]  JA,
     input  wire [2:0]  JB,

     output wire [7:5]  JBo,
     output wire [6:0]  JC,

     output wire [6:0]  seg,
     output wire [3:0]  an,
     output wire        dp,

     output wire Hsync,
     output wire [3:0] vgaRed,
     output wire [3:0] vgaGreen,
     output wire [3:0] vgaBlue,
     output wire JA1
 );
  
 /**
  * Local variables and signals
  */

 wire locked;
 wire pclk;
 wire pclk_mirror;
 wire pclk100MHz;
 
 /**
  * Signals assignments
  */
 
 assign JA1 = pclk_mirror;
 
 clk_wiz_0 u_clk_wiz_0(
    .clk(clk),
    .clk_100MHz(pclk100MHz),
    .clk_65MHz(pclk),
    .locked(locked)
 );
 
 ODDR pclk_oddr (
     .Q(pclk_mirror),
     .C(pclk),
     .CE(1'b1),
     .D1(1'b1),
     .D2(1'b0),
     .R(1'b0),
     .S(1'b0)
 );
 
 
 /**
  *  Project functional top module
  */
 
 top u_top (
     .clk65MHz(pclk),
     .clk100MHz(pclk100MHz),

     .ps2_clk(PS2Clk),
     .ps2_data(PS2Data),

     .rst(btnC),

     .serve(btnR),

     .sw,
     .input_pos({JA,JB}),
     .output_pos({JBo,JC}),

     .seg,
     .an,
     .dp,

     .r(vgaRed),
     .g(vgaGreen),
     .b(vgaBlue),
     .hs(Hsync),
     .vs(Vsync)
 );
 
 endmodule