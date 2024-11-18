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
    parameter
        
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
        // LDR:  Result = valA+ {{20{offset[21]}}, offset[21:0}};
            ST:   Result = ALUdo ? (valA + {{15{offset[16]}}, offset[16:0}}) : {{15{offset[16]}}, offset[16:0}};
            //수정필요,valA=pc 값으로 설정 STR:  Result = valA + {{20{offset[21]}}, offset[21:0]};
         //J,JL,BR,BRL
        J:Result= valA+ {{20{offset[21]}}, offset[21:0]};
        JL:Result=valA+{{20{offset[21]}}, offset[21:0]};
      // 헷갈림  
                                                                                                         
                                                                                                        
BR:
Result=
       if(offset == 0) // Never 
    
       else if(offset == 1) // Always     
            PC = valA;
                                                                                                         
       else if(offset== 2)  //Zero 
           if(valB == 0)
            PC = valA;
                                                                                                            
     else if(offset == 3) // Nonzero 
           if(valB!= 0)
           PC = valA;
                                                                                                               
    else if(offset== 4) // Plus 
          if(valB >= 0)
          PC = valA;
                                                                                                                    
  else if(offset == 5) // Minus 
          if(valB < 0)
         PC = valA;
        
BRL:
//이부분 PC 값 할당만 하면됨. 코드맞는지도 체크 하기  
     
Result=
 if(offset == 0) // Never 
    else if(offset == 1) // Always
        PC = valA;
    else if(offset == 2)   //Zero 
        if(valB == 0)
        PC = valA;
    else if(offset == 3) // Nonzero
        if(valB != 0)
        PC =valA;
    else if(offset == 4) // Plus 
        if(valB >= 0)
        PC =valA;
    else if(offset == 5)  // Minus 
        if(valB < 0)
        PC = valA;


            // Default case
            default: Result = 32'b0;
        endcase
    end
endmodule






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
