`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Engineer: Shreyashi Chakraborty
// 
// Create Date: 20/08/25
// Design Name: 
// Module Name: async_fifo
// Project Name: Asynchronous Fifo
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module async_fifo(
wr_clk,rd_clk,wr_data,rd_data,rst,wr_en,rd_en,valid,empty,full
    );
parameter DATA_WIDTH=8;
parameter FIFO_DEPTH=8;
parameter ADD_WIDTH=3;
input wr_clk;
input rd_clk;
input[DATA_WIDTH-1:0] wr_data;
output reg [DATA_WIDTH-1:0] rd_data;
input rst;
input wr_en;
input rd_en;
output valid;
output reg empty;
output reg full;

wire[ADD_WIDTH:0] wr_bin_next,rd_bin_next,wr_g_next,rd_g_next;
reg[ADD_WIDTH:0] wr_bin,rd_bin,wr_g,rd_g,wr_g_s1,rd_g_s1,wr_g_s2,rd_g_s2;
wire[ADD_WIDTH-1:0] wr_address,rd_address;
reg [DATA_WIDTH-1:0] fifo [FIFO_DEPTH-1:0];
reg [ADD_WIDTH:0] wr_dff1,wr_dff2,rd_dff1,rd_dff2;

always@(posedge wr_clk) begin
if (rst) begin
wr_bin<=0;
wr_g<=0;
full<=0;
wr_dff1<=0;
wr_dff2<=0;
end
else begin
wr_bin<=wr_bin_next;
wr_g<=wr_g_next;
full<=full_val;
wr_dff1<=wr_bin;
wr_dff2<=wr_dff1;
end
end

always@(posedge wr_clk) begin
if (rst) begin
rd_g_s1<=0;
rd_g_s2<=0;
end
else begin
rd_g_s1<=rd_g;
rd_g_s2<=rd_g_s1;
end
end



assign wr_bin_next=wr_bin+(wr_en & !full);
assign wr_g_next= (wr_bin_next)^(wr_bin_next>>1);
assign wr_address=wr_dff2[ADD_WIDTH-1:0];

assign full_val= (wr_g_next == {!(rd_g_s2[ADD_WIDTH:ADD_WIDTH-1]),(rd_g_s2[ADD_WIDTH-1:0])});




always@(posedge wr_clk) begin
if (wr_en & !full) begin
fifo[wr_address]<=wr_data;
end
end



//Read

always@(posedge rd_clk or posedge rst) begin
if (rst) begin
rd_bin<=0;
rd_g<=0;
rd_dff1<=0;
rd_dff2<=0;
empty<=1;
end
else begin
rd_bin<=rd_bin_next;
rd_g<=rd_g_next;
empty<=empty_val;
rd_dff1<=rd_bin;
rd_dff2<=rd_dff1;
end
end

always@(posedge rd_clk or posedge rst) begin
if (rst) begin
wr_g_s1<=0;
wr_g_s2<=0;
end
else begin
wr_g_s1<=wr_g;
wr_g_s2<=wr_g_s1;
end
end



assign rd_bin_next=rd_bin+(rd_en & !empty);
assign rd_g_next= (rd_bin_next)^(rd_bin_next>>1);
assign rd_address=rd_dff2[ADD_WIDTH-1:0];

assign empty_val= (rd_g_next == wr_g_s2[ADD_WIDTH:0]);

always@(posedge rd_clk) begin
if (rd_en & !empty) begin
rd_data<=fifo[rd_address];
end
end



endmodule

interface fifo_if;
  
  logic wr_clk,rd_clk, rd_en, wr_en;         // Clock, read, and write signals
  logic full, empty, valid;           // Flags indicating FIFO status
  logic [7:0] wr_data;         // Data input
  logic [7:0] rd_data;        // Data output
  logic rst;                   // Reset signal
 
endinterface

