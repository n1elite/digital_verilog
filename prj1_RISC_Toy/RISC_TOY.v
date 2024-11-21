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
`define ADDI 	5'b00000
`define ANDI 	5'b00001
`define ORI		5'b00010
`define MOVI		5'b00011
`define ADD		5'b00100
`define SUB		5'b00101
`define NEG		5'b00110
`define NOT		5'b00111
`define AND		5'b01000
`define OR		5'b01001
`define XOR		5'b01010
`define LSR		5'b01011
`define ASR		5'b01100
`define SHL		5'b01101
`define ROR		5'b01110
`define BR		5'b01111
`define BRL		5'b10000
`define J		5'b10001
`define JL		5'b10010
`define LD		5'b10011
`define LDR		5'b10100
`define ST		5'b10101
`define STR		5'b10110

    
    /////////////////IF/////////////////
    reg [31:0] IF_instr;
    reg [29:0] IF_iaddr;
    reg [4:0] IF_op;


    /////////////////IF_ID/////////////////
    wire [4:0] FI_read_address0, FI_read_address1;
    wire [31:0] read_data0, read_data1;


	/////////////////ID/////////////////
    reg [4:0] ID_dest;      
    reg [4:0] ID_op; 
    reg [31:0] ID_instr;                                        // 명령어
    reg [29:0] ID_iaddr;                                        // 명령어 add
    reg [31:0] ID_imm;
    reg [31:0] ID_valA, ID_valB;

	/////////////////ID_EX/////////////////
    reg [31:0] ALU_out;
    reg [31:0] ALU_PC;

	//cond


    /////////////////EX/////////////////
    reg [4:0] EX_dest;        											// rega add _ regb add _ regc add _ opcode
    reg [4:0] EX_op; 
    reg [31:0] EX_ALU_out, EX_valA, EX_valB, EX_imm;                          // ID_valA _ ID_valB _ ID_imm 
    reg [31:0] EX_instr;                                        // 명령어
    reg [29:0] EX_iaddr;                                        // 명령어 add
    reg [2:0] EX_cond;
    reg EX_BR_enable;
    reg EX_we, EX_wer;                                          // DREQ가 될 녀적, IREQ가 될 녀적   (write enalbe / write enable reg)

    /////////////////EX_MEM/////////////////
    reg [4:0] XM_op, XM_ra;												// opcode 5bit _ dest reg add
    reg [31:0] XM_aluout, XM_rv1, XM_rv2, XM_instr;							// alu EX_ALU_out _ ID_valA _ ID_valB _ 명령어
    reg XM_we, XM_wer, XM_csn;

    /////////////////MEM_WB/////////////////
    reg [4:0] MW_op, MW_ra;                                     // opcode 5bit _ dest reg add
    reg [31:0] MW_aluout, MW_rv1, MW_rv2, MW_instr, WB_instr;   // alu EX_ALU_out _ ID_valA _ ID_valB _ 어떤 계산 _ 어떤 계산
    reg MW_wer, MW_we;  // 계산 결과 이어받음 이것이 mem에 연결되서 wer에서 enable되면 reg에 저장하고 we에서 enable되면 mem에 저장


    /////////////////PC_reg/////////////////
    reg [31:0] PC;  // Program Counter


    // REGISTER FILE FOR GENRAL PURPOSE REGISTERS
    REGFILE    #(.AW(5), .ENTRY(32))    RegFile (
                    .CLK    (CLK),
                    .RSTN   (RSTN),
                    .WEN    (MW_wer),
                    .WA     (MW_ra),
                    .DI     (MW_aluout),
                    .RA0    (FI_read_address0),
                    .RA1    (FI_read_address1),
                    .DOUT0  (read_data0),
                    .DOUT1  (read_data1)
    );


    /////////////////IF/////////////////
    always @(posedge CLK or negedge RSTN) begin
        if(~RSTN) begin
            IF_op <= 0;
            IF_instr <= 0;
			IF_iaddr <= 0;
        end
        else begin
            IF_op <= INSTR[31:27];
            IF_instr <= INSTR;
			IF_iaddr <= PC;
        end
        
    end

	assign IREQ = 1;
	assign IADDR = IF_iaddr;

    /////////////////IF_ID/////////////////


	assign FI_read_address0 = 
    		(IF_op == `ADDI || IF_op == `ANDI || IF_op == `ORI || IF_op == `LD || 
    	 	IF_op == `ST || IF_op == `MOVI || IF_op == `NEG || IF_op == `NOT) ? IF_instr[26:22] :
    		(IF_op == `ADD || IF_op == `SUB || IF_op == `AND || IF_op == `OR || 
    	 	IF_op == `XOR || IF_op == `LSR || IF_op == `ASR || IF_op == `SHL || 
    	 	IF_op == `ROR || IF_op == `BR || IF_op == `BRL) ? IF_instr[21:17] : 0;

	assign FI_read_address1 = 
	    	(IF_op == `ADDI || IF_op == `ANDI || IF_op == `ORI || IF_op == `LD || IF_op == `ST) ? IF_instr[21:17] :
    		(IF_op == `ADD || IF_op == `SUB || IF_op == `AND || IF_op == `OR || IF_op == `XOR || 
    	 	IF_op == `NEG || IF_op == `NOT || IF_op == `BR || IF_op == `BRL) ? IF_instr[16:12] :
		((IF_op == `LSR || IF_op == `ASR || IF_op == `SHL || IF_op == `ROR) && IF_instr[5]) ? IF_instr[16:12] : IF_instr[4:0];



    always @(posedge CLK or negedge RSTN) begin
		if(!RSTN) begin
			ID_valA <= 0;
			ID_valB <= 0;
			ID_imm <= 0;
			ID_dest <= 0;
          		ID_iaddr <= 0;
           		ID_instr <= 0;
            		ID_op <= 0;
		end else begin 
            		ID_iaddr <= IF_iaddr;
            		ID_instr <= IF_instr;
            		ID_op <= IF_op;
				case(IF_op)
					`ADDI, `ANDI, `ORI: begin
					ID_valA <= read_data1;//R[ra]
					ID_valB <= read_data0;//R[rb] 
					ID_imm <= {{15{IF_instr[16]}}, IF_instr[16:0]}; //상수
					ID_dest <= IF_instr[26:22]; //ra
				end `MOVI: begin 
					ID_valB <= read_data1; //R[ra]
					ID_imm <= {{15{IF_instr[16]}}, IF_instr[16:0]}; //imm
					ID_dest <= IF_instr[26:22]; //ra
				end `ADD, `SUB, `AND, `OR, `XOR: begin
					ID_valA <= read_data0; //R[rb]
					ID_valB <= read_data1; //R[rc]
					ID_imm <= {27'b0, IF_instr[26:22]}; //ra
					ID_dest <= IF_instr[26:22]; //ra
				end `NEG, `NOT: begin
					ID_valA <= read_data1; //R[rc] 
					ID_valB <= read_data0; //R[ra]
					ID_imm <= {27'b0, IF_instr[26:22]}; //ra 
					ID_dest <= IF_instr[26:22]; //ra
				end `LSR, `ASR, `SHL, `ROR: begin
					ID_valA <= read_data0; //R[rb]  
					ID_imm <= {27'b0, IF_instr[26:22]}; //ra				수정!
					ID_dest <= IF_instr[26:22]; //ra	
				end `BR: begin 
					ID_valA <= read_data0; //R[rb]
					ID_valB <= read_data1; //R[rc]
					ID_imm <= {29'b0,IF_instr[2:0]}; //cond    	
				end `BRL: begin 
					ID_valA <= read_data0; //R[rb]
					ID_valB <= read_data1; //R[rc]
					ID_imm <= {29'b0,IF_instr[2:0]}; //cond  	
					ID_dest <= IF_instr[26:22];
				end `JL, `LDR, `STR: begin
					ID_valA <= {IF_iaddr,2'b0}; // 현재 PC
					ID_imm <= {{10{IF_instr[21]}},IF_instr[21:0]}; //imm
					ID_dest <= IF_instr[26:22]; //ra
				end `J: begin
					ID_valA <= {IF_iaddr,2'b0}; // 현재 PC
					ID_imm <= {{10{IF_instr[21]}},IF_instr[21:0]}; //imm
				end `LD, `ST: begin
					ID_valA <= read_data1;//R[ra]
					ID_valB <= read_data0;//R[rb] 
					ID_imm <= {15'b0, IF_instr[16:0]}; //상수
					ID_dest <= IF_instr[26:22]; //ra
				end
			endcase
		end
	end


	/////////////////ID_EX/////////////////
	always @(*) begin
    	case (ID_op)
        	// Immediate 연산
        	`ADDI: ALU_out <= ID_valB + ID_imm;
        	`ANDI: ALU_out = ID_valB & ID_imm;
        	`ORI:  ALU_out = ID_valB | ID_imm;
        	`MOVI: ALU_out = ID_imm;
        	// Register 간 연산
        	`ADD:  ALU_out = ID_valA + ID_valB;
        	`SUB:  ALU_out = ID_valA - ID_valB;
        	`NEG:  ALU_out = -ID_valB;
        	`NOT:  ALU_out = ~ID_valB;
        	`AND:  ALU_out = ID_valA & ID_valB;
        	`OR :  ALU_out = ID_valA | ID_valB;
        	`XOR:  ALU_out = ID_valA ^ ID_valB;
        	// Shift 연산
        	`LSR:  ALU_out = ID_valA >> ID_valB[4:0];   		//조건문 안나눔음 안해도 될드?
        	`ASR:  ALU_out = ID_valA >>> ID_valB[4:0];  		//조건문 안나눔음안해도 될드?
        	`SHL:  ALU_out = ID_valA << ID_valB[4:0];		//조건문안해도 될드?
        	`ROR:  ALU_out = (ID_valA >> ID_valB[4:0]) | (ID_valA << (32 - ID_valB[4:0]));		//조건문안해도 될드?
        	`BR :  begin
			if(ID_instr[2:0] == 0) begin
			end
			else if (ID_instr[2:0] == 1)begin
				ALU_PC <= ID_valA;
				EX_BR_enable <= 1;
			end
			else if (ID_instr[2:0] == 2)begin
				if(ID_valB == 0)begin
					ALU_PC <= ID_valA;
					EX_BR_enable <= 1;
				end
			end
				else if (ID_instr[2:0] == 3)begin
					if(ID_valB != 0)begin
						ALU_PC <= ID_valA;
						EX_BR_enable <= 1;
					end
				end
				else if (ID_instr[2:0] == 4)begin
					if(ID_valB >= 0)begin
						ALU_PC <= ID_valA;
						EX_BR_enable <= 1;
					end
				end
				else if (ID_instr[2:0] == 5)begin
					if(ID_valB < 0)begin
						ALU_PC <= ID_valA;
						EX_BR_enable <= 1;
					end
				end
			end
        	`BRL:	begin
			ALU_out = ID_iaddr;
			if(ID_instr[2:0] == 0) begin
			end
			else if (ID_instr[2:0] == 1)begin
				ALU_PC <= ID_valA;
				EX_BR_enable <= 1;
			end
			else if (ID_instr[2:0] == 2)begin
				if(ID_valB == 0)begin
					ALU_PC <= ID_valA;
					EX_BR_enable <= 1;
				end
			end
			else if (ID_instr[2:0] == 3)begin
				if(ID_valB != 0)begin
					ALU_PC <= ID_valA;
					EX_BR_enable <= 1;
				end
			end
			else if (ID_instr[2:0] == 4)begin
				if(ID_valB >= 0)begin
					ALU_PC <= ID_valA;
					EX_BR_enable <= 1;
				end
			end
			else if (ID_instr[2:0] == 5)begin
				if(ID_valB < 0)begin
					ALU_PC <= ID_valA;
					EX_BR_enable <= 1;
				end
			end
		end
        	`J  :  ALU_PC = {ID_iaddr, 2'b0} + ID_imm;
        	`JL :  begin
			ALU_out ={ID_iaddr, 2'b0};
			ALU_PC = {ID_iaddr, 2'b0} + ID_imm;
			end
			`LD : begin //수정!
				if(ID_valB == 5'b11111) begin				 //memory 알켜야 함  read신호
				    ALU_out <= {15'b0, ID_imm[16:0]};    
				end	else begin
				    ALU_out <= ID_imm + ID_valB;         
				end
			end
			`LDR	: ALU_out <= {ID_iaddr, 2'b0} + ID_imm;        	//memory 알켜야 함  read신호
			`ST	: begin											//memory에 적어야 함 write 신호
				if(ID_valA == 5'b11111) begin	
    				ALU_out <= {15'b0, ID_imm[16:0]};
				end	else begin
				    ALU_out <= ID_imm + ID_valB;
				end
			end
			`STR : ALU_out <= {ID_iaddr, 2'b0} + ID_imm; 			//memory에 적어야 함 write 신호
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
		end else begin
			EX_iaddr <= ID_iaddr;
		end
	end
	end

	/////////////////EX_MEM/////////////////
    SRAM #(
        .BW(32),           // 데이터 폭 32비트 (기본값)
        .AW(10),           // 주소 폭 10비트 (기본값)
        .ENTRY(1024),      // 총 엔트리 수 (기본값)
        .WRITE(0),         // 초기 메모리 파일 읽기
        .MEM_FILE("mem.hex") // 초기 메모리 파일 이름
    ) sram_inst (
	    .CLK(CLK),         // 클럭 입력
	    .CSN(~DREQ),         // 칩 선택 입력 (Active Low)
	    .A(DADDR[11:2]),          // 주소 입력
	    .WEN(~DRW),         // 읽기/쓰기 제어 입력
	    .DI(DWDATA),      // 데이터 입력
	    .DOUT(DRDATA)    // 데이터 출력
    );

	
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
            XM_rv2 <= EX_valA;
            XM_instr <= EX_instr;
            XM_iaddr <= EX_iaddr;
	    XM_csn <= (EX_op == `ST || EX_op == `STR || EX_op == `LD || EX_op == `LDR) ? 1 : 0;
	    XM_we <= (EX_op == `ST || EX_op == `STR) ? 1 : 0; // 메모리 쓰기/읽기 신호
	    XM_wer <= (EX_op != `ST && EX_op != `STR && EX_op != `BR && EX_op != `BRL) ? 1 : 0; // 레지스터 기록 신호
        end
    end

    assign DREQ = XM_csn;
    assign DRW = XM_we;
    assign DADDR = XM_aluout[31:2];
    assign DWDATA = XM_rv1;

    /////////////////MEM_WB/////////////////
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
            MW_aluout <= (XM_op == `LD || XM_op == `LDR) ? DRDATA : XM_aluout;
            MW_rv1 <= XM_rv1;
            MW_rv2 <= XM_rv2;
            MW_instr <= XM_instr;
            MW_iaddr <= XM_iaddr;
            MW_wer <= XM_wer;
            MW_we <= XM_we;
        end
    end

    //////////////////WRITEBACK/////////////////
    always @(posedge CLK or negedge RSTN) begin
        if (!RSTN) begin
            WB_instr <= 0;
        end else begin
            if (MW_wer) begin
                WB_instr <= MW_instr;
            end
        end
    end

    always @(posedge CLK or negedge RSTN) begin
        if (!RSTN) begin
            PC <= 0;
        end else if (MW_op == `J || MW_op == `JL) begin
            PC <= MW_iaddr + MW_aluout[29:0];
        end else if ((MW_op == `BR || MW_op == `BRL) && EX_BR_enable) begin
            PC <= MW_rv1[29:0];
        end else begin
            PC <= PC + 1;
        end
    end

endmodule
