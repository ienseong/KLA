// `timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////
// Title: gain_pred_top_tb
// Project: Voyager2 
// File: gain_pred_top_tb

//////////////////////////////////////////////////////////////////////////////////


module sub_pixel_delay
    #(parameter L=4)
    (
    input clk,
    input reset,
    input [9:0] clk_cnt,
    
    input [13:0]  sample_in0,
    input [13:0]  sample_in1,
    input [13:0]  sample_in2,
    input [13:0]  sample_in3,
    
    input sample_in_v,
    
    // Fractional shift
    input [7:0]  fract_steps,
    input shift_dir
    
    // Output gain samples
    // output reg [13:0]  sample_out_A[L-1:0],
    // output reg [13:0]  sample_out_B[L-1:0]

    // output reg [13:0]  sample_out_A[0],
    // output reg [13:0]  sample_out_B[0],

    // output reg [13:0]  sample_out_A[1],
    // output reg [13:0]  sample_out_B[1],

    // output reg [13:0]  sample_out_A[2],
    // output reg [13:0]  sample_out_B[2],

    // output reg [13:0]  sample_out_A[3],
    // output reg [13:0]  sample_out_B[3]

    );
    localparam DELAY=1'd1;
    // reg [9:0] k='b0;
    // wire [9:0] k;
    reg [9:0] k_d1, k_d2='b0;
    
    // wire [13:0] sample_in[3:0];
    reg [13:0] sample_in[3:0];
    reg [13:0] sample_in_temp[3:0];
    wire [13:0] sample_d_in[3:0];

    

    reg sample_in_v_d1='b0;

    wire [13:0] sample_out_A[3:0];
    wire [13:0] sample_out_B[3:0];
    
    integer i;

    // reg [13:0] A_pix[L-1:0]      ='b1;
    // reg [13:0] D_pix_prev[L-1:0] ='b0,
    // reg [13:0] D_pix_next[L-1:0] ='b0,
    // reg [21:0] C_pix[L-1:0]      ='b0;

    reg [13:0] A_pix[L-1:0]      ;
    reg [13:0] D_pix_prev[L-1:0] ;
    reg [13:0] D_pix_next[L-1:0] ;
    reg [21:0] C_pix[L-1:0]      ;
    
   

    
    always@(posedge clk) begin // 2 clock delay from LUT input to output
        if(sample_in_v=='b1) begin
            sample_in_v_d1 <= sample_in_v; 
        end
    end  

    
    reg [13:0] sample_in_prev_idx3[L-1:0];


    // always@(posedge clk) begin
    //     if(reset==0) begin
    //     end

    //     else if(sample_in_v_d1=='b1) begin
    //         k_d1 <= clk_cnt; //count index from LUT

    //         sample_in_v_d1 = sample_in_v;

    //         sample_in[0] <= sample_in0<<9;
    //         sample_in[1] <= sample_in1<<9;
    //         sample_in[2] <= sample_in2<<9;
    //         sample_in[3] <= sample_in3<<9;
    
    //         $display("k = %d, k%4= %d ",k_d1, k_d1%4);
    //     end
    // end

    always@(posedge clk) begin
            k_d1 <= clk_cnt; //count index from LUT

            sample_in_v_d1 <= sample_in_v;

            sample_in[0] <= sample_in0<<9;
            sample_in[1] <= sample_in1<<9;
            sample_in[2] <= sample_in2<<9;
            sample_in[3] <= sample_in3<<9;

            // sample_in_temp[0] <= sample_in[0];
            // sample_in_temp[1] <= sample_in[1];
            // sample_in_temp[2] <= sample_in[2];
            // sample_in_temp[3] <= sample_in[3];
    end

    always@(posedge clk) begin
        if(k_d1>=1)
            k_d2<= k_d2 +1;

        if(k_d2>=1) begin
            sample_in_temp[0] <= sample_d_in[0];
            sample_in_temp[1] <= sample_d_in[1];
            sample_in_temp[2] <= sample_d_in[2];
            sample_in_temp[3] <= sample_d_in[3];
        end
    end

    c_shift_ram_0 c_shift_ram_0(
        // .A(DELAY-1),
        .D(sample_in[0]),
        .clk(clk),
        .Q(sample_d_in[0])
    );

    c_shift_ram_0 c_shift_ram_1(
        // .A(DELAY-1),
        .D(sample_in[1]),
        .clk(clk),
        .Q(sample_d_in[1])
    );

    c_shift_ram_0 c_shift_ram_2(
        // .A(DELAY-1),
        .D(sample_in[2]),
        .clk(clk),
        .Q(sample_d_in[2])
    );

    c_shift_ram_0 c_shift_ram_3(
        // .A(DELAY-1),
        .D(sample_in[3]),
        .clk(clk),
        .Q(sample_d_in[3])

    );

    generate 
        genvar j;
        for(j=0;j<L;j=j+1) begin

            single_interp single_interp(    
                .clk(clk),
                .reset(reset),
                .sample_in_v(sample_in_v_d1),
                
                .fract_steps(fract_steps),
                .shift_dir(shift_dir),
                
                .A_pix(A_pix[j]),
                .D_pix_prev(D_pix_prev[j]),
                .D_pix_next(D_pix_next[j]),
                .C_pix(C_pix[j]),
                
                .sample_out_A(sample_out_A[j]),
                .sample_out_B(sample_out_B[j])
                
            );

            always@(posedge clk) begin
                if(reset==0) begin
                    A_pix[j] <= 'b0;
                    D_pix_prev[j] <= 'b0;
                    D_pix_next[j] <= 'b0;
                    C_pix[j] <= 'b0;
                end

                else if(sample_in_v_d1=='b1) begin
                    // if(k==0) begin
                    if(j==0) begin
                        A_pix[j]      <= sample_d_in[0];
                        D_pix_prev[j] <= sample_d_in[0];
                        D_pix_next[j] <= sample_d_in[1];
                        C_pix[j] <= sample_d_in[0];// 0.10.9 + add 0.3.0+ = 0.13.9 = 13+9=22 bits            
                        sample_in_prev_idx3[j] <= sample_in_temp[3];
                    end
                    else begin 
                        // case (j%4)
                        //     0: begin
                        //         A_pix[j] <= sample_in[j][k_d1%4];
                        //         C_pix[j] <= sample_in[j][k_d1%4]<<5;// 0.10.9 + add 0.3.0+ = 0.13.9 = 13+9=22 bits            
                            
                        //         D_pix_prev[j] <= sample_in_prev_idx3[j];
                        //         D_pix_next[j] <= sample_in[j][k_d1%4+1];
                        //     end
                        //     1,2: begin
                        //         A_pix[j] <= sample_in[j][k_d1%4];
                        //         C_pix[j] <= sample_in[j][k_d1%4]<<5;// 0.10.9 + add 0.3.0+ = 0.13.9 = 13+9=22 bits            
                            
                        //         D_pix_prev[j] <= sample_in[j-1];
                        //         D_pix_next[j] <= sample_in[j][k_d1%4+1];
                        //     end

                        //     3: begin
                        //         A_pix[j] <= sample_in[j][k_d1%4];
                        //         C_pix[j] <= sample_in[j][k_d1%4]<<5;// 0.10.9 + add 0.3.0+ = 0.13.9 = 13+9=22 bits            
                            
                        //         D_pix_prev[j] <= sample_in[j][k_d1%4-1];
                        //         D_pix_next[j] <= sample_in[j][0];
                        //     end
                        
                        // endcase
                        A_pix[j] <= sample_d_in[j];
                        C_pix[j] <= sample_d_in[j]<<5;// 0.10.9 + add 0.3.0+ = 0.13.9 = 13+9=22 bits            
                            
                        

                        case (j%4)
                            0: begin
                                sample_in_prev_idx3[j]<=sample_in_temp[3];        
                                D_pix_prev[j] <= sample_in_prev_idx3[0];
                                D_pix_next[j] <= sample_d_in[j+1];
                            end
                            1,2: begin
                                sample_in_prev_idx3[j]<=sample_d_in[j-1];        
                                // D_pix_prev[j] <= sample_in[j-1];
                                D_pix_prev[j] <= sample_in_prev_idx3[j];
                                D_pix_next[j] <= sample_d_in[j+1];
                            end

                            3: begin
                                sample_in_prev_idx3[j]<=sample_d_in[j-1];        
                                D_pix_prev[j] <= sample_in_prev_idx3[j-1];
                                D_pix_next[j] <= sample_in[0];
                                
                            end
                        
                        endcase
                        
                            // case (k%4)
                            //     0: begin
                            //         D_pix_prev <= sample_in[3];
                            //         D_pix_next <= sample_in[k%4+1];
                                    
                            //     end
                            //     1,2: begin
                            //         D_pix_prev <= sample_in[k%4-1];
                            //         D_pix_next <= sample_in[k%4+1];
                            //     end
                            //     3: begin
                            //         D_pix_prev <= sample_in[k%4-1];
                            //         D_pix_next <= sample_in[0];
                            //     end
                            // endcase
                        // end
                    end
                end
            
            end
        end
    endgenerate
endmodule

    














