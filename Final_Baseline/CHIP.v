// Top module of your design, you cannot modify this module!!
module CHIP (	mem_read_D,
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

output			mem_read_I;
output			mem_write_I;
output	[31:4]	mem_addr_I;
input	[127:0]	mem_rdata_I;
output	[127:0]	mem_wdata_I;
input			mem_ready_I;

output			mem_read_D;
output			mem_write_D;
output	[31:4]	mem_addr_D;
input	[127:0]	mem_rdata_D;
output	[127:0]	mem_wdata_D;
input			mem_ready_D;

input			clk, rst_n;

// For testbench check
output	[29:0]	DCACHE_addr;
output	[31:0]	DCACHE_wdata;
output			DCACHE_wen;

// wire declaration

wire [29:0] ICACHE_addr;
wire [31:0] ICACHE_rdata;
wire ICACHE_ren;
wire ICACHE_wen;
wire [31:0] ICACHE_wdata;
wire ICACHE_stall;

wire [29:0] DCACHE_addr;
wire [31:0] DCACHE_rdata;
wire DCACHE_ren;
wire DCACHE_wen;
wire [31:0] DCACHE_wdata;
wire DCACHE_stall;
	
//=========================================
	// Note that the overall design of your MIPS includes:
	// 1. pipelined MIPS processor
	// 2. data cache
	// 3. instruction cache


	MIPS_Pipeline i_MIPS(
		// control interface
		clk, 
		rst_n,
		
		//I cache interface
		ICACHE_addr,
		ICACHE_rdata,
		ICACHE_ren,
		ICACHE_wen,
		ICACHE_wdata,
		ICACHE_stall,
	
		//D cache interface
		DCACHE_addr,
		DCACHE_rdata,
		DCACHE_ren,
		DCACHE_wen,
		DCACHE_wdata,
		DCACHE_stall
	);
	
	cache D_cache(
		clk,
		~rst_n,
		
		DCACHE_ren,
		DCACHE_wen,
		DCACHE_addr,
		DCACHE_rdata,
		DCACHE_wdata,
		DCACHE_stall,
		
		mem_read_D,
		mem_write_D,
		mem_addr_D,
		mem_rdata_D,
		mem_wdata_D,
		mem_ready_D
	);

	cache I_cache(
		clk,
		~rst_n,
		
		ICACHE_ren,
		ICACHE_wen,
		ICACHE_addr,
		ICACHE_rdata,
		ICACHE_wdata,
		ICACHE_stall,
		
		mem_read_I,
		mem_write_I,
		mem_addr_I,
		mem_rdata_I,
		mem_wdata_I,
		mem_ready_I
	);


endmodule


