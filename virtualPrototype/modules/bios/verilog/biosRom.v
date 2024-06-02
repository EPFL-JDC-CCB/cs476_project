// Original top bios file: c/uartTest.c

module biosRom ( input wire        clock,
                 input wire [10:0] address,
                 output reg [31:0] romData);

  always @*
    case (address)
      11'b00000000000 : romData <= 32'hEFBEADDE;
      11'b00000000001 : romData <= 32'h00000015;
      11'b00000000010 : romData <= 32'h11000000;
      11'b00000000011 : romData <= 32'h00000015;
      11'b00000000100 : romData <= 32'h0F000000;
      11'b00000000101 : romData <= 32'h00000015;
      11'b00000000110 : romData <= 32'h0D000000;
      11'b00000000111 : romData <= 32'h00000015;
      11'b00000001000 : romData <= 32'h0B000000;
      11'b00000001001 : romData <= 32'h00000015;
      11'b00000001010 : romData <= 32'h09000000;
      11'b00000001011 : romData <= 32'h00000015;
      11'b00000001100 : romData <= 32'h00C02018;
      11'b00000001101 : romData <= 32'hFC1F21A8;
      11'b00000001110 : romData <= 32'h050060E0;
      11'b00000001111 : romData <= 32'hC2000004;
      11'b00000010000 : romData <= 32'h050080E0;
      11'b00000010010 : romData <= 32'h00000015;
      11'b00000010011 : romData <= 32'h84FF219C;
      11'b00000010100 : romData <= 32'h001001D4;
      11'b00000010101 : romData <= 32'h041801D4;
      11'b00000010110 : romData <= 32'h082001D4;
      11'b00000010111 : romData <= 32'h0C2801D4;
      11'b00000011000 : romData <= 32'h103001D4;
      11'b00000011001 : romData <= 32'h143801D4;
      11'b00000011010 : romData <= 32'h184001D4;
      11'b00000011011 : romData <= 32'h1C4801D4;
      11'b00000011100 : romData <= 32'h205001D4;
      11'b00000011101 : romData <= 32'h245801D4;
      11'b00000011110 : romData <= 32'h286001D4;
      11'b00000011111 : romData <= 32'h2C6801D4;
      11'b00000100000 : romData <= 32'h307001D4;
      11'b00000100001 : romData <= 32'h347801D4;
      11'b00000100010 : romData <= 32'h388001D4;
      11'b00000100011 : romData <= 32'h3C8801D4;
      11'b00000100100 : romData <= 32'h409001D4;
      11'b00000100101 : romData <= 32'h449801D4;
      11'b00000100110 : romData <= 32'h48A001D4;
      11'b00000100111 : romData <= 32'h4CA801D4;
      11'b00000101000 : romData <= 32'h50B001D4;
      11'b00000101001 : romData <= 32'h54B801D4;
      11'b00000101010 : romData <= 32'h58C001D4;
      11'b00000101011 : romData <= 32'h5CC801D4;
      11'b00000101100 : romData <= 32'h60D001D4;
      11'b00000101101 : romData <= 32'h64D801D4;
      11'b00000101110 : romData <= 32'h68E001D4;
      11'b00000101111 : romData <= 32'h6CE801D4;
      11'b00000110000 : romData <= 32'h70F001D4;
      11'b00000110001 : romData <= 32'h74F801D4;
      11'b00000110010 : romData <= 32'h1200E0B7;
      11'b00000110011 : romData <= 32'h0200FFBB;
      11'b00000110100 : romData <= 32'h00F0C01B;
      11'b00000110101 : romData <= 32'h6C01DEAB;
      11'b00000110110 : romData <= 32'h00F8DEE3;
      11'b00000110111 : romData <= 32'h0000FE87;
      11'b00000111000 : romData <= 32'h00F80048;
      11'b00000111001 : romData <= 32'h00000015;
      11'b00000111010 : romData <= 32'h00004184;
      11'b00000111011 : romData <= 32'h04006184;
      11'b00000111100 : romData <= 32'h08008184;
      11'b00000111101 : romData <= 32'h0C00A184;
      11'b00000111110 : romData <= 32'h1000C184;
      11'b00000111111 : romData <= 32'h1400E184;
      11'b00001000000 : romData <= 32'h18000185;
      11'b00001000001 : romData <= 32'h1C002185;
      11'b00001000010 : romData <= 32'h20004185;
      11'b00001000011 : romData <= 32'h24006185;
      11'b00001000100 : romData <= 32'h28008185;
      11'b00001000101 : romData <= 32'h2C00A185;
      11'b00001000110 : romData <= 32'h3000C185;
      11'b00001000111 : romData <= 32'h3400E185;
      11'b00001001000 : romData <= 32'h38000186;
      11'b00001001001 : romData <= 32'h3C002186;
      11'b00001001010 : romData <= 32'h40004186;
      11'b00001001011 : romData <= 32'h44006186;
      11'b00001001100 : romData <= 32'h48008186;
      11'b00001001101 : romData <= 32'h4C00A186;
      11'b00001001110 : romData <= 32'h5000C186;
      11'b00001001111 : romData <= 32'h5400E186;
      11'b00001010000 : romData <= 32'h58000187;
      11'b00001010001 : romData <= 32'h5C002187;
      11'b00001010010 : romData <= 32'h60004187;
      11'b00001010011 : romData <= 32'h64006187;
      11'b00001010100 : romData <= 32'h68008187;
      11'b00001010101 : romData <= 32'h6C00A187;
      11'b00001010110 : romData <= 32'h7000C187;
      11'b00001010111 : romData <= 32'h7400E187;
      11'b00001011000 : romData <= 32'h7C00219C;
      11'b00001011001 : romData <= 32'h00000024;
      11'b00001011010 : romData <= 32'h00000015;
      11'b00001011011 : romData <= 32'h300000F0;
      11'b00001011100 : romData <= 32'h1C0300F0;
      11'b00001011101 : romData <= 32'h240300F0;
      11'b00001011110 : romData <= 32'h2C0300F0;
      11'b00001011111 : romData <= 32'h340300F0;
      11'b00001100000 : romData <= 32'h3C0300F0;
      11'b00001100001 : romData <= 32'h0050201A;
      11'b00001100010 : romData <= 32'h030071AA;
      11'b00001100011 : romData <= 32'h83FFA0AE;
      11'b00001100100 : romData <= 32'h00A813D8;
      11'b00001100101 : romData <= 32'h2800A0AA;
      11'b00001100110 : romData <= 32'h00A811D8;
      11'b00001100111 : romData <= 32'h010031AA;
      11'b00001101000 : romData <= 32'h000011D8;
      11'b00001101001 : romData <= 32'h030020AA;
      11'b00001101010 : romData <= 32'h008813D8;
      11'b00001101011 : romData <= 32'h00480044;
      11'b00001101100 : romData <= 32'h00000015;
      11'b00001101101 : romData <= 32'h0050601A;
      11'b00001101110 : romData <= 32'hFF0063A4;
      11'b00001101111 : romData <= 32'h0500B3AA;
      11'b00001110000 : romData <= 32'h0000358E;
      11'b00001110001 : romData <= 32'h400031A6;
      11'b00001110010 : romData <= 32'h0000E01A;
      11'b00001110011 : romData <= 32'h00B811E4;
      11'b00001110100 : romData <= 32'h05000010;
      11'b00001110101 : romData <= 32'h00000015;
      11'b00001110110 : romData <= 32'h001813D8;
      11'b00001110111 : romData <= 32'h00480044;
      11'b00001111000 : romData <= 32'h00000015;
      11'b00001111001 : romData <= 32'h00000015;
      11'b00001111010 : romData <= 32'hF6FFFF03;
      11'b00001111011 : romData <= 32'h00000015;
      11'b00001111100 : romData <= 32'h0050601A;
      11'b00001111101 : romData <= 32'h0500B3AA;
      11'b00001111110 : romData <= 32'h0000358E;
      11'b00001111111 : romData <= 32'h010031A6;
      11'b00010000000 : romData <= 32'h0000E01A;
      11'b00010000001 : romData <= 32'h00B811E4;
      11'b00010000010 : romData <= 32'hFCFFFF13;
      11'b00010000011 : romData <= 32'h00000015;
      11'b00010000100 : romData <= 32'h0000738D;
      11'b00010000101 : romData <= 32'h00480044;
      11'b00010000110 : romData <= 32'h00000015;
      11'b00010000111 : romData <= 32'hF0FF219C;
      11'b00010001000 : romData <= 32'hFF0063A4;
      11'b00010001001 : romData <= 32'h008001D4;
      11'b00010001010 : romData <= 32'hD0FF039E;
      11'b00010001011 : romData <= 32'hFF0030A6;
      11'b00010001100 : romData <= 32'h090060AA;
      11'b00010001101 : romData <= 32'h049001D4;
      11'b00010001110 : romData <= 32'h08A001D4;
      11'b00010001111 : romData <= 32'h009851E4;
      11'b00010010000 : romData <= 32'h0800000C;
      11'b00010010001 : romData <= 32'h0C4801D4;
      11'b00010010010 : romData <= 32'hBFFF239E;
      11'b00010010011 : romData <= 32'hFF0031A6;
      11'b00010010100 : romData <= 32'h050060AA;
      11'b00010010101 : romData <= 32'h009851E4;
      11'b00010010110 : romData <= 32'h18000010;
      11'b00010010111 : romData <= 32'hC9FF039E;
      11'b00010011000 : romData <= 32'h090040AA;
      11'b00010011001 : romData <= 32'h050080AA;
      11'b00010011010 : romData <= 32'hE2FFFF07;
      11'b00010011011 : romData <= 32'h00000015;
      11'b00010011100 : romData <= 32'hFF006BA5;
      11'b00010011101 : romData <= 32'hD0FF2B9E;
      11'b00010011110 : romData <= 32'hFF0071A6;
      11'b00010011111 : romData <= 32'h009053E4;
      11'b00010100000 : romData <= 32'h04000010;
      11'b00010100001 : romData <= 32'h0400A0AA;
      11'b00010100010 : romData <= 32'h08A810E2;
      11'b00010100011 : romData <= 32'h008011E2;
      11'b00010100100 : romData <= 32'hBFFF2B9E;
      11'b00010100101 : romData <= 32'hFF0031A6;
      11'b00010100110 : romData <= 32'h00A051E4;
      11'b00010100111 : romData <= 32'h10000010;
      11'b00010101000 : romData <= 32'h9FFF2B9E;
      11'b00010101001 : romData <= 32'h040020AA;
      11'b00010101010 : romData <= 32'h088810E2;
      11'b00010101011 : romData <= 32'hC9FF6B9D;
      11'b00010101100 : romData <= 32'hEEFFFF03;
      11'b00010101101 : romData <= 32'h00800BE2;
      11'b00010101110 : romData <= 32'h9FFF239E;
      11'b00010101111 : romData <= 32'hFF0031A6;
      11'b00010110000 : romData <= 32'h009851E4;
      11'b00010110001 : romData <= 32'h04000010;
      11'b00010110010 : romData <= 32'h00000015;
      11'b00010110011 : romData <= 32'hE5FFFF03;
      11'b00010110100 : romData <= 32'hA9FF039E;
      11'b00010110101 : romData <= 32'hE3FFFF03;
      11'b00010110110 : romData <= 32'h0000001A;
      11'b00010110111 : romData <= 32'hFF0031A6;
      11'b00010111000 : romData <= 32'h00A051E4;
      11'b00010111001 : romData <= 32'h05000010;
      11'b00010111010 : romData <= 32'h040020AA;
      11'b00010111011 : romData <= 32'h088810E2;
      11'b00010111100 : romData <= 32'hF0FFFF03;
      11'b00010111101 : romData <= 32'hA9FF6B9D;
      11'b00010111110 : romData <= 32'h0090B3E4;
      11'b00010111111 : romData <= 32'hDBFFFF13;
      11'b00011000000 : romData <= 32'h048070E1;
      11'b00011000001 : romData <= 32'h04004186;
      11'b00011000010 : romData <= 32'h00000186;
      11'b00011000011 : romData <= 32'h08008186;
      11'b00011000100 : romData <= 32'h0C002185;
      11'b00011000101 : romData <= 32'h00480044;
      11'b00011000110 : romData <= 32'h1000219C;
      11'b00011000111 : romData <= 32'h00480044;
      11'b00011001000 : romData <= 32'h00000015;
      11'b00011001001 : romData <= 32'h00480044;
      11'b00011001010 : romData <= 32'h00000015;
      11'b00011001011 : romData <= 32'h00480044;
      11'b00011001100 : romData <= 32'h00000015;
      11'b00011001101 : romData <= 32'h00480044;
      11'b00011001110 : romData <= 32'h00000015;
      11'b00011001111 : romData <= 32'h00480044;
      11'b00011010000 : romData <= 32'h00000015;
      11'b00011010001 : romData <= 32'hF8FF219C;
      11'b00011010010 : romData <= 32'h008001D4;
      11'b00011010011 : romData <= 32'h044801D4;
      11'b00011010100 : romData <= 32'h8DFFFF07;
      11'b00011010101 : romData <= 32'h610000AA;
      11'b00011010110 : romData <= 32'h97FFFF07;
      11'b00011010111 : romData <= 32'h048070E0;
      11'b00011011000 : romData <= 32'hFEFFFF03;
      11'b00011011001 : romData <= 32'h00000015;
      default : romData <= 32'd0;
    endcase

endmodule

