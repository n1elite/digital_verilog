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

	reg [4:0] read_address0, read_address1;
	wire [31:0] read_data0, read_data1;
	reg WEN;
	reg [4:0]write_address;
	wire [31:0] write_data;

  ////////////////////
  // 레지스터 파일 모듈 인스턴스화
  ////////////////////
  REGFILE #(.AW(5), .ENTRY(32)) RegFile (
    .CLK    (CLK),
    .RSTN   (RSTN),
	  .WEN    (WEN),
	  .WA     (write_address),
	  .DI     (write_data),
	  .RA0    (read_address0),
	  .RA1    (read_address1),
	  .DOUT0  (read_data0),
	  .DOUT1  (read_data1)
  );
	reg [31:0] instruction;
	reg [4:0] opcode = instruction[31:27];
	reg [31:0] valA;
	reg [31:0] valB;
	reg [31:0] offset; // immeadiate
	reg [4:0] dest;  // destination
	reg [31:0] PC = 0;  // Program Counter
    	reg [31:0] next_PC;
	
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
	
	assign opcode = INSTR[31:27];
	assign IADDR = PC[31:2]; 
    	assign IREQ = 1'b1;  //enable request

  	//////////////
    	// Fetch stage
    	//////////////
    	always @(posedge CLK or negedge RSTN) begin
        	if (!RSTN) begin
            		PC <= 0; // Reset Program Counter
			instruction <= 0;
        	end else begin
            		PC <= next_PC; // Update Program Counter
			instruction <= INSTR;
        	end
    	end
	
	//////////////
	//Decode stage
	//////////////
	always @(posedge CLK or negedge RSTN) begin
		if(!RSTN) begin
			read_address0 <= 0;
			read_address1 <= 0;
			valA <= 0;
			valB <= 0;
			offset <= 0;
			dest <= 0;
			PC <= 0;
		end else begin 
			if(ADDI || ANDI || ORI || LD || ST) begin //MOVI 주의
				read_address0 <= instruction[26:22]; //ra
				read_address1 <= instruction[21:17]; //rb
				valA <= read_data1;//R[ra]
				valB <= read_data0;//R[rb] 
				offset <= {15'b0, instruction[16:0]}; //상수
				dest <= instruction[26:22]; //ra
			end else if(MOVI) begin 
				read_address0 <= INSTR[26:22]; //ra 
				valB <= read_data1; //R[ra]
				offset <= {15'b0, instruction[16:0]}; //imm
				dest <= instruction[26:22]; //ra
			end else if(ADD || SUB || AND || OR || XOR) begin 
				read_address0 <= INSTR[21:17]; //rb
				read_address1 <= INSTR[16:12]; //rc
				valA <= read_data0; //R[rb]
				valB <= read_data1; //R[rc]
				offset <= {15'b0, instruction[26:22]}; //ra
				dest <= instruction[26:22]; //ra
			end else if(NEG || NOT) begin 
				read_address0 <= INSTR[26:22]; //ra
				read_address1 <= INSTR[16:12]; //rc
				valA <= read_data1; //R[rc] 
				valB <= read_data0; //R[ra]
				offset <= {15'b0, instruction[26:22]}; //ra 
				dest <= instruction[26:22]; //ra
			end else if(LSR || ASR || SHL || ROR) begin 
				read_address0 <= instruction[21:17]; //rb
					if (INSTR[5] == 0)
						valB <= instruction[4:0]; //shamt
					else begin
						read_address1 <= instruction[16:12]; //rc
						valB <= read_data1; //R[rc]
					end
				valA <= read_data0; //R[rb]  
				offset <= instruction[26:22]; //ra
				dest <= instruction[26:22]; //ra
		end else if(BR) begin 
			read_address0 <= instruction[21:17]; //rb
			read_address1 <= instruction[16:12]; //rc
			valA <= read_data0; //R[rb]
			valB <= read_data1; //R[rc]
			offset <= instruction[2:0]; //cond
		end else if(BRL) begin 
			read_address0 <= instruction[21:17]; //rb
			read_address1 <= instruction[16:12]; //rc
			valA <= read_data0; //R[rb]
			valB <= read_data1; //R[rc]
			offset <= instruction[2:0]; //cond 
			dest <= instruction[26:22];
		end else if(JL || LDR || STR) begin 
			read_address0 <= instruction[26:22]; //ra
			valA <= PC // 현재 PC
			valB <= read_data0; //R[ra]
			offset <= instruction[21:0]; //imm
			dest <= instruction[26:22]; //ra
		end else if(J) begin 
			valA <= PC // 현재 PC
			offset <= instruction[21:0]; //imm
		end
	end

    ///////////////////////
    // Program Counter 
    ///////////////////////
	always @(posedge clk or negedge RSTN) begin
        	if (!RSTN) begin
            		next_PC = 0;
        	end else if (J || JL) begin
			next_PC = PC + offset; // Jump with offset
        	end else if (BR || BRL) begin
			if (valA == valB) begin  // ALU에서 비교한 리턴값 보내주면 조건 대체
                		next_PC = read_data0; // Branch if condition is met
            		end else begin
                		next_PC = PC + 4; // Increment to next instruction
            	end
        	end else begin
            		next_PC = PC + 4; // Default: increment by 4 (next instruction)
        	end
    	end


endmodule
`default_nettype wire
