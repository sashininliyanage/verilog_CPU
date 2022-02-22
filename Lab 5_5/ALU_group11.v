//CO224 - Computer Architecture
//Lab 5 : 8-bit ALU
// Group - 11


//alu module
module alu(DATA1, DATA2, RESULT, SELECT,ZERO) ;

	// Port declarations
	output wire signed[7:0] RESULT;         //8 bit wire to output the result
    output wire ZERO;
	input signed[7:0] DATA1,DATA2;          //8 bit input data
    input [2:0] SELECT;                     //a code for operations
    reg signed[7:0] out;                    //a temporary register to store results
    wire [7:0]temp1result6,temp2result6;    //for right shift and left shift
    wire signed[7:0] RESULT1,RESULT2,RESULT3,RESULT4,RESULT5,RESULT6,RESULT7,RESULT8; // 7 bit wires to store result according to the operation

    // Do all the operations on DATA1 and DATA2
    Forward f(DATA2,RESULT1);               //forward DATA2 data to RESULT1
    Add a2(DATA1,DATA2,RESULT2,ZERO);       //add two operands
    And a3(DATA1,DATA2,RESULT3);            //bitwise ANDing
    Or or1(DATA1,DATA2,RESULT4);            //bitwise ORing
    Multiply mul1(DATA1,DATA2,RESULT5);     //multiplication
    LSR lr1(DATA1,DATA2,temp1result6);      //logical shift right
    LSL ll1(DATA1,DATA2,temp2result6);      //logical shift left
    ASR as1(DATA1,DATA2,RESULT7);           //arithmatic shift right
    ROR ror1(DATA1,DATA2,RESULT8);    

    mux8bit2to1 m8(temp1result6,temp2result6,DATA2[7],RESULT6); //select left or right shift results according to the first bit of immediate value

    always @(SELECT,RESULT1, RESULT2, RESULT3, RESULT4,RESULT5,RESULT6,RESULT7,RESULT8) begin

        case (SELECT)
 		    3'd0 :   out= RESULT1;   // store Forward operation results in register out
 		    3'd1 :   out= RESULT2;   // store Add operation results in register out
 		    3'd2 :   out= RESULT3;   // store And operation results in register out
		    3'd3 :   out= RESULT4;   // store Or operation results in register out
            3'd4 :   out= RESULT5;   // store Multiply operation result in register out
            3'd5 :   out= RESULT6;   // store lsr/lsl operation result in register out    
            3'd6 :   out= RESULT7;   // store asr operation result in register out
            3'd7 :   out= RESULT8;   // store ror operation result in register out
	    endcase
    end
    //store results in to the output RESULT
    assign RESULT =out;

endmodule



//forward module
module Forward(DATA2,RESULT1);
    // module to pass the data as it is
    // Port declarations
    output reg signed[7:0] RESULT1;
    input signed[7:0] DATA2;
    //input [2:0] SELECT;

    always @(DATA2) begin
       #1 RESULT1 =  DATA2;         //forward the DATA2 data in to Result1
    end

endmodule

//add module
module Add(DATA1,DATA2,RESULT2,ZERO);
    // module to perform ADD operation
    // Port declarations
    output reg signed[7:0] RESULT2;
    output reg ZERO;
    input signed[7:0] DATA1,DATA2;
    
    always @(DATA1,DATA2) begin
        ZERO=1'b0;
        #2 RESULT2 = (DATA1+DATA2);   //add the two operands and send to Result2
        if(RESULT2==8'd0) begin
            ZERO=1'b1;
        end
    end

endmodule

//add module
module And(DATA1,DATA2,RESULT3);
    // module to perform AND operation
    // Port declarations
    output reg [7:0] RESULT3;
    input signed[7:0] DATA1,DATA2;
    //input [2:0] SELECT;

    always @(DATA1,DATA2) begin
        #1 RESULT3 =  DATA1 & DATA2;     //bitwise ANDing and send to Result3
    end

endmodule


//forward module
module Or(DATA1,DATA2,RESULT4);
    // module to perform OR operation
    // Port declarations
    output reg signed[7:0] RESULT4;
    input signed[7:0] DATA1,DATA2;
   // input [2:0] SELECT;

    //store the result in to the output
    always @(DATA1,DATA2) begin
        #1 RESULT4 =  DATA2 | DATA1;         //bitwise ORing
    end

endmodule


//Multiply module
module Multiply(DATA1,DATA2,RESULT5);
    // module to perform multiplication operation
    // Port declarations
    output signed[7:0] RESULT5;
    input signed[7:0] DATA1,DATA2;

    wire [7:0] mult[7:0];           //to store ANDed rows
    wire [7:0] shiftmult[7:0];      //to shift ANDed rows
    //wire [7:0] multshift[7:0];
    wire [7:0]select;
    assign select=DATA2;

    //ANDing DATA1 from DATA2 bit by bit
    mux8bit2to1 mu1(8'b0,DATA1,select[0],mult[7]);
    mux8bit2to1 mu2(8'b0,DATA1,select[1],mult[6]);
    mux8bit2to1 mu3(8'b0,DATA1,select[2],mult[5]);
    mux8bit2to1 mu4(8'b0,DATA1,select[3],mult[4]);
    mux8bit2to1 mu5(8'b0,DATA1,select[4],mult[3]);
    mux8bit2to1 mu6(8'b0,DATA1,select[5],mult[2]);
    mux8bit2to1 mu7(8'b0,DATA1,select[6],mult[1]);
    mux8bit2to1 mu8(8'b0,DATA1,select[7],mult[0]);
    
    //shift left ANDed result in order to get the sumation (#2 time delay included)
    LSL mulshift1(mult[7],8'b10000000,shiftmult[7]);
    LSL mulshift2(mult[6],8'b10000001,shiftmult[6]);
    LSL mulshift3(mult[5],8'b10000010,shiftmult[5]);
    LSL mulshift4(mult[4],8'b10000011,shiftmult[4]);
    LSL mulshift5(mult[3],8'b10000100,shiftmult[3]);
    LSL mulshift6(mult[2],8'b10000101,shiftmult[2]);
    LSL mulshift7(mult[1],8'b10000110,shiftmult[1]);
    LSL mulshift8(mult[0],8'b10000111,shiftmult[0]);

    //get the sumation of the shifted results (with #1 time delay there is #2 time delay all together)
    assign #1 RESULT5=shiftmult[7]+shiftmult[6]+shiftmult[5]+shiftmult[4]+shiftmult[3]+shiftmult[2]+shiftmult[1]+shiftmult[0];

endmodule


//module to arithmatic shift right 
module ASR(DATA1,DATA2,RESULT7);
    // Port declarations
    output signed[7:0] RESULT7;
    input [7:0] DATA1,DATA2;

    reg [2:0]SHIFT;
    wire A,C;
    wire[7:0] OUT;
    assign A=1'b1;
    assign C=1'b0;

    //store the result in to the output
     always @(DATA1,DATA2) begin
        case(DATA2)
            8'd0 :  SHIFT=3'b000;  
            8'd1 :  SHIFT=3'b001;  
            8'd2 :  SHIFT=3'b010;  
            8'd3 :  SHIFT=3'b011;  
            8'd4 :  SHIFT=3'b100;  
            8'd5 :  SHIFT=3'b101;  
            8'd6 :  SHIFT=3'b110;  
            8'd7 :  SHIFT=3'b111;   
        endcase
    end 

    barellshift b1(DATA1,SHIFT,A,C,OUT);
    assign #2 RESULT7=OUT;

endmodule


//Logical Shift Right
module LSR(DATA1,DATA2,RESULT6);
    // Port declarations
    output wire [7:0] RESULT6;
    input signed[7:0] DATA1,DATA2;
   // input [2:0] SELECT;

    reg [2:0]SHIFT;
    wire A,C;
    wire[7:0] OUT;
    assign A=1'b0;
    assign C=1'b0;

    always @(DATA1,DATA2) begin
        case(DATA2)
            8'd0 :  SHIFT=3'b000;  
            8'd1 :  SHIFT=3'b001;  
            8'd2 :  SHIFT=3'b010;  
            8'd3 :  SHIFT=3'b011;  
            8'd4 :  SHIFT=3'b100;  
            8'd5 :  SHIFT=3'b101;  
            8'd6 :  SHIFT=3'b110;  
            8'd7 :  SHIFT=3'b111;
        endcase
    end 
    
    barellshift b2(DATA1,SHIFT,A,C,OUT);
    assign #2 RESULT6=OUT;

endmodule


//module to logical shift left
module LSL(DATA1, DATA2,RESULT6);
    //port declaration
    input [7:0] DATA2, DATA1;
    output [7:0] RESULT6;
    wire [7:0] lev1out, lev2out;
    reg [2:0]SHIFT;

    wire [7:0] OUT;
    always @(DATA1,DATA2) begin
       // $monitor($time," data2: %b shift: %b DATA1: %b result: %b",DATA2,SHIFT,DATA1, RESULT6);
        case(DATA2)
            8'b10000000 :  SHIFT=3'b000;  
            8'b10000001 :  SHIFT=3'b001;  
            8'b10000010 :  SHIFT=3'b010;  
            8'b10000011 :  SHIFT=3'b011;  
            8'b10000100 :  SHIFT=3'b100;  
            8'b10000101 :  SHIFT=3'b101;  
            8'b10000110 :  SHIFT=3'b110;
            8'b10000111 :  SHIFT=3'b111;
        endcase
    end
    
    //3 levels left shifting
    mux2to1_1 lev1_7(lev1out[7], DATA1[7], DATA1[6], SHIFT[0]);
    mux2to1_1 lev1_6(lev1out[6], DATA1[6], DATA1[5], SHIFT[0]);
    mux2to1_1 lev1_5(lev1out[5], DATA1[5], DATA1[4], SHIFT[0]);
    mux2to1_1 lev1_4(lev1out[4], DATA1[4], DATA1[3], SHIFT[0]);
    mux2to1_1 lev1_3(lev1out[3], DATA1[3], DATA1[2], SHIFT[0]);
    mux2to1_1 lev1_2(lev1out[2], DATA1[2], DATA1[1], SHIFT[0]);
    mux2to1_1 lev1_1(lev1out[1], DATA1[1], DATA1[0], SHIFT[0]);
    mux2to1_1 lev1_0(lev1out[0], DATA1[0], 1'b0, SHIFT[0]);
    
    mux2to1_1 lev2_7(lev2out[7], lev1out[7], lev1out[5], SHIFT[1]);
    mux2to1_1 lev2_6(lev2out[6], lev1out[6], lev1out[4], SHIFT[1]);
    mux2to1_1 lev2_5(lev2out[5], lev1out[5], lev1out[3], SHIFT[1]);
    mux2to1_1 lev2_4(lev2out[4], lev1out[4], lev1out[2], SHIFT[1]);
    mux2to1_1 lev2_3(lev2out[3], lev1out[3], lev1out[1], SHIFT[1]);
    mux2to1_1 lev2_2(lev2out[2], lev1out[2], lev1out[0], SHIFT[1]);
    mux2to1_1 lev2_1(lev2out[1], lev1out[1], 1'b0, SHIFT[1]);
    mux2to1_1 lev2_0(lev2out[0], lev1out[0], 1'b0, SHIFT[1]);
    
    mux2to1_1 lev3_7(OUT[7], lev2out[7], lev2out[3], SHIFT[2]);
    mux2to1_1 lev3_6(OUT[6], lev2out[6], lev2out[2], SHIFT[2]);
    mux2to1_1 lev3_5(OUT[5], lev2out[5], lev2out[1], SHIFT[2]);
    mux2to1_1 lev3_4(OUT[4], lev2out[4], lev2out[0], SHIFT[2]);
    mux2to1_1 lev3_3(OUT[3], lev2out[3], 1'b0, SHIFT[2]);
    mux2to1_1 lev3_2(OUT[2], lev2out[2], 1'b0, SHIFT[2]);
    mux2to1_1 lev3_1(OUT[1], lev2out[1], 1'b0, SHIFT[2]);
    mux2to1_1 lev3_0(OUT[0], lev2out[0], 1'b0, SHIFT[2]);

    assign #2 RESULT6 = OUT;

endmodule


//module to rotate
module ROR(DATA1,DATA2,RESULT8);
    // Port declarations
    output signed[7:0] RESULT8;
    input [7:0] DATA1,DATA2;

    reg [2:0]SHIFT;
    wire A,C;
    wire [7:0] OUT;
    assign A=1'b0;
    assign C=1'b1;

    //store the result in to the output
     always @(DATA1,DATA2) begin

        case(DATA2)
            8'd0 :  SHIFT=3'b000;  
            8'd1 :  SHIFT=3'b001;  
            8'd2 :  SHIFT=3'b010;  
            8'd3 :  SHIFT=3'b011;  
            8'd4 :  SHIFT=3'b100;  
            8'd5 :  SHIFT=3'b101;  
            8'd6 :  SHIFT=3'b110;  
            8'd7 :  SHIFT=3'b111;   
        endcase
    end 

    barellshift b3(DATA1,SHIFT,A,C,OUT);
    assign #2 RESULT8=OUT;

    

endmodule


module mux2to1_1 (OUT, IN1, IN2, SELECT);
    //    1 bit bit 2 to 1 mux
    // port declaration
    input IN1, IN2;
    input SELECT;
    output OUT;
    wire y1,y2;
    
    and(y1, IN1, ~SELECT);
    and(y2, IN2, SELECT);
    or(OUT, y1, y2);

endmodule

//barrelshifting arithmatic/right shift/rotate selecting module part
module barrelshiftlevel(OUT,IN1,IN2,IN3,S,A,C);
    input IN1,IN2,IN3,S,A,C;
    output OUT;

    wire temp1,temp2,temp3;
    and a11(temp1,S,C,IN1);
    and a12(temp2,S,~C,A,IN2);
    and a13(temp3,~S,IN3);
    or o1(OUT,temp1,temp2,temp3);

endmodule



//3 level barrell shifting module
module barellshift(DATA,SHIFT,A,C,RESULT);
    input [7:0]DATA;
    input[2:0]SHIFT;
    input  A,C;
    output [7:0]RESULT;
    wire [7:0]temp1,temp2,out;

    //shift/rotate 1 bit
    barrelshiftlevel bs1(temp1[7],DATA[0],DATA[7],DATA[7],SHIFT[0],A,C);
    mux2to1_1 m11(temp1[6], DATA[6], DATA[7], SHIFT[0]);
    mux2to1_1 m13(temp1[5], DATA[5], DATA[6], SHIFT[0]);
    mux2to1_1 m14(temp1[4], DATA[4], DATA[5], SHIFT[0]);
    mux2to1_1 m15(temp1[3], DATA[3], DATA[4], SHIFT[0]);
    mux2to1_1 m16(temp1[2], DATA[2], DATA[3], SHIFT[0]);
    mux2to1_1 m17(temp1[1], DATA[1], DATA[2], SHIFT[0]);
    mux2to1_1 m18(temp1[0], DATA[0], DATA[1], SHIFT[0]);

    //shift/rotate 2 bits
    barrelshiftlevel bs2(temp2[7],temp1[1],temp1[7],temp1[7],SHIFT[1],A,C);
    barrelshiftlevel bs3(temp2[6],temp1[0],temp1[7],temp1[6],SHIFT[1],A,C);
    mux2to1_1 m21(temp2[5], temp1[5], temp1[7], SHIFT[1]);
    mux2to1_1 m22(temp2[4], temp1[4], temp1[6], SHIFT[1]);
    mux2to1_1 m23(temp2[3], temp1[3], temp1[5], SHIFT[1]);
    mux2to1_1 m24(temp2[2], temp1[2], temp1[4], SHIFT[1]);
    mux2to1_1 m25(temp2[1], temp1[1], temp1[3], SHIFT[1]);
    mux2to1_1 m26(temp2[0], temp1[0], temp1[2], SHIFT[1]);

    //shift/rotate 4 bits
    barrelshiftlevel bs5(out[7],temp2[3],temp2[7],temp2[7],SHIFT[2],A,C);
    barrelshiftlevel bs6(out[6],temp2[2],temp2[7],temp2[6],SHIFT[2],A,C);
    barrelshiftlevel bs7(out[5],temp2[1],temp2[7],temp2[5],SHIFT[2],A,C);
    barrelshiftlevel bs8(out[4],temp2[0],temp2[7],temp2[4],SHIFT[2],A,C);
    mux2to1_1 m32(out[3], temp2[3], temp2[6], SHIFT[2]);
    mux2to1_1 m33(out[2], temp2[2], temp2[5], SHIFT[2]);
    mux2to1_1 m34(out[1], temp2[1], temp2[4], SHIFT[2]);
    mux2to1_1 m35(out[0], temp2[0], temp2[3], SHIFT[2]);

    assign RESULT=out;

endmodule

//8 bits 2to1 mux
module mux8bit2to1(IN1,IN2,SEL,OUT);
    input [7:0]IN1,IN2;
    input SEL;
    output reg [7:0] OUT;

    always @(IN1,IN2,SEL) begin
        if(~SEL)begin
            OUT=IN1;
        end else begin
            OUT=IN2;
        end

    end

endmodule