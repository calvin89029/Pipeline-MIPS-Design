
// this is a test bench feeds initial instruction and data
// the processor output is not verified

`timescale 1 ns/10 ps

`define CYCLE 5 // You can modify your clock frequency

`define IMEM_INIT "I_mem"
`define DMEM_INIT "D_mem"
`define SDFFILE   "./CHIP.sdf"	// Modify your SDF file name


module Final_tb;

	reg clk;
	reg slow_clk;
	reg rst_n;
	
	wire mem_read_D;
	wire mem_write_D;
	wire [31:4] mem_addr_D;
	wire [127:0] mem_wdata_D;
	wire [127:0] mem_rdata_D;
	wire mem_ready_D;

	wire mem_read_I;
	wire mem_write_I;
	wire [31:4] mem_addr_I;
	wire [127:0] mem_wdata_I;
	wire [127:0] mem_rdata_I;
	wire mem_ready_I;
	
	wire [29:0]	DCACHE_addr;
	wire [31:0]	DCACHE_wdata;
	wire 		DCACHE_wen;
	
	wire [7:0] error_num;
	wire [15:0] duration;
	wire finish;	

	// Note the design is connected at testbench, include:
	// 1. CHIP (MIPS + D_cache + I_chache)
	// 2. slow memory for data
	// 3. slow memory for instruction
	
	CHIP chip0 (	
				mem_read_D,
				mem_write_D,
				mem_addr_D,
				mem_rdata_D,
				mem_wdata_D,
				mem_ready_D,
				mem_read_I,
				mem_write_I,
				mem_addr_I,
				mem_rdata_I,
				mem_wdata_I,
				mem_ready_I,
				clk,
				rst_n,
				DCACHE_addr,
				DCACHE_wdata,
				DCACHE_wen
				);
	
	slow_memory slow_memD(
		clk,
		mem_read_D,
		mem_write_D,
		mem_addr_D,
		mem_wdata_D,
		mem_rdata_D,
		mem_ready_D
	);

	slow_memory slow_memI(
		clk,
		mem_read_I,
		mem_write_I,
		mem_addr_I,
		mem_wdata_I,
		mem_rdata_I,
		mem_ready_I
	);
	
	TestBed testbed(
	.rst(rst_n),
	.clk(clk),
	.addr(DCACHE_addr),
	.data(DCACHE_wdata),
	.wen(DCACHE_wen),
	.error_num(error_num),
	.duration(duration),
	.finish(finish),
	.stall(DCACHE_stall)
	);
	
    initial $sdf_annotate(`SDFFILE, chip0);
	
	
// Initialize the data memory
	initial begin
		$readmemb (`DMEM_INIT, slow_memD.mem ); // initialize data in DMEM
		$readmemb (`IMEM_INIT, slow_memI.mem ); // initialize data in IMEM
		
		$fsdbDumpfile("Final.fsdb");			
		$fsdbDumpvars(0,Final_tb,"+mda");

		clk = 0;
		slow_clk = 0;

		rst_n = 1'b1;
		#2 rst_n = 1'b0;
		#(`CYCLE*8.5) rst_n = 1'b1;
     
		#(`CYCLE*100000)	 $finish; // you have to calculate clock cycles for all operation

	end
		
	always #(`CYCLE*0.5) clk = ~clk;
	
	always@(finish)
	    if(finish)
	       #(`CYCLE) $finish;		   
	
endmodule