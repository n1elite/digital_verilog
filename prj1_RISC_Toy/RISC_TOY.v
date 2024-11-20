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



	
    /////////////////IF/////////////////
    reg [31:0] IF_instr;
    reg [29:0] IF_iaddr;
    reg [4:0] IF_op;

    /////////////////IF_ID/////////////////      
    reg [4:0] FI_op; 
    reg [31:0] FI_instr;                                        // 명령어
    reg [29:0] FI_iaddr;                                        // 명령어 add
    reg [31:0] FI_imm;
    reg [31:0] FI_valA, FI_valB, FI_dest;
    wire [4:0] FI_read_address0, FI_read_address1;
    wire [31:0] read_data0, read_data1;

    /////////////////ID_EX/////////////////
    reg [4:0] DE_read_address0, DE_read_address1, DE_dest;        // rega add _ regb add _ regc add _ opcode
    reg [4:0] DE_op; 
    reg [31:0] DE_valA, DE_valB, DE_imm;                          // FI_valA _ FI_valB _ FI_imm 
    reg [31:0] DE_instr;                                        // 명령어
    reg [29:0] DE_iaddr;                                        // 명령어 add

    
    reg DE_we, DE_wer;                                          // DREQ가 될 녀석, IREQ가 될 녀석   (write enalbe / write enable reg)
    

    /////////////////EX_MEM/////////////////

    reg [4:0] XM_op, XM_ra;                                     // opcode 5bit _ dest reg add
    reg [31:0] XM_aluout, XM_rv1, XM_rv2, XM_instr;             // alu result _ FI_valA _ FI_valB _ 명령어
    reg [29:0] XM_iaddr;                                        // IF_instr add (PC) => DADDR

    reg XM_we, XM_wer;

    /////////////////MEM_WB/////////////////

    reg [4:0] MW_op, MW_ra;                                     // opcode 5bit _ dest reg add
    reg [31:0] MW_aluout, MW_rv1, MW_rv2, MW_instr, WB_instr;   // alu result _ FI_valA _ FI_valB _ 어떤 계산 _ 어떤 계산
    reg [29:0] MW_iaddr;                                        // P
    reg MW_wer, MW_we;  // 계산 결과 이어받음 이게 mem에 연결되서 wer에서 enable되면 reg에 저장하고 we에서 enable되면 mem에 저장





    reg [31:0] PC;  // Program Counter
    reg [31:0] next_PC;
    


    // REGISTER FILE FOR GENRAL PURPOSE REGISTERS
    REGFILE    #(.AW(5), .ENTRY(32))    RegFile (
                    .CLK    (CLK),
                    .RSTN   (RSTN),
	    	    .WEN    (WEN),
	    .WA     (WA),
	    .DI     (DI),
	    .RA0    (FI_read_address0),
	    .RA1    (FI_read_address1),
	    .DOUT0  (read_data0),
	    .DOUT1  (read_data1)
    );





    // WRITE YOUR CODE

    /////////////////IF/////////////////
    always @(posedge CLK or negedge RSTN) begin
        if(~RSTN) begin
            IF_op <= 0;
            IF_instr <= 0;
	    IF_iaddr <= 0;
        end
	else if (IREQ) begin
            IF_op <= INSTR[31:27];
            IF_instr <= INSTR;
	    IF_iaddr <= PC[31:2];
        end
        
    end

    /////////////////IF_ID/////////////////

	wire ADDI = (IF_op == 5'b00000);
	wire ANDI = (IF_op == 5'b00001);
	wire ORI = (IF_op == 5'b00010);
	wire MOVI = (IF_op == 5'b00011);
	wire ADD = (IF_op == 5'b00100);
	wire SUB = (IF_op == 5'b00101);
	wire NEG = (IF_op == 5'b00110);
	wire NOT = (IF_op == 5'b00111);
	wire AND = (IF_op == 5'b01000);
	wire OR = (IF_op == 5'b01001);
	wire XOR = (IF_op == 5'b01010);
	wire LSR = (IF_op == 5'b01011);
	wire ASR = (IF_op == 5'b01100);
	wire SHL = (IF_op == 5'b01101);
	wire ROR = (IF_op == 5'b01110);
	wire BR = (IF_op == 5'b01111);
	wire BRL = (IF_op == 5'b10000);
	wire J = (IF_op == 5'b10001);
	wire JL = (IF_op == 5'b10010);
	wire LD = (IF_op == 5'b10011);
	wire LDR = (IF_op == 5'b10100);
	wire ST = (IF_op == 5'b10101);
	wire STR = (IF_op == 5'b10110);


	assign FI_read_address0 = (ADDI || ANDI || ORI || LD || ST || MOVI || NEG || NOT) ? IF_instr[26:22] : 
		(ADD || SUB || AND || OR || XOR || LSR || ASR || SHL || ROR || BR || BRL) ? IF_instr[21:17] : 0;
	assign FI_read_address1 = (ADDI || ANDI || ORI || LD || ST) ? IF_instr[21:17] : 
		(ADD || SUB || AND || OR || XOR || NEG || NOT || BR || BRL ) ? IF_instr[16:12] :
		((LSR || ASR || SHL || ROR) && IF_instr[5]) ? IF_instr[16:12] :IF_instr[4:0];
		

    always @(posedge CLK or negedge RSTN) begin
		if(!RSTN) begin
			FI_valA <= 0;
			FI_valB <= 0;
			FI_imm <= 0;
			FI_dest <= 0;
            		FI_iaddr <= 0;
            		FI_instr <= 0;
            		FI_op <= 0;
			PC <= 0;
		end else begin 
            	FI_iaddr <= IF_iaddr;
            	FI_instr <= IF_instr;
            	FI_op <= IF_op;
			if(ADDI || ANDI || ORI || LD || ST) begin //MOVI 주의
				FI_valA <= read_data1;//R[ra]
				FI_valB <= read_data0;//R[rb] 
				FI_imm <= {15'b0, IF_instr[16:0]}; //상수
				FI_dest <= IF_instr[26:22]; //ra
			end else if(MOVI) begin 
				FI_valB <= read_data1; //R[ra]
				FI_imm <= {15'b0, IF_instr[16:0]}; //imm
				FI_dest <= IF_instr[26:22]; //ra
			end else if(ADD || SUB || AND || OR || XOR) begin 
				FI_valA <= read_data0; //R[rb]
				FI_valB <= read_data1; //R[rc]
				FI_imm <= {15'b0, IF_instr[26:22]}; //ra
				FI_dest <= IF_instr[26:22]; //ra
			end else if(NEG || NOT) begin 
				FI_valA <= read_data1; //R[rc] 
				FI_valB <= read_data0; //R[ra]
				FI_imm <= {15'b0, IF_instr[26:22]}; //ra 
				FI_dest <= IF_instr[26:22]; //ra
			end else if(LSR || ASR || SHL || ROR) begin 
				FI_valA <= read_data0; //R[rb]  
				FI_imm <= IF_instr[26:22]; //ra
				FI_dest <= IF_instr[26:22]; //ra
			end else if(BR) begin 
				FI_valA <= read_data0; //R[rb]
				FI_valB <= read_data1; //R[rc]
				FI_imm <= IF_instr[2:0]; //cond
			end else if(BRL) begin 
				FI_valA <= read_data0; //R[rb]
				FI_valB <= read_data1; //R[rc]
				FI_imm <= IF_instr[2:0]; //cond 
				FI_dest <= IF_instr[26:22];
			end else if(JL || LDR || STR) begin 
				FI_valA <= PC; // 현재 PC
				FI_imm <= IF_instr[21:0]; //imm
				FI_dest <= IF_instr[26:22]; //ra
			end else if(J) begin 
				FI_valA <= PC; // 현재 PC
				FI_imm <= IF_instr[21:0]; //imm
			end
		end
	end























/////////////////////////////clock 여기 변수 수정해야 됨

    always @(posedge CLK or negedge RSTN) begin
         	if (!RSTN) begin
              		next_PC = 0;
           	end else if (J || JL) begin
    		next_PC = PC + FI_imm; // Jump with FI_imm
           	end else if (BR || BRL) begin
    		if (FI_valA == FI_valB) begin  // ALU에서 비교한 리턴값 보내주면 조건 대체
            	next_PC = read_data0; // Branch if condition is met
            end else begin
           		next_PC = PC + 4; // Increment to next IF_instr
           	end
       	end else begin
        	next_PC = PC + 4; // Default: increment by 4 (next IF_instr)
       	end
    end



endmodule
