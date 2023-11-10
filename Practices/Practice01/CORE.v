module CORE (
	in_n0,
    in_n1,
    opt,
    out_n
);

input [2:0] in_n0, in_n1;
input opt;
output [3:0] out_n;

reg [3:0] in_n1_inv;
reg carry_in;
wire [3:0] tmp;

always @ (*) begin
	if(opt) begin
		in_n1_inv = {1'b1, ~in_n1};
		carry_in = 1'b1;
	end
	else begin
		in_n1_inv = {1'b0,in_n1};
		carry_in = 1'b0;
	end
end

FA FA0 (.a(in_n0[0]),.b(in_n1_inv[0]),.c_in(carry_in),.sum(out_n[0]),.c_out(tmp[0]));
FA FA1 (.a(in_n0[1]),.b(in_n1_inv[1]),.c_in(tmp[0]),.sum(out_n[1]),.c_out(tmp[1]));
FA FA2 (.a(in_n0[2]),.b(in_n1_inv[2]),.c_in(tmp[1]),.sum(out_n[2]),.c_out(tmp[2]));
HA HA3 (.a(tmp[2]),.b(in_n1_inv[3]),.sum(out_n[3]),.c_out(tmp[3]));

endmodule 


module HA(
	a, 
	b, 
	sum, 
	c_out
);
	input wire a, b;
	output wire sum, c_out;
	
	xor (sum, a, b);
	and (c_out, a, b);

endmodule


module FA(
	a, 
	b, 
	c_in, 
	sum, 
	c_out
);
	input   a, b, c_in;
	output  sum, c_out;
	wire   w1, w2, w3;

	HA M1(.a(a), .b(b), .sum(w1), .c_out(w2));
	HA M2(.a(w1), .b(c_in), .sum(sum), .c_out(w3));
	or (c_out, w2, w3);
endmodule