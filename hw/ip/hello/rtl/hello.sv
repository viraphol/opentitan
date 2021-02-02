
module hello();
    initial begin
        $display("Hello DUT");
        #20 $finish();
    end
endmodule
