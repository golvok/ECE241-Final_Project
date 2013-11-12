/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_Avalon_Video_In                                   *
 * Description:                                                              *
 *      This module processes a video input stream.                          *
 *                                                                           *
 *****************************************************************************/

module Video_In (
// Inputs
input				CLOCK_50,
input				CLOCK_27,
input				reset,

input		[7:0]	TD_DATA,
input				TD_HS,
input				TD_VS,

input				waitrequest,

// Outputs
output				TD_RESET,

output		[8:0] 	x,
output		[7:0] 	y,
output		[4:0] 	red,
output		[5:0] 	green,
output		[4:0] 	blue,
output				pixel_en
); 

/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/

// Internal Wires
// Video In ITU-R 656 Decoder
wire		[7:0]	decoded_Y;
wire		[7:0]	decoded_CrCb;

wire		[1:0]	decoded_pixel_info;
wire				decoded_valid_pixel;

// Video In Buffer
wire				read_buffer;

wire				buffer_has_data;

wire		[7:0]	buffered_Y;
wire		[7:0]	buffered_CrCb;
wire		[1:0]	buffered_pixel_info;

// Video In 422 to 444 Converter
wire		[7:0]	Y_444;
wire		[7:0]	Cr_444;
wire		[7:0]	Cb_444;
wire		[1:0]	pixel_info_444;
wire				pixel_en_444;

// Video In YCrCb to RGB Converter
wire		[7:0]	R;
wire		[7:0]	G;
wire		[7:0]	B;
wire		[1:0]	pixel_info_RGB;
wire				pixel_en_RGB;

// Video In Resize
wire		[15:0]	resize_pixel_data;
wire		[1:0]	resize_pixel_info;
wire				resize_pixel_en;

// Video In Deinterlacer
wire				deinterlacer_ready;

// Output Assignments
assign TD_RESET = 1'b1;

// Internal Assignments
assign read_buffer = buffer_has_data & deinterlacer_ready;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Altera_UP_ITU_R_656_Decoder ITU_R_656_Decoder (
	// Inputs
	.clk			(CLOCK_27),
	.reset			(reset),

	.TD_DATA		(TD_DATA),

	// Outputs
	.Y				(decoded_Y),
	.CrCb			(decoded_CrCb),
	
	.pixel_info		(decoded_pixel_info),
	.valid_pixel	(decoded_valid_pixel)
);

Altera_UP_Video_In_Buffer Video_In_Data_Buffer (
	// Inputs
	.system_clk			(CLOCK_50),
	.video_in_clk		(CLOCK_27),
	.reset				(reset),

	.Y_in				(decoded_Y),
	.CrCb_in			(decoded_CrCb),
	.pixel_info_in		(decoded_pixel_info),
	.valid_pixel		(decoded_valid_pixel),

	.read_buffer		(read_buffer),

	// Outputs
	.buffer_has_data	(buffer_has_data),

	.Y_out				(buffered_Y),
	.CrCb_out			(buffered_CrCb),
	.pixel_info_out		(buffered_pixel_info)
);

Altera_UP_YCrCb_422_to_444_Converter YCrCb_422_to_444_Converter (
	// Inputs
	.clk			(CLOCK_50),
	.reset			(reset),

	.Y_in			(buffered_Y),
	.CrCb_in		(buffered_CrCb),
	.pixel_info_in	(buffered_pixel_info),
	.pixel_en_in	(read_buffer),

	// Outputs
	.Y_out			(Y_444),
	.Cr_out			(Cr_444),
	.Cb_out			(Cb_444),
	.pixel_info_out	(pixel_info_444),
	.pixel_en_out	(pixel_en_444)
);

Altera_UP_YCrCb_to_RGB_Converter YCrCb_to_RGB_Converter (
	// Inputs
	.clk			(CLOCK_50),
	.reset			(reset),

	.Y				(Y_444),
	.Cr				(Cr_444),
	.Cb				(Cb_444),
	.pixel_info_in	(pixel_info_444),
	.pixel_en_in	(pixel_en_444),

	// Outputs
	.R				(R),
	.G				(G),
	.B				(B),
	.pixel_info_out	(pixel_info_RGB),
	.pixel_en_out	(pixel_en_RGB)
);

Altera_UP_Video_In_Resize Video_In_Resize (
	// Inputs
	.clk			(CLOCK_50),
	.reset			(reset),

	.pixel_data_in	({R[7:3], G[7:2], B[7:3]}),
	.pixel_info_in	(pixel_info_RGB),
	.pixel_en_in	(pixel_en_RGB),

	// Outputs
	.pixel_data_out	(resize_pixel_data),
	.pixel_info_out	(resize_pixel_info),
	.pixel_en_out	(resize_pixel_en)
);

Altera_UP_Video_In_Deinterlacer Video_In_Deinterlacer (
	// Inputs
	.clk						(CLOCK_50),
	.reset						(reset),

	.pixel_data					(resize_pixel_data),
	.pixel_info					(resize_pixel_info),
	.pixel_en					(resize_pixel_en),

	.waitrequest				(waitrequest),

	// Outputs
	.ready_for_data				(deinterlacer_ready),

	.address					({y, x}),
	.writedata					({red, green, blue}),
	.write						(pixel_en)
);

endmodule
