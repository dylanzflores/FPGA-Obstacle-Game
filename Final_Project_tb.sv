  module Final_Project_tb();				 
	logic clk, reset, pushButton, vga_clk, vga_hs, vga_vs, vga_sync_n, vga_blank_n, cout;
	logic [4:0] GPIO;
	logic [7:0] vga_r, vga_g, vga_b;
	logic [6:0] seg1, seg2;
	
	always begin
	  #5; clk = 0; #5; clk = 1;
	end
	
	initial begin
	  pushButton = 0;
	  reset = 1;
	  #10;
	  reset = 0;
	  #10;
	  pushButton = 1;
	  #5;
	  pushButton = 0;
	  #30;
	end
	// Instantiate project module
    Final_Project dut(clk, reset, ~pushButton, GPIO, vga_clk, vga_hs, vga_vs, vga_sync_n, vga_blank_n, vga_r, vga_g, vga_b, seg1, seg2, cout);

  endmodule
