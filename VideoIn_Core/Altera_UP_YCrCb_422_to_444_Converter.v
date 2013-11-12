/******************************************************************************
 *                                                                            *
 * Module:       Altera_UP_YCrCb_422_to_444_Converter                         *
 * Description:                                                               *
 *      This module performs conversion from YCrCb 422 to YCrCb 444.          *
 *                                                                            *
 ******************************************************************************/

module Altera_UP_YCrCb_422_to_444_Converter (
	// Inputs
	clk,
	reset,

	Y_in,
	CrCb_in,
	pixel_info_in,
	pixel_en_in,
	
	// Bidirectionals

	// Outputs
	Y_out,
	Cr_out,
	Cb_out,
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

input		[7:0]	Y_in;
input		[7:0]	CrCb_in;
input		[1:0]	pixel_info_in;
input				pixel_en_in;

// Bidirectionals

// Outputs
output	reg	[7:0] 	Y_out;
output	reg	[7:0] 	Cr_out;
output	reg	[7:0] 	Cb_out;
output	reg	[1:0] 	pixel_info_out;
output	reg		 	pixel_en_out;

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/


/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[8:0] 	CrCb_avg;

wire		[1:0]	current_pixel_info;
wire		[1:0]	next_pixel_info;

// Internal Registers
reg	 		[7:0]	Y_shift_reg [3:1];
reg	 		[7:0]	CrCb_shift_reg [3:1];
reg	 		[1:0]	pixel_info_shift_reg [3:1];

reg					CrCb_select;

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
begin
	if (reset == 1'b1)
		Y_out <= 8'h00;
	else if (pixel_en_in)
		Y_out <= Y_shift_reg[2];
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		Cr_out <= 8'h00;
	else if (pixel_en_in)
	begin
		if (~CrCb_select)
			Cr_out <= CrCb_shift_reg[2];
		else if (current_pixel_info[1])
			Cr_out <= CrCb_shift_reg[1];
		else
			Cr_out <= CrCb_avg[8:1];
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		Cb_out <= 8'h00;
	else if (pixel_en_in)
	begin
		if (CrCb_select)
			Cb_out <= CrCb_shift_reg[2];
		else if (next_pixel_info[1])
			Cb_out <= CrCb_shift_reg[3];
		else
			Cb_out <= CrCb_avg[8:1];
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		pixel_info_out <= 2'h0;
	else if (pixel_en_in)
		pixel_info_out <= pixel_info_shift_reg[2];
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		pixel_en_out <= 1'b0;
	else
		pixel_en_out <= pixel_en_in;
end


// Internal Registers
always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		Y_shift_reg[3] <= 8'h00;
		Y_shift_reg[2] <= 8'h00;
		Y_shift_reg[1] <= 8'h00;
	end
	else if (pixel_en_in)
	begin
		Y_shift_reg[3] <= Y_shift_reg[2];
		Y_shift_reg[2] <= Y_shift_reg[1];
		Y_shift_reg[1] <= Y_in;
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		CrCb_shift_reg[3] <= 8'h00;
		CrCb_shift_reg[2] <= 8'h00;
		CrCb_shift_reg[1] <= 8'h00;
	end
	else if (pixel_en_in)
	begin
		CrCb_shift_reg[3] <= CrCb_shift_reg[2];
		CrCb_shift_reg[2] <= CrCb_shift_reg[1];
		CrCb_shift_reg[1] <= CrCb_in;
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		pixel_info_shift_reg[3] <= 2'h0;
		pixel_info_shift_reg[2] <= 2'h0;
		pixel_info_shift_reg[1] <= 2'h0;
	end
	else if (pixel_en_in)
	begin
		pixel_info_shift_reg[3] <= pixel_info_shift_reg[2];
		pixel_info_shift_reg[2] <= pixel_info_shift_reg[1];
		pixel_info_shift_reg[1] <= pixel_info_in;
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		CrCb_select <= 1'b1;
	else if (pixel_en_in)
	begin
		if (next_pixel_info[1])
			CrCb_select <= 1'b1;
		else
			CrCb_select <= CrCb_select ^ 1'b1;
	end
end

/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/
// Output Assignments

// Internal Assignments
assign CrCb_avg = ({1'b0, CrCb_shift_reg[1]}  + {1'b0, CrCb_shift_reg[3]});

assign current_pixel_info	= pixel_info_shift_reg[2];
assign next_pixel_info		= pixel_info_shift_reg[1];

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule

