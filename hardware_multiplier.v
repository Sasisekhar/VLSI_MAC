module hardware_multiplier (
    input clk,                     // Input clock signal
    input nreset,                  // Input active low reset signal
    input [7:0] a,                 // 8-bit input data signal 'a'
    input [7:0] b,                 // 8-bit input data signal 'b'
    output reg [15:0] r            // 16-bit output signal 'r'
);

    // Internal signals for partial products and addition
    wire [15:0] partial_products[7:0];

    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_partial_products
            assign partial_products[i] = b[i] ? (a << i) : 0;
        end
    endgenerate

    // Sum the partial products
    wire [15:0] sum;
    wire carry;

    // Using a simple ripple-carry adder for demonstration
    assign {carry, sum} = partial_products[0] + partial_products[1] + 
                          partial_products[2] + partial_products[3] + 
                          partial_products[4] + partial_products[5] + 
                          partial_products[6] + partial_products[7];

    // Sequential logic for reset and output assignment
    always @(posedge clk or negedge nreset) begin
        if (!nreset) begin
            // Active low reset: clear the output
            r <= 0;
        end
        else begin
            // On clock edge, assign the sum of partial products to output
            r <= sum;
        end
    end

endmodule
