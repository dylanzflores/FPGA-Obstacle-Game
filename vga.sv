	module vga(input  logic clk, game_clk, reset, playerLost, playerWon, menuScreen,
				  input logic  shapes[30:0],
				  input  logic [9:0] distance, obj_counter,
				  output logic win, dead, 
				  output logic vgaclk,          // 25.175 MHz VGA clock 
				  output logic hsync, vsync, 
				  output logic sync_b, blank_b, // to monitor & DAC 
				  output logic [7:0] r, g, b);  // to video DAC 
			  
  logic [9:0] x, y; 
  always_ff @(posedge clk, posedge reset)
    if (reset)
	   vgaclk = 1'b0;
    else
	   vgaclk = ~vgaclk;
		
  // generate monitor timing signals 
  vgaController vgaCont(vgaclk, reset, hsync, vsync, sync_b, blank_b, x, y); 

  // user-defined module to determine pixel color 
	videoGen videoGen1(x, y, vgaclk, distance, obj_counter, reset, game_clk, playerLost, playerWon, menuScreen, shapes, r, g, b, win, dead); 

endmodule 

// Module detecting whenever the player hits an obstacle that triggers a death
	module collisions_tri(input logic [9:0] player_right, player_bot, tria_left, tria_top,
								 output logic hit);
	  parameter delay = 5;
	  always_comb begin
		if( (player_right + delay) == tria_left) hit = 1; // if player hits left side of triangle trigger hit  
		else if(player_bot + delay == tria_top) hit = 1; // else if player hits top of triangle trigger hit
		else hit = 0; // hit not triggered
	  end
	endmodule
	
	module videoGen(input  logic [9:0] x, y, clk, distance, obj_position_counter,
						input  logic reset, game_clk, playerLost, playerWon, menuScreen,
						input logic shapes [30:0],
						output logic [7:0] r, g, b,
						output logic win, dead); 
	parameter spawn_loc = 680;
	parameter base_lvl = 360;
	
  logic obs[10:0], player, ground, mb1; 	
  logic menu, hit;
  //Top Left Top Edge  Top Right Bottom Edg
  logic [9:0] player_right_loc, player_bottom_loc;
  //logic [9:0] obj_position_counter;
  logic [10:0] game_time;
  assign player_right_loc = 10'd250;
  assign player_bottom_loc = 10'd400 - distance;
  generateMenuScreen(x, y, obj_position_counter, menu); // menu screen
  sqGen mainSq(x, y, 10'd220, base_lvl - distance, player_right_loc, player_bottom_loc, player); // main player square character
  triangle_generate o1(x, y, obj_position_counter, obs[0]); 
  triangle_generate o2(x, y, obj_position_counter - 120, obs[1]); 
  movingBackground b1(x, y, 10'd850, base_lvl, spawn_loc, 10'd400, game_clk, reset, mb1);
  sqGen ground1(x, y, 10'd20, 10'd400, 10'd700, 10'd500, ground); // level for player
  
  // Display shapes
  display_to_vga_screen(clk, reset, menu, menuScreen, playerWon, playerLost, player, ground, mb1, obs[10:0], r, g, b);

endmodule

module display_to_vga_screen(input logic clk, reset, 
										  input logic menu, menuScreen, playerWon, playerLost, 
										  input logic player, ground, mb1, obs[10:0],
										  output logic [7:0] r_red, r_green, r_blue);
  always_ff @(posedge clk) begin		
	if(menuScreen == 1) begin
		if(menu) begin
			r_red = 8'h00;
			r_green = 8'h00;
			r_blue = 8'hFF;
		end
		else begin
			r_red = 8'h00;
			r_green = 8'h00;
			r_blue = 8'h00;
		end
	end
	else if(playerWon == 1) begin
		r_red = 8'h00;
		r_green = 8'hFF;
		r_blue = 8'h00;
	end
	else begin
	
	if(player) begin // player
	   r_red = 8'hFF;
		r_green = 8'h00;
		r_blue = 8'h00;
	 end
	 else if(!player) begin // background
		r_red = 8'h72;
		r_green = 8'h09;
		r_blue = 8'hAA;
	 end
	  else begin // float values of red, green, blue
		r_red = 8'hzz;
		r_green = 8'hzz;
		r_blue = 8'hzz;
	 end
	 
	 // Moving background obstacle appears as a challenge
	if(mb1) begin
		r_red = 8'h0A;
		r_green = 8'h13;
		r_blue = 8'h81;
	end
	
	else if(obs[0]) begin // obstacle 1
		r_red = 8'h00;
		r_green = 8'h00;
		r_blue = 8'h00;
	 end
	 else if(obs[1]) begin // obstacle 2
		r_red = 8'hFF;
		r_green = 8'hFF;
		r_blue = 8'hFF;
	 end
	 else if(obs[2]) begin
		r_red = 8'h0A;
		r_green = 8'h13;
		r_blue = 8'h81;
	end
	 else if(ground) begin
		r_red = 8'h00;
		r_green = 8'h00;
		r_blue = 8'h00;
	 end
	end
  end
  									  
										  
endmodule										  
module generateMenuScreen(input  logic [9:0] x, y, movingPosition,
								 output logic       menu);
  logic [1024:0] menuROM[2047:0]; // character generator ROM 
  logic [1023:0] ROMline;            // a line read from the ROM 
  
  // initialize ROM with characters from text file 
  initial $readmemb("menuText.txt", menuROM); 
  // index into ROM 
  assign ROMline = menuROM[y - 200];  
  assign menu = ROMline[10'd1024 - x - 200]; 
  
endmodule
module triangle_generate #(parameter spawn_loc = 360, parameter triangle_spawn_base_lvl = 375)
									(input  logic [9:0] x, y, movingPosition, make_triangle,
									 output logic       triangle,
									 output logic [9:0] obstacle_pos); 
									 
		logic [1024:0] triROM[2047:0]; // character generator ROM 
		logic [1023:0] ROMline;            // a line read from the ROM 
		
		// initialize ROM with characters from text file 
		initial $readmemb("triangle.txt", triROM); 
		// index into ROM 
		assign obstacle_pos = x + movingPosition;
		assign ROMline = triROM[y - triangle_spawn_base_lvl];  
		assign triangle = ROMline[obstacle_pos - spawn_loc]; 
	
	endmodule 
/*// Create a triangle 30 x 30 pixels
module triangle_generate(input  logic [9:0] x, y, movingPosition,
								 output logic       triangle); 
  logic [1024:0] triROM[2047:0]; // character generator ROM 
  logic [1023:0] ROMline;            // a line read from the ROM 
  
  // initialize ROM with characters from text file 
  initial $readmemb("triangle.txt", triROM); 
  // index into ROM 
  assign ROMline = triROM[y - 365];  
  assign triangle = ROMline[x + movingPosition - 680]; 
  
endmodule 
*/
// Moving obstacle logic
module movingBackground(input  logic [9:0] x, y, left, top, right, bot, 
					input logic clk, reset,
               output logic shape);
  logic [9:0] make = 0;
  
  always_ff @(posedge clk, posedge reset) begin
	if(reset) 
		make = 0;
	else if(make >= 10'd450) make <= 0;
	else begin
		make <= make + 1;
	end
  end

	always_comb begin
		if( (x + make) >= left)
			shape = 1;
		else shape = 0;
	end
	

endmodule 

// Square logic
module sqGen(input  logic [9:0] x, y, left, top, right, bot, 
               output logic shape);
  assign shape = (x > left & x < right &  y > top & y < bot); 
endmodule 
	
module vgaController #(parameter HBP     = 10'd48,   // horizontal back porch
                                 HACTIVE = 10'd640,  // number of pixels per line
                                 HFP     = 10'd16,   // horizontal front porch
                                 HSYN    = 10'd96,   // horizontal sync pulse = 96 to move electron gun back to left
                                 HMAX    = HBP + HACTIVE + HFP + HSYN, //48+640+16+96=800: number of horizontal pixels (i.e., clock cycles)
                                 VBP     = 10'd32,   // vertical back porch
                                 VACTIVE = 10'd480,  // number of lines
                                 VFP     = 10'd11,   // vertical front porch
                                 VSYN    = 10'd2,    // vertical sync pulse = 2 to move electron gun back to top
                                 VMAX    = VBP + VACTIVE + VFP  + VSYN) //32+480+11+2=525: number of vertical pixels (i.e., clock cycles)                      

     (input  logic vgaclk, reset,
      output logic hsync, vsync, sync_b, blank_b, 
      output logic [9:0] hcnt, vcnt); 

      // counters for horizontal and vertical positions 
      always @(posedge vgaclk, posedge reset) begin 
        if (reset) begin
          hcnt <= 0;
          vcnt <= 0;
        end
        else  begin
          hcnt++; 
      	   if (hcnt == HMAX) begin 
            hcnt <= 0; 
  	        vcnt++; 
  	        if (vcnt == VMAX) 
  	          vcnt <= 0; 
          end 
        end
      end 
	  
      // compute sync signals (active low)
      assign hsync  = ~( (hcnt >= (HBP + HACTIVE + HFP)) & (hcnt < HMAX) ); 
      assign vsync  = ~( (vcnt >= (VBP + VACTIVE + VFP)) & (vcnt < VMAX) ); 

      // assign sync_b = hsync & vsync; 
      assign sync_b = 1'b0;  // this should be 0 for newer monitors

      // force outputs to black when not writing pixels
      assign blank_b = (hcnt > HBP & hcnt < (HBP + HACTIVE)) & (vcnt > VBP & vcnt < (VBP + VACTIVE)); 
endmodule 
