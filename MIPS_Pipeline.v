module MIPS_Pipeline
(
	clk, 
	rst_n,
	ICACHE_addr,
	ICACHE_rdata,
	ICACHE_ren,
	ICACHE_wen,
	ICACHE_wdata,
	ICACHE_stall,
	DCACHE_addr,
	DCACHE_rdata,
	DCACHE_ren,
	DCACHE_wen,
	DCACHE_wdata,
	DCACHE_stall
);
//==== in/out declaration =================================
	input  clk;
	input  rst_n;
	input  [29:0] ICACHE_addr;
	input  [31:0] ICACHE_rdata;
	input  ICACHE_ren;
	input  ICACHE_wen;
	input  [31:0] ICACHE_wdata;
	input  ICACHE_stall;

	output [29:0] DCACHE_addr;
	output [31:0] DCACHE_rdata;
	output DCACHE_ren;
	output DCACHE_wen;
	output [31:0] DCACHE_wdata;
	output DCACHE_stall;
//==== combinational part =================================

//==== sequential part ====================================

endmodule

module register_file(
    Clk  ,
	rst_n,
    WEN  ,
    RW   ,
    busW ,
    RX   ,
    RY   ,
    busX ,
    busY
);
    input        Clk, rst_n, WEN;
    input  [4:0] RW, RX, RY;
    input  [31:0] busW;
    output reg[31:0] busX, busY;
    integer i;
    reg[31:0] register[0:31];
	always@(*)begin
		busX = register[RX];
		busY = register[RY];
	end	
	always@(posedge Clk or negedge rst_n) begin
		if(!rst_n)
			for(i=0;i<=31;i=i+1)
				register[i]<=0;		
		else if(WEN)
			register[RW]<=busW;
	end
endmodule

module control(
	op ,
	func ,
	RegDst ,
	Jump ,
	JR ,
	JAL,
	Branch ,
	MemRead ,
	MemtoReg ,
	ALUOp ,
	MemWrite ,
	ALUSrc ,
	RegWrite
);
	input  [5:0] op;//op
	input  [5:0] func;//func included only to determine jr :/
	output RegDst,Jump,JR,JAL,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite;
	output [3:0] ALUOp;
	assign RegDst  = (op==6'd0)   ? 1:0;
	assign Jump    = (op==6'd2 || op==6'd3)   ? 1:0;
	assign JR	   = (op==6'd0 && func==6'd8) ? 1:0;
	assign JAL     = (op==6'd3)   ? 1:0;
	assign Branch  = (op==6'd4)   ? 1:0;
	assign MemRead = (op==6'd35)  ? 1:0;
	assign MemtoReg= (op==6'd35)  ? 1:0;
	assign ALUOp   = (op==6'd4)   ? 4'd1://beq
					 (op==6'd0)   ? 4'd2://R-format
					 (op==6'd8)   ? 4'd3://addi
					 (op==6'd10)  ? 4'd4://slti
					 (op==6'd12)  ? 4'd5://andi
					 (op==6'd13)  ? 4'd6://ori
					 (op==6'd14)  ? 4'd7://xori
					 (op==6'd35)  ? 4'd0://lw
					 (op==6'd43)  ? 4'd0://sw
									  0 ;
	assign MemWrite= (op==6'd43)  ? 1:0;
	assign ALUSrc  = (op==6'd35 || op==6'd43)  ? 1:0;
	assign RegWrite= (op==6'd4  || op==6'd43)  ? 0:1; // only beq and sw has RegWrite = 0 (not so sure @@)
endmodule

module alu_control(
	func ,
	ALUOp,
	out
);
	input  [5:0] func;
	input  [3:0] ALUOp; 
	output reg [3:0] out;
	always@(*)begin
		case(ALUOp)
			4'd0:	out = 4'd2;//lw,sw, using add
			4'd1:   out = 4'd6;//beq,   using sub
			4'd2:	out = (func==6'd0 )? 4'd3:// SLL
						  (func==6'd2 )? 4'd4:// SRL
						  (func==6'd3 )? 4'd5:// SRA
						  (func==6'd27)? 4'd12:// NOR
						  (func==6'd32)? 4'd2:// add
						  (func==6'd34)? 4'd6:// sub
						  (func==6'd36)? 4'd0:// AND
						  (func==6'd37)? 4'd1:// OR
						  (func==6'd40)? 4'd13:// XOR
						  (func==6'd42)? 4'd7:// less than
							               0;
			4'd3:	out = 4'b0010;//addi
			4'd4:	out = 4'b0111;//slti
			4'd5:	out = 4'b0000;//andi
			4'd6:	out = 4'b0001;//ori
			4'd7:	out = 4'b1101;//xori
		endcase
	end
endmodule

module alu(
    ctrl,
    x,
    y,
	shamt,// newly added input, derived ins[10:6]
    zero,
    out  
);
    input  [3:0] ctrl;
    input  [31:0] x;
    input  [31:0] y;
	input  [4:0] shamt;
    output        zero;
    output [31:0] out;
    wire   [31:0] add,sub;
	wire   [31:0] negy;
	wire   [31:0] sll,sra,srl;
	assign add  	= x+y;
	assign negy 	= ~y+32'd1;
	assign sub  	= x+negy;
	assign zero 	= (x==y)?1:0;
	assign sll  	= y<<shamt;
	assign srl      = y>>shamt;
	assign sra      = y>>>shamt;
	assign out  	= (ctrl==4'd0) 		 ? x&y        :
					  (ctrl==4'd1) 		 ? x|y        :
				      (ctrl==4'd2) 		 ? add[31:0]  :
					  (ctrl==4'd3)       ? sll        :
					  (ctrl==4'd4)       ? srl        :
					  (ctrl==4'd5)       ? sra        :
				      (ctrl==4'd6)  	 ? sub[31:0]  :
				      (ctrl==4'd7 && x<y)? 1          :
				      (ctrl==4'd12)    	 ? ~(x|y)     :
				      (ctrl==4'd13)      ? x^y        :
						       			   0	      ;	
endmodule
