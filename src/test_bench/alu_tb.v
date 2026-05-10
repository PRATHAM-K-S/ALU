module alu_tb;

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
	alu dut(
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
	alu ref(
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
	);
	
	//driver
	task driver;
	endtask

	//monitor
	task monitor;
	endtask

	//scoreboard
	task scoreboard;
	endtask

endmodule
