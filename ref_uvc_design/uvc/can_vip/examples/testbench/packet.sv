/*
Copyright (C) 2011 SysWip

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package PACKET;
typedef bit [7:0]  bit8;
typedef bit8       packet[$];
///////////////////////////////////////////////////////////////////////////////
// Class Packet:
///////////////////////////////////////////////////////////////////////////////
class Packet;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  rand int unsigned      rndNum;
  rand int unsigned      rndNumRange;
  int unsigned           rndNumMin;
  int unsigned           rndNumMax;
  int unsigned           rndNumMult;
  int unsigned           rndNumMinRanges[3];
  int unsigned           rndNumMaxRanges[3];
  // Constraints for "rndNum" random variable
  constraint c_rundNum {
                             rndNum inside {[rndNumMin:rndNumMax]};
                             rndNum%rndNumMult == 0;
                       }
  // Constraints for "rndNumRange" random variable
  constraint c_rundNumRange {
                             rndNumRange inside {[rndNumMinRanges[0]:rndNumMaxRanges[0]], [rndNumMinRanges[1]:rndNumMaxRanges[1]], [rndNumMinRanges[2]:rndNumMaxRanges[2]]};
                             rndNumRange%rndNumMult == 0;
                       }
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- genRndPkt(): Generates random packet with the given length.*/
  /////////////////////////////////////////////////////////////////////////////
  task genRndPkt(input int length, output packet pkt);
    pkt = {};
    for (int i = 0; i < length; i++) begin
      pkt.push_back($urandom_range(0, 255));
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- genCntPkt(): Generates packet with the given length where the first byte
  // is 0 the second is 1 the third is 2 etc.*/
  /////////////////////////////////////////////////////////////////////////////
  task genCntPkt(input int length, output packet pkt);
    bit8 pktElement = 0;
    pkt = {};
    for (int i = 0; i < length; i++) begin
      pkt.push_back(pktElement);
      pktElement++;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- genNullPkt(): Generates packet with the given length where all bytes are
  // zeros.*/
  /////////////////////////////////////////////////////////////////////////////
  task genNullPkt(input int length, output packet pkt);
    pkt = {};
    for (int i = 0; i < length; i++) begin
      pkt.push_back(8'd0);
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- genRndNum(): Generates random number with a given range and then rounds
  // up to be multiple to "mult" value.*/
  /////////////////////////////////////////////////////////////////////////////
  function int genRndNum(int unsigned min, max, mult=1);
    this.rndNumMin = min;
    this.rndNumMax = max;
    this.rndNumMult= mult;
    assert (this.randomize())
    else $fatal(0, "Gen Randon Number: Randomize failed");
    genRndNum = this.rndNum;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- genRndNumRanges(): Generates random number with a given ranges and then rounds
  // up to be multiple to "mult" value.*/
  /////////////////////////////////////////////////////////////////////////////
  function int genRndNumRanges(int unsigned min0, max0, min1, max1, min2, max2, mult=1);
    this.rndNumMinRanges[0] = min0;
    this.rndNumMaxRanges[0] = max0;
    this.rndNumMinRanges[1] = min1;
    this.rndNumMaxRanges[1] = max1;
    this.rndNumMinRanges[2] = min2;
    this.rndNumMaxRanges[2] = max2;
    this.rndNumMult= mult;
    assert (this.randomize())
    else $fatal(0, "Gen Randon Number: Randomize failed");
    genRndNumRanges = this.rndNumRange;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- genRndPkt(): Generates random packet. The packet length will be generated
  // randomly in the given range and will be multiple to "mult" value.*/
  /////////////////////////////////////////////////////////////////////////////
  task genFullRndPkt(input int min, max, mult, output packet pkt);
    int length = this.genRndNum(min, max, mult);
    this.genRndPkt(length, pkt);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- PrintPkt(): Prints given "str" string and then packet containt.*/
  /////////////////////////////////////////////////////////////////////////////
  function void PrintPkt(string str, packet pkt, int length=0);
    if(length==0)begin
      length = pkt.size();
    end
    $write("%s: Packet size is %d bytes\n", str, pkt.size());
    for (int i = 1; i <= length; i++) begin
      $write("%h",pkt[i-1]);
      if ((i%4) == 0) $write(" ");
      if ((i%32) == 0) $write("\n");
    end
    $write("\n");
  endfunction
  //
endclass // Packet
///////////////////////////////////////////////////////////////////////////////
// Class Checker:
///////////////////////////////////////////////////////////////////////////////
class Checker;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  static int AllChecks     = 0;
  static int AllChecksFail = 0;
  local  int Checks        = 0;
  local  int ChecksFail    = 0;
  local Packet pkt;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  function new();
    pkt = new();
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- CheckPkt(): Compares 2 given packets and returns '0' if they are equal.
  // Otherwise returns '-1'.*/
  /////////////////////////////////////////////////////////////////////////////
  function int CheckPkt(packet resPkt, expPkt, int length = 0);
    int dataError = 0;
    if(length == 0)begin
      length = expPkt.size();
    end
    this.Checks++;
    this.AllChecks++;
    $write("#-----Check %0d",this.Checks);
    if((expPkt.size()==0) || (resPkt.size()==0))begin
      $write("   Failed. Empty packet detected \n");
      $write("           Expected packet length is %d \n", expPkt.size());
      $write("           Result   packet length is %d \n", resPkt.size());
      CheckPkt = -1;
      this.ChecksFail++;
      this.AllChecksFail++;
    end else if(expPkt.size() != resPkt.size()) begin
      $write("   Failed. Packets have different lengths detected \n");
      $write("           Expected packet length is %d \n", expPkt.size());
      $write("           Result   packet length is %d \n", resPkt.size());
      pkt.PrintPkt("Expected Packet", expPkt, expPkt.size());
      pkt.PrintPkt("Result Packet", resPkt, resPkt.size());
      CheckPkt = -1;
      this.ChecksFail++;
      this.AllChecksFail++;
    end else begin
      for (int i = 0; i < length; i++) begin
        if (resPkt[i] != expPkt[i]) begin
          dataError++;
        end
      end
      if (dataError == 0) begin
        $write("   Passed!!! \n");
        CheckPkt = 0;
      end else begin
        $write("   Failed. Current Check has %0d errors\n", dataError);
        pkt.PrintPkt("Expected Packet", expPkt, length);
        pkt.PrintPkt("Result Packet", resPkt, length);
        CheckPkt = -1;
        this.ChecksFail++;
        this.AllChecksFail++;
      end
    end
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- CheckWord(): Compares 2 given words and returns '0' if they are equal.
  // Otherwise returns '-1'.*/
  /////////////////////////////////////////////////////////////////////////////
  function int CheckWord(int resPkt, expPkt, string chkMsg = "");
    $display("%s", chkMsg);
    this.Checks++;
    this.AllChecks++;
    $write("#-----Check %0d",this.Checks);
    if(resPkt == expPkt) begin
      $write("   Passed!!! \n");
      CheckWord = 0;
    end else begin
      $write("   Failed. Result word is 0x%h expected word is 0x%h\n", resPkt, expPkt);
      CheckWord = -1;
      this.ChecksFail++;
      this.AllChecksFail++;
    end
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- CheckBitVec(): Compare 2 given bit vectors and return '0' if they are equal.
  // Otherwise return '-1'.*/
  /////////////////////////////////////////////////////////////////////////////
  function int CheckBitVec(bit[511:0] resPkt, expPkt, string chkMsg = "");
    $display("%s", chkMsg);
    this.Checks++;
    this.AllChecks++;
    $write("#-----Check %0d",this.Checks);
    if(resPkt == expPkt) begin
      $write("   Passed!!! \n");
      CheckBitVec = 0;
    end else begin
      $write("   Failed. Result word is 0x%h expected word is 0x%h\n", resPkt, expPkt);
      CheckBitVec = -1;
      this.ChecksFail++;
      this.AllChecksFail++;
    end
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- printStatus(): Print checks and failed checks information.*/
  /////////////////////////////////////////////////////////////////////////////
  function void printStatus();
    $write("---Number of Checks        %0d \n", this.Checks);
    $write("---Number of failed Checks %0d \n", this.ChecksFail);
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- printFullStatus(): Print checks and failed checks information.*/
  /////////////////////////////////////////////////////////////////////////////
  function void printFullStatus();
    $write("---Number of Checks        %0d \n", this.AllChecks);
    $write("---Number of failed Checks %0d \n", this.AllChecksFail);
  endfunction
endclass // Checker
//
endpackage
