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


//MUX////

wire [31:0]A,B; wire signed [31:0]Imm; //Immediate Signed Extension

assign A= EX_ALUsigA? EX_PC:EX_data0; 
assign B= EX_ALUsigB? EX_shamt:EX_data1;
assign Imm=EX_ALUImm? EX_22:EX_17;

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
