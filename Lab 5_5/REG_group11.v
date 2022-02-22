//CO224 - Computer Architecture
//Lab 5 : 8x8 register
// Group - 11



//register file module
module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS, WRITE, CLK, RESET);

	// Port declarations
	output [7:0] OUT1, OUT2;
	input [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;
    input [7:0] IN;
    input WRITE, RESET, CLK;

    integer i;


    // declaring internal registers
    reg [7:0] registers [7:0];//regdata0, regdata1, regdata2, regdata3, regdata4, regdata5, regdata6, regdata7;

    initial begin 
		#5
		$display("\t\t======================================================================");
		$display("\t\t\treg0\treg1\treg2\treg3\treg4\treg5\treg6\treg7");
		$display("\t\t======================================================================");
	    $monitor($time,"\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",registers[0],registers[1],registers[2],registers[3],registers[4],registers[5],registers[6],registers[7]);
		
	end


    //synchroneous writing and reseting
    always @(posedge CLK) begin

        if (RESET == 1'b1) begin        //if RESET is set to 1 clear all the registers
            #1;                         //one unit, time delay
            for( i=0;i<8;i=i+1) begin
                registers [i] = 8'b0;       //assigning zero to every register
            end
            
        end else if (WRITE== 1'b1) begin    //if RESET=0 and WRITE enable is high then write the registers                                           
            #1 registers [INADDRESS] = IN;          //one unit, time delay for writing   
            
        end
        
    end

    //output the register OUT1 values asynchroneously
    //whenever a register changes OUT1 should be change respectivly
        
    assign #2 OUT1 = registers[OUT1ADDRESS]; 
    assign #2 OUT2 = registers[OUT2ADDRESS];                                      
    

    

    

endmodule

