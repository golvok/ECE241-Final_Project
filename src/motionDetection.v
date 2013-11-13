
`define X_WIDTH 8
`define Y_WIDTH 7
`define COLOUR_WIDTH 3

module motionDetection(
    input           CLOCK_50,               //  On Board 50 MHz
    input           CLOCK_27,

    input   [3:0]   KEY,

    output          VGA_CLK,                //  VGA Clock
    output          VGA_HS,                 //  VGA H_SYNC
    output          VGA_VS,                 //  VGA V_SYNC
    output          VGA_BLANK,              //  VGA BLANK
    output          VGA_SYNC,               //  VGA SYNC
    output  [9:0]   VGA_R,                  //  VGA Red[9:0]
    output  [9:0]   VGA_G,                  //  VGA Green[9:0]
    output  [9:0]   VGA_B,                  //  VGA Blue[9:0]

    input   [7:0]   TD_DATA,                //  TV Decoder Data bus 8 bits
    input           TD_HS,                  //  TV Decoder H_SYNC
    input           TD_VS,                  //  TV Decoder V_SYNC
    output          TD_RESET,               //  TV Decoder Reset

    output          I2C_SCLK,
    inout           I2C_SDAT
    );

    wire [4:0] red, blue;
    wire [5:0] green;

    wire vga_plot;
    wire [8:0] vga_x;
    wire [7:0] vga_y;

    Video_In vin(
        .CLOCK_50       (CLOCK_50),
        .CLOCK_27       (CLOCK_27),
        .TD_RESET       (TD_RESET),
        .reset          (~KEY[0]),

        .TD_DATA        (TD_DATA),
        .TD_HS          (TD_HS),
        .TD_VS          (TD_VS),

        .waitrequest    (0),

        .x              (vga_x),
        .y              (vga_y),
        .red            (red),
        .green          (green),
        .blue           (blue),
        .pixel_en       (vga_plot)
    );

    avconf avc(
        .I2C_SCLK       (I2C_SCLK),
        .I2C_SDAT       (I2C_SDAT),
        .CLOCK_50       (CLOCK_50),
        .reset          (~KEY[0])
    );


    vga_adapter VGA(
                .resetn(KEY[0]),
                .clock(CLOCK_50),
                .colour({red[4], green[5], blue[4]}),
                .x(vga_x),
                .y(vga_y),
                .plot(vga_plot),
                .VGA_R(VGA_R),
                .VGA_G(VGA_G),
                .VGA_B(VGA_B),
                .VGA_HS(VGA_HS),
                .VGA_VS(VGA_VS),
                .VGA_BLANK(VGA_BLANK),
                .VGA_SYNC(VGA_SYNC),
                .VGA_CLK(VGA_CLK));
            defparam VGA.RESOLUTION = "320x240";
            defparam VGA.MONOCHROME = "FALSE";
            defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;

endmodule
