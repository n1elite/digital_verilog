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
    //.valB(alu_va언 Result=
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
