`timescale 1ns/1ps
module VGA_TOP_TB#(
    parameter rgb_width =8,
              red_width = 3,
              green_width = 3,
              blue_width = 2,
              H_BACK = 48,
              H_ACTIVE = 640,
              H_FRONT = 16,
              H_SYNC = 96,
              V_SYNC = 2,
              V_BACK = 33,
              V_ACTIVE = 480,
              V_FRONT = 10
) ();
    reg CLK_tb;
    reg RST_tb;
    reg [rgb_width-1:0] rgb_in_tb;
    wire [$clog2(H_ACTIVE*V_ACTIVE)-1:0] addr;
    wire h_sync;
    wire v_sync;
    wire [rgb_width-1:0] RGB;
    integer t_fall, t_rise;
    integer h_low, v_low;

parameter CLK_PERIOD = 40;

initial 
begin
    $dumpfile("VGA_TOP.vcd");
    $dumpvars();
    initializer();
    // h_sync low width lazem yeb2a 96 clk
    @(negedge h_sync) t_fall = $time;
    @(posedge h_sync) t_rise = $time;
    h_low = (t_rise - t_fall) / CLK_PERIOD;

    if (h_low == H_SYNC)
    begin
    $display("PASS: h_sync low = %0d clks", h_low);
    end
    else
    begin
        $display("FAIL: h_sync low = %0d clks (expected %0d)", h_low, H_SYNC);
    end

    // v_sync low width lazem yeb2a 2 clk* 800 frame
    @(negedge v_sync) t_fall = $time;
    @(posedge v_sync) t_rise = $time;
    v_low = (t_rise - t_fall) / CLK_PERIOD;
    if (v_low == 1600) 
    begin
        $display("PASS: v_sync low = %0d clks", v_low);
    end
    else
    begin
        $display("FAIL: v_sync low = %0d clks (expected %0d)", v_low, V_SYNC);
    end
    #(CLK_PERIOD*6)
    $stop;


end

always #(CLK_PERIOD/2) CLK_tb = ~CLK_tb;

VGA_TOP #(
    .rgb_width(rgb_width),
    .red_width(red_width),
    .green_width(green_width),
    .blue_width(blue_width),
    .H_BACK(H_BACK),
    .H_ACTIVE(H_ACTIVE),
    .H_FRONT(H_FRONT),
    .H_SYNC(H_SYNC),
    .V_SYNC(V_SYNC),
    .V_BACK(V_BACK),
    .V_ACTIVE(V_ACTIVE),
    .V_FRONT(V_FRONT)
) DUT (
    .CLK(CLK_tb),
    .RST(RST_tb),
    .rgb_in(rgb_in_tb),
    .addr(addr),
    .h_sync(h_sync),
    .v_sync(v_sync),
    .RGB(RGB)
);

task initializer();
    begin
        RST_tb = 0;
        rgb_in_tb = 8'b11111111;
        CLK_tb = 0;
        #(CLK_PERIOD*2) 
        RST_tb = 1;
    end
endtask
    
endmodule
