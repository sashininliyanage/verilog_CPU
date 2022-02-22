// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Isuru Nawinne

`include "ALU.v"			//Include the module ALU
`include "REG.v"		    //Include the module regfile

module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;
    
    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
    reg [7:0] instr_mem [0:1024];
    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)
    
    assign #2 INSTRUCTION[7:0] = instr_mem[PC];
    assign #2 INSTRUCTION[15:8] = instr_mem[PC+1];
    assign #2 INSTRUCTION[23:16] = instr_mem[PC+2];
    assign #2 INSTRUCTION[31:24]= instr_mem[PC+3];
    	

    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        // METHOD 1: manually loading instructions to instr_mem
        //{instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00000000000001000000000000000101;
        //{instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00000000000000100000000000001001;
        //{instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00000010000001100000010000000010;
        
        // METHOD 2: loading instr_mem content from instr_mem.mem file
        $readmemb("instr_mem.mem", instr_mem);
    end
    
    /* 
    -----
     CPU
    -----
    */
    cpu mycpu(PC, INSTRUCTION, CLK, RESET);

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        
        CLK = 1'b0;

        #3
        RESET = 1'b1;
        #3
        RESET = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        
        // finish simulation after some time
        #500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        
endmodule

module cpu(PC, INSTRUCTION, CLK, RESET);
    input CLK, RESET, ZERO;
    input [31:0] INSTRUCTION;   //32 bit instruction
    output reg [31:0] PC;       //32 bit programe counter

    wire writeEnable,addOrSubSelect, imediateSelect, jump, branch;
    wire [2:0] WRITEREG,READREG1,READREG2,ALUOP;
    wire [7:0] OPCODE,REGOUT1,REGOUT2, ALURESULT, IMMEDIATE, negative, mux1out,mux2out;
    wire [31:0] newPC, temp1PC, temp2PC, offset, extended_offset;
    wire beq, offset_select;
    //instruction fetching 
    assign    WRITEREG=   INSTRUCTION[18:16];
    assign    READREG1=   INSTRUCTION[10:8];
    assign    READREG2=   INSTRUCTION[2:0]; 
    assign    OPCODE  =   INSTRUCTION[31:24];
    assign    IMMEDIATE=  INSTRUCTION[7:0];

    //find the offset corosponding to the jump and branch vlues
    assign offset = INSTRUCTION[23:16];
    assign extended_offset = { {22{offset[7]}}, offset, 2'b00};

    control_unit controlUnit(OPCODE,writeEnable,ALUOP,immediateSelect,suboraddSelect, jump,branch);
    reg_file regfile(ALURESULT,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2, writeEnable, CLK, RESET);

    assign #1 negative = ~REGOUT2 + 1;

    assign #1 temp1PC = PC + 4 ;
    assign #2 temp2PC = PC + 4 + extended_offset;


    mux8bit2_1 mux1(REGOUT2,negative,suboraddSelect,mux1out);
    mux8bit2_1 mux2(IMMEDIATE,mux1out,immediateSelect,mux2out);

    alu myalu(REGOUT1,mux2out, ALURESULT, ALUOP,ZERO);

    //offset enable signal
    and a(beq,branch,ZERO);
    or o(offset_select,beq,jump);

    mux32bit2_1 pc_update(temp1PC,temp2PC,offset_select,newPC);
    

    //at positive edge of the clock PC updating or reseting
    always @ (posedge CLK) begin
        if(RESET==1'b1) begin
           #1 PC =  32'd0;
        end else begin
           #1 PC=  newPC;

        end
    end

endmodule


module control_unit(OPCODE,writeEnable,ALUOP,immediateSelect,suboraddSelect, jump,branch);
    // port declaration
    input [7:0] OPCODE;
    output reg suboraddSelect, immediateSelect, writeEnable, jump,branch;
    output reg [2:0] ALUOP;

    always @ (OPCODE) begin
        case (OPCODE)
            8'd0: {branch, jump, ALUOP, suboraddSelect, immediateSelect, writeEnable} <= #1 8'b0_0_000_0_0_1;    // loadi
            8'd1: {branch, jump, ALUOP, suboraddSelect, immediateSelect, writeEnable} <= #1 8'b0_0_000_0_1_1;    // mov
            8'd2: {branch, jump, ALUOP, suboraddSelect, immediateSelect, writeEnable} <= #1 8'b0_0_001_0_1_1;    // add
            8'd3: {branch, jump, ALUOP, suboraddSelect, immediateSelect, writeEnable} <= #1 8'b0_0_001_1_1_1;    // sub
            8'd4: {branch, jump, ALUOP, suboraddSelect, immediateSelect, writeEnable} <= #1 8'b0_0_010_0_1_1;    // and
            8'd5: {branch, jump, ALUOP, suboraddSelect, immediateSelect, writeEnable} <= #1 8'b0_0_011_0_1_1;    // or
            8'd6: {branch, jump, ALUOP, suboraddSelect, immediateSelect, writeEnable} <= #1 8'b0_1_011_0_1_1;    // jump
            8'd7: {branch, jump, ALUOP, suboraddSelect, immediateSelect, writeEnable} <= #1 8'b1_0_011_0_1_1;    // branch
        endcase
    end

endmodule



module mux8bit2_1(IN1,IN2,SEL,OUT);
    input [7:0]IN1,IN2;
    input SEL;
    output reg [7:0] OUT;

    always @(IN1,IN2,SEL) begin
        if(SEL)begin
            OUT=IN2;
        end else begin
            OUT=IN1;
        end

    end

endmodule

module mux32bit2_1(IN1,IN2,SEL,OUT);
    input [31:0]IN1,IN2;
    input SEL;
    output reg [31:0] OUT;

    always @(IN1,IN2,SEL) begin
        if(SEL)begin
            OUT=IN2;
        end else begin
            OUT=IN1;
        end
    end
endmodule