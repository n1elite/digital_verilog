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


    //*************************************************************************************************
    //추가변수 여기에 할당해주세요~~~!
    //*************************************************************************************************


    /////////////////IF///////////////// (초기값 설정 레지) 없어도 된다고 생각하면 제거 하셔도 됩니다
    reg [4:0] IF_ra, IF_rb, IF_rc, IF_op;
    reg [31:0] IF_instr;
    reg [29:0] IF_iaddr;
    
    
    /////////////////IF_ID/////////////////
    reg [4:0] FI_ra, FI_rb, FI_rc, FI_op                        // rega add _ regb add _ regc add _ opcode
    reg [31:0] FI_instr;                                        // 명령어
    reg [29:0] FI_iaddr;                                        // 명령어 add
    wire [31:0] FI_rv1, FI_rv2;


    //reg FI_wer;                                                  // 레지스터 저장 정보가 맨마지막에 여기로 수렴되서 나중에 스톨 생각하면 여기에 enable신호가 올 수 도 있겠다고 생각해서 reg 추가합니다 

    /////////////////DECODER/////////////////
	wire ADDI = (opcode == 5'b00000);
	wire ANDI = (opcode == 5'b00001);
	wire ORI = (opcode == 5'b00010);
	wire MOVI = (opcode == 5'b00011);
	wire ADD = (opcode == 5'b00100);
	wire SUB = (opcode == 5'b00101);
	wire NEG = (opcode == 5'b00110);
	wire NOT = (opcode == 5'b00111);
	wire AND = (opcode == 5'b01000);
	wire OR = (opcode == 5'b01001);
	wire XOR = (opcode == 5'b01010);
	wire LSR = (opcode == 5'b01011);
	wire ASR = (opcode == 5'b01100);
	wire SHL = (opcode == 5'b01101);
	wire ROR = (opcode == 5'b01110);
	wire BR = (opcode == 5'b01111);
	wire BRL = (opcode == 5'b10000);
	wire J = (opcode == 5'b10001);
	wire JL = (opcode == 5'b10010);
	wire LD = (opcode == 5'b10011);
	wire LDR = (opcode == 5'b10100);
	wire ST = (opcode == 5'b10101);
	wire STR = (opcode == 5'b10110);



    /////////////////ID_EX/////////////////
    reg [4:0] DE_ra, DE_rb, DE_rc, DE_op;                       // rega add _ regb add _ regc add _ opcode
    reg [31:0] DE_rv1, DE_rv2, DE_imm;                          // valA _ valB _ offset 
    reg [31:0] DE_instr;                                        // 명령어
	reg [29:0] DE_iaddr;                                        // 명령어 add
    reg DE_we, DE_wer;                                          // DREQ가 될 녀석, IREQ가 될 녀석   (write enalbe / write enable reg)
    

    /////////////////EX_MEM/////////////////

    reg [4:0] XM_op, XM_ra;                                     // opcode 5bit _ dest reg add
    reg [31:0] XM_aluout, XM_rv1, XM_rv2, XM_instr;             // alu result _ valA _ valB _ 명령어
    reg [29:0] XM_iaddr;                                        // instruction add (PC) => DADDR

    reg XM_we, XM_wer;  // 계산 결과가 여기서 나올꺼라 여기서 설정해놔야 함 reg write는 굳이 mem 안가도 될꺼 같고...

    // in  XM_iaddr, XM_rv1, XM_rv2, XM_ra
    // out XM_aluout, XM_rv2, XM_instr*



    /////////////////MEM_WB/////////////////

    reg [4:0] MW_op, MW_ra;                                     // opcode 5bit _ dest reg add
    reg [31:0] MW_aluout, MW_rv1, MW_rv2, MW_instr, WB_instr;   // alu result _ valA _ valB _ 어떤 계산 _ 어떤 계산
    reg [29:0] MW_iaddr;                                        // P
    reg MW_wer, MW_we;  // 계산 결과 이어받음 이게 mem에 연결되서 wer에서 enable되면 reg에 저장하고 we에서 enable되면 mem에 저장






    //clock code**********************

//







    // REGISTER FILE FOR GENRAL PURPOSE REGISTERS
    REGFILE    #(.AW(5), .ENTRY(32))    RegFile (
                    .CLK    (CLK),
                    .RSTN   (RSTN),
                    .WEN    (XM_wer),
                    .WA     (regwriteaddr),
                    .DI     (regwritedata),
                    .RA0    (regreadaddr0),
                    .RA1    (regreadaddr1),
                    .DOUT0  (),
                    .DOUT1  ()
    );

    //regwriteaddr와 regwritedata 구현
    wire [31:0] regwritedata;
    wire [4:0] regwriteaddr;

    assign regwritedata = ((XM_instr[31:27] == 5'b10000) | (XM_instr[31:27] == 5'b10010)) ? (DE_iaddr + 4) : 
    ((XM_instr[31:27] == 5'd19) | (XM_instr[31:27] == 5'd20) ? DRDATA : XM_aluout);

    assign regwriteaddr = ((XM_instr[31:27] == 5'b10000) | (XM_instr[31:27] == 5'b10010)) ? XM_instr[26:22] : 
    ((XM_instr[31:27] == 5'd19) | (XM_instr[31:27] == 5'd20) ? XM_ra: XM_ra);

    // WRITE YOUR CODE



    /////////////////DECODER/////////////////
	// always @(posedge CLK or negedge RSTN) begin
	// 	if(!RSTN) begin
	// 		regreadaddr0 <= 0;
	// 		regreadaddr1 <= 0;
	// 		INSTR <= 0;
	// 		valA <= 0;
	// 		valB <= 0;
	// 		offset <= 0;
	// 		dest <= 0;
	// 	end else if(ADDI || ANDI || ORI || LD || ST || MOVI) begin //MOVI 주의
	// 		regreadaddr0 <= INSTR[26:22];
	// 		regreadaddr1 <= INSTR[21:17];
	// 		valA <= read_data1; valB <= read_data0; 
	// 		offset <= {15'b0, INSTR[16:0]}; dest <= INSTR[26:22];
	// 	end else if(ADD || SUB || AND || OR || XOR || NEG || NOT) begin 
	// 		//NEG, NOT 주의
	// 		regreadaddr0 <= INSTR[21:17];
	// 		regreadaddr1 <= INSTR[16:12];
	// 		valA <= read_data0; valB <= read_data1; 
	// 		offset <= {15'b0, INSTR[26:22]}; dest <= INSTR[26:22];
	// 	end else if(LSR || ASR || SHL || ROR) begin 
	// 		regreadaddr0 <= INSTR[21:17];
	// 		if (INSTR[5] == 0)
	// 			valB <= INSTR[4:0];
	// 		else begin
	// 			regreadaddr1 <= INSTR[16:12];
	// 			valB <= read_data1;
	// 		end
	// 		valA <= read_data0;  
	// 		offset <= INSTR[26:22]; dest <= INSTR[26:22];
	// 	end else if(BR || BRL) begin 
	// 		regreadaddr0 <= INSTR[21:17];
	// 		regreadaddr1 <= INSTR[16:12];
	// 		valA <= read_data0; valB <= read_data1; 
	// 		//offset <= INSTR[26:22]; dest <= INSTR[26:22];
	// 	end else if(J || JL || LDR || STR) begin 
	// 		regreadaddr0 <= INSTR[21:17];
	// 		regreadaddr1 <= INSTR[16:12];
	// 		//valA <= read_data0; valB <= read_data1; 
	// 		offset <= INSTR[21:0]; dest <= INSTR[21:0];
    //     end
	// end

module ALU (
    input signed [31:0] valA,   // 레지스터 A 값
    input signed [31:0] valB,   // 레지스터 B 값
    input signed [31:0] offset, // Immediate 값
    input [4:0] ALUop,          // ALU 연산 코드
    input ALUdo,                // ALU 실행 제어 신호
    output reg signed [31:0] Result // 연산 결과
);
    parameter
        ADDI = 5'b00000, ANDI = 5'b00001, ORI = 5'b00010, MOVI = 5'b00011, ADD = 5'b00100,
        SUB = 5'b00101, NEG = 5'b00110, NOT = 5'b00111, AND = 5'b01000, OR = 5'b01001,
        XOR = 5'b01010, LSR = 5'b01011, ASR = 5'b01100, SHL = 5'b01101, ROR = 5'b01110,
        LD = 5'b10011, LDR = 5'b10100, ST = 5'b10101, STR = 5'b10110;

    always @(*) begin
        case (ALUop)
            // Immediate 연산
            ADDI: Result = valB + {{15{offset[16]}}, offset[16:0}};
            ANDI: Result = valB & {{15{offset[16]}}, offset[16:0}};
            ORI:  Result = valB | {{15{offset[16]}}, offset[16:0}};
            MOVI: Result = {{15{offset[16]}}, offset[16:0}};

            // Register 간 연산
            ADD:  Result = valA + valB;
            SUB:  Result = valA - valB;
            NEG:  Result = -valB;
            NOT:  Result = ~valB;
            AND:  Result = valA & valB;
            OR:   Result = valA | valB;
            XOR:  Result = valA ^ valB;

            // Shift 연산
            LSR:  Result = valA >> valB[4:0];
            ASR:  Result = valA >>> valB[4:0];
            SHL:  Result = valA << valB[4:0];
            ROR:  Result = (valA >> valB[4:0]) | (valA << (32 - valB[4:0]));

            // Load/Store 연산
            LD:   Result = ALUdo ? (valB + {{15{offset[16]}}, offset[16:0}}) : {{15{offset[16]}}, offset[16:0}};
            LDR:  Result = valB + {{15{offset[16]}}, offset[16:0}};
            ST:   Result = ALUdo ? (valB + {{15{offset[16]}}, offset[16:0}}) : {{15{offset[16]}}, offset[16:0}};
            STR:  Result = valB + {{15{offset[16]}}, offset[16:0}};

            // Default case
            default: Result = 32'b0;
        endcase
    end
endmodule





    /////////////////IF_ID/////////////////


    //위에 디코더를 통해 IF에서 ID를 이어주는 작업이 필요합니다~


    /////////////////ID_EX/////////////////
    always @(posedge CLK or negedge RSTN) begin
        if(~RSTN) begin
            DE_ra <= 0;
            DE_rb <= 0;
            DE_rc <= 0;
            DE_op <= 0;
            DE_imm <= 0;
            DE_we <= 0;
            DE_wer <= 0;
            DE_rv1 <= 0;
            DE_rv2 <= 0;
            DE_instr <= 0;
            DE_iaddr <= 0;
        end


//코드 추가

    end




    /////////////////EX_MEM/////////////////
    always @(posedge CLK or negedge RSTN) begin
        if(~RSTN) begin
            XM_op <= 0;
            XM_we <= 0;
            XM_wer <= 0;
            XM_rv1 <= 0;
            XM_rv2 <= 0;
            XM_ra <= 0;
            XM_aluout <= 0;
            XM_iaddr <= 0;
            XM_instr <= 0;
        end
        else begin
            XM_op <= DE_op;
            XM_we <= DE_we;
            XM_wer <= DE_wer;
            XM_rv1 <= DE_rv1;
            XM_rv2 <= DE_rv2;
            XM_ra <= DE_ra;
            XM_aluout <= ;                                     //여기 ALU에서 나온 값으로 대체!
            XM_iaddr <= DE_iaddr;
            XM_instr <= DE_instr;
        end 
    end

    assign DWDATA = DRW ? XM_rv2 : 0;
    assign DADDR = XM_aluout : // ALU_OUT********
    assign DRW = ~XM_we;

    /////////////////MEM_WB/////////////////
    always @(posedge CLK or negedge RSTN) begin
        if(~RSTN) begin
            MW_op <= 0;
            MW_we <= 0;
            MW_wer <= 0;
            MW_ra <= 0;
            MW_rv1 <= 0;
            MW_rv2 <= 0;
            MW_aluout <= 0;
            MW_iaddr <= 0;
            MW_instr <= 0;
        end
        else begin
            MW_op <= XM_op;
            MW_we <= XM_we;
            MW_wer <= XM_wer;
            MW_ra <= XM_ra;
            MW_rv1 <= XM_rv1;
            MW_rv2 <= XM_rv2;
            MW_aluout <= XM_aluout;
            MW_iaddr <= XM_iaddr;
            MW_instr <= XM_instr;
        end
    end


endmodule
