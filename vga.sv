	module vga(input  logic clk, game_clk, reset, playerWon, menuScreen,
				  input logic  shapes[30:0],
				  input  logic [9:0] distance, obj_counter,
				  output logic hits, readCol[3:0],
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
	videoGen videoGen1(x, y, vgaclk, distance, obj_counter, reset, game_clk, playerWon, menuScreen, shapes, r, g, b, hits, readCol[3:0]); 

endmodule 

// Module detecting whenever the player hits an obstacle that triggers a death
	module collisions_tri(input logic state,
								 input logic [9:0] player_left, player_top, player_right, player_bot, 
								 input logic [9:0] hit_left, hit_top, hit_right, hit_bot,
								 output logic hit);
	  always_comb begin
			if( (state == 1) && (player_left >= hit_left && player_right <= hit_right && player_top <= hit_top && player_bot >= hit_bot) ) hit = 1;
			else hit = 0; // hit not triggered*/
	  end
	endmodule
	
	
	module videoGen(input  logic [9:0] x, y, clk, distance, obj_position_counter,
						input  logic reset, game_clk, playerWon, menuScreen,
						input logic shapes [30:0],
						output logic [7:0] r, g, b,
						output logic hits,
						output logic readCol[3:0]); 
	parameter spawn_loc = 680;
	parameter base_lvl = 360;
	
  logic obs[10:0], collisions[10:0], hitBox[10:0]; 	
  logic menu, player, ground, mb1;
  logic [9:0] player_left_loc, player_top_loc, player_right_loc, player_bottom_loc;
  logic [9:0] obs_top[10:0], obs_left[10:0];
  logic [9:0] hitBox_left[10:0], hitBox_right[10:0], hitBox_top[10:0], hitBox_bot[10:0];
  
  logic y1, y2, y3;
  assign player_left_loc = 10'd220;
  assign player_right_loc = 10'd250;
  assign player_top_loc = base_lvl - distance;
  assign player_bottom_loc = 10'd400 - distance;
  generateMenuScreen m(x, y, obj_position_counter, menu); // menu screen
  sqGen mainSq(x, y, player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, player); // main player square character
  sqGen ground1(x, y, 10'd20, 10'd400, 10'd700, 10'd500, ground); // level for player
  
  hitBoxGen h(x, y, obj_position_counter, shapes[0], hitBox_left[0], hitBox_top[0], hitBox_right[0], hitBox_bot[0], hitBox[0]); 
  hitBoxGen h1(x, y, obj_position_counter - 120, shapes[0], hitBox_left[1], hitBox_top[1], hitBox_right[1], hitBox_bot[1], hitBox[1]); 
  hitBoxGen h2(x, y, obj_position_counter - 120, shapes[1], hitBox_left[2], hitBox_top[2], hitBox_right[2], hitBox_bot[2], hitBox[2]); 
  hitBoxGen h3(x, y, obj_position_counter, shapes[2], hitBox_left[3], hitBox_top[3], hitBox_right[3], hitBox_bot[3], hitBox[3]); 

  triangle_generate o1(x, y, obj_position_counter, shapes[0], obs[0], obs_left[0], obs_top[0]); 
  triangle_generate o2(x, y, obj_position_counter - 120, shapes[0], obs[1], obs_left[1], obs_top[1]); 
  triangle_generate o3(x, y, obj_position_counter - 120, shapes[1], obs[2], obs_left[2], obs_top[2]); 
  triangle_generate o4(x, y, obj_position_counter, shapes[2], obs[3], obs_left[3], obs_top[3]); 

  collisions_tri c1(shapes[0], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
						  hitBox_left[0], hitBox_top[0], hitBox_right[0], hitBox_bot[0], collisions[0]);
  collisions_tri c2(shapes[0], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc,
						  hitBox_left[1], hitBox_top[1], hitBox_right[1], hitBox_bot[1], collisions[1]);
  collisions_tri c3(shapes[1], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
						  hitBox_left[2], hitBox_top[2], hitBox_right[2], hitBox_bot[2], collisions[2]);
  collisions_tri c4(shapes[2], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
						  hitBox_left[3], hitBox_top[3], hitBox_right[3], hitBox_bot[3], collisions[3]);
  /*collisions_tri c4(player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
						  hitBox_left[3], hitBox_top[3], hitBox_right[3], hitBox_bot[3], collisions[3]);
	*/				

  assign hits = collisions[0] | collisions[1] | collisions[2] | collisions[3];
  
  movingBackground b1(x, y, 10'd850, base_lvl, spawn_loc, 10'd400, game_clk, reset, mb1);
    
  // Display shapes
  display_to_vga_screen ngng(clk, reset, menu, menuScreen, playerWon, collisions[2], player, ground, mb1, obs[10:0], r, g, b);

endmodule

// Hitbox Generator for spikes
module hitBoxGen #(parameter spawn_loc = 680, parameter hitBox_spawn_base_lvl = 375) 
					  (input  logic [9:0] x, y, c,
						input logic make,
						output logic [9:0] left, top, right, bot,
						output logic shape);
						
  assign left = spawn_loc - c;
  assign right = spawn_loc + 30 - c;
  assign bot = hitBox_spawn_base_lvl;
  assign top = hitBox_spawn_base_lvl + 30;
  assign shape = make ? (x > (left) & x < (right) &  y > (bot) & y < (top) ) : 0; 
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
	else if(playerLost == 1) begin
		r_red = 8'hFF;
		r_green = 8'h00;
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
			r_red = 8'hDF;
			r_green = 8'h00;
			r_blue = 8'h00;
		end
		else if(obs[1]) begin // obstacle 2
			r_red = 8'h0F;
			r_green = 8'hFF;
			r_blue = 8'h40;
		end
		else if(obs[2]) begin
			r_red = 8'h0A;
			r_green = 8'h13;
			r_blue = 8'h81;
		end
		else if(obs[3]) begin
			r_red = 8'hFF;
			r_green = 8'h00;
			r_blue = 8'h43;
		end
		else if(ground) begin
			r_red = 8'h00;
			r_green = 8'h00;
			r_blue = 8'h00;
		end
	end
  end
  									  
										  
endmodule										  
module triangle_generate #(parameter spawn_loc = 680, parameter triangle_spawn_base_lvl = 375)
									(input  logic [9:0] x, y, movingPosition, 
									 input  logic 		  make_triangle,
									 output logic       triangle,
									 output logic [9:0] obstacle_pos_left, obstacle_pos_top); 
									 
		logic [750:0] triROM[750:0]; // character generator ROM 
		logic [750:0] ROMline;            // a line read from the ROM 
		
		// initialize ROM with characters from text file 
		initial $readmemb("triangle.txt", triROM); 
		// index into ROM 
		assign obstacle_pos_left = x + movingPosition - spawn_loc;
		assign obstacle_pos_top = y - triangle_spawn_base_lvl;
		// Generate triangle
		assign ROMline = triROM[obstacle_pos_top];  
		assign triangle = make_triangle ? ROMline[obstacle_pos_left] : 0; 
	
	endmodule 
	
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

// Generate Menu Screen logic
module generateMenuScreen(input  logic [9:0] x, y, movingPosition,
								 output logic       menu);
  logic [1024:0] menuROM[1023:0]; // character generator ROM 
  logic [1023:0] ROMline;            // a line read from the ROM 
  
  // initialize ROM with characters from text file 
  initial $readmemb("menuText.txt", menuROM); 
  // index into ROM 
  assign ROMline = menuROM[y - 200];  
  assign menu = ROMline[10'd1024 - x - 200]; 
  
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
