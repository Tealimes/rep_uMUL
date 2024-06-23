//By Alexander Peacock
//email: alexpeacock56ten@gmail.com

`timescale 1ns/1ns
`include "sobolrng.v"
`include "rep_uMUL.v"
`define TESTAMOUNT 10 //change for number of bitstreams tested

//used to check erors
class errorcheck;
    real uResult;
    real eResult;
    real fnum;
    real cntrA;
    real cntrB;
    real fdenom;
    real asum;
    real mse;
    real rmse;
    static int j;

    function new();
        asum = 0;
        cntrA = 0;
        cntrB = 0;
        fnum = 0;
        fdenom = 0;
        j = 0;
    endfunction

    function count(real a, b, outC);
        cntrA = cntrA + a;
        cntrB = cntrB + b;
        fnum = fnum + outC;
        fdenom++;
    endfunction 

    //sums the results of a bitstream cycle
    function fSUM();
        j++; //counts current run

        $display("Run %.0f results: ", j);
        $display("Number of 1s output = %.0f", fnum);
        $display("Bits in bitstream = %.0f", fdenom);
        $display("Number of 1s in A = %.0f", cntrA);
        $display("Number of 1s in B = %.0f", cntrB);
        uResult = (fnum/fdenom);
        eResult = (cntrA / fdenom) * (cntrB / fdenom);

        $display("uResult = %.9f", uResult);
        $display("eResult = %.9f", eResult); 

        asum = asum + ((uResult - eResult) * (uResult - eResult));
        $display("sum: %.9f", asum);
        $display("");

        //resets for next bitstreams
        cntrA = 0;
        cntrB = 0;
        fnum = 0;
        fdenom = 0;
    endfunction

    //mean squared error
    function fMSE();
        $display("Final Results: "); 
        mse = asum / `TESTAMOUNT;
        $display("mse: %.9f", mse);
    endfunction

    //root mean square error
    function fRMSE();
        rmse = $sqrt(mse);
        $display("rmse: %.9f", rmse);
    endfunction

endclass


module rep_uMUL_tb();
    parameter BITWIDTH = 8;
    
    logic iClk;
    logic iRstN;
    logic iA;
    logic iClr;
    logic loadB;
    logic oB;
    reg oMult;
    
    errorcheck error; //class for error checking

    //used for bitstream generation
    logic [BITWIDTH-1:0] sobolseq_tbA;
    logic [BITWIDTH-1:0] rand_A;
    logic [BITWIDTH-1: 0] iB;

    // This code is used to delay the expected output
    parameter PPCYCLE = 1;

    // dont change code below
    logic result [PPCYCLE-1:0];
    logic result_expected;
    assign result_expected = oMult;

    genvar i;
    generate
        for (i = 1; i < PPCYCLE; i = i + 1) begin
            always@(posedge iClk or negedge iRstN) begin
                if (~iRstN) begin
                    result[i] <= 0;
                end else begin
                    result[i] <= result[i-1];
                end
            end
        end
    endgenerate

    always@(posedge iClk or negedge iRstN) begin
        if (~iRstN) begin
            result[0] <= 0;
        end else begin
            result[0] <= result_expected;
        end
    end
    // end here

    //generates bitstream for comparison with number rand_A
    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng_tbA (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(1),
        .iClr(iClr),
        .sobolseq(sobolseq_tbA)
    );

    rep_uMUL #(
        .BITWIDTH(BITWIDTH)
    ) u_rep_uMUL (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(iA),
        .iB(iB),
        .loadB(loadB),
        .iClr(iClr),
        .oB(oB),
        .oMult(oMult)
    );

    always #5 iClk = ~iClk; //defines the clock


    initial begin 
        $dumpfile("rep_uMUL_tb.vcd"); $dumpvars;

        iClk = 1;
        iB = 0;
        iA = 0;
        rand_A = 0;
        iRstN = 0;
        iClr = 0;
        loadB = 1;
        error = new;

        #10;
        iRstN = 1;

        //specified cycles of unary bitstreams
        repeat(`TESTAMOUNT) begin
            iB = $urandom_range(255);
            rand_A = $urandom_range(255);
            
            repeat(256) begin
                #10;
                iA = (rand_A > sobolseq_tbA);
                error.count(iA, oB, result[PPCYCLE-1]);
            end
            
            error.fSUM();        
        end
        
        //gives final eror results
        error.fMSE();
        error.fRMSE();
        
        iClr = 1;
        iA = 0;
        iB = 0;
        #400;

        $finish;
    end 

endmodule
