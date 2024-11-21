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
wire [31:0] ALU_result;

// ALU 
ALU alu_inst (
    .valA   (DE_valA),         
    .valB   (DE_valB),        
    .offset (DE_offset),      
    .ALUop  (DE_ALUop),        
    .ALUdo  (DE_ALUdo),        
    .Result (ALU_result)       
);

        
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
            LD:   Result = ALUdo ? (valA + {{15{offset[16]}}, offset[16:0}}) : {{15{offset[16]}}, offset[16:0}};
         LDR:  Result = valA+ {{20{offset[21]}}, offset[21:0}};
            ST:   Result = ALUdo ? (valA + {{15{offset[16]}}, offset[16:0}}) : {{15{offset[16]}}, offset[16:0}};
            STR:  Result = valA + {{20{offset[21]}}, offset[21:0]};
         //J,JL,BR,BRL
        J:Result= valA+ {{20{offset[21]}}, offset[21:0]};
        JL:Result=valA+{{20{offset[21]}}, offset[21:0]};
      
                                                                                                         
                                                                                                        

BR:begin
    case (offset)
        0: Result = 0;                 // Never (No operation)
        1: Result = valA;              // Always
        2: Result = (valB == 0) ? valA : 0;  // Zero
        3: Result = (valB != 0) ? valA : 0;  // Nonzero
        4: Result = (valB >= 0) ? valA : 0;  // Plus
        5: Result = (valB < 0) ? valA : 0;   // Minus
        default: Result = 0;           // Default case (safe fallback)
    endcase
end

BRL: begin
    case (offset)
        0: Result = 0;                 // Never (No operation)
        1: Result = valA;              // Always
        2: Result = (valB == 0) ? valA : 0;  // Zero
        3: Result = (valB != 0) ? valA : 0;  // Nonzero
        4: Result = (valB >= 0) ? valA : 0;  // Plus
        5: Result = (valB < 0) ? valA : 0;   // Minus
        default: Result = 0;           // Default case (safe fallback)
    endcase
end

            // Default case
            default: Result = 32'b0;
        endcase
    end
endmodule


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
        
      
 if (EX_op == LD || EX_op == LDR) begin
            // 메모리 읽기
            XM_wer <= 1; //memory 읽기 활성화
            XM_we <= 0;  //쓰기는 X
        end else if (EX_op == ST || EX_op == STR) begin
            // 메모리 쓰기
            XM_wer <= 0; //memory 읽기 X
           XM_we <= 1; // memroy 쓰기 활성 
        end else begin
            XM_wer <= 0;
            XM_we <= 0;

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



endmodule
