
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory OASIS
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2021 ICLAB fall Course
//   Lab02			: Sequential circuit Knight's Tour
//   Author         : Echin-Wang (echinwang861025@gmail.com)
//
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TESTBED.sv
//   Module Name : TESTBED
//   Release version : v1.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`include "PATTERN.v"

module TESTBED();

wire clk;
wire rst_n;

wire in_valid,out_valid;
wire [4:0] move_num,move_out;
wire [2:0] in_x,in_y,out_x,out_y,priority_num;


KT U_KT(
	.clk(clk),
	.rst_n(rst_n),
	.in_valid(in_valid),
	.in_x(in_x),
	.in_y(in_y),
	.move_num(move_num),
	.priority_num(priority_num),
	.out_valid(out_valid),
	.out_x(out_x),
	.out_y(out_y),
	.move_out(move_out)
);

PATTERN U_PATTERN(
	.clk(clk),
	.rst_n(rst_n),
	.in_valid(in_valid),
	.in_x(in_x),
	.in_y(in_y),
	.move_num(move_num),
	.priority_num(priority_num),
	.out_valid(out_valid),
	.out_x(out_x),
	.out_y(out_y),
	.move_out(move_out)
);

initial begin
	`ifdef RTL
		$fsdbDumpfile("KT.fsdb");
		$fsdbDumpvars(0,"+mda");
		$fsdbDumpvars();
	`endif
	`ifdef GATE
		$sdf_annotate("KT_SYN.sdf",U_KT);
		$fsdbDumpfile("KT_SYN.fsdb");
		$fsdbDumpvars();
	`endif
end

endmodule
