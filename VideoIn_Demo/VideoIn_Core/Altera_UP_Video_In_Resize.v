/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_Video_In_Resize                                   *
 * Description:                                                              *
 *      This module resizes a video in stream.                               *
 *                                                                           *
 *****************************************************************************/

module Altera_UP_Video_In_Resize (
	// Inputs
	clk,
	reset,

	pixel_data_in,
	pixel_info_in,
	pixel_en_in,

	// Bidirectional

	// Outputs
	pixel_data_out,
	pixel_info_out,
	pixel_en_out
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

input		[15:0]	pixel_data_in;
input		[1:0]	pixel_info_in;
input				pixel_en_in;

// Bidirectional

// Outputs
output	reg	[15:0]	pixel_data_out;
output	reg	[1:0]	pixel_info_out;
output	reg			pixel_en_out;

/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/
// Internal Wires

// Internal Registers
reg					keep_pixel;

// State Machine Registers

// Integers


/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential logic                              *
 *****************************************************************************/
// Output Registers
always @(posedge clk)
	pixel_data_out <= pixel_data_in;

always @(posedge clk)
	pixel_info_out <= pixel_info_in;

always @(posedge clk)
	pixel_en_out <= (pixel_en_in & keep_pixel) | 
					(pixel_en_in & pixel_info_in[1]);

// Internal Registers
always @(posedge clk)
begin
	if (reset)
		keep_pixel <= 1'b0;
	else if (pixel_en_in & pixel_info_in[1])
		keep_pixel <= 1'b0;
	else if (pixel_en_in)
		keep_pixel <= keep_pixel ^ 1'b1;
end


/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/
// Output Assignments

// Internal Assignments

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule
