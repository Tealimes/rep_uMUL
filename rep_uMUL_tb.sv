`include "rep_uMUL.v"

module rep_uMUL_tb();
    parameter BITWIDTH = 8;

    logic iClk;
    logic iRstN;
    logic A;
    logic [BITWIDTH - 1: 0] B;
    logic loadB;
    logic iClr;
    reg mult;

    //creates a stochastic number inside testbench
    logic [BITWIDTH-1:0] sobolseq_tb;
    logic [BITWIDTH-1:0] rand_a;

    //used to calculate result
    logic [BITWIDTH-1:0] result;

    //calculates end result
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            result <= 0;
        end else begin
            result <= result + 1;
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
        B = $urandom_range(255);
        A = 0;
        rand_a = $urandom_range(255);
        iRstN = 0;
        iClr = 0;
        loadB = 1;

        #10;
        iRstN = 1;

        repeat(500) begin
          #10;  
          A = (rand_a > sobolseq_tb);
        end
        
        iClr = 1;
        #400;

        $finish;
    end
endmodule
