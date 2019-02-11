//------------------------------------------------------------
//   Copyright 2013 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------

class LP_FILTER_cg_wrapper extends uvm_object;

`uvm_object_utils(LP_FILTER_cg_wrapper)

// Co-Efficient values
bit[23:0] b10;
bit[23:0] b11;
bit[23:0] b12;
bit[23:0] a10;
bit[23:0] a11;

// LP_FILTER Covergroup:
covergroup LP_FILTER_cg() with function sample(int frequency);

  option.name = "LP_FILTER_cg";
  option.per_instance = 1;

  IP_FREQ: coverpoint frequency {
    bins HZ_100 = { 100 };
    bins HZ_200 = { 200 };
    bins HZ_400 = { 400 };
    bins HZ_800 = { 800 };
    bins HZ_1k = { 1000 };
    bins HZ_1k5 = { 1500 };
    bins HZ_2k = { 2000 };
    bins HZ_2k5 = { 2500 };
    bins HZ_3k = { 3000 };
    bins HZ_3k5 = { 3500 };
    bins HZ_4k = { 4000 };
    bins HZ_5k = { 5000 };
    bins HZ_6k = { 6000 };
    bins HZ_7k = { 7000 };
    bins HZ_8k = { 8000 };
    bins HZ_9k = { 9000 };
    bins HZ_10k = { 10000 };
    bins HZ_11k = { 11000 };
    bins HZ_12k = { 12000 };
    bins HZ_13k = { 13000 };
    bins HZ_14k = { 14000 };
    bins HZ_15k = { 15000 };
    bins HZ_16k = { 16000 };
    bins HZ_17k = { 17000 };
    bins HZ_18k = { 18000 };
    bins HZ_19k = { 19000 };
    bins HZ_20k = { 20000 };
  }

  CO_EFFICIENTS: coverpoint {b10, b11, b12, a10, a11} {
    bins CE_200 = {120'h0002C10005830002C1FDA1603DAC66};
    bins CE_400 = {120'h000AD30015A6000AD3FB43263B6E74};
    bins CE_800 = {120'h0029C90053930029C9F68940373067};
    bins CE_1000 = {120'h004029008052004029F42E2B352ED0};
    bins CE_1200 = {120'h005ACF00B59E005ACFF1D4AA333FE8};
    bins CE_1400 = {120'h00798300F307007983EF7CF4316303};
    bins CE_1600 = {120'h009C11013822009C11ED27392F977E};
    bins CE_1800 = {120'h00C24501848B00C245EAD3A32DDCBA};
    bins CE_2000 = {120'h00EBF201D7E500EBF2E882552C3220};
    bins CE_2200 = {120'h0118EC0231D80118ECE6336E2A971F};
    bins CE_2400 = {120'h014909029212014909E3E707290B2C};
    bins CE_2600 = {120'h017C2302F847017C23E19D34278DC4};
    bins CE_2800 = {120'h01B21703642E01B217DF5608261E66};
    bins CE_3000 = {120'h01EAC203D58501EAC2DD118F24BC99};
    bins CE_3200 = {120'h022605044C0B022605DACFD32367EA};
    bins CE_3400 = {120'h0263C304C7860263C3D890DC221FE8};
    bins CE_3600 = {120'h02A3DF0547BF02A3DFD654AD20E42B};
    bins CE_3800 = {120'h02E64105CC8202E641D41B471FB44C};
    bins CE_4k = {120'h032ACF06559F032ACFD1E4AB1E8FEA};
    bins CE_5k = {120'h049F60093EC0049F60C6FCC7197A49};
    bins CE_6k = {120'h063F810C7F03063F81BC563415543B};
    bins CE_7k = {120'h080518100A30080518B1EA5811FEBA};
    bins CE_8k = {120'h09EC3513D86B09EC35A7B0D70F61AE};
    bins CE_9k = {120'h0BF29E17E53C0BF29E9DA0520D6ACB};
    bins CE_10k = {120'h0E17721C2EE50E177293AEDB0C0CA7};
    bins CE_11k = {120'h105AF920B5F3105AF989D2350B3E1D};
    bins CE_12k = {120'h12BE76257CEC12BE768000000AF9D9};
    bins CE_13k = {120'h1544142A882915441409D2350B3E1D};
    bins CE_14k = {120'h17EEE02FDDC117EEE013AEDB0C0CA7};
    bins CE_15k = {120'h1AC2C735858F1AC2C71DA0520D6ACB};
    bins CE_16k = {120'h1DC4A13B89431DC4A127B0D70F61AE};
    bins CE_17k = {120'h20FA4441F48920FA4431EA5811FEBA};
    bins CE_18k = {120'h246A9C48D538246A9C3C563415543B};
    bins CE_19k = {120'h281DC4503B88281DC446FCC7197A49};
    bins CE_20k = {120'h2C1D25583A4B2C1D2551E4AB1E8FEA};
  }

  X: cross CO_EFFICIENTS, IP_FREQ;
endgroup: LP_FILTER_cg

function new(string name = "LP_FILTER_cg_wrapper");
  super.new(name);
  LP_FILTER_cg = new();
endfunction

function void sample(int frequency);
  LP_FILTER_cg.sample(frequency);
endfunction

endclass: LP_FILTER_cg_wrapper

class HP_FILTER_cg_wrapper extends uvm_object;

`uvm_object_utils(HP_FILTER_cg_wrapper)

// Co-Efficient values
bit[23:0] b10;
bit[23:0] b11;
bit[23:0] b12;
bit[23:0] a10;
bit[23:0] a11;

// HP_FILTER Covergroup:
covergroup HP_FILTER_cg() with function sample(int frequency);

  option.name = "HP_FILTER_cg";
  option.per_instance = 1;

  IP_FREQ: coverpoint frequency {
    bins HZ_100 = { 100 };
    bins HZ_200 = { 200 };
    bins HZ_400 = { 400 };
    bins HZ_800 = { 800 };
    bins HZ_1k = { 1000 };
    bins HZ_1k5 = { 1500 };
    bins HZ_2k = { 2000 };
    bins HZ_2k5 = { 2500 };
    bins HZ_3k = { 3000 };
    bins HZ_3k5 = { 3500 };
    bins HZ_4k = { 4000 };
    bins HZ_5k = { 5000 };
    bins HZ_6k = { 6000 };
    bins HZ_7k = { 7000 };
    bins HZ_8k = { 8000 };
    bins HZ_9k = { 9000 };
    bins HZ_10k = { 10000 };
    bins HZ_11k = { 11000 };
    bins HZ_12k = { 12000 };
    bins HZ_13k = { 13000 };
    bins HZ_14k = { 14000 };
    bins HZ_15k = { 15000 };
    bins HZ_16k = { 16000 };
    bins HZ_17k = { 17000 };
    bins HZ_18k = { 18000 };
    bins HZ_19k = { 19000 };
    bins HZ_20k = { 20000 };
  }

  CO_EFFICIENTS: coverpoint {b10, b11, b12, a10, a11} {
    bins CE_200 = {120'h3ED371FDA6E33ED371FDA1603DAC66};
    bins CE_400 = {120'h3DAC66FB58CD3DAC66FB43263B6E74};
    bins CE_800 = {120'h3B6E69F6DCD33B6E69F68940373067};
    bins CE_1000 = {120'h3A573EF4AE7D3A573EF42E2B352ED0};
    bins CE_1200 = {120'h394524F28A49394524F1D4AA333FE8};
    bins CE_1400 = {120'h3837FEF06FFC3837FEEF7CF4316303};
    bins CE_1600 = {120'h372FAEEE5F5C372FAEED27392F977E};
    bins CE_1800 = {120'h362C17EC582E362C17EAD3A32DDCBA};
    bins CE_2000 = {120'h352D1DEA5A3A352D1DE882552C3220};
    bins CE_2200 = {120'h3432A3E865463432A3E6336E2A971F};
    bins CE_2400 = {120'h333C8CE67919333C8CE3E707290B2C};
    bins CE_2600 = {120'h324ABEE4957C324ABEE19D34278DC4};
    bins CE_2800 = {120'h315D1BE2BA37315D1BDF5608261E66};
    bins CE_3000 = {120'h30738AE0E71430738ADD118F24BC99};
    bins CE_3200 = {120'h2F8DEFDF1BDF2F8DEFDACFD32367EA};
    bins CE_3400 = {120'h2EAC31DD58622EAC31D890DC221FE8};
    bins CE_3600 = {120'h2DCE36DB9C6C2DCE36D654AD20E42B};
    bins CE_3800 = {120'h2CF3E4D9E7C92CF3E4D41B471FB44C};
    bins CE_4k = {120'h2C1D25D83A4B2C1D25D1E4AB1E8FEA};
    bins CE_5k = {120'h281DC4D03B88281DC4C6FCC7197A49};
    bins CE_6k = {120'h246A9CC8D538246A9CBC563415543B};
    bins CE_7k = {120'h20FA44C1F48920FA44B1EA5811FEBA};
    bins CE_8k = {120'h1DC4A1BB89431DC4A1A7B0D70F61AE};
    bins CE_9k = {120'h1AC2C7B5858F1AC2C79DA0520D6ACB};
    bins CE_10k = {120'h17EEE0AFDDC117EEE093AEDB0C0CA7};
    bins CE_11k = {120'h154414AA882915441489D2350B3E1D};
    bins CE_12k = {120'h12BE76A57CEC12BE768000000AF9D9};
    bins CE_13k = {120'h105AF9A0B5F3105AF909D2350B3E1D};
    bins CE_14k = {120'h0E17729C2EE50E177213AEDB0C0CA7};
    bins CE_15k = {120'h0BF29E97E53C0BF29E1DA0520D6ACB};
    bins CE_16k = {120'h09EC3593D86B09EC3527B0D70F61AE};
    bins CE_17k = {120'h080518900A3008051831EA5811FEBA};
    bins CE_18k = {120'h063F818C7F03063F813C563415543B};
    bins CE_19k = {120'h049F60893EC0049F6046FCC7197A49};
    bins CE_20k = {120'h032ACF86559F032ACF51E4AB1E8FEA};
  }

  X: cross CO_EFFICIENTS, IP_FREQ;
endgroup: HP_FILTER_cg

function new(string name = "HP_FILTER_cg_wrapper");
  super.new(name);
  HP_FILTER_cg = new();
endfunction

function void sample(int frequency);
  HP_FILTER_cg.sample(frequency);
endfunction

endclass: HP_FILTER_cg_wrapper

class BP_FILTER_cg_wrapper extends uvm_object;

`uvm_object_utils(BP_FILTER_cg_wrapper)

// Co-Efficient values
bit[23:0] b10;
bit[23:0] b11;
bit[23:0] b12;
bit[23:0] a10;
bit[23:0] a11;

// BP_FILTER Covergroup:
covergroup BP_FILTER_cg() with function sample(int frequency);

  option.name = "BP_FILTER_cg";
  option.per_instance = 1;

  IP_FREQ: coverpoint frequency {
    bins HZ_100 = { 100 };
    bins HZ_200 = { 200 };
    bins HZ_400 = { 400 };
    bins HZ_800 = { 800 };
    bins HZ_1k = { 1000 };
    bins HZ_1k5 = { 1500 };
    bins HZ_2k = { 2000 };
    bins HZ_2k5 = { 2500 };
    bins HZ_3k = { 3000 };
    bins HZ_3k5 = { 3500 };
    bins HZ_4k = { 4000 };
    bins HZ_5k = { 5000 };
    bins HZ_6k = { 6000 };
    bins HZ_7k = { 7000 };
    bins HZ_8k = { 8000 };
    bins HZ_9k = { 9000 };
    bins HZ_10k = { 10000 };
    bins HZ_11k = { 11000 };
    bins HZ_12k = { 12000 };
    bins HZ_13k = { 13000 };
    bins HZ_14k = { 14000 };
    bins HZ_15k = { 15000 };
    bins HZ_16k = { 16000 };
    bins HZ_17k = { 17000 };
    bins HZ_18k = { 18000 };
    bins HZ_19k = { 19000 };
    bins HZ_20k = { 20000 };
  }

  CO_EFFICIENTS: coverpoint {b10, b11, b12, a10, a11} {
    bins CE_200 = {120'h0129CC0000008129CCFDA1603DAC66};
    bins CE_400 = {120'h0248C50000008248C5FB43263B6E74};
    bins CE_800 = {120'h0467CC0000008467CCF68940373067};
    bins CE_1000 = {120'h056897000000856897F42E2B352ED0};
    bins CE_1200 = {120'h06600B00000086600BF1D4AA333FE8};
    bins CE_1400 = {120'h074E7E000000874E7EEF7CF4316303};
    bins CE_1600 = {120'h083440000000883440ED27392F977E};
    bins CE_1800 = {120'h0911A20000008911A2EAD3A32DDCBA};
    bins CE_2000 = {120'h09E6EF00000089E6EFE882552C3220};
    bins CE_2200 = {120'h0AB4700000008AB470E6336E2A971F};
    bins CE_2400 = {120'h0B7A690000008B7A69E3E707290B2C};
    bins CE_2600 = {120'h0C391D0000008C391DE19D34278DC4};
    bins CE_2800 = {120'h0CF0CC0000008CF0CCDF5608261E66};
    bins CE_3000 = {120'h0DA1B30000008DA1B3DD118F24BC99};
    bins CE_3200 = {120'h0E4C0A0000008E4C0ADACFD32367EA};
    bins CE_3400 = {120'h0EF00B0000008EF00BD890DC221FE8};
    bins CE_3600 = {120'h0F8DEA0000008F8DEAD654AD20E42B};
    bins CE_3800 = {120'h1025D90000009025D9D41B471FB44C};
    bins CE_4k = {120'h10B80A00000090B80AD1E4AB1E8FEA};
    bins CE_5k = {120'h1342DB0000009342DBC6FCC7197A49};
    bins CE_6k = {120'h1555E20000009555E2BC563415543B};
    bins CE_7k = {120'h1700A20000009700A2B1EA5811FEBA};
    bins CE_8k = {120'h184F28000000984F28A7B0D70F61AE};
    bins CE_9k = {120'h194A9A000000994A9A9DA0520D6ACB};
    bins CE_10k = {120'h19F9AC00000099F9AC93AEDB0C0CA7};
    bins CE_11k = {120'h1A60F10000009A60F189D2350B3E1D};
    bins CE_12k = {120'h1A83130000009A83138000000AF9D9};
    bins CE_13k = {120'h1A60F10000009A60F109D2350B3E1D};
    bins CE_14k = {120'h19F9AC00000099F9AC13AEDB0C0CA7};
    bins CE_15k = {120'h194A9A000000994A9A1DA0520D6ACB};
    bins CE_16k = {120'h184F28000000984F2827B0D70F61AE};
    bins CE_17k = {120'h1700A20000009700A231EA5811FEBA};
    bins CE_18k = {120'h1555E20000009555E23C563415543B};
    bins CE_19k = {120'h1342DB0000009342DB46FCC7197A49};
    bins CE_20k = {120'h10B80A00000090B80A51E4AB1E8FEA};
  }

  X: cross CO_EFFICIENTS, IP_FREQ;
endgroup: BP_FILTER_cg

function new(string name = "BP_FILTER_cg_wrapper");
  super.new(name);
  BP_FILTER_cg = new();
endfunction

function void sample(int frequency);
  BP_FILTER_cg.sample(frequency);
endfunction

endclass: BP_FILTER_cg_wrapper

