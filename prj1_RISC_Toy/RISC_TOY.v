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
    reg [4:0] FI_read_address0, FI_read_address1, FI_dest;      
    reg [4:0] FI_op; 
    reg [31:0] FI_instr;                                        // 명령어
    reg [29:0] FI_iaddr;                                        // 명령어 add
    reg [31:0] FI_imm;
    reg [31:0] FI_valA, FI_valB;

    /////////////////ID_EX/////////////////
    reg [4:0] DE_read_address0, DE_read_address1 DE_dest;        // rega add _ regb add _ regc add _ opcode
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

    always @(posedge CLK or negedge RSTN) begin
       	if (!RSTN) begin
           		PC <= 0; // Reset Program Counter
		IF_instr <= 0;
       	end else begin
           		PC <= next_PC; // Update Program Counter
		IF_instr <= INSTR;
       	end
    end




    // REGISTER FILE FOR GENRAL PURPOSE REGISTERS
    REGFILE    #(.AW(5), .ENTRY(32))    RegFile (
                    .CLK    (CLK),
                    .RSTN   (RSTN),
                    .WEN    (),
                    .WA     (),
                    .DI     (),
                    .RA0    (),
                    .RA1    (),
                    .DOUT0  (),
                    .DOUT1  ()
    );





    // WRITE YOUR CODE

    /////////////////IF/////////////////
    always @(posedge CLK or negedge RSTN) begin
        if(~RSTN) begin
            IF_op <= 0;
            IF_instr <= 0;
        end
        else begin
            IF_op <= INSTR[31:27];
            IF_instr <= INSTR;
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


	wire [31:0] read_data0, read_data1;


    always @(posedge CLK or negedge RSTN) begin
		if(!RSTN) begin
            FI_op <= 0;
            FI_instr <= 0;
            FI_iaddr <= 0;
			FI_read_address0 <= 0;
			FI_read_address1 <= 0;
			FI_valA <= 0;
			FI_valB <= 0;
			FI_imm <= 0;
			FI_dest <= 0;
			PC <= 0;
		end else begin 

            FI_op <= IF_op;
            FI_instr <= IF_instr;
            FI_iaddr <= IF_iaddr;

		    if(ADDI || ANDI || ORI || LD || ST) begin //MOVI 주의
			    FI_read_address0 <= IF_instr[26:22];
    			FI_read_address1 <= IF_instr[21:17];
	    		FI_valA <= read_data1; FI_valB <= read_data0; 
		    	FI_imm <= {15'b0, IF_instr[16:0]}; FI_dest <= IF_instr[26:22];
		    end else if(MOVI) begin 
    			FI_read_address0 <= INSTR[21:17];
	    		FI_read_address1 <= INSTR[16:12];
		    	FI_valA <= read_data0; FI_valB <= read_data1; 
		    	FI_imm <= {15'b0, IF_instr[16:0]}; FI_dest <= IF_instr[26:22];
		    end else if(ADD || SUB || AND || OR || XOR) begin 
		    	//NEG, NOT 주의
		    	FI_read_address0 <= INSTR[21:17];
		    	FI_read_address1 <= INSTR[16:12];
		    	FI_valA <= read_data0; FI_valB <= read_data1; 
		    	FI_imm <= {15'b0, IF_instr[26:22]}; FI_dest <= IF_instr[26:22];
		    end else if(NEG || NOT) begin 
		    	//NEG, NOT 주의
		    	FI_read_address0 <= INSTR[26:22];
		    	FI_read_address1 <= INSTR[16:12];
		    	FI_valA <= read_data1; FI_valB <= read_data0; 
		    	FI_imm <= {15'b0, IF_instr[26:22]}; FI_dest <= IF_instr[26:22];
		    end else if(LSR || ASR || SHL || ROR) begin 
		    	FI_read_address0 <= IF_instr[21:17];
		    	if (INSTR[5] == 0)
		    		FI_valB <= IF_instr[4:0];
		    	else begin
		    		FI_read_address1 <= IF_instr[16:12];
		    		FI_valB <= read_data1;
		    	end
		    	FI_valA <= read_data0;  
		    	FI_imm <= IF_instr[26:22]; FI_dest <= IF_instr[26:22];
		    end else if(BR) begin 
		    	FI_read_address0 <= IF_instr[21:17];
		    	FI_read_address1 <= IF_instr[16:12];
		    	FI_valA <= read_data0; FI_valB <= read_data1; 
		    	//FI_imm <= INSTR[26:22]; FI_dest <= INSTR[26:22];
		    end else if(BRL) begin 
		    	FI_read_address0 <= IF_instr[21:17];
		    	FI_read_address1 <= IF_instr[16:12];
		    	FI_valA <= read_data0; FI_valB <= read_data1; 
		    	//FI_imm <= INSTR[26:22]; FI_dest <= INSTR[26:22];
		    end else if(JL || LDR || STR) begin 
		    	FI_read_address0 <= IF_instr[26:22];
		    	FI_valB <= read_data0; 
		    	FI_imm <= IF_instr[21:0]; FI_dest <= IF_instr[26:22];
		    end else if(J) begin 
		    	FI_imm <= IF_instr[21:0]; 
		    end
	    end
    end























/////////////////////////////clock 여기 변수 수정해야 됨

always @(posedge CLK or negedge RSTN) begin
     	if (!RSTN) begin
          		next_PC = 0;
       	end else if (J || JL) begin
		next_PC = PC + offset; // Jump with offset
       	end else if (BR || BRL) begin
		if (valA == valB) begin  // ALU에서 비교한 리턴값 보내주면 조건 대체
               		next_PC = read_data0; // Branch if condition is met
           		end else begin
               		next_PC = PC + 4; // Increment to next instruction
           	end
       	end else begin
           		next_PC = PC + 4; // Default: increment by 4 (next instruction)
       	end
   	end



endmodule
