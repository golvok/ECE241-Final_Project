/******************************************************************************
 *                                                                            *
 * Module:       Altera_UP_YCrCb_to_RGB_Converter                             *
 * Description:                                                               *
 *      This module performs colour space conversion from YCrCb to RGB.       *
 *                                                                            *
 ******************************************************************************/

module Altera_UP_YCrCb_to_RGB_Converter (
	// Inputs
	clk,
	reset,

	Y,
	Cr,
	Cb,
	pixel_info_in,
	pixel_en_in,

	// Bidirectionals

	// Outputs
	R,
	G,
	B,
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

input		[7:0]	Y;
input		[7:0]	Cr;
input		[7:0]	Cb;
input		[1:0]	pixel_info_in;
input				pixel_en_in;

// Bidirectionals

// Outputs
output	reg	[7:0] 	R;
output	reg	[7:0] 	G;
output	reg	[7:0] 	B;
output	reg	[1:0]	pixel_info_out;
output	reg			pixel_en_out;

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/


/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[35:0] 	product_0;
wire		[35:0] 	product_1;
wire		[35:0] 	product_2;
wire		[35:0] 	product_3;
wire		[35:0] 	product_4;

wire		[10:0]	R_sum;
wire		[10:0]	G_sum;
wire		[10:0]	B_sum;

// Internal Registers
reg			[10:0]	Y_sub;
reg			[10:0]	Cr_sub;
reg			[10:0]	Cb_sub;

reg			[10:0]	Y_1d1640;
reg			[10:0]	Cr_0d813;
reg			[10:0]	Cr_1d596;
reg			[10:0]	Cb_2d017;
reg			[10:0]	Cb_0d392;

reg	 		[1:0]	pixel_info_shift_reg [3:1];
reg	 				pixel_en_shift_reg [3:1];

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential logic                              *
 *****************************************************************************/

// Output Registers
always @ (posedge clk)
begin
	if (reset == 1'b1)
	begin
		R <= 8'h00;
		G <= 8'h00;
		B <= 8'h00;
	end
	else
	begin
		if (R_sum[10] == 1'b1) // Negative number
			R <= 8'h00;
		else if ((R_sum[9] | R_sum[8]) == 1'b1) // Number greater than 255
			R <= 8'hFF;
		else
			R <= R_sum[7:0];

		if (G_sum[10] == 1'b1) // Negative number
			G <= 8'h00;
		else if ((G_sum[9] | G_sum[8]) == 1'b1) // Number greater than 255
			G <= 8'hFF;
		else
			G <= G_sum[7:0];

		if (B_sum[10] == 1'b1) // Negative number
			B <= 8'h00;
		else if ((B_sum[9] | B_sum[8]) == 1'b1) // Number greater than 255
			B <= 8'hFF;
		else
			B <= B_sum[7:0];
	end
end

always @ (posedge clk)
	pixel_info_out	<= pixel_info_shift_reg[2];

always @ (posedge clk)
	pixel_en_out	<= pixel_en_shift_reg[2];

// Internal Registers
// ---------------------------------------------------------------------------
//
// Offset Y, Cr, and Cb.
// Note: Internal wires are all 11 bits from here out, to allow for 
// increasing bit extent due to additions, subtractions, and multiplies
// Signs are extended when appropriate.
//
//assign Y_sub  = ({3'b000, Y}  - 'd16);  // result always positive
//assign Cr_sub = ({3'b000, Cr} - 'd128); // result is positive or negative
//assign Cb_sub = ({3'b000, Cb} - 'd128); // result is positive or negative

always @ (posedge clk)
begin
	if (reset == 1'b1)
	begin
		Y_sub	<= 11'h000;
		Cr_sub	<= 11'h000;
		Cb_sub	<= 11'h000;
	end
	else
	begin
//		Y_sub	<= ({{3{Y[7]}}, Y}  - 'd16);  // result always positive
//		Cr_sub	<= ({{3{Cr[7]}}, Cr} - 'd128); // result is positive or negative
//		Cb_sub	<= ({{3{Cb[7]}}, Cb} - 'd128); // result is positive or negative
		Y_sub	<= ({3'b000, Y}  - 'd16);  // result always positive
		Cr_sub	<= ({3'b000, Cr} - 'd128); // result is positive or negative
		Cb_sub	<= ({3'b000, Cb} - 'd128); // result is positive or negative
	end
end

always @ (posedge clk)
begin
	if (reset == 1'b1)
	begin
		Y_1d1640 <= 11'h000;
		Cr_0d813 <= 11'h000;
		Cr_1d596 <= 11'h000;
		Cb_2d017 <= 11'h000;
		Cb_0d392 <= 11'h000;
	end
	else
	begin
		Y_1d1640 <= product_0[25:15];
		Cr_0d813 <= product_1[25:15];
		Cr_1d596 <= product_2[25:15];
		Cb_2d017 <= product_3[25:15];
		Cb_0d392 <= product_4[25:15];
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
	else
	begin
		pixel_info_shift_reg[3] <= pixel_info_shift_reg[2];
		pixel_info_shift_reg[2] <= pixel_info_shift_reg[1];
		pixel_info_shift_reg[1] <= pixel_info_in;
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		pixel_en_shift_reg[3] <= 1'b0;
		pixel_en_shift_reg[2] <= 1'b0;
		pixel_en_shift_reg[1] <= 1'b0;
	end
	else
	begin
		pixel_en_shift_reg[3] <= pixel_en_shift_reg[2];
		pixel_en_shift_reg[2] <= pixel_en_shift_reg[1];
		pixel_en_shift_reg[1] <= pixel_en_in;
	end
end

/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/

// Output Assignments

// Internal Assignments
// ---------------------------------------------------------------------------
//
// Sum the proper outputs from the multiply to form R'G'B'
//
assign R_sum = Y_1d1640 + Cr_1d596;
assign G_sum = Y_1d1640 - Cr_0d813 - Cb_0d392;
assign B_sum = Y_1d1640            + Cb_2d017;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


// Formula Set #1
// ---------------------------------------------------------------------------
// R' = 1.164(Y-16) + 1.596(Cr-128)
// G' = 1.164(Y-16) -  .813(Cr-128) -  .392(Cb-128)
// B' = 1.164(Y-16)                 + 2.017(Cb-128)
// 
// use full precision of multiply to experiment with coefficients
// 1.164 -> I[1:0].F[14:0]  .164 X 2^15 = 094FD or 00 1.001 0100 1111 1101 
// 0.813 -> I[1:0].F[14:0]  .813 X 2^15 = 06810 or 00 0.110 1000 0001 0000
// 1.596 -> I[1:0].F[14:0]  .596 X 2^15 = 0CC49 or 00 1.100 1100 0100 1001
// 2.017 -> I[1:0].F[14:0]  .017 X 2^15 = 1022D or 01 0.000 0010 0010 1101
// 0.392 -> I[1:0].F[14:0]  .392 X 2^15 = 0322D or 00 0.011 0010 0010 1101

lpm_mult lpm_mult_component_0 (
	.dataa	({{7{Y_sub[10]}}, Y_sub}),
	.datab	(18'h094FD),
	.result	(product_0),
	.aclr	(1'b0),
	.clken	(1'b1),
	.clock	(1'b0),
	.sum	(1'b0));
defparam
	lpm_mult_component_0.lpm_widtha = 18,
	lpm_mult_component_0.lpm_widthb = 18,
	lpm_mult_component_0.lpm_widthp = 36,
	lpm_mult_component_0.lpm_widths = 1,
	lpm_mult_component_0.lpm_type = "LPM_MULT",
	lpm_mult_component_0.lpm_representation = "SIGNED",
	lpm_mult_component_0.lpm_hint = "INPUT_B_IS_CONSTANT=YES,MAXIMIZE_SPEED=5";


lpm_mult lpm_mult_component_1 (
	.dataa	({{7{Cr_sub[10]}}, Cr_sub}),
	.datab	(18'h06810),
	.result	(product_1),
	.aclr	(1'b0),
	.clken	(1'b1),
	.clock	(1'b0),
	.sum	(1'b0));
defparam
	lpm_mult_component_1.lpm_widtha = 18,
	lpm_mult_component_1.lpm_widthb = 18,
	lpm_mult_component_1.lpm_widthp = 36,
	lpm_mult_component_1.lpm_widths = 1,
	lpm_mult_component_1.lpm_type = "LPM_MULT",
	lpm_mult_component_1.lpm_representation = "SIGNED",
	lpm_mult_component_1.lpm_hint = "INPUT_B_IS_CONSTANT=YES,MAXIMIZE_SPEED=5";


lpm_mult lpm_mult_component_2 (
	.dataa	({{7{Cr_sub[10]}}, Cr_sub}),
	.datab	(18'h0CC49),
	.result	(product_2),
	.aclr	(1'b0),
	.clken	(1'b1),
	.clock	(1'b0),
	.sum	(1'b0));
defparam
	lpm_mult_component_2.lpm_widtha = 18,
	lpm_mult_component_2.lpm_widthb = 18,
	lpm_mult_component_2.lpm_widthp = 36,
	lpm_mult_component_2.lpm_widths = 1,
	lpm_mult_component_2.lpm_type = "LPM_MULT",
	lpm_mult_component_2.lpm_representation = "SIGNED",
	lpm_mult_component_2.lpm_hint = "INPUT_B_IS_CONSTANT=YES,MAXIMIZE_SPEED=5";


lpm_mult lpm_mult_component_3 (
	.dataa	({{7{Cb_sub[10]}}, Cb_sub}),
	.datab	(18'h1022D),
	.result	(product_3),
	.aclr	(1'b0),
	.clken	(1'b1),
	.clock	(1'b0),
	.sum	(1'b0));
defparam
	lpm_mult_component_3.lpm_widtha = 18,
	lpm_mult_component_3.lpm_widthb = 18,
	lpm_mult_component_3.lpm_widthp = 36,
	lpm_mult_component_3.lpm_widths = 1,
	lpm_mult_component_3.lpm_type = "LPM_MULT",
	lpm_mult_component_3.lpm_representation = "SIGNED",
	lpm_mult_component_3.lpm_hint = "INPUT_B_IS_CONSTANT=YES,MAXIMIZE_SPEED=5";


lpm_mult lpm_mult_component_4 (
	.dataa	({{7{Cb_sub[10]}}, Cb_sub}),
	.datab	(18'h0322D),
	.result	(product_4),
	.aclr	(1'b0),
	.clken	(1'b1),
	.clock	(1'b0),
	.sum	(1'b0));
defparam
	lpm_mult_component_4.lpm_widtha = 18,
	lpm_mult_component_4.lpm_widthb = 18,
	lpm_mult_component_4.lpm_widthp = 36,
	lpm_mult_component_4.lpm_widths = 1,
	lpm_mult_component_4.lpm_type = "LPM_MULT",
	lpm_mult_component_4.lpm_representation = "SIGNED",
	lpm_mult_component_4.lpm_hint = "INPUT_B_IS_CONSTANT=YES,MAXIMIZE_SPEED=5";

// Formula Set #2
// ---------------------------------------------------------------------------
// R = Y + 1.402   (Cr-128)
// G = Y - 0.71414 (Cr-128) - 0.34414 (Cb-128) 
// B = Y                    + 1.772   (Cb-128)
// 
// use full precision of multiply to experiment with coefficients
// 1.00000 -> I[0].F[16:0]  1.00000 X 2^15 = 08000  
// 1.40200 -> I[0].F[16:0]  1.40200 X 2^15 = 0B375 
// 0.71414 -> I[0].F[16:0]  0.71414 X 2^15 = 05B69 
// 0.34414 -> I[0].F[16:0]  0.34414 X 2^15 = 02C0D 
// 1.77200 -> I[0].F[16:0]  1.77200 X 2^15 = 0E2D1 

endmodule

