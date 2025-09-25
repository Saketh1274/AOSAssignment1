
bootloader/bootloader:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00011117          	auipc	sp,0x11
    80000004:	b6010113          	addi	sp,sp,-1184 # 80010b60 <sys_info_ptr>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	40a10133          	sub	sp,sp,a0
    80000018:	032000ef          	jal	8000004a <start>

000000008000001c <spin>:
    8000001c:	a001                	j	8000001c <spin>

000000008000001e <panic>:
};
struct sys_info* sys_info_ptr;

//extern void _entry(void);
void panic(char *s)
{
    8000001e:	1141                	addi	sp,sp,-16
    80000020:	e406                	sd	ra,8(sp)
    80000022:	e022                	sd	s0,0(sp)
    80000024:	0800                	addi	s0,sp,16
  for(;;)
    80000026:	a001                	j	80000026 <panic+0x8>

0000000080000028 <setup_recovery_kernel>:
    ;
}

/* CSE 536: Boot into the RECOVERY kernel instead of NORMAL kernel
 * when hash verification fails. */
void setup_recovery_kernel(void) {
    80000028:	1141                	addi	sp,sp,-16
    8000002a:	e406                	sd	ra,8(sp)
    8000002c:	e022                	sd	s0,0(sp)
    8000002e:	0800                	addi	s0,sp,16
}
    80000030:	60a2                	ld	ra,8(sp)
    80000032:	6402                	ld	s0,0(sp)
    80000034:	0141                	addi	sp,sp,16
    80000036:	8082                	ret

0000000080000038 <is_secure_boot>:
  //if (!verification)
    //setup_recovery_kernel();
  
  //return verification;
//}
bool is_secure_boot(void) {
    80000038:	1141                	addi	sp,sp,-16
    8000003a:	e406                	sd	ra,8(sp)
    8000003c:	e022                	sd	s0,0(sp)
    8000003e:	0800                	addi	s0,sp,16

  // Copy expected kernel hash to system info table (already done above)
  memmove(sys_info_ptr->expected_kernel_measurement, trusted_kernel_hash, 32);*/
  verification = true;
  return verification;
}
    80000040:	4505                	li	a0,1
    80000042:	60a2                	ld	ra,8(sp)
    80000044:	6402                	ld	s0,0(sp)
    80000046:	0141                	addi	sp,sp,16
    80000048:	8082                	ret

000000008000004a <start>:
}*/


// entry.S jumps here in machine mode on stack0.
void start()
{
    8000004a:	b8010113          	addi	sp,sp,-1152
    8000004e:	46113c23          	sd	ra,1144(sp)
    80000052:	46813823          	sd	s0,1136(sp)
    80000056:	46913423          	sd	s1,1128(sp)
    8000005a:	47213023          	sd	s2,1120(sp)
    8000005e:	45313c23          	sd	s3,1112(sp)
    80000062:	45413823          	sd	s4,1104(sp)
    80000066:	45513423          	sd	s5,1096(sp)
    8000006a:	45613023          	sd	s6,1088(sp)
    8000006e:	43713c23          	sd	s7,1080(sp)
    80000072:	48010413          	addi	s0,sp,1152
  /* CSE 536: Define the system information table's location. */
  sys_info_ptr = (struct sys_info*) SYSINFOADDR;
    80000076:	010017b7          	lui	a5,0x1001
    8000007a:	079e                	slli	a5,a5,0x7
    8000007c:	00011717          	auipc	a4,0x11
    80000080:	aef73223          	sd	a5,-1308(a4) # 80010b60 <sys_info_ptr>
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000084:	f14027f3          	csrr	a5,mhartid

  // keep each CPU's hartid in its tp register, for cpuid().
  int id = r_mhartid();
  w_tp(id);
    80000088:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    8000008a:	823e                	mv	tp,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008c:	300027f3          	csrr	a5,mstatus

  // set M Previous Privilege mode to Supervisor, for mret.
  unsigned long x = r_mstatus();
  x &= ~MSTATUS_MPP_MASK;
    80000090:	7779                	lui	a4,0xffffe
    80000092:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <kernel_elfhdr+0xffffffff7ffedc8f>
    80000096:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000098:	6705                	lui	a4,0x1
    8000009a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000009e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a0:	30079073          	csrw	mstatus,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000a4:	4781                	li	a5,0
    800000a6:	18079073          	csrw	satp,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000b8:	21d807b7          	lui	a5,0x21d80
    800000bc:	3b079073          	csrw	pmpaddr0,a5
static inline void w_pmpaddr1(uint64 x) { asm volatile("csrw pmpaddr1, %0" : : "r"(x)); }
    800000c0:	21dc07b7          	lui	a5,0x21dc0
    800000c4:	17fd                	addi	a5,a5,-1 # 21dbffff <_entry-0x5e240001>
    800000c6:	3b179073          	csrw	pmpaddr1,a5
static inline void w_pmpaddr2(uint64 x) { asm volatile("csrw pmpaddr2, %0" : : "r"(x)); }
    800000ca:	21e407b7          	lui	a5,0x21e40
    800000ce:	17fd                	addi	a5,a5,-1 # 21e3ffff <_entry-0x5e1c0001>
    800000d0:	3b279073          	csrw	pmpaddr2,a5
static inline void w_pmpaddr3(uint64 x) { asm volatile("csrw pmpaddr3, %0" : : "r"(x)); }
    800000d4:	21ec07b7          	lui	a5,0x21ec0
    800000d8:	17fd                	addi	a5,a5,-1 # 21ebffff <_entry-0x5e140001>
    800000da:	3b379073          	csrw	pmpaddr3,a5
static inline void w_pmpaddr4(uint64 x) { asm volatile("csrw pmpaddr4, %0" : : "r"(x)); }
    800000de:	21f407b7          	lui	a5,0x21f40
    800000e2:	17fd                	addi	a5,a5,-1 # 21f3ffff <_entry-0x5e0c0001>
    800000e4:	3b479073          	csrw	pmpaddr4,a5
static inline void w_pmpaddr5(uint64 x) { asm volatile("csrw pmpaddr5, %0" : : "r"(x)); }
    800000e8:	220007b7          	lui	a5,0x22000
    800000ec:	17fd                	addi	a5,a5,-1 # 21ffffff <_entry-0x5e000001>
    800000ee:	3b579073          	csrw	pmpaddr5,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000f2:	3e3037b7          	lui	a5,0x3e303
    800000f6:	078a                	slli	a5,a5,0x2
    800000f8:	0f978793          	addi	a5,a5,249 # 3e3030f9 <_entry-0x41cfcf07>
    800000fc:	07b6                	slli	a5,a5,0xd
    800000fe:	80f78793          	addi	a5,a5,-2033
    80000102:	3a079073          	csrw	pmpcfg0,a5
     * in the function is_secure_boot() */
    goto out;
  }
  
  /* CSE 536: Load the NORMAL kernel binary (assuming secure boot passed). */
  uint64 kcopy_loc            = find_kernel_read_addr(NORMAL) + find_kernel_scopy_off();
    80000106:	4501                	li	a0,0
    80000108:	00000097          	auipc	ra,0x0
    8000010c:	35a080e7          	jalr	858(ra) # 80000462 <find_kernel_read_addr>
    80000110:	84aa                	mv	s1,a0
    80000112:	00000097          	auipc	ra,0x0
    80000116:	3b4080e7          	jalr	948(ra) # 800004c6 <find_kernel_scopy_off>
    8000011a:	94aa                	add	s1,s1,a0
  uint64 kernload_start       = find_kernel_load_addr(NORMAL);
    8000011c:	4501                	li	a0,0
    8000011e:	00000097          	auipc	ra,0x0
    80000122:	3c2080e7          	jalr	962(ra) # 800004e0 <find_kernel_load_addr>
    80000126:	892a                	mv	s2,a0
  uint64 kbsize     =           find_kernel_size(NORMAL);     
    80000128:	4501                	li	a0,0
    8000012a:	00000097          	auipc	ra,0x0
    8000012e:	3d0080e7          	jalr	976(ra) # 800004fa <find_kernel_size>
    80000132:	89aa                	mv	s3,a0
  uint64 kernel_entry           = find_kernel_entry_addr(NORMAL);
    80000134:	4501                	li	a0,0
    80000136:	00000097          	auipc	ra,0x0
    8000013a:	412080e7          	jalr	1042(ra) # 80000548 <find_kernel_entry_addr>
    8000013e:	8baa                	mv	s7,a0

  uint64 start_block = (kcopy_loc - RAMDISK)/BSIZE;
    80000140:	fdf00793          	li	a5,-33
    80000144:	07ea                	slli	a5,a5,0x1a
    80000146:	94be                	add	s1,s1,a5
    80000148:	80a9                	srli	s1,s1,0xa

  struct buf b;
  uint64 blocks = (kbsize) / BSIZE + 1;
    8000014a:	00a9d993          	srli	s3,s3,0xa
    8000014e:	0985                	addi	s3,s3,1
    80000150:	99a6                	add	s3,s3,s1

  for (uint64 i = 0; i < blocks; i++){
    b.blockno = start_block + i;
    kernel_copy(NORMAL, &b);
    80000152:	b8040b13          	addi	s6,s0,-1152
    memmove((void *)(kernload_start + i * BSIZE), &b.data, BSIZE);
    80000156:	bb040a93          	addi	s5,s0,-1104
    8000015a:	40000a13          	li	s4,1024
    b.blockno = start_block + i;
    8000015e:	b8943823          	sd	s1,-1136(s0)
    kernel_copy(NORMAL, &b);
    80000162:	85da                	mv	a1,s6
    80000164:	4501                	li	a0,0
    80000166:	00000097          	auipc	ra,0x0
    8000016a:	096080e7          	jalr	150(ra) # 800001fc <kernel_copy>
    memmove((void *)(kernload_start + i * BSIZE), &b.data, BSIZE);
    8000016e:	8652                	mv	a2,s4
    80000170:	85d6                	mv	a1,s5
    80000172:	854a                	mv	a0,s2
    80000174:	00000097          	auipc	ra,0x0
    80000178:	132080e7          	jalr	306(ra) # 800002a6 <memmove>
  for (uint64 i = 0; i < blocks; i++){
    8000017c:	0485                	addi	s1,s1,1
    8000017e:	40090913          	addi	s2,s2,1024
    80000182:	fd349ee3          	bne	s1,s3,8000015e <start+0x114>
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000186:	341b9073          	csrw	mepc,s7
  /* CSE 536: Write the correct kernel entry point */
  w_mepc((uint64) kernel_entry);
 
 out:
  /* CSE 536: Provide system information to the kernel. */
  sys_info_ptr->bl_start = (uint64)_entry;
    8000018a:	00011797          	auipc	a5,0x11
    8000018e:	9d678793          	addi	a5,a5,-1578 # 80010b60 <sys_info_ptr>
    80000192:	6398                	ld	a4,0(a5)
    80000194:	00000697          	auipc	a3,0x0
    80000198:	e6c68693          	addi	a3,a3,-404 # 80000000 <_entry>
    8000019c:	e314                	sd	a3,0(a4)
  sys_info_ptr->bl_end = (uint64)end;
    8000019e:	639c                	ld	a5,0(a5)
    800001a0:	00011717          	auipc	a4,0x11
    800001a4:	9c073703          	ld	a4,-1600(a4) # 80010b60 <sys_info_ptr>
    800001a8:	e798                	sd	a4,8(a5)

  sys_info_ptr->dr_start = 0x80000000UL;
    800001aa:	4705                	li	a4,1
    800001ac:	077e                	slli	a4,a4,0x1f
    800001ae:	eb98                	sd	a4,16(a5)
  sys_info_ptr->dr_end = 0x0000000088000000;
    800001b0:	4745                	li	a4,17
    800001b2:	076e                	slli	a4,a4,0x1b
    800001b4:	ef98                	sd	a4,24(a5)
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800001b6:	67c1                	lui	a5,0x10
    800001b8:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800001ba:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800001be:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800001c2:	104027f3          	csrr	a5,sie
  //memmove(sys_info_ptr->observed_kernel_measurement, measured_hash, 32);

  // delegate all interrupts and exceptions to supervisor mode.
  w_medeleg(0xffff);
  w_mideleg(0xffff);
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800001c6:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800001ca:	10479073          	csrw	sie,a5

  // switch to supervisor mode and jump to main().
  asm volatile("mret");
    800001ce:	30200073          	mret
    800001d2:	47813083          	ld	ra,1144(sp)
    800001d6:	47013403          	ld	s0,1136(sp)
    800001da:	46813483          	ld	s1,1128(sp)
    800001de:	46013903          	ld	s2,1120(sp)
    800001e2:	45813983          	ld	s3,1112(sp)
    800001e6:	45013a03          	ld	s4,1104(sp)
    800001ea:	44813a83          	ld	s5,1096(sp)
    800001ee:	44013b03          	ld	s6,1088(sp)
    800001f2:	43813b83          	ld	s7,1080(sp)
    800001f6:	48010113          	addi	sp,sp,1152
    800001fa:	8082                	ret

00000000800001fc <kernel_copy>:
#include "layout.h"
#include "buf.h"

/* In-built function to load NORMAL/RECOVERY kernels */
void kernel_copy(enum kernel ktype, struct buf *b)
{
    800001fc:	1101                	addi	sp,sp,-32
    800001fe:	ec06                	sd	ra,24(sp)
    80000200:	e822                	sd	s0,16(sp)
    80000202:	e426                	sd	s1,8(sp)
    80000204:	1000                	addi	s0,sp,32
    80000206:	84ae                	mv	s1,a1
  /*if(b->blockno >= FSSIZE)
    panic("ramdiskrw: blockno too big");*/

  uint64 diskaddr = b->blockno * BSIZE;
    80000208:	699c                	ld	a5,16(a1)
    8000020a:	07aa                	slli	a5,a5,0xa
  char* addr = 0x0; 
  
  if (ktype == NORMAL)
    8000020c:	e505                	bnez	a0,80000234 <kernel_copy+0x38>
    addr = (char *)RAMDISK + diskaddr;
    8000020e:	02100593          	li	a1,33
    80000212:	05ea                	slli	a1,a1,0x1a
    80000214:	95be                	add	a1,a1,a5
  else if (ktype == RECOVERY)
    addr = (char *)RECOVERYDISK + diskaddr;

  memmove(b->data, addr, BSIZE);
    80000216:	40000613          	li	a2,1024
    8000021a:	03048513          	addi	a0,s1,48
    8000021e:	00000097          	auipc	ra,0x0
    80000222:	088080e7          	jalr	136(ra) # 800002a6 <memmove>
  b->valid = 1;
    80000226:	4785                	li	a5,1
    80000228:	c09c                	sw	a5,0(s1)
}
    8000022a:	60e2                	ld	ra,24(sp)
    8000022c:	6442                	ld	s0,16(sp)
    8000022e:	64a2                	ld	s1,8(sp)
    80000230:	6105                	addi	sp,sp,32
    80000232:	8082                	ret
  else if (ktype == RECOVERY)
    80000234:	4705                	li	a4,1
  char* addr = 0x0; 
    80000236:	4581                	li	a1,0
  else if (ktype == RECOVERY)
    80000238:	fce51fe3          	bne	a0,a4,80000216 <kernel_copy+0x1a>
    addr = (char *)RECOVERYDISK + diskaddr;
    8000023c:	008455b7          	lui	a1,0x845
    80000240:	05a2                	slli	a1,a1,0x8
    80000242:	95be                	add	a1,a1,a5
    80000244:	bfc9                	j	80000216 <kernel_copy+0x1a>

0000000080000246 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000246:	1141                	addi	sp,sp,-16
    80000248:	e406                	sd	ra,8(sp)
    8000024a:	e022                	sd	s0,0(sp)
    8000024c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    8000024e:	ca19                	beqz	a2,80000264 <memset+0x1e>
    80000250:	87aa                	mv	a5,a0
    80000252:	1602                	slli	a2,a2,0x20
    80000254:	9201                	srli	a2,a2,0x20
    80000256:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    8000025a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    8000025e:	0785                	addi	a5,a5,1
    80000260:	fee79de3          	bne	a5,a4,8000025a <memset+0x14>
  }
  return dst;
}
    80000264:	60a2                	ld	ra,8(sp)
    80000266:	6402                	ld	s0,0(sp)
    80000268:	0141                	addi	sp,sp,16
    8000026a:	8082                	ret

000000008000026c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    8000026c:	1141                	addi	sp,sp,-16
    8000026e:	e406                	sd	ra,8(sp)
    80000270:	e022                	sd	s0,0(sp)
    80000272:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000274:	c61d                	beqz	a2,800002a2 <memcmp+0x36>
    80000276:	1602                	slli	a2,a2,0x20
    80000278:	9201                	srli	a2,a2,0x20
    8000027a:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    8000027e:	00054783          	lbu	a5,0(a0) # 1000 <_entry-0x7ffff000>
    80000282:	0005c703          	lbu	a4,0(a1) # 845000 <_entry-0x7f7bb000>
    80000286:	00e79863          	bne	a5,a4,80000296 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    8000028a:	0505                	addi	a0,a0,1
    8000028c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    8000028e:	fed518e3          	bne	a0,a3,8000027e <memcmp+0x12>
  }

  return 0;
    80000292:	4501                	li	a0,0
    80000294:	a019                	j	8000029a <memcmp+0x2e>
      return *s1 - *s2;
    80000296:	40e7853b          	subw	a0,a5,a4
}
    8000029a:	60a2                	ld	ra,8(sp)
    8000029c:	6402                	ld	s0,0(sp)
    8000029e:	0141                	addi	sp,sp,16
    800002a0:	8082                	ret
  return 0;
    800002a2:	4501                	li	a0,0
    800002a4:	bfdd                	j	8000029a <memcmp+0x2e>

00000000800002a6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800002a6:	1141                	addi	sp,sp,-16
    800002a8:	e406                	sd	ra,8(sp)
    800002aa:	e022                	sd	s0,0(sp)
    800002ac:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800002ae:	c205                	beqz	a2,800002ce <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    800002b0:	02a5e363          	bltu	a1,a0,800002d6 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800002b4:	1602                	slli	a2,a2,0x20
    800002b6:	9201                	srli	a2,a2,0x20
    800002b8:	00c587b3          	add	a5,a1,a2
{
    800002bc:	872a                	mv	a4,a0
      *d++ = *s++;
    800002be:	0585                	addi	a1,a1,1
    800002c0:	0705                	addi	a4,a4,1
    800002c2:	fff5c683          	lbu	a3,-1(a1)
    800002c6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800002ca:	feb79ae3          	bne	a5,a1,800002be <memmove+0x18>

  return dst;
}
    800002ce:	60a2                	ld	ra,8(sp)
    800002d0:	6402                	ld	s0,0(sp)
    800002d2:	0141                	addi	sp,sp,16
    800002d4:	8082                	ret
  if(s < d && s + n > d){
    800002d6:	02061693          	slli	a3,a2,0x20
    800002da:	9281                	srli	a3,a3,0x20
    800002dc:	00d58733          	add	a4,a1,a3
    800002e0:	fce57ae3          	bgeu	a0,a4,800002b4 <memmove+0xe>
    d += n;
    800002e4:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    800002e6:	fff6079b          	addiw	a5,a2,-1
    800002ea:	1782                	slli	a5,a5,0x20
    800002ec:	9381                	srli	a5,a5,0x20
    800002ee:	fff7c793          	not	a5,a5
    800002f2:	97ba                	add	a5,a5,a4
      *--d = *--s;
    800002f4:	177d                	addi	a4,a4,-1
    800002f6:	16fd                	addi	a3,a3,-1
    800002f8:	00074603          	lbu	a2,0(a4)
    800002fc:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000300:	fee79ae3          	bne	a5,a4,800002f4 <memmove+0x4e>
    80000304:	b7e9                	j	800002ce <memmove+0x28>

0000000080000306 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000306:	1141                	addi	sp,sp,-16
    80000308:	e406                	sd	ra,8(sp)
    8000030a:	e022                	sd	s0,0(sp)
    8000030c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    8000030e:	00000097          	auipc	ra,0x0
    80000312:	f98080e7          	jalr	-104(ra) # 800002a6 <memmove>
}
    80000316:	60a2                	ld	ra,8(sp)
    80000318:	6402                	ld	s0,0(sp)
    8000031a:	0141                	addi	sp,sp,16
    8000031c:	8082                	ret

000000008000031e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000031e:	1141                	addi	sp,sp,-16
    80000320:	e406                	sd	ra,8(sp)
    80000322:	e022                	sd	s0,0(sp)
    80000324:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000326:	ce11                	beqz	a2,80000342 <strncmp+0x24>
    80000328:	00054783          	lbu	a5,0(a0)
    8000032c:	cf89                	beqz	a5,80000346 <strncmp+0x28>
    8000032e:	0005c703          	lbu	a4,0(a1)
    80000332:	00f71a63          	bne	a4,a5,80000346 <strncmp+0x28>
    n--, p++, q++;
    80000336:	367d                	addiw	a2,a2,-1
    80000338:	0505                	addi	a0,a0,1
    8000033a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000033c:	f675                	bnez	a2,80000328 <strncmp+0xa>
  if(n == 0)
    return 0;
    8000033e:	4501                	li	a0,0
    80000340:	a801                	j	80000350 <strncmp+0x32>
    80000342:	4501                	li	a0,0
    80000344:	a031                	j	80000350 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000346:	00054503          	lbu	a0,0(a0)
    8000034a:	0005c783          	lbu	a5,0(a1)
    8000034e:	9d1d                	subw	a0,a0,a5
}
    80000350:	60a2                	ld	ra,8(sp)
    80000352:	6402                	ld	s0,0(sp)
    80000354:	0141                	addi	sp,sp,16
    80000356:	8082                	ret

0000000080000358 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000358:	1141                	addi	sp,sp,-16
    8000035a:	e406                	sd	ra,8(sp)
    8000035c:	e022                	sd	s0,0(sp)
    8000035e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000360:	87aa                	mv	a5,a0
    80000362:	a011                	j	80000366 <strncpy+0xe>
    80000364:	8636                	mv	a2,a3
    80000366:	02c05863          	blez	a2,80000396 <strncpy+0x3e>
    8000036a:	fff6069b          	addiw	a3,a2,-1
    8000036e:	8836                	mv	a6,a3
    80000370:	0785                	addi	a5,a5,1
    80000372:	0005c703          	lbu	a4,0(a1)
    80000376:	fee78fa3          	sb	a4,-1(a5)
    8000037a:	0585                	addi	a1,a1,1
    8000037c:	f765                	bnez	a4,80000364 <strncpy+0xc>
    ;
  while(n-- > 0)
    8000037e:	873e                	mv	a4,a5
    80000380:	01005b63          	blez	a6,80000396 <strncpy+0x3e>
    80000384:	9fb1                	addw	a5,a5,a2
    80000386:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000388:	0705                	addi	a4,a4,1
    8000038a:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    8000038e:	40e786bb          	subw	a3,a5,a4
    80000392:	fed04be3          	bgtz	a3,80000388 <strncpy+0x30>
  return os;
}
    80000396:	60a2                	ld	ra,8(sp)
    80000398:	6402                	ld	s0,0(sp)
    8000039a:	0141                	addi	sp,sp,16
    8000039c:	8082                	ret

000000008000039e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    8000039e:	1141                	addi	sp,sp,-16
    800003a0:	e406                	sd	ra,8(sp)
    800003a2:	e022                	sd	s0,0(sp)
    800003a4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800003a6:	02c05363          	blez	a2,800003cc <safestrcpy+0x2e>
    800003aa:	fff6069b          	addiw	a3,a2,-1
    800003ae:	1682                	slli	a3,a3,0x20
    800003b0:	9281                	srli	a3,a3,0x20
    800003b2:	96ae                	add	a3,a3,a1
    800003b4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800003b6:	00d58963          	beq	a1,a3,800003c8 <safestrcpy+0x2a>
    800003ba:	0585                	addi	a1,a1,1
    800003bc:	0785                	addi	a5,a5,1
    800003be:	fff5c703          	lbu	a4,-1(a1)
    800003c2:	fee78fa3          	sb	a4,-1(a5)
    800003c6:	fb65                	bnez	a4,800003b6 <safestrcpy+0x18>
    ;
  *s = 0;
    800003c8:	00078023          	sb	zero,0(a5)
  return os;
}
    800003cc:	60a2                	ld	ra,8(sp)
    800003ce:	6402                	ld	s0,0(sp)
    800003d0:	0141                	addi	sp,sp,16
    800003d2:	8082                	ret

00000000800003d4 <strlen>:

int
strlen(const char *s)
{
    800003d4:	1141                	addi	sp,sp,-16
    800003d6:	e406                	sd	ra,8(sp)
    800003d8:	e022                	sd	s0,0(sp)
    800003da:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800003dc:	00054783          	lbu	a5,0(a0)
    800003e0:	cf91                	beqz	a5,800003fc <strlen+0x28>
    800003e2:	00150793          	addi	a5,a0,1
    800003e6:	86be                	mv	a3,a5
    800003e8:	0785                	addi	a5,a5,1
    800003ea:	fff7c703          	lbu	a4,-1(a5)
    800003ee:	ff65                	bnez	a4,800003e6 <strlen+0x12>
    800003f0:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    800003f4:	60a2                	ld	ra,8(sp)
    800003f6:	6402                	ld	s0,0(sp)
    800003f8:	0141                	addi	sp,sp,16
    800003fa:	8082                	ret
  for(n = 0; s[n]; n++)
    800003fc:	4501                	li	a0,0
    800003fe:	bfdd                	j	800003f4 <strlen+0x20>

0000000080000400 <is_elf>:
#include <stdint.h>

struct elfhdr* kernel_elfhdr;
struct proghdr* kernel_phdr;

bool is_elf(uint64 address){
    80000400:	1141                	addi	sp,sp,-16
    80000402:	e406                	sd	ra,8(sp)
    80000404:	e022                	sd	s0,0(sp)
    80000406:	0800                	addi	s0,sp,16
        struct elfhdr* elook = (struct elfhdr*) address;
        return elook->magic == ELF_MAGIC;
    80000408:	4108                	lw	a0,0(a0)
    8000040a:	464c47b7          	lui	a5,0x464c4
    8000040e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80000412:	8d1d                	sub	a0,a0,a5
}
    80000414:	00153513          	seqz	a0,a0
    80000418:	60a2                	ld	ra,8(sp)
    8000041a:	6402                	ld	s0,0(sp)
    8000041c:	0141                	addi	sp,sp,16
    8000041e:	8082                	ret

0000000080000420 <find_exec_segment>:

void find_exec_segment(uint64 start){
    80000420:	1141                	addi	sp,sp,-16
    80000422:	e406                	sd	ra,8(sp)
    80000424:	e022                	sd	s0,0(sp)
    80000426:	0800                	addi	s0,sp,16
    for(uint64 i = 0; i< kernel_elfhdr->phnum; i++){
    80000428:	00010797          	auipc	a5,0x10
    8000042c:	7487b783          	ld	a5,1864(a5) # 80010b70 <kernel_elfhdr>
    80000430:	0387d683          	lhu	a3,56(a5)
    80000434:	c29d                	beqz	a3,8000045a <find_exec_segment+0x3a>
        kernel_phdr = (struct proghdr*) (start + kernel_elfhdr->phoff + kernel_elfhdr->phentsize*i);
    80000436:	7398                	ld	a4,32(a5)
    80000438:	953a                	add	a0,a0,a4
    8000043a:	0367d803          	lhu	a6,54(a5)
    for(uint64 i = 0; i< kernel_elfhdr->phnum; i++){
    8000043e:	4781                	li	a5,0
        kernel_phdr = (struct proghdr*) (start + kernel_elfhdr->phoff + kernel_elfhdr->phentsize*i);
    80000440:	00010597          	auipc	a1,0x10
    80000444:	72858593          	addi	a1,a1,1832 # 80010b68 <kernel_phdr>
        if(kernel_phdr->type ==1)
    80000448:	4605                	li	a2,1
        kernel_phdr = (struct proghdr*) (start + kernel_elfhdr->phoff + kernel_elfhdr->phentsize*i);
    8000044a:	e188                	sd	a0,0(a1)
        if(kernel_phdr->type ==1)
    8000044c:	4118                	lw	a4,0(a0)
    8000044e:	00c70663          	beq	a4,a2,8000045a <find_exec_segment+0x3a>
    for(uint64 i = 0; i< kernel_elfhdr->phnum; i++){
    80000452:	0785                	addi	a5,a5,1
    80000454:	9542                	add	a0,a0,a6
    80000456:	fed79ae3          	bne	a5,a3,8000044a <find_exec_segment+0x2a>
            break;
    }
}
    8000045a:	60a2                	ld	ra,8(sp)
    8000045c:	6402                	ld	s0,0(sp)
    8000045e:	0141                	addi	sp,sp,16
    80000460:	8082                	ret

0000000080000462 <find_kernel_read_addr>:

uint64 find_kernel_read_addr(enum kernel ktype){
    80000462:	1101                	addi	sp,sp,-32
    80000464:	ec06                	sd	ra,24(sp)
    80000466:	e822                	sd	s0,16(sp)
    80000468:	e426                	sd	s1,8(sp)
    8000046a:	1000                	addi	s0,sp,32
    uint64 check2 = 0xA0000000;
    uint64 check1 = RAMDISK;
    uint64 addr_offset = 0;
    if(ktype == RECOVERY)
    8000046c:	4785                	li	a5,1
        addr_offset=RECOVERYDISK - RAMDISK;
    8000046e:	00500737          	lui	a4,0x500
    if(ktype == RECOVERY)
    80000472:	00f50363          	beq	a0,a5,80000478 <find_kernel_read_addr+0x16>
    uint64 addr_offset = 0;
    80000476:	4701                	li	a4,0
    uint64 start = check1 + addr_offset;
    80000478:	02100493          	li	s1,33
    8000047c:	04ea                	slli	s1,s1,0x1a
    8000047e:	94ba                	add	s1,s1,a4
    if(is_elf(start)){
    80000480:	4094                	lw	a3,0(s1)
    80000482:	464c47b7          	lui	a5,0x464c4
    80000486:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000048a:	02f68463          	beq	a3,a5,800004b2 <find_kernel_read_addr+0x50>
        kernel_elfhdr = (struct elfhdr*) (check1 + addr_offset);
        find_exec_segment(check1 + addr_offset);
        return check1 + addr_offset;
    }
    kernel_elfhdr = (struct elfhdr*) (check2 + addr_offset);
    8000048e:	4495                	li	s1,5
    80000490:	04f6                	slli	s1,s1,0x1d
    80000492:	94ba                	add	s1,s1,a4
    80000494:	00010797          	auipc	a5,0x10
    80000498:	6c97be23          	sd	s1,1756(a5) # 80010b70 <kernel_elfhdr>
    find_exec_segment(check2 + addr_offset);
    8000049c:	8526                	mv	a0,s1
    8000049e:	00000097          	auipc	ra,0x0
    800004a2:	f82080e7          	jalr	-126(ra) # 80000420 <find_exec_segment>
    return check2 + addr_offset;
}
    800004a6:	8526                	mv	a0,s1
    800004a8:	60e2                	ld	ra,24(sp)
    800004aa:	6442                	ld	s0,16(sp)
    800004ac:	64a2                	ld	s1,8(sp)
    800004ae:	6105                	addi	sp,sp,32
    800004b0:	8082                	ret
        kernel_elfhdr = (struct elfhdr*) (check1 + addr_offset);
    800004b2:	00010797          	auipc	a5,0x10
    800004b6:	6a97bf23          	sd	s1,1726(a5) # 80010b70 <kernel_elfhdr>
        find_exec_segment(check1 + addr_offset);
    800004ba:	8526                	mv	a0,s1
    800004bc:	00000097          	auipc	ra,0x0
    800004c0:	f64080e7          	jalr	-156(ra) # 80000420 <find_exec_segment>
        return check1 + addr_offset;
    800004c4:	b7cd                	j	800004a6 <find_kernel_read_addr+0x44>

00000000800004c6 <find_kernel_scopy_off>:
uint64 find_kernel_scopy_off(){
    800004c6:	1141                	addi	sp,sp,-16
    800004c8:	e406                	sd	ra,8(sp)
    800004ca:	e022                	sd	s0,0(sp)
    800004cc:	0800                	addi	s0,sp,16
    return kernel_phdr->off;
}
    800004ce:	00010797          	auipc	a5,0x10
    800004d2:	69a7b783          	ld	a5,1690(a5) # 80010b68 <kernel_phdr>
    800004d6:	6788                	ld	a0,8(a5)
    800004d8:	60a2                	ld	ra,8(sp)
    800004da:	6402                	ld	s0,0(sp)
    800004dc:	0141                	addi	sp,sp,16
    800004de:	8082                	ret

00000000800004e0 <find_kernel_load_addr>:
uint64 find_kernel_load_addr(enum kernel ktype) {
    800004e0:	1141                	addi	sp,sp,-16
    800004e2:	e406                	sd	ra,8(sp)
    800004e4:	e022                	sd	s0,0(sp)
    800004e6:	0800                	addi	s0,sp,16
    struct proghdr* sec_addr=kernel_phdr;
    return sec_addr->vaddr;
}
    800004e8:	00010797          	auipc	a5,0x10
    800004ec:	6807b783          	ld	a5,1664(a5) # 80010b68 <kernel_phdr>
    800004f0:	6b88                	ld	a0,16(a5)
    800004f2:	60a2                	ld	ra,8(sp)
    800004f4:	6402                	ld	s0,0(sp)
    800004f6:	0141                	addi	sp,sp,16
    800004f8:	8082                	ret

00000000800004fa <find_kernel_size>:


uint64 find_kernel_size(enum kernel ktype) {
    800004fa:	1141                	addi	sp,sp,-16
    800004fc:	e406                	sd	ra,8(sp)
    800004fe:	e022                	sd	s0,0(sp)
    80000500:	0800                	addi	s0,sp,16
    return kernel_elfhdr->shoff - kernel_phdr->off;
    80000502:	00010797          	auipc	a5,0x10
    80000506:	66e7b783          	ld	a5,1646(a5) # 80010b70 <kernel_elfhdr>
    8000050a:	7788                	ld	a0,40(a5)
    8000050c:	00010797          	auipc	a5,0x10
    80000510:	65c7b783          	ld	a5,1628(a5) # 80010b68 <kernel_phdr>
    80000514:	679c                	ld	a5,8(a5)
}
    80000516:	8d1d                	sub	a0,a0,a5
    80000518:	60a2                	ld	ra,8(sp)
    8000051a:	6402                	ld	s0,0(sp)
    8000051c:	0141                	addi	sp,sp,16
    8000051e:	8082                	ret

0000000080000520 <find_kernel_full_size>:
uint64 find_kernel_full_size(enum kernel ktype) {
    80000520:	1141                	addi	sp,sp,-16
    80000522:	e406                	sd	ra,8(sp)
    80000524:	e022                	sd	s0,0(sp)
    80000526:	0800                	addi	s0,sp,16
    return kernel_elfhdr->shoff + kernel_elfhdr->shnum*kernel_elfhdr->shentsize;
    80000528:	00010717          	auipc	a4,0x10
    8000052c:	64873703          	ld	a4,1608(a4) # 80010b70 <kernel_elfhdr>
    80000530:	03c75783          	lhu	a5,60(a4)
    80000534:	03a75683          	lhu	a3,58(a4)
    80000538:	02d787bb          	mulw	a5,a5,a3
    8000053c:	7708                	ld	a0,40(a4)
}
    8000053e:	953e                	add	a0,a0,a5
    80000540:	60a2                	ld	ra,8(sp)
    80000542:	6402                	ld	s0,0(sp)
    80000544:	0141                	addi	sp,sp,16
    80000546:	8082                	ret

0000000080000548 <find_kernel_entry_addr>:
uint64 find_kernel_entry_addr(enum kernel ktype) {
    80000548:	1141                	addi	sp,sp,-16
    8000054a:	e406                	sd	ra,8(sp)
    8000054c:	e022                	sd	s0,0(sp)
    8000054e:	0800                	addi	s0,sp,16
    /* CSE 536: Get kernel entry point from headers */
    struct elfhdr* rd=kernel_elfhdr;
    return rd->entry;
    80000550:	00010797          	auipc	a5,0x10
    80000554:	6207b783          	ld	a5,1568(a5) # 80010b70 <kernel_elfhdr>
    80000558:	6f88                	ld	a0,24(a5)
    8000055a:	60a2                	ld	ra,8(sp)
    8000055c:	6402                	ld	s0,0(sp)
    8000055e:	0141                	addi	sp,sp,16
    80000560:	8082                	ret

0000000080000562 <sha256_transform>:
	0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
};

/*********************** FUNCTION DEFINITIONS ***********************/
void sha256_transform(SHA256_CTX *ctx, const BYTE data[])
{
    80000562:	714d                	addi	sp,sp,-336
    80000564:	e686                	sd	ra,328(sp)
    80000566:	e2a2                	sd	s0,320(sp)
    80000568:	fe26                	sd	s1,312(sp)
    8000056a:	fa4a                	sd	s2,304(sp)
    8000056c:	f64e                	sd	s3,296(sp)
    8000056e:	f252                	sd	s4,288(sp)
    80000570:	ee56                	sd	s5,280(sp)
    80000572:	ea5a                	sd	s6,272(sp)
    80000574:	e65e                	sd	s7,264(sp)
    80000576:	e262                	sd	s8,256(sp)
    80000578:	0a80                	addi	s0,sp,336
	WORD a, b, c, d, e, f, g, h, i, j, t1, t2, m[64];

	for (i = 0, j = 0; i < 16; ++i, j += 4)
    8000057a:	eb040313          	addi	t1,s0,-336
    8000057e:	ef040613          	addi	a2,s0,-272
{
    80000582:	869a                	mv	a3,t1
		m[i] = (data[j] << 24) | (data[j + 1] << 16) | (data[j + 2] << 8) | (data[j + 3]);
    80000584:	0005c783          	lbu	a5,0(a1)
    80000588:	0187979b          	slliw	a5,a5,0x18
    8000058c:	0015c703          	lbu	a4,1(a1)
    80000590:	0107171b          	slliw	a4,a4,0x10
    80000594:	8fd9                	or	a5,a5,a4
    80000596:	0035c703          	lbu	a4,3(a1)
    8000059a:	8fd9                	or	a5,a5,a4
    8000059c:	0025c703          	lbu	a4,2(a1)
    800005a0:	0087171b          	slliw	a4,a4,0x8
    800005a4:	8fd9                	or	a5,a5,a4
    800005a6:	c29c                	sw	a5,0(a3)
	for (i = 0, j = 0; i < 16; ++i, j += 4)
    800005a8:	0591                	addi	a1,a1,4
    800005aa:	0691                	addi	a3,a3,4
    800005ac:	fcc69ce3          	bne	a3,a2,80000584 <sha256_transform+0x22>
	for ( ; i < 64; ++i)
    800005b0:	0c030893          	addi	a7,t1,192
	for (i = 0, j = 0; i < 16; ++i, j += 4)
    800005b4:	869a                	mv	a3,t1
		m[i] = SIG1(m[i - 2]) + m[i - 7] + SIG0(m[i - 15]) + m[i - 16];
    800005b6:	5e98                	lw	a4,56(a3)
    800005b8:	42dc                	lw	a5,4(a3)
    800005ba:	0117559b          	srliw	a1,a4,0x11
    800005be:	00f7161b          	slliw	a2,a4,0xf
    800005c2:	9e2d                	addw	a2,a2,a1
    800005c4:	0137581b          	srliw	a6,a4,0x13
    800005c8:	00d7159b          	slliw	a1,a4,0xd
    800005cc:	010585bb          	addw	a1,a1,a6
    800005d0:	8e2d                	xor	a2,a2,a1
    800005d2:	00a7571b          	srliw	a4,a4,0xa
    800005d6:	8f31                	xor	a4,a4,a2
    800005d8:	52cc                	lw	a1,36(a3)
    800005da:	4290                	lw	a2,0(a3)
    800005dc:	9e2d                	addw	a2,a2,a1
    800005de:	9f31                	addw	a4,a4,a2
    800005e0:	0077d59b          	srliw	a1,a5,0x7
    800005e4:	0197961b          	slliw	a2,a5,0x19
    800005e8:	9e2d                	addw	a2,a2,a1
    800005ea:	0127d81b          	srliw	a6,a5,0x12
    800005ee:	00e7959b          	slliw	a1,a5,0xe
    800005f2:	010585bb          	addw	a1,a1,a6
    800005f6:	8e2d                	xor	a2,a2,a1
    800005f8:	0037d79b          	srliw	a5,a5,0x3
    800005fc:	8fb1                	xor	a5,a5,a2
    800005fe:	9fb9                	addw	a5,a5,a4
    80000600:	c2bc                	sw	a5,64(a3)
	for ( ; i < 64; ++i)
    80000602:	0691                	addi	a3,a3,4
    80000604:	fad899e3          	bne	a7,a3,800005b6 <sha256_transform+0x54>

	a = ctx->state[0];
    80000608:	05052b03          	lw	s6,80(a0)
	b = ctx->state[1];
    8000060c:	05452a83          	lw	s5,84(a0)
	c = ctx->state[2];
    80000610:	05852a03          	lw	s4,88(a0)
	d = ctx->state[3];
    80000614:	05c52983          	lw	s3,92(a0)
	e = ctx->state[4];
    80000618:	06052903          	lw	s2,96(a0)
	f = ctx->state[5];
    8000061c:	5164                	lw	s1,100(a0)
	g = ctx->state[6];
    8000061e:	06852383          	lw	t2,104(a0)
	h = ctx->state[7];
    80000622:	06c52283          	lw	t0,108(a0)

	for (i = 0; i < 64; ++i) {
    80000626:	00000817          	auipc	a6,0x0
    8000062a:	38a80813          	addi	a6,a6,906 # 800009b0 <k>
    8000062e:	00000f97          	auipc	t6,0x0
    80000632:	482f8f93          	addi	t6,t6,1154 # 80000ab0 <trusted_kernel_hash>
	h = ctx->state[7];
    80000636:	8b96                	mv	s7,t0
	g = ctx->state[6];
    80000638:	8e1e                	mv	t3,t2
	f = ctx->state[5];
    8000063a:	8ea6                	mv	t4,s1
	e = ctx->state[4];
    8000063c:	86ca                	mv	a3,s2
	d = ctx->state[3];
    8000063e:	8f4e                	mv	t5,s3
	c = ctx->state[2];
    80000640:	85d2                	mv	a1,s4
	b = ctx->state[1];
    80000642:	88d6                	mv	a7,s5
	a = ctx->state[0];
    80000644:	865a                	mv	a2,s6
    80000646:	a039                	j	80000654 <sha256_transform+0xf2>
    80000648:	8e76                	mv	t3,t4
    8000064a:	8eb6                	mv	t4,a3
    8000064c:	86e2                	mv	a3,s8
    8000064e:	85c6                	mv	a1,a7
    80000650:	88b2                	mv	a7,a2
    80000652:	863e                	mv	a2,a5
		t1 = h + EP1(e) + CH(e,f,g) + k[i] + m[i];
    80000654:	0066d71b          	srliw	a4,a3,0x6
    80000658:	01a6979b          	slliw	a5,a3,0x1a
    8000065c:	9fb9                	addw	a5,a5,a4
    8000065e:	00b6dc1b          	srliw	s8,a3,0xb
    80000662:	0156971b          	slliw	a4,a3,0x15
    80000666:	0187073b          	addw	a4,a4,s8
    8000066a:	8fb9                	xor	a5,a5,a4
    8000066c:	0196dc1b          	srliw	s8,a3,0x19
    80000670:	0076971b          	slliw	a4,a3,0x7
    80000674:	0187073b          	addw	a4,a4,s8
    80000678:	8f3d                	xor	a4,a4,a5
    8000067a:	00082c03          	lw	s8,0(a6)
    8000067e:	00032783          	lw	a5,0(t1)
    80000682:	018787bb          	addw	a5,a5,s8
    80000686:	9fb9                	addw	a5,a5,a4
    80000688:	fff6c713          	not	a4,a3
    8000068c:	01c77733          	and	a4,a4,t3
    80000690:	01d6fc33          	and	s8,a3,t4
    80000694:	01874733          	xor	a4,a4,s8
    80000698:	9fb9                	addw	a5,a5,a4
    8000069a:	017787bb          	addw	a5,a5,s7
		t2 = EP0(a) + MAJ(a,b,c);
    8000069e:	0026571b          	srliw	a4,a2,0x2
    800006a2:	01e61b9b          	slliw	s7,a2,0x1e
    800006a6:	00eb8bbb          	addw	s7,s7,a4
    800006aa:	00d65c1b          	srliw	s8,a2,0xd
    800006ae:	0136171b          	slliw	a4,a2,0x13
    800006b2:	0187073b          	addw	a4,a4,s8
    800006b6:	00ebcbb3          	xor	s7,s7,a4
    800006ba:	01665c1b          	srliw	s8,a2,0x16
    800006be:	00a6171b          	slliw	a4,a2,0xa
    800006c2:	0187073b          	addw	a4,a4,s8
    800006c6:	01774733          	xor	a4,a4,s7
    800006ca:	00b8cbb3          	xor	s7,a7,a1
    800006ce:	01767bb3          	and	s7,a2,s7
    800006d2:	00b8fc33          	and	s8,a7,a1
    800006d6:	018bcbb3          	xor	s7,s7,s8
    800006da:	0177073b          	addw	a4,a4,s7
		h = g;
		g = f;
		f = e;
		e = d + t1;
    800006de:	01e78c3b          	addw	s8,a5,t5
		d = c;
		c = b;
		b = a;
		a = t1 + t2;
    800006e2:	9fb9                	addw	a5,a5,a4
	for (i = 0; i < 64; ++i) {
    800006e4:	0811                	addi	a6,a6,4
    800006e6:	0311                	addi	t1,t1,4
    800006e8:	8f2e                	mv	t5,a1
    800006ea:	8bf2                	mv	s7,t3
    800006ec:	f5f81ee3          	bne	a6,t6,80000648 <sha256_transform+0xe6>
	}

	ctx->state[0] += a;
    800006f0:	00fb0b3b          	addw	s6,s6,a5
    800006f4:	05652823          	sw	s6,80(a0)
	ctx->state[1] += b;
    800006f8:	00ca8abb          	addw	s5,s5,a2
    800006fc:	05552a23          	sw	s5,84(a0)
	ctx->state[2] += c;
    80000700:	011a0a3b          	addw	s4,s4,a7
    80000704:	05452c23          	sw	s4,88(a0)
	ctx->state[3] += d;
    80000708:	00b989bb          	addw	s3,s3,a1
    8000070c:	05352e23          	sw	s3,92(a0)
	ctx->state[4] += e;
    80000710:	0189093b          	addw	s2,s2,s8
    80000714:	07252023          	sw	s2,96(a0)
	ctx->state[5] += f;
    80000718:	9cb5                	addw	s1,s1,a3
    8000071a:	d164                	sw	s1,100(a0)
	ctx->state[6] += g;
    8000071c:	01d383bb          	addw	t2,t2,t4
    80000720:	06752423          	sw	t2,104(a0)
	ctx->state[7] += h;
    80000724:	01c282bb          	addw	t0,t0,t3
    80000728:	06552623          	sw	t0,108(a0)
}
    8000072c:	60b6                	ld	ra,328(sp)
    8000072e:	6416                	ld	s0,320(sp)
    80000730:	74f2                	ld	s1,312(sp)
    80000732:	7952                	ld	s2,304(sp)
    80000734:	79b2                	ld	s3,296(sp)
    80000736:	7a12                	ld	s4,288(sp)
    80000738:	6af2                	ld	s5,280(sp)
    8000073a:	6b52                	ld	s6,272(sp)
    8000073c:	6bb2                	ld	s7,264(sp)
    8000073e:	6c12                	ld	s8,256(sp)
    80000740:	6171                	addi	sp,sp,336
    80000742:	8082                	ret

0000000080000744 <sha256_init>:

void sha256_init(SHA256_CTX *ctx)
{
    80000744:	1141                	addi	sp,sp,-16
    80000746:	e406                	sd	ra,8(sp)
    80000748:	e022                	sd	s0,0(sp)
    8000074a:	0800                	addi	s0,sp,16
	ctx->datalen = 0;
    8000074c:	04052023          	sw	zero,64(a0)
	ctx->bitlen = 0;
    80000750:	04053423          	sd	zero,72(a0)
	ctx->state[0] = 0x6a09e667;
    80000754:	6a09e7b7          	lui	a5,0x6a09e
    80000758:	66778793          	addi	a5,a5,1639 # 6a09e667 <_entry-0x15f61999>
    8000075c:	c93c                	sw	a5,80(a0)
	ctx->state[1] = 0xbb67ae85;
    8000075e:	bb67b7b7          	lui	a5,0xbb67b
    80000762:	e8578793          	addi	a5,a5,-379 # ffffffffbb67ae85 <kernel_elfhdr+0xffffffff3b66a315>
    80000766:	c97c                	sw	a5,84(a0)
	ctx->state[2] = 0x3c6ef372;
    80000768:	3c6ef7b7          	lui	a5,0x3c6ef
    8000076c:	37278793          	addi	a5,a5,882 # 3c6ef372 <_entry-0x43910c8e>
    80000770:	cd3c                	sw	a5,88(a0)
	ctx->state[3] = 0xa54ff53a;
    80000772:	a54ff7b7          	lui	a5,0xa54ff
    80000776:	53a78793          	addi	a5,a5,1338 # ffffffffa54ff53a <kernel_elfhdr+0xffffffff254ee9ca>
    8000077a:	cd7c                	sw	a5,92(a0)
	ctx->state[4] = 0x510e527f;
    8000077c:	510e57b7          	lui	a5,0x510e5
    80000780:	27f78793          	addi	a5,a5,639 # 510e527f <_entry-0x2ef1ad81>
    80000784:	d13c                	sw	a5,96(a0)
	ctx->state[5] = 0x9b05688c;
    80000786:	9b0577b7          	lui	a5,0x9b057
    8000078a:	88c78793          	addi	a5,a5,-1908 # ffffffff9b05688c <kernel_elfhdr+0xffffffff1b045d1c>
    8000078e:	d17c                	sw	a5,100(a0)
	ctx->state[6] = 0x1f83d9ab;
    80000790:	1f83e7b7          	lui	a5,0x1f83e
    80000794:	9ab78793          	addi	a5,a5,-1621 # 1f83d9ab <_entry-0x607c2655>
    80000798:	d53c                	sw	a5,104(a0)
	ctx->state[7] = 0x5be0cd19;
    8000079a:	5be0d7b7          	lui	a5,0x5be0d
    8000079e:	d1978793          	addi	a5,a5,-743 # 5be0cd19 <_entry-0x241f32e7>
    800007a2:	d57c                	sw	a5,108(a0)
}
    800007a4:	60a2                	ld	ra,8(sp)
    800007a6:	6402                	ld	s0,0(sp)
    800007a8:	0141                	addi	sp,sp,16
    800007aa:	8082                	ret

00000000800007ac <sha256_update>:

void sha256_update(SHA256_CTX *ctx, const BYTE data[], size_t len)
{
	WORD i;

	for (i = 0; i < len; ++i) {
    800007ac:	ce35                	beqz	a2,80000828 <sha256_update+0x7c>
{
    800007ae:	7139                	addi	sp,sp,-64
    800007b0:	fc06                	sd	ra,56(sp)
    800007b2:	f822                	sd	s0,48(sp)
    800007b4:	f426                	sd	s1,40(sp)
    800007b6:	f04a                	sd	s2,32(sp)
    800007b8:	ec4e                	sd	s3,24(sp)
    800007ba:	e852                	sd	s4,16(sp)
    800007bc:	e456                	sd	s5,8(sp)
    800007be:	0080                	addi	s0,sp,64
    800007c0:	84aa                	mv	s1,a0
    800007c2:	8a2e                	mv	s4,a1
    800007c4:	89b2                	mv	s3,a2
	for (i = 0; i < len; ++i) {
    800007c6:	4901                	li	s2,0
    800007c8:	4781                	li	a5,0
		ctx->data[ctx->datalen] = data[i];
		ctx->datalen++;
		if (ctx->datalen == 64) {
    800007ca:	04000a93          	li	s5,64
    800007ce:	a801                	j	800007de <sha256_update+0x32>
	for (i = 0; i < len; ++i) {
    800007d0:	0019079b          	addiw	a5,s2,1
    800007d4:	893e                	mv	s2,a5
    800007d6:	1782                	slli	a5,a5,0x20
    800007d8:	9381                	srli	a5,a5,0x20
    800007da:	0337fe63          	bgeu	a5,s3,80000816 <sha256_update+0x6a>
		ctx->data[ctx->datalen] = data[i];
    800007de:	40b8                	lw	a4,64(s1)
    800007e0:	97d2                	add	a5,a5,s4
    800007e2:	0007c683          	lbu	a3,0(a5)
    800007e6:	02071793          	slli	a5,a4,0x20
    800007ea:	9381                	srli	a5,a5,0x20
    800007ec:	97a6                	add	a5,a5,s1
    800007ee:	00d78023          	sb	a3,0(a5)
		ctx->datalen++;
    800007f2:	0017079b          	addiw	a5,a4,1
    800007f6:	c0bc                	sw	a5,64(s1)
		if (ctx->datalen == 64) {
    800007f8:	fd579ce3          	bne	a5,s5,800007d0 <sha256_update+0x24>
			sha256_transform(ctx, ctx->data);
    800007fc:	85a6                	mv	a1,s1
    800007fe:	8526                	mv	a0,s1
    80000800:	00000097          	auipc	ra,0x0
    80000804:	d62080e7          	jalr	-670(ra) # 80000562 <sha256_transform>
			ctx->bitlen += 512;
    80000808:	64bc                	ld	a5,72(s1)
    8000080a:	20078793          	addi	a5,a5,512
    8000080e:	e4bc                	sd	a5,72(s1)
			ctx->datalen = 0;
    80000810:	0404a023          	sw	zero,64(s1)
    80000814:	bf75                	j	800007d0 <sha256_update+0x24>
		}
	}
}
    80000816:	70e2                	ld	ra,56(sp)
    80000818:	7442                	ld	s0,48(sp)
    8000081a:	74a2                	ld	s1,40(sp)
    8000081c:	7902                	ld	s2,32(sp)
    8000081e:	69e2                	ld	s3,24(sp)
    80000820:	6a42                	ld	s4,16(sp)
    80000822:	6aa2                	ld	s5,8(sp)
    80000824:	6121                	addi	sp,sp,64
    80000826:	8082                	ret
    80000828:	8082                	ret

000000008000082a <sha256_final>:

void sha256_final(SHA256_CTX *ctx, BYTE hash[])
{
    8000082a:	1101                	addi	sp,sp,-32
    8000082c:	ec06                	sd	ra,24(sp)
    8000082e:	e822                	sd	s0,16(sp)
    80000830:	e426                	sd	s1,8(sp)
    80000832:	e04a                	sd	s2,0(sp)
    80000834:	1000                	addi	s0,sp,32
    80000836:	84aa                	mv	s1,a0
    80000838:	892e                	mv	s2,a1
	WORD i;

	i = ctx->datalen;
    8000083a:	4134                	lw	a3,64(a0)

	// Pad whatever data is left in the buffer.
	if (ctx->datalen < 56) {
    8000083c:	03700793          	li	a5,55
    80000840:	04d7e563          	bltu	a5,a3,8000088a <sha256_final+0x60>
		ctx->data[i++] = 0x80;
    80000844:	0016879b          	addiw	a5,a3,1
    80000848:	02069713          	slli	a4,a3,0x20
    8000084c:	9301                	srli	a4,a4,0x20
    8000084e:	972a                	add	a4,a4,a0
    80000850:	f8000613          	li	a2,-128
    80000854:	00c70023          	sb	a2,0(a4)
		while (i < 56)
    80000858:	03700713          	li	a4,55
    8000085c:	08f76763          	bltu	a4,a5,800008ea <sha256_final+0xc0>
    80000860:	02079613          	slli	a2,a5,0x20
    80000864:	9201                	srli	a2,a2,0x20
    80000866:	00a607b3          	add	a5,a2,a0
    8000086a:	00150713          	addi	a4,a0,1
    8000086e:	9732                	add	a4,a4,a2
    80000870:	03600613          	li	a2,54
    80000874:	40d606bb          	subw	a3,a2,a3
    80000878:	1682                	slli	a3,a3,0x20
    8000087a:	9281                	srli	a3,a3,0x20
    8000087c:	9736                	add	a4,a4,a3
			ctx->data[i++] = 0x00;
    8000087e:	00078023          	sb	zero,0(a5)
		while (i < 56)
    80000882:	0785                	addi	a5,a5,1
    80000884:	fee79de3          	bne	a5,a4,8000087e <sha256_final+0x54>
    80000888:	a08d                	j	800008ea <sha256_final+0xc0>
	}
	else {
		ctx->data[i++] = 0x80;
    8000088a:	0016879b          	addiw	a5,a3,1
    8000088e:	02069713          	slli	a4,a3,0x20
    80000892:	9301                	srli	a4,a4,0x20
    80000894:	972a                	add	a4,a4,a0
    80000896:	f8000613          	li	a2,-128
    8000089a:	00c70023          	sb	a2,0(a4)
		while (i < 64)
    8000089e:	03f00713          	li	a4,63
    800008a2:	02f76663          	bltu	a4,a5,800008ce <sha256_final+0xa4>
    800008a6:	02079613          	slli	a2,a5,0x20
    800008aa:	9201                	srli	a2,a2,0x20
    800008ac:	00a607b3          	add	a5,a2,a0
    800008b0:	00150713          	addi	a4,a0,1
    800008b4:	9732                	add	a4,a4,a2
    800008b6:	03e00613          	li	a2,62
    800008ba:	40d606bb          	subw	a3,a2,a3
    800008be:	1682                	slli	a3,a3,0x20
    800008c0:	9281                	srli	a3,a3,0x20
    800008c2:	9736                	add	a4,a4,a3
			ctx->data[i++] = 0x00;
    800008c4:	00078023          	sb	zero,0(a5)
		while (i < 64)
    800008c8:	0785                	addi	a5,a5,1
    800008ca:	fee79de3          	bne	a5,a4,800008c4 <sha256_final+0x9a>
		sha256_transform(ctx, ctx->data);
    800008ce:	85a6                	mv	a1,s1
    800008d0:	8526                	mv	a0,s1
    800008d2:	00000097          	auipc	ra,0x0
    800008d6:	c90080e7          	jalr	-880(ra) # 80000562 <sha256_transform>
		memset(ctx->data, 0, 56);
    800008da:	03800613          	li	a2,56
    800008de:	4581                	li	a1,0
    800008e0:	8526                	mv	a0,s1
    800008e2:	00000097          	auipc	ra,0x0
    800008e6:	964080e7          	jalr	-1692(ra) # 80000246 <memset>
	}

	// Append to the padding the total message's length in bits and transform.
	ctx->bitlen += ctx->datalen * 8;
    800008ea:	40bc                	lw	a5,64(s1)
    800008ec:	0037979b          	slliw	a5,a5,0x3
    800008f0:	1782                	slli	a5,a5,0x20
    800008f2:	9381                	srli	a5,a5,0x20
    800008f4:	64b8                	ld	a4,72(s1)
    800008f6:	97ba                	add	a5,a5,a4
    800008f8:	e4bc                	sd	a5,72(s1)
	ctx->data[63] = ctx->bitlen;
    800008fa:	02f48fa3          	sb	a5,63(s1)
	ctx->data[62] = ctx->bitlen >> 8;
    800008fe:	0087d713          	srli	a4,a5,0x8
    80000902:	02e48f23          	sb	a4,62(s1)
	ctx->data[61] = ctx->bitlen >> 16;
    80000906:	0107d713          	srli	a4,a5,0x10
    8000090a:	02e48ea3          	sb	a4,61(s1)
	ctx->data[60] = ctx->bitlen >> 24;
    8000090e:	0187d713          	srli	a4,a5,0x18
    80000912:	02e48e23          	sb	a4,60(s1)
	ctx->data[59] = ctx->bitlen >> 32;
    80000916:	0207d713          	srli	a4,a5,0x20
    8000091a:	02e48da3          	sb	a4,59(s1)
	ctx->data[58] = ctx->bitlen >> 40;
    8000091e:	0287d713          	srli	a4,a5,0x28
    80000922:	02e48d23          	sb	a4,58(s1)
	ctx->data[57] = ctx->bitlen >> 48;
    80000926:	0307d713          	srli	a4,a5,0x30
    8000092a:	02e48ca3          	sb	a4,57(s1)
	ctx->data[56] = ctx->bitlen >> 56;
    8000092e:	93e1                	srli	a5,a5,0x38
    80000930:	02f48c23          	sb	a5,56(s1)
	sha256_transform(ctx, ctx->data);
    80000934:	85a6                	mv	a1,s1
    80000936:	8526                	mv	a0,s1
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	c2a080e7          	jalr	-982(ra) # 80000562 <sha256_transform>

	// Since this implementation uses little endian byte ordering and SHA uses big endian,
	// reverse all the bytes when copying the final state to the output hash.
	for (i = 0; i < 4; ++i) {
    80000940:	85ca                	mv	a1,s2
	sha256_transform(ctx, ctx->data);
    80000942:	47e1                	li	a5,24
	for (i = 0; i < 4; ++i) {
    80000944:	56e1                	li	a3,-8
		hash[i]      = (ctx->state[0] >> (24 - i * 8)) & 0x000000ff;
    80000946:	48b8                	lw	a4,80(s1)
    80000948:	00f7573b          	srlw	a4,a4,a5
    8000094c:	00e58023          	sb	a4,0(a1)
		hash[i + 4]  = (ctx->state[1] >> (24 - i * 8)) & 0x000000ff;
    80000950:	48f8                	lw	a4,84(s1)
    80000952:	00f7573b          	srlw	a4,a4,a5
    80000956:	00e58223          	sb	a4,4(a1)
		hash[i + 8]  = (ctx->state[2] >> (24 - i * 8)) & 0x000000ff;
    8000095a:	4cb8                	lw	a4,88(s1)
    8000095c:	00f7573b          	srlw	a4,a4,a5
    80000960:	00e58423          	sb	a4,8(a1)
		hash[i + 12] = (ctx->state[3] >> (24 - i * 8)) & 0x000000ff;
    80000964:	4cf8                	lw	a4,92(s1)
    80000966:	00f7573b          	srlw	a4,a4,a5
    8000096a:	00e58623          	sb	a4,12(a1)
		hash[i + 16] = (ctx->state[4] >> (24 - i * 8)) & 0x000000ff;
    8000096e:	50b8                	lw	a4,96(s1)
    80000970:	00f7573b          	srlw	a4,a4,a5
    80000974:	00e58823          	sb	a4,16(a1)
		hash[i + 20] = (ctx->state[5] >> (24 - i * 8)) & 0x000000ff;
    80000978:	50f8                	lw	a4,100(s1)
    8000097a:	00f7573b          	srlw	a4,a4,a5
    8000097e:	00e58a23          	sb	a4,20(a1)
		hash[i + 24] = (ctx->state[6] >> (24 - i * 8)) & 0x000000ff;
    80000982:	54b8                	lw	a4,104(s1)
    80000984:	00f7573b          	srlw	a4,a4,a5
    80000988:	00e58c23          	sb	a4,24(a1)
		hash[i + 28] = (ctx->state[7] >> (24 - i * 8)) & 0x000000ff;
    8000098c:	54f8                	lw	a4,108(s1)
    8000098e:	00f7573b          	srlw	a4,a4,a5
    80000992:	00e58e23          	sb	a4,28(a1)
	for (i = 0; i < 4; ++i) {
    80000996:	37e1                	addiw	a5,a5,-8
    80000998:	0585                	addi	a1,a1,1
    8000099a:	fad796e3          	bne	a5,a3,80000946 <sha256_final+0x11c>
	}
    8000099e:	60e2                	ld	ra,24(sp)
    800009a0:	6442                	ld	s0,16(sp)
    800009a2:	64a2                	ld	s1,8(sp)
    800009a4:	6902                	ld	s2,0(sp)
    800009a6:	6105                	addi	sp,sp,32
    800009a8:	8082                	ret
