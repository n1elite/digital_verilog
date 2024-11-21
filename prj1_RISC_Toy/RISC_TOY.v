/*****************************************
    
    Team XX : 
        2024000000    Kim Mina
        2024000001    Lee Minho
*****************************************/


// You are able to add additional modules and instantiate in RISC_TOY.


////////////////////////////////////
//  TOP MODULE
////////////////////////////////////
module RISC_TOY (
    input     wire              CLK,
    input     wire              RSTN,
    output    wire              IREQ,
    output    wire    [29:0]    IADDR,
    input     wire    [31:0]    INSTR,
    output    wire              DREQ,
    output    wire              DRW,
    output    wire    [29:0]    DADDR,
    output    wire    [31:0]    DWDATA,
    input     wire    [31:0]    DRDATA
);


    // WRITE YOUR CODE
//Execute
reg EX_ALUImm,EX_ALUsigA,ALUsigB
reg [16:0]Ex_17;
reg [21:0]EX_22;
reg [4:0]EX_shamt;
reg [31:0]EX_PC;
reg [31:0]EX_data0;
reg [31:0]EX_data1;
    //Execute (제일 처음 쓴 코드,지금 사용X)
//reg EX_ALUImm,EX_ALUsigA,ALUsigB
//reg [16:0]Ex_17;
//reg [21:0]EX_22;
//reg [4:0]EX_shamt;
//reg [31:0]EX_PC;
//reg [31:0]EX_data0;
//reg [31:0]EX_data1;


//MUX////

    wire [31:0]valA,valB; wire signed [31:0]offset; //Immediate Signed Extension

//assign valA= EX_ALUsigA? EX_PC:EX_data0; 
//assign valB= EX_ALUsigB? EX_shamt:EX_data1;
//assign offset=EX_ALUImm? EX_22:EX_17;


    // main 코드에서의 변수랑 내 코드 변수랑 맞추기

    //ALU my_alu (
    //.valA(alu_valA),
    //.valB(alu_valB),
    //.offset(alu_offset),
    //.ALUop(alu_op),
    //.ALUdo(alu_do),
    //.Result(alu_result)
);
// 
// assign alu_valA = DE_rv1;
//assign alu_valB = DE_rv2;
//assign alu_offset = DE_imm;
//assign alu_op = DE_op;
//assign alu_do = 1'b1;
    //always @(posedge CLK or negedge RSTN) begin
//if (~RSTN) begin
  //      XM_aluout <= 0;
   // end else begin
    //    XM_aluout <= alu_result;
    //end
// end
module ALU (
    input signed [31:0] valA,   // 레지스터 A 값
    input signed [31:0] valB,   // 레지스터 B 값
    input signed [31:0] offset, // Immediate 값
    input [4:0] ALUop,          // ALU 연산 코드
    input ALUdo,                // ALU 실행 제어 신호
    output reg signed [31:0] Result // 연산 결과
);
    // ALU 
/////////////////ID_EX/////////////////
	always @(*) begin
    	case (ID_op)
        	// Immediate 연산
        	ADDI: ALU_out = ID_valB + {{15{offset[16]}}, offset[16:0]};
        	ANDI: ALU_out = ID_valB & {{15{offset[16]}}, offset[16:0]};
        	ORI:  ALU_out = ID_valB | {{15{offset[16]}}, offset[16:0]};
        	MOVI: ALU_out = {{15{offset[16]}}, offset[16:0]};
        	// Register 간 연산
        	ADD:  ALU_out = ID_valA + ID_valB;
        	SUB:  ALU_out = ID_valA - ID_valB;
        	NEG:  ALU_out = -ID_valB;
        	NOT:  ALU_out = ~ID_valB;
        	AND:  ALU_out = ID_valA & ID_valB;
        	OR :  ALU_out = ID_valA | ID_valB;
        	XOR:  ALU_out = ID_valA ^ ID_valB;
        	// Shift 연산
        	LSR:  ALU_out = ID_valA >> ID_valB[4:0];   		//조건문 안나눴음 안해도 될듯?
        	ASR:  ALU_out = ID_valA >>> ID_valB[4:0];  		//조건문 안나눴음안해도 될듯?
        	SHL:  ALU_out = ID_valA << ID_valB[4:0];		//조건문안해도 될듯?
        	ROR:  ALU_out = (ID_valA >> ID_valB[4:0]) | (ID_valA << (32 - ID_valB[4:0]));		//조건문안해도 될듯?
        	BR :  begin
				if(ID_instr[2:0] == 0) begin
				end
				else if (ID_instr[2:0] == 1)begin
					ALU_PC <= ID_valA;
				end
				else if (ID_instr[2:0] == 2)begin
					if(ID_valB == 0)begin
						ALU_PC <= ID_valA
					end
				end
				else if (ID_instr[2:0] == 3)begin
					if(ID_valB != 0)begin
						ALU_PC <= ID_valA
					end
				end
				else if (ID_instr[2:0] == 4)begin
					if(ID_valB >= 0)begin
						ALU_PC <= ID_valA
					end
				end
				else if (ID_instr[2:0] == 5)begin
					if(ID_valB < 0)begin
						ALU_PC <= ID_valA
					end
				end
			end
        	BRL:	begin
				ALU_out = ID_iaddr;
				if(ID_instr[2:0] == 0) begin
				end
				else if (ID_instr[2:0] == 1)begin
					ALU_PC <= ID_valA;
				end
				else if (ID_instr[2:0] == 2)begin
					if(ID_valB == 0)begin
						ALU_PC <= ID_valA
					end
				end
				else if (ID_instr[2:0] == 3)begin
					if(ID_valB != 0)begin
						ALU_PC <= ID_valA
					end
				end
				else if (ID_instr[2:0] == 4)begin
					if(ID_valB >= 0)begin
						ALU_PC <= ID_valA
					end
				end
				else if (ID_instr[2:0] == 5)begin
					if(ID_valB < 0)begin
						ALU_PC <= ID_valA
					end
				end
			end
        	J  :  ALU_PC = {ID_iaddr, 2'b0} + ID_imm;
        	JL :  begin
				ALU_out ={ID_iaddr, 2'b0};
				ALU_PC = {ID_iaddr, 2'b0} + ID_imm;
			end
			LD : begin //수정!
				if(ID_instr[26:22] == 5'b11111) begin				 //memory 앍어야 함  read신호
				    ALU_out <= 15'b0, ID_imm[16:0];    
				end	else begin
				    ALU_out <= ID_imm + ID_valB;         
				end
			end
			LDR	: ALU_out <= {ID_iaddr, 2'b0} + ID_imm;        	//memory 앍어야 함  read신호
			ST	: begin												//memory에 적어야 함 write 신호
				if(instr21_17 == 5'b11111) begin	
    				ALU_out <= 15'b0, ID_imm[16:0];
				end	else begin
				    ALU_out <= ID_imm + ID_valB;
				end
			end
			STR : ALU_out <= {ID_iaddr, 2'b0} + ID_imm; 			//memory에 적어야 함 write 신호
		endcase			
	end      


	always @(posedge CLK or negedge RSTN) begin
		if(!RSTN) begin
			EX_dest <= 0;
			EX_op <= 0;
			EX_ALU_out <= 0;
			EX_valB <= 0;
			EX_imm <= 0;
            EX_iaddr <= 0;
            EX_instr <= 0;
		end else begin
			EX_dest <= ID_dest;
			EX_op <= ID_op;
			EX_ALU_out <= ALU_out;
			EX_valB <= ID_valB;
            
			EX_iaddr <= ID_iaddr;
            EX_instr <= ID_instr;
			if (ID_op == `BR || ID_op == `BRL || ID_op == `J || ID_op == `JL)	begin
				EX_iaddr <= ALU_PC;
			end	else begin
				EX_iaddr <= ID_iaddr;
			end
		end
	end






///////////////// MEM ///////////////
always @(posedge CLK or negedge RSTN) begin
    if (!RSTN) begin
        XM_op <= 0;
        XM_ra <= 0;
        XM_aluout <= 0;
        XM_rv1 <= 0;
        XM_rv2 <= 0;
        XM_instr <= 0;
        XM_iaddr <= 0;
        XM_we <= 0;
        XM_wer <= 0;
    end else begin
        XM_op <= EX_op;
        XM_ra <= EX_dest;
        XM_aluout <= EX_ALU_out;
        XM_rv1 <= EX_valB;
        XM_instr <= EX_instr;
        XM_iaddr <= EX_iaddr;
        
	if (ID_op == `LD || ID_op == `LDR) begin
            EX_wer <= 1;  // 메모리 읽기 요청
            EX_we <= 0;   // 쓰기 동작 비활성화
        end else if (ID_op == `ST || ID_op == `STR) begin
            EX_wer <= 0;  // 읽기 동작 비활성화
            EX_we <= 1;   // 메모리 쓰기 요청
        end else begin
            EX_wer <= 0;
            EX_we <= 0;
        end
    end
end
//////////////// WB ////////////////
always @(posedge CLK or negedge RSTN) begin
    if (!RSTN) begin
        MW_op <= 0;
        MW_ra <= 0;
        MW_aluout <= 0;
        MW_rv1 <= 0;
        MW_rv2 <= 0;
        MW_instr <= 0;
        MW_iaddr <= 0;
        MW_wer <= 0;
        MW_we <= 0;
    end else begin
        MW_op <= XM_op;
        MW_ra <= XM_ra;
        MW_aluout <= XM_aluout;
        MW_rv1 <= XM_rv1;
        MW_rv2 <= XM_rv2;
        MW_instr <= XM_instr;
        MW_iaddr <= XM_iaddr;
        MW_wer <= XM_wer;
        MW_we <= XM_we;
    end
end


// REGISTER FILE FOR GENERAL PURPOSE REGISTERS
REGFILE    #(.AW(5), .ENTRY(32))    RegFile (
                .CLK    (CLK),
                .RSTN   (RSTN),
                .WEN    (MW_wer || MW_we),   // Write Enable: 메모리 읽기(wer)나 ALU 연산 결과(we)일 때 활성화
                .WA     (MW_ra),             // Write Address: 목적지 레지스터 주소
                .DI     (MW_aluout),  // ALU 결과??
                .RA0    (FI_read_address0),  // Read Address 0: 소스 레지스터 주소 0
                .RA1    (FI_read_address1),  // Read Address 1: 소스 레지스터 주소 1
                .DOUT0  (read_data0),        // Read Data 0: 읽은 레지스터 값 0
                .DOUT1  (read_data1)         // Read Data 1: 읽은 레지스터 값 1
);

    // WRITE YOUR CODE



endmodule
