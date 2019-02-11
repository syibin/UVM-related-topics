/*
Copyright (C) 2012 SysWip

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
///////////////////////////////////////////////////////////////////////////////
// Class Packet:
///////////////////////////////////////////////////////////////////////////////
class Packet;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local rand int unsigned      rndNum;
  local int unsigned           rndNumMin;
  local int unsigned           rndNumMax;
  local int unsigned           rndNumMult;
  
  constraint c_rundNum {
                             rndNum inside {[rndNumMin:rndNumMax]};
                             rndNum%rndNumMult == 0;
                       }
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- genRndPkt(): Generates random packet with the given length.*/
  /////////////////////////////////////////////////////////////////////////////
  task genRndPkt(input int length, output bit8 pkt[]);
    pkt = new[length];
    for (int i = 0; i < length; i++) begin
      pkt[i] = $urandom_range(0, 255);
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- genCntPkt(): Generates packet with the given length where the first byte
  // is 0 the second is 1 the third is 2 etc.*/
  /////////////////////////////////////////////////////////////////////////////
  task genCntPkt(input int length, output bit8 pkt[]);
    pkt = new[length];
    for (int i = 0; i < length; i++) begin
      pkt[i] = i[7:0];
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- genNullPkt(): Generates packet with the given length where all bytes are
  // constant.*/
  /////////////////////////////////////////////////////////////////////////////
  task genConstPkt(input int length, constVal, output bit8 pkt[]);
    pkt = new[length];
    for (int i = 0; i < length; i++) begin
      pkt[i] = constVal[7:0];
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
  /*- genRndPkt(): Generates random packet. The packet length will be generated
  // randomly in the given range and will be multiple to "mult" value.*/
  /////////////////////////////////////////////////////////////////////////////
  task genFullRndPkt(input int min, max, mult, output bit8 pkt[]);
    this.genRndPkt((this.genRndNum(min, max, mult)), pkt);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- PrintPkt(): Prints given "str" string and then packet containt.*/
  /////////////////////////////////////////////////////////////////////////////
  function void PrintPkt(string str, bit8 pkt[], int length=0);
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
    this.pkt = new();
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- CheckPkt(): Compares 2 given packets and returns '0' if they are equal.
  // Otherwise returns '-1'.*/
  /////////////////////////////////////////////////////////////////////////////
  function int CheckPkt(bit8 resPkt[], expPkt[], int length = 0);
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
      $write("   Failed. Packets have different lengths \n");
      $write("           Expected packet length is %d \n", expPkt.size());
      $write("           Result   packet length is %d \n", resPkt.size());
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
        this.pkt.PrintPkt("Expected Packet", expPkt, length);
        this.pkt.PrintPkt("Result Packet", resPkt, length);
        CheckPkt = -1;
        this.ChecksFail++;
        this.AllChecksFail++;
      end
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
