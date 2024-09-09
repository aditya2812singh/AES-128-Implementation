//1-byte:8-bits
//word(shortint): 16-bits i.e. 2-byte
`define INPUT_TEXT 'h00112233445566778899aabbccddeeff
parameter AES_BLOCK_SIZE = 16;
parameter AES_ROUNDS     = 10;
parameter Nb             = 4;
parameter Nr             = 10;
//module cipher(input byte plain_text[4*Nb], input byte out[4*Nb], output shortint round_keys_array[Nb*(Nr+1)]);
module cipher();
bit [127:0]input_text;//128bits
bit [127:0]input_round_keys[(AES_ROUNDS+1)];
byte plain_text[AES_BLOCK_SIZE];//16 byte i.e. 128 bits plain text
byte round_key[(AES_ROUNDS+1)][AES_BLOCK_SIZE];
byte plain_text_2d[Nb][Nb];                  // TO USE
byte round_key_2d[(AES_ROUNDS+1)][Nb][Nb];   // TO USE
byte state[Nb][Nb];
byte sbox[16][16];
byte inv_sbox[16][16];
byte multiply_matrix[Nb][Nb];
byte inv_transform_matrix[Nb][Nb];
bit [127:0] state_plain;
string txt;

task fill_round_keys_arrays();
   int counter;
   input_round_keys[0] ='h 000102030405060708090a0b0c0d0e0f;
   input_round_keys[1] ='h d6aa74fdd2af72fadaa678f1d6ab76fe;
   input_round_keys[2] ='h b692cf0b643dbdf1be9bc5006830b3fe;
   input_round_keys[3] ='h b6ff744ed2c2c9bf6c590cbf0469bf41;
   input_round_keys[4] ='h 47f7f7bc95353e03f96c32bcfd058dfd;
   input_round_keys[5] ='h 3caaa3e8a99f9deb50f3af57adf622aa;
   input_round_keys[6] ='h 5e390f7df7a69296a7553dc10aa31f6b;
   input_round_keys[7] ='h 14f9701ae35fe28c440adf4d4ea9c026;
   input_round_keys[8] ='h 47438735a41c65b9e016baf4aebf7ad2;
   input_round_keys[9] ='h 549932d1f08557681093ed9cbe2c974e;
   input_round_keys[10] ='h 13111d7fe3944a17f307a78b4d2b30c5;

   for(int j=0; j<AES_ROUNDS+1; j++)begin
      for(int i=0;i<16;i++)begin
         round_key[j][i]= input_round_keys[j][127:120];
         input_round_keys[j]=input_round_keys[j]<<8;
         //$display("round key[%0d][%0d]=%0h,%0h",j,i,round_key[j][i],input_round_keys[j]);
      end
   end

   counter=0;
   for(int num_rnd_key_array=0;num_rnd_key_array<(AES_ROUNDS+1);num_rnd_key_array++)begin
      for(int i=0;i<Nb;i++) begin
         for(int j=0;j<Nb;j++) begin
            round_key_2d[num_rnd_key_array][j][i] = round_key[num_rnd_key_array][counter];
            counter++;
         end
      end
      counter=0;
   end

endtask

task fill_plain_text_array();
   //input_text='h00112233445566778899aabbccddeeff;//128 bits plain text 
   input_text=`INPUT_TEXT;//128 bits plain text 
   foreach(plain_text[i])begin
      plain_text[i]= input_text[127:120];
      input_text= input_text<<8;
      //$display("plain text[%0d]=%0h,%0h",i,plain_text[i],input_text);
   end
   convert_plain_text_1d_to_2d();
endtask

task convert_plain_text_1d_to_2d();
   int counter;
   counter=0;
   for(int i=0;i<Nb;i++) begin
      for(int j=0;j<Nb;j++) begin
         plain_text_2d[j][i] = plain_text[counter];
         counter++;
      end
   end

// //Display Logic-----------------------------------------------------------------------------
//    for(int i=0;i<Nb;i++) begin
//       for(int j=0;j<Nb;j++) begin
//          $write("%0h ",plain_text_2d[i][j]);
//       end
//       $display("");
//    end
// //Display Logic-----------------------------------------------------------------------------
endtask

task addroundkey(int round_num);
//byte plain_text_2d[Nb][Nb];                  // TO USE
//byte round_key_2d[(AES_ROUNDS+1)][Nb][Nb];   // TO USE
if(round_num==0)begin
   for(int i=0;i<Nb;i++) begin
      for(int j=0;j<Nb;j++) begin
         state[i][j]=plain_text_2d[i][j]^round_key_2d[round_num][i][j];
      end
   end
end
else begin
   for(int i=0;i<Nb;i++) begin
      for(int j=0;j<Nb;j++) begin
         state[i][j]=state[i][j]^round_key_2d[round_num][i][j];
      end
   end
end
   //display_state();
endtask

task inv_addroundkey(int round_num);
//byte plain_text_2d[Nb][Nb];                  // TO USE
//byte round_key_2d[(AES_ROUNDS+1)][Nb][Nb];   // TO USE
for(int i=0;i<Nb;i++) begin
   for(int j=0;j<Nb;j++) begin
      state[i][j]=state[i][j]^round_key_2d[round_num][i][j];
   end
end
endtask

task state_to_plain();
   int k;
   k=0;
   state_plain = 128'h0;
   for(int i=0;i<4;i=i+1) begin
      for(int j=0;j<4;j=j+1) begin
         //state_plain=(state_plain << Nb)|state[i][j];
         state_plain[127-k*8-:8] = state[j][i];
         k=k+1;
      end
   end
   //$display("State in text format=  %02h",state_plain);
   //$write("State in text format=  %02x",state_plain);
   txt=$sformatf("%032h", state_plain);
   $display("In text format=  %s",txt);
   $display("");
   $display("------------------------------------");
endtask

task display_state();
// temp Display Logic-----------------------------------------------------------------------------
   //$display("State Matrix after Roundkey operation=%0d",round_num);
   $display("------------------------------------");
   for(int i=0;i<Nb;i++) begin
      for(int j=0;j<Nb;j++) begin
         $write("%02h ",state[i][j]);
      end
      $display("");
   end
   //$display("-----------------------");
   $display("");
   state_to_plain();
//Display Logic-----------------------------------------------------------------------------
endtask

task subbytes();
   bit[7:0] temp;
   for(int i=0;i<Nb;i++) begin
      for(int j=0;j<Nb;j++) begin
         temp=state[i][j];
         state[i][j]=sbox[temp[7:4]][temp[3:0]];
      end
   end
   //display_state();
endtask

task inv_subbytes();
   bit[7:0] temp;
   for(int i=0;i<Nb;i++) begin
      for(int j=0;j<Nb;j++) begin
         temp=state[i][j];
         state[i][j]=inv_sbox[temp[7:4]][temp[3:0]];
      end
   end
   //display_state();
endtask

task shiftrow(); //shift left
byte temp_rotate;
for(int rotateby=0;rotateby<Nb;rotateby++)begin
   repeat(rotateby)begin
   for(int j=0;j<Nb;j++)begin
      temp_rotate=state[rotateby][Nb-1-j];
      state[rotateby][Nb-1-j]=state[rotateby][0];
      state[rotateby][0]=temp_rotate;
   end
   end
end
//display_state();
endtask

task inv_shiftrow(); //shift right
byte temp_rotate;
for(int rotateby=0;rotateby<Nb;rotateby++)begin
   repeat(rotateby)begin
   for(int j=Nb-1;j>=0;j--)begin
      temp_rotate=state[rotateby][Nb-1-j];
      state[rotateby][Nb-1-j]=state[rotateby][0];
      state[rotateby][0]=temp_rotate;
   end
   end
end
//display_state();
endtask

function byte gf_multiplication(input byte a, input byte b);
   byte result;
   byte temp_a;
   begin
      result = 8'h00;temp_a = a;
      if (b[0]) result ^= temp_a;
      for (int i = 1; i < 8; i++) begin
         if (temp_a[7]) begin
            temp_a = (temp_a*2); temp_a = temp_a^(8'h1b);
         end
         else begin
            temp_a = (temp_a*2);
         end
         if (b[i]) begin result = result^temp_a; end //added
      end
      gf_multiplication = result;
   end
endfunction

task mixcolumns();
   byte xr;
   byte temp_mixcol_matrix[Nb][Nb];

   for(int i=0;i<Nb;i++)begin
      for(int j=0;j<Nb;j++)begin
         xr=8'b0;
         for(int k=0;k<Nb;k++) begin
            xr=xr ^ gf_multiplication(multiply_matrix[i][k],state[k][j]);
         end
         temp_mixcol_matrix[i][j] = xr;
      end
   end
   for(int i=0;i<Nb;i++) begin
      for(int j=0;j<Nb;j++) begin
         state[i][j]=temp_mixcol_matrix[i][j];
      end
   end
   //display_state();
endtask

task inv_mixcolumns();
   byte xr;
   byte inv_temp_mixcol_matrix[Nb][Nb];

   for(int i=0;i<Nb;i++)begin
      for(int j=0;j<Nb;j++)begin
         xr=8'b0;
         for(int k=0;k<Nb;k++) begin
            xr=xr ^ gf_multiplication(inv_transform_matrix[i][k],state[k][j]);
         end
         inv_temp_mixcol_matrix[i][j] = xr;
      end
   end
   for(int i=0;i<Nb;i++) begin
      for(int j=0;j<Nb;j++) begin
         state[i][j]=inv_temp_mixcol_matrix[i][j];
      end
   end
   //display_state();
endtask

initial begin
   $display("====================================");
   $display("Implementation of AES-128 Encryption");
   $display("====================================");
   setup_sbox();
   fill_plain_text_array();
   fill_round_keys_arrays();

   begin//initial transformation
   addroundkey(0);
   //$display("---State Matrix after Round=0 is---"); 
   $display("Q1. What is the value (round[ 1].start) you obtain?");display_state();//Q1. What is the value (round[ 1].start) you obtain? 
   end

   for(int round=1;round<=9;round++)begin //additional rounds
      subbytes(); if(round==1) begin $display("Q2-3. What is the value (round[ 1].sbox) you obtain?");display_state();end//Q2-3. What is the value (round[ 1].sbox) you obtain? 
      shiftrow(); if(round==1) begin $display("Q4. What is the value (round[ 1].s_row) you obtain?");display_state();end//Q4. What is the value (round[ 1].s_row) you obtain?
      mixcolumns(); if(round==1) begin $display("Q5. What is the value (round[ 1].m_col) you obtain?");display_state();end//Q5. What is the value (round[ 1].m_col) you obtain?
      addroundkey(round); if(round==1) begin $display("Q6. What is the value (round[2].start) you obtain?");display_state();end//Q6. What is the value (round[2].start) you obtain?
      //$display("---State Matrix after Round=%0d is---",round);
   end

   $display("Q7. What is the value (round[10].start) you obtain?");display_state();//Q7. What is the value (round[10].start) you obtain?
   begin // last round
   subbytes();
   shiftrow();
   addroundkey(10);
   end
   $display("---State Matrix after Round=10, Encrypted Matrix is---"); $display("Q8. What is the value (cipher text) you obtain?");display_state();//Q8. What is the value (cipher text) you obtain?

   $display("");
   $display("====================================");
   $display("Implementation of AES-128 Decryption");
   $display("====================================");
   inv_setup_sbox();

   begin
   //use same round keys in descending order
    inv_addroundkey(10); //$display("state after inv_addroundkey=10");display_state();
    inv_shiftrow(); //$display("state after inv_shiftrow");display_state();
    inv_subbytes(); $display("state after initial inv_addroundkey=10");display_state();
   end

   begin
    for(int round=9;round>=1;round--)begin //additional rounds
       inv_addroundkey(round);//$display("inv_addroundkey");display_state(); //round
       inv_mixcolumns();
       inv_shiftrow(); //$display("inv_shiftrow");display_state();
       inv_subbytes(); $display("---State Matrix after Round=%0d is---",round);display_state();
    end
   end

   begin
    inv_addroundkey(0); $display("---State Matrix after Round=0, Decrypted matrix is=");display_state();
   end

end

task setup_sbox();
        sbox[0][0]  = 8'h63; sbox[0][1]  = 8'h7c; sbox[0][2]  = 8'h77; sbox[0][3]  = 8'h7b;
        sbox[0][4]  = 8'hf2; sbox[0][5]  = 8'h6b; sbox[0][6]  = 8'h6f; sbox[0][7]  = 8'hc5;
        sbox[0][8]  = 8'h30; sbox[0][9]  = 8'h01; sbox[0][10] = 8'h67; sbox[0][11] = 8'h2b;
        sbox[0][12] = 8'hfe; sbox[0][13] = 8'hd7; sbox[0][14] = 8'hab; sbox[0][15] = 8'h76;

        sbox[1][0]  = 8'hca; sbox[1][1]  = 8'h82; sbox[1][2]  = 8'hc9; sbox[1][3]  = 8'h7d;
        sbox[1][4]  = 8'hfa; sbox[1][5]  = 8'h59; sbox[1][6]  = 8'h47; sbox[1][7]  = 8'hf0;
        sbox[1][8]  = 8'had; sbox[1][9]  = 8'hd4; sbox[1][10] = 8'ha2; sbox[1][11] = 8'haf;
        sbox[1][12] = 8'h9c; sbox[1][13] = 8'ha4; sbox[1][14] = 8'h72; sbox[1][15] = 8'hc0;

        sbox[2][0]  = 8'hb7; sbox[2][1]  = 8'hfd; sbox[2][2]  = 8'h93; sbox[2][3]  = 8'h26;
        sbox[2][4]  = 8'h36; sbox[2][5]  = 8'h3f; sbox[2][6]  = 8'hf7; sbox[2][7]  = 8'hcc;
        sbox[2][8]  = 8'h34; sbox[2][9]  = 8'ha5; sbox[2][10] = 8'he5; sbox[2][11] = 8'hf1;
        sbox[2][12] = 8'h71; sbox[2][13] = 8'hd8; sbox[2][14] = 8'h31; sbox[2][15] = 8'h15;

        sbox[3][0]  = 8'h04; sbox[3][1]  = 8'hc7; sbox[3][2]  = 8'h23; sbox[3][3]  = 8'hc3;
        sbox[3][4]  = 8'h18; sbox[3][5]  = 8'h96; sbox[3][6]  = 8'h05; sbox[3][7]  = 8'h9a;
        sbox[3][8]  = 8'h07; sbox[3][9]  = 8'h12; sbox[3][10] = 8'h80; sbox[3][11] = 8'he2;
        sbox[3][12] = 8'heb; sbox[3][13] = 8'h27; sbox[3][14] = 8'hb2; sbox[3][15] = 8'h75;

        sbox[4][0]  = 8'h09; sbox[4][1]  = 8'h83; sbox[4][2]  = 8'h2c; sbox[4][3]  = 8'h1a;
        sbox[4][4]  = 8'h1b; sbox[4][5]  = 8'h6e; sbox[4][6]  = 8'h5a; sbox[4][7]  = 8'ha0;
        sbox[4][8]  = 8'h52; sbox[4][9]  = 8'h3b; sbox[4][10] = 8'hd6; sbox[4][11] = 8'hb3;
        sbox[4][12] = 8'h29; sbox[4][13] = 8'he3; sbox[4][14] = 8'h2f; sbox[4][15] = 8'h84;

        sbox[5][0]  = 8'h53; sbox[5][1]  = 8'hd1; sbox[5][2]  = 8'h00; sbox[5][3]  = 8'hed;
        sbox[5][4]  = 8'h20; sbox[5][5]  = 8'hfc; sbox[5][6]  = 8'hb1; sbox[5][7]  = 8'h5b;
        sbox[5][8]  = 8'h6a; sbox[5][9]  = 8'hcb; sbox[5][10] = 8'hbe; sbox[5][11] = 8'h39;
        sbox[5][12] = 8'h4a; sbox[5][13] = 8'h4c; sbox[5][14] = 8'h58; sbox[5][15] = 8'hcf;

        sbox[6][0]  = 8'hd0; sbox[6][1]  = 8'hef; sbox[6][2]  = 8'haa; sbox[6][3]  = 8'hfb;
        sbox[6][4]  = 8'h43; sbox[6][5]  = 8'h4d; sbox[6][6]  = 8'h33; sbox[6][7]  = 8'h85;
        sbox[6][8]  = 8'h45; sbox[6][9]  = 8'hf9; sbox[6][10] = 8'h02; sbox[6][11] = 8'h7f;
        sbox[6][12] = 8'h50; sbox[6][13] = 8'h3c; sbox[6][14] = 8'h9f; sbox[6][15] = 8'ha8;

        sbox[7][0]  = 8'h51; sbox[7][1]  = 8'ha3; sbox[7][2]  = 8'h40; sbox[7][3]  = 8'h8f;
        sbox[7][4]  = 8'h92; sbox[7][5]  = 8'h9d; sbox[7][6]  = 8'h38; sbox[7][7]  = 8'hf5;
        sbox[7][8]  = 8'hbc; sbox[7][9]  = 8'hb6; sbox[7][10] = 8'hda; sbox[7][11] = 8'h21;
        sbox[7][12] = 8'h10; sbox[7][13] = 8'hff; sbox[7][14] = 8'hf3; sbox[7][15] = 8'hd2;

        sbox[8][0]  = 8'hcd; sbox[8][1]  = 8'h0c; sbox[8][2]  = 8'h13; sbox[8][3]  = 8'hec;
        sbox[8][4]  = 8'h5f; sbox[8][5]  = 8'h97; sbox[8][6]  = 8'h44; sbox[8][7]  = 8'h17;
        sbox[8][8]  = 8'hc4; sbox[8][9]  = 8'ha7; sbox[8][10] = 8'h7e; sbox[8][11] = 8'h3d;
        sbox[8][12] = 8'h64; sbox[8][13] = 8'h5d; sbox[8][14] = 8'h19; sbox[8][15] = 8'h73;

        sbox[9][0]  = 8'h60; sbox[9][1]  = 8'h81; sbox[9][2]  = 8'h4f; sbox[9][3]  = 8'hdc;
        sbox[9][4]  = 8'h22; sbox[9][5]  = 8'h2a; sbox[9][6]  = 8'h90; sbox[9][7]  = 8'h88;
        sbox[9][8]  = 8'h46; sbox[9][9]  = 8'hee; sbox[9][10] = 8'hb8; sbox[9][11] = 8'h14;
        sbox[9][12] = 8'hde; sbox[9][13] = 8'h5e; sbox[9][14] = 8'h0b; sbox[9][15] = 8'hdb;

        sbox[10][0] = 8'he0; sbox[10][1] = 8'h32; sbox[10][2] = 8'h3a; sbox[10][3] = 8'h0a;
        sbox[10][4] = 8'h49; sbox[10][5] = 8'h06; sbox[10][6] = 8'h24; sbox[10][7] = 8'h5c;
        sbox[10][8] = 8'hc2; sbox[10][9] = 8'hd3; sbox[10][10] = 8'hac; sbox[10][11] = 8'h62;
        sbox[10][12] = 8'h91; sbox[10][13] = 8'h95; sbox[10][14] = 8'he4; sbox[10][15] = 8'h79;

        sbox[11][0] = 8'he7; sbox[11][1] = 8'hc8; sbox[11][2] = 8'h37; sbox[11][3] = 8'h6d;
        sbox[11][4] = 8'h8d; sbox[11][5] = 8'hd5; sbox[11][6] = 8'h4e; sbox[11][7] = 8'ha9;
        sbox[11][8] = 8'h6c; sbox[11][9] = 8'h56; sbox[11][10] = 8'hf4; sbox[11][11] = 8'hea;
        sbox[11][12] = 8'h65; sbox[11][13] = 8'h7a; sbox[11][14] = 8'hae; sbox[11][15] = 8'h08;

        sbox[12][0] = 8'hba; sbox[12][1] = 8'h78; sbox[12][2] = 8'h25; sbox[12][3] = 8'h2e;
        sbox[12][4] = 8'h1c; sbox[12][5] = 8'ha6; sbox[12][6] = 8'hb4; sbox[12][7] = 8'hc6;
        sbox[12][8] = 8'he8; sbox[12][9] = 8'hdd; sbox[12][10] = 8'h74; sbox[12][11] = 8'h1f;
        sbox[12][12] = 8'h4b; sbox[12][13] = 8'hbd; sbox[12][14] = 8'h8b; sbox[12][15] = 8'h8a;

        sbox[13][0] = 8'h70; sbox[13][1] = 8'h3e; sbox[13][2] = 8'hb5; sbox[13][3] = 8'h66;
        sbox[13][4] = 8'h48; sbox[13][5] = 8'h03; sbox[13][6] = 8'hf6; sbox[13][7] = 8'h0e;
        sbox[13][8] = 8'h61; sbox[13][9] = 8'h35; sbox[13][10] = 8'h57; sbox[13][11] = 8'hb9;
        sbox[13][12] = 8'h86; sbox[13][13] = 8'hc1; sbox[13][14] = 8'h1d; sbox[13][15] = 8'h9e;

        sbox[14][0] = 8'he1; sbox[14][1] = 8'hf8; sbox[14][2] = 8'h98; sbox[14][3] = 8'h11;
        sbox[14][4] = 8'h69; sbox[14][5] = 8'hd9; sbox[14][6] = 8'h8e; sbox[14][7] = 8'h94;
        sbox[14][8] = 8'h9b; sbox[14][9] = 8'h1e; sbox[14][10] = 8'h87; sbox[14][11] = 8'he9;
        sbox[14][12] = 8'hce; sbox[14][13] = 8'h55; sbox[14][14] = 8'h28; sbox[14][15] = 8'hdf;

        sbox[15][0] = 8'h8c; sbox[15][1] = 8'ha1; sbox[15][2] = 8'h89; sbox[15][3] = 8'h0d;
        sbox[15][4] = 8'hbf; sbox[15][5] = 8'he6; sbox[15][6] = 8'h42; sbox[15][7] = 8'h68;
        sbox[15][8] = 8'h41; sbox[15][9] = 8'h99; sbox[15][10] = 8'h2d; sbox[15][11] = 8'h0f;
        sbox[15][12] = 8'hb0; sbox[15][13] = 8'h54; sbox[15][14] = 8'hbb; sbox[15][15] = 8'h16;

        //--------------------------------------------------------------------------------------
        multiply_matrix[0][0]  = 8'h2; multiply_matrix[0][1]  = 8'h3; multiply_matrix[0][2]  = 8'h1; multiply_matrix[0][3]  = 8'h1;
        multiply_matrix[1][0]  = 8'h1; multiply_matrix[1][1]  = 8'h2; multiply_matrix[1][2]  = 8'h3; multiply_matrix[1][3]  = 8'h1;
        multiply_matrix[2][0]  = 8'h1; multiply_matrix[2][1]  = 8'h1; multiply_matrix[2][2] = 8'h2; multiply_matrix[2][3] = 8'h3;
        multiply_matrix[3][0] = 8'h3; multiply_matrix[3][1] = 8'h1; multiply_matrix[3][2] = 8'h1; multiply_matrix[3][3] = 8'h2;
endtask
task inv_setup_sbox();
        inv_sbox[0][0]  = 8'h52; inv_sbox[0][1]  = 8'h09; inv_sbox[0][2]  = 8'h6a; inv_sbox[0][3]  = 8'hd5;
        inv_sbox[0][4]  = 8'h30; inv_sbox[0][5]  = 8'h36; inv_sbox[0][6]  = 8'ha5; inv_sbox[0][7]  = 8'h38;
        inv_sbox[0][8]  = 8'hbf; inv_sbox[0][9]  = 8'h40; inv_sbox[0][10] = 8'ha3; inv_sbox[0][11] = 8'h9e;
        inv_sbox[0][12] = 8'h81; inv_sbox[0][13] = 8'hf3; inv_sbox[0][14] = 8'hd7; inv_sbox[0][15] = 8'hfb;

        inv_sbox[1][0]  = 8'h7c; inv_sbox[1][1]  = 8'he3; inv_sbox[1][2]  = 8'h39; inv_sbox[1][3]  = 8'h82;
        inv_sbox[1][4]  = 8'h9b; inv_sbox[1][5]  = 8'h2f; inv_sbox[1][6]  = 8'hff; inv_sbox[1][7]  = 8'h87;
        inv_sbox[1][8]  = 8'h34; inv_sbox[1][9]  = 8'h8e; inv_sbox[1][10] = 8'h43; inv_sbox[1][11] = 8'h44;
        inv_sbox[1][12] = 8'hc4; inv_sbox[1][13] = 8'hde; inv_sbox[1][14] = 8'he9; inv_sbox[1][15] = 8'hcb;

        inv_sbox[2][0]  = 8'h54; inv_sbox[2][1]  = 8'h7b; inv_sbox[2][2]  = 8'h94; inv_sbox[2][3]  = 8'h32;
        inv_sbox[2][4]  = 8'ha6; inv_sbox[2][5]  = 8'hc2; inv_sbox[2][6]  = 8'h23; inv_sbox[2][7]  = 8'h3d;
        inv_sbox[2][8]  = 8'hee; inv_sbox[2][9]  = 8'h4c; inv_sbox[2][10] = 8'h95; inv_sbox[2][11] = 8'h0b;
        inv_sbox[2][12] = 8'h42; inv_sbox[2][13] = 8'hfa; inv_sbox[2][14] = 8'hc3; inv_sbox[2][15] = 8'h4e;

        inv_sbox[3][0]  = 8'h08; inv_sbox[3][1]  = 8'h2e; inv_sbox[3][2]  = 8'ha1; inv_sbox[3][3]  = 8'h66;
        inv_sbox[3][4]  = 8'h28; inv_sbox[3][5]  = 8'hd9; inv_sbox[3][6]  = 8'h24; inv_sbox[3][7]  = 8'hb2;
        inv_sbox[3][8]  = 8'h76; inv_sbox[3][9]  = 8'h5b; inv_sbox[3][10] = 8'ha2; inv_sbox[3][11] = 8'h49;
        inv_sbox[3][12] = 8'h6d; inv_sbox[3][13] = 8'h8b; inv_sbox[3][14] = 8'hd1; inv_sbox[3][15] = 8'h25;

        inv_sbox[4][0]  = 8'h72; inv_sbox[4][1]  = 8'hf8; inv_sbox[4][2]  = 8'hf6; inv_sbox[4][3]  = 8'h64;
        inv_sbox[4][4]  = 8'h86; inv_sbox[4][5]  = 8'h68; inv_sbox[4][6]  = 8'h98; inv_sbox[4][7]  = 8'h16;
        inv_sbox[4][8]  = 8'hd4; inv_sbox[4][9]  = 8'ha4; inv_sbox[4][10] = 8'h5c; inv_sbox[4][11] = 8'hcc;
        inv_sbox[4][12] = 8'h5d; inv_sbox[4][13] = 8'h65; inv_sbox[4][14] = 8'hb6; inv_sbox[4][15] = 8'h92;

        inv_sbox[5][0]  = 8'h6c; inv_sbox[5][1]  = 8'h70; inv_sbox[5][2]  = 8'h48; inv_sbox[5][3]  = 8'h50;
        inv_sbox[5][4]  = 8'hfd; inv_sbox[5][5]  = 8'hed; inv_sbox[5][6]  = 8'hb9; inv_sbox[5][7]  = 8'hda;
        inv_sbox[5][8]  = 8'h5e; inv_sbox[5][9]  = 8'h15; inv_sbox[5][10] = 8'h46; inv_sbox[5][11] = 8'h57;
        inv_sbox[5][12] = 8'ha7; inv_sbox[5][13] = 8'h8d; inv_sbox[5][14] = 8'h9d; inv_sbox[5][15] = 8'h84;

        inv_sbox[6][0]  = 8'h90; inv_sbox[6][1]  = 8'hd8; inv_sbox[6][2]  = 8'hab; inv_sbox[6][3]  = 8'h00;
        inv_sbox[6][4]  = 8'h8c; inv_sbox[6][5]  = 8'hbc; inv_sbox[6][6]  = 8'hd3; inv_sbox[6][7]  = 8'h0a;
        inv_sbox[6][8]  = 8'hf7; inv_sbox[6][9]  = 8'he4; inv_sbox[6][10] = 8'h58; inv_sbox[6][11] = 8'h05;
        inv_sbox[6][12] = 8'hb8; inv_sbox[6][13] = 8'hb3; inv_sbox[6][14] = 8'h45; inv_sbox[6][15] = 8'h06;

        inv_sbox[7][0]  = 8'hd0; inv_sbox[7][1]  = 8'h2c; inv_sbox[7][2]  = 8'h1e; inv_sbox[7][3]  = 8'h8f;
        inv_sbox[7][4]  = 8'hca; inv_sbox[7][5]  = 8'h3f; inv_sbox[7][6]  = 8'h0f; inv_sbox[7][7]  = 8'h02;
        inv_sbox[7][8]  = 8'hc1; inv_sbox[7][9]  = 8'haf; inv_sbox[7][10] = 8'hbd; inv_sbox[7][11] = 8'h03;
        inv_sbox[7][12] = 8'h01; inv_sbox[7][13] = 8'h13; inv_sbox[7][14] = 8'h8a; inv_sbox[7][15] = 8'h6b;

        inv_sbox[8][0]  = 8'h3a; inv_sbox[8][1]  = 8'h91; inv_sbox[8][2]  = 8'h11; inv_sbox[8][3]  = 8'h41;
        inv_sbox[8][4]  = 8'h4f; inv_sbox[8][5]  = 8'h67; inv_sbox[8][6]  = 8'hdc; inv_sbox[8][7]  = 8'hea;
        inv_sbox[8][8]  = 8'h97; inv_sbox[8][9]  = 8'hf2; inv_sbox[8][10] = 8'hcf; inv_sbox[8][11] = 8'hce;
        inv_sbox[8][12] = 8'hf0; inv_sbox[8][13] = 8'hb4; inv_sbox[8][14] = 8'he6; inv_sbox[8][15] = 8'h73;

        inv_sbox[9][0]  = 8'h96; inv_sbox[9][1]  = 8'hac; inv_sbox[9][2]  = 8'h74; inv_sbox[9][3]  = 8'h22;
        inv_sbox[9][4]  = 8'he7; inv_sbox[9][5]  = 8'had; inv_sbox[9][6]  = 8'h35; inv_sbox[9][7]  = 8'h85;
        inv_sbox[9][8]  = 8'he2; inv_sbox[9][9]  = 8'hf9; inv_sbox[9][10] = 8'h37; inv_sbox[9][11] = 8'he8;
        inv_sbox[9][12] = 8'h1c; inv_sbox[9][13] = 8'h75; inv_sbox[9][14] = 8'hdf; inv_sbox[9][15] = 8'h6e;

        inv_sbox[10][0] = 8'h47; inv_sbox[10][1] = 8'hf1; inv_sbox[10][2] = 8'h1a; inv_sbox[10][3] = 8'h71;
        inv_sbox[10][4] = 8'h1d; inv_sbox[10][5] = 8'h29; inv_sbox[10][6] = 8'hc5; inv_sbox[10][7] = 8'h89;
        inv_sbox[10][8] = 8'h6f; inv_sbox[10][9] = 8'hb7; inv_sbox[10][10] = 8'h62; inv_sbox[10][11] = 8'h0e;
        inv_sbox[10][12] = 8'haa; inv_sbox[10][13] = 8'h18; inv_sbox[10][14] = 8'hbe; inv_sbox[10][15] = 8'h1b;

        inv_sbox[11][0] = 8'hfc; inv_sbox[11][1] = 8'h56; inv_sbox[11][2] = 8'h3e; inv_sbox[11][3] = 8'h4b;
        inv_sbox[11][4] = 8'hc6; inv_sbox[11][5] = 8'hd2; inv_sbox[11][6] = 8'h79; inv_sbox[11][7] = 8'h20;
        inv_sbox[11][8] = 8'h9a; inv_sbox[11][9] = 8'hdb; inv_sbox[11][10] = 8'hc0; inv_sbox[11][11] = 8'hfe;
        inv_sbox[11][12] = 8'h78; inv_sbox[11][13] = 8'hcd; inv_sbox[11][14] = 8'h5a; inv_sbox[11][15] = 8'hf4;

        inv_sbox[12][0] = 8'h1f; inv_sbox[12][1] = 8'hdd; inv_sbox[12][2] = 8'ha8; inv_sbox[12][3] = 8'h33;
        inv_sbox[12][4] = 8'h88; inv_sbox[12][5] = 8'h07; inv_sbox[12][6] = 8'hc7; inv_sbox[12][7] = 8'h31;
        inv_sbox[12][8] = 8'hb1; inv_sbox[12][9] = 8'h12; inv_sbox[12][10] = 8'h10; inv_sbox[12][11] = 8'h59;
        inv_sbox[12][12] = 8'h27; inv_sbox[12][13] = 8'h80; inv_sbox[12][14] = 8'hec; inv_sbox[12][15] = 8'h5f;

        inv_sbox[13][0] = 8'h60; inv_sbox[13][1] = 8'h51; inv_sbox[13][2] = 8'h7f; inv_sbox[13][3] = 8'ha9;
        inv_sbox[13][4] = 8'h19; inv_sbox[13][5] = 8'hb5; inv_sbox[13][6] = 8'h4a; inv_sbox[13][7] = 8'h0d;
        inv_sbox[13][8] = 8'h2d; inv_sbox[13][9] = 8'he5; inv_sbox[13][10] = 8'h7a; inv_sbox[13][11] = 8'h9f;
        inv_sbox[13][12] = 8'h93; inv_sbox[13][13] = 8'hc9; inv_sbox[13][14] = 8'h9c; inv_sbox[13][15] = 8'hef;

        inv_sbox[14][0] = 8'ha0; inv_sbox[14][1] = 8'he0; inv_sbox[14][2] = 8'h3b; inv_sbox[14][3] = 8'h4d;
        inv_sbox[14][4] = 8'hae; inv_sbox[14][5] = 8'h2a; inv_sbox[14][6] = 8'hf5; inv_sbox[14][7] = 8'hb0;
        inv_sbox[14][8] = 8'hc8; inv_sbox[14][9] = 8'heb; inv_sbox[14][10] = 8'hbb; inv_sbox[14][11] = 8'h3c;
        inv_sbox[14][12] = 8'h83; inv_sbox[14][13] = 8'h53; inv_sbox[14][14] = 8'h99; inv_sbox[14][15] = 8'h61;

        inv_sbox[15][0] = 8'h17; inv_sbox[15][1] = 8'h2b; inv_sbox[15][2] = 8'h04; inv_sbox[15][3] = 8'h7e;
        inv_sbox[15][4] = 8'hba; inv_sbox[15][5] = 8'h77; inv_sbox[15][6] = 8'hd6; inv_sbox[15][7] = 8'h26;
        inv_sbox[15][8] = 8'he1; inv_sbox[15][9] = 8'h69; inv_sbox[15][10] = 8'h14; inv_sbox[15][11] = 8'h63;
        inv_sbox[15][12] = 8'h55; inv_sbox[15][13] = 8'h21; inv_sbox[15][14] = 8'h0c; inv_sbox[15][15] = 8'h7d;

        //--------------------------------------------------------------------------------------
        inv_transform_matrix[0][0] = 8'h0E; inv_transform_matrix[0][1] = 8'h0B; inv_transform_matrix[0][2] = 8'h0D; inv_transform_matrix[0][3] = 8'h09;
        inv_transform_matrix[1][0] = 8'h09; inv_transform_matrix[1][1] = 8'h0E; inv_transform_matrix[1][2] = 8'h0B; inv_transform_matrix[1][3] = 8'h0D;
        inv_transform_matrix[2][0] = 8'h0D; inv_transform_matrix[2][1] = 8'h09; inv_transform_matrix[2][2] = 8'h0E; inv_transform_matrix[2][3] = 8'h0B;
        inv_transform_matrix[3][0] = 8'h0B; inv_transform_matrix[3][1] = 8'h0D; inv_transform_matrix[3][2] = 8'h09; inv_transform_matrix[3][3] = 8'h0E;
endtask
endmodule
