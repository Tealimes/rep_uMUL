`timescale 1ns/1ns

`include "lsz.v"

module lsz_tb();
    parameter BITWIDTH = 4;
    parameter LOGBITWIDTH = $clog2(BITWIDTH);

    logic [BITWIDTH - 1: 0] iGrey;
    logic [BITWIDTH - 1: 0] oOneHot;
    logic [LOGBITWIDTH - 1: 0] lszIdx;

    lsz #(
        .BITWIDTH(BITWIDTH)
    ) u_lsz (
        .iGrey(iGrey),
        .oOneHot(oOneHot),
        .lszIdx(lszIdx)
    );

    initial begin
        $dumpfile("lsz.vcd"); $dumpvars;

        iGrey = 0;

        #15;
        repeat(500) begin
            #10 iGrey = iGrey + 1;
        end

        $finish;
    end


endmodule
