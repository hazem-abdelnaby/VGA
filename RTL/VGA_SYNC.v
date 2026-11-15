module VGA_SYNC#(
    parameter H_SYNC = 96,
              H_BACK = 48,
              H_ACTIVE = 640,
              H_FRONT = 16,
              V_SYNC = 2,
              V_BACK = 33,
              V_ACTIVE = 480,
              V_FRONT = 10
) (
    input CLK,
    input RST,
    output [$clog2(H_SYNC + H_BACK + H_ACTIVE + H_FRONT)-1:0] pixel_x,
    output [$clog2(V_SYNC + V_BACK + V_ACTIVE + V_FRONT)-1:0] pixel_y,
    output reg h_sync,
    output reg v_sync,
    output reg video_on
);


// Horizontal and vertical counters 3la $clog2 3la4an a7sb 3la 7sb el total 3la4an a3rf el range bta3 el counter 
reg [$clog2(H_SYNC + H_BACK + H_ACTIVE + H_FRONT)-1:0] H_CNT;
reg [$clog2(V_SYNC + V_BACK + V_ACTIVE + V_FRONT)-1:0] V_CNT;

assign pixel_x = H_CNT;
assign pixel_y = V_CNT;


// Horizontal and vertical counters block
always @(posedge CLK or negedge RST) 
begin
    if (!RST) 
    begin
        H_CNT <= 0;
        V_CNT <= 0;
    end 
    else 
    begin
        if (H_CNT == (H_SYNC + H_BACK + H_ACTIVE + H_FRONT) - 1) 
        begin
            H_CNT <= 0;
            if (V_CNT == (V_SYNC + V_BACK + V_ACTIVE + V_FRONT) - 1) 
            begin
                V_CNT <= 0;
            end 
            else 
            begin
                V_CNT <= V_CNT + 1;
            end
        end 
        else 
        begin
            H_CNT <= H_CNT + 1;
        end
    end
end

// Horizontal and vertical sync signals block
always @(*)
begin
    if (H_CNT > (H_ACTIVE+H_FRONT)-1&& H_CNT < (H_ACTIVE+H_SYNC+H_FRONT))
    begin 
        h_sync = 1'b0;
    end
    else
    begin 
        h_sync = 1'b1;
    end
    if (V_CNT > (V_ACTIVE+V_FRONT)-1&& V_CNT < (V_ACTIVE+V_SYNC+V_FRONT)) 
    begin
        v_sync = 1'b0;
    end
    else
    begin 
        v_sync = 1'b1;
    end
end

// Video on signal bock
always @(*)
begin
    if ((H_CNT < H_ACTIVE) && (V_CNT < V_ACTIVE)) 
    begin
        video_on = 1'b1;
    end
    else 
    begin
        video_on = 1'b0;
    end
end


endmodule
