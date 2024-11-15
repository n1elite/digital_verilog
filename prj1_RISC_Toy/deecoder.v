`timescale 1ns/1ps
`default_nettype none

module decoder (
  input wire CLK,
  input wire RSTN,
  input wire DECODER_ENABLED,
  input wire [31:0] INSTRUCTION,
  input wire [31:0] PC,
  output wire CONDITIONAL_JUMP,
  output reg [1:0] FOR_INFO,
  output reg [32:0] CTR_INFO,
  output wire [31:2] IADDR,
  output wire IREQ
);

// 명령어 필드 추출
wire [4:0] opcode = INSTRUCTION[31:27];
wire [4:0] ra = INSTRUCTION[26:22]; // rd
wire [4:0] rb = INSTRUCTION[21:17]; // rs1
wire [4:0] rc = INSTRUCTION[16:12]; // rs2
wire [2:0] Imm = INSTRUCTION[11:5];
wire [2:0] cond = INSTRUCTION[2:0];
wire [4:0] shamt = INSTRUCTION[4:0];
wire i = INSTRUCTION[5];

// RISC-V 명령어 유형 구분
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

// 레지스터 선택
wire [4:0] RS1 = (ADDI || ANDI || BR || BRL || ST || LD || ROR || SHL || ASR || LSR || XOR || OR || AND || SUB || ADD || ORI) ? rb : 5'b0;
wire [4:0] RS2 = (ADD || SUB || NEG || NOT || AND || OR || XOR || LSR || ASR || SHL || ROR || BR || BRL) ? rc : 5'b0;
wire [4:0] RD = (BR || J) ? 5'b0 : ra;

// 즉시 값 생성
wire [21:0] IMMEDIATE = (ADDI || ANDI || ORI || MOVI || LD || ST) ? {4'b0, INSTRUCTION[16:0]} :
                        (J || JL || LDR || STR) ? INSTRUCTION[21:0] : 22'b0;

// 조건부 점프 명령어 식별
wire is_conditional_jump = (BR || BRL || J || JL);
assign CONDITIONAL_JUMP = is_conditional_jump;

// 프로그램 카운터
reg [31:0]pc;
assign IADDR = pc[31:2];
assign IREQ = 1;

// 이전 레지스터 저장 (파이프라인의 데이터 전달을 위해)
reg [4:0] prev_rd;

always @(posedge CLK or negedge RSTN) begin
  if (!RSTN) begin
    prev_rd <= 5'b0;
    FOR_INFO <= 32'b0;
    pc <= PC;
  end else if (DECODER_ENABLED) begin
    // 명령어 가져오기 단계
    pc <= pc + 4;
    // 전달 체크 - forwarding
    FOR_INFO[0] <= (prev_rd == RS1) ? 1'b1 : 1'b0;
    FOR_INFO[1] <= (prev_rd == RS2) ? 1'b1 : 1'b0;
    prev_rd <= RD;
    // 명령어 정보 저장
  end else if (ADDI || ANDI || ORI || LD || ST || MOVI)
    CTR_INFO <= {opcode, RD, RS1, IMMEDIATE[16:0]};
  else if (ADD || SUB || AND || OR || XOR || NEG || NOT)
    CTR_INFO <= {opcode, RD, RS1, RS2, IMMEDIATE[11:0]};
  else if (LSR || ASR || SHL || ROR)
    CTR_INFO <= {opcode, RD, RS1, RS2, 6'b0, i, shamt};
  else if (BR || BRL)
    CTR_INFO <= {opcode, RD, RS1, RS2, 9'b0, cond};
  else if (J || JL || LDR || STR)
    CTR_INFO <= {opcode, RD, IMMEDIATE};
end

endmodule

`default_nettype wire
