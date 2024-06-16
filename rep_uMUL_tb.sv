`include "rep_uMUL.v"
`include "sobolrng.v"
`define TESTAMOUNT 10

module rep_uMUL_tb();
    parameter BITWIDTH = 8;

    logic iClk;
    logic iRstN;
    logic A;
    logic [BITWIDTH - 1: 0] B;
    logic loadB;
    logic iClr;
    logic oB;
    reg mult;

    //creates a stochastic number inside testbench
    logic [BITWIDTH-1:0] sobolseq_tb;
    logic [BITWIDTH-1:0] rand_a;

    //used to calculate result
    real calcNum; //numerator 
    real cntA; //counts As
    real cntB; //counts Bs
    real denom; //denominator of unary number
    real eResult; //expected binary result
    real uResult; //final unary result
    real sum; //finds sum for mse and rmse 
    real mse; //final mse
    real rmse; //final rmse

    //calculates end result
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            calcNum <= 0;
        end else begin
            if(~iClr) begin 
                calcNum <= calcNum + mult;
            end
        end
    end

    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            denom <= 0;
        end else begin
            if(~iClr) begin 
                denom <= denom + 1;
            end
        end
    end

    //Counts 1 in As and Bs
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            cntA <= 0;
        end else begin
            if(~iClr) begin 
                cntA <= cntA + A;
            end
        end
    end
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            cntA <= 0;
        end else begin
            if(~iClr) begin 
                    cntB <= cntB + oB;
            end
        end
    end


    rep_uMUL #(
        .BITWIDTH(BITWIDTH)
    ) u_rep_uMUL (
        .iClk(iClk),
        .iRstN(iRstN),
        .A(A),
        .B(B),
        .loadB(loadB),
        .iClr(iClr),
        .oB(oB),
        .mult(mult)
    );

    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng_tb (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(1),
        .iClr(iClr),
        .sobolseq(sobolseq_tb)
    );

    //defines clk
    always #5 iClk = ~iClk;

    initial begin
        $dumpfile("rep_uMUL.vcd"); $dumpvars;

        iClk = 1;
        B = 0;
        A = 0;
        rand_a = 0;
        iRstN = 0;
        iClr = 0;
        loadB = 1;
        uResult = 0;
        sum = 0;
        mse = 0;
        rmse = 0;

        #10;
        iRstN = 1;

        //specified cycles of unary bitstreams
        repeat(`TESTAMOUNT) begin
            calcNum = 0;
            denom = 0;
            cntA = 0;
            cntB = 0;
            B = $urandom_range(255);
            rand_a = $urandom_range(255);

            repeat(256) begin
                #10;
                A = (rand_a > sobolseq_tb);
            end

            uResult = (calcNum / denom);
            eResult = (cntA / denom) * (cntB / denom);
            sum = sum + ((uResult - eResult) * (uResult - eResult));
        end
        
        mse = sum / `TESTAMOUNT;
        rmse = $sqrt(mse);
            
        iClr = 1;
        #400;

        $finish;
    end
endmodule
