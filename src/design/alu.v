module alu
	#(
		parameter N = 4,
		parameter CMD_N = 4
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
		input wire [CMD_N-1:0] CMD,
		output reg [(N+N)-1:0] RES,
		output reg OFLOW,
		output reg COUT,
		output reg G,
		output reg L,
		output reg E,
		output reg ERR
	);
	
	localparam clog_n = $clog2(N);
	
	reg opa;
	reg opb;
	reg [(N+N)-1:0] res;
	reg oflow;
	reg cout;
	reg g;
	reg l;
	reg e;
	reg err;

	//delay registers
	reg [(N+N)-1:0] delay_res;
	reg delay_oflow;
	reg delay_cout;
	reg delay_g;
	reg delay_l;
	reg delay_e;
	reg delay_err;

	//multiply operations variables
	reg count;
	reg [N-1:0] temp_a;
	reg [N-1:0] temp_b;

	always @(posedge CLK or posedge RST) begin
		if(RST) begin
			count <= 0;
			temp_a <= 0;
			temp_b <= 0;
		end
		else if(CMD == 9 || CMD == 10) begin
			count <= count + 1;
		end
		else
			count <= 0;
	end

	always @(posedge CLK or posedge RST) begin
		if(RST) begin
			res <= 0;
			oflow <= 0;
			cout <= 0;
			g <= 0;
			l <= 0;
			e <= 0;
			err <= 0;
		end
		else begin
			if(CE) begin
				res <= delay_res;
				oflow <=  delay_oflow;
				cout <= delay_cout;
				g <= delay_g;
				l <= delay_l;
				e <= delay_e;
				err <= delay_err;
			end
			else begin
				res <= res;
				oflow <= oflow;
				cout <= cout;
				g <= g;
				l <= l;
				e <= e;
				err <= err;
			end
		end
	end

	always @(posedge CLK or posedge RST) begin
		if(RST) begin
			delay_res <= 0;
			delay_oflow <= 0;
			delay_cout <= 0;
			delay_g <= 0;
			delay_l <= 0;
			delay_e <= 0;
			delay_err <= 0;
		end
		else begin
			if(CE) begin
				{delay_res, delay_oflow, delay_cout, delay_g, delay_l, delay_e, delay_err} <= 0;
				if(MODE == 1) begin	
					case(CMD)
						0://unsigned addition
							begin
								if(INP_VALID == 2'b11) begin
									{cout,delay_res[N-1:0]} <= OPA + OPB;
									delay_res <= OPA + OPB;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						1://unsigned subtraction
							begin
								if(INP_VALID == 2'b11) begin
									delay_res <= OPA - OPB;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						2://unsigned addition with cin
							begin
								if(INP_VALID == 2'b11) begin
									{cout,delay_res[N-1:0]} <= OPA + OPB + CIN;
									delay_res <= OPA + OPB + CIN;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						3://unsigned subtraction with cin
							begin
								if(INP_VALID == 2'b11) begin
									delay_res <= OPA - OPB - CIN;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						4://increment A
							begin
								if(INP_VALID[0] == 1'b1) begin
									delay_res[N-1:0] <= OPA + 1;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						5://decrement A
							begin
								if(INP_VALID[0] == 1'b1) begin
									delay_res <= OPA - 1;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						6://increment B
							begin
								if(INP_VALID[1] == 1'b1) begin
									delay_res[N-1:0] <= OPB + 1;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						7://decrement B
							begin
								if(INP_VALID[1] == 1'b1) begin
									delay_res <= OPB - 1;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						8://compare A B
							begin
								if(INP_VALID == 2'b11) begin
									{delay_g, delay_l, delay_e} <= {(OPA > OPB), (OPA < OPB), (OPA == OPB)};
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						9://incr A multiply B
							begin
								if(INP_VALID == 2'b11) begin
									if(count == 0) begin
										delay_res <= 'bx;
										temp_a <= OPA;
										temp_b <= OPB;
									end
									else begin
										delay_res <= (temp_a + 1) * temp_b;
									end
								end
							end
						10://left shift A multiply B
							begin
								if(INP_VALID == 2'b11) begin
									if(count == 0) begin
										delay_res <= 'bx;
										temp_a <= OPA;
										temp_b <= OPB;
									end
									else begin
										delay_res <= (temp_a << 1) * temp_b;
									end
								end
							end
						11://signed addition
							begin
								if(INP_VALID == 2'b11) begin
									delay_res <= $signed(OPA) + $signed(OPB);
									delay_oflow <= OPA[N-1] == OPB[N-1];
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						12://signed addition
							begin
								if(INP_VALID == 2'b11) begin
									delay_res <= $signed(OPA) - $signed(OPB);
									delay_oflow <= OPA[N-1] == OPB[N-1];
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						default: delay_err <= 1'b1;
					endcase
				end
				else begin
					case(CMD)
						0://and operation
							begin
								if(INP_VALID == 2'b11) begin
									delay_res <= OPA & OPB;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						1://nand operation
							begin
								if(INP_VALID == 2'b11) begin
									delay_res <= ~(OPA & OPB);
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						2://or operation
							begin
								if(INP_VALID == 2'b11) begin
									delay_res <= OPA | OPB;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						3://nor operation
							begin
								if(INP_VALID == 2'b11) begin
									delay_res <= ~(OPA | OPB);
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						4://xor operation
							begin
								if(INP_VALID == 2'b11) begin
									delay_res <= OPA ^ OPB;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						5://xnor operation
							begin
								if(INP_VALID == 2'b11) begin
									delay_res <= ~(OPA ^ OPB);
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						6://not A operation
							begin
								if(INP_VALID[0] == 1'b1) begin
									delay_res <= ~OPA;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						7://not B operation
							begin
								if(INP_VALID[1] == 1'b1) begin
									delay_res <= ~OPB;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						8://shift right A by 1
							begin
								if(INP_VALID[0] == 1'b1) begin
									delay_res <= OPA >> 1;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						9://shift left A by 1
							begin
								if(INP_VALID[0] == 1'b1) begin
									delay_res <= OPA << 1;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						10://shift right B by 1
							begin
								if(INP_VALID[1] == 1'b1) begin
									delay_res <= OPB >> 1;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						11://shift left B by 1
							begin
								if(INP_VALID[1] == 1'b1) begin
									delay_res <= OPB << 1;
								end
								else begin
									delay_err <= 1'b1;
								end
							end
						12://rotate left a b
							begin
								if(INP_VALID == 2'b11) begin
									delay_res <= (OPA << OPB[clog_n-1:0]) | (OPA >> (N - OPB[clog_n-1:0]));
									if(|OPB[N-1:clog_n] == 1'b1)begin
										delay_err <= 1;
									end
								end
								else begin
									delay_err <= 1;
								end
							end
						13://rotate right a b
							begin
								if(INP_VALID == 2'b11) begin
									delay_res <= (OPA >> OPB[clog_n-1:0]) | (OPA << (N - OPB[clog_n-1:0]));
									if(|OPB[N-1:clog_n] == 1'b1)begin
										delay_err <= 1;
									end
								end
								else begin
									delay_err <= 1;
								end
							end
						default: delay_err <= 1'b1;
					endcase
				end
			end
			else begin
				delay_res <= delay_res;
				delay_oflow <= delay_oflow;
				delay_cout <= delay_cout;
				delay_g <= delay_g;
				delay_l <= delay_l;
				delay_e <= delay_e;
				delay_err <= delay_err;
			end
		end
	end

	//output assignments
	always @(*) begin
		RES = res;
		OFLOW = oflow;
		COUT = cout;
		G = g;
		L = l;
		E = e;
		ERR = err;
	end

endmodule
