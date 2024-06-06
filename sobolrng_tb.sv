`timescale 1ns/1ns

`include "sobolrng.v"

module sobolrng_tb();
    parameter BITWIDTH = 8;

    logic iClk;
    logic iRstN;
    logic iEn;
    logic iClr;
    logic [BITWIDTH - 1: 0] sobolseq;

    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iEn),
        .iClr(iClr),
        .sobolseq(sobolseq)
    );

    always #5 iClk = ~iClk;

    initial begin
        $dumpfile("sobolrng.vcd"); $dumpvars;

        iClk = 1;
        iRstN = 0;
        iEn = 1;
        iClr = 0;

        #15;
        iRstN = 1;
        repeat(500) begin
            #10;
        end

        iClr = 1;
        #400

        $finish;
    end

endmodule
