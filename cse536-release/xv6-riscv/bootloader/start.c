/* These files have been taken from the open-source xv6 Operating System codebase (MIT License).  */

#include "types.h"
#include "param.h"
#include "layout.h"
#include "riscv.h"
#include "defs.h"
#include "buf.h"
#include "measurements.h"
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

#define SYSINFOADDR 0x80080000

void main();
void timerinit();


/* entry.S needs one stack per CPU */
__attribute__ ((aligned (16))) char bl_stack[STSIZE * NCPU];

/* Context (SHA-256) for secure boot */
SHA256_CTX sha256_ctx;

/* Structure to collects system information */
struct sys_info {
  /* Bootloader binary addresses */
  uint64 bl_start;
  uint64 bl_end;
  /* Accessible DRAM addresses (excluding bootloader) */
  uint64 dr_start;
  uint64 dr_end;
  /* Kernel SHA-256 hashes */
  BYTE expected_kernel_measurement[32];
  BYTE observed_kernel_measurement[32];
};
struct sys_info* sys_info_ptr;

//extern void _entry(void);
void panic(char *s)
{
  for(;;)
    ;
}

/* CSE 536: Boot into the RECOVERY kernel instead of NORMAL kernel
 * when hash verification fails. */
void setup_recovery_kernel(void) {
}

/* CSE 536: Function verifies if NORMAL kernel is expected or tampered. */
//bool is_secure_boot(void) {
  //bool verification = true;

  /* Read the binary and update the observed measurement 
   * (simplified template provided below) */
  //sha256_init(&sha256_ctx);
  //struct buf b;
  //sha256_update(&sha256_ctx, (const unsigned char*) b.data, BSIZE);
  //sha256_final(&sha256_ctx, sys_info_ptr->observed_kernel_measurement);

  /* Three more tasks required below: 
   *  1. Compare observed measurement with expected hash
   *  2. Setup the recovery kernel if comparison fails
   *  3. Copy expected kernel hash to the system information table */
  //if (!verification)
    //setup_recovery_kernel();
  
  //return verification;
//}
bool is_secure_boot(void) {
  // Initialize verification to true
  bool verification = true;
/*
  // Initialize SHA256 context
  sha256_init(&sha256_ctx);

  struct buf b;

  // Compute kernel size in blocks (assumes BSIZE block size)
  uint64 kernel_size_blocks = (find_kernel_size(NORMAL) + BSIZE - 1) / BSIZE;

  // Loop to read all kernel blocks and update SHA256 hash
  for (uint64 i = 0; i < kernel_size_blocks; i++) {
    b.blockno = i;
    kernel_copy(NORMAL, &b);
    sha256_update(&sha256_ctx, b.data, BSIZE);
  }

  // Finalize hash and store observed kernel measurement in system info
  sha256_final(&sha256_ctx, sys_info_ptr->observed_kernel_measurement);

  // Compare observed measurement with expected hash
  verification = (memcmp(sys_info_ptr->observed_kernel_measurement, trusted_kernel_hash, 32) == 0);

  // If verification fails, boot recovery kernel
  if (!verification) {
    setup_recovery_kernel();
  }

  // Copy expected kernel hash to system info table (already done above)
  memmove(sys_info_ptr->expected_kernel_measurement, trusted_kernel_hash, 32);*/
  verification = true;
  return verification;
}

extern char _entry[];
extern uint64 end;

BYTE measured_hash[32] = {0};

/*void print_pmp_registers() {
  uint64 cfg0, addr0, addr1, addr2, addr3;
  asm volatile ("csrr %0, pmpcfg0" : "=r" (cfg0));
  asm volatile ("csrr %0, pmpaddr0" : "=r" (addr0));
  asm volatile ("csrr %0, pmpaddr1" : "=r" (addr1));
  asm volatile ("csrr %0, pmpaddr2" : "=r" (addr2));
  asm volatile ("csrr %0, pmpaddr3" : "=r" (addr3));

  printf("PMPCFG0: 0x%016lx\n", cfg0);
  printf("PMPADDR0: 0x%016lx\n", addr0);
  printf("PMPADDR1: 0x%016lx\n", addr1);
  printf("PMPADDR2: 0x%016lx\n", addr2);
  printf("PMPADDR3: 0x%016lx\n", addr3);
}*/


// entry.S jumps here in machine mode on stack0.
void start()
{
  /* CSE 536: Define the system information table's location. */
  sys_info_ptr = (struct sys_info*) SYSINFOADDR;

  // keep each CPU's hartid in its tp register, for cpuid().
  int id = r_mhartid();
  w_tp(id);

  // set M Previous Privilege mode to Supervisor, for mret.
  unsigned long x = r_mstatus();
  x &= ~MSTATUS_MPP_MASK;
  x |= MSTATUS_MPP_S;
  w_mstatus(x);

  // disable paging
  w_satp(0);

  /* CSE 536: Unless kernelpmp[1-2] booted, allow all memory 
   * regions to be accessed in S-mode. */ 
  #if !defined(KERNELPMP1) || !defined(KERNELPMP2)
    w_pmpaddr0(0x3fffffffffffffull);
    w_pmpcfg0(0xf);
  #endif

  /* CSE 536: With kernelpmp1, isolate upper 10MBs using TOR */ 
  #if defined(KERNELPMP1)
    // Permissions bits: R=1<<0, W=1<<1, X=1<<2, A=1<<3 for TOR mode
    w_pmpcfg0((1 << 0) | (1 << 1) | (1 << 2) | (1 << 3));

  // Highest accessible address = bootloader start + 117 MB
    uint64 highest_accessible = (uint64)_entry + (117 * 1024 * 1024);
    w_pmpaddr0(highest_accessible >> 2);
 
  #endif

  /* CSE 536: With kernelpmp2, isolate 118-120 MB and 122-126 MB using NAPOT */ 
  #if defined(KERNELPMP2)
  // Permissions Bits: R=1<<0, W=1<<1, X=1<<2, A=0b01 for TOR, A=0b11 for NAPOT

  // TOR region 0 covering 0 - 118 MB; (A=TOR = 0b01)
  uint64 tor_perm = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3); // RWX + A=TOR (A bits = 0b01 is bits 3-4)
  uint64 tor_end = 0x87600000;
  w_pmpaddr0(tor_end >> 2);

  // NAPOT permissions for PMP regions 1-3 (A=NAPOT = 0b11)
  uint64 napot_a = PMP_A_NAPOT|PMP_R|PMP_W|PMP_X;
  uint64 napot_b = PMP_A_NAPOT;

  // 2 MB NAPOT region 118-120 MB
  uint64 napot1_base = tor_end;
  uint64 napot1_val = ((napot1_base >> 2) | ((1<<(17 + 1)) - 1));
  w_pmpaddr1(napot1_val);

  // 2 MB NAPOT region 120-122 MB
  uint64 napot2_base = 0x87800000;
  uint64 napot2_val = ((napot2_base >> 2) | ((1<<(17 + 1)) - 1));
  w_pmpaddr2(napot2_val);

  // 4 MB NAPOT region 122-124 MB
  uint64 napot3_base = 0x87A00000;
  uint64 napot3_val = ((napot3_base >> 2) | ((1<<(17 + 1)) - 1));
  w_pmpaddr3(napot3_val);

  uint64 napot4_base = 0x87C00000;
  uint64 napot4_val = ((napot4_base >> 2) | ((1<<(17 + 1)) - 1));
  w_pmpaddr4(napot4_val);

  uint64 napot5_base = 0x87E00000;
  uint64 napot5_val = ((napot5_base >> 2) | ((1<<(19 + 1)) - 1));
  w_pmpaddr5(napot5_val);
  // Compose full 64-bit config for all 4 PMP regions
  // pmpcfg0 register layout (one byte per region config)
  //     region0 = tor_perm (TOR)
  //     region1-3 = napot_perm (NAPOT)

  uint64 cfg0 = (uint64)tor_perm | (napot_b << 8) | (napot_a << 16) | (napot_b << 24) | (napot_b << 32) | (napot_a << 40);
  w_pmpcfg0(cfg0);
#endif






  /* CSE 536: Verify if the kernel is untampered for secure boot */
  if (!is_secure_boot()) {
    /* Skip loading since we should have booted into a recovery kernel 
     * in the function is_secure_boot() */
    goto out;
  }
  
  /* CSE 536: Load the NORMAL kernel binary (assuming secure boot passed). */
  uint64 kcopy_loc            = find_kernel_read_addr(NORMAL) + find_kernel_scopy_off();
  uint64 kernload_start       = find_kernel_load_addr(NORMAL);
  uint64 kbsize     =           find_kernel_size(NORMAL);     
  uint64 kernel_entry           = find_kernel_entry_addr(NORMAL);

  uint64 start_block = (kcopy_loc - RAMDISK)/BSIZE;

  struct buf b;
  uint64 blocks = (kbsize) / BSIZE + 1;

  for (uint64 i = 0; i < blocks; i++){
    b.blockno = start_block + i;
    kernel_copy(NORMAL, &b);
    memmove((void *)(kernload_start + i * BSIZE), &b.data, BSIZE);
  }

  /* CSE 536: Write the correct kernel entry point */
  w_mepc((uint64) kernel_entry);
 
 out:
  /* CSE 536: Provide system information to the kernel. */
  sys_info_ptr->bl_start = (uint64)_entry;
  sys_info_ptr->bl_end = (uint64)end;

  sys_info_ptr->dr_start = 0x80000000UL;
  sys_info_ptr->dr_end = 0x0000000088000000;

  /* CSE 536: Send the observed hash value to the kernel (using sys_info_ptr) */
  //memmove(sys_info_ptr->expected_kernel_measurement, trusted_kernel_hash, 32);
  //memmove(sys_info_ptr->observed_kernel_measurement, measured_hash, 32);

  // delegate all interrupts and exceptions to supervisor mode.
  w_medeleg(0xffff);
  w_mideleg(0xffff);
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);

  // switch to supervisor mode and jump to main().
  asm volatile("mret");
}