//`default_nettype none

module alu_tb;
	//local parameters
	localparam N=4;
	localparam CMD_N=4;

	//input signal declerations
	reg [N-1:0] OPA;
	reg [N-1:0] OPB;
	reg CIN;
	reg CLK;
	reg RST;
	reg CE;
	reg MODE;
	reg [1:0] INP_VALID;
	reg [CMD_N-1:0] CMD;

	//dut output signal declerations
	wire [(N+N)-1:0] RES_dut;
	wire COUT_dut;
	wire OFLOW_dut;
	wire G_dut;
	wire L_dut;
	wire E_dut;
	wire ERR_dut;

	//reference module output signal declerations
	wire [(N+N)-1:0] RES_ref;
	wire COUT_ref;
	wire OFLOW_ref;
	wire G_ref;
	wire L_ref;
	wire E_ref;
	wire ERR_ref;

	//dut decleration
	alu
	#(
		.N(N),
		.CMD_N(CMD_N)
	)
	dut (
		.OPA(OPA),
		.OPB(OPB),
		.CIN(CIN),
		.CLK(CLK),
		.RST(RST),
		.CE(CE),
		.MODE(MODE),
		.INP_VALID(INP_VALID),
		.CMD(CMD),
		.RES(RES_dut),
		.COUT(COUT_dut),
		.OFLOW(OFLOW_dut),
		.G(G_dut),
		.L(L_dut),
		.E(E_dut),
		.ERR(ERR_dut)
	);
	
	//reference module decleration
	/*alu ref(
		.OPA(OPA),
		.OPB(OPB),
		.CIN(CIN),
		.CLK(CLK),
		.RST(RST),
		.CE(CE),
		.MODE(MODE),
		.INP_VALID(INP_VALID),
		.CMD(CMD),
		.RES(RES_ref),
		.COUT(COUT_ref),
		.OFLOW(OFLOW_ref),
		.G(G_ref),
		.L(L_ref),
		.E(E_ref),
		.ERR(ERR_ref)
	);*/
	
	//driver
	/*task driver;
	endtask*/

	//monitor
	task monitor;
		$display("OPA:%b OPB:%b CIN:%b CE:%b MODE:%b INP_VALID:%b CMD:%b RES:%b OFLOW:%b COUT:%b G:%b L:%b E:%b ERR:%b",OPA,OPB,CIN,CE,MODE,INP_VALID,CMD,RES_dut,OFLOW_dut,COUT_dut,G_dut,L_dut,E_dut,ERR_dut);
	endtask

	//scoreboard
	/*task scoreboard;
	endtask*/

	task apply_test(
		input [N-1:0]opa,
		input [N-1:0]opb,
		input cin,
		input ce,
		input mode,
		input [1:0]inp_valid,
		input [CMD_N-1:0]cmd,
		input [80*8:1]test_name
	);
		begin
			@(posedge CLK);
			OPA = opa;
			OPB = opb;
			CIN = cin;
			CE = ce;
			MODE = mode;
			INP_VALID = inp_valid;
			CMD = cmd;
			@(posedge CLK);
			@(posedge CLK);
			monitor();
			//scoreboard();
		end
	endtask

	//clock signal
	initial begin
		CLK = 0;
		forever #5 CLK = ~CLK;
	end

	initial begin
		RST = 1;
		apply_test(4'b0001,4'b0001,1'b0,1'b1,1'b1,2'b11,4'b0000,"add_valid");
		@(posedge CLK);
		RST = 0;
		@(posedge CLK);
		apply_test(4'b0001,4'b0001,1'b0,1'b1,1'b1,2'b11,4'b0000,"add_valid");
		@(posedge CLK);
		$finish;
	end

endmodule
