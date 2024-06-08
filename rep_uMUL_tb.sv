`include "rep_uMUL.v"

module rep_uMUL_tb();
    parameter BITWIDTH = 8;

    logic iClk;
    logic iRstN;
    logic A;
    logic [BITWIDTH - 1: 0] B;
    logic loadB;
    logic iClr;
    logic mult;

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

    //defines clk
    always #5 iClk = ~iClk;

    initial begin
        $dumpfile("rep_uMUL.vcd"); $dumpvars;

        iClk = 1;
        iRstN = 0;
        B = 157;
        loadB = 0;
        A = 0;
        iClr = 0;

        #15;
        iRstN = 1;
        

        #10;
        loadB = 1;

        #10;
        loadB = 0;

        #50; 
        A = 1;
        
        repeat(500) begin
            #10;
        end

        A = 0;
        repeat(500) begin
            #10;
        end

        iClr = 1;
        #400

        $finish;
    end
endmodule
