//CO224 - Computer Architecture
//Lab 5_1   : 8-bit ALU

// module testbed;

// 	// Declare variables for stimulating input
// 	reg [2:0] ALUOP;                        //3 bit register for operations
//     reg signed [7:0] OPERAND1,OPERAND2;    //8 bit registers for Data1 and Data2
//     wire signed [7:0] ALURESULT;           //8 bit register to store result

//     // instantiation of ALU
//     alu a1( OPERAND1,OPERAND2,ALURESULT,ALUOP);


//     //Monitor changes in ALURESULT and print once a ALUOP change happens

//     initial begin
//         $monitor($time," Select: %d     Data1: %d    Data2: %d     result : %d", ALUOP, OPERAND1,  OPERAND2,  ALURESULT);
   
//         assign OPERAND1 = 8'd15;     // provide random input to check
//         assign OPERAND2 = 8'd22;
//         assign ALUOP=3'd0;
// 	    #5 
//         assign OPERAND1 = 8'd3;
//         assign OPERAND2 = 8'd5;
//         assign ALUOP=3'd1;
// 	    #5
//         assign OPERAND1 = 8'd3;
//         assign OPERAND2 = 8'd5;
//         assign ALUOP=3'd2;
	    
// 	    #5
//         assign OPERAND1 = 8'd4;
//         assign OPERAND2 = 8'd5;
//         assign ALUOP=3'd3;
//         #5 
//         assign OPERAND1 = 8'd115;
//         assign OPERAND2 = 8'd232;
//         assign ALUOP=3'd0;
// 	    #5
//         assign OPERAND1 = 8'd7;
//         assign OPERAND2 = 8'd0;
//         assign ALUOP=3'd3;
//         #5 
//         assign OPERAND1 = 8'd2;
//         assign OPERAND2 = 8'd4;
//         assign ALUOP=3'd2;
// 	    #5
//         assign OPERAND1 = 8'd156;
//         assign OPERAND2 = 8'd20;
//         assign ALUOP=3'd1; 
//         #5
//         assign OPERAND1 = 8'd6;
//         assign OPERAND2 = 8'd20;
//         assign ALUOP=3'd3; 
//     end

// endmodule


//alu module
module alu(DATA1, DATA2, RESULT, SELECT, ZERO) ;

	// Port declarations
	output signed [7:0] RESULT;   //8 bit wire to output the result
	input signed [7:0] DATA1,DATA2;    //8 bit input data
    input [2:0] SELECT;         //a code for operations
    reg [7:0] out;              //a temporary register to store results
    output ZERO;

    wire signed [7:0] RESULT1,RESULT2,RESULT3,RESULT4; // 7 bit wires to store result according to the operation

    // Do all the operations on DATA1 and DATA2
    Forward f( DATA2,RESULT1);          //forward DATA2 data to RESULT1
    Add a2(DATA1,DATA2,RESULT2,ZERO);   //add two operands
    And a3(DATA1,DATA2,RESULT3);        //bitwise ANDing
    Or o1(DATA1,DATA2,RESULT4);         //bitwise ORing

    always @(SELECT,RESULT1,RESULT2,RESULT3,RESULT4) begin
        case (SELECT)
 		    3'd0 :   out= RESULT1;   // store Forward operation results in register out
 		    3'd1 :   out= RESULT2;   // store Add operation results in register out
 		    3'd2 :   out= RESULT3;   // store And operation results in register out
		    3'd3 :   out= RESULT4;   // store Or operation results in register out
	    endcase
    end
    //store results in to the output RESULT
    assign RESULT = out;

endmodule



//forward module
module Forward(DATA2,RESULT);
    // module to pass the data as it is
    // Port declarations
    output [7:0] RESULT;
    input [7:0] DATA2;
    
    //store the result in to the output
    assign  #1 RESULT = DATA2;

endmodule


//add module
module Add(DATA1,DATA2,RESULT,ZERO);
    // module to perform ADD operation
    // Port declarations
    output signed [7:0] RESULT;
    output reg ZERO;
    input signed [7:0] DATA1,DATA2;

    //store the result in to the output
    assign #2 RESULT= (DATA1+DATA2);

    always @(RESULT) begin
        ZERO=1'b0;
        if(RESULT==8'd0) begin
            ZERO=1'b1;
        end
    end

endmodule

//add module
module And(DATA1,DATA2,RESULT);
    // module to perform AND operation
    // Port declarations
    output [7:0] RESULT;
    input [7:0] DATA1,DATA2;
   
    //store the result in to the output
    assign  #1 RESULT= DATA1 & DATA2;

endmodule


//forward module
module Or(DATA1,DATA2,RESULT);
    // module to perform OR operation
    // Port declarations
    output [7:0] RESULT;
    input [7:0] DATA1,DATA2;
    
    //store the result in to the output
    assign  #1 RESULT = DATA2 | DATA1;

endmodule
