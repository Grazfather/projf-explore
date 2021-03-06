// Project F: Top Square (Arty with Pmod VGA)
// (C)2020 Will Green, Open Source Hardware released under the MIT License
// Learn more at https://projectf.io/posts/fpga-graphics/

`default_nettype none
`timescale 1ns / 1ps

module top_square (
    input  wire logic clk_100m,         // 100 MHz clock
    input  wire logic btn_rst,          // reset button (active low)
    output      logic vga_hsync,        // horizontal sync
    output      logic vga_vsync,        // vertical sync
    output      logic [3:0] vga_r,      // 4-bit VGA red
    output      logic [3:0] vga_g,      // 4-bit VGA green
    output      logic [3:0] vga_b       // 4-bit VGA blue
    );

    // generate pixel clock
    logic clk_pix;
    logic clk_locked;
    clock_gen clock_640x480 (
       .clk(clk_100m),
       .rst(!btn_rst),  // reset button is active low
       .clk_pix,
       .clk_locked
    );

    // display timings
    logic [9:0] sx, sy;
    logic hsync, vsync;
    logic de;
    display_timings timings_640x480 (
        .clk_pix,
        .rst(!clk_locked),  // wait for clock lock
        .sx,
        .sy,
        .hsync(vga_hsync),
        .vsync(vga_vsync),
        .de
    );

    // 32 x 32 pixel square
    logic q_draw;
    always_comb q_draw = (sx < 32 && sy < 32) ? 1 : 0;

    // VGA output
    always_comb begin
        vga_r     = !de ? 4'h0 : (q_draw ? 4'hD : 4'h3);
        vga_g     = !de ? 4'h0 : (q_draw ? 4'hA : 4'h7);
        vga_b     = !de ? 4'h0 : (q_draw ? 4'h3 : 4'hD);
    end
endmodule
