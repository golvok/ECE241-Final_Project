//altsyncram CBX_SINGLE_OUTPUT_FILE="ON" CLOCK_ENABLE_INPUT_A="BYPASS" CLOCK_ENABLE_OUTPUT_A="BYPASS" INIT_FILE="UNUSED" INTENDED_DEVICE_FAMILY=""Cyclone II"" NUMWORDS_A=256 OPERATION_MODE="ROM" OUTDATA_ACLR_A="NONE" OUTDATA_REG_A="CLOCK0" WIDTH_A=0 WIDTH_B=1 WIDTH_BYTEENA_A=1 WIDTH_BYTEENA_B=1 WIDTH_ECCSTATUS=3 WIDTHAD_A=8 WIDTHAD_B=1 address_a clock0 q_a
//VERSION_BEGIN 13.0 cbx_mgl 2013:06:12:18:33:59:SJ cbx_stratixii 2013:06:12:18:03:33:SJ cbx_util_mgl 2013:06:12:18:03:33:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 1991-2013 Altera Corporation
//  Your use of Altera Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Altera Program License 
//  Subscription Agreement, Altera MegaCore Function License 
//  Agreement, or other applicable license agreement, including, 
//  without limitation, that your use is for the sole purpose of 
//  programming logic devices manufactured by Altera and sold by 
//  Altera or its authorized distributors.  Please refer to the 
//  applicable agreement for further details.



//synthesis_resources = altsyncram 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  mgcn01
	( 
	address_a,
	clock0,
	q_a) /* synthesis synthesis_clearbox=1 */;
	input   [7:0]  address_a;
	input   clock0;
	output   q_a;

	wire  wire_mgl_prim1_q_a;

	altsyncram   mgl_prim1
	( 
	.address_a(address_a),
	.clock0(clock0),
	.q_a(wire_mgl_prim1_q_a));
	defparam
		mgl_prim1.clock_enable_input_a = "BYPASS",
		mgl_prim1.clock_enable_output_a = "BYPASS",
		mgl_prim1.intended_device_family = ""Cyclone II"",
		mgl_prim1.numwords_a = 256,
		mgl_prim1.operation_mode = "ROM",
		mgl_prim1.outdata_aclr_a = "NONE",
		mgl_prim1.outdata_reg_a = "CLOCK0",
		mgl_prim1.width_a = 0,
		mgl_prim1.width_b = 1,
		mgl_prim1.width_byteena_a = 1,
		mgl_prim1.width_byteena_b = 1,
		mgl_prim1.width_eccstatus = 3,
		mgl_prim1.widthad_a = 8,
		mgl_prim1.widthad_b = 1;
	assign
		q_a = wire_mgl_prim1_q_a;
endmodule //mgcn01
//VALID FILE
