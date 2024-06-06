`timescale 1ns/1ns
`include "cntwithen.v"

module cntwithen_tb();
    parameter BITWIDTH = 8;

    logic iClk;
    logic iRstN;
    logic iEn;
    logic iClr;
    logic [BITWIDTH-1:0] oCnt;

    cntwithen #(
        .BITWIDTH(BITWIDTH)
    ) u_cntwithen(
        .iClk(iClk), 
        .iRstN(iRstN),
        .iEn(iEn),
        .iClr(iClr),
        .oCnt(oCnt)
    );

    always #5 iClk = ~iClk;

    initial begin 
        $dumpfile("cntwithen.vcd"); $dumpvars;

        iClk = 1;
        iRstN = 0;
        iEn = 1;
        iClr = 0;

        #15;
        iRstN = 1;
        #100
        repeat(100) begin
            #10;
        end

        #100;
        iClr = 1;
        #100;
        $finish;
    end

endmodule
