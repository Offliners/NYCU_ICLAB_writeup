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

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input [2:0] W_0, V_GS_0, V_DS_0;
input [2:0] W_1, V_GS_1, V_DS_1;
input [2:0] W_2, V_GS_2, V_DS_2;
input [2:0] W_3, V_GS_3, V_DS_3;
input [2:0] W_4, V_GS_4, V_DS_4;
input [2:0] W_5, V_GS_5, V_DS_5;
input [1:0] mode;
//output [8:0] out_n;         							// use this if using continuous assignment for out_n  // Ex: assign out_n = XXX;
 output reg [9:0] out_n; 								// use this if using procedure assignment for out_n   // Ex: always@(*) begin out_n = XXX; end

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment

wire [7:0] ID0, ID1, ID2, ID3, ID4, ID5;
wire [7:0] GM0, GM1, GM2, GM3, GM4, GM5;

reg [7:0] arr [5:0];

//================================================================
//    DESIGN
//================================================================
// --------------------------------------------------
// write your design here
// --------------------------------------------------

Calculate calc0(.w(W_0), .vgs(V_GS_0), .vds(V_DS_0), .id(ID0), .gm(GM0));
Calculate calc1(.w(W_1), .vgs(V_GS_1), .vds(V_DS_1), .id(ID1), .gm(GM1));
Calculate calc2(.w(W_2), .vgs(V_GS_2), .vds(V_DS_2), .id(ID2), .gm(GM2));
Calculate calc3(.w(W_3), .vgs(V_GS_3), .vds(V_DS_3), .id(ID3), .gm(GM3));
Calculate calc4(.w(W_4), .vgs(V_GS_4), .vds(V_DS_4), .id(ID4), .gm(GM4));
Calculate calc5(.w(W_5), .vgs(V_GS_5), .vds(V_DS_5), .id(ID5), .gm(GM5));

always @ (*) begin
  if(mode == 2'b00 || mode == 2'b10) 
    {arr[5], arr[4], arr[3], arr[2], arr[1], arr[0]} = {ID5, ID4, ID3, ID2, ID1, ID0};
  else
    {arr[5], arr[4], arr[3], arr[2], arr[1], arr[0]} = {GM5, GM4, GM3, GM2, GM1, GM0};
end




endmodule


module Calculate(
  w,
  vgs,
  vds,
  id,
  gm
)

input [2:0] w, vgs, vds;
output [7:0] id, gm;

parameter vt = 3'b001;

wire [2:0] w, vgs, vds;
reg [7:0] id, gm;
wire mode;

assign mode = (vgs - vt > vds) ? 1 : 0; // 1: Triode mode, 0: Saturation mode

always @ (*) begin
  if(mode == 1'b1) begin
    id = 1 / 3'b011 * w * (2 * (vgs - vt) * vds - vds * vds);
    gm = 3'b001 / 3'b011 * w * vds;
  end
  else begin
    id = 1 / 3'b011 * w * (vgs - vt) * (vgs - vt);
    gm = 3'b001 / 3'b011 * w * (vgs - vt);
  end
end

endmodule


module comparator (
  in_0,
	in_1,
	out_0,
	out_1
);

input [2:0] in_0, in_1;
output [2:0] out_0, out_1;

assign out_0 = (in_0 <= in_1) ? in_0 : in_1;
assign out_1 = (in_0 <= in_1) ? in_1 : in_0;
  
endmodule
