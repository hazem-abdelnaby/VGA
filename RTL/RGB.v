module RGB#(
    parameter rgb_width =8,
              red_width = 3,
              green_width = 3,
              blue_width = 2,
              H_SYNC = 96,
              H_BACK = 48,
              H_ACTIVE = 640,
              H_FRONT = 16,
              V_SYNC = 2,
              V_BACK = 33,
              V_ACTIVE = 480,
              V_FRONT = 10
) (
    input video_on,
    input [rgb_width-1:0] rgb_in,
    output [red_width-1:0] red,
    output [green_width-1:0] green,
    output [blue_width-1:0] blue
);
wire [rgb_width-1:0] rgb_out;

assign rgb_out = (video_on) ? rgb_in : 'b0; //MUX el sel bta3o howa video_on 3la4an lw el video_on
assign red = rgb_out[rgb_width-1:rgb_width-red_width];// el 3 bits elly msb ll red
assign green = rgb_out[rgb_width-red_width-1:rgb_width-red_width-green_width];// el 3 bits elly ba3d el red green
assign blue = rgb_out[rgb_width-red_width-green_width-1:0];// el fadlen ll blue

    
endmodule
