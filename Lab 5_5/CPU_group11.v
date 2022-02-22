`include "ALU_group11.v" 
`include "REG_group11.v"
// Computer Architecture (CO224) - Lab 05_part3
// group_11


module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;

    

    /*
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */

    //Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
    reg [7:0] instr_mem[1023:0] ;

    assign #2 INSTRUCTION = {instr_mem[PC+3], instr_mem[PC+2], instr_mem[PC+1], instr_mem[PC]};
    
   
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
        
        CLK = 1'b1;
        RESET = 1'b1;   //Reset the CPU to start the program execution
        #1
        RESET = 1'b0;   //Set reset to zero to continue 

        
        // finish simulation after some time
        #500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        
endmodule


//CPU module
module cpu(PC, INSTRUCTION, CLK, RESET);

    input CLK, RESET;
    input [31:0] INSTRUCTION;   //32 bit instruction
    output reg [31:0] PC;       //32 bit programe counter

    //registers for reg_file module
    wire [2:0] WRITEREG, READREG1, READREG2;
    wire WRITEENABLE; 
    wire [7:0] REGOUT1, REGOUT2;
    wire [7:0] regout2;

    //registers for ALU module
    wire [2:0] ALUOP;                
    wire signed[7:0] OPERAND1,OPERAND2;    
    wire signed [7:0] ALURESULT;

    wire [31:0] temp_update1,temp_update2,PC_new,extended_offset;
    wire ZERO,offset_select;
    wire [7:0]OPCODE;
    wire [7:0] forleftIMMEDIATE,IMMEDIATE;
    wire [7:0] twoscomplement,offset;
    wire suboraddSelect,immediateSelect,branch,jump,leftshift; //enable variables for muxes

    //twos compliment for sub
    assign #1 twoscomplement= ~REGOUT2 +1;

    //instruction fetching 
    assign    WRITEREG=   INSTRUCTION[18:16];
    assign    READREG1=   INSTRUCTION[10:8];
    assign    READREG2=   INSTRUCTION[2:0]; 
    assign    OPCODE  =   INSTRUCTION[31:24];

    assign forleftIMMEDIATE ={1'b1,INSTRUCTION[6:0]};

    //find the offset corosponding to the jump and branch vlues
    assign offset = INSTRUCTION[23:16];
    assign extended_offset = { {22{offset[7]}}, offset, 2'b00};

    //enable offset signal for branch equal,branch not equal or jump
    wire temp1,temp2,temp3;
    and an1(temp1,~branch,jump);
    and an2(temp2,jump,~ZERO,branch);
    and an3(temp3,branch,~jump,ZERO);
    or o(offset_select,temp1,temp2,temp3);

    //Control unit-decording
    control_unit unit(branch, jump, ALUOP, suboraddSelect, immediateSelect,leftshift,WRITEENABLE, OPCODE);

    //temporary PC updates
    assign #1 temp_update1 =  PC + 4;
    assign #2 temp_update2 =  PC + 4 + extended_offset;


    //MUX to update the PC_New value
    mux32bit2_1 pc_update(temp_update2,temp_update1,offset_select,PC_new);
    //MUX for choose 2scomplement value and regout2 according to the OPCODE
    mux8bit2_1 suboradd(twoscomplement,REGOUT2,suboraddSelect,regout2);
    //MUX for choose immediate value and regout2 according to the OPCODE
    mux8bit2_1 leftorright(forleftIMMEDIATE,INSTRUCTION[7:0],leftshift,IMMEDIATE);
    mux8bit2_1 immediate(IMMEDIATE,regout2,immediateSelect,OPERAND2);
    
    //call the reg_file and ALU modules
    reg_file r1(ALURESULT,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2, WRITEENABLE, CLK, RESET);
    alu a1(OPERAND1, OPERAND2, ALURESULT, ALUOP,ZERO) ;

    //when REGOUT1 changes OPERAND1 changes according to that
    assign OPERAND1=REGOUT1;

    //at positive edge of the clock PC updating or reseting
    always @ (posedge CLK) begin
        if(RESET==1'b1) begin
           #1 PC =  32'd0;
        end else begin
           #1 PC=  PC_new;

        end
    end

    

endmodule

module control_unit (branch, jump, ALUOP, suboraddSelect, immediateSelect,leftshift, WRITEENABLE, OPCODE);
    // port declaration
    input [7:0] OPCODE;
    output reg suboraddSelect, immediateSelect, WRITEENABLE, branch, jump,leftshift;
    output reg [2:0] ALUOP;

    always @ (OPCODE) begin
        case (OPCODE)
            8'd0: {branch, jump, ALUOP, suboraddSelect, immediateSelect, WRITEENABLE,leftshift} <= #1 9'b0_0_000_0_1_1_0;    // loadi
            8'd1: {branch, jump, ALUOP, suboraddSelect, immediateSelect, WRITEENABLE} <= #1 8'b0_0_000_0_0_1;    // mov
            8'd2: {branch, jump, ALUOP, suboraddSelect, immediateSelect, WRITEENABLE} <= #1 8'b0_0_001_0_0_1;    // add
            8'd3: {branch, jump, ALUOP, suboraddSelect, immediateSelect, WRITEENABLE} <= #1 8'b0_0_001_1_0_1;    // sub
            8'd4: {branch, jump, ALUOP, suboraddSelect, immediateSelect, WRITEENABLE} <= #1 8'b0_0_010_0_0_1;    // and
            8'd5: {branch, jump, ALUOP, suboraddSelect, immediateSelect, WRITEENABLE} <= #1 8'b0_0_011_0_0_1;    // or
            8'd6: {branch, jump, ALUOP, suboraddSelect, immediateSelect, WRITEENABLE} <= #1 8'b0_1_000_0_0_0;    // jump 
            8'd7: {branch, jump, ALUOP, suboraddSelect, immediateSelect, WRITEENABLE} <= #1 8'b1_0_001_1_0_0;    // branch equal (do sub)
            8'd8: {branch, jump, ALUOP, suboraddSelect, immediateSelect, WRITEENABLE} <= #1 8'b1_1_001_1_0_0;    // branch not equal(do sub)
            8'd9: {branch, jump, ALUOP, suboraddSelect, immediateSelect, WRITEENABLE} <= #1 8'b0_0_100_0_0_1;    // multiply
            8'd10:{branch, jump, ALUOP, suboraddSelect, immediateSelect, WRITEENABLE,leftshift} <= #1 9'b0_0_101_0_1_1_0;    //lsr
            8'd11:{branch, jump, ALUOP, suboraddSelect, immediateSelect, WRITEENABLE,leftshift} <= #1 9'b0_0_101_0_1_1_1;    //lsl
            8'd12:{branch, jump, ALUOP, suboraddSelect, immediateSelect, WRITEENABLE,leftshift} <= #1 9'b0_0_110_0_1_1_0;    //asr
            8'd13:{branch, jump, ALUOP, suboraddSelect, immediateSelect, WRITEENABLE,leftshift} <= #1 9'b0_0_111_0_1_1_0;    //ror
        endcase
    end

endmodule


module mux8bit2_1(IN1,IN2,SEL,OUT);
    input [7:0]IN1,IN2;
    input SEL;
    output reg [7:0] OUT;

    always @(IN1,IN2,SEL) begin
        if(SEL)begin
            OUT=IN1;
        end else begin
            OUT=IN2;
        end

    end

endmodule

module mux32bit2_1(IN1,IN2,SEL,OUT);
    input [31:0]IN1,IN2;
    input SEL;
    output reg [31:0] OUT;

    always @(IN1,IN2,SEL) begin
        if(SEL)begin
            OUT=IN1;
        end else begin
            OUT=IN2;
        end
    end
endmodule

