module VGA_TOP#(
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
) (
    input CLK,
    input RST,
    input [rgb_width-1:0] rgb_in,
    output [$clog2(H_ACTIVE*V_ACTIVE)-1:0] addr,
    output h_sync,
    output v_sync,
    output [rgb_width-1:0] RGB
);
wire [red_width-1:0] red;
wire [green_width-1:0] green;
wire [blue_width-1:0] blue;
wire [$clog2(H_SYNC + H_BACK + H_ACTIVE + H_FRONT)-1:0] pixel_x;
wire [$clog2(V_SYNC + V_BACK + V_ACTIVE + V_FRONT)-1:0] pixel_y;
wire video_on;

assign RGB = {red, green, blue};
assign addr = pixel_y * H_ACTIVE + pixel_x; // el address bta3 pixel (0.0)->0 (639.479)->307199

VGA_SYNC #(
    .H_SYNC(H_SYNC),
    .H_BACK(H_BACK),
    .H_ACTIVE(H_ACTIVE),
    .H_FRONT(H_FRONT),
    .V_SYNC(V_SYNC),
    .V_BACK(V_BACK),
    .V_ACTIVE(V_ACTIVE),
    .V_FRONT(V_FRONT)
) U0 (
    .CLK(CLK),
    .RST(RST),
    .pixel_x(pixel_x),
    .pixel_y(pixel_y),
    .h_sync(h_sync),
    .v_sync(v_sync),
    .video_on(video_on)
);

RGB #(
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
) U1 (
    .video_on(video_on),
    .rgb_in(rgb_in),
    .red(red),
    .green(green),
    .blue(blue)
);

    
endmodule
