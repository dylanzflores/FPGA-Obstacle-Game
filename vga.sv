	`define max_obs 20;
	module vga(input  logic clk, game_clk, reset, playerWon, menuScreen,
				  input logic  shapes[19:0],
				  input  logic [9:0] distance, obj_counter,
				  output logic hits,
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
	videoGen videoGen1(x, y, vgaclk, distance, obj_counter, reset, game_clk, playerWon, menuScreen, shapes, r, g, b, hits); 

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
						input logic shapes [19:0],
						output logic [7:0] r, g, b,
						output logic hits); 
	parameter spawn_loc = 680;
	parameter base_lvl = 360;
	//logic [9:0] platforms_left[10:0], platforms_right[10:0], platforms_top[10:0], platforms_bot[10:0];
  //logic [9:0] player_move_bot, player_move_top;
 // assign player_move_bot = platforms_check_col[0] ? platforms_top[0] : 10'd400; 
  //assign player_move_top = platforms_check_col[0] ? base_lvl - 40  - distance: base_lvl - distance;
   /*platform p1(x, y, obj_position_counter, shapes[1], platforms_left[0], platforms_top[0], platforms_right[0], platforms_bot[0], platforms[0]);
   platform_ontop po1(shapes[1], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
	platforms_left[0], platforms_top[0], platforms_right[0], platforms_bot[0], platforms_check_col[0]);	
*/
  logic obs[30:0], collisions[30:0], platforms_check_col[30:0], platforms[30:0]; 	
  logic menu, player, ground;
  logic [9:0] player_left_loc, player_top_loc, player_right_loc, player_bottom_loc;
  logic [9:0] obs_top[30:0], obs_left[30:0];
  logic [9:0] hitBox_left[30:0], hitBox_right[30:0], hitBox_top[30:0], hitBox_bot[30:0];
  assign player_left_loc = 10'd220;
  assign player_right_loc = 10'd250;
  assign player_top_loc = base_lvl - distance;
  assign player_bottom_loc = 10'd400 - distance;

  generateMenuScreen m(x, y, obj_position_counter, menu); // menu screen
  sqGen mainSq(x, y, player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, player); // main player square character
  sqGen ground1(x, y, 10'd0, 10'd400, 10'd700, 10'd405, ground); // level for player
  // S0
  hitBoxGen h(x, y, obj_position_counter, shapes[0], hitBox_left[0], hitBox_top[0], hitBox_right[0], hitBox_bot[0]); 
  hitBoxGen h12(x, y, obj_position_counter - 30, shapes[0], hitBox_left[1], hitBox_top[1], hitBox_right[1], hitBox_bot[1]); 
  hitBoxGen h13(x, y, obj_position_counter - 150, shapes[0], hitBox_left[2], hitBox_top[2], hitBox_right[2], hitBox_bot[2]); 
  // S1
  hitBoxGen h2(x, y, obj_position_counter - 120, shapes[1], hitBox_left[3], hitBox_top[3], hitBox_right[3], hitBox_bot[3]);
  // S2
  hitBoxGen h3(x, y, obj_position_counter, shapes[2], hitBox_left[4], hitBox_top[4], hitBox_right[4], hitBox_bot[4]); 
  // S3
  hitBoxGen h40(x, y, obj_position_counter, shapes[3], hitBox_left[5], hitBox_top[5], hitBox_right[5], hitBox_bot[5]); 
  hitBoxGen h41(x, y, obj_position_counter - 30, shapes[3], hitBox_left[6], hitBox_top[6], hitBox_right[6], hitBox_bot[6]); 
  hitBoxGen h42(x, y, obj_position_counter - 60, shapes[3], hitBox_left[7], hitBox_top[7], hitBox_right[7], hitBox_bot[7]); 
  hitBoxGen h43(x, y, obj_position_counter - 150, shapes[3], hitBox_left[8], hitBox_top[8], hitBox_right[8], hitBox_bot[8]); 
  // S4
  hitBoxGen h50(x, y, obj_position_counter, shapes[4], hitBox_left[9], hitBox_top[9], hitBox_right[9], hitBox_bot[9]); 
  hitBoxGen h51(x, y, obj_position_counter - 60, shapes[4], hitBox_left[10], hitBox_top[10], hitBox_right[10], hitBox_bot[10]); 
  hitBoxGen h52(x, y, obj_position_counter - 80, shapes[4], hitBox_left[11], hitBox_top[11], hitBox_right[11], hitBox_bot[11]); 

  hitBoxGen h60(x, y, obj_position_counter, shapes[5], hitBox_left[12], hitBox_top[12], hitBox_right[12], hitBox_bot[12]); 
  hitBoxGen h61(x, y, obj_position_counter - 76, shapes[5], hitBox_left[13], hitBox_top[13], hitBox_right[13], hitBox_bot[13]); 
  hitBoxGen h62(x, y, obj_position_counter - 91, shapes[5], hitBox_left[14], hitBox_top[14], hitBox_right[14], hitBox_bot[14]); 

  // ************************************************************************************************************************//
  triangle_generate o1(x, y, obj_position_counter, shapes[0], obs[0], obs_left[0], obs_top[0]); 
  triangle_generate o12(x, y, obj_position_counter - 30, shapes[0], obs[1], obs_left[1], obs_top[1]); 
  triangle_generate o13(x, y, obj_position_counter - 150, shapes[0], obs[2], obs_left[2], obs_top[2]); 
  
  triangle_generate o23(x, y, obj_position_counter - 120, shapes[1], obs[3], obs_left[3], obs_top[3]); 
  
  triangle_generate o2(x, y, obj_position_counter, shapes[2], obs[4], obs_left[4], obs_top[4]); 
  
  triangle_generate o3(x, y, obj_position_counter, shapes[3], obs[5], obs_left[5], obs_top[5]); 
  triangle_generate o33(x, y, obj_position_counter - 30, shapes[3], obs[6], obs_left[6], obs_top[6]); 
  triangle_generate o333(x, y, obj_position_counter - 60, shapes[3], obs[7], obs_left[7], obs_top[7]); 
  triangle_generate o3333(x, y, obj_position_counter - 150, shapes[3], obs[8], obs_left[8], obs_top[8]); 

  triangle_generate o41(x, y, obj_position_counter, shapes[4], obs[9], obs_left[9], obs_top[9]); 
  triangle_generate o42(x, y, obj_position_counter - 60, shapes[4], obs[10], obs_left[10], obs_top[10]); 
  triangle_generate o43(x, y, obj_position_counter - 80, shapes[4], obs[11], obs_left[11], obs_top[11]); 

  triangle_generate o51(x, y, obj_position_counter, shapes[5], obs[12], obs_left[12], obs_top[12]); 
  triangle_generate o52(x, y, obj_position_counter - 76, shapes[5], obs[13], obs_left[13], obs_top[13]); 
  triangle_generate o53(x, y, obj_position_counter - 91, shapes[5], obs[14], obs_left[14], obs_top[14]); 
  // ************************************************************************************************************************//
  collisions_tri c1(shapes[0], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
						  hitBox_left[0], hitBox_top[0], hitBox_right[0], hitBox_bot[0], collisions[0]);
  collisions_tri c2(shapes[0], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc,
						  hitBox_left[1], hitBox_top[1], hitBox_right[1], hitBox_bot[1], collisions[1]);
  collisions_tri c3(shapes[0], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
						  hitBox_left[2], hitBox_top[2], hitBox_right[2], hitBox_bot[2], collisions[2]);	
						  
  collisions_tri c4(shapes[1], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
						  hitBox_left[3], hitBox_top[3], hitBox_right[3], hitBox_bot[3], collisions[3]);
						  
  collisions_tri c5(shapes[2], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
					  hitBox_left[4], hitBox_top[4], hitBox_right[4], hitBox_bot[4], collisions[4]);
					  
  collisions_tri c6(shapes[3], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
					  hitBox_left[5], hitBox_top[5], hitBox_right[5], hitBox_bot[5], collisions[5]);				 
  collisions_tri c7(shapes[3], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
					  hitBox_left[6], hitBox_top[6], hitBox_right[6], hitBox_bot[6], collisions[6]);				 
  collisions_tri c8(shapes[3], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
					  hitBox_left[7], hitBox_top[7], hitBox_right[7], hitBox_bot[7], collisions[7]);				 
  collisions_tri c9(shapes[3], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
					  hitBox_left[8], hitBox_top[8], hitBox_right[8], hitBox_bot[8], collisions[8]);	
	
  collisions_tri c10(shapes[4], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
					  hitBox_left[9], hitBox_top[9], hitBox_right[9], hitBox_bot[9], collisions[9]);
  collisions_tri c11(shapes[4], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
					  hitBox_left[10], hitBox_top[10], hitBox_right[10], hitBox_bot[10], collisions[10]);
  collisions_tri c12(shapes[4], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
					  hitBox_left[11], hitBox_top[11], hitBox_right[11], hitBox_bot[11], collisions[11]);
					  
  collisions_tri c13(shapes[5], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
					  hitBox_left[12], hitBox_top[12], hitBox_right[12], hitBox_bot[12], collisions[12]);
  collisions_tri c14(shapes[5], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
					  hitBox_left[13], hitBox_top[13], hitBox_right[13], hitBox_bot[13], collisions[13]);
  collisions_tri c15(shapes[5], player_left_loc, player_top_loc, player_right_loc, player_bottom_loc, 
					  hitBox_left[14], hitBox_top[14], hitBox_right[14], hitBox_bot[14], collisions[14]);				  
  // ************************************************************************************************************************//				  
  assign hits = (collisions[0]| collisions[1] | collisions[2] | collisions[3] | collisions[4] | collisions[5] | collisions[6] | collisions[7] |
  collisions[8] | collisions[9] | collisions[10] | collisions[11] | collisions[12] | collisions[13] | collisions[14] | collisions[15] | collisions[16]
  | collisions[17] | collisions[18] | collisions[19] | collisions[20]);
    
  // Display shapes
  display_to_vga_screen ngng(clk, reset, menu, menuScreen, playerWon, hits, player, ground, obs[30:0], platforms[30:0], r, g, b);

endmodule

module platform_ontop(input logic state,
								 input logic [9:0] player_left, player_top, player_right, player_bot, 
								 input logic [9:0] hit_left, hit_top, hit_right, hit_bot,
								 output logic hit);
  always_comb begin
  	if( (state == 1) && (player_left >= hit_left && player_right <= hit_right && player_top <= hit_top && player_bot >= hit_bot) ) hit = 1;
	 else hit = 0;
  end

endmodule
module platform #(parameter spawn_loc = 680, parameter hitBox_spawn_base_lvl = 320) 
					  (input  logic [9:0] x, y, count,
						input logic make,
						output logic [9:0] left, top, right, bot,
						output logic shape);
						
  assign left = spawn_loc - count;
  assign right = spawn_loc + 200 - count;
  assign bot = hitBox_spawn_base_lvl;
  assign top = hitBox_spawn_base_lvl + 25;
  
  assign shape = make ? (x > (left) & x < (right) &  y > (bot) & y < (top) ) : 0; 
endmodule 
// Hitbox Generator for spikes
module hitBoxGen #(parameter spawn_loc = 680, parameter hitBox_spawn_base_lvl = 375) 
					  (input  logic [9:0] x, y, count,
						input logic make,
						output logic [9:0] left, top, right, bot,
						output logic shape);
						
  assign left = spawn_loc - count - 25;
  assign right = spawn_loc + 30 - count;
  assign bot = hitBox_spawn_base_lvl;
  assign top = hitBox_spawn_base_lvl + 30;
  assign shape = make ? (x > (left) & x < (right) &  y > (bot) & y < (top) ) : 0; 
endmodule 
	
	
module display_to_vga_screen(input logic clk, reset, 
										  input logic menu, menuScreen, playerWon, playerLost, 
										  input logic player, ground, obs[30:0], platforms[30:0],
										  output logic [7:0] r_red, r_green, r_blue);
  logic display_obstacles;
  assign display_obstacles = obs[0] | obs[1] | obs[2] | obs[3] | obs[4] | obs[5] | obs[6] | obs[7] | obs[8] | obs[9] | obs[10] | obs[11];
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
		r_red = 8'hFF;
		r_green = 8'hFF;
		r_blue = 8'hFF;
	end
	else begin
		if(player & playerLost == 0) begin // player	
				r_red = 8'hFF;
				r_green = 8'h00;
				r_blue = 8'h00;
		end
		else if(!player) begin // background
			r_red = 8'h25;
			r_green = 8'hAA;
			r_blue = 8'hAD;
		end
		else begin // float values of red, green, blue
			r_red = 8'hzz;
			r_green = 8'hzz;
			r_blue = 8'hzz;
		end
		if(display_obstacles) begin // obstacle 1
			r_red = 8'h00;
			r_green = 8'h00;
			r_blue = 8'h00;
		end
		else if(ground) begin
			r_red = 8'hFF;
			r_green = 8'hFF;
			r_blue = 8'hFF;
		end
	end
  end
  									  
										  
endmodule										  
module triangle_generate #(parameter spawn_loc = 680, parameter triangle_spawn_base_lvl = 370)
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
