module alu_ref
	#(
		parameter N = 4,
		parameter CMD_N = 4
	)
	(
		input wire [N-1:0] OPA,
		input wire [N-1:0] OPB,
		input wire CIN,
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
	
	always @(*) begin
		if(RST) begin
			RES = 0;
			OFLOW = 0;
			COUT = 0;
			G = 0;
			L = 0;
			E = 0;
			ERR = 0;
		end
		else begin
			if(CE) begin
				{RES, OFLOW, COUT, G, L, E, ERR} = 0;
				if(MODE == 1) begin	
					case(CMD)
						0://unsigned addition
							begin
								if(INP_VALID == 2'b11) begin
									{COUT,RES[N-1:0]} = OPA + OPB;
									RES = OPA + OPB;
								end
								else begin
									ERR = 1'b1;
								end
							end
						1://unsigned subtraction
							begin
								if(INP_VALID == 2'b11) begin
									RES = OPA - OPB;
								end
								else begin
									ERR = 1'b1;
								end
							end
						2://unsigned addition with cin
							begin
								if(INP_VALID == 2'b11) begin
									{COUT,RES[N-1:0]} = OPA + OPB + CIN;
									RES = OPA + OPB + CIN;
								end
								else begin
									ERR = 1'b1;
								end
							end
						3://unsigned subtraction with cin
							begin
								if(INP_VALID == 2'b11) begin
									RES = OPA - OPB - CIN;
								end
								else begin
									ERR = 1'b1;
								end
							end
						4://increment A
							begin
								if(INP_VALID[0] == 1'b1) begin
									RES[N-1:0] = OPA + 1;
								end
								else begin
									ERR = 1'b1;
								end
							end
						5://decrement A
							begin
								if(INP_VALID[0] == 1'b1) begin
									RES = OPA - 1;
								end
								else begin
									ERR = 1'b1;
								end
							end
						6://increment B
							begin
								if(INP_VALID[1] == 1'b1) begin
									RES[N-1:0] = OPB + 1;
								end
								else begin
									ERR = 1'b1;
								end
							end
						7://decrement B
							begin
								if(INP_VALID[1] == 1'b1) begin
									RES = OPB - 1;
								end
								else begin
									ERR = 1'b1;
								end
							end
						8://compare A B
							begin
								if(INP_VALID == 2'b11) begin
									{G, L, E} = {(OPA > OPB), (OPA < OPB), (OPA == OPB)};
								end
								else begin
									ERR = 1'b1;
								end
							end
						9://increment A muliply B
							begin
								if(INP_VALID == 2'b11) begin
									RES = (OPA + 1) * OPB;
								end
								else begin
									ERR = 1'b1;
								end
							end
						10://left shift A muliply B
							begin
								if(INP_VALID == 2'b11) begin
									RES = (OPA << 1) * OPB;
								end
								else begin
									ERR = 1'b1;
								end
							end
						11://signed addition
							begin
								if(INP_VALID == 2'b11) begin
									RES = $signed(OPA) + $signed(OPB);
									OFLOW = (OPA[N-1] == OPB[N-1]);
								end
								else begin
									ERR = 1'b1;
								end
							end
						12://signed subtraction
							begin
								if(INP_VALID == 2'b11) begin
									RES = $signed(OPA) - $signed(OPB);
									OFLOW = (OPA[N-1] == OPB[N-1]);
								end
								else begin
									ERR = 1'b1;
								end
							end
						default: ERR = 1'b1;
					endcase
				end
				else begin
					case(CMD)
						0://and operation
							begin
								if(INP_VALID == 2'b11) begin
									RES = OPA & OPB;
								end
								else begin
									ERR = 1'b1;
								end
							end
						1://nand operation
							begin
								if(INP_VALID == 2'b11) begin
									RES = ~(OPA & OPB);
								end
								else begin
									ERR = 1'b1;
								end
							end
						2://or operation
							begin
								if(INP_VALID == 2'b11) begin
									RES = OPA | OPB;
								end
								else begin
									ERR = 1'b1;
								end
							end
						3://nor operation
							begin
								if(INP_VALID == 2'b11) begin
									RES = ~(OPA | OPB);
								end
								else begin
									ERR = 1'b1;
								end
							end
						4://xor operation
							begin
								if(INP_VALID == 2'b11) begin
									RES = OPA ^ OPB;
								end
								else begin
									ERR = 1'b1;
								end
							end
						5://xnor operation
							begin
								if(INP_VALID == 2'b11) begin
									RES = ~(OPA ^ OPB);
								end
								else begin
									ERR = 1'b1;
								end
							end
						6://not A operation
							begin
								if(INP_VALID[0] == 1'b1) begin
									RES = ~OPA;
								end
								else begin
									ERR = 1'b1;
								end
							end
						7://not B operation
							begin
								if(INP_VALID[1] == 1'b1) begin
									RES = ~OPB;
								end
								else begin
									ERR = 1'b1;
								end
							end
						8://shift right A by 1
							begin
								if(INP_VALID[0] == 1'b1) begin
									RES = OPA >> 1;
								end
								else begin
									ERR = 1'b1;
								end
							end
						9://shift left A by 1
							begin
								if(INP_VALID[0] == 1'b1) begin
									RES = OPA << 1;
								end
								else begin
									ERR = 1'b1;
								end
							end
						10://shift right B by 1
							begin
								if(INP_VALID[1] == 1'b1) begin
									RES = OPB >> 1;
								end
								else begin
									ERR = 1'b1;
								end
							end
						11://shift left B by 1
							begin
								if(INP_VALID[1] == 1'b1) begin
									RES = OPB << 1;
								end
								else begin
									ERR = 1'b1;
								end
							end
						12://rotate left a b
							begin
                if(INP_VALID == 2'b11) begin
                  RES <= (OPA << OPB[clog_n-1:0]) | (OPA >> (N - OPB[clog_n-1:0]));
                  if(|OPB[N-1:clog_n] == 1'b1)begin
                    ERR <= 1;
                  end
                end
                else begin
                  ERR <= 1;
                end
              end
            13://rotate right a b
              begin
                if(INP_VALID == 2'b11) begin
                  RES <= (OPA >> OPB[clog_n-1:0]) | (OPA << (N - OPB[clog_n-1:0]));
                  if(|OPB[N-1:clog_n] == 1'b1)begin
                    ERR <= 1;
                  end
                end
                else begin
                  ERR <= 1;
                end
              end
						default: ERR = 1'b1;
					endcase
				end
			end
		end
	end


endmodule
