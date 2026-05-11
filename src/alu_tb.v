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

	/*ALU dut (
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
	);*/

	//reference module decleration
	alu_ref ref(
		.OPA(OPA),
		.OPB(OPB),
		.CIN(CIN),
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
	task driver(
		input [N-1:0]opa,
		input [N-1:0]opb,
		input cin,
		input ce,
		input mode,
		input [1:0]inp_valid,
		input [CMD_N-1:0]cmd
	);
		begin
			OPA = opa;
			OPB = opb;
			CIN = cin;
			CE = ce;
			MODE = mode;
			INP_VALID = inp_valid;
			CMD = cmd;	
		end
	endtask

	//monitor
	task monitor;
		$display("OPA:%b OPB:%b CIN:%b CE:%b MODE:%b INP_VALID:%b CMD:%b RES:%b OFLOW:%b COUT:%b G:%b L:%b E:%b ERR:%b",OPA,OPB,CIN,CE,MODE,INP_VALID,CMD,RES_dut,OFLOW_dut,COUT_dut,G_dut,L_dut,E_dut,ERR_dut);
	endtask

	//scoreboard
	task scoreboard(
		input [1:40*8]test_name
	);
		if(RES_dut != RES_ref)
			$display("%s: Fail",test_name);
		else
			$display("%s: Pass",test_name);
	endtask

	task apply_test(
		input [N-1:0]opa,
		input [N-1:0]opb,
		input cin,
		input ce,
		input mode,
		input [1:0]inp_valid,
		input [CMD_N-1:0]cmd,
		input [1:40*8]test_name
	);
		begin
			@(posedge CLK);
			driver(opa,opb,cin,ce,mode,inp_valid,cmd);
			@(posedge CLK);
			@(posedge CLK);
			@(posedge CLK);
			monitor();
			scoreboard(test_name);
		end
	endtask

	task sanity_test;
		begin
			RST = 1;
			apply_test(4'b0001,4'b0001,1'b0,1'b1,1'b1,2'b11,4'b0000,"async_reset_assert_deassert");
			RST = 0;
			apply_test(4'b0001,4'b0001,1'b0,1'b1,1'b1,2'b11,4'b0000,"ce_enable_operation");
			apply_test(4'b0001,4'b0001,1'b0,1'b1,1'b0,2'b11,4'b0000,"mode_assert_deassert");
			apply_test(4'b0001,4'b0010,1'b0,1'b0,1'b1,2'b11,4'b0000,"ce_disabled");
			apply_test(4'b0001,4'b0010,1'b0,1'b1,1'b1,2'b00,4'b0000,"inp_invalid");
			apply_test(4'b0001,4'b0010,1'b0,1'b1,1'b1,2'b00,4'b1111,"invalid_command_mode_1");
			apply_test(4'b0001,4'b0010,1'b0,1'b1,1'b0,2'b00,4'b1111,"invalid_command_mode_1");
		end
	endtask

	task arithmetic_test;
		begin	
			apply_test(4'b0001,4'b0001,1'b0,1'b1,1'b1,2'b11,4'b0000,"add_valid");
			apply_test(4'b0001,4'b0001,1'b0,1'b1,1'b1,2'b01,4'b0000,"add_invalid");
			apply_test(4'b1111,4'b0001,1'b0,1'b1,1'b1,2'b11,4'b0000,"add_max");
			apply_test(4'b0010,4'b0001,1'b0,1'b1,1'b1,2'b11,4'b0001,"sub_valid");
			apply_test(4'b0010,4'b0001,1'b0,1'b1,1'b1,2'b01,4'b0001,"sub_invalid");
			apply_test(4'b0000,4'b0001,1'b0,1'b1,1'b1,2'b11,4'b0001,"sub_min");
			apply_test(4'b0001,4'b0001,1'b1,1'b1,1'b1,2'b11,4'b0010,"add_cin_valid");
			apply_test(4'b0001,4'b0001,1'b1,1'b1,1'b1,2'b01,4'b0010,"add_cin_invalid");
			apply_test(4'b1111,4'b0000,1'b1,1'b1,1'b1,2'b11,4'b0010,"add_cin_max");
			apply_test(4'b0010,4'b0000,1'b1,1'b1,1'b1,2'b11,4'b0011,"sub_cin_valid");
			apply_test(4'b0010,4'b0000,1'b1,1'b1,1'b1,2'b01,4'b0011,"sub_cin_invalid");
			apply_test(4'b0000,4'b0000,1'b1,1'b1,1'b1,2'b11,4'b0011,"sub_cin_min");
			apply_test(4'b0001,4'b0000,1'b0,1'b1,1'b1,2'b11,4'b0100,"inc_a_valid");
			apply_test(4'b0001,4'b0000,1'b0,1'b1,1'b1,2'b10,4'b0100,"inc_a_invalid");
			apply_test(4'b1111,4'b0000,1'b0,1'b1,1'b1,2'b11,4'b0100,"inc_a_max");
			apply_test(4'b0001,4'b0000,1'b0,1'b1,1'b1,2'b11,4'b0101,"dec_a_valid");
			apply_test(4'b0001,4'b0000,1'b0,1'b1,1'b1,2'b10,4'b0101,"dec_a_invalid");
			apply_test(4'b0000,4'b0000,1'b0,1'b1,1'b1,2'b11,4'b0101,"dec_a_min");
			apply_test(4'b0000,4'b0001,1'b0,1'b1,1'b1,2'b11,4'b0110,"inc_b_valid");
			apply_test(4'b0000,4'b0001,1'b0,1'b1,1'b1,2'b01,4'b0110,"inc_b_invalid");
			apply_test(4'b0000,4'b1111,1'b0,1'b1,1'b1,2'b11,4'b0110,"inc_b_max");
			apply_test(4'b0000,4'b0001,1'b0,1'b1,1'b1,2'b11,4'b0111,"dec_b_valid");
			apply_test(4'b0000,4'b0001,1'b0,1'b1,1'b1,2'b01,4'b0111,"dec_b_invalid");
			apply_test(4'b0000,4'b0000,1'b0,1'b1,1'b1,2'b11,4'b0111,"dec_b_min");
			apply_test(4'b0001,4'b0000,1'b0,1'b1,1'b1,2'b11,4'b1000,"cmp_valid_greater");
			apply_test(4'b0000,4'b0001,1'b0,1'b1,1'b1,2'b11,4'b1000,"cmp_valid_less");
			apply_test(4'b0000,4'b0000,1'b0,1'b1,1'b1,2'b11,4'b1000,"cmp_valid_equal");
			apply_test(4'b0000,4'b0000,1'b0,1'b1,1'b1,2'b01,4'b1000,"cmp_invalid");
			apply_test(4'b0001,4'b0010,1'b0,1'b1,1'b1,2'b11,4'b1001,"incr_a_mul_b_valid");
			apply_test(4'b0001,4'b0010,1'b0,1'b1,1'b1,2'b10,4'b1001,"incr_a_mul_b_invalid");
			apply_test(4'b0001,4'b0010,1'b0,1'b1,1'b1,2'b11,4'b1010,"l_shift_a_mul_b_valid");
			apply_test(4'b0001,4'b0010,1'b0,1'b1,1'b1,2'b10,4'b1010,"l_shift_a_mul_b_invalid");
			apply_test(4'b0001,4'b1010,1'b0,1'b1,1'b1,2'b11,4'b1011,"signed_addition_valid");
			apply_test(4'b0001,4'b1010,1'b0,1'b1,1'b1,2'b10,4'b1011,"signed_addition_invalid");
			apply_test(4'b0001,4'b0010,1'b0,1'b1,1'b1,2'b11,4'b1011,"signed_addition_overflow");
			apply_test(4'b0001,4'b1010,1'b0,1'b1,1'b1,2'b11,4'b1100,"signed_subtraction_valid");
			apply_test(4'b0001,4'b1010,1'b0,1'b1,1'b1,2'b10,4'b1100,"signed_subtraction_valid");
			apply_test(4'b1001,4'b1010,1'b0,1'b1,1'b1,2'b11,4'b1100,"signed_subtraction_overflow");
		end
	endtask

	task logical_test;
		begin
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b11,4'b0000,"and_valid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b01,4'b0000,"and_invalid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b11,4'b0001,"nand_valid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b01,4'b0001,"nand_invalid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b11,4'b0010,"or_valid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b01,4'b0010,"or_invalid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b11,4'b0011,"nor_valid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b01,4'b0011,"nor_invalid");
			apply_test(4'b1010,4'b0101,1'b0,1'b1,1'b0,2'b11,4'b0100,"xor_valid");
			apply_test(4'b1010,4'b0101,1'b0,1'b1,1'b0,2'b01,4'b0100,"xor_invalid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b11,4'b0101,"xnor_valid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b01,4'b0101,"xnor_invalid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b01,4'b0110,"not_a_valid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b10,4'b0110,"not_a_invalid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b10,4'b0111,"not_b_valid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b01,4'b0111,"not_b_invalid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b01,4'b1000,"shift_right_a_valid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b10,4'b1000,"shift_right_a_invalid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b01,4'b1001,"shift_left_a_valid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b10,4'b1001,"shift_left_a_invalid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b10,4'b1010,"shift_right_b_valid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b01,4'b1010,"shift_right_b_invalid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b10,4'b1011,"shift_left_b_valid");
			apply_test(4'b1010,4'b1010,1'b0,1'b1,1'b0,2'b01,4'b1011,"shift_left_b_invalid");
			apply_test(4'b0001,4'b0010,1'b0,1'b1,1'b0,2'b11,4'b1100,"rotate_left_a_b");
			apply_test(4'b0001,4'b1010,1'b0,1'b1,1'b0,2'b11,4'b1100,"rotate_left_a_b_err");
			apply_test(4'b0001,4'b0010,1'b0,1'b1,1'b0,2'b10,4'b1100,"rotate_left_a_b_invalid");
			apply_test(4'b0001,4'b0001,1'b0,1'b1,1'b0,2'b11,4'b1101,"rotate_right_a_b");
			apply_test(4'b0001,4'b1001,1'b0,1'b1,1'b0,2'b11,4'b1101,"rotate_right_a_b_err");
			apply_test(4'b0001,4'b0001,1'b0,1'b1,1'b0,2'b10,4'b1101,"rotate_right_a_b_invalid");
		end
	endtask

	//clock signal
	initial begin
		CLK = 0;
		forever #5 CLK = ~CLK;
	end

	initial begin
		sanity_test();
		logical_test();
		arithmetic_test();
		@(posedge CLK);
		$finish;
	end

endmodule
