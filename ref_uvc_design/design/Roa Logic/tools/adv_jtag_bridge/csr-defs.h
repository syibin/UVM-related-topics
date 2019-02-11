/* csr-defs.h -- Defines RISC-V (and RVxx in particular) control/status registers

   Copyright (C) 2016 Roa Logic BV  
   Contributor Richard Herveille <richard.herveille@roalogic.com>
  
   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the Free
   Software Foundation; either version 3 of the License, or (at your option)
   any later version.
  
   This program is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
  
   You should have received a copy of the GNU General Public License along
   with this program.  If not, see <http://www.gnu.org/licenses/>. */

#ifndef CSR_DEFS__H
#define CSR_DEFS__H


/*
 *  General Definitions
 */

//number of General Purpose (Integer) Registers
#define MAX_GPRS			(32)
#define MAX_FPRS			(32)
#define MAX_CSRS			(1 << 12)

//Offset in Debug Address Space
#define DBG_CTRL_BASE			0x0000
#define DBG_GPR_BASE			0x1000
#define DBG_FPR_BASE			0x1100
#define DBG_CSR_BASE			0x2000

#define NO_VECTOR			0x000
#define USER_MODE_VECTOR		0x100
#define SUPERVISOR_MODE_VECTOR		0x140
#define HYPERVISOR_MODE_VECTOR		0x180
#define MACHINE_MODE_VECTOR		0x1C0
#define NON_MASKABLE_INTERRUPT_VECTOR	0x1FC
#define RESET_VECTOR			0x200

#define RISCV_EBREAK_INSTR		0x00100073


/*
 * DU Register Access
 */
#define MAX_BREAKPOINTS			8

//DU (internal) Control registers
#define DBG_CTRL			(DBG_CTRL_BASE + 0x00)
#define DBG_HIT				(DBG_CTRL_BASE + 0x01)
#define DBG_IE				(DBG_CTRL_BASE + 0x02)
#define DBG_CAUSE			(DBG_CTRL_BASE + 0x03)
#define DBG_BPCTRL(N)			(DBG_CTRL_BASE + 0x10 + 2*N)
#define DBG_BPDATA(N)			(DBG_CTRL_BASE + 0x11 + 2*N)

//Next/Current Program Counters
#define DBG_NPC				(DBG_GPR_BASE + 0x200)
#define DBG_PPC				(DBG_GPR_BASE + 0x201)

//Debug CSRs
#define DBG_CSR(N)			(DBG_CSR_BASE + N)

//Integer Register File
#define DBG_X(N)			(DBG_GPR_BASE + N)

//Bit definitions
#define DBG_CTRL_SINGLE_STEP_TRACE	0x01       /* Enable single-step trace                        */
#define DBG_CTRL_BRANCH_TRACE		0x02       /* Enable branch-trace                             */

#define DBG_HIT_SINGLE_STEP		0x01       /* Single-Step caused breakpoint                   */
#define DBG_HIT_BRANCH			0x02       /* Branch-trace caused breakpoint                  */
#define DBG_HIT_BP(N)			(0x10 <<N) /* BreakPoint(n) caused breakpoint             */
#define DBG_HIT_MASK			0xFF3      /* Masks all HIT bits                              */
#define DBG_HIT_BP_MASK			0xFF0      /* Masks all BP HIT bits                           */

#define DBG_BPCTRL_IMPLEMENTED		0x01
#define DBG_BPCTRL_ENABLED		0x02
#define DBG_BPCTRL_CC_INST_FETCH	(0x0 << 4)
#define DBG_BPCTRL_CC_LD_ADR 		(0x1 << 4)
#define DBG_BPCTRL_CC_ST_ADR		(0x2 << 4)
#define DBG_BPCTRL_CC_LDST_ADR		(0x3 << 4)
#define DBG_BPCTRL_CC_MASK              (0x7 << 4)

#define DBG_IE_INST_MISALIGNED		0x00001
#define DBG_IE_INST_ACCESS_FAULT	0x00002
#define DBG_IE_ILLEGAL			0x00004
#define DBG_IE_BREAKPOINT		0x00008
#define DBG_IE_LOAD_MISALIGNED		0x00010
#define DBG_IE_LOAD_ACCESS_FAULT	0x00020
#define DBG_IE_AMO_MISALIGNED		0x00040
#define DBG_IE_STORE_ACCESS_FAULT	0x00080
#define DBG_IE_UMODE_ECALL		0x00100
#define DBG_IE_SMODE_ECALL		0x00200
#define DBG_IE_HMODE_ECALL		0x00400
#define DBG_IE_MMODE_ECALL		0x00800
#define DBG_IE_SOFTWARE_INT		0x10000
#define DBG_IE_TIMER_INT		0x20000
#define DBG_IE_UART			0x40000


/*
 * CSRs
 */

/* User Level CSRs */

#define CSR_FFLAGS 			0x001
#define CSR_FRM    			0x002
#define CSR_FCSR   			0x003

#define CSR_CYCLE  			0xC00
#define CSR_TIME   			0xC01
#define CSR_INSTRET			0xC02
#define CSR_CYCLEH			0xC80
#define CSR_TIMEH			0xC81
#define CSR_INSTRETH			0xC82


/* Supervisor Level CSRs */

#define CSR_SSTATUS			0x100
#define CSR_STVEC			0x101
#define	CSR_SIE				0x104
#define	CSR_STIMECMP			0x121

#define CSR_STIME			0xD01
#define CSR_STIMEH			0xD81

#define CSR_SSCRATCH			0x140
#define CSR_SEPC			0x141
#define	CSR_SCAUSE			0xD42
#define	CSR_SBADADDR			0xD43
#define	CSR_SIP				0x144

#define CSR_SPTBR			0x180
#define	CSR_SASID			0x181

#define CSR_CYCLEW  			0x900
#define CSR_TIMEW   			0x901
#define CSR_INSTRETW			0x902
#define CSR_CYCLEHW			0x980
#define CSR_TIMEHW			0x981
#define CSR_INSTRETHW			0x982


/* Hypervisor Level CSRs */

#define CSR_HSTATUS			0x200
#define CSR_HTVEC			0x201
#define CSR_HTDELEG			0x202
#define	CSR_HTIMECMP			0x221

#define CSR_HTIME			0xE01
#define CSR_HTIMEH			0xE81

#define CSR_HSCRATCH			0x240
#define CSR_HEPC			0x241
#define	CSR_HCAUSE			0x242
#define	CSR_HBADADDR			0x243

#define CSR_STIMEW 		  	0xA01
#define CSR_STIMEHW			0xA81


/* Machine Level CSRs */

#define CSR_MCPUID			0xF00
#define CSR_MIMPID			0xF01
#define CSR_MHARTID			0xF10

#define CSR_MSTATUS			0x300
#define CSR_MTVEC			0x301
#define CSR_MTDELEG			0x302
#define	CSR_MIE				0x304
#define	CSR_MTIMECMP			0x321

#define CSR_MTIME			0x701
//#define CSR_MTIMEH			0x781
#define CSR_MTIMEH			0x741

#define CSR_MSCRATCH			0x340
#define CSR_MEPC			0x341
#define	CSR_MCAUSE			0x342
#define	CSR_MBADADDR			0x343
#define	CSR_MIP				0x344

#define CSR_MBASE			0x380
#define CSR_MBOUND			0x381
#define CSR_MIBASE			0x382
#define CSR_MIBOUND			0x383
#define CSR_MDBASE			0x384
#define CSR_MDBOUND			0x385

#define CSR_HTIMEW   			0xB01
#define CSR_HTIMEHW			0xB81



/*
 * Bit Definitions
 */

/* Machine Level ISA */

#define CSR_MCPUID_BASE_RV32I		0x0
#define CSR_MCPUID_BASE_RV32E		0x1
#define CSR_MCPUID_BASE_RV64I		0x2
#define CSR_MCPUID_BASE_RV128I		0x3

/* cause registers */
#define CSR_CAUSE_INST_MISALIGNED	0
#define CSR_CAUSE_INST_ACCESS_FAULT	1
#define CSR_CAUSE_ILLEGAL		2
#define CSR_CAUSE_BREAKPOINT		3
#define CSR_CAUSE_LOAD_MISALIGNED	4
#define CSR_CAUSE_LOAD_ACCESS_FAULT	5
#define CSR_CAUSE_AMO_MISALIGNED	6
#define CSR_CAUSE_STORE_ACCESS_FAULT	7
#define CSR_CAUSE_UMODE_ECALL		8
#define CSR_CAUSE_SMODE_ECALL		9
#define CSR_CAUSE_HMODE_ECALL		10
#define CSR_CAUSE_MMODE_ECALL		11

#define CSR_CAUSE_SOFTWARE_INT		0
#define CSR_CAUSE_TIMER_INT		1
#define CSR_CAUSE_UART			2

#endif //CSR_DEFS
