module SMC(
  // Input signals
    mode,
    W_0, V_GS_0, V_DS_0,
    W_1, V_GS_1, V_DS_1,
    W_2, V_GS_2, V_DS_2,
    W_3, V_GS_3, V_DS_3,
    W_4, V_GS_4, V_DS_4,
    W_5, V_GS_5, V_DS_5,   

  // Output signals
    out_n
);

input [2:0] W_0, V_GS_0, V_DS_0;
input [2:0] W_1, V_GS_1, V_DS_1;
input [2:0] W_2, V_GS_2, V_DS_2;
input [2:0] W_3, V_GS_3, V_DS_3;
input [2:0] W_4, V_GS_4, V_DS_4;
input [2:0] W_5, V_GS_5, V_DS_5;
input [1:0] mode;

output reg [9:0] out_n;


wire [7:0] ID0, ID1, ID2, ID3, ID4, ID5;
wire [7:0] GM0, GM1, GM2, GM3, GM4, GM5;

reg [7:0] A, B, C, D, E, F;

wire [7:0] lv0_n0, lv0_n1, lv0_n2, lv0_n3, lv0_n4, lv0_n5;
wire [7:0] lv1_n0, lv1_n1, lv1_n2, lv1_n3, lv1_n4, lv1_n5;
wire [7:0] lv2_n0, lv2_n1, lv2_n2, lv2_n3, lv2_n4, lv2_n5;
wire [7:0] lv3_n0, lv3_n1, lv3_n2, lv3_n3, lv3_n4, lv3_n5;

// n0 >= n1 >= n2 >= n3 >= n4 >= n5
wire [7:0] n0, n1, n2, n3, n4, n5;

Calculate calc0(.w(W_0), .vgs(V_GS_0), .vds(V_DS_0), .id(ID0), .gm(GM0));
Calculate calc1(.w(W_1), .vgs(V_GS_1), .vds(V_DS_1), .id(ID1), .gm(GM1));
Calculate calc2(.w(W_2), .vgs(V_GS_2), .vds(V_DS_2), .id(ID2), .gm(GM2));
Calculate calc3(.w(W_3), .vgs(V_GS_3), .vds(V_DS_3), .id(ID3), .gm(GM3));
Calculate calc4(.w(W_4), .vgs(V_GS_4), .vds(V_DS_4), .id(ID4), .gm(GM4));
Calculate calc5(.w(W_5), .vgs(V_GS_5), .vds(V_DS_5), .id(ID5), .gm(GM5));

always @ (*) begin
  if(mode == 2'b00 || mode == 2'b10)
    {A, B, C, D, E, F} = {GM0, GM1, GM2, GM3, GM4, GM5};
  else
    {A, B, C, D, E, F} = {ID0, ID1, ID2, ID3, ID4, ID5};
end

Comparator cmp1_lv0 (.in_0(A), .in_1(B), .out_small(lv0_n0), .out_big(lv0_n1));
Comparator cmp2_lv0 (.in_0(C), .in_1(D), .out_small(lv0_n2), .out_big(lv0_n3));
Comparator cmp3_lv0 (.in_0(E), .in_1(F), .out_small(lv0_n4), .out_big(lv0_n5));

Comparator cmp4_lv1 (.in_0(lv0_n0), .in_1(lv0_n2), .out_small(lv1_n0), .out_big(lv1_n1));
Comparator cmp5_lv1 (.in_0(lv0_n1), .in_1(lv0_n4), .out_small(lv1_n2), .out_big(lv1_n3));
Comparator cmp6_lv1 (.in_0(lv0_n3), .in_1(lv0_n5), .out_small(lv1_n4), .out_big(lv1_n5));

Comparator cmp7_lv2 (.in_0(lv1_n0), .in_1(lv1_n2), .out_small(lv2_n0), .out_big(lv2_n1));
Comparator cmp8_lv2 (.in_0(lv1_n1), .in_1(lv1_n4), .out_small(lv2_n2), .out_big(lv2_n3));
Comparator cmp9_lv2 (.in_0(lv1_n3), .in_1(lv1_n5), .out_small(lv2_n4), .out_big(lv2_n5));

assign lv3_n0 = lv2_n0;
Comparator cmp10_lv3 (.in_0(lv2_n1), .in_1(lv2_n2), .out_small(lv3_n1), .out_big(lv3_n2));
Comparator cmp11_lv3 (.in_0(lv2_n3), .in_1(lv2_n4), .out_small(lv3_n3), .out_big(lv3_n4));
assign lv3_n5 = lv2_n5;

assign n5 = lv3_n0;
assign n4 = lv3_n1;
Comparator cmp12_lv4 (.in_0(lv3_n2), .in_1(lv3_n3), .out_small(n3), .out_big(n2));
assign n1 = lv3_n4;
assign n0 = lv3_n5;

always @ (*) begin
  case(mode)
    2'b00 : out_n = n3 + n4 + n5;
    2'b01 : out_n = 3'b011 * n3 + 3'b100 * n4 + 3'b101 * n5;
    2'b10 : out_n = n0 + n1 + n2;
    2'b11 : out_n = 3'b011 * n0 + 3'b100 * n1 + 3'b101 * n2;
  endcase
end

endmodule


module Calculate(
  w,
  vgs,
  vds,
  id,
  gm
);

input [2:0] w, vgs, vds;
output [7:0] id, gm;

parameter vt = 3'b001;

wire [2:0] w, vgs, vds;
reg [7:0] id, gm;
wire mode;

assign mode = (vgs - vt > vds) ? 1'b1 : 1'b0; // 1: Triode mode, 0: Saturation mode

always @ (*) begin
  if(mode == 1'b1) begin
    id = w * (3'b010 * (vgs - vt) * vds - vds * vds) / 3'b011;
    gm = 3'b010 * w * vds / 3'b011;
  end
  else begin
    id = w * (vgs - vt) * (vgs - vt) / 3'b011;
    gm = 3'b010 * w * (vgs - vt) / 3'b011;
  end
end

endmodule


module Comparator (
  in_0,
	in_1,
	out_small,
	out_big
);

input [7:0] in_0, in_1;
output [7:0] out_small, out_big;

assign out_small = (in_0 <= in_1) ? in_0 : in_1;
assign out_big = (in_0 <= in_1) ? in_1 : in_0;
  
endmodule