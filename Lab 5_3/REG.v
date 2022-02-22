//CO224 - Computer Architecture
//Lab 5_2 : 8x8 register

// module reg_file_tb;
    
//     reg [7:0] WRITEDATA;
//     reg [2:0] WRITEREG, READREG1, READREG2;
//     reg CLK, RESET, WRITEENABLE; 
//     wire signed [7:0] REGOUT1, REGOUT2;
    
//     reg_file myregisters(WRITEDATA, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
    
//     initial
//     begin
//         CLK = 1'b1;
        
//         // generate files needed to plot the waveform using GTKWave
//         $dumpfile("reg_file_wavedata.vcd");
// 		$dumpvars(0, reg_file_tb);
        
//         // assign values with time to input signals to see output 
//         RESET = 1'b0;
//         WRITEENABLE = 1'b0;
        
//         #5
//         RESET = 1'b1;
//         READREG1 = 3'd0;
//         READREG2 = 3'd4;
        
//         #7
//         RESET = 1'b0;
        
//         #3
//         WRITEREG = 3'd2;
//         WRITEDATA = 8'd95;
//         WRITEENABLE = 1'b1;
        
//         #9
//         WRITEENABLE = 1'b0;
        
//         #1
//         READREG1 = 3'd2;
        
//         #9
//         WRITEREG = 3'd1;
//         WRITEDATA = 8'd28;
//         WRITEENABLE = 1'b1;
//         READREG1 = 3'd1;
        
//         #10
//         WRITEENABLE = 1'b0;
        
//         #10
//         WRITEREG = 3'd4;
//         WRITEDATA = 8'd6;
//         WRITEENABLE = 1'b1;
        
//         #10
//         WRITEDATA = 8'd15;
//         WRITEENABLE = 1'b1;
        
//         #10
//         WRITEENABLE = 1'b0;
        
//         #6
//         WRITEREG = 3'd1;
//         WRITEDATA = 8'd50;
//         WRITEENABLE = 1'b1;
        
//         #5
//         WRITEENABLE = 1'b0;
        
//         #10
//         $finish;
//     end
    
//     // clock signal generation
//     always
//         #5 CLK = ~CLK;
        
// endmodule


//register file module
module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS, WRITE, CLK, RESET);

	// Port declarations
	output wire signed [7:0] OUT1, OUT2;
	input [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;
    input signed [7:0] IN;
    input WRITE, RESET, CLK;

    integer i;

    // declaring internal registers
    reg signed [7:0] registers [7:0];//regdata0, regdata1, regdata2, regdata3, regdata4, regdata5, regdata6, regdata7;


    //synchroneous writing and reseting
    always @(posedge CLK) 
    begin
        if (WRITE == 1'b1 && RESET== 1'b0) begin    //if RESET=0 and WRITE enable is high then write the registers 
            #1 registers [INADDRESS] = IN;          //one unit, time delay for writing   
        end

        if (RESET == 1'b1) begin                    //if RESET is set to 1 clear all the registers
            for( i=0;i<8;i=i+1) begin               //one unit, time delay
                registers [i] <= #1 8'b0;           //assigning zero to every register
            end
        end 
    end

    //output the register OUT1 values asynchroneously
    //whenever a register changes OUT1 should be change respectivly
    
    assign #2 OUT1 = registers[OUT1ADDRESS]; 
    assign #2 OUT2 = registers[OUT2ADDRESS];                                      

	initial
	begin
		#5;
		$display("\n\t\t\t___________________________________________________");
		$display("\n\t\t\t CHANGE OF REGISTER CONTENT STARTING FROM TIME #5");
		$display("\n\t\t\t___________________________________________________\n");
		$display("\t\ttime\treg0\treg1\treg2\treg3\treg4\treg5\treg6\treg7");
		$display("\t\t____________________________________________________________________");
		$monitor($time, "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",registers[0],registers[1],registers[2],registers[3],registers[4],registers[5],registers[6],registers[7]);
	end
    

endmodule

