`default_nettype none

module alu_design
#(
	parameter N = 4
)
(
	input wire [N-1:0] OPA,
	input wire [N-1:0] OPB,
	input wire CIN,
	input wire CLK,
	input wire RST,
	input wire CE,
	input wire MODE,
	input wire [1:0] INP_VALID,
	input wire [3:0] CMD,
	output reg [(N+N)-1:0] RES,
	output reg OFLOW,
	output reg COUT,
	output reg G,
	output reg L,
	output reg E,
	output reg ERR
);
	
	always @(posedge CLK or posedge RST) begin
		if(RST) begin
			RES <= 0;
			OFLOW <= 0;
			G <= 0;
			L <= 0;
			E <= 0;
			ERR <= 0;
		end
		else begin
			if(!CE) begin
				RES <= RES;
				OFLOW <= OFLOW;
				G <= G;
				L <= L;
				E <= E;
				ERR <= ERR;
			end
			else begin
				if(MODE == 0) begin
					case(MODE)
						0://unsigned addition
							begin
								if(INP_VALID == 2'b11) begin
									RES <= OPA + OPB;
									OFLOW <= 0;
									COUT <= RES[N];
									{G,L,E} <= (OPA > OPB)? 3'b100: ((OPA < OPB)? 3'b010: 3'b001);
									ERR <= 0;
								end
								else begin
									{RES,G,L,E,OFLOW,COUT} <= 0;
									ERR <= 1'b1;
								end
							end
						1://unsigned subtraction
							begin
								if(INP_VALID == 2'b11) begin
									RES <= OPA - OPB;
									OFLOW <= 0;
									COUT <= ~(OPA < OPB);
									{G,L,E} <= (OPA > OPB)? 3'b100: ((OPA < OPB)? 3'b010: 3'b001);
									ERR <= 0;
								end
								else begin
									{RES,G,L,E,OFLOW,COUT} <= 0;
									ERR <= 1'b1;
								end
							end
						2://addition with carry
							begin
								if(INP_VALID == 2'b11) begin
									RES <= OPA + OPB + CIN;
									OFLOW <= 0;
									COUT <= RES[N];
									{G,L,E} <= (OPA > OPB)? 3'b100: ((OPA < OPB)? 3'b010: 3'b001);
									ERR <= 0;
								end
								else begin
									{RES,G,L,E,OFLOW,COUT} <= 0;
									ERR <= 1'b1;
								end
							end
						3://subtraction with carry
							begin
								if(INP_VALID == 2'b11) begin
									RES <= OPA - OPB - CIN;
									OFLOW <= 0;
									COUT <= ~(OPA < OPB);
									{G,L,E} <= (OPA > OPB)? 3'b100: ((OPA < OPB)? 3'b010: 3'b001);
									ERR <= 0;
								end
								else begin
									{RES,G,L,E,OFLOW,COUT} <= 0;
									ERR <= 1'b1;
								end
							end
						4://increment A
							begin
								if(INP_VALID[1] == 1'b1) begin
									RES <= OPA + 1;
									OFLOW <= 0;
									COUT <= RES[N];
									{G,L,E} <= (OPA > OPB)? 3'b100: ((OPA < OPB)? 3'b010: 3'b001);
									ERR <= 0;
								end
								else begin
									{RES,G,L,E,OFLOW,COUT} <= 0;
									ERR <= 1'b1;
								end
							end
						5://decrement A
							begin
								if(INP_VALID[1] == 1'b1) begin
									RES <= OPA - 1;
									OFLOW <= 0;
									COUT <= ~(OPA == 0);
									{G,L,E} <= (OPA > OPB)? 3'b100: ((OPA < OPB)? 3'b010: 3'b001);
									ERR <= 0;
								end
								else begin
									{RES,G,L,E,OFLOW,COUT} <= 0;
									ERR <= 1'b1;
								end
							end
						6://increment B
							begin
								if(INP_VALID[0] == 1'b1) begin
									RES <= OPB + 1;
									OFLOW <= 0;
									COUT <= RES[N];
									{G,L,E} <= (OPA > OPB)? 3'b100: ((OPA < OPB)? 3'b010: 3'b001);
									ERR <= 0;
								end
								else begin
									{RES,G,L,E,OFLOW,COUT} <= 0;
									ERR <= 1'b1;
								end
							end
						7://decrement B
							begin
								if(INP_VALID[0] == 1'b1) begin
									RES <= OPB - 1;
									OFLOW <= 0;
									COUT <= ~(OPB == 0);
									{G,L,E} <= (OPA > OPB)? 3'b100: ((OPA < OPB)? 3'b010: 3'b001);
									ERR <= 0;
								end
								else begin
									{RES,G,L,E,OFLOW,COUT} <= 0;
									ERR <= 1'b1;
								end
							end
						8://compare A and B
							begin
								if(INP_VALID == 2'b11) begin
									RES <= 0;
									OFLOW <= 0;
									COUT <= 0;
									{G,L,E} <= (OPA > OPB)? 3'b100: ((OPA < OPB)? 3'b010: 3'b001);
									ERR <= 0;
								end
								else begin
									{RES,G,L,E,OFLOW,COUT} <= 0;
									ERR <= 1'b1;
								end
							end
					endcase
				end
			end
		end
	end	
endmodule
