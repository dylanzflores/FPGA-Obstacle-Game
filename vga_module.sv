module vga_module(input clk, input jump,
						output [2:0] G, B, R);
						
  logic blank, vgaclk, reset;
  logic [9:0] x = 150, y = 100;
  
  always @(posedge clk) begin
		if(jump) begin
		  y <= y + 150;
		end
		else 
		  y <= y - 150;
  end
 endmodule
//vga (clk, reset, vgaclk, hsync, vsync, sync, blank, R, G, B);  // to video DAC endmodule
