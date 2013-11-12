/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_Video_In_Deinterlacer                             *
 * Description:                                                              *
 *      This module deinterlaces a video in stream.                          *
 *                                                                           *
 *****************************************************************************/

module Altera_UP_Video_In_Deinterlacer (
	// Inputs
	clk,
	reset,

	pixel_data,
	pixel_info,
	pixel_en,

	waitrequest,

	// Bidirectional

	// Outputs
	ready_for_data,

	address,
	writedata,
	write
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				clk;
input				reset;

input		[15:0]	pixel_data;
input		[1:0]	pixel_info;
input				pixel_en;

input				waitrequest;

// Bidirectional

// Outputs
output				ready_for_data;

output		[16:0] 	address;
output		[15:0] 	writedata;
output				write; 

/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire		[17:0]	data_to_fifo;
wire		[17:0]	data_from_fifo;

wire				read_fifo;

wire				fifo_empty;
wire		[7:0]	fifo_used_words;
/*
wire		[3:0]	control_to_fifo;
wire		[3:0]	control_from_fifo;

wire				proceed;

wire				control_fifo_empty;
wire				data_fifo_empty;

wire				control_fifo_full;
wire				data_fifo_full;
*/
// Internal Registers
reg					line_type;
/*
reg					last_active_even_pixel;
reg					last_active_odd_pixel;
reg					last_vertical_blanking;
*/
reg			[8:0]	x_address;
reg			[7:0]	y_address;

// State Machine Registers

// Integers


/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential logic                              *
 *****************************************************************************/
// Output Registers

// Internal Registers
always @(posedge clk)
begin
	if (reset == 1'b1)
		line_type <= 1'b0;
	else if (read_fifo == 1'b1)
		line_type <= data_from_fifo[16];
end

/*
always @(posedge clk)
begin
	if (clk_en)
		last_active_even_pixel	<= active_even_pixel;
end

always @(posedge clk)
begin
	if (clk_en)
		last_active_odd_pixel	<= active_odd_pixel;
end

always @(posedge clk)
begin
	if (clk_en)
		last_vertical_blanking	<= vertical_blanking;
end

*/
always @(posedge clk)
begin
	if (reset == 1'b1)
		x_address = 0;
	else if (read_fifo & data_from_fifo[17])
		x_address = 0;
	else if (read_fifo & (x_address < 320))
		x_address = x_address + 1;
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		y_address = 0;
	else if (read_fifo & data_from_fifo[17] & (data_from_fifo[16] ^ line_type))
	begin
		if (data_from_fifo[16])
			y_address = 0;
		else
			y_address = 240;
	end
	else if (read_fifo & data_from_fifo[17] & (y_address < 240))
		y_address = y_address + 1;
end

/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/
// Output Assignments
assign ready_for_data	= (fifo_used_words[7:5] == 3'h7) ? 1'b0 : 1'b1;

assign address			= {y_address, x_address};
assign writedata		= data_from_fifo[15:0];
assign write			= ~fifo_empty;

// Internal Assignments
assign data_to_fifo[15: 0]	= pixel_data;
assign data_to_fifo[17:16]	= pixel_info;
/*
assign control_to_fifo[0]	= ~last_active_even_pixel & active_even_pixel;
assign control_to_fifo[1]	= last_vertical_blanking & control_to_fifo[0];
assign control_to_fifo[2]	= ~last_active_odd_pixel & active_odd_pixel;
assign control_to_fifo[3]	= last_vertical_blanking & control_to_fifo[2];

*/
assign read_fifo			= write & ~waitrequest;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Video_In_FIFO Video_In_FIFO (
	// Inputs
	.clock	(clk),
	.sclr	(reset),

	.wrreq	(pixel_en),
	.data	(data_to_fifo),
	
	.rdreq	(read_fifo),
	
	// Bidirectional
	
	// Outputs
	.empty	(fifo_empty),
	.usedw	(fifo_used_words),
	.q		(data_from_fifo)
);

endmodule
