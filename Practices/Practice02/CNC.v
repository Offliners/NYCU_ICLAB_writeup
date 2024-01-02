module CNC(
    //Input Port
    clk,
    rst_n,
    IN_VALID,
    MODE,
    IN,

    //Output Port
    OUT_VALID,
    OUT
);

input           clk, rst_n, IN_VALID;
input   [ 1:0]  MODE;
input   [ 7:0]  IN;
output          OUT_VALID;
output  [16:0]  OUT;

parameter s_idle = 3'd0; 
parameter s_input = 3'd1;
parameter s_add = 3'd2;
parameter s_sub = 3'd3;
parameter s_mul = 3'd4;
parameter s_output = 3'd6; 

reg        OUT_VALID;
reg [16:0] OUT;

reg [2:0] current_state, next_state;
reg [1:0] cnt;

reg [1:0] MODE_r;
reg signed  [7:0] A, B, C, D;
reg signed [16:0] E, F;

wire       [16:0] ACC_OUT;
reg signed  [8:0] ACC_A, ACC_B;
reg signed [15:0] ACC_C;

always @ (posedge clk) begin
    if(!rst_n)
        current_state <= s_idle;
    else
        current_state <= next_state;
end

always @ (*) begin
    case(current_state)
		s_idle: if(IN_VALID) next_state = s_input;
				else         next_state = s_idle;
		s_input: if(cnt==2'd2)
					 case(MODE_r)
					 2'd0: next_state = s_add;
					 2'd1: next_state = s_sub;
					 2'd2: next_state = s_mul;
					 default: next_state = s_input;
					 endcase
				 else
					 next_state = s_input;
		s_add:   if(cnt==2'd1) next_state = s_output;
				 else next_state = s_add;
		s_sub:   if(cnt==2'd1) next_state = s_output;
				 else next_state = s_sub;
		s_mul:   if(cnt==2'd3) next_state = s_output;
				 else next_state = s_mul;
		s_output: if(cnt==2'd1) next_state = s_idle;
				 else next_state = s_output; 
		default: next_state = current_state;
    endcase
end

always @ (posedge clk) begin
    if(!rst_n)
        cnt <= 2'b0;
    else
		case(current_state)
			s_idle: cnt <= 2'b0;
			s_input: if(cnt==2'd2) cnt <= 2'b0;
					 else cnt <= cnt+1'b1;
			s_add:   if(cnt==2'd1) cnt <= 2'b0;
					 else cnt <= cnt+1'b1;
			s_sub:   if(cnt==2'd1) cnt <= 2'b0;
					 else cnt <= cnt+1'b1;
			s_mul:   if(cnt==2'd3) cnt <= 2'b0;
					 else cnt <= cnt+1'b1;
			s_output: if(cnt==2'd1) cnt <= 2'b0;
					 else cnt <= cnt+1'b1;
			default: cnt <= cnt;
		endcase
end

always @ (posedge clk) begin
    if(!rst_n)
        MODE_r <= 2'b0;
    else
		case(current_state)
			s_idle: if(IN_VALID) MODE_r <= MODE;
			default: MODE_r <= MODE_r;
		endcase
end

always @ (posedge clk) begin
    if(!rst_n)
        A <= 8'b0;
    else
		case(current_state)
			s_input: if(IN_VALID) A <= B;
			default: A <= A;
		endcase
end

always @ (posedge clk) begin
    if(!rst_n)
        B <= 8'b0;
    else
		case(current_state)
			s_input: if(IN_VALID) B <= C;
			default: B <= B;
		endcase
end

always @ (posedge clk) begin
    if(!rst_n)
        C <= 8'b0;
    else
		case(current_state)
			s_input: if(IN_VALID) C <= D;
			default: C <= C;
		endcase
end

always @ (posedge clk) begin
    if(!rst_n)
        D <= 8'b0;
    else
		case(current_state)
			s_idle: if(IN_VALID) D <= IN;
			s_input: if(IN_VALID) D <= IN;
			default: D <= D;
		endcase
end

assign ACC_OUT = ACC_C + ACC_A * ACC_B;

always @ (*) begin
    case(current_state)
		s_add: if(cnt==2'b0) ACC_C = A; else ACC_C = B;
		s_sub: if(cnt==2'b0) ACC_C = A; else ACC_C = B;
		s_mul:begin 
			if(cnt==2'b0) ACC_C = 0;
		       else if(cnt==2'b1)  ACC_C = E;
               else if(cnt==2'd2)  ACC_C = 0;
               else ACC_C = F;
		end
		default: ACC_C = 8'b0;
    endcase
end

always @ (*) begin
    case(current_state)
		s_add: if(cnt==2'b0) ACC_A = C; else ACC_A = D;
		s_sub: if(cnt==2'b0) ACC_A = C; else ACC_A = D;
		s_mul: begin
			if(cnt==2'b0) ACC_A = A;
			else if(cnt==2'b1)  ACC_A = B;
            else if(cnt==2'd2)  ACC_A = A;
            else  ACC_A = B;
		end
		default: ACC_A = 8'b0;
    endcase
end

always @ (*) begin
    case(current_state)
		s_add: ACC_B = 8'b1;
		s_sub: ACC_B = -1;
		s_mul: if(cnt==2'b0) ACC_B = C;
		       else if(cnt==2'b1)  ACC_B = -D;
               else if(cnt==2'd2)  ACC_B = D;
               else ACC_B = C;

		default: ACC_B = 8'b0;
    endcase
end

always @ (posedge clk) begin
    if(!rst_n)
        E <= 17'b0;
    else
    case(current_state)
		s_add: if(cnt==2'b0) E <= ACC_OUT; else E <= E;
		s_sub: if(cnt==2'b0) E <= ACC_OUT; else E <= E;
		s_mul: begin
			if(cnt==2'd0 || cnt==2'd1) E <= ACC_OUT;  
			else E <= E;
		end
		default: E <= E;
    endcase
end

always @ (posedge clk) begin
    if(!rst_n)
        F <= 17'b0;
    else
    case(current_state)
		s_add: if(cnt==2'b1) F <= ACC_OUT; else F <= F;
		s_sub: if(cnt==2'b1) F <= ACC_OUT; else F <= F;
		s_mul: begin
			if(cnt==2'd2 || cnt==2'd3) F <= ACC_OUT;  
			else F <= F;
		end
		default: F <= F;
    endcase
end

always @ (posedge clk) begin
    if(!rst_n)
        OUT_VALID <= 1'b0;
    else
		case(current_state)
		s_output: OUT_VALID <= 1'b1;
		default: OUT_VALID <= 1'b0;
		endcase
end

always @ (posedge clk) begin
    if(!rst_n)
        OUT <= 17'b0;
    else
		case(current_state)
		s_output: if(cnt==2'b00) OUT <= E; else OUT <= F;
		default: OUT <= 17'b0;
		endcase
end

endmodule
