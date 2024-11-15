`timescale 1ns/1ps
`default_nettype none

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



  ////////////////////
  // 레지스터 파일 모듈 인스턴스화
  ////////////////////
  REGFILE #(.AW(5), .ENTRY(32)) RegFile (
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
	reg [4:0]opcode <= INSTR[31:27];
	
 
endmodule
`default_nettype wire

