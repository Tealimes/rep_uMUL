`include "sobolrng.v"


module rep_uMUL #(
    parameter BITWIDTH = 8
) (
    input wire iClk,
    input wire iRstN,
    input wire A,
    input wire [BITWIDTH - 1: 0] B,
    input wire loadB,
    input wire iClr,
    output reg oB, //delete maybe
    output reg mult
);

    reg [BITWIDTH-1:0] iB_buff; //to store a value in block so reg
    wire [BITWIDTH-1:0] sobolseq;

    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            iB_buff <= 0;
        end else begin
            if(loadB) begin
                iB_buff <= B;
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
        .iEn(A), 
        .iClr(iClr),
        .sobolseq(sobolseq)
    );

    always@(*) begin
        oB <= (iB_buff > sobolseq);
        mult <= A & (iB_buff > sobolseq);
    end



endmodule
