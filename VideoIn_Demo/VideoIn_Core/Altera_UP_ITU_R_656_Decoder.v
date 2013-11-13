/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_ITU_R_656_Decoder                                 *
 * Description:                                                              *
 *      This module decodes a NTSC video stream.                             *
 *                                                                           *
 *****************************************************************************/

module Altera_UP_ITU_R_656_Decoder (
	// Inputs
	clk,
	reset,

	TD_DATA,

	// Bidirectional

	// Outputs
	Y,
	CrCb,

	pixel_info,
	valid_pixel
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

input		[7:0]	TD_DATA;

// Bidirectional

// Outputs
output	reg	[7:0] 	Y;
output	reg	[7:0] 	CrCb;

output	reg	[1:0] 	pixel_info;
output	reg		 	valid_pixel;

/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire			 	active_video_code; // 4-Bytes: FF 00 00 XY

wire			 	start_of_an_even_line;
wire			 	start_of_an_odd_line;

wire		[7:0]	last_data;

// Internal Registers
reg			[7:0]	io_register;
reg	 		[7:0]	video_shift_reg [6:1];

reg					possible_active_video_code;

reg			[6:1]	active_even_line;
reg			[6:1]	active_odd_line;

reg			[3:0]	blanking_counter;
reg					blanking_done;

// State Machine Registers

// Integers
integer				i;

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential logic                              *
 *****************************************************************************/
// Input Registers
always @ (posedge clk)
	io_register	<= TD_DATA;

// Output Registers
always @ (posedge clk)
	Y		<= video_shift_reg[4];
	
always @ (posedge clk)
	CrCb	<= video_shift_reg[5];

always @(posedge clk)
begin
	if (~active_even_line[6] & active_even_line[5])
		pixel_info <= 2'h2;
	else if (~active_odd_line[6] & active_odd_line[5])
		pixel_info <= 2'h3;
	else if (active_odd_line[5])
		pixel_info <= 2'h1;
	else
		pixel_info <= 2'h0;
end

always @(posedge clk)
begin
	if (active_even_line[5] | active_odd_line[5])
		valid_pixel <= valid_pixel ^ 1'b1;
	else
		valid_pixel <= 1'b0;
end

// Internal Registers
always @ (posedge clk)
begin
	for (i = 6; i > 1; i = i - 1)
		video_shift_reg[i] <= video_shift_reg[(i - 1)];
	video_shift_reg[1] <= io_register;
end

always @(posedge clk)
begin
	if ((video_shift_reg[3] == 8'hFF) && 
			(video_shift_reg[2] == 8'h00) && 
			(video_shift_reg[1] == 8'h00))
		possible_active_video_code <= 1'b1;
	else
		possible_active_video_code <= 1'b0;
end

always @ (posedge clk)
begin
	if (reset == 1'b1)
		active_even_line			<= 6'h00;
	else
	begin
		if (start_of_an_even_line == 1'b1)
		begin
			active_even_line[6:2]	<= active_even_line[5:1];
			active_even_line[1]		<= 1'h1;
		end
		else if (active_video_code == 1'b1)
			active_even_line		<= 6'h00;
		else
			active_even_line[6:2]	<= active_even_line[5:1];
	end
end

always @ (posedge clk)
begin
	if (reset == 1'b1)
		active_odd_line				<= 6'h00;
	else 
	begin
		if (start_of_an_odd_line == 1'b1)
		begin
			active_odd_line[6:2]	<= active_odd_line[5:1];
			active_odd_line[1]		<= 1'h1;
		end
		else if (active_video_code == 1'b1)
			active_odd_line			<= 6'h00;
		else
			active_odd_line[6:2]	<= active_odd_line[5:1];
	end
end


/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/
// Output Assignments

// Internal Assignments
assign last_data = video_shift_reg[1];

assign active_video_code = 
	(  possible_active_video_code &
	 ( (last_data[5] ^ last_data[4])				==  last_data[3]) &
	 ( (last_data[6] ^ last_data[4])				==  last_data[2]) &
	 ( (last_data[6] ^ last_data[5])				==  last_data[1]) &
	 ( (last_data[6] ^ last_data[5] ^ last_data[4])	==  last_data[0])
	);
	
assign start_of_an_even_line		= active_video_code & 
		last_data[6] & ~last_data[5] & ~last_data[4];

assign start_of_an_odd_line			= active_video_code & 
		~last_data[6] & ~last_data[5] & ~last_data[4];

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule

