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
	
	////////// EX_MEM //////////

    reg [4:0] XM_op, XM_ra;                                    // opcode 5bit _ dest reg add
    reg [31:0] XM_aluout, XM_rv1, XM_rv2, XM_instr;            // alu result _ valA _ valB _ caculate store
    reg [29:0] XM_iaddr;                                       // instruction add (PC) => DADDR

    reg XM_we, XM_wer;  // 계산 결과가 여기서 나올꺼라 여기서 설정해놔야 함 reg write는 굳이 mem 안가도 될꺼 같고...

    // in  XM_iaddr, XM_rv1, XM_rv2, XM_ra
    // out XM_aluout, XM_rv2, XM_instr*



    ////////// MEM_WB //////////

    reg [4:0] MW_op, MW_ra;                                     // opcode 5bit _ dest reg add
    reg [31:0] MW_aluout, MW_rv1, MW_rv2, MW_instr, WB_instr;   // alu result _ valA _ valB _ 어떤 계산 _ 어떤 계산
    reg [29:0] MW_iaddr;                                        // P
    reg MW_wer, MW_we;  // 계산 결과 이어받음 이게 mem에 연결되서 wer에서 enable되면 reg에 저장하고 we에서 enable되면 mem에 저장






    // REGISTER FILE FOR GENRAL PURPOSE REGISTERS
    REGFILE    #(.AW(5), .ENTRY(32))    RegFile (
                    .CLK    (CLK),
                    .RSTN   (RSTN),
                    .WEN    (XM_wer),
                    .WA     (regwriteaddr),
                    .DI     (regwritedata),
                    .RA0    (),
                    .RA1    (),
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
            XM_op <= ;      //  ex 받아온 opcode
            XM_we <= ;      //  ex 받아온
            XM_wer <= ;
            XM_rv1 <= ;
            XM_rv2 <= ;
            XM_ra <= ;
            XM_aluout <= ;
            XM_iaddr <= ;
            XM_instr <= ;
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
