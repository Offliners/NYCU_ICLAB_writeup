module KT(
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

input clk,rst_n;
input in_valid;
input [2:0] in_x,in_y;
input [4:0] move_num;
input [2:0] priority_num;

output reg out_valid;
output reg [2:0] out_x,out_y;
output reg [4:0] move_out;

//***************************************************//
//Finite State Machine example
//***************************************************//

//FSM current state assignment
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		state <= RESET;
	end
	else begin
		state <= n_state;
	end
end

//FSM next state assignment
always@(*) begin
	case(state)
		
		RESET: begin
			n_state = 
		end
		
		
		default: begin
			n_state = 
		end
	
	endcase
end 

//Output assignment
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		
	end
	else if( ) begin
		
	end
	else begin
		
	end
end

endmodule
