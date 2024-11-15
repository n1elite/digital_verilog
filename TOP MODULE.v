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
  // 주요 구성 요소
  ////////////////////
  // 현재 명령어 주소를 추적하는 프로그램 카운터 (PC)
  reg [31:0] pc;
  // 명령어를 임시로 저장하는 레지스터
  reg [31:0] instruction;

  // 파이프라인 단계에 대한 제어 플래그
  reg decoder_enabled;
  reg executer_enabled;
  reg writer_enabled;
  reg [3:0] conditional_jump_count;

  ////////////////////
  // 출력 신호
  ////////////////////
  assign IADDR = pc[31:2];
  assign IREQ = 1;

  ////////////////////
  // 초기 값 설정
  ////////////////////
  integer reg_index;
  initial begin
    pc <= 0;
    decoder_enabled <= 1;
    executer_enabled <= 1;
    writer_enabled <= 1;
    conditional_jump_count <= 3'b0;
  end

  ////////////////////
  // 명령어 가져오기 (IF) 단계
  ////////////////////
  always @(posedge CLK or negedge RSTN) begin
    if (!RSTN) begin
      pc <= 0;
      conditional_jump_count <= 0;
      decoder_enabled <= 1;
    end else begin
      instruction <= INSTR;
	 decoder (
    .CLK(CLK),
    .RSTN(RSTN),
    .decoder_enabled(decoder_enabled),
    .instruction(IF_ID_INSTR),
    .pc(IF_ID_PC),
    .register_file(register_file),
    .ID_EX_PC(ID_EX_PC),
    .ID_EX_INSTR(ID_EX_INSTR),
    .ID_EX_REG_A(ID_EX_REG_A),
    .ID_EX_REG_B(ID_EX_REG_B)
  );
      if (conditional_jump_count == 0) begin
        pc <= pc + 4;
      end else if (conditional_jump_count == 1) begin
        conditional_jump_count <= 2;
        pc <= EX_MEM_ALU_RESULT - 4;
      end else if (conditional_jump_count == 2) begin
        conditional_jump_count <= 0;
        decoder_enabled <= 1;
        pc <= pc + 4;
      end else begin
        pc <= pc + 4;
      end
    end
  end

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

  ////////////////////
  // 명령어 디코드 (ID) 단계
  ////////////////////
  decoder (
    .CLK(CLK),
    .RSTN(RSTN),
    .decoder_enabled(decoder_enabled),
    .instruction(IF_ID_INSTR),
    .pc(IF_ID_PC),
    .register_file(register_file),
    .ID_EX_PC(ID_EX_PC),
    .ID_EX_INSTR(ID_EX_INSTR),
    .ID_EX_REG_A(ID_EX_REG_A),
    .ID_EX_REG_B(ID_EX_REG_B)
  );

  ////////////////////
  // 실행 (EX) 단계
  ////////////////////
  excute (
    .CLK(CLK),
    .RSTN(RSTN),
    .executer_enabled(executer_enabled),
    .ID_EX_REG_A(ID_EX_REG_A),
    .ID_EX_REG_B(ID_EX_REG_B),
    .EX_MEM_ALU_RESULT(EX_MEM_ALU_RESULT),
    .EX_MEM_REG_B(EX_MEM_REG_B)
  );

  ////////////////////
  // 메모리 접근 (MEM) 단계
  ////////////////////
  mem (
    .CLK(CLK),
    .RSTN(RSTN),
    .EX_MEM_ALU_RESULT(EX_MEM_ALU_RESULT),
    .EX_MEM_REG_B(EX_MEM_REG_B),
    .DADDR(DADDR),
    .DREQ(DREQ),
    .DRW(DRW),
    .DWDATA(DWDATA),
    .DRDATA(DRDATA),
    .MEM_WB_ALU_RESULT(MEM_WB_ALU_RESULT),
    .MEM_WB_MEM_DATA(MEM_WB_MEM_DATA)
  );

  ////////////////////
  // 쓰기 (WB) 단계
  ////////////////////
  wb (
    .CLK(CLK),
    .RSTN(RSTN),
    .writer_enabled(writer_enabled),
    .MEM_WB_ALU_RESULT(MEM_WB_ALU_RESULT),
    .MEM_WB_MEM_DATA(MEM_WB_MEM_DATA),
    .ID_EX_INSTR(ID_EX_INSTR),
    .register_file(register_file)
  );

endmodule
`default_nettype wire

