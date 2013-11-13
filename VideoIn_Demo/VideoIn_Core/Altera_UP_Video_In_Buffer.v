/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_Video_In_Buffer                                   *
 * Description:                                                              *
 *      This module store the video input stream to be processed.            *
 *                                                                           *
 *****************************************************************************/

module Altera_UP_Video_In_Buffer (
	// Inputs
	system_clk,
	video_in_clk,
	reset,

	Y_in,
	CrCb_in,
	pixel_info_in,
	valid_pixel,

	read_buffer,

	// Bidirectional

	// Outputs
	buffer_has_data,

	Y_out,
	CrCb_out,
	pixel_info_out
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				system_clk;
input				video_in_clk;
input				reset;

input		[7:0]	Y_in;
input		[7:0]	CrCb_in;
input		[1:0]	pixel_info_in;
input				valid_pixel;

input				read_buffer;

// Bidirectional

// Outputs
output				buffer_has_data;

output		[7:0]	Y_out;
output		[7:0]	CrCb_out;
output		[1:0]	pixel_info_out;

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/


/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[17:0] 	data_to_fifo;
wire		[17:0] 	data_from_fifo;

wire		[7:0]	read_used;

// Internal Registers

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
	
/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/

// Output Assignments
assign buffer_has_data		= (|(read_used[7:4]));

assign Y_out				= data_from_fifo[ 7: 0];
assign CrCb_out				= data_from_fifo[15: 8];
assign pixel_info_out		= data_from_fifo[17:16];

// Internal Assignments
assign data_to_fifo[ 7: 0]	= Y_in;
assign data_to_fifo[15: 8]	= CrCb_in;
assign data_to_fifo[17:16]	= pixel_info_in;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Dual_Clock_FIFO Video_In_Buffer (
	// Inputs
	.wrclk		(video_in_clk),
	.wrreq		(valid_pixel),
	.data		(data_to_fifo),
	
	.rdclk		(system_clk),
	.rdreq		(read_buffer),
	
	// Bidirectional
	
	// Outputs
	.rdusedw	(read_used),
	.q			(data_from_fifo)
);

endmodule

