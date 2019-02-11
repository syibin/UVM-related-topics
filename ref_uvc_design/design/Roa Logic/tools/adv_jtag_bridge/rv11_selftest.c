/* rv11_selftest.c -- JTAG protocol bridge between GDB and Advanced debug module.
   Copyright(C) 2001 Marko Mlinar, markom@opencores.org
   Code for TCP/IP copied from gdb, by Chris Ziomkowski
   Refactoring and USB support by Nathan Yawn, (C) 2008-2010
   Adapted for Roa Logic RV11 by Richard Herveille, (C)2016 Roa Logic BV
   
   This file contains functions which perform high-level transactions
   on a JTAG chain and debug unit, such as setting a value in the TAP IR
   or doing a burst write through the wishbone module of the debug unit.
   It uses the protocol for the Advanced Debug Interface (adv_dbg_if).
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. 
*/


#include <stdio.h>
#include <stdlib.h>  // for exit()
#include <stdint.h>

#include "rv11_selftest.h"
#include "csr-defs.h"
#include "dbg_api.h"
#include "errcodes.h"


// Define your system parameters here
//#define HAS_MEMORY_CONTROLLER // init the SDRAM controller
#define MC_BASE_ADDR     0x93000000
#define SDRAM_BASE       0x00000000
#define SDRAM_SIZE       0x04000000
//#define SDRAM_SIZE 0x400

//test-system SRAM start
#define SRAM_BASE        0x00010000

#define SRAM_SIZE        0x04000000
#define FLASH_BASE_ADDR  0xf0000000

// Define the tests to be performed here
#define TEST_SRAM
//#define TEST_SDRAM
#define TEST_RV11

// Defines which depend on user-defined values, don't change these
#define FLASH_BAR_VAL    FLASH_BASE_ADDR
#define SDRAM_BASE_ADDR  SDRAM_BASE
#define SDRAM_BAR_VAL    SDRAM_BASE_ADDR
#define SDRAM_AMR_VAL    (~(SDRAM_SIZE -1))

#define CHECK(x) check(__FILE__, __LINE__, (x))
void check(char *fn, int l, int i);

void check(char *fn, int l, int i) {
  if (i != 0) {
    fprintf(stderr, "%s:%d: Jtag error %d occured; exiting.\n", fn, l, i);
    exit(1);
  }
}


////////////////////////////////////////////////////////////
// Self-test functions
//
// RISC-V: Currently working (based on DE2-115 RoaLogic Demo design) 
// - Test SRAM
// - Test rv11
///////////////////////////////////////////////////////////
int dbg_test() 
{
  int success;

  success = stall_cpus();
  if(success == APP_ERR_NONE) {

#ifdef HAS_MEMORY_CONTROLLER
    // Init the memory contloller
    init_mc();
    // Init the SRAM addresses in the MC
    init_sram();
#endif

#ifdef TEST_SDRAM
    success |= test_sdram();
    success |= test_sdram_2();
#endif

#ifdef TEST_SRAM
    success |= test_sram();
#endif
  
#ifdef TEST_RV11
    success |= test_rv11_cpu0();
#endif

    return success;
  }

  return APP_ERR_TEST_FAIL;
}


int stall_cpus(void) 
{
  unsigned int stalled;

  printf("Stalling rv11 - ");
  CHECK(dbg_cpu0_write_ctrl(0, 0x01));      // stall 1st CPU/Thread


  CHECK(dbg_cpu0_read_ctrl(0, &stalled));
  if (!(stalled & 0x1)) {
    printf("rv11 is not stalled!\n");       // check stall RV11
    return APP_ERR_TEST_FAIL;
  }

  printf("CPU(s) stalled.\n");

  return APP_ERR_NONE;
}


void init_mc(void)
{
  uint32_t insn;

  printf("Initialize Memory Controller (SDRAM)\n");
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_BAR_0, FLASH_BAR_VAL & 0xffff0000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_AMR_0, FLASH_AMR_VAL & 0xffff0000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_WTR_0, FLASH_WTR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_RTR_0, FLASH_RTR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_OSR, 0x40000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_BAR_4, SDRAM_BAR_VAL & 0xffff0000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_AMR_4, SDRAM_AMR_VAL & 0xffff0000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_CCR_4, 0x00bf0005));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_RATR, SDRAM_RATR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_RCDR, SDRAM_RCDR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_RCTR, SDRAM_RCTR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_REFCTR, SDRAM_REFCTR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_PTR, SDRAM_PTR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_RRDR, SDRAM_RRDR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_RIR, SDRAM_RIR_VAL));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_OSR, 0x5e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x5e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_OSR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x6e000000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_OSR, 0x7e000033));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_ORR, 0x7e000033));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_CCR_4, 0xc0bf0005));
  
  CHECK(dbg_wb_read32(MC_BASE_ADDR+MC_CCR_4, &insn));
  printf("expected %x, read %x\n", 0xc0bf0005, insn);
}


void init_sram(void)
{
  // SRAM initialized to 0x40000000
  printf("Initialize Memory Controller (SRAM)\n");
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_BAR_1, SRAM_BASE & 0xffff0000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_AMR_1, ~(SRAM_SIZE - 1) & 0xffff0000));
  CHECK(dbg_wb_write32(MC_BASE_ADDR + MC_CCR_1, 0xc020001f));
}



int test_sdram(void) 
{
  uint32_t insn;
  unsigned long i;
  uint32_t data4_out[0x08];
  uint32_t data4_in[0x08];
  uint16_t data2_out[0x10];
  uint16_t data2_in[0x10];
  uint8_t data1_out[0x20];
  uint8_t data1_in[0x20];
          
  printf("Start SDRAM WR\n");
  for (i=0x10; i<(SDRAM_SIZE+SDRAM_BASE); i=i<<1) {
    //printf("0x%x: 0x%x\n", SDRAM_BASE+i, i);
    CHECK(dbg_wb_write32(SDRAM_BASE+i, i));
  }
  
  printf("Start SDRAM RD\n");
  for (i=0x10; i<(SDRAM_SIZE+SDRAM_BASE); i=i<<1) {
    CHECK(dbg_wb_read32(SDRAM_BASE+i, &insn));
    //printf("0x%x: 0x%x\n", SDRAM_BASE+i, insn);
    if (i != insn) {
      printf("SDRAM test FAIL\n");
      return APP_ERR_TEST_FAIL;
    }
  }

  printf("32-bit block write from %x to %x\n", SDRAM_BASE, SDRAM_BASE + 0x20);
  for (i=0; i<(0x20/4); i++) {
    data4_out[i] = data4_in[i] = ((4*i+3)<<24) | ((4*i+2)<<16) | ((4*i+1)<<8) | (4*i);
    //printf("data_out = %0x\n", data4_out[i]);
  }
    
  //printf("Press a key for write\n"); getchar();
  CHECK(dbg_wb_write_block32(SDRAM_BASE, &data4_out[0], 0x20));

  // 32-bit block read is used for checking
  printf("32-bit block read from %x to %x\n", SDRAM_BASE, SDRAM_BASE + 0x20);
  CHECK(dbg_wb_read_block32(SDRAM_BASE, &data4_out[0], 0x20));
  for (i=0; i<(0x20/4); i++) {
    //printf("0x%x: 0x%x\n", SDRAM_BASE+(i*4), data_out[i]);
    if (data4_in[i] != data4_out[i]) {
      printf("SDRAM data differs. Expected: 0x%0x, read: 0x%0x\n", data4_in[i], data4_out[i]);
      return APP_ERR_TEST_FAIL;
    }
  }

 
  printf("16-bit block write from %x to %x\n", SDRAM_BASE, SDRAM_BASE + 0x20);
  for (i=0; i<(0x20/2); i++) {
    data2_out[i] = data2_in[i] = ((4*i+1)<<8) | (4*i);
    //printf("data_out = %0x\n", data_out[i]);
  }
  CHECK(dbg_wb_write_block16(SDRAM_BASE, &data2_out[0], 0x20));

  // 16-bit block read is used for checking
  printf("16-bit block read from %x to %x\n", SDRAM_BASE, SDRAM_BASE + 0x20);
  CHECK(dbg_wb_read_block16(SDRAM_BASE, &data2_out[0], 0x20));
  for (i=0; i<(0x20/2); i++) {
    //printf("0x%x: 0x%x\n", SDRAM_BASE+(i*4), data_out[i]);
    if (data2_in[i] != data2_out[i]) {
      printf("SDRAM data differs. Expected: 0x%0x, read: 0x%0x\n", data2_in[i], data2_out[i]);
      return APP_ERR_TEST_FAIL;
    }
  }

  printf("8-bit block write from %x to %x\n", SDRAM_BASE, SDRAM_BASE + 0x20);
  for (i=0; i<(0x20/1); i++) {
    data1_out[i] = data1_in[i] = (4*i);
    //printf("data_out = %0x\n", data_out[i]);
  }
  CHECK(dbg_wb_write_block8(SDRAM_BASE, &data1_out[0], 0x20));

  // 32-bit block read is used for checking
  printf("8-bit block read from %x to %x\n", SDRAM_BASE, SDRAM_BASE + 0x20);
  CHECK(dbg_wb_read_block8(SDRAM_BASE, &data1_out[0], 0x20));
  for (i=0; i<(0x20/1); i++) {
    //printf("0x%x: 0x%x\n", SDRAM_BASE+(i*4), data_out[i]);
    if (data1_in[i] != data1_out[i]) {
      printf("SDRAM data differs. Expected: 0x%0x, read: 0x%0x\n", data1_in[i], data1_out[i]);
      return APP_ERR_TEST_FAIL;
    }
  }

  printf("SDRAM OK!\n");
  return APP_ERR_NONE;
}


int test_sdram_2(void)
{
  uint32_t insn;

  printf("SDRAM test 2: \n");
  CHECK(dbg_wb_write32(SDRAM_BASE+0x00, 0x12345678));
  CHECK(dbg_wb_read32(SDRAM_BASE+0x00, &insn));
  printf("expected %x, read %x\n", 0x12345678, insn);
  if (insn != 0x12345678) return APP_ERR_TEST_FAIL;
  
  CHECK(dbg_wb_write32(SDRAM_BASE+0x0000, 0x11112222));
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0000, &insn));
  printf("expected %x, read %x\n", 0x11112222, insn);
  if (insn != 0x11112222) return APP_ERR_TEST_FAIL;

  CHECK(dbg_wb_write32(SDRAM_BASE+0x0004, 0x33334444));
  CHECK(dbg_wb_write32(SDRAM_BASE+0x0008, 0x55556666));
  CHECK(dbg_wb_write32(SDRAM_BASE+0x000c, 0x77778888));
  CHECK(dbg_wb_write32(SDRAM_BASE+0x0010, 0x9999aaaa));
  CHECK(dbg_wb_write32(SDRAM_BASE+0x0014, 0xbbbbcccc));
  CHECK(dbg_wb_write32(SDRAM_BASE+0x0018, 0xddddeeee));
  CHECK(dbg_wb_write32(SDRAM_BASE+0x001c, 0xffff0000));
  CHECK(dbg_wb_write32(SDRAM_BASE+0x0020, 0xdeadbeef));
  
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0000, &insn));
  printf("expected %x, read %x\n", 0x11112222, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0004, &insn));
  printf("expected %x, read %x\n", 0x33334444, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0008, &insn));
  printf("expected %x, read %x\n", 0x55556666, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x000c, &insn));
  printf("expected %x, read %x\n", 0x77778888, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0010, &insn));
  printf("expected %x, read %x\n", 0x9999aaaa, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0014, &insn));
  printf("expected %x, read %x\n", 0xbbbbcccc, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0018, &insn));
  printf("expected %x, read %x\n", 0xddddeeee, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x001c, &insn));
  printf("expected %x, read %x\n", 0xffff0000, insn);
  CHECK(dbg_wb_read32(SDRAM_BASE+0x0020, &insn));
  printf("expected %x, read %x\n", 0xdeadbeef, insn);
    
  if (insn != 0xdeadbeef) {
    printf("SDRAM test 2 FAILED\n");
    return APP_ERR_TEST_FAIL;
  }
    else
    printf("SDRAM test 2 passed\n");

  return APP_ERR_NONE;
}


int test_sram(void)
{
  //unsigned long insn;
  uint32_t ins;
  uint32_t insn[9];
  insn[0] = 0x11112222;
  insn[1] = 0x33334444;
  insn[2] = 0x55556666;
  insn[3] = 0x77778888;
  insn[4] = 0x9999aaaa;
  insn[5] = 0xbbbbcccc;
  insn[6] = 0xddddeeee;
  insn[7] = 0xffff0000;
  insn[8] = 0xdedababa;

  printf("SRAM test: \n");
  //dbg_wb_write_block32(0x0, insn, 9);
  
  CHECK(dbg_wb_write32(SRAM_BASE+0x0000, 0x11112222));
  CHECK(dbg_wb_write32(SRAM_BASE+0x0004, 0x33334444));
  CHECK(dbg_wb_write32(SRAM_BASE+0x0008, 0x55556666));
  CHECK(dbg_wb_write32(SRAM_BASE+0x000c, 0x77778888));
  CHECK(dbg_wb_write32(SRAM_BASE+0x0010, 0x9999aaaa));
  CHECK(dbg_wb_write32(SRAM_BASE+0x0014, 0xbbbbcccc));
  CHECK(dbg_wb_write32(SRAM_BASE+0x0018, 0xddddeeee));
  CHECK(dbg_wb_write32(SRAM_BASE+0x001c, 0xffff0000));
  CHECK(dbg_wb_write32(SRAM_BASE+0x0020, 0xdedababa));
  

  CHECK(dbg_wb_read32(SRAM_BASE+0x0000, &ins));
  printf("expected %x, read %x\n", 0x11112222, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x0004, &ins));
  printf("expected %x, read %x\n", 0x33334444, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x0008, &ins));
  printf("expected %x, read %x\n", 0x55556666, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x000c, &ins));
  printf("expected %x, read %x\n", 0x77778888, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x0010, &ins));
  printf("expected %x, read %x\n", 0x9999aaaa, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x0014, &ins));
  printf("expected %x, read %x\n", 0xbbbbcccc, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x0018, &ins));
  printf("expected %x, read %x\n", 0xddddeeee, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x001c, &ins));
  printf("expected %x, read %x\n", 0xffff0000, ins);
  CHECK(dbg_wb_read32(SRAM_BASE+0x0020, &ins));
  printf("expected %x, read %x\n", 0xdedababa, ins);
 
  if (ins != 0xdedababa) {
    printf("SRAM test failed!!!\n");
    return APP_ERR_TEST_FAIL;
  }
    else
    printf("SRAM test passed\n");

  return APP_ERR_NONE;
}



int test_rv11_cpu0(void)
{
  uint32_t npc, ppc, r1, insn;
  uint8_t stalled;
  uint32_t result;
  int i;

  printf("Testing CPU0 (RV11) - writing instructions\n");
  CHECK(dbg_wb_write32(SRAM_BASE+0x00, 0x00004033));   /* xor   x0,x0,x0               */
  CHECK(dbg_wb_write32(SRAM_BASE+0x04, 0x00000093));   /* addi  x1,x0,0x0              */
  CHECK(dbg_wb_write32(SRAM_BASE+0x08, 0x00010137));   /* lui   x2,0x00010  (RAM_BASE) */
  CHECK(dbg_wb_write32(SRAM_BASE+0x0c, 0x03016113));   /* ori   x2,x2,0x30             */
  CHECK(dbg_wb_write32(SRAM_BASE+0x10, 0x00108093));   /* addi  x1,x1,1                */
  CHECK(dbg_wb_write32(SRAM_BASE+0x14, 0x00108093));   /* addi  x1,x1,1                */
  CHECK(dbg_wb_write32(SRAM_BASE+0x18, 0x00112023));   /* sw    0(x2),x1               */
  CHECK(dbg_wb_write32(SRAM_BASE+0x1c, 0x00108093));   /* addi  x1,x1,1                */
  CHECK(dbg_wb_write32(SRAM_BASE+0x20, 0x00012183));   /* lw    x3,0(x2)               */
  CHECK(dbg_wb_write32(SRAM_BASE+0x24, 0x003080b3));   /* add   x1,x1,x3               */
  CHECK(dbg_wb_write32(SRAM_BASE+0x28, 0xfe9ff06f));   /* j     (base+0x10)            */

  printf("Setting up CPU0\n");

  /*
   * Test 1
   */
  //enable Single-Stepping
  CHECK(dbg_cpu0_read(DBG_CTRL, &r1)); //read DU-CTRL
  r1 |= DBG_CTRL_SINGLE_STEP_TRACE;
  CHECK(dbg_cpu0_write(DBG_CTRL, r1));

  //set PC
  CHECK(dbg_cpu0_write(DBG_NPC, SRAM_BASE));


  printf("Starting CPU0!\n");
  for(i = 0; i < 11; i++) {
    CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));      /* 11x Unstall */
    printf("Starting CPU, waiting for breakpoint ...\n");
    do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));
    printf("Got breakpoint\n");
/*
    CHECK(dbg_cpu0_read(DBG_CTRL, &r1)); //read MDCTRL
    printf ("DBG_CTRL=%.8x\n", r1);
    CHECK(dbg_cpu0_read(DBG_NPC, &npc));   //read NPC
    CHECK(dbg_cpu0_read(DBG_PPC, &ppc));   //read PPC
    printf ("PPC-->NPC=%.8x-->%.8x\n", ppc,npc);
*/
  }

  CHECK(dbg_cpu0_read(DBG_NPC, &npc));              /* Read NPC */
  CHECK(dbg_cpu0_read(DBG_PPC, &ppc));              /* Read PPC */
  CHECK(dbg_cpu0_read(DBG_X(1),&r1 ));              /* Read x1 */
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x00010010, 0x00010028, 5);
  result = npc + ppc + r1;

//return APP_ERR_NONE;

  /*
   * Test 2
   */
  //disable Single-Stepping, clear Single-Step-Hit bit
  CHECK(dbg_cpu0_read(DBG_CTRL, &r1)); //read DBG_CTRL
  r1 &= ~(DBG_CTRL_SINGLE_STEP_TRACE);
  CHECK(dbg_cpu0_write(DBG_CTRL, r1));

  CHECK(dbg_cpu0_write(DBG_HIT, 0)); //clear all HIT bits


  //Enable EBREAK to call debug controller
  CHECK(dbg_cpu0_write(DBG_IE, BREAKPOINT_INT)); //BREAK hands over to DebugUnit, does not cause an exception

  //set EBREAK at last 'add' instruction
  CHECK(dbg_wb_read32(SRAM_BASE + 0x24, &insn));
  CHECK(dbg_wb_write32(SRAM_BASE + 0x24, EBREAK));

  //unstall CPU
  CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));

  //wait for STALL
  do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));

  //write back original instruction
  CHECK(dbg_wb_write32(SRAM_BASE + 0x24, insn));

  CHECK(dbg_cpu0_read(DBG_NPC, &npc));  // Read NPC 
  CHECK(dbg_cpu0_read(DBG_PPC, &ppc));  // Read PPC 
  CHECK(dbg_cpu0_read(DBG_X(1),&r1 ));  // Read R1 
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x00010028, 0x00000024, 8);
  result = npc + ppc + r1 + result;

//return APP_ERR_NONE;

  /*
   * Test 3
   */
  CHECK(dbg_wb_read32(SRAM_BASE + 0x28, &insn));  // Set trap insn in place of jump insn 
  CHECK(dbg_wb_write32(SRAM_BASE + 0x28, EBREAK));
  CHECK(dbg_cpu0_write(DBG_NPC, SRAM_BASE + 0x10));  // Set PC 

  //unstall CPU
  CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));

  //wait for STALL
  do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));

  //Write back original instruction
  CHECK(dbg_wb_write32(SRAM_BASE + 0x28, insn));

  CHECK(dbg_cpu0_read(DBG_NPC, &npc));  // Read NPC 
  CHECK(dbg_cpu0_read(DBG_PPC, &ppc));  // Read PPC 
  CHECK(dbg_cpu0_read(DBG_X(1),&r1 ));  // Read R1 
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x0001002c, 0x00010028, 21);
  result = npc + ppc + r1 + result;

//return APP_ERR_NONE;

  /*
   * Test 4
   */
  CHECK(dbg_wb_read32(SRAM_BASE + 0x10, &insn));  /* Set trap insn to the start */
  CHECK(dbg_wb_write32(SRAM_BASE + 0x10, EBREAK));
  CHECK(dbg_cpu0_write(DBG_NPC, SRAM_BASE + 0x20)  /* Set PC */);

  //unstall CPU
  CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));

  //Wait for STALL
  do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));

  //Write back original instruction
  CHECK(dbg_wb_write32(SRAM_BASE + 0x28, insn));

  CHECK(dbg_cpu0_read(DBG_NPC, &npc));  // Read NPC
  CHECK(dbg_cpu0_read(DBG_PPC, &ppc));  // Read PPC
  CHECK(dbg_cpu0_read(DBG_X(1),&r1 ));  // Read R1
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x00010014, 0x00010010, 31);
  result = npc + ppc + r1 + result;

return APP_ERR_NONE;


  CHECK(dbg_cpu0_write((6 << 11) + 16, 1 << 22));  /* Set step bit */
  for(i = 0; i < 5; i++) {
    CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));  /* Unstall */
    //printf("Waiting for trap...");
    do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));
    //printf("got trap.\n");
  }
  CHECK(dbg_cpu0_read((0 << 11) + 16, &npc));  /* Read NPC */
  CHECK(dbg_cpu0_read((0 << 11) + 18, &ppc));  /* Read PPC */
  CHECK(dbg_cpu0_read(0x401, &r1));  /* Read R1 */
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x00000028, 0x00000024, 101);
  result = npc + ppc + r1 + result;

  CHECK(dbg_cpu0_write((0 << 11) + 16, SDRAM_BASE + 0x24));  /* Set PC */
  for(i = 0; i < 2; i++) {
    CHECK(dbg_cpu0_write_ctrl(CPU_OP_ADR, 0x00));  /* Unstall */
    //printf("Waiting for trap...\n");
    do CHECK(dbg_cpu0_read_ctrl(CPU_OP_ADR, &stalled)); while (!(stalled & 1));
    //printf("Got trap.\n");
  }
  CHECK(dbg_cpu0_read((0 << 11) + 16, &npc));  /* Read NPC */
  CHECK(dbg_cpu0_read((0 << 11) + 18, &ppc));  /* Read PPC */
  CHECK(dbg_cpu0_read(0x401, &r1));  /* Read R1 */
  printf("Read      npc = %.8x ppc = %.8x r1 = %.8x\n", npc, ppc, r1);
  printf("Expected  npc = %.8x ppc = %.8x r1 = %.8x\n", 0x00000010, 0x00000028, 201);
  result = npc + ppc + r1 + result;
  printf("result = %.8x\n", result ^ 0xdeaddae1);

  if((result ^ 0xdeaddae1) != 0xdeaddead)
    return APP_ERR_TEST_FAIL;

  return APP_ERR_NONE;
}

