module sync(
    input logic rst,
    input logic clk40MHz,

    vga_if.in draw_bg_if,
    vga_if.out sync_if,

    input logic [11:0] xpos,
    input logic [11:0] ypos,
    output logic [11:0] xpos_out,
    output logic [11:0] ypos_out
);

always_ff @(posedge clk40MHz) begin
    if(!rst) begin
        xpos_out <= xpos;
        ypos_out <= ypos;

        sync_if.hblnk  <= draw_bg_if.hblnk;
        sync_if.hcount <= draw_bg_if.hcount;
        sync_if.hsync  <= draw_bg_if.hsync;
        sync_if.vblnk  <= draw_bg_if.vblnk;
        sync_if.vcount <= draw_bg_if.vcount;
        sync_if.vsync  <= draw_bg_if.vsync;
        sync_if.rgb    <= draw_bg_if.rgb;
    end
    else begin
        xpos_out <= '0;
        ypos_out <= '0;
  
        sync_if.hblnk  <= '0;
        sync_if.hcount <= '0;
        sync_if.hsync  <= '0;  
        sync_if.vblnk  <= '0;
        sync_if.vcount <= '0;
        sync_if.vsync  <= '0;
        sync_if.rgb    <= '0;
    end
end
endmodule