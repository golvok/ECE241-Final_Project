`define X_WIDTH 8
`define Y_WIDTH 7
`define IMAGE_H 240
`define IMAGE_W 320
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
	inout           I2C_SDAT,
	input [17:0]SW,
	output reg [17:0] LEDR
	);


	wire pixelIn_en;
	wire [4:0] pixelIn_r, pixelIn_b;
	wire [5:0] pixelIn_g;
	wire [2:0] pixelIn_colour = {pixelIn_r[4], pixelIn_g[5], pixelIn_b[4]};
	wire [8:0] pixelIn_x;
	wire [7:0] pixelIn_y;

	reg vga_plot;
	reg [8:0] vga_x;
	reg [7:0] vga_y;

	reg vga_colour;
	wire [2:0] displayChanel;
	assign displayChanel = SW[2:0];

	Video_In vin(
		.CLOCK_50       (CLOCK_50),
		.CLOCK_27       (CLOCK_27),
		.TD_RESET       (TD_RESET),
		.reset          (~KEY[0]),

		.TD_DATA        (TD_DATA),
		.TD_HS          (TD_HS),
		.TD_VS          (TD_VS),

		.waitrequest    (0),

		.x              (pixelIn_x),
		.y              (pixelIn_y),
		.red            (pixelIn_r),
		.green          (pixelIn_g),
		.blue           (pixelIn_b),
		.pixel_en       (pixelIn_en)
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
				// .colour({pixelIn_r[4], pixelIn_g[5], pixelIn_b[4]}),
				.colour(vga_colour),
				// .colour(prev_image_data_out[displayChanel]),
				// .colour(prev_image_data_in[displayChanel]),
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
				.VGA_CLK(VGA_CLK)
	);
			defparam VGA.RESOLUTION = "320x240";
			defparam VGA.MONOCHROME = "TRUE";
			defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;


	reg [2:0]  prev_image_data_in;
	reg [16:0] prev_image_rdaddress;
	reg [16:0] prev_image_wraddress;
	reg        prev_image_wr_en;
	wire [2:0]  prev_image_data_out;

	prev_image_ram prev_image(
		.data(prev_image_data_in),
		.rdaddress(prev_image_rdaddress),
		.rdclock(CLOCK_50),
		.wraddress(prev_image_wraddress),
		.wrclock(CLOCK_50),
		.wren(prev_image_wr_en),
		.q(prev_image_data_out)
	);

	reg	       bdiff_data_in;
	reg	[16:0] bdiff_rdaddress;
	reg	[16:0] bdiff_wraddress;
	reg	       bdiff_wr_en;
	wire       bdiff_data_out;

	bdiff_image bdi(
		.data(bdiff_data_in),
		.rdaddress(bdiff_rdaddress),
		.rdclock(CLOCK_50),
		.wraddress(bdiff_wraddress),
		.wrclock(CLOCK_50),
		.wren(bdiff_wr_en),
		.q(bdiff_data_out)
	);

	reg [3:0] loadLoc; //3 load, 0,1,2 shift, 4 display
	reg [2:0] row_above;
	reg [2:0] row_curr;
	reg [2:0] row_below;

	reg [8:0] bdiff_read_x;
	reg [7:0] bdiff_read_y;

	reg checkColour;
	always @(posedge CLOCK_50)
	begin
		if(loadLoc == 3)
		begin
			if (bdiff_read_x >= `IMAGE_W - 1 && bdiff_read_y >= `IMAGE_H - 1)
			begin
				bdiff_read_y <= 1;
				bdiff_read_x <= 1;
				bdiff_read_x <= bdiff_read_x +1;
			end
			else if(bdiff_read_x >= `IMAGE_W - 1)
			begin
				bdiff_read_x <= 1;
				bdiff_read_y <= bdiff_read_y + 1;
				// LEDR[0] <= !LEDR[0];
			end
			else
			begin
				bdiff_read_x <= bdiff_read_x +1;
			end

			vga_plot <= 0;
			loadLoc <= 4;
			bdiff_rdaddress <= bdiff_read_y*`IMAGE_W + bdiff_read_x;

		end
		else if(loadLoc == 4)
		begin

			vga_plot <= 1;
			vga_x <= bdiff_read_x;
			vga_y <= bdiff_read_y;
			// vga_colour <= bdiff_data_out;
			if(SW[3])
			begin
				vga_colour <= row_curr[1] & row_above[0]
										  & row_above[1]
										  & row_above[2]
										  & row_below[0]
										  & row_below[1]
										  & row_below[2]
										  & row_curr[0]
										  & row_curr[2];
			end
			else
			begin
				vga_colour <= row_curr[1];
			end

			// checkColour <= !checkColour;
			loadLoc <= 0;
		end

		// if(SW[5])LEDR[0] <= 0;
		else
		begin
			vga_plot <= 0;

			if(loadLoc == 0)
			begin
				bdiff_rdaddress <= bdiff_read_y*`IMAGE_W + bdiff_read_x;
				row_curr <= {row_curr[1:0], bdiff_data_out};
				loadLoc <= 1;
			end

			else if(loadLoc == 1)
			begin
				bdiff_rdaddress <= bdiff_rdaddress - `IMAGE_W;
				row_above <= {row_above[1:0], bdiff_data_out};
				loadLoc <= 2;

			end

			else if(loadLoc == 2)
			begin
				bdiff_rdaddress <= bdiff_rdaddress - `IMAGE_W*2;
				loadLoc <= 3;
				row_below <= {row_below[1:0], bdiff_data_out};

			end

		end

	end





	always @(posedge CLOCK_50)
	begin
		prev_image_data_in <= pixelIn_colour;

		prev_image_wraddress <= prev_image_rdaddress;
		prev_image_rdaddress <= pixelIn_y*`IMAGE_W + pixelIn_x;
		bdiff_wraddress <= pixelIn_y*`IMAGE_W + pixelIn_x;
		// prev_image_rdaddress <= pixelIn_y*360 + pixelIn_x;

		if(pixelIn_en)
		begin
			bdiff_wr_en <= 1;
			prev_image_wr_en <=1;
			// vga_x <= pixelIn_x;
			// vga_y <= pixelIn_y;
			if(SW[2])
			begin
				if(prev_image_data_out != pixelIn_colour) begin
					bdiff_data_in <= 1;
				end
				else
				begin
					bdiff_data_in <= 0;
				end
			end
			else
			begin
				bdiff_data_in <= prev_image_data_out[displayChanel];
			end

			// if(newData != 3'b000)
			// begin
			// end
			// else
			// begin
			// 	vga_colour <= 0;
			// end
		end
		else
		begin
			bdiff_wr_en <= 0;
			prev_image_wr_en <= 0;
			// vga_x <= 0;
			// vga_y <= 0;
		end
	end

endmodule
