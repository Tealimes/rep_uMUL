//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com
`ifndef rep_uMUL
`define rep_uMUL

`include "sobolrng.v"

module rep_uMUL #(
    parameter BITWIDTH = 8
) (
    input wire iClk,
    input wire iRstN,
    input wire iA,
    input wire [BITWIDTH - 1: 0] iB,
    input wire loadB,
    input wire iClr,
    output reg oB, 
    output reg oMult
);

    reg [BITWIDTH-1:0] iB_buff; //to store a value in block
    wire [BITWIDTH-1:0] sobolseq;

    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            iB_buff <= 0;
        end else begin
            if(loadB) begin
                iB_buff <= iB;
            end else begin
                iB_buff <= iB_buff;
            end
            
        end
    end

    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iA), 
        .iClr(iClr),
        .sobolseq(sobolseq)
    );

    always@(*) begin
        oB <= (iB_buff > sobolseq);
        oMult <= iA & (iB_buff > sobolseq);
    end

endmodule

`endif
