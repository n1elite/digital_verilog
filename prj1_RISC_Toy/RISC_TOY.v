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


// ALU	
module ALU (
input signed [31:0]A,
input signed [31:0]B,
input signed [31:0]Imm,
input  [4:0]ALUop, //ALU operate determine
input ALUdo,//ALU execution sign
output reg signed [31:0]Result,
);
parameter
ADDI=5'b00000, ANDI=5'b00001,ORI=5'b00010,MOVI=5'b00011, ADD=5'b00100,
SUB=5'b00101, NEG=5'b00110, NOT=5'b00111, AND=5'b01000, OR=5'b01001, XOR=5'b01010,
LSR=5'b01011, ASR=5'b01100, SHL=5'b01101, ROR=5'b01110, BR=5'b01111, BRL=5'b10000,
J=5'b10001, JL=5'b10010, LD=5'b10011, LDR=5'b10100, ST=5'b10101, STR=5'b10110;

always@(posedge CLK)
case(ALUop)
ADDI:RESULT=A+Imm;
ANDI:RESULT=A&Imm;
ORI:RESULT=A|Imm;
MOVI:RESULT=Imm;
ADD:RESULT=A+B;	
SUB:RESULT=A-B;
NEG:RESULT=-B;
NOT:RESULT=~B;
AND:RESULT=A%B;
OR:RESULT=A|B;
XOR:RESULT=A^B;
LSR:RESULT=A>>B[4:0];
ASR:RESULT=A>>>B[4:0];
SHL:RESULT=A<<B[4:0];
ROR:RESULT=
BR:RESULT=
BRL:RESULT=
J:RESULT=
JL:RESULT=
LD:RESULT=ALUdo? (A+Imm):Imm;
LDR:RESULT=A+Imm;
ST:RESULT=ALUdo?(A+Imm):Imm;
STR:RESULT=A+Imm;


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
