//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory OASIS
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : PATTERN.v
//   Module Name : PATTERN
//   Release version : v1.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`ifdef RTL
	`timescale 1ns/10ps
	`include "KT.v"
	`define CYCLE_TIME 5.0
`endif
`ifdef GATE
	`timescale 1ns/10ps
	`include "KT_SYN.v"
	`define CYCLE_TIME 5.0
`endif

module PATTERN(
   clk,
   rst_n,
   in_valid,
   in_x,
   in_y,
   move_num,
   priority_num,
   out_valid,
   out_x,
   out_y,
   move_out
     
);

output reg clk,rst_n,in_valid;
output reg [4:0] move_num;
output reg [2:0] in_x,in_y,priority_num;
input out_valid;
input [4:0] move_out;
input [2:0] out_x,out_y;

//================================================================
// wires & registers
//================================================================

reg [2:0] golden_x,golden_y;
reg [4:0] golden_step;

reg [2:0] prio_temp;
reg [4:0] step_temp;

//================================================================
// parameters & integer
//================================================================

integer total_cycles;
integer patcount;
integer cycles;
integer a, b, c, i, k, input_file,output_file;
integer gap;

parameter PATNUM=104;
//================================================================
// clock
//================================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;
//================================================================
// initial
//================================================================
initial begin
	rst_n    = 1'b1;
	in_valid = 1'b0;
	in_x     =  'dx;
	in_y     =  'dx;
	move_num =  'dx;
	
	force clk = 0;
	total_cycles = 0;
	reset_task;
	
	input_file=$fopen("../00_TESTBED/input.txt","r");
  	output_file=$fopen("../00_TESTBED/output.txt","r");
    @(negedge clk);

	for (patcount=0;patcount<PATNUM;patcount=patcount+1) begin
		input_data;
		wait_out_valid;
		check_ans;
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m", patcount ,cycles);
	end
	#(1000);
	YOU_PASS_task;
	$finish;
end

task reset_task ; begin
	#(10); rst_n = 0;

	#(10);
	if((out_x !== 0) || (out_y !== 0) || (out_valid !== 0) || (move_out !== 0)) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                  Output signal should be 0 after initial RESET at %8t                                      ",$time);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		
		#(100);
	    $finish ;
	end
	
	#(10); rst_n = 1 ;
	#(3.0); release clk;
end endtask

task input_data ; 
	begin
		gap = $urandom_range(1,5);
		repeat(gap)@(negedge clk);
		in_valid = 'b1;
		a = $fscanf(input_file,"%d %d",move_num,priority_num);
		step_temp = move_num;
		prio_temp = priority_num;
		for(i=0;i<step_temp;i=i+1)begin
			b = $fscanf(input_file,"%d %d",in_x,in_y);
			@(negedge clk);
			if(i ==0) begin
				move_num     = 'bx;
				priority_num = 'bx;
			end
		end
		in_valid     = 'b0;
		move_num     = 'bx;
		priority_num = 'bx;
		in_x         = 'bx;
		in_y         = 'bx;
	end 
endtask

task wait_out_valid ; 
begin
	cycles = 0;
	while(out_valid === 0)begin
		cycles = cycles + 1;
		if(cycles == 10000) begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                                                                                            ");
			$display ("                                                     The execution latency are over 10000 cycles                                              ");
			$display ("                                                                                                                                            ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2)@(negedge clk);
			$finish;
		end
	@(negedge clk);
	end
	total_cycles = total_cycles + cycles;
end 
endtask

task check_ans ; 
begin
	golden_step = 1;
    while(out_valid === 1) begin
		c = $fscanf(output_file,"%d %d",golden_x,golden_y);
		if(	(out_x !== golden_x) || (out_y !== golden_y) || (move_out !== golden_step)) begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                        FAIL!                                                               ");
			$display ("                                                                   Pattern NO.%03d                                                     ", patcount);
			$display ("                                                         \033[0;31mInput step number: %2d \033[m                                       ", step_temp);
			$display ("                                                         \033[0;31mInput priority   : %2d \033[m                                       ", prio_temp);
			$display ("                                                       Your output -> out_x: %d,  out_y: %d,  step: %d                                 ", out_x, out_y,move_out);
			$display ("                                                     Golden output -> out_x: %d,  out_y: %d,  step: %d                                 ", golden_x, golden_y,golden_step);
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			@(negedge clk);
			$finish;
		end
		
		@(negedge clk);
		golden_step=golden_step+1;
    end
	if(golden_step !== 25+1) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                                   Pattern NO.%03d                                                     ", patcount);
		$display ("	                                                   Output cycle should be 25 cycle                                              ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		@(negedge clk);
		$finish;
	end
end 
endtask

task YOU_PASS_task;
	begin
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$display ("                                                  Congratulations!                						            ");
	$display ("                                           You have passed all patterns!          						            ");
	$display ("                                           Your execution cycles = %5d cycles   						            ", total_cycles);
	$display ("                                           Your clock period = %.1f ns        					                ", `CYCLE_TIME);
	$display ("                                           Your total latency = %.1f ns         						            ", total_cycles*`CYCLE_TIME);
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;

	end
endtask

endmodule