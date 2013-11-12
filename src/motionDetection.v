
`define X_WIDTH 8
`define Y_WIDTH 7
`define COLOUR_WIDTH 3

module motionDetection(
    input           CLOCK_50,
    input           CLOCK_27,
    input [7:0]     D_DATA,
    input           TD_HS,
    input           TD_VS,
    input [7:0]     TD_DATA,
    output          TD_RESET,
    output [9:0]    VGA_R,
    output [9:0]    VGA_G,
    output [9:0]    VGA_B,
    output          VGA_HS,
    output          VGA_VS,
    output          VGA_BLANK,
    output          VGA_SYNC,
    output          VGA_CLK,

    output [17:0]   LEDR
);

    wire [`X_WIDTH-1:0] x;
    wire [`Y_WIDTH-1:0] y;

    assign LEDR = {x,y};

    wire pixel_en;

    wire [4:0] red, blue;
    wire [5:0] green;

    Video_In vi(
        // Inputs
        .CLOCK_50(CLOCK_50),
        .CLOCK_27(CLOCK_27),
        .reset(0),
        .TD_DATA(TD_DATA),
        .TD_HS(TD_HS),
        .TD_VS(TD_VS),
        .waitrequest(0),
        // Outputs
        .TD_RESET(TD_RESET),
        .x(x),
        .y(y),
        .red(red),
        .green(green),
        .blue(blue),
        .pixel_en(pixel_en)
    );

    vga_adapter vga(
        .resetn(1),
        .clock(CLOCK_50),
        .colour({red[4],green[5],blue[4]}),
        // .colour(3'b111),
        .x(x),
        .y(y),
        .plot(pixel_en),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK(VGA_BLANK),
        .VGA_SYNC(VGA_SYNC),
        .VGA_CLK(VGA_CLK)
    );

    defparam vga.RESOLUTION = "320x240";
    defparam vga.MONOCHROME = "FALSE";
    defparam vga.BITS_PER_COLOUR_CHANNEL = 1;
    //defparam vga.BACKGROUND_IMAGE = "images/background.mif";


endmodule