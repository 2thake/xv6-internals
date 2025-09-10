
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + (hartid * 4096)
        la sp, stack0
    80000000:	00009117          	auipc	sp,0x9
    80000004:	ab010113          	addi	sp,sp,-1360 # 80008ab0 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	078000ef          	jal	8000008e <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000024:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000028:	2781                	sext.w	a5,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037961b          	slliw	a2,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	963a                	add	a2,a2,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f46b7          	lui	a3,0xf4
    80000040:	24068693          	addi	a3,a3,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9736                	add	a4,a4,a3
    80000046:	e218                	sd	a4,0(a2)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00279713          	slli	a4,a5,0x2
    8000004c:	973e                	add	a4,a4,a5
    8000004e:	070e                	slli	a4,a4,0x3
    80000050:	00009797          	auipc	a5,0x9
    80000054:	92078793          	addi	a5,a5,-1760 # 80008970 <timer_scratch>
    80000058:	97ba                	add	a5,a5,a4
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef90                	sd	a2,24(a5)
  scratch[4] = interval;
    8000005c:	f394                	sd	a3,32(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	eae78793          	addi	a5,a5,-338 # 80005f10 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	60a2                	ld	ra,8(sp)
    80000088:	6402                	ld	s0,0(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca1f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	e6078793          	addi	a5,a5,-416 # 80000f0e <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	711d                	addi	sp,sp,-96
    80000104:	ec86                	sd	ra,88(sp)
    80000106:	e8a2                	sd	s0,80(sp)
    80000108:	e0ca                	sd	s2,64(sp)
    8000010a:	1080                	addi	s0,sp,96
  int i;

  for(i = 0; i < n; i++){
    8000010c:	04c05b63          	blez	a2,80000162 <consolewrite+0x60>
    80000110:	e4a6                	sd	s1,72(sp)
    80000112:	fc4e                	sd	s3,56(sp)
    80000114:	f852                	sd	s4,48(sp)
    80000116:	f456                	sd	s5,40(sp)
    80000118:	f05a                	sd	s6,32(sp)
    8000011a:	ec5e                	sd	s7,24(sp)
    8000011c:	8a2a                	mv	s4,a0
    8000011e:	84ae                	mv	s1,a1
    80000120:	89b2                	mv	s3,a2
    80000122:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000124:	faf40b93          	addi	s7,s0,-81
    80000128:	4b05                	li	s6,1
    8000012a:	5afd                	li	s5,-1
    8000012c:	86da                	mv	a3,s6
    8000012e:	8626                	mv	a2,s1
    80000130:	85d2                	mv	a1,s4
    80000132:	855e                	mv	a0,s7
    80000134:	00002097          	auipc	ra,0x2
    80000138:	58a080e7          	jalr	1418(ra) # 800026be <either_copyin>
    8000013c:	03550563          	beq	a0,s5,80000166 <consolewrite+0x64>
      break;
    uartputc(c);
    80000140:	faf44503          	lbu	a0,-81(s0)
    80000144:	00000097          	auipc	ra,0x0
    80000148:	7d8080e7          	jalr	2008(ra) # 8000091c <uartputc>
  for(i = 0; i < n; i++){
    8000014c:	2905                	addiw	s2,s2,1
    8000014e:	0485                	addi	s1,s1,1
    80000150:	fd299ee3          	bne	s3,s2,8000012c <consolewrite+0x2a>
    80000154:	64a6                	ld	s1,72(sp)
    80000156:	79e2                	ld	s3,56(sp)
    80000158:	7a42                	ld	s4,48(sp)
    8000015a:	7aa2                	ld	s5,40(sp)
    8000015c:	7b02                	ld	s6,32(sp)
    8000015e:	6be2                	ld	s7,24(sp)
    80000160:	a809                	j	80000172 <consolewrite+0x70>
    80000162:	4901                	li	s2,0
    80000164:	a039                	j	80000172 <consolewrite+0x70>
    80000166:	64a6                	ld	s1,72(sp)
    80000168:	79e2                	ld	s3,56(sp)
    8000016a:	7a42                	ld	s4,48(sp)
    8000016c:	7aa2                	ld	s5,40(sp)
    8000016e:	7b02                	ld	s6,32(sp)
    80000170:	6be2                	ld	s7,24(sp)
  }

  return i;
}
    80000172:	854a                	mv	a0,s2
    80000174:	60e6                	ld	ra,88(sp)
    80000176:	6446                	ld	s0,80(sp)
    80000178:	6906                	ld	s2,64(sp)
    8000017a:	6125                	addi	sp,sp,96
    8000017c:	8082                	ret

000000008000017e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000017e:	711d                	addi	sp,sp,-96
    80000180:	ec86                	sd	ra,88(sp)
    80000182:	e8a2                	sd	s0,80(sp)
    80000184:	e4a6                	sd	s1,72(sp)
    80000186:	e0ca                	sd	s2,64(sp)
    80000188:	fc4e                	sd	s3,56(sp)
    8000018a:	f852                	sd	s4,48(sp)
    8000018c:	f05a                	sd	s6,32(sp)
    8000018e:	ec5e                	sd	s7,24(sp)
    80000190:	1080                	addi	s0,sp,96
    80000192:	8b2a                	mv	s6,a0
    80000194:	8a2e                	mv	s4,a1
    80000196:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000198:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    8000019a:	00011517          	auipc	a0,0x11
    8000019e:	91650513          	addi	a0,a0,-1770 # 80010ab0 <cons>
    800001a2:	00001097          	auipc	ra,0x1
    800001a6:	aba080e7          	jalr	-1350(ra) # 80000c5c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001aa:	00011497          	auipc	s1,0x11
    800001ae:	90648493          	addi	s1,s1,-1786 # 80010ab0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b2:	00011917          	auipc	s2,0x11
    800001b6:	99690913          	addi	s2,s2,-1642 # 80010b48 <cons+0x98>
  while(n > 0){
    800001ba:	0d305563          	blez	s3,80000284 <consoleread+0x106>
    while(cons.r == cons.w){
    800001be:	0984a783          	lw	a5,152(s1)
    800001c2:	09c4a703          	lw	a4,156(s1)
    800001c6:	0af71a63          	bne	a4,a5,8000027a <consoleread+0xfc>
      if(killed(myproc())){
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	9ea080e7          	jalr	-1558(ra) # 80001bb4 <myproc>
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	33c080e7          	jalr	828(ra) # 8000250e <killed>
    800001da:	e52d                	bnez	a0,80000244 <consoleread+0xc6>
      sleep(&cons.r, &cons.lock);
    800001dc:	85a6                	mv	a1,s1
    800001de:	854a                	mv	a0,s2
    800001e0:	00002097          	auipc	ra,0x2
    800001e4:	082080e7          	jalr	130(ra) # 80002262 <sleep>
    while(cons.r == cons.w){
    800001e8:	0984a783          	lw	a5,152(s1)
    800001ec:	09c4a703          	lw	a4,156(s1)
    800001f0:	fcf70de3          	beq	a4,a5,800001ca <consoleread+0x4c>
    800001f4:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001f6:	00011717          	auipc	a4,0x11
    800001fa:	8ba70713          	addi	a4,a4,-1862 # 80010ab0 <cons>
    800001fe:	0017869b          	addiw	a3,a5,1
    80000202:	08d72c23          	sw	a3,152(a4)
    80000206:	07f7f693          	andi	a3,a5,127
    8000020a:	9736                	add	a4,a4,a3
    8000020c:	01874703          	lbu	a4,24(a4)
    80000210:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    80000214:	4691                	li	a3,4
    80000216:	04da8a63          	beq	s5,a3,8000026a <consoleread+0xec>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000021a:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000021e:	4685                	li	a3,1
    80000220:	faf40613          	addi	a2,s0,-81
    80000224:	85d2                	mv	a1,s4
    80000226:	855a                	mv	a0,s6
    80000228:	00002097          	auipc	ra,0x2
    8000022c:	440080e7          	jalr	1088(ra) # 80002668 <either_copyout>
    80000230:	57fd                	li	a5,-1
    80000232:	04f50863          	beq	a0,a5,80000282 <consoleread+0x104>
      break;

    dst++;
    80000236:	0a05                	addi	s4,s4,1
    --n;
    80000238:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000023a:	47a9                	li	a5,10
    8000023c:	04fa8f63          	beq	s5,a5,8000029a <consoleread+0x11c>
    80000240:	7aa2                	ld	s5,40(sp)
    80000242:	bfa5                	j	800001ba <consoleread+0x3c>
        release(&cons.lock);
    80000244:	00011517          	auipc	a0,0x11
    80000248:	86c50513          	addi	a0,a0,-1940 # 80010ab0 <cons>
    8000024c:	00001097          	auipc	ra,0x1
    80000250:	ac0080e7          	jalr	-1344(ra) # 80000d0c <release>
        return -1;
    80000254:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000256:	60e6                	ld	ra,88(sp)
    80000258:	6446                	ld	s0,80(sp)
    8000025a:	64a6                	ld	s1,72(sp)
    8000025c:	6906                	ld	s2,64(sp)
    8000025e:	79e2                	ld	s3,56(sp)
    80000260:	7a42                	ld	s4,48(sp)
    80000262:	7b02                	ld	s6,32(sp)
    80000264:	6be2                	ld	s7,24(sp)
    80000266:	6125                	addi	sp,sp,96
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0179fa63          	bgeu	s3,s7,8000027e <consoleread+0x100>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	8cf72d23          	sw	a5,-1830(a4) # 80010b48 <cons+0x98>
    80000276:	7aa2                	ld	s5,40(sp)
    80000278:	a031                	j	80000284 <consoleread+0x106>
    8000027a:	f456                	sd	s5,40(sp)
    8000027c:	bfad                	j	800001f6 <consoleread+0x78>
    8000027e:	7aa2                	ld	s5,40(sp)
    80000280:	a011                	j	80000284 <consoleread+0x106>
    80000282:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000284:	00011517          	auipc	a0,0x11
    80000288:	82c50513          	addi	a0,a0,-2004 # 80010ab0 <cons>
    8000028c:	00001097          	auipc	ra,0x1
    80000290:	a80080e7          	jalr	-1408(ra) # 80000d0c <release>
  return target - n;
    80000294:	413b853b          	subw	a0,s7,s3
    80000298:	bf7d                	j	80000256 <consoleread+0xd8>
    8000029a:	7aa2                	ld	s5,40(sp)
    8000029c:	b7e5                	j	80000284 <consoleread+0x106>

000000008000029e <consputc>:
{
    8000029e:	1141                	addi	sp,sp,-16
    800002a0:	e406                	sd	ra,8(sp)
    800002a2:	e022                	sd	s0,0(sp)
    800002a4:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800002a6:	10000793          	li	a5,256
    800002aa:	00f50a63          	beq	a0,a5,800002be <consputc+0x20>
    uartputc_sync(c);
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	590080e7          	jalr	1424(ra) # 8000083e <uartputc_sync>
}
    800002b6:	60a2                	ld	ra,8(sp)
    800002b8:	6402                	ld	s0,0(sp)
    800002ba:	0141                	addi	sp,sp,16
    800002bc:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002be:	4521                	li	a0,8
    800002c0:	00000097          	auipc	ra,0x0
    800002c4:	57e080e7          	jalr	1406(ra) # 8000083e <uartputc_sync>
    800002c8:	02000513          	li	a0,32
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	572080e7          	jalr	1394(ra) # 8000083e <uartputc_sync>
    800002d4:	4521                	li	a0,8
    800002d6:	00000097          	auipc	ra,0x0
    800002da:	568080e7          	jalr	1384(ra) # 8000083e <uartputc_sync>
    800002de:	bfe1                	j	800002b6 <consputc+0x18>

00000000800002e0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002e0:	1101                	addi	sp,sp,-32
    800002e2:	ec06                	sd	ra,24(sp)
    800002e4:	e822                	sd	s0,16(sp)
    800002e6:	e426                	sd	s1,8(sp)
    800002e8:	1000                	addi	s0,sp,32
    800002ea:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002ec:	00010517          	auipc	a0,0x10
    800002f0:	7c450513          	addi	a0,a0,1988 # 80010ab0 <cons>
    800002f4:	00001097          	auipc	ra,0x1
    800002f8:	968080e7          	jalr	-1688(ra) # 80000c5c <acquire>

  switch(c){
    800002fc:	47d5                	li	a5,21
    800002fe:	0af48363          	beq	s1,a5,800003a4 <consoleintr+0xc4>
    80000302:	0297c963          	blt	a5,s1,80000334 <consoleintr+0x54>
    80000306:	47a1                	li	a5,8
    80000308:	0ef48a63          	beq	s1,a5,800003fc <consoleintr+0x11c>
    8000030c:	47c1                	li	a5,16
    8000030e:	10f49d63          	bne	s1,a5,80000428 <consoleintr+0x148>
  case C('P'):  // Print process list.
    procdump();
    80000312:	00002097          	auipc	ra,0x2
    80000316:	402080e7          	jalr	1026(ra) # 80002714 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000031a:	00010517          	auipc	a0,0x10
    8000031e:	79650513          	addi	a0,a0,1942 # 80010ab0 <cons>
    80000322:	00001097          	auipc	ra,0x1
    80000326:	9ea080e7          	jalr	-1558(ra) # 80000d0c <release>
}
    8000032a:	60e2                	ld	ra,24(sp)
    8000032c:	6442                	ld	s0,16(sp)
    8000032e:	64a2                	ld	s1,8(sp)
    80000330:	6105                	addi	sp,sp,32
    80000332:	8082                	ret
  switch(c){
    80000334:	07f00793          	li	a5,127
    80000338:	0cf48263          	beq	s1,a5,800003fc <consoleintr+0x11c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000033c:	00010717          	auipc	a4,0x10
    80000340:	77470713          	addi	a4,a4,1908 # 80010ab0 <cons>
    80000344:	0a072783          	lw	a5,160(a4)
    80000348:	09872703          	lw	a4,152(a4)
    8000034c:	9f99                	subw	a5,a5,a4
    8000034e:	07f00713          	li	a4,127
    80000352:	fcf764e3          	bltu	a4,a5,8000031a <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    80000356:	47b5                	li	a5,13
    80000358:	0cf48b63          	beq	s1,a5,8000042e <consoleintr+0x14e>
      consputc(c);
    8000035c:	8526                	mv	a0,s1
    8000035e:	00000097          	auipc	ra,0x0
    80000362:	f40080e7          	jalr	-192(ra) # 8000029e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000366:	00010717          	auipc	a4,0x10
    8000036a:	74a70713          	addi	a4,a4,1866 # 80010ab0 <cons>
    8000036e:	0a072683          	lw	a3,160(a4)
    80000372:	0016879b          	addiw	a5,a3,1
    80000376:	863e                	mv	a2,a5
    80000378:	0af72023          	sw	a5,160(a4)
    8000037c:	07f6f693          	andi	a3,a3,127
    80000380:	9736                	add	a4,a4,a3
    80000382:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000386:	ff648713          	addi	a4,s1,-10
    8000038a:	cb61                	beqz	a4,8000045a <consoleintr+0x17a>
    8000038c:	14f1                	addi	s1,s1,-4
    8000038e:	c4f1                	beqz	s1,8000045a <consoleintr+0x17a>
    80000390:	00010717          	auipc	a4,0x10
    80000394:	7b872703          	lw	a4,1976(a4) # 80010b48 <cons+0x98>
    80000398:	9f99                	subw	a5,a5,a4
    8000039a:	08000713          	li	a4,128
    8000039e:	f6e79ee3          	bne	a5,a4,8000031a <consoleintr+0x3a>
    800003a2:	a865                	j	8000045a <consoleintr+0x17a>
    800003a4:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    800003a6:	00010717          	auipc	a4,0x10
    800003aa:	70a70713          	addi	a4,a4,1802 # 80010ab0 <cons>
    800003ae:	0a072783          	lw	a5,160(a4)
    800003b2:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003b6:	00010497          	auipc	s1,0x10
    800003ba:	6fa48493          	addi	s1,s1,1786 # 80010ab0 <cons>
    while(cons.e != cons.w &&
    800003be:	4929                	li	s2,10
    800003c0:	02f70a63          	beq	a4,a5,800003f4 <consoleintr+0x114>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003c4:	37fd                	addiw	a5,a5,-1
    800003c6:	07f7f713          	andi	a4,a5,127
    800003ca:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003cc:	01874703          	lbu	a4,24(a4)
    800003d0:	03270463          	beq	a4,s2,800003f8 <consoleintr+0x118>
      cons.e--;
    800003d4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003d8:	10000513          	li	a0,256
    800003dc:	00000097          	auipc	ra,0x0
    800003e0:	ec2080e7          	jalr	-318(ra) # 8000029e <consputc>
    while(cons.e != cons.w &&
    800003e4:	0a04a783          	lw	a5,160(s1)
    800003e8:	09c4a703          	lw	a4,156(s1)
    800003ec:	fcf71ce3          	bne	a4,a5,800003c4 <consoleintr+0xe4>
    800003f0:	6902                	ld	s2,0(sp)
    800003f2:	b725                	j	8000031a <consoleintr+0x3a>
    800003f4:	6902                	ld	s2,0(sp)
    800003f6:	b715                	j	8000031a <consoleintr+0x3a>
    800003f8:	6902                	ld	s2,0(sp)
    800003fa:	b705                	j	8000031a <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003fc:	00010717          	auipc	a4,0x10
    80000400:	6b470713          	addi	a4,a4,1716 # 80010ab0 <cons>
    80000404:	0a072783          	lw	a5,160(a4)
    80000408:	09c72703          	lw	a4,156(a4)
    8000040c:	f0f707e3          	beq	a4,a5,8000031a <consoleintr+0x3a>
      cons.e--;
    80000410:	37fd                	addiw	a5,a5,-1
    80000412:	00010717          	auipc	a4,0x10
    80000416:	72f72f23          	sw	a5,1854(a4) # 80010b50 <cons+0xa0>
      consputc(BACKSPACE);
    8000041a:	10000513          	li	a0,256
    8000041e:	00000097          	auipc	ra,0x0
    80000422:	e80080e7          	jalr	-384(ra) # 8000029e <consputc>
    80000426:	bdd5                	j	8000031a <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000428:	ee0489e3          	beqz	s1,8000031a <consoleintr+0x3a>
    8000042c:	bf01                	j	8000033c <consoleintr+0x5c>
      consputc(c);
    8000042e:	4529                	li	a0,10
    80000430:	00000097          	auipc	ra,0x0
    80000434:	e6e080e7          	jalr	-402(ra) # 8000029e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000438:	00010797          	auipc	a5,0x10
    8000043c:	67878793          	addi	a5,a5,1656 # 80010ab0 <cons>
    80000440:	0a07a703          	lw	a4,160(a5)
    80000444:	0017069b          	addiw	a3,a4,1
    80000448:	8636                	mv	a2,a3
    8000044a:	0ad7a023          	sw	a3,160(a5)
    8000044e:	07f77713          	andi	a4,a4,127
    80000452:	97ba                	add	a5,a5,a4
    80000454:	4729                	li	a4,10
    80000456:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000045a:	00010797          	auipc	a5,0x10
    8000045e:	6ec7a923          	sw	a2,1778(a5) # 80010b4c <cons+0x9c>
        wakeup(&cons.r);
    80000462:	00010517          	auipc	a0,0x10
    80000466:	6e650513          	addi	a0,a0,1766 # 80010b48 <cons+0x98>
    8000046a:	00002097          	auipc	ra,0x2
    8000046e:	e5c080e7          	jalr	-420(ra) # 800022c6 <wakeup>
    80000472:	b565                	j	8000031a <consoleintr+0x3a>

0000000080000474 <consoleinit>:

void
consoleinit(void)
{
    80000474:	1141                	addi	sp,sp,-16
    80000476:	e406                	sd	ra,8(sp)
    80000478:	e022                	sd	s0,0(sp)
    8000047a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000047c:	00008597          	auipc	a1,0x8
    80000480:	b8458593          	addi	a1,a1,-1148 # 80008000 <etext>
    80000484:	00010517          	auipc	a0,0x10
    80000488:	62c50513          	addi	a0,a0,1580 # 80010ab0 <cons>
    8000048c:	00000097          	auipc	ra,0x0
    80000490:	736080e7          	jalr	1846(ra) # 80000bc2 <initlock>

  uartinit();
    80000494:	00000097          	auipc	ra,0x0
    80000498:	350080e7          	jalr	848(ra) # 800007e4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000049c:	00020797          	auipc	a5,0x20
    800004a0:	7ac78793          	addi	a5,a5,1964 # 80020c48 <devsw>
    800004a4:	00000717          	auipc	a4,0x0
    800004a8:	cda70713          	addi	a4,a4,-806 # 8000017e <consoleread>
    800004ac:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004ae:	00000717          	auipc	a4,0x0
    800004b2:	c5470713          	addi	a4,a4,-940 # 80000102 <consolewrite>
    800004b6:	ef98                	sd	a4,24(a5)
}
    800004b8:	60a2                	ld	ra,8(sp)
    800004ba:	6402                	ld	s0,0(sp)
    800004bc:	0141                	addi	sp,sp,16
    800004be:	8082                	ret

00000000800004c0 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004c0:	7179                	addi	sp,sp,-48
    800004c2:	f406                	sd	ra,40(sp)
    800004c4:	f022                	sd	s0,32(sp)
    800004c6:	e84a                	sd	s2,16(sp)
    800004c8:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ca:	c219                	beqz	a2,800004d0 <printint+0x10>
    800004cc:	08054563          	bltz	a0,80000556 <printint+0x96>
    x = -xx;
  else
    x = xx;
    800004d0:	4301                	li	t1,0

  i = 0;
    800004d2:	fd040913          	addi	s2,s0,-48
    x = xx;
    800004d6:	86ca                	mv	a3,s2
  i = 0;
    800004d8:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004da:	00008817          	auipc	a6,0x8
    800004de:	2e680813          	addi	a6,a6,742 # 800087c0 <digits>
    800004e2:	88ba                	mv	a7,a4
    800004e4:	0017061b          	addiw	a2,a4,1
    800004e8:	8732                	mv	a4,a2
    800004ea:	02b577bb          	remuw	a5,a0,a1
    800004ee:	1782                	slli	a5,a5,0x20
    800004f0:	9381                	srli	a5,a5,0x20
    800004f2:	97c2                	add	a5,a5,a6
    800004f4:	0007c783          	lbu	a5,0(a5)
    800004f8:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004fc:	87aa                	mv	a5,a0
    800004fe:	02b5553b          	divuw	a0,a0,a1
    80000502:	0685                	addi	a3,a3,1
    80000504:	fcb7ffe3          	bgeu	a5,a1,800004e2 <printint+0x22>

  if(sign)
    80000508:	00030c63          	beqz	t1,80000520 <printint+0x60>
    buf[i++] = '-';
    8000050c:	fe060793          	addi	a5,a2,-32
    80000510:	00878633          	add	a2,a5,s0
    80000514:	02d00793          	li	a5,45
    80000518:	fef60823          	sb	a5,-16(a2)
    8000051c:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    80000520:	02e05663          	blez	a4,8000054c <printint+0x8c>
    80000524:	ec26                	sd	s1,24(sp)
    80000526:	377d                	addiw	a4,a4,-1
    80000528:	00e904b3          	add	s1,s2,a4
    8000052c:	197d                	addi	s2,s2,-1
    8000052e:	993a                	add	s2,s2,a4
    80000530:	1702                	slli	a4,a4,0x20
    80000532:	9301                	srli	a4,a4,0x20
    80000534:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000538:	0004c503          	lbu	a0,0(s1)
    8000053c:	00000097          	auipc	ra,0x0
    80000540:	d62080e7          	jalr	-670(ra) # 8000029e <consputc>
  while(--i >= 0)
    80000544:	14fd                	addi	s1,s1,-1
    80000546:	ff2499e3          	bne	s1,s2,80000538 <printint+0x78>
    8000054a:	64e2                	ld	s1,24(sp)
}
    8000054c:	70a2                	ld	ra,40(sp)
    8000054e:	7402                	ld	s0,32(sp)
    80000550:	6942                	ld	s2,16(sp)
    80000552:	6145                	addi	sp,sp,48
    80000554:	8082                	ret
    x = -xx;
    80000556:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000055a:	4305                	li	t1,1
    x = -xx;
    8000055c:	bf9d                	j	800004d2 <printint+0x12>

000000008000055e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000055e:	1101                	addi	sp,sp,-32
    80000560:	ec06                	sd	ra,24(sp)
    80000562:	e822                	sd	s0,16(sp)
    80000564:	e426                	sd	s1,8(sp)
    80000566:	1000                	addi	s0,sp,32
    80000568:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000056a:	00010797          	auipc	a5,0x10
    8000056e:	6007a323          	sw	zero,1542(a5) # 80010b70 <pr+0x18>
  printf("panic: ");
    80000572:	00008517          	auipc	a0,0x8
    80000576:	a9650513          	addi	a0,a0,-1386 # 80008008 <etext+0x8>
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	02e080e7          	jalr	46(ra) # 800005a8 <printf>
  printf(s);
    80000582:	8526                	mv	a0,s1
    80000584:	00000097          	auipc	ra,0x0
    80000588:	024080e7          	jalr	36(ra) # 800005a8 <printf>
  printf("\n");
    8000058c:	00008517          	auipc	a0,0x8
    80000590:	a8450513          	addi	a0,a0,-1404 # 80008010 <etext+0x10>
    80000594:	00000097          	auipc	ra,0x0
    80000598:	014080e7          	jalr	20(ra) # 800005a8 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059c:	4785                	li	a5,1
    8000059e:	00008717          	auipc	a4,0x8
    800005a2:	38f72923          	sw	a5,914(a4) # 80008930 <panicked>
  for(;;)
    800005a6:	a001                	j	800005a6 <panic+0x48>

00000000800005a8 <printf>:
{
    800005a8:	7131                	addi	sp,sp,-192
    800005aa:	fc86                	sd	ra,120(sp)
    800005ac:	f8a2                	sd	s0,112(sp)
    800005ae:	e8d2                	sd	s4,80(sp)
    800005b0:	ec6e                	sd	s11,24(sp)
    800005b2:	0100                	addi	s0,sp,128
    800005b4:	8a2a                	mv	s4,a0
    800005b6:	e40c                	sd	a1,8(s0)
    800005b8:	e810                	sd	a2,16(s0)
    800005ba:	ec14                	sd	a3,24(s0)
    800005bc:	f018                	sd	a4,32(s0)
    800005be:	f41c                	sd	a5,40(s0)
    800005c0:	03043823          	sd	a6,48(s0)
    800005c4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c8:	00010d97          	auipc	s11,0x10
    800005cc:	5a8dad83          	lw	s11,1448(s11) # 80010b70 <pr+0x18>
  if(locking)
    800005d0:	040d9463          	bnez	s11,80000618 <printf+0x70>
  if (fmt == 0)
    800005d4:	040a0b63          	beqz	s4,8000062a <printf+0x82>
  va_start(ap, fmt);
    800005d8:	00840793          	addi	a5,s0,8
    800005dc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e0:	000a4503          	lbu	a0,0(s4)
    800005e4:	18050c63          	beqz	a0,8000077c <printf+0x1d4>
    800005e8:	f4a6                	sd	s1,104(sp)
    800005ea:	f0ca                	sd	s2,96(sp)
    800005ec:	ecce                	sd	s3,88(sp)
    800005ee:	e4d6                	sd	s5,72(sp)
    800005f0:	e0da                	sd	s6,64(sp)
    800005f2:	fc5e                	sd	s7,56(sp)
    800005f4:	f862                	sd	s8,48(sp)
    800005f6:	f466                	sd	s9,40(sp)
    800005f8:	f06a                	sd	s10,32(sp)
    800005fa:	4981                	li	s3,0
    if(c != '%'){
    800005fc:	02500b13          	li	s6,37
    switch(c){
    80000600:	07000b93          	li	s7,112
  consputc('x');
    80000604:	07800c93          	li	s9,120
    80000608:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000060a:	00008a97          	auipc	s5,0x8
    8000060e:	1b6a8a93          	addi	s5,s5,438 # 800087c0 <digits>
    switch(c){
    80000612:	07300c13          	li	s8,115
    80000616:	a0b9                	j	80000664 <printf+0xbc>
    acquire(&pr.lock);
    80000618:	00010517          	auipc	a0,0x10
    8000061c:	54050513          	addi	a0,a0,1344 # 80010b58 <pr>
    80000620:	00000097          	auipc	ra,0x0
    80000624:	63c080e7          	jalr	1596(ra) # 80000c5c <acquire>
    80000628:	b775                	j	800005d4 <printf+0x2c>
    8000062a:	f4a6                	sd	s1,104(sp)
    8000062c:	f0ca                	sd	s2,96(sp)
    8000062e:	ecce                	sd	s3,88(sp)
    80000630:	e4d6                	sd	s5,72(sp)
    80000632:	e0da                	sd	s6,64(sp)
    80000634:	fc5e                	sd	s7,56(sp)
    80000636:	f862                	sd	s8,48(sp)
    80000638:	f466                	sd	s9,40(sp)
    8000063a:	f06a                	sd	s10,32(sp)
    panic("null fmt");
    8000063c:	00008517          	auipc	a0,0x8
    80000640:	9e450513          	addi	a0,a0,-1564 # 80008020 <etext+0x20>
    80000644:	00000097          	auipc	ra,0x0
    80000648:	f1a080e7          	jalr	-230(ra) # 8000055e <panic>
      consputc(c);
    8000064c:	00000097          	auipc	ra,0x0
    80000650:	c52080e7          	jalr	-942(ra) # 8000029e <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000654:	0019879b          	addiw	a5,s3,1
    80000658:	89be                	mv	s3,a5
    8000065a:	97d2                	add	a5,a5,s4
    8000065c:	0007c503          	lbu	a0,0(a5)
    80000660:	10050563          	beqz	a0,8000076a <printf+0x1c2>
    if(c != '%'){
    80000664:	ff6514e3          	bne	a0,s6,8000064c <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000668:	0019879b          	addiw	a5,s3,1
    8000066c:	89be                	mv	s3,a5
    8000066e:	97d2                	add	a5,a5,s4
    80000670:	0007c783          	lbu	a5,0(a5)
    80000674:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000678:	10078a63          	beqz	a5,8000078c <printf+0x1e4>
    switch(c){
    8000067c:	05778a63          	beq	a5,s7,800006d0 <printf+0x128>
    80000680:	02fbf463          	bgeu	s7,a5,800006a8 <printf+0x100>
    80000684:	09878763          	beq	a5,s8,80000712 <printf+0x16a>
    80000688:	0d979663          	bne	a5,s9,80000754 <printf+0x1ac>
      printint(va_arg(ap, int), 16, 1);
    8000068c:	f8843783          	ld	a5,-120(s0)
    80000690:	00878713          	addi	a4,a5,8
    80000694:	f8e43423          	sd	a4,-120(s0)
    80000698:	4605                	li	a2,1
    8000069a:	85ea                	mv	a1,s10
    8000069c:	4388                	lw	a0,0(a5)
    8000069e:	00000097          	auipc	ra,0x0
    800006a2:	e22080e7          	jalr	-478(ra) # 800004c0 <printint>
      break;
    800006a6:	b77d                	j	80000654 <printf+0xac>
    switch(c){
    800006a8:	0b678063          	beq	a5,s6,80000748 <printf+0x1a0>
    800006ac:	06400713          	li	a4,100
    800006b0:	0ae79263          	bne	a5,a4,80000754 <printf+0x1ac>
      printint(va_arg(ap, int), 10, 1);
    800006b4:	f8843783          	ld	a5,-120(s0)
    800006b8:	00878713          	addi	a4,a5,8
    800006bc:	f8e43423          	sd	a4,-120(s0)
    800006c0:	4605                	li	a2,1
    800006c2:	45a9                	li	a1,10
    800006c4:	4388                	lw	a0,0(a5)
    800006c6:	00000097          	auipc	ra,0x0
    800006ca:	dfa080e7          	jalr	-518(ra) # 800004c0 <printint>
      break;
    800006ce:	b759                	j	80000654 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006d0:	f8843783          	ld	a5,-120(s0)
    800006d4:	00878713          	addi	a4,a5,8
    800006d8:	f8e43423          	sd	a4,-120(s0)
    800006dc:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006e0:	03000513          	li	a0,48
    800006e4:	00000097          	auipc	ra,0x0
    800006e8:	bba080e7          	jalr	-1094(ra) # 8000029e <consputc>
  consputc('x');
    800006ec:	8566                	mv	a0,s9
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	bb0080e7          	jalr	-1104(ra) # 8000029e <consputc>
    800006f6:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f8:	03c95793          	srli	a5,s2,0x3c
    800006fc:	97d6                	add	a5,a5,s5
    800006fe:	0007c503          	lbu	a0,0(a5)
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b9c080e7          	jalr	-1124(ra) # 8000029e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070a:	0912                	slli	s2,s2,0x4
    8000070c:	34fd                	addiw	s1,s1,-1
    8000070e:	f4ed                	bnez	s1,800006f8 <printf+0x150>
    80000710:	b791                	j	80000654 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    80000712:	f8843783          	ld	a5,-120(s0)
    80000716:	00878713          	addi	a4,a5,8
    8000071a:	f8e43423          	sd	a4,-120(s0)
    8000071e:	6384                	ld	s1,0(a5)
    80000720:	cc89                	beqz	s1,8000073a <printf+0x192>
      for(; *s; s++)
    80000722:	0004c503          	lbu	a0,0(s1)
    80000726:	d51d                	beqz	a0,80000654 <printf+0xac>
        consputc(*s);
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b76080e7          	jalr	-1162(ra) # 8000029e <consputc>
      for(; *s; s++)
    80000730:	0485                	addi	s1,s1,1
    80000732:	0004c503          	lbu	a0,0(s1)
    80000736:	f96d                	bnez	a0,80000728 <printf+0x180>
    80000738:	bf31                	j	80000654 <printf+0xac>
        s = "(null)";
    8000073a:	00008497          	auipc	s1,0x8
    8000073e:	8de48493          	addi	s1,s1,-1826 # 80008018 <etext+0x18>
      for(; *s; s++)
    80000742:	02800513          	li	a0,40
    80000746:	b7cd                	j	80000728 <printf+0x180>
      consputc('%');
    80000748:	855a                	mv	a0,s6
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	b54080e7          	jalr	-1196(ra) # 8000029e <consputc>
      break;
    80000752:	b709                	j	80000654 <printf+0xac>
      consputc('%');
    80000754:	855a                	mv	a0,s6
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	b48080e7          	jalr	-1208(ra) # 8000029e <consputc>
      consputc(c);
    8000075e:	8526                	mv	a0,s1
    80000760:	00000097          	auipc	ra,0x0
    80000764:	b3e080e7          	jalr	-1218(ra) # 8000029e <consputc>
      break;
    80000768:	b5f5                	j	80000654 <printf+0xac>
    8000076a:	74a6                	ld	s1,104(sp)
    8000076c:	7906                	ld	s2,96(sp)
    8000076e:	69e6                	ld	s3,88(sp)
    80000770:	6aa6                	ld	s5,72(sp)
    80000772:	6b06                	ld	s6,64(sp)
    80000774:	7be2                	ld	s7,56(sp)
    80000776:	7c42                	ld	s8,48(sp)
    80000778:	7ca2                	ld	s9,40(sp)
    8000077a:	7d02                	ld	s10,32(sp)
  if(locking)
    8000077c:	020d9263          	bnez	s11,800007a0 <printf+0x1f8>
}
    80000780:	70e6                	ld	ra,120(sp)
    80000782:	7446                	ld	s0,112(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	6de2                	ld	s11,24(sp)
    80000788:	6129                	addi	sp,sp,192
    8000078a:	8082                	ret
    8000078c:	74a6                	ld	s1,104(sp)
    8000078e:	7906                	ld	s2,96(sp)
    80000790:	69e6                	ld	s3,88(sp)
    80000792:	6aa6                	ld	s5,72(sp)
    80000794:	6b06                	ld	s6,64(sp)
    80000796:	7be2                	ld	s7,56(sp)
    80000798:	7c42                	ld	s8,48(sp)
    8000079a:	7ca2                	ld	s9,40(sp)
    8000079c:	7d02                	ld	s10,32(sp)
    8000079e:	bff9                	j	8000077c <printf+0x1d4>
    release(&pr.lock);
    800007a0:	00010517          	auipc	a0,0x10
    800007a4:	3b850513          	addi	a0,a0,952 # 80010b58 <pr>
    800007a8:	00000097          	auipc	ra,0x0
    800007ac:	564080e7          	jalr	1380(ra) # 80000d0c <release>
}
    800007b0:	bfc1                	j	80000780 <printf+0x1d8>

00000000800007b2 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007b2:	1141                	addi	sp,sp,-16
    800007b4:	e406                	sd	ra,8(sp)
    800007b6:	e022                	sd	s0,0(sp)
    800007b8:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    800007ba:	00008597          	auipc	a1,0x8
    800007be:	87658593          	addi	a1,a1,-1930 # 80008030 <etext+0x30>
    800007c2:	00010517          	auipc	a0,0x10
    800007c6:	39650513          	addi	a0,a0,918 # 80010b58 <pr>
    800007ca:	00000097          	auipc	ra,0x0
    800007ce:	3f8080e7          	jalr	1016(ra) # 80000bc2 <initlock>
  pr.locking = 1;
    800007d2:	4785                	li	a5,1
    800007d4:	00010717          	auipc	a4,0x10
    800007d8:	38f72e23          	sw	a5,924(a4) # 80010b70 <pr+0x18>
}
    800007dc:	60a2                	ld	ra,8(sp)
    800007de:	6402                	ld	s0,0(sp)
    800007e0:	0141                	addi	sp,sp,16
    800007e2:	8082                	ret

00000000800007e4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007e4:	1141                	addi	sp,sp,-16
    800007e6:	e406                	sd	ra,8(sp)
    800007e8:	e022                	sd	s0,0(sp)
    800007ea:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ec:	100007b7          	lui	a5,0x10000
    800007f0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f4:	10000737          	lui	a4,0x10000
    800007f8:	f8000693          	li	a3,-128
    800007fc:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000800:	468d                	li	a3,3
    80000802:	10000637          	lui	a2,0x10000
    80000806:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000080a:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080e:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000812:	8732                	mv	a4,a2
    80000814:	461d                	li	a2,7
    80000816:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081a:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000081e:	00008597          	auipc	a1,0x8
    80000822:	81a58593          	addi	a1,a1,-2022 # 80008038 <etext+0x38>
    80000826:	00010517          	auipc	a0,0x10
    8000082a:	35250513          	addi	a0,a0,850 # 80010b78 <uart_tx_lock>
    8000082e:	00000097          	auipc	ra,0x0
    80000832:	394080e7          	jalr	916(ra) # 80000bc2 <initlock>
}
    80000836:	60a2                	ld	ra,8(sp)
    80000838:	6402                	ld	s0,0(sp)
    8000083a:	0141                	addi	sp,sp,16
    8000083c:	8082                	ret

000000008000083e <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000083e:	1101                	addi	sp,sp,-32
    80000840:	ec06                	sd	ra,24(sp)
    80000842:	e822                	sd	s0,16(sp)
    80000844:	e426                	sd	s1,8(sp)
    80000846:	1000                	addi	s0,sp,32
    80000848:	84aa                	mv	s1,a0
  push_off();
    8000084a:	00000097          	auipc	ra,0x0
    8000084e:	3c2080e7          	jalr	962(ra) # 80000c0c <push_off>

  if(panicked){
    80000852:	00008797          	auipc	a5,0x8
    80000856:	0de7a783          	lw	a5,222(a5) # 80008930 <panicked>
    8000085a:	eb85                	bnez	a5,8000088a <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085c:	10000737          	lui	a4,0x10000
    80000860:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000862:	00074783          	lbu	a5,0(a4)
    80000866:	0207f793          	andi	a5,a5,32
    8000086a:	dfe5                	beqz	a5,80000862 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000086c:	0ff4f513          	zext.b	a0,s1
    80000870:	100007b7          	lui	a5,0x10000
    80000874:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000878:	00000097          	auipc	ra,0x0
    8000087c:	438080e7          	jalr	1080(ra) # 80000cb0 <pop_off>
}
    80000880:	60e2                	ld	ra,24(sp)
    80000882:	6442                	ld	s0,16(sp)
    80000884:	64a2                	ld	s1,8(sp)
    80000886:	6105                	addi	sp,sp,32
    80000888:	8082                	ret
    for(;;)
    8000088a:	a001                	j	8000088a <uartputc_sync+0x4c>

000000008000088c <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000088c:	00008797          	auipc	a5,0x8
    80000890:	0ac7b783          	ld	a5,172(a5) # 80008938 <uart_tx_r>
    80000894:	00008717          	auipc	a4,0x8
    80000898:	0ac73703          	ld	a4,172(a4) # 80008940 <uart_tx_w>
    8000089c:	06f70f63          	beq	a4,a5,8000091a <uartstart+0x8e>
{
    800008a0:	7139                	addi	sp,sp,-64
    800008a2:	fc06                	sd	ra,56(sp)
    800008a4:	f822                	sd	s0,48(sp)
    800008a6:	f426                	sd	s1,40(sp)
    800008a8:	f04a                	sd	s2,32(sp)
    800008aa:	ec4e                	sd	s3,24(sp)
    800008ac:	e852                	sd	s4,16(sp)
    800008ae:	e456                	sd	s5,8(sp)
    800008b0:	e05a                	sd	s6,0(sp)
    800008b2:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b4:	10000937          	lui	s2,0x10000
    800008b8:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ba:	00010a97          	auipc	s5,0x10
    800008be:	2bea8a93          	addi	s5,s5,702 # 80010b78 <uart_tx_lock>
    uart_tx_r += 1;
    800008c2:	00008497          	auipc	s1,0x8
    800008c6:	07648493          	addi	s1,s1,118 # 80008938 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008ca:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008ce:	00008997          	auipc	s3,0x8
    800008d2:	07298993          	addi	s3,s3,114 # 80008940 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d6:	00094703          	lbu	a4,0(s2)
    800008da:	02077713          	andi	a4,a4,32
    800008de:	c705                	beqz	a4,80000906 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008e0:	01f7f713          	andi	a4,a5,31
    800008e4:	9756                	add	a4,a4,s5
    800008e6:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008ea:	0785                	addi	a5,a5,1
    800008ec:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008ee:	8526                	mv	a0,s1
    800008f0:	00002097          	auipc	ra,0x2
    800008f4:	9d6080e7          	jalr	-1578(ra) # 800022c6 <wakeup>
    WriteReg(THR, c);
    800008f8:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fc:	609c                	ld	a5,0(s1)
    800008fe:	0009b703          	ld	a4,0(s3)
    80000902:	fcf71ae3          	bne	a4,a5,800008d6 <uartstart+0x4a>
  }
}
    80000906:	70e2                	ld	ra,56(sp)
    80000908:	7442                	ld	s0,48(sp)
    8000090a:	74a2                	ld	s1,40(sp)
    8000090c:	7902                	ld	s2,32(sp)
    8000090e:	69e2                	ld	s3,24(sp)
    80000910:	6a42                	ld	s4,16(sp)
    80000912:	6aa2                	ld	s5,8(sp)
    80000914:	6b02                	ld	s6,0(sp)
    80000916:	6121                	addi	sp,sp,64
    80000918:	8082                	ret
    8000091a:	8082                	ret

000000008000091c <uartputc>:
{
    8000091c:	7179                	addi	sp,sp,-48
    8000091e:	f406                	sd	ra,40(sp)
    80000920:	f022                	sd	s0,32(sp)
    80000922:	ec26                	sd	s1,24(sp)
    80000924:	e84a                	sd	s2,16(sp)
    80000926:	e44e                	sd	s3,8(sp)
    80000928:	e052                	sd	s4,0(sp)
    8000092a:	1800                	addi	s0,sp,48
    8000092c:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000092e:	00010517          	auipc	a0,0x10
    80000932:	24a50513          	addi	a0,a0,586 # 80010b78 <uart_tx_lock>
    80000936:	00000097          	auipc	ra,0x0
    8000093a:	326080e7          	jalr	806(ra) # 80000c5c <acquire>
  if(panicked){
    8000093e:	00008797          	auipc	a5,0x8
    80000942:	ff27a783          	lw	a5,-14(a5) # 80008930 <panicked>
    80000946:	ebc1                	bnez	a5,800009d6 <uartputc+0xba>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000948:	00008717          	auipc	a4,0x8
    8000094c:	ff873703          	ld	a4,-8(a4) # 80008940 <uart_tx_w>
    80000950:	00008797          	auipc	a5,0x8
    80000954:	fe87b783          	ld	a5,-24(a5) # 80008938 <uart_tx_r>
    80000958:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095c:	00010997          	auipc	s3,0x10
    80000960:	21c98993          	addi	s3,s3,540 # 80010b78 <uart_tx_lock>
    80000964:	00008497          	auipc	s1,0x8
    80000968:	fd448493          	addi	s1,s1,-44 # 80008938 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096c:	00008917          	auipc	s2,0x8
    80000970:	fd490913          	addi	s2,s2,-44 # 80008940 <uart_tx_w>
    80000974:	00e79f63          	bne	a5,a4,80000992 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000978:	85ce                	mv	a1,s3
    8000097a:	8526                	mv	a0,s1
    8000097c:	00002097          	auipc	ra,0x2
    80000980:	8e6080e7          	jalr	-1818(ra) # 80002262 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000984:	00093703          	ld	a4,0(s2)
    80000988:	609c                	ld	a5,0(s1)
    8000098a:	02078793          	addi	a5,a5,32
    8000098e:	fee785e3          	beq	a5,a4,80000978 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000992:	01f77693          	andi	a3,a4,31
    80000996:	00010797          	auipc	a5,0x10
    8000099a:	1e278793          	addi	a5,a5,482 # 80010b78 <uart_tx_lock>
    8000099e:	97b6                	add	a5,a5,a3
    800009a0:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a4:	0705                	addi	a4,a4,1
    800009a6:	00008797          	auipc	a5,0x8
    800009aa:	f8e7bd23          	sd	a4,-102(a5) # 80008940 <uart_tx_w>
  uartstart();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	ede080e7          	jalr	-290(ra) # 8000088c <uartstart>
  release(&uart_tx_lock);
    800009b6:	00010517          	auipc	a0,0x10
    800009ba:	1c250513          	addi	a0,a0,450 # 80010b78 <uart_tx_lock>
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	34e080e7          	jalr	846(ra) # 80000d0c <release>
}
    800009c6:	70a2                	ld	ra,40(sp)
    800009c8:	7402                	ld	s0,32(sp)
    800009ca:	64e2                	ld	s1,24(sp)
    800009cc:	6942                	ld	s2,16(sp)
    800009ce:	69a2                	ld	s3,8(sp)
    800009d0:	6a02                	ld	s4,0(sp)
    800009d2:	6145                	addi	sp,sp,48
    800009d4:	8082                	ret
    for(;;)
    800009d6:	a001                	j	800009d6 <uartputc+0xba>

00000000800009d8 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d8:	1141                	addi	sp,sp,-16
    800009da:	e406                	sd	ra,8(sp)
    800009dc:	e022                	sd	s0,0(sp)
    800009de:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e0:	100007b7          	lui	a5,0x10000
    800009e4:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009e8:	8b85                	andi	a5,a5,1
    800009ea:	cb89                	beqz	a5,800009fc <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009ec:	100007b7          	lui	a5,0x10000
    800009f0:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009f4:	60a2                	ld	ra,8(sp)
    800009f6:	6402                	ld	s0,0(sp)
    800009f8:	0141                	addi	sp,sp,16
    800009fa:	8082                	ret
    return -1;
    800009fc:	557d                	li	a0,-1
    800009fe:	bfdd                	j	800009f4 <uartgetc+0x1c>

0000000080000a00 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a00:	1101                	addi	sp,sp,-32
    80000a02:	ec06                	sd	ra,24(sp)
    80000a04:	e822                	sd	s0,16(sp)
    80000a06:	e426                	sd	s1,8(sp)
    80000a08:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a0a:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a0c:	00000097          	auipc	ra,0x0
    80000a10:	fcc080e7          	jalr	-52(ra) # 800009d8 <uartgetc>
    if(c == -1)
    80000a14:	00950763          	beq	a0,s1,80000a22 <uartintr+0x22>
      break;
    consoleintr(c);
    80000a18:	00000097          	auipc	ra,0x0
    80000a1c:	8c8080e7          	jalr	-1848(ra) # 800002e0 <consoleintr>
  while(1){
    80000a20:	b7f5                	j	80000a0c <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a22:	00010517          	auipc	a0,0x10
    80000a26:	15650513          	addi	a0,a0,342 # 80010b78 <uart_tx_lock>
    80000a2a:	00000097          	auipc	ra,0x0
    80000a2e:	232080e7          	jalr	562(ra) # 80000c5c <acquire>
  uartstart();
    80000a32:	00000097          	auipc	ra,0x0
    80000a36:	e5a080e7          	jalr	-422(ra) # 8000088c <uartstart>
  release(&uart_tx_lock);
    80000a3a:	00010517          	auipc	a0,0x10
    80000a3e:	13e50513          	addi	a0,a0,318 # 80010b78 <uart_tx_lock>
    80000a42:	00000097          	auipc	ra,0x0
    80000a46:	2ca080e7          	jalr	714(ra) # 80000d0c <release>
}
    80000a4a:	60e2                	ld	ra,24(sp)
    80000a4c:	6442                	ld	s0,16(sp)
    80000a4e:	64a2                	ld	s1,8(sp)
    80000a50:	6105                	addi	sp,sp,32
    80000a52:	8082                	ret

0000000080000a54 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a54:	1101                	addi	sp,sp,-32
    80000a56:	ec06                	sd	ra,24(sp)
    80000a58:	e822                	sd	s0,16(sp)
    80000a5a:	e426                	sd	s1,8(sp)
    80000a5c:	e04a                	sd	s2,0(sp)
    80000a5e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a60:	00021797          	auipc	a5,0x21
    80000a64:	38078793          	addi	a5,a5,896 # 80021de0 <end>
    80000a68:	00f53733          	sltu	a4,a0,a5
    80000a6c:	47c5                	li	a5,17
    80000a6e:	07ee                	slli	a5,a5,0x1b
    80000a70:	17fd                	addi	a5,a5,-1
    80000a72:	00a7b7b3          	sltu	a5,a5,a0
    80000a76:	8fd9                	or	a5,a5,a4
    80000a78:	e7a1                	bnez	a5,80000ac0 <kfree+0x6c>
    80000a7a:	84aa                	mv	s1,a0
    80000a7c:	03451793          	slli	a5,a0,0x34
    80000a80:	e3a1                	bnez	a5,80000ac0 <kfree+0x6c>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a82:	6605                	lui	a2,0x1
    80000a84:	4585                	li	a1,1
    80000a86:	00000097          	auipc	ra,0x0
    80000a8a:	2ce080e7          	jalr	718(ra) # 80000d54 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a8e:	00010917          	auipc	s2,0x10
    80000a92:	12290913          	addi	s2,s2,290 # 80010bb0 <kmem>
    80000a96:	854a                	mv	a0,s2
    80000a98:	00000097          	auipc	ra,0x0
    80000a9c:	1c4080e7          	jalr	452(ra) # 80000c5c <acquire>
  r->next = kmem.freelist;
    80000aa0:	01893783          	ld	a5,24(s2)
    80000aa4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aaa:	854a                	mv	a0,s2
    80000aac:	00000097          	auipc	ra,0x0
    80000ab0:	260080e7          	jalr	608(ra) # 80000d0c <release>
}
    80000ab4:	60e2                	ld	ra,24(sp)
    80000ab6:	6442                	ld	s0,16(sp)
    80000ab8:	64a2                	ld	s1,8(sp)
    80000aba:	6902                	ld	s2,0(sp)
    80000abc:	6105                	addi	sp,sp,32
    80000abe:	8082                	ret
    panic("kfree");
    80000ac0:	00007517          	auipc	a0,0x7
    80000ac4:	58050513          	addi	a0,a0,1408 # 80008040 <etext+0x40>
    80000ac8:	00000097          	auipc	ra,0x0
    80000acc:	a96080e7          	jalr	-1386(ra) # 8000055e <panic>

0000000080000ad0 <freerange>:
{
    80000ad0:	7179                	addi	sp,sp,-48
    80000ad2:	f406                	sd	ra,40(sp)
    80000ad4:	f022                	sd	s0,32(sp)
    80000ad6:	ec26                	sd	s1,24(sp)
    80000ad8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ada:	6785                	lui	a5,0x1
    80000adc:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ae0:	00e504b3          	add	s1,a0,a4
    80000ae4:	777d                	lui	a4,0xfffff
    80000ae6:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae8:	94be                	add	s1,s1,a5
    80000aea:	0295e463          	bltu	a1,s1,80000b12 <freerange+0x42>
    80000aee:	e84a                	sd	s2,16(sp)
    80000af0:	e44e                	sd	s3,8(sp)
    80000af2:	e052                	sd	s4,0(sp)
    80000af4:	892e                	mv	s2,a1
    kfree(p);
    80000af6:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af8:	89be                	mv	s3,a5
    kfree(p);
    80000afa:	01448533          	add	a0,s1,s4
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	f56080e7          	jalr	-170(ra) # 80000a54 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b06:	94ce                	add	s1,s1,s3
    80000b08:	fe9979e3          	bgeu	s2,s1,80000afa <freerange+0x2a>
    80000b0c:	6942                	ld	s2,16(sp)
    80000b0e:	69a2                	ld	s3,8(sp)
    80000b10:	6a02                	ld	s4,0(sp)
}
    80000b12:	70a2                	ld	ra,40(sp)
    80000b14:	7402                	ld	s0,32(sp)
    80000b16:	64e2                	ld	s1,24(sp)
    80000b18:	6145                	addi	sp,sp,48
    80000b1a:	8082                	ret

0000000080000b1c <kinit>:
{
    80000b1c:	1141                	addi	sp,sp,-16
    80000b1e:	e406                	sd	ra,8(sp)
    80000b20:	e022                	sd	s0,0(sp)
    80000b22:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b24:	00007597          	auipc	a1,0x7
    80000b28:	52458593          	addi	a1,a1,1316 # 80008048 <etext+0x48>
    80000b2c:	00010517          	auipc	a0,0x10
    80000b30:	08450513          	addi	a0,a0,132 # 80010bb0 <kmem>
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	08e080e7          	jalr	142(ra) # 80000bc2 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b3c:	45c5                	li	a1,17
    80000b3e:	05ee                	slli	a1,a1,0x1b
    80000b40:	00021517          	auipc	a0,0x21
    80000b44:	2a050513          	addi	a0,a0,672 # 80021de0 <end>
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	f88080e7          	jalr	-120(ra) # 80000ad0 <freerange>
}
    80000b50:	60a2                	ld	ra,8(sp)
    80000b52:	6402                	ld	s0,0(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b58:	1101                	addi	sp,sp,-32
    80000b5a:	ec06                	sd	ra,24(sp)
    80000b5c:	e822                	sd	s0,16(sp)
    80000b5e:	e426                	sd	s1,8(sp)
    80000b60:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b62:	00010517          	auipc	a0,0x10
    80000b66:	04e50513          	addi	a0,a0,78 # 80010bb0 <kmem>
    80000b6a:	00000097          	auipc	ra,0x0
    80000b6e:	0f2080e7          	jalr	242(ra) # 80000c5c <acquire>
  r = kmem.freelist;
    80000b72:	00010497          	auipc	s1,0x10
    80000b76:	0564b483          	ld	s1,86(s1) # 80010bc8 <kmem+0x18>
  if(r)
    80000b7a:	c89d                	beqz	s1,80000bb0 <kalloc+0x58>
    kmem.freelist = r->next;
    80000b7c:	609c                	ld	a5,0(s1)
    80000b7e:	00010717          	auipc	a4,0x10
    80000b82:	04f73523          	sd	a5,74(a4) # 80010bc8 <kmem+0x18>
  release(&kmem.lock);
    80000b86:	00010517          	auipc	a0,0x10
    80000b8a:	02a50513          	addi	a0,a0,42 # 80010bb0 <kmem>
    80000b8e:	00000097          	auipc	ra,0x0
    80000b92:	17e080e7          	jalr	382(ra) # 80000d0c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b96:	6605                	lui	a2,0x1
    80000b98:	4595                	li	a1,5
    80000b9a:	8526                	mv	a0,s1
    80000b9c:	00000097          	auipc	ra,0x0
    80000ba0:	1b8080e7          	jalr	440(ra) # 80000d54 <memset>
  return (void*)r;
}
    80000ba4:	8526                	mv	a0,s1
    80000ba6:	60e2                	ld	ra,24(sp)
    80000ba8:	6442                	ld	s0,16(sp)
    80000baa:	64a2                	ld	s1,8(sp)
    80000bac:	6105                	addi	sp,sp,32
    80000bae:	8082                	ret
  release(&kmem.lock);
    80000bb0:	00010517          	auipc	a0,0x10
    80000bb4:	00050513          	mv	a0,a0
    80000bb8:	00000097          	auipc	ra,0x0
    80000bbc:	154080e7          	jalr	340(ra) # 80000d0c <release>
  if(r)
    80000bc0:	b7d5                	j	80000ba4 <kalloc+0x4c>

0000000080000bc2 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bc2:	1141                	addi	sp,sp,-16
    80000bc4:	e406                	sd	ra,8(sp)
    80000bc6:	e022                	sd	s0,0(sp)
    80000bc8:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bca:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bcc:	00052023          	sw	zero,0(a0) # 80010bb0 <kmem>
  lk->cpu = 0;
    80000bd0:	00053823          	sd	zero,16(a0)
}
    80000bd4:	60a2                	ld	ra,8(sp)
    80000bd6:	6402                	ld	s0,0(sp)
    80000bd8:	0141                	addi	sp,sp,16
    80000bda:	8082                	ret

0000000080000bdc <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bdc:	411c                	lw	a5,0(a0)
    80000bde:	e399                	bnez	a5,80000be4 <holding+0x8>
    80000be0:	4501                	li	a0,0
  return r;
}
    80000be2:	8082                	ret
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bee:	691c                	ld	a5,16(a0)
    80000bf0:	84be                	mv	s1,a5
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	fa2080e7          	jalr	-94(ra) # 80001b94 <mycpu>
    80000bfa:	40a48533          	sub	a0,s1,a0
    80000bfe:	00153513          	seqz	a0,a0
}
    80000c02:	60e2                	ld	ra,24(sp)
    80000c04:	6442                	ld	s0,16(sp)
    80000c06:	64a2                	ld	s1,8(sp)
    80000c08:	6105                	addi	sp,sp,32
    80000c0a:	8082                	ret

0000000080000c0c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c0c:	1101                	addi	sp,sp,-32
    80000c0e:	ec06                	sd	ra,24(sp)
    80000c10:	e822                	sd	s0,16(sp)
    80000c12:	e426                	sd	s1,8(sp)
    80000c14:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c16:	100027f3          	csrr	a5,sstatus
    80000c1a:	84be                	mv	s1,a5
    80000c1c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c20:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c22:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c26:	00001097          	auipc	ra,0x1
    80000c2a:	f6e080e7          	jalr	-146(ra) # 80001b94 <mycpu>
    80000c2e:	5d3c                	lw	a5,120(a0)
    80000c30:	cf89                	beqz	a5,80000c4a <push_off+0x3e>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	f62080e7          	jalr	-158(ra) # 80001b94 <mycpu>
    80000c3a:	5d3c                	lw	a5,120(a0)
    80000c3c:	2785                	addiw	a5,a5,1
    80000c3e:	dd3c                	sw	a5,120(a0)
}
    80000c40:	60e2                	ld	ra,24(sp)
    80000c42:	6442                	ld	s0,16(sp)
    80000c44:	64a2                	ld	s1,8(sp)
    80000c46:	6105                	addi	sp,sp,32
    80000c48:	8082                	ret
    mycpu()->intena = old;
    80000c4a:	00001097          	auipc	ra,0x1
    80000c4e:	f4a080e7          	jalr	-182(ra) # 80001b94 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c52:	0014d793          	srli	a5,s1,0x1
    80000c56:	8b85                	andi	a5,a5,1
    80000c58:	dd7c                	sw	a5,124(a0)
    80000c5a:	bfe1                	j	80000c32 <push_off+0x26>

0000000080000c5c <acquire>:
{
    80000c5c:	1101                	addi	sp,sp,-32
    80000c5e:	ec06                	sd	ra,24(sp)
    80000c60:	e822                	sd	s0,16(sp)
    80000c62:	e426                	sd	s1,8(sp)
    80000c64:	1000                	addi	s0,sp,32
    80000c66:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c68:	00000097          	auipc	ra,0x0
    80000c6c:	fa4080e7          	jalr	-92(ra) # 80000c0c <push_off>
  if(holding(lk))
    80000c70:	8526                	mv	a0,s1
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	f6a080e7          	jalr	-150(ra) # 80000bdc <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c7a:	4705                	li	a4,1
  if(holding(lk))
    80000c7c:	e115                	bnez	a0,80000ca0 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c7e:	87ba                	mv	a5,a4
    80000c80:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c84:	2781                	sext.w	a5,a5
    80000c86:	ffe5                	bnez	a5,80000c7e <acquire+0x22>
  __sync_synchronize();
    80000c88:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c8c:	00001097          	auipc	ra,0x1
    80000c90:	f08080e7          	jalr	-248(ra) # 80001b94 <mycpu>
    80000c94:	e888                	sd	a0,16(s1)
}
    80000c96:	60e2                	ld	ra,24(sp)
    80000c98:	6442                	ld	s0,16(sp)
    80000c9a:	64a2                	ld	s1,8(sp)
    80000c9c:	6105                	addi	sp,sp,32
    80000c9e:	8082                	ret
    panic("acquire");
    80000ca0:	00007517          	auipc	a0,0x7
    80000ca4:	3b050513          	addi	a0,a0,944 # 80008050 <etext+0x50>
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	8b6080e7          	jalr	-1866(ra) # 8000055e <panic>

0000000080000cb0 <pop_off>:

void
pop_off(void)
{
    80000cb0:	1141                	addi	sp,sp,-16
    80000cb2:	e406                	sd	ra,8(sp)
    80000cb4:	e022                	sd	s0,0(sp)
    80000cb6:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cb8:	00001097          	auipc	ra,0x1
    80000cbc:	edc080e7          	jalr	-292(ra) # 80001b94 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cc0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cc4:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cc6:	e39d                	bnez	a5,80000cec <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cc8:	5d3c                	lw	a5,120(a0)
    80000cca:	02f05963          	blez	a5,80000cfc <pop_off+0x4c>
    panic("pop_off");
  c->noff -= 1;
    80000cce:	37fd                	addiw	a5,a5,-1
    80000cd0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cd2:	eb89                	bnez	a5,80000ce4 <pop_off+0x34>
    80000cd4:	5d7c                	lw	a5,124(a0)
    80000cd6:	c799                	beqz	a5,80000ce4 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cd8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cdc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ce0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ce4:	60a2                	ld	ra,8(sp)
    80000ce6:	6402                	ld	s0,0(sp)
    80000ce8:	0141                	addi	sp,sp,16
    80000cea:	8082                	ret
    panic("pop_off - interruptible");
    80000cec:	00007517          	auipc	a0,0x7
    80000cf0:	36c50513          	addi	a0,a0,876 # 80008058 <etext+0x58>
    80000cf4:	00000097          	auipc	ra,0x0
    80000cf8:	86a080e7          	jalr	-1942(ra) # 8000055e <panic>
    panic("pop_off");
    80000cfc:	00007517          	auipc	a0,0x7
    80000d00:	37450513          	addi	a0,a0,884 # 80008070 <etext+0x70>
    80000d04:	00000097          	auipc	ra,0x0
    80000d08:	85a080e7          	jalr	-1958(ra) # 8000055e <panic>

0000000080000d0c <release>:
{
    80000d0c:	1101                	addi	sp,sp,-32
    80000d0e:	ec06                	sd	ra,24(sp)
    80000d10:	e822                	sd	s0,16(sp)
    80000d12:	e426                	sd	s1,8(sp)
    80000d14:	1000                	addi	s0,sp,32
    80000d16:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d18:	00000097          	auipc	ra,0x0
    80000d1c:	ec4080e7          	jalr	-316(ra) # 80000bdc <holding>
    80000d20:	c115                	beqz	a0,80000d44 <release+0x38>
  lk->cpu = 0;
    80000d22:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d26:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000d2a:	0310000f          	fence	rw,w
    80000d2e:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000d32:	00000097          	auipc	ra,0x0
    80000d36:	f7e080e7          	jalr	-130(ra) # 80000cb0 <pop_off>
}
    80000d3a:	60e2                	ld	ra,24(sp)
    80000d3c:	6442                	ld	s0,16(sp)
    80000d3e:	64a2                	ld	s1,8(sp)
    80000d40:	6105                	addi	sp,sp,32
    80000d42:	8082                	ret
    panic("release");
    80000d44:	00007517          	auipc	a0,0x7
    80000d48:	33450513          	addi	a0,a0,820 # 80008078 <etext+0x78>
    80000d4c:	00000097          	auipc	ra,0x0
    80000d50:	812080e7          	jalr	-2030(ra) # 8000055e <panic>

0000000080000d54 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d54:	1141                	addi	sp,sp,-16
    80000d56:	e406                	sd	ra,8(sp)
    80000d58:	e022                	sd	s0,0(sp)
    80000d5a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d5c:	ca19                	beqz	a2,80000d72 <memset+0x1e>
    80000d5e:	87aa                	mv	a5,a0
    80000d60:	1602                	slli	a2,a2,0x20
    80000d62:	9201                	srli	a2,a2,0x20
    80000d64:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d68:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d6c:	0785                	addi	a5,a5,1
    80000d6e:	fee79de3          	bne	a5,a4,80000d68 <memset+0x14>
  }
  return dst;
}
    80000d72:	60a2                	ld	ra,8(sp)
    80000d74:	6402                	ld	s0,0(sp)
    80000d76:	0141                	addi	sp,sp,16
    80000d78:	8082                	ret

0000000080000d7a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d7a:	1141                	addi	sp,sp,-16
    80000d7c:	e406                	sd	ra,8(sp)
    80000d7e:	e022                	sd	s0,0(sp)
    80000d80:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d82:	c61d                	beqz	a2,80000db0 <memcmp+0x36>
    80000d84:	1602                	slli	a2,a2,0x20
    80000d86:	9201                	srli	a2,a2,0x20
    80000d88:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d8c:	00054783          	lbu	a5,0(a0)
    80000d90:	0005c703          	lbu	a4,0(a1)
    80000d94:	00e79863          	bne	a5,a4,80000da4 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d98:	0505                	addi	a0,a0,1
    80000d9a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d9c:	fed518e3          	bne	a0,a3,80000d8c <memcmp+0x12>
  }

  return 0;
    80000da0:	4501                	li	a0,0
    80000da2:	a019                	j	80000da8 <memcmp+0x2e>
      return *s1 - *s2;
    80000da4:	40e7853b          	subw	a0,a5,a4
}
    80000da8:	60a2                	ld	ra,8(sp)
    80000daa:	6402                	ld	s0,0(sp)
    80000dac:	0141                	addi	sp,sp,16
    80000dae:	8082                	ret
  return 0;
    80000db0:	4501                	li	a0,0
    80000db2:	bfdd                	j	80000da8 <memcmp+0x2e>

0000000080000db4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000db4:	1141                	addi	sp,sp,-16
    80000db6:	e406                	sd	ra,8(sp)
    80000db8:	e022                	sd	s0,0(sp)
    80000dba:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000dbc:	c205                	beqz	a2,80000ddc <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dbe:	02a5e363          	bltu	a1,a0,80000de4 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dc2:	1602                	slli	a2,a2,0x20
    80000dc4:	9201                	srli	a2,a2,0x20
    80000dc6:	00c587b3          	add	a5,a1,a2
{
    80000dca:	872a                	mv	a4,a0
      *d++ = *s++;
    80000dcc:	0585                	addi	a1,a1,1
    80000dce:	0705                	addi	a4,a4,1
    80000dd0:	fff5c683          	lbu	a3,-1(a1)
    80000dd4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000dd8:	feb79ae3          	bne	a5,a1,80000dcc <memmove+0x18>

  return dst;
}
    80000ddc:	60a2                	ld	ra,8(sp)
    80000dde:	6402                	ld	s0,0(sp)
    80000de0:	0141                	addi	sp,sp,16
    80000de2:	8082                	ret
  if(s < d && s + n > d){
    80000de4:	02061693          	slli	a3,a2,0x20
    80000de8:	9281                	srli	a3,a3,0x20
    80000dea:	00d58733          	add	a4,a1,a3
    80000dee:	fce57ae3          	bgeu	a0,a4,80000dc2 <memmove+0xe>
    d += n;
    80000df2:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000df4:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000df8:	1782                	slli	a5,a5,0x20
    80000dfa:	9381                	srli	a5,a5,0x20
    80000dfc:	fff7c793          	not	a5,a5
    80000e00:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e02:	177d                	addi	a4,a4,-1
    80000e04:	16fd                	addi	a3,a3,-1
    80000e06:	00074603          	lbu	a2,0(a4)
    80000e0a:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e0e:	fee79ae3          	bne	a5,a4,80000e02 <memmove+0x4e>
    80000e12:	b7e9                	j	80000ddc <memmove+0x28>

0000000080000e14 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e14:	1141                	addi	sp,sp,-16
    80000e16:	e406                	sd	ra,8(sp)
    80000e18:	e022                	sd	s0,0(sp)
    80000e1a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e1c:	00000097          	auipc	ra,0x0
    80000e20:	f98080e7          	jalr	-104(ra) # 80000db4 <memmove>
}
    80000e24:	60a2                	ld	ra,8(sp)
    80000e26:	6402                	ld	s0,0(sp)
    80000e28:	0141                	addi	sp,sp,16
    80000e2a:	8082                	ret

0000000080000e2c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e2c:	1141                	addi	sp,sp,-16
    80000e2e:	e406                	sd	ra,8(sp)
    80000e30:	e022                	sd	s0,0(sp)
    80000e32:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e34:	ce11                	beqz	a2,80000e50 <strncmp+0x24>
    80000e36:	00054783          	lbu	a5,0(a0)
    80000e3a:	cf89                	beqz	a5,80000e54 <strncmp+0x28>
    80000e3c:	0005c703          	lbu	a4,0(a1)
    80000e40:	00f71a63          	bne	a4,a5,80000e54 <strncmp+0x28>
    n--, p++, q++;
    80000e44:	367d                	addiw	a2,a2,-1
    80000e46:	0505                	addi	a0,a0,1
    80000e48:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e4a:	f675                	bnez	a2,80000e36 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000e4c:	4501                	li	a0,0
    80000e4e:	a801                	j	80000e5e <strncmp+0x32>
    80000e50:	4501                	li	a0,0
    80000e52:	a031                	j	80000e5e <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000e54:	00054503          	lbu	a0,0(a0)
    80000e58:	0005c783          	lbu	a5,0(a1)
    80000e5c:	9d1d                	subw	a0,a0,a5
}
    80000e5e:	60a2                	ld	ra,8(sp)
    80000e60:	6402                	ld	s0,0(sp)
    80000e62:	0141                	addi	sp,sp,16
    80000e64:	8082                	ret

0000000080000e66 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e66:	1141                	addi	sp,sp,-16
    80000e68:	e406                	sd	ra,8(sp)
    80000e6a:	e022                	sd	s0,0(sp)
    80000e6c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e6e:	87aa                	mv	a5,a0
    80000e70:	a011                	j	80000e74 <strncpy+0xe>
    80000e72:	8636                	mv	a2,a3
    80000e74:	02c05863          	blez	a2,80000ea4 <strncpy+0x3e>
    80000e78:	fff6069b          	addiw	a3,a2,-1
    80000e7c:	8836                	mv	a6,a3
    80000e7e:	0785                	addi	a5,a5,1
    80000e80:	0005c703          	lbu	a4,0(a1)
    80000e84:	fee78fa3          	sb	a4,-1(a5)
    80000e88:	0585                	addi	a1,a1,1
    80000e8a:	f765                	bnez	a4,80000e72 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e8c:	873e                	mv	a4,a5
    80000e8e:	01005b63          	blez	a6,80000ea4 <strncpy+0x3e>
    80000e92:	9fb1                	addw	a5,a5,a2
    80000e94:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e96:	0705                	addi	a4,a4,1
    80000e98:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e9c:	40e786bb          	subw	a3,a5,a4
    80000ea0:	fed04be3          	bgtz	a3,80000e96 <strncpy+0x30>
  return os;
}
    80000ea4:	60a2                	ld	ra,8(sp)
    80000ea6:	6402                	ld	s0,0(sp)
    80000ea8:	0141                	addi	sp,sp,16
    80000eaa:	8082                	ret

0000000080000eac <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000eac:	1141                	addi	sp,sp,-16
    80000eae:	e406                	sd	ra,8(sp)
    80000eb0:	e022                	sd	s0,0(sp)
    80000eb2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000eb4:	02c05363          	blez	a2,80000eda <safestrcpy+0x2e>
    80000eb8:	fff6069b          	addiw	a3,a2,-1
    80000ebc:	1682                	slli	a3,a3,0x20
    80000ebe:	9281                	srli	a3,a3,0x20
    80000ec0:	96ae                	add	a3,a3,a1
    80000ec2:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ec4:	00d58963          	beq	a1,a3,80000ed6 <safestrcpy+0x2a>
    80000ec8:	0585                	addi	a1,a1,1
    80000eca:	0785                	addi	a5,a5,1
    80000ecc:	fff5c703          	lbu	a4,-1(a1)
    80000ed0:	fee78fa3          	sb	a4,-1(a5)
    80000ed4:	fb65                	bnez	a4,80000ec4 <safestrcpy+0x18>
    ;
  *s = 0;
    80000ed6:	00078023          	sb	zero,0(a5)
  return os;
}
    80000eda:	60a2                	ld	ra,8(sp)
    80000edc:	6402                	ld	s0,0(sp)
    80000ede:	0141                	addi	sp,sp,16
    80000ee0:	8082                	ret

0000000080000ee2 <strlen>:

int
strlen(const char *s)
{
    80000ee2:	1141                	addi	sp,sp,-16
    80000ee4:	e406                	sd	ra,8(sp)
    80000ee6:	e022                	sd	s0,0(sp)
    80000ee8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eea:	00054783          	lbu	a5,0(a0)
    80000eee:	cf91                	beqz	a5,80000f0a <strlen+0x28>
    80000ef0:	00150793          	addi	a5,a0,1
    80000ef4:	86be                	mv	a3,a5
    80000ef6:	0785                	addi	a5,a5,1
    80000ef8:	fff7c703          	lbu	a4,-1(a5)
    80000efc:	ff65                	bnez	a4,80000ef4 <strlen+0x12>
    80000efe:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000f02:	60a2                	ld	ra,8(sp)
    80000f04:	6402                	ld	s0,0(sp)
    80000f06:	0141                	addi	sp,sp,16
    80000f08:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f0a:	4501                	li	a0,0
    80000f0c:	bfdd                	j	80000f02 <strlen+0x20>

0000000080000f0e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f0e:	1141                	addi	sp,sp,-16
    80000f10:	e406                	sd	ra,8(sp)
    80000f12:	e022                	sd	s0,0(sp)
    80000f14:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f16:	00001097          	auipc	ra,0x1
    80000f1a:	c6a080e7          	jalr	-918(ra) # 80001b80 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f1e:	00008717          	auipc	a4,0x8
    80000f22:	a2a70713          	addi	a4,a4,-1494 # 80008948 <started>
  if(cpuid() == 0){
    80000f26:	c139                	beqz	a0,80000f6c <main+0x5e>
    while(started == 0)
    80000f28:	431c                	lw	a5,0(a4)
    80000f2a:	2781                	sext.w	a5,a5
    80000f2c:	dff5                	beqz	a5,80000f28 <main+0x1a>
      ;
    __sync_synchronize();
    80000f2e:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000f32:	00001097          	auipc	ra,0x1
    80000f36:	c4e080e7          	jalr	-946(ra) # 80001b80 <cpuid>
    80000f3a:	85aa                	mv	a1,a0
    80000f3c:	00007517          	auipc	a0,0x7
    80000f40:	15c50513          	addi	a0,a0,348 # 80008098 <etext+0x98>
    80000f44:	fffff097          	auipc	ra,0xfffff
    80000f48:	664080e7          	jalr	1636(ra) # 800005a8 <printf>
    kvminithart();    // turn on paging
    80000f4c:	00000097          	auipc	ra,0x0
    80000f50:	1ac080e7          	jalr	428(ra) # 800010f8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f54:	00002097          	auipc	ra,0x2
    80000f58:	902080e7          	jalr	-1790(ra) # 80002856 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f5c:	00005097          	auipc	ra,0x5
    80000f60:	ff8080e7          	jalr	-8(ra) # 80005f54 <plicinithart>
  }

  scheduler();        
    80000f64:	00001097          	auipc	ra,0x1
    80000f68:	14a080e7          	jalr	330(ra) # 800020ae <scheduler>
    consoleinit();
    80000f6c:	fffff097          	auipc	ra,0xfffff
    80000f70:	508080e7          	jalr	1288(ra) # 80000474 <consoleinit>
    printfinit();
    80000f74:	00000097          	auipc	ra,0x0
    80000f78:	83e080e7          	jalr	-1986(ra) # 800007b2 <printfinit>
    printf("\n");
    80000f7c:	00007517          	auipc	a0,0x7
    80000f80:	09450513          	addi	a0,a0,148 # 80008010 <etext+0x10>
    80000f84:	fffff097          	auipc	ra,0xfffff
    80000f88:	624080e7          	jalr	1572(ra) # 800005a8 <printf>
    printf("xv6 kernel is booting\n");
    80000f8c:	00007517          	auipc	a0,0x7
    80000f90:	0f450513          	addi	a0,a0,244 # 80008080 <etext+0x80>
    80000f94:	fffff097          	auipc	ra,0xfffff
    80000f98:	614080e7          	jalr	1556(ra) # 800005a8 <printf>
    printf("\n");
    80000f9c:	00007517          	auipc	a0,0x7
    80000fa0:	07450513          	addi	a0,a0,116 # 80008010 <etext+0x10>
    80000fa4:	fffff097          	auipc	ra,0xfffff
    80000fa8:	604080e7          	jalr	1540(ra) # 800005a8 <printf>
    kinit();         // physical page allocator
    80000fac:	00000097          	auipc	ra,0x0
    80000fb0:	b70080e7          	jalr	-1168(ra) # 80000b1c <kinit>
    kvminit();       // create kernel page table
    80000fb4:	00000097          	auipc	ra,0x0
    80000fb8:	40c080e7          	jalr	1036(ra) # 800013c0 <kvminit>
    kvminithart();   // turn on paging
    80000fbc:	00000097          	auipc	ra,0x0
    80000fc0:	13c080e7          	jalr	316(ra) # 800010f8 <kvminithart>
    procinit();      // process table
    80000fc4:	00001097          	auipc	ra,0x1
    80000fc8:	afa080e7          	jalr	-1286(ra) # 80001abe <procinit>
    trapinit();      // trap vectors
    80000fcc:	00002097          	auipc	ra,0x2
    80000fd0:	862080e7          	jalr	-1950(ra) # 8000282e <trapinit>
    trapinithart();  // install kernel trap vector
    80000fd4:	00002097          	auipc	ra,0x2
    80000fd8:	882080e7          	jalr	-1918(ra) # 80002856 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fdc:	00005097          	auipc	ra,0x5
    80000fe0:	f5e080e7          	jalr	-162(ra) # 80005f3a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fe4:	00005097          	auipc	ra,0x5
    80000fe8:	f70080e7          	jalr	-144(ra) # 80005f54 <plicinithart>
    binit();         // buffer cache
    80000fec:	00002097          	auipc	ra,0x2
    80000ff0:	fd2080e7          	jalr	-46(ra) # 80002fbe <binit>
    iinit();         // inode table
    80000ff4:	00002097          	auipc	ra,0x2
    80000ff8:	652080e7          	jalr	1618(ra) # 80003646 <iinit>
    fileinit();      // file table
    80000ffc:	00003097          	auipc	ra,0x3
    80001000:	63c080e7          	jalr	1596(ra) # 80004638 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001004:	00005097          	auipc	ra,0x5
    80001008:	058080e7          	jalr	88(ra) # 8000605c <virtio_disk_init>
    userinit();      // first user process
    8000100c:	00001097          	auipc	ra,0x1
    80001010:	e82080e7          	jalr	-382(ra) # 80001e8e <userinit>
    __sync_synchronize();
    80001014:	0330000f          	fence	rw,rw
    started = 1;
    80001018:	4785                	li	a5,1
    8000101a:	00008717          	auipc	a4,0x8
    8000101e:	92f72723          	sw	a5,-1746(a4) # 80008948 <started>
    80001022:	b789                	j	80000f64 <main+0x56>

0000000080001024 <print_pagetable>:
  }
}

// print_pagetable and vmprint written by John Hughes
static void print_pagetable(pagetable_t pagetable, const int level)
{
    80001024:	7159                	addi	sp,sp,-112
    80001026:	f486                	sd	ra,104(sp)
    80001028:	f0a2                	sd	s0,96(sp)
    8000102a:	eca6                	sd	s1,88(sp)
    8000102c:	e8ca                	sd	s2,80(sp)
    8000102e:	e4ce                	sd	s3,72(sp)
    80001030:	e0d2                	sd	s4,64(sp)
    80001032:	fc56                	sd	s5,56(sp)
    80001034:	f85a                	sd	s6,48(sp)
    80001036:	f45e                	sd	s7,40(sp)
    80001038:	f062                	sd	s8,32(sp)
    8000103a:	ec66                	sd	s9,24(sp)
    8000103c:	e86a                	sd	s10,16(sp)
    8000103e:	e46e                	sd	s11,8(sp)
    80001040:	1880                	addi	s0,sp,112
    80001042:	8aae                	mv	s5,a1
  for (int i = 0; i < 512; i++)
    80001044:	89aa                	mv	s3,a0
{
    80001046:	4b01                	li	s6,0
  for (int i = 0; i < 512; i++)
    80001048:	4901                	li	s2,0
      uint64 pa = PTE2PA(pte); // find physical address using PTE2PA

      if (pte & (PTE_R | PTE_W | PTE_X))
      {                                                                                              // check if this PT is a leaf
        uint64 va = i << PGSHIFT;                                                                    // derive virtual address
        printf("%d: leaf pte: va %p-%p -> pa %p-%p\n", i, va, va + PGSIZE - 1, pa, pa + PGSIZE - 1); // print the contents
    8000104a:	6c05                	lui	s8,0x1
    8000104c:	fffc0d13          	addi	s10,s8,-1 # fff <_entry-0x7ffff001>
    80001050:	00007d97          	auipc	s11,0x7
    80001054:	068d8d93          	addi	s11,s11,104 # 800080b8 <etext+0xb8>
        printf(".. ");
    80001058:	00007b97          	auipc	s7,0x7
    8000105c:	058b8b93          	addi	s7,s7,88 # 800080b0 <etext+0xb0>
  for (int i = 0; i < 512; i++)
    80001060:	20000c93          	li	s9,512
    80001064:	a805                	j	80001094 <print_pagetable+0x70>
      }
      else
      {
        printf("%d: pte points to lower-level page table: pte %p -> pa %p\n", i, pte, pa);
    80001066:	86a6                	mv	a3,s1
    80001068:	8652                	mv	a2,s4
    8000106a:	85ca                	mv	a1,s2
    8000106c:	00007517          	auipc	a0,0x7
    80001070:	07450513          	addi	a0,a0,116 # 800080e0 <etext+0xe0>
    80001074:	fffff097          	auipc	ra,0xfffff
    80001078:	534080e7          	jalr	1332(ra) # 800005a8 <printf>
        print_pagetable((pagetable_t)pa, level + 1); // if there is a lower level PT, call function recursively
    8000107c:	001a859b          	addiw	a1,s5,1
    80001080:	8526                	mv	a0,s1
    80001082:	00000097          	auipc	ra,0x0
    80001086:	fa2080e7          	jalr	-94(ra) # 80001024 <print_pagetable>
  for (int i = 0; i < 512; i++)
    8000108a:	2905                	addiw	s2,s2,1
    8000108c:	09a1                	addi	s3,s3,8
    8000108e:	9b62                	add	s6,s6,s8
    80001090:	05990563          	beq	s2,s9,800010da <print_pagetable+0xb6>
    pte_t pte = pagetable[i];
    80001094:	0009ba03          	ld	s4,0(s3)
    if (pte & PTE_V)
    80001098:	001a7793          	andi	a5,s4,1
    8000109c:	d7fd                	beqz	a5,8000108a <print_pagetable+0x66>
      for (int j = 0; j < level; j++)
    8000109e:	01505b63          	blez	s5,800010b4 <print_pagetable+0x90>
    800010a2:	4481                	li	s1,0
        printf(".. ");
    800010a4:	855e                	mv	a0,s7
    800010a6:	fffff097          	auipc	ra,0xfffff
    800010aa:	502080e7          	jalr	1282(ra) # 800005a8 <printf>
      for (int j = 0; j < level; j++)
    800010ae:	2485                	addiw	s1,s1,1
    800010b0:	fe9a9ae3          	bne	s5,s1,800010a4 <print_pagetable+0x80>
      uint64 pa = PTE2PA(pte); // find physical address using PTE2PA
    800010b4:	00aa5493          	srli	s1,s4,0xa
    800010b8:	04b2                	slli	s1,s1,0xc
      if (pte & (PTE_R | PTE_W | PTE_X))
    800010ba:	00ea7793          	andi	a5,s4,14
    800010be:	d7c5                	beqz	a5,80001066 <print_pagetable+0x42>
        printf("%d: leaf pte: va %p-%p -> pa %p-%p\n", i, va, va + PGSIZE - 1, pa, pa + PGSIZE - 1); // print the contents
    800010c0:	01a487b3          	add	a5,s1,s10
    800010c4:	8726                	mv	a4,s1
    800010c6:	01ab06b3          	add	a3,s6,s10
    800010ca:	865a                	mv	a2,s6
    800010cc:	85ca                	mv	a1,s2
    800010ce:	856e                	mv	a0,s11
    800010d0:	fffff097          	auipc	ra,0xfffff
    800010d4:	4d8080e7          	jalr	1240(ra) # 800005a8 <printf>
    800010d8:	bf4d                	j	8000108a <print_pagetable+0x66>
      }
    }
  }
}
    800010da:	70a6                	ld	ra,104(sp)
    800010dc:	7406                	ld	s0,96(sp)
    800010de:	64e6                	ld	s1,88(sp)
    800010e0:	6946                	ld	s2,80(sp)
    800010e2:	69a6                	ld	s3,72(sp)
    800010e4:	6a06                	ld	s4,64(sp)
    800010e6:	7ae2                	ld	s5,56(sp)
    800010e8:	7b42                	ld	s6,48(sp)
    800010ea:	7ba2                	ld	s7,40(sp)
    800010ec:	7c02                	ld	s8,32(sp)
    800010ee:	6ce2                	ld	s9,24(sp)
    800010f0:	6d42                	ld	s10,16(sp)
    800010f2:	6da2                	ld	s11,8(sp)
    800010f4:	6165                	addi	sp,sp,112
    800010f6:	8082                	ret

00000000800010f8 <kvminithart>:
{
    800010f8:	1141                	addi	sp,sp,-16
    800010fa:	e406                	sd	ra,8(sp)
    800010fc:	e022                	sd	s0,0(sp)
    800010fe:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001100:	12000073          	sfence.vma
  w_satp(MAKE_SATP(kernel_pagetable));
    80001104:	00008797          	auipc	a5,0x8
    80001108:	84c7b783          	ld	a5,-1972(a5) # 80008950 <kernel_pagetable>
    8000110c:	83b1                	srli	a5,a5,0xc
    8000110e:	577d                	li	a4,-1
    80001110:	177e                	slli	a4,a4,0x3f
    80001112:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001114:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001118:	12000073          	sfence.vma
}
    8000111c:	60a2                	ld	ra,8(sp)
    8000111e:	6402                	ld	s0,0(sp)
    80001120:	0141                	addi	sp,sp,16
    80001122:	8082                	ret

0000000080001124 <walk>:
{
    80001124:	7139                	addi	sp,sp,-64
    80001126:	fc06                	sd	ra,56(sp)
    80001128:	f822                	sd	s0,48(sp)
    8000112a:	f426                	sd	s1,40(sp)
    8000112c:	f04a                	sd	s2,32(sp)
    8000112e:	ec4e                	sd	s3,24(sp)
    80001130:	e852                	sd	s4,16(sp)
    80001132:	e456                	sd	s5,8(sp)
    80001134:	e05a                	sd	s6,0(sp)
    80001136:	0080                	addi	s0,sp,64
    80001138:	84aa                	mv	s1,a0
    8000113a:	89ae                	mv	s3,a1
    8000113c:	8b32                	mv	s6,a2
  if (va >= MAXVA)
    8000113e:	57fd                	li	a5,-1
    80001140:	83e9                	srli	a5,a5,0x1a
    80001142:	4a79                	li	s4,30
  for (int level = 2; level > 0; level--)
    80001144:	4ab1                	li	s5,12
  if (va >= MAXVA)
    80001146:	04b7e263          	bltu	a5,a1,8000118a <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    8000114a:	0149d933          	srl	s2,s3,s4
    8000114e:	1ff97913          	andi	s2,s2,511
    80001152:	090e                	slli	s2,s2,0x3
    80001154:	9926                	add	s2,s2,s1
    if (*pte & PTE_V)
    80001156:	00093483          	ld	s1,0(s2)
    8000115a:	0014f793          	andi	a5,s1,1
    8000115e:	cf95                	beqz	a5,8000119a <walk+0x76>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001160:	80a9                	srli	s1,s1,0xa
    80001162:	04b2                	slli	s1,s1,0xc
  for (int level = 2; level > 0; level--)
    80001164:	3a5d                	addiw	s4,s4,-9
    80001166:	ff5a12e3          	bne	s4,s5,8000114a <walk+0x26>
  return &pagetable[PX(0, va)];
    8000116a:	00c9d513          	srli	a0,s3,0xc
    8000116e:	1ff57513          	andi	a0,a0,511
    80001172:	050e                	slli	a0,a0,0x3
    80001174:	9526                	add	a0,a0,s1
}
    80001176:	70e2                	ld	ra,56(sp)
    80001178:	7442                	ld	s0,48(sp)
    8000117a:	74a2                	ld	s1,40(sp)
    8000117c:	7902                	ld	s2,32(sp)
    8000117e:	69e2                	ld	s3,24(sp)
    80001180:	6a42                	ld	s4,16(sp)
    80001182:	6aa2                	ld	s5,8(sp)
    80001184:	6b02                	ld	s6,0(sp)
    80001186:	6121                	addi	sp,sp,64
    80001188:	8082                	ret
    panic("walk");
    8000118a:	00007517          	auipc	a0,0x7
    8000118e:	f9650513          	addi	a0,a0,-106 # 80008120 <etext+0x120>
    80001192:	fffff097          	auipc	ra,0xfffff
    80001196:	3cc080e7          	jalr	972(ra) # 8000055e <panic>
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    8000119a:	020b0663          	beqz	s6,800011c6 <walk+0xa2>
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	9ba080e7          	jalr	-1606(ra) # 80000b58 <kalloc>
    800011a6:	84aa                	mv	s1,a0
    800011a8:	d579                	beqz	a0,80001176 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    800011aa:	6605                	lui	a2,0x1
    800011ac:	4581                	li	a1,0
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	ba6080e7          	jalr	-1114(ra) # 80000d54 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800011b6:	00c4d793          	srli	a5,s1,0xc
    800011ba:	07aa                	slli	a5,a5,0xa
    800011bc:	0017e793          	ori	a5,a5,1
    800011c0:	00f93023          	sd	a5,0(s2)
    800011c4:	b745                	j	80001164 <walk+0x40>
        return 0;
    800011c6:	4501                	li	a0,0
    800011c8:	b77d                	j	80001176 <walk+0x52>

00000000800011ca <walkaddr>:
  if (va >= MAXVA)
    800011ca:	57fd                	li	a5,-1
    800011cc:	83e9                	srli	a5,a5,0x1a
    800011ce:	00b7f463          	bgeu	a5,a1,800011d6 <walkaddr+0xc>
    return 0;
    800011d2:	4501                	li	a0,0
}
    800011d4:	8082                	ret
{
    800011d6:	1141                	addi	sp,sp,-16
    800011d8:	e406                	sd	ra,8(sp)
    800011da:	e022                	sd	s0,0(sp)
    800011dc:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800011de:	4601                	li	a2,0
    800011e0:	00000097          	auipc	ra,0x0
    800011e4:	f44080e7          	jalr	-188(ra) # 80001124 <walk>
  if (pte == 0)
    800011e8:	c901                	beqz	a0,800011f8 <walkaddr+0x2e>
  if ((*pte & PTE_V) == 0)
    800011ea:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    800011ec:	0117f693          	andi	a3,a5,17
    800011f0:	4745                	li	a4,17
    return 0;
    800011f2:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    800011f4:	00e68663          	beq	a3,a4,80001200 <walkaddr+0x36>
}
    800011f8:	60a2                	ld	ra,8(sp)
    800011fa:	6402                	ld	s0,0(sp)
    800011fc:	0141                	addi	sp,sp,16
    800011fe:	8082                	ret
  pa = PTE2PA(*pte);
    80001200:	83a9                	srli	a5,a5,0xa
    80001202:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001206:	bfcd                	j	800011f8 <walkaddr+0x2e>

0000000080001208 <mappages>:
{
    80001208:	715d                	addi	sp,sp,-80
    8000120a:	e486                	sd	ra,72(sp)
    8000120c:	e0a2                	sd	s0,64(sp)
    8000120e:	fc26                	sd	s1,56(sp)
    80001210:	f84a                	sd	s2,48(sp)
    80001212:	f44e                	sd	s3,40(sp)
    80001214:	f052                	sd	s4,32(sp)
    80001216:	ec56                	sd	s5,24(sp)
    80001218:	e85a                	sd	s6,16(sp)
    8000121a:	e45e                	sd	s7,8(sp)
    8000121c:	0880                	addi	s0,sp,80
  if (size == 0)
    8000121e:	ca21                	beqz	a2,8000126e <mappages+0x66>
    80001220:	8a2a                	mv	s4,a0
    80001222:	8aba                	mv	s5,a4
  a = PGROUNDDOWN(va);
    80001224:	777d                	lui	a4,0xfffff
    80001226:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000122a:	fff58913          	addi	s2,a1,-1
    8000122e:	9932                	add	s2,s2,a2
    80001230:	00e97933          	and	s2,s2,a4
  a = PGROUNDDOWN(va);
    80001234:	84be                	mv	s1,a5
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001236:	4b05                	li	s6,1
    80001238:	40f689b3          	sub	s3,a3,a5
    a += PGSIZE;
    8000123c:	6b85                	lui	s7,0x1
    if ((pte = walk(pagetable, a, 1)) == 0)
    8000123e:	865a                	mv	a2,s6
    80001240:	85a6                	mv	a1,s1
    80001242:	8552                	mv	a0,s4
    80001244:	00000097          	auipc	ra,0x0
    80001248:	ee0080e7          	jalr	-288(ra) # 80001124 <walk>
    8000124c:	c129                	beqz	a0,8000128e <mappages+0x86>
    if (*pte & PTE_V)
    8000124e:	611c                	ld	a5,0(a0)
    80001250:	8b85                	andi	a5,a5,1
    80001252:	e795                	bnez	a5,8000127e <mappages+0x76>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001254:	013487b3          	add	a5,s1,s3
    80001258:	83b1                	srli	a5,a5,0xc
    8000125a:	07aa                	slli	a5,a5,0xa
    8000125c:	0157e7b3          	or	a5,a5,s5
    80001260:	0017e793          	ori	a5,a5,1
    80001264:	e11c                	sd	a5,0(a0)
    if (a == last)
    80001266:	05248063          	beq	s1,s2,800012a6 <mappages+0x9e>
    a += PGSIZE;
    8000126a:	94de                	add	s1,s1,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    8000126c:	bfc9                	j	8000123e <mappages+0x36>
    panic("mappages: size");
    8000126e:	00007517          	auipc	a0,0x7
    80001272:	eba50513          	addi	a0,a0,-326 # 80008128 <etext+0x128>
    80001276:	fffff097          	auipc	ra,0xfffff
    8000127a:	2e8080e7          	jalr	744(ra) # 8000055e <panic>
      panic("mappages: remap");
    8000127e:	00007517          	auipc	a0,0x7
    80001282:	eba50513          	addi	a0,a0,-326 # 80008138 <etext+0x138>
    80001286:	fffff097          	auipc	ra,0xfffff
    8000128a:	2d8080e7          	jalr	728(ra) # 8000055e <panic>
      return -1;
    8000128e:	557d                	li	a0,-1
}
    80001290:	60a6                	ld	ra,72(sp)
    80001292:	6406                	ld	s0,64(sp)
    80001294:	74e2                	ld	s1,56(sp)
    80001296:	7942                	ld	s2,48(sp)
    80001298:	79a2                	ld	s3,40(sp)
    8000129a:	7a02                	ld	s4,32(sp)
    8000129c:	6ae2                	ld	s5,24(sp)
    8000129e:	6b42                	ld	s6,16(sp)
    800012a0:	6ba2                	ld	s7,8(sp)
    800012a2:	6161                	addi	sp,sp,80
    800012a4:	8082                	ret
  return 0;
    800012a6:	4501                	li	a0,0
    800012a8:	b7e5                	j	80001290 <mappages+0x88>

00000000800012aa <kvmmap>:
{
    800012aa:	1141                	addi	sp,sp,-16
    800012ac:	e406                	sd	ra,8(sp)
    800012ae:	e022                	sd	s0,0(sp)
    800012b0:	0800                	addi	s0,sp,16
    800012b2:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    800012b4:	86b2                	mv	a3,a2
    800012b6:	863e                	mv	a2,a5
    800012b8:	00000097          	auipc	ra,0x0
    800012bc:	f50080e7          	jalr	-176(ra) # 80001208 <mappages>
    800012c0:	e509                	bnez	a0,800012ca <kvmmap+0x20>
}
    800012c2:	60a2                	ld	ra,8(sp)
    800012c4:	6402                	ld	s0,0(sp)
    800012c6:	0141                	addi	sp,sp,16
    800012c8:	8082                	ret
    panic("kvmmap");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e7e50513          	addi	a0,a0,-386 # 80008148 <etext+0x148>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	28c080e7          	jalr	652(ra) # 8000055e <panic>

00000000800012da <kvmmake>:
{
    800012da:	1101                	addi	sp,sp,-32
    800012dc:	ec06                	sd	ra,24(sp)
    800012de:	e822                	sd	s0,16(sp)
    800012e0:	e426                	sd	s1,8(sp)
    800012e2:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    800012e4:	00000097          	auipc	ra,0x0
    800012e8:	874080e7          	jalr	-1932(ra) # 80000b58 <kalloc>
    800012ec:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800012ee:	6605                	lui	a2,0x1
    800012f0:	4581                	li	a1,0
    800012f2:	00000097          	auipc	ra,0x0
    800012f6:	a62080e7          	jalr	-1438(ra) # 80000d54 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012fa:	4719                	li	a4,6
    800012fc:	6685                	lui	a3,0x1
    800012fe:	10000637          	lui	a2,0x10000
    80001302:	85b2                	mv	a1,a2
    80001304:	8526                	mv	a0,s1
    80001306:	00000097          	auipc	ra,0x0
    8000130a:	fa4080e7          	jalr	-92(ra) # 800012aa <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000130e:	4719                	li	a4,6
    80001310:	6685                	lui	a3,0x1
    80001312:	10001637          	lui	a2,0x10001
    80001316:	85b2                	mv	a1,a2
    80001318:	8526                	mv	a0,s1
    8000131a:	00000097          	auipc	ra,0x0
    8000131e:	f90080e7          	jalr	-112(ra) # 800012aa <kvmmap>
  kvmmap(kpgtbl, GOLDFISH, GOLDFISH, PGSIZE, PTE_R | PTE_W);
    80001322:	4719                	li	a4,6
    80001324:	6685                	lui	a3,0x1
    80001326:	00101637          	lui	a2,0x101
    8000132a:	85b2                	mv	a1,a2
    8000132c:	8526                	mv	a0,s1
    8000132e:	00000097          	auipc	ra,0x0
    80001332:	f7c080e7          	jalr	-132(ra) # 800012aa <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001336:	4719                	li	a4,6
    80001338:	004006b7          	lui	a3,0x400
    8000133c:	0c000637          	lui	a2,0xc000
    80001340:	85b2                	mv	a1,a2
    80001342:	8526                	mv	a0,s1
    80001344:	00000097          	auipc	ra,0x0
    80001348:	f66080e7          	jalr	-154(ra) # 800012aa <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    8000134c:	4729                	li	a4,10
    8000134e:	80007697          	auipc	a3,0x80007
    80001352:	cb268693          	addi	a3,a3,-846 # 8000 <_entry-0x7fff8000>
    80001356:	4605                	li	a2,1
    80001358:	067e                	slli	a2,a2,0x1f
    8000135a:	85b2                	mv	a1,a2
    8000135c:	8526                	mv	a0,s1
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	f4c080e7          	jalr	-180(ra) # 800012aa <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    80001366:	4719                	li	a4,6
    80001368:	00007697          	auipc	a3,0x7
    8000136c:	c9868693          	addi	a3,a3,-872 # 80008000 <etext>
    80001370:	47c5                	li	a5,17
    80001372:	07ee                	slli	a5,a5,0x1b
    80001374:	40d786b3          	sub	a3,a5,a3
    80001378:	00007617          	auipc	a2,0x7
    8000137c:	c8860613          	addi	a2,a2,-888 # 80008000 <etext>
    80001380:	85b2                	mv	a1,a2
    80001382:	8526                	mv	a0,s1
    80001384:	00000097          	auipc	ra,0x0
    80001388:	f26080e7          	jalr	-218(ra) # 800012aa <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000138c:	4729                	li	a4,10
    8000138e:	6685                	lui	a3,0x1
    80001390:	00006617          	auipc	a2,0x6
    80001394:	c7060613          	addi	a2,a2,-912 # 80007000 <_trampoline>
    80001398:	040005b7          	lui	a1,0x4000
    8000139c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000139e:	05b2                	slli	a1,a1,0xc
    800013a0:	8526                	mv	a0,s1
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	f08080e7          	jalr	-248(ra) # 800012aa <kvmmap>
  proc_mapstacks(kpgtbl);
    800013aa:	8526                	mv	a0,s1
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	662080e7          	jalr	1634(ra) # 80001a0e <proc_mapstacks>
}
    800013b4:	8526                	mv	a0,s1
    800013b6:	60e2                	ld	ra,24(sp)
    800013b8:	6442                	ld	s0,16(sp)
    800013ba:	64a2                	ld	s1,8(sp)
    800013bc:	6105                	addi	sp,sp,32
    800013be:	8082                	ret

00000000800013c0 <kvminit>:
{
    800013c0:	1141                	addi	sp,sp,-16
    800013c2:	e406                	sd	ra,8(sp)
    800013c4:	e022                	sd	s0,0(sp)
    800013c6:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800013c8:	00000097          	auipc	ra,0x0
    800013cc:	f12080e7          	jalr	-238(ra) # 800012da <kvmmake>
    800013d0:	00007797          	auipc	a5,0x7
    800013d4:	58a7b023          	sd	a0,1408(a5) # 80008950 <kernel_pagetable>
}
    800013d8:	60a2                	ld	ra,8(sp)
    800013da:	6402                	ld	s0,0(sp)
    800013dc:	0141                	addi	sp,sp,16
    800013de:	8082                	ret

00000000800013e0 <uvmunmap>:
{
    800013e0:	715d                	addi	sp,sp,-80
    800013e2:	e486                	sd	ra,72(sp)
    800013e4:	e0a2                	sd	s0,64(sp)
    800013e6:	0880                	addi	s0,sp,80
  if ((va % PGSIZE) != 0)
    800013e8:	03459793          	slli	a5,a1,0x34
    800013ec:	e39d                	bnez	a5,80001412 <uvmunmap+0x32>
    800013ee:	f84a                	sd	s2,48(sp)
    800013f0:	f44e                	sd	s3,40(sp)
    800013f2:	f052                	sd	s4,32(sp)
    800013f4:	ec56                	sd	s5,24(sp)
    800013f6:	e85a                	sd	s6,16(sp)
    800013f8:	e45e                	sd	s7,8(sp)
    800013fa:	8a2a                	mv	s4,a0
    800013fc:	892e                	mv	s2,a1
    800013fe:	8ab6                	mv	s5,a3
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001400:	0632                	slli	a2,a2,0xc
    80001402:	00b609b3          	add	s3,a2,a1
    if (PTE_FLAGS(*pte) == PTE_V)
    80001406:	4b85                	li	s7,1
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001408:	6b05                	lui	s6,0x1
    8000140a:	0935fb63          	bgeu	a1,s3,800014a0 <uvmunmap+0xc0>
    8000140e:	fc26                	sd	s1,56(sp)
    80001410:	a8a9                	j	8000146a <uvmunmap+0x8a>
    80001412:	fc26                	sd	s1,56(sp)
    80001414:	f84a                	sd	s2,48(sp)
    80001416:	f44e                	sd	s3,40(sp)
    80001418:	f052                	sd	s4,32(sp)
    8000141a:	ec56                	sd	s5,24(sp)
    8000141c:	e85a                	sd	s6,16(sp)
    8000141e:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80001420:	00007517          	auipc	a0,0x7
    80001424:	d3050513          	addi	a0,a0,-720 # 80008150 <etext+0x150>
    80001428:	fffff097          	auipc	ra,0xfffff
    8000142c:	136080e7          	jalr	310(ra) # 8000055e <panic>
      panic("uvmunmap: walk");
    80001430:	00007517          	auipc	a0,0x7
    80001434:	d3850513          	addi	a0,a0,-712 # 80008168 <etext+0x168>
    80001438:	fffff097          	auipc	ra,0xfffff
    8000143c:	126080e7          	jalr	294(ra) # 8000055e <panic>
      panic("uvmunmap: not mapped");
    80001440:	00007517          	auipc	a0,0x7
    80001444:	d3850513          	addi	a0,a0,-712 # 80008178 <etext+0x178>
    80001448:	fffff097          	auipc	ra,0xfffff
    8000144c:	116080e7          	jalr	278(ra) # 8000055e <panic>
      panic("uvmunmap: not a leaf");
    80001450:	00007517          	auipc	a0,0x7
    80001454:	d4050513          	addi	a0,a0,-704 # 80008190 <etext+0x190>
    80001458:	fffff097          	auipc	ra,0xfffff
    8000145c:	106080e7          	jalr	262(ra) # 8000055e <panic>
    *pte = 0;
    80001460:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001464:	995a                	add	s2,s2,s6
    80001466:	03397c63          	bgeu	s2,s3,8000149e <uvmunmap+0xbe>
    if ((pte = walk(pagetable, a, 0)) == 0)
    8000146a:	4601                	li	a2,0
    8000146c:	85ca                	mv	a1,s2
    8000146e:	8552                	mv	a0,s4
    80001470:	00000097          	auipc	ra,0x0
    80001474:	cb4080e7          	jalr	-844(ra) # 80001124 <walk>
    80001478:	84aa                	mv	s1,a0
    8000147a:	d95d                	beqz	a0,80001430 <uvmunmap+0x50>
    if ((*pte & PTE_V) == 0)
    8000147c:	6108                	ld	a0,0(a0)
    8000147e:	00157793          	andi	a5,a0,1
    80001482:	dfdd                	beqz	a5,80001440 <uvmunmap+0x60>
    if (PTE_FLAGS(*pte) == PTE_V)
    80001484:	3ff57793          	andi	a5,a0,1023
    80001488:	fd7784e3          	beq	a5,s7,80001450 <uvmunmap+0x70>
    if (do_free)
    8000148c:	fc0a8ae3          	beqz	s5,80001460 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    80001490:	8129                	srli	a0,a0,0xa
      kfree((void *)pa);
    80001492:	0532                	slli	a0,a0,0xc
    80001494:	fffff097          	auipc	ra,0xfffff
    80001498:	5c0080e7          	jalr	1472(ra) # 80000a54 <kfree>
    8000149c:	b7d1                	j	80001460 <uvmunmap+0x80>
    8000149e:	74e2                	ld	s1,56(sp)
    800014a0:	7942                	ld	s2,48(sp)
    800014a2:	79a2                	ld	s3,40(sp)
    800014a4:	7a02                	ld	s4,32(sp)
    800014a6:	6ae2                	ld	s5,24(sp)
    800014a8:	6b42                	ld	s6,16(sp)
    800014aa:	6ba2                	ld	s7,8(sp)
}
    800014ac:	60a6                	ld	ra,72(sp)
    800014ae:	6406                	ld	s0,64(sp)
    800014b0:	6161                	addi	sp,sp,80
    800014b2:	8082                	ret

00000000800014b4 <uvmcreate>:
{
    800014b4:	1101                	addi	sp,sp,-32
    800014b6:	ec06                	sd	ra,24(sp)
    800014b8:	e822                	sd	s0,16(sp)
    800014ba:	e426                	sd	s1,8(sp)
    800014bc:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t)kalloc();
    800014be:	fffff097          	auipc	ra,0xfffff
    800014c2:	69a080e7          	jalr	1690(ra) # 80000b58 <kalloc>
    800014c6:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800014c8:	c519                	beqz	a0,800014d6 <uvmcreate+0x22>
  memset(pagetable, 0, PGSIZE);
    800014ca:	6605                	lui	a2,0x1
    800014cc:	4581                	li	a1,0
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	886080e7          	jalr	-1914(ra) # 80000d54 <memset>
}
    800014d6:	8526                	mv	a0,s1
    800014d8:	60e2                	ld	ra,24(sp)
    800014da:	6442                	ld	s0,16(sp)
    800014dc:	64a2                	ld	s1,8(sp)
    800014de:	6105                	addi	sp,sp,32
    800014e0:	8082                	ret

00000000800014e2 <uvmfirst>:
{
    800014e2:	7179                	addi	sp,sp,-48
    800014e4:	f406                	sd	ra,40(sp)
    800014e6:	f022                	sd	s0,32(sp)
    800014e8:	ec26                	sd	s1,24(sp)
    800014ea:	e84a                	sd	s2,16(sp)
    800014ec:	e44e                	sd	s3,8(sp)
    800014ee:	e052                	sd	s4,0(sp)
    800014f0:	1800                	addi	s0,sp,48
  if (sz >= PGSIZE)
    800014f2:	6785                	lui	a5,0x1
    800014f4:	04f67863          	bgeu	a2,a5,80001544 <uvmfirst+0x62>
    800014f8:	89aa                	mv	s3,a0
    800014fa:	8a2e                	mv	s4,a1
    800014fc:	84b2                	mv	s1,a2
  mem = kalloc();
    800014fe:	fffff097          	auipc	ra,0xfffff
    80001502:	65a080e7          	jalr	1626(ra) # 80000b58 <kalloc>
    80001506:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001508:	6605                	lui	a2,0x1
    8000150a:	4581                	li	a1,0
    8000150c:	00000097          	auipc	ra,0x0
    80001510:	848080e7          	jalr	-1976(ra) # 80000d54 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    80001514:	4779                	li	a4,30
    80001516:	86ca                	mv	a3,s2
    80001518:	6605                	lui	a2,0x1
    8000151a:	4581                	li	a1,0
    8000151c:	854e                	mv	a0,s3
    8000151e:	00000097          	auipc	ra,0x0
    80001522:	cea080e7          	jalr	-790(ra) # 80001208 <mappages>
  memmove(mem, src, sz);
    80001526:	8626                	mv	a2,s1
    80001528:	85d2                	mv	a1,s4
    8000152a:	854a                	mv	a0,s2
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	888080e7          	jalr	-1912(ra) # 80000db4 <memmove>
}
    80001534:	70a2                	ld	ra,40(sp)
    80001536:	7402                	ld	s0,32(sp)
    80001538:	64e2                	ld	s1,24(sp)
    8000153a:	6942                	ld	s2,16(sp)
    8000153c:	69a2                	ld	s3,8(sp)
    8000153e:	6a02                	ld	s4,0(sp)
    80001540:	6145                	addi	sp,sp,48
    80001542:	8082                	ret
    panic("uvmfirst: more than a page");
    80001544:	00007517          	auipc	a0,0x7
    80001548:	c6450513          	addi	a0,a0,-924 # 800081a8 <etext+0x1a8>
    8000154c:	fffff097          	auipc	ra,0xfffff
    80001550:	012080e7          	jalr	18(ra) # 8000055e <panic>

0000000080001554 <uvmdealloc>:
{
    80001554:	1101                	addi	sp,sp,-32
    80001556:	ec06                	sd	ra,24(sp)
    80001558:	e822                	sd	s0,16(sp)
    8000155a:	e426                	sd	s1,8(sp)
    8000155c:	1000                	addi	s0,sp,32
    return oldsz;
    8000155e:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    80001560:	00b67d63          	bgeu	a2,a1,8000157a <uvmdealloc+0x26>
    80001564:	84b2                	mv	s1,a2
  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    80001566:	6785                	lui	a5,0x1
    80001568:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000156a:	00f60733          	add	a4,a2,a5
    8000156e:	76fd                	lui	a3,0xfffff
    80001570:	8f75                	and	a4,a4,a3
    80001572:	97ae                	add	a5,a5,a1
    80001574:	8ff5                	and	a5,a5,a3
    80001576:	00f76863          	bltu	a4,a5,80001586 <uvmdealloc+0x32>
}
    8000157a:	8526                	mv	a0,s1
    8000157c:	60e2                	ld	ra,24(sp)
    8000157e:	6442                	ld	s0,16(sp)
    80001580:	64a2                	ld	s1,8(sp)
    80001582:	6105                	addi	sp,sp,32
    80001584:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001586:	8f99                	sub	a5,a5,a4
    80001588:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000158a:	4685                	li	a3,1
    8000158c:	0007861b          	sext.w	a2,a5
    80001590:	85ba                	mv	a1,a4
    80001592:	00000097          	auipc	ra,0x0
    80001596:	e4e080e7          	jalr	-434(ra) # 800013e0 <uvmunmap>
    8000159a:	b7c5                	j	8000157a <uvmdealloc+0x26>

000000008000159c <uvmalloc>:
  if (newsz < oldsz)
    8000159c:	0ab66d63          	bltu	a2,a1,80001656 <uvmalloc+0xba>
{
    800015a0:	715d                	addi	sp,sp,-80
    800015a2:	e486                	sd	ra,72(sp)
    800015a4:	e0a2                	sd	s0,64(sp)
    800015a6:	f84a                	sd	s2,48(sp)
    800015a8:	f052                	sd	s4,32(sp)
    800015aa:	ec56                	sd	s5,24(sp)
    800015ac:	e45e                	sd	s7,8(sp)
    800015ae:	0880                	addi	s0,sp,80
    800015b0:	8aaa                	mv	s5,a0
    800015b2:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800015b4:	6785                	lui	a5,0x1
    800015b6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015b8:	95be                	add	a1,a1,a5
    800015ba:	77fd                	lui	a5,0xfffff
    800015bc:	00f5f933          	and	s2,a1,a5
    800015c0:	8bca                	mv	s7,s2
  for (a = oldsz; a < newsz; a += PGSIZE)
    800015c2:	08c97c63          	bgeu	s2,a2,8000165a <uvmalloc+0xbe>
    800015c6:	fc26                	sd	s1,56(sp)
    800015c8:	f44e                	sd	s3,40(sp)
    800015ca:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    800015cc:	6985                	lui	s3,0x1
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    800015ce:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800015d2:	fffff097          	auipc	ra,0xfffff
    800015d6:	586080e7          	jalr	1414(ra) # 80000b58 <kalloc>
    800015da:	84aa                	mv	s1,a0
    if (mem == 0)
    800015dc:	c90d                	beqz	a0,8000160e <uvmalloc+0x72>
    memset(mem, 0, PGSIZE);
    800015de:	864e                	mv	a2,s3
    800015e0:	4581                	li	a1,0
    800015e2:	fffff097          	auipc	ra,0xfffff
    800015e6:	772080e7          	jalr	1906(ra) # 80000d54 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    800015ea:	875a                	mv	a4,s6
    800015ec:	86a6                	mv	a3,s1
    800015ee:	864e                	mv	a2,s3
    800015f0:	85ca                	mv	a1,s2
    800015f2:	8556                	mv	a0,s5
    800015f4:	00000097          	auipc	ra,0x0
    800015f8:	c14080e7          	jalr	-1004(ra) # 80001208 <mappages>
    800015fc:	ed05                	bnez	a0,80001634 <uvmalloc+0x98>
  for (a = oldsz; a < newsz; a += PGSIZE)
    800015fe:	994e                	add	s2,s2,s3
    80001600:	fd4969e3          	bltu	s2,s4,800015d2 <uvmalloc+0x36>
  return newsz;
    80001604:	8552                	mv	a0,s4
    80001606:	74e2                	ld	s1,56(sp)
    80001608:	79a2                	ld	s3,40(sp)
    8000160a:	6b42                	ld	s6,16(sp)
    8000160c:	a821                	j	80001624 <uvmalloc+0x88>
      uvmdealloc(pagetable, a, oldsz);
    8000160e:	865e                	mv	a2,s7
    80001610:	85ca                	mv	a1,s2
    80001612:	8556                	mv	a0,s5
    80001614:	00000097          	auipc	ra,0x0
    80001618:	f40080e7          	jalr	-192(ra) # 80001554 <uvmdealloc>
      return 0;
    8000161c:	4501                	li	a0,0
    8000161e:	74e2                	ld	s1,56(sp)
    80001620:	79a2                	ld	s3,40(sp)
    80001622:	6b42                	ld	s6,16(sp)
}
    80001624:	60a6                	ld	ra,72(sp)
    80001626:	6406                	ld	s0,64(sp)
    80001628:	7942                	ld	s2,48(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6ba2                	ld	s7,8(sp)
    80001630:	6161                	addi	sp,sp,80
    80001632:	8082                	ret
      kfree(mem);
    80001634:	8526                	mv	a0,s1
    80001636:	fffff097          	auipc	ra,0xfffff
    8000163a:	41e080e7          	jalr	1054(ra) # 80000a54 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000163e:	865e                	mv	a2,s7
    80001640:	85ca                	mv	a1,s2
    80001642:	8556                	mv	a0,s5
    80001644:	00000097          	auipc	ra,0x0
    80001648:	f10080e7          	jalr	-240(ra) # 80001554 <uvmdealloc>
      return 0;
    8000164c:	4501                	li	a0,0
    8000164e:	74e2                	ld	s1,56(sp)
    80001650:	79a2                	ld	s3,40(sp)
    80001652:	6b42                	ld	s6,16(sp)
    80001654:	bfc1                	j	80001624 <uvmalloc+0x88>
    return oldsz;
    80001656:	852e                	mv	a0,a1
}
    80001658:	8082                	ret
  return newsz;
    8000165a:	8532                	mv	a0,a2
    8000165c:	b7e1                	j	80001624 <uvmalloc+0x88>

000000008000165e <freewalk>:
{
    8000165e:	7179                	addi	sp,sp,-48
    80001660:	f406                	sd	ra,40(sp)
    80001662:	f022                	sd	s0,32(sp)
    80001664:	ec26                	sd	s1,24(sp)
    80001666:	e84a                	sd	s2,16(sp)
    80001668:	e44e                	sd	s3,8(sp)
    8000166a:	1800                	addi	s0,sp,48
    8000166c:	89aa                	mv	s3,a0
  for (int i = 0; i < 512; i++)
    8000166e:	84aa                	mv	s1,a0
    80001670:	6905                	lui	s2,0x1
    80001672:	992a                	add	s2,s2,a0
    80001674:	a821                	j	8000168c <freewalk+0x2e>
      panic("freewalk: leaf");
    80001676:	00007517          	auipc	a0,0x7
    8000167a:	b5250513          	addi	a0,a0,-1198 # 800081c8 <etext+0x1c8>
    8000167e:	fffff097          	auipc	ra,0xfffff
    80001682:	ee0080e7          	jalr	-288(ra) # 8000055e <panic>
  for (int i = 0; i < 512; i++)
    80001686:	04a1                	addi	s1,s1,8
    80001688:	03248363          	beq	s1,s2,800016ae <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000168c:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    8000168e:	0017f713          	andi	a4,a5,1
    80001692:	db75                	beqz	a4,80001686 <freewalk+0x28>
    80001694:	00e7f713          	andi	a4,a5,14
    80001698:	ff79                	bnez	a4,80001676 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    8000169a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000169c:	00c79513          	slli	a0,a5,0xc
    800016a0:	00000097          	auipc	ra,0x0
    800016a4:	fbe080e7          	jalr	-66(ra) # 8000165e <freewalk>
      pagetable[i] = 0;
    800016a8:	0004b023          	sd	zero,0(s1)
    {
    800016ac:	bfe9                	j	80001686 <freewalk+0x28>
  kfree((void *)pagetable);
    800016ae:	854e                	mv	a0,s3
    800016b0:	fffff097          	auipc	ra,0xfffff
    800016b4:	3a4080e7          	jalr	932(ra) # 80000a54 <kfree>
}
    800016b8:	70a2                	ld	ra,40(sp)
    800016ba:	7402                	ld	s0,32(sp)
    800016bc:	64e2                	ld	s1,24(sp)
    800016be:	6942                	ld	s2,16(sp)
    800016c0:	69a2                	ld	s3,8(sp)
    800016c2:	6145                	addi	sp,sp,48
    800016c4:	8082                	ret

00000000800016c6 <uvmfree>:
{
    800016c6:	1101                	addi	sp,sp,-32
    800016c8:	ec06                	sd	ra,24(sp)
    800016ca:	e822                	sd	s0,16(sp)
    800016cc:	e426                	sd	s1,8(sp)
    800016ce:	1000                	addi	s0,sp,32
    800016d0:	84aa                	mv	s1,a0
  if (sz > 0)
    800016d2:	e999                	bnez	a1,800016e8 <uvmfree+0x22>
  freewalk(pagetable);
    800016d4:	8526                	mv	a0,s1
    800016d6:	00000097          	auipc	ra,0x0
    800016da:	f88080e7          	jalr	-120(ra) # 8000165e <freewalk>
}
    800016de:	60e2                	ld	ra,24(sp)
    800016e0:	6442                	ld	s0,16(sp)
    800016e2:	64a2                	ld	s1,8(sp)
    800016e4:	6105                	addi	sp,sp,32
    800016e6:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    800016e8:	6785                	lui	a5,0x1
    800016ea:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800016ec:	95be                	add	a1,a1,a5
    800016ee:	4685                	li	a3,1
    800016f0:	00c5d613          	srli	a2,a1,0xc
    800016f4:	4581                	li	a1,0
    800016f6:	00000097          	auipc	ra,0x0
    800016fa:	cea080e7          	jalr	-790(ra) # 800013e0 <uvmunmap>
    800016fe:	bfd9                	j	800016d4 <uvmfree+0xe>

0000000080001700 <uvmcopy>:
  for (i = 0; i < sz; i += PGSIZE)
    80001700:	c669                	beqz	a2,800017ca <uvmcopy+0xca>
{
    80001702:	715d                	addi	sp,sp,-80
    80001704:	e486                	sd	ra,72(sp)
    80001706:	e0a2                	sd	s0,64(sp)
    80001708:	fc26                	sd	s1,56(sp)
    8000170a:	f84a                	sd	s2,48(sp)
    8000170c:	f44e                	sd	s3,40(sp)
    8000170e:	f052                	sd	s4,32(sp)
    80001710:	ec56                	sd	s5,24(sp)
    80001712:	e85a                	sd	s6,16(sp)
    80001714:	e45e                	sd	s7,8(sp)
    80001716:	0880                	addi	s0,sp,80
    80001718:	8b2a                	mv	s6,a0
    8000171a:	8aae                	mv	s5,a1
    8000171c:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += PGSIZE)
    8000171e:	4901                	li	s2,0
    memmove(mem, (char *)pa, PGSIZE);
    80001720:	6985                	lui	s3,0x1
    if ((pte = walk(old, i, 0)) == 0)
    80001722:	4601                	li	a2,0
    80001724:	85ca                	mv	a1,s2
    80001726:	855a                	mv	a0,s6
    80001728:	00000097          	auipc	ra,0x0
    8000172c:	9fc080e7          	jalr	-1540(ra) # 80001124 <walk>
    80001730:	c139                	beqz	a0,80001776 <uvmcopy+0x76>
    if ((*pte & PTE_V) == 0)
    80001732:	00053b83          	ld	s7,0(a0)
    80001736:	001bf793          	andi	a5,s7,1
    8000173a:	c7b1                	beqz	a5,80001786 <uvmcopy+0x86>
    if ((mem = kalloc()) == 0)
    8000173c:	fffff097          	auipc	ra,0xfffff
    80001740:	41c080e7          	jalr	1052(ra) # 80000b58 <kalloc>
    80001744:	84aa                	mv	s1,a0
    80001746:	cd29                	beqz	a0,800017a0 <uvmcopy+0xa0>
    pa = PTE2PA(*pte);
    80001748:	00abd593          	srli	a1,s7,0xa
    memmove(mem, (char *)pa, PGSIZE);
    8000174c:	864e                	mv	a2,s3
    8000174e:	05b2                	slli	a1,a1,0xc
    80001750:	fffff097          	auipc	ra,0xfffff
    80001754:	664080e7          	jalr	1636(ra) # 80000db4 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    80001758:	3ffbf713          	andi	a4,s7,1023
    8000175c:	86a6                	mv	a3,s1
    8000175e:	864e                	mv	a2,s3
    80001760:	85ca                	mv	a1,s2
    80001762:	8556                	mv	a0,s5
    80001764:	00000097          	auipc	ra,0x0
    80001768:	aa4080e7          	jalr	-1372(ra) # 80001208 <mappages>
    8000176c:	e50d                	bnez	a0,80001796 <uvmcopy+0x96>
  for (i = 0; i < sz; i += PGSIZE)
    8000176e:	994e                	add	s2,s2,s3
    80001770:	fb4969e3          	bltu	s2,s4,80001722 <uvmcopy+0x22>
    80001774:	a081                	j	800017b4 <uvmcopy+0xb4>
      panic("uvmcopy: pte should exist");
    80001776:	00007517          	auipc	a0,0x7
    8000177a:	a6250513          	addi	a0,a0,-1438 # 800081d8 <etext+0x1d8>
    8000177e:	fffff097          	auipc	ra,0xfffff
    80001782:	de0080e7          	jalr	-544(ra) # 8000055e <panic>
      panic("uvmcopy: page not present");
    80001786:	00007517          	auipc	a0,0x7
    8000178a:	a7250513          	addi	a0,a0,-1422 # 800081f8 <etext+0x1f8>
    8000178e:	fffff097          	auipc	ra,0xfffff
    80001792:	dd0080e7          	jalr	-560(ra) # 8000055e <panic>
      kfree(mem);
    80001796:	8526                	mv	a0,s1
    80001798:	fffff097          	auipc	ra,0xfffff
    8000179c:	2bc080e7          	jalr	700(ra) # 80000a54 <kfree>
  uvmunmap(new, 0, i / PGSIZE, 1);
    800017a0:	4685                	li	a3,1
    800017a2:	00c95613          	srli	a2,s2,0xc
    800017a6:	4581                	li	a1,0
    800017a8:	8556                	mv	a0,s5
    800017aa:	00000097          	auipc	ra,0x0
    800017ae:	c36080e7          	jalr	-970(ra) # 800013e0 <uvmunmap>
  return -1;
    800017b2:	557d                	li	a0,-1
}
    800017b4:	60a6                	ld	ra,72(sp)
    800017b6:	6406                	ld	s0,64(sp)
    800017b8:	74e2                	ld	s1,56(sp)
    800017ba:	7942                	ld	s2,48(sp)
    800017bc:	79a2                	ld	s3,40(sp)
    800017be:	7a02                	ld	s4,32(sp)
    800017c0:	6ae2                	ld	s5,24(sp)
    800017c2:	6b42                	ld	s6,16(sp)
    800017c4:	6ba2                	ld	s7,8(sp)
    800017c6:	6161                	addi	sp,sp,80
    800017c8:	8082                	ret
  return 0;
    800017ca:	4501                	li	a0,0
}
    800017cc:	8082                	ret

00000000800017ce <uvmclear>:
{
    800017ce:	1141                	addi	sp,sp,-16
    800017d0:	e406                	sd	ra,8(sp)
    800017d2:	e022                	sd	s0,0(sp)
    800017d4:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800017d6:	4601                	li	a2,0
    800017d8:	00000097          	auipc	ra,0x0
    800017dc:	94c080e7          	jalr	-1716(ra) # 80001124 <walk>
  if (pte == 0)
    800017e0:	c901                	beqz	a0,800017f0 <uvmclear+0x22>
  *pte &= ~PTE_U;
    800017e2:	611c                	ld	a5,0(a0)
    800017e4:	9bbd                	andi	a5,a5,-17
    800017e6:	e11c                	sd	a5,0(a0)
}
    800017e8:	60a2                	ld	ra,8(sp)
    800017ea:	6402                	ld	s0,0(sp)
    800017ec:	0141                	addi	sp,sp,16
    800017ee:	8082                	ret
    panic("uvmclear");
    800017f0:	00007517          	auipc	a0,0x7
    800017f4:	a2850513          	addi	a0,a0,-1496 # 80008218 <etext+0x218>
    800017f8:	fffff097          	auipc	ra,0xfffff
    800017fc:	d66080e7          	jalr	-666(ra) # 8000055e <panic>

0000000080001800 <copyout>:
  while (len > 0)
    80001800:	c6bd                	beqz	a3,8000186e <copyout+0x6e>
{
    80001802:	715d                	addi	sp,sp,-80
    80001804:	e486                	sd	ra,72(sp)
    80001806:	e0a2                	sd	s0,64(sp)
    80001808:	fc26                	sd	s1,56(sp)
    8000180a:	f84a                	sd	s2,48(sp)
    8000180c:	f44e                	sd	s3,40(sp)
    8000180e:	f052                	sd	s4,32(sp)
    80001810:	ec56                	sd	s5,24(sp)
    80001812:	e85a                	sd	s6,16(sp)
    80001814:	e45e                	sd	s7,8(sp)
    80001816:	e062                	sd	s8,0(sp)
    80001818:	0880                	addi	s0,sp,80
    8000181a:	8b2a                	mv	s6,a0
    8000181c:	8c2e                	mv	s8,a1
    8000181e:	8a32                	mv	s4,a2
    80001820:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001822:	7bfd                	lui	s7,0xfffff
    n = PGSIZE - (dstva - va0);
    80001824:	6a85                	lui	s5,0x1
    80001826:	a015                	j	8000184a <copyout+0x4a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001828:	9562                	add	a0,a0,s8
    8000182a:	0004861b          	sext.w	a2,s1
    8000182e:	85d2                	mv	a1,s4
    80001830:	41250533          	sub	a0,a0,s2
    80001834:	fffff097          	auipc	ra,0xfffff
    80001838:	580080e7          	jalr	1408(ra) # 80000db4 <memmove>
    len -= n;
    8000183c:	409989b3          	sub	s3,s3,s1
    src += n;
    80001840:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001842:	01590c33          	add	s8,s2,s5
  while (len > 0)
    80001846:	02098263          	beqz	s3,8000186a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000184a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000184e:	85ca                	mv	a1,s2
    80001850:	855a                	mv	a0,s6
    80001852:	00000097          	auipc	ra,0x0
    80001856:	978080e7          	jalr	-1672(ra) # 800011ca <walkaddr>
    if (pa0 == 0)
    8000185a:	cd01                	beqz	a0,80001872 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000185c:	418904b3          	sub	s1,s2,s8
    80001860:	94d6                	add	s1,s1,s5
    if (n > len)
    80001862:	fc99f3e3          	bgeu	s3,s1,80001828 <copyout+0x28>
    80001866:	84ce                	mv	s1,s3
    80001868:	b7c1                	j	80001828 <copyout+0x28>
  return 0;
    8000186a:	4501                	li	a0,0
    8000186c:	a021                	j	80001874 <copyout+0x74>
    8000186e:	4501                	li	a0,0
}
    80001870:	8082                	ret
      return -1;
    80001872:	557d                	li	a0,-1
}
    80001874:	60a6                	ld	ra,72(sp)
    80001876:	6406                	ld	s0,64(sp)
    80001878:	74e2                	ld	s1,56(sp)
    8000187a:	7942                	ld	s2,48(sp)
    8000187c:	79a2                	ld	s3,40(sp)
    8000187e:	7a02                	ld	s4,32(sp)
    80001880:	6ae2                	ld	s5,24(sp)
    80001882:	6b42                	ld	s6,16(sp)
    80001884:	6ba2                	ld	s7,8(sp)
    80001886:	6c02                	ld	s8,0(sp)
    80001888:	6161                	addi	sp,sp,80
    8000188a:	8082                	ret

000000008000188c <copyin>:
  while (len > 0)
    8000188c:	caa5                	beqz	a3,800018fc <copyin+0x70>
{
    8000188e:	715d                	addi	sp,sp,-80
    80001890:	e486                	sd	ra,72(sp)
    80001892:	e0a2                	sd	s0,64(sp)
    80001894:	fc26                	sd	s1,56(sp)
    80001896:	f84a                	sd	s2,48(sp)
    80001898:	f44e                	sd	s3,40(sp)
    8000189a:	f052                	sd	s4,32(sp)
    8000189c:	ec56                	sd	s5,24(sp)
    8000189e:	e85a                	sd	s6,16(sp)
    800018a0:	e45e                	sd	s7,8(sp)
    800018a2:	e062                	sd	s8,0(sp)
    800018a4:	0880                	addi	s0,sp,80
    800018a6:	8b2a                	mv	s6,a0
    800018a8:	8a2e                	mv	s4,a1
    800018aa:	8c32                	mv	s8,a2
    800018ac:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800018ae:	7bfd                	lui	s7,0xfffff
    n = PGSIZE - (srcva - va0);
    800018b0:	6a85                	lui	s5,0x1
    800018b2:	a01d                	j	800018d8 <copyin+0x4c>
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018b4:	018505b3          	add	a1,a0,s8
    800018b8:	0004861b          	sext.w	a2,s1
    800018bc:	412585b3          	sub	a1,a1,s2
    800018c0:	8552                	mv	a0,s4
    800018c2:	fffff097          	auipc	ra,0xfffff
    800018c6:	4f2080e7          	jalr	1266(ra) # 80000db4 <memmove>
    len -= n;
    800018ca:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018ce:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018d0:	01590c33          	add	s8,s2,s5
  while (len > 0)
    800018d4:	02098263          	beqz	s3,800018f8 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800018d8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018dc:	85ca                	mv	a1,s2
    800018de:	855a                	mv	a0,s6
    800018e0:	00000097          	auipc	ra,0x0
    800018e4:	8ea080e7          	jalr	-1814(ra) # 800011ca <walkaddr>
    if (pa0 == 0)
    800018e8:	cd01                	beqz	a0,80001900 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800018ea:	418904b3          	sub	s1,s2,s8
    800018ee:	94d6                	add	s1,s1,s5
    if (n > len)
    800018f0:	fc99f2e3          	bgeu	s3,s1,800018b4 <copyin+0x28>
    800018f4:	84ce                	mv	s1,s3
    800018f6:	bf7d                	j	800018b4 <copyin+0x28>
  return 0;
    800018f8:	4501                	li	a0,0
    800018fa:	a021                	j	80001902 <copyin+0x76>
    800018fc:	4501                	li	a0,0
}
    800018fe:	8082                	ret
      return -1;
    80001900:	557d                	li	a0,-1
}
    80001902:	60a6                	ld	ra,72(sp)
    80001904:	6406                	ld	s0,64(sp)
    80001906:	74e2                	ld	s1,56(sp)
    80001908:	7942                	ld	s2,48(sp)
    8000190a:	79a2                	ld	s3,40(sp)
    8000190c:	7a02                	ld	s4,32(sp)
    8000190e:	6ae2                	ld	s5,24(sp)
    80001910:	6b42                	ld	s6,16(sp)
    80001912:	6ba2                	ld	s7,8(sp)
    80001914:	6c02                	ld	s8,0(sp)
    80001916:	6161                	addi	sp,sp,80
    80001918:	8082                	ret

000000008000191a <copyinstr>:
  while (got_null == 0 && max > 0)
    8000191a:	cad5                	beqz	a3,800019ce <copyinstr+0xb4>
{
    8000191c:	715d                	addi	sp,sp,-80
    8000191e:	e486                	sd	ra,72(sp)
    80001920:	e0a2                	sd	s0,64(sp)
    80001922:	fc26                	sd	s1,56(sp)
    80001924:	f84a                	sd	s2,48(sp)
    80001926:	f44e                	sd	s3,40(sp)
    80001928:	f052                	sd	s4,32(sp)
    8000192a:	ec56                	sd	s5,24(sp)
    8000192c:	e85a                	sd	s6,16(sp)
    8000192e:	e45e                	sd	s7,8(sp)
    80001930:	0880                	addi	s0,sp,80
    80001932:	8aaa                	mv	s5,a0
    80001934:	84ae                	mv	s1,a1
    80001936:	8bb2                	mv	s7,a2
    80001938:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000193a:	7b7d                	lui	s6,0xfffff
    n = PGSIZE - (srcva - va0);
    8000193c:	6a05                	lui	s4,0x1
    8000193e:	a82d                	j	80001978 <copyinstr+0x5e>
        *dst = '\0';
    80001940:	00078023          	sb	zero,0(a5)
        got_null = 1;
    80001944:	4785                	li	a5,1
  if (got_null)
    80001946:	0017c793          	xori	a5,a5,1
    8000194a:	40f0053b          	negw	a0,a5
}
    8000194e:	60a6                	ld	ra,72(sp)
    80001950:	6406                	ld	s0,64(sp)
    80001952:	74e2                	ld	s1,56(sp)
    80001954:	7942                	ld	s2,48(sp)
    80001956:	79a2                	ld	s3,40(sp)
    80001958:	7a02                	ld	s4,32(sp)
    8000195a:	6ae2                	ld	s5,24(sp)
    8000195c:	6b42                	ld	s6,16(sp)
    8000195e:	6ba2                	ld	s7,8(sp)
    80001960:	6161                	addi	sp,sp,80
    80001962:	8082                	ret
    80001964:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001968:	9726                	add	a4,a4,s1
      --max;
    8000196a:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    8000196e:	01490bb3          	add	s7,s2,s4
  while (got_null == 0 && max > 0)
    80001972:	04e58663          	beq	a1,a4,800019be <copyinstr+0xa4>
{
    80001976:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001978:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000197c:	85ca                	mv	a1,s2
    8000197e:	8556                	mv	a0,s5
    80001980:	00000097          	auipc	ra,0x0
    80001984:	84a080e7          	jalr	-1974(ra) # 800011ca <walkaddr>
    if (pa0 == 0)
    80001988:	cd0d                	beqz	a0,800019c2 <copyinstr+0xa8>
    n = PGSIZE - (srcva - va0);
    8000198a:	417906b3          	sub	a3,s2,s7
    8000198e:	96d2                	add	a3,a3,s4
    if (n > max)
    80001990:	00d9f363          	bgeu	s3,a3,80001996 <copyinstr+0x7c>
    80001994:	86ce                	mv	a3,s3
    while (n > 0)
    80001996:	ca85                	beqz	a3,800019c6 <copyinstr+0xac>
    char *p = (char *)(pa0 + (srcva - va0));
    80001998:	01750633          	add	a2,a0,s7
    8000199c:	41260633          	sub	a2,a2,s2
    800019a0:	87a6                	mv	a5,s1
      if (*p == '\0')
    800019a2:	8e05                	sub	a2,a2,s1
    while (n > 0)
    800019a4:	96a6                	add	a3,a3,s1
    800019a6:	85be                	mv	a1,a5
      if (*p == '\0')
    800019a8:	00f60733          	add	a4,a2,a5
    800019ac:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd220>
    800019b0:	db41                	beqz	a4,80001940 <copyinstr+0x26>
        *dst = *p;
    800019b2:	00e78023          	sb	a4,0(a5)
      dst++;
    800019b6:	0785                	addi	a5,a5,1
    while (n > 0)
    800019b8:	fed797e3          	bne	a5,a3,800019a6 <copyinstr+0x8c>
    800019bc:	b765                	j	80001964 <copyinstr+0x4a>
    800019be:	4781                	li	a5,0
    800019c0:	b759                	j	80001946 <copyinstr+0x2c>
      return -1;
    800019c2:	557d                	li	a0,-1
    800019c4:	b769                	j	8000194e <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800019c6:	6b85                	lui	s7,0x1
    800019c8:	9bca                	add	s7,s7,s2
    800019ca:	87a6                	mv	a5,s1
    800019cc:	b76d                	j	80001976 <copyinstr+0x5c>
  int got_null = 0;
    800019ce:	4781                	li	a5,0
  if (got_null)
    800019d0:	0017c793          	xori	a5,a5,1
    800019d4:	40f0053b          	negw	a0,a5
}
    800019d8:	8082                	ret

00000000800019da <vmprint>:

void vmprint(pagetable_t pagetable)
{
    800019da:	1101                	addi	sp,sp,-32
    800019dc:	ec06                	sd	ra,24(sp)
    800019de:	e822                	sd	s0,16(sp)
    800019e0:	e426                	sd	s1,8(sp)
    800019e2:	1000                	addi	s0,sp,32
    800019e4:	84aa                	mv	s1,a0
  printf("page table at physical address (pa) %p\n", pagetable); // print PT address
    800019e6:	85aa                	mv	a1,a0
    800019e8:	00007517          	auipc	a0,0x7
    800019ec:	84050513          	addi	a0,a0,-1984 # 80008228 <etext+0x228>
    800019f0:	fffff097          	auipc	ra,0xfffff
    800019f4:	bb8080e7          	jalr	-1096(ra) # 800005a8 <printf>
  print_pagetable(pagetable, 0);                                 // call print_pagetable with 0 recursion index
    800019f8:	4581                	li	a1,0
    800019fa:	8526                	mv	a0,s1
    800019fc:	fffff097          	auipc	ra,0xfffff
    80001a00:	628080e7          	jalr	1576(ra) # 80001024 <print_pagetable>
}
    80001a04:	60e2                	ld	ra,24(sp)
    80001a06:	6442                	ld	s0,16(sp)
    80001a08:	64a2                	ld	s1,8(sp)
    80001a0a:	6105                	addi	sp,sp,32
    80001a0c:	8082                	ret

0000000080001a0e <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001a0e:	715d                	addi	sp,sp,-80
    80001a10:	e486                	sd	ra,72(sp)
    80001a12:	e0a2                	sd	s0,64(sp)
    80001a14:	fc26                	sd	s1,56(sp)
    80001a16:	f84a                	sd	s2,48(sp)
    80001a18:	f44e                	sd	s3,40(sp)
    80001a1a:	f052                	sd	s4,32(sp)
    80001a1c:	ec56                	sd	s5,24(sp)
    80001a1e:	e85a                	sd	s6,16(sp)
    80001a20:	e45e                	sd	s7,8(sp)
    80001a22:	e062                	sd	s8,0(sp)
    80001a24:	0880                	addi	s0,sp,80
    80001a26:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a28:	0000f497          	auipc	s1,0xf
    80001a2c:	5d848493          	addi	s1,s1,1496 # 80011000 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001a30:	8c26                	mv	s8,s1
    80001a32:	000a57b7          	lui	a5,0xa5
    80001a36:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001a3a:	07b2                	slli	a5,a5,0xc
    80001a3c:	fa578793          	addi	a5,a5,-91
    80001a40:	4fa50937          	lui	s2,0x4fa50
    80001a44:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001a48:	1902                	slli	s2,s2,0x20
    80001a4a:	993e                	add	s2,s2,a5
    80001a4c:	040009b7          	lui	s3,0x4000
    80001a50:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a52:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a54:	4b99                	li	s7,6
    80001a56:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a58:	00015a97          	auipc	s5,0x15
    80001a5c:	fa8a8a93          	addi	s5,s5,-88 # 80016a00 <tickslock>
    char *pa = kalloc();
    80001a60:	fffff097          	auipc	ra,0xfffff
    80001a64:	0f8080e7          	jalr	248(ra) # 80000b58 <kalloc>
    80001a68:	862a                	mv	a2,a0
    if(pa == 0)
    80001a6a:	c131                	beqz	a0,80001aae <proc_mapstacks+0xa0>
    uint64 va = KSTACK((int) (p - proc));
    80001a6c:	418485b3          	sub	a1,s1,s8
    80001a70:	858d                	srai	a1,a1,0x3
    80001a72:	032585b3          	mul	a1,a1,s2
    80001a76:	05b6                	slli	a1,a1,0xd
    80001a78:	6789                	lui	a5,0x2
    80001a7a:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a7c:	875e                	mv	a4,s7
    80001a7e:	86da                	mv	a3,s6
    80001a80:	40b985b3          	sub	a1,s3,a1
    80001a84:	8552                	mv	a0,s4
    80001a86:	00000097          	auipc	ra,0x0
    80001a8a:	824080e7          	jalr	-2012(ra) # 800012aa <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a8e:	16848493          	addi	s1,s1,360
    80001a92:	fd5497e3          	bne	s1,s5,80001a60 <proc_mapstacks+0x52>
  }
}
    80001a96:	60a6                	ld	ra,72(sp)
    80001a98:	6406                	ld	s0,64(sp)
    80001a9a:	74e2                	ld	s1,56(sp)
    80001a9c:	7942                	ld	s2,48(sp)
    80001a9e:	79a2                	ld	s3,40(sp)
    80001aa0:	7a02                	ld	s4,32(sp)
    80001aa2:	6ae2                	ld	s5,24(sp)
    80001aa4:	6b42                	ld	s6,16(sp)
    80001aa6:	6ba2                	ld	s7,8(sp)
    80001aa8:	6c02                	ld	s8,0(sp)
    80001aaa:	6161                	addi	sp,sp,80
    80001aac:	8082                	ret
      panic("kalloc");
    80001aae:	00006517          	auipc	a0,0x6
    80001ab2:	7a250513          	addi	a0,a0,1954 # 80008250 <etext+0x250>
    80001ab6:	fffff097          	auipc	ra,0xfffff
    80001aba:	aa8080e7          	jalr	-1368(ra) # 8000055e <panic>

0000000080001abe <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001abe:	7139                	addi	sp,sp,-64
    80001ac0:	fc06                	sd	ra,56(sp)
    80001ac2:	f822                	sd	s0,48(sp)
    80001ac4:	f426                	sd	s1,40(sp)
    80001ac6:	f04a                	sd	s2,32(sp)
    80001ac8:	ec4e                	sd	s3,24(sp)
    80001aca:	e852                	sd	s4,16(sp)
    80001acc:	e456                	sd	s5,8(sp)
    80001ace:	e05a                	sd	s6,0(sp)
    80001ad0:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001ad2:	00006597          	auipc	a1,0x6
    80001ad6:	78658593          	addi	a1,a1,1926 # 80008258 <etext+0x258>
    80001ada:	0000f517          	auipc	a0,0xf
    80001ade:	0f650513          	addi	a0,a0,246 # 80010bd0 <pid_lock>
    80001ae2:	fffff097          	auipc	ra,0xfffff
    80001ae6:	0e0080e7          	jalr	224(ra) # 80000bc2 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001aea:	00006597          	auipc	a1,0x6
    80001aee:	77658593          	addi	a1,a1,1910 # 80008260 <etext+0x260>
    80001af2:	0000f517          	auipc	a0,0xf
    80001af6:	0f650513          	addi	a0,a0,246 # 80010be8 <wait_lock>
    80001afa:	fffff097          	auipc	ra,0xfffff
    80001afe:	0c8080e7          	jalr	200(ra) # 80000bc2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b02:	0000f497          	auipc	s1,0xf
    80001b06:	4fe48493          	addi	s1,s1,1278 # 80011000 <proc>
      initlock(&p->lock, "proc");
    80001b0a:	00006b17          	auipc	s6,0x6
    80001b0e:	766b0b13          	addi	s6,s6,1894 # 80008270 <etext+0x270>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001b12:	8aa6                	mv	s5,s1
    80001b14:	000a57b7          	lui	a5,0xa5
    80001b18:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001b1c:	07b2                	slli	a5,a5,0xc
    80001b1e:	fa578793          	addi	a5,a5,-91
    80001b22:	4fa50937          	lui	s2,0x4fa50
    80001b26:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001b2a:	1902                	slli	s2,s2,0x20
    80001b2c:	993e                	add	s2,s2,a5
    80001b2e:	040009b7          	lui	s3,0x4000
    80001b32:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001b34:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b36:	00015a17          	auipc	s4,0x15
    80001b3a:	ecaa0a13          	addi	s4,s4,-310 # 80016a00 <tickslock>
      initlock(&p->lock, "proc");
    80001b3e:	85da                	mv	a1,s6
    80001b40:	8526                	mv	a0,s1
    80001b42:	fffff097          	auipc	ra,0xfffff
    80001b46:	080080e7          	jalr	128(ra) # 80000bc2 <initlock>
      p->state = UNUSED;
    80001b4a:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001b4e:	415487b3          	sub	a5,s1,s5
    80001b52:	878d                	srai	a5,a5,0x3
    80001b54:	032787b3          	mul	a5,a5,s2
    80001b58:	07b6                	slli	a5,a5,0xd
    80001b5a:	6709                	lui	a4,0x2
    80001b5c:	9fb9                	addw	a5,a5,a4
    80001b5e:	40f987b3          	sub	a5,s3,a5
    80001b62:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b64:	16848493          	addi	s1,s1,360
    80001b68:	fd449be3          	bne	s1,s4,80001b3e <procinit+0x80>
  }
}
    80001b6c:	70e2                	ld	ra,56(sp)
    80001b6e:	7442                	ld	s0,48(sp)
    80001b70:	74a2                	ld	s1,40(sp)
    80001b72:	7902                	ld	s2,32(sp)
    80001b74:	69e2                	ld	s3,24(sp)
    80001b76:	6a42                	ld	s4,16(sp)
    80001b78:	6aa2                	ld	s5,8(sp)
    80001b7a:	6b02                	ld	s6,0(sp)
    80001b7c:	6121                	addi	sp,sp,64
    80001b7e:	8082                	ret

0000000080001b80 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001b80:	1141                	addi	sp,sp,-16
    80001b82:	e406                	sd	ra,8(sp)
    80001b84:	e022                	sd	s0,0(sp)
    80001b86:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b88:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b8a:	2501                	sext.w	a0,a0
    80001b8c:	60a2                	ld	ra,8(sp)
    80001b8e:	6402                	ld	s0,0(sp)
    80001b90:	0141                	addi	sp,sp,16
    80001b92:	8082                	ret

0000000080001b94 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001b94:	1141                	addi	sp,sp,-16
    80001b96:	e406                	sd	ra,8(sp)
    80001b98:	e022                	sd	s0,0(sp)
    80001b9a:	0800                	addi	s0,sp,16
    80001b9c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b9e:	2781                	sext.w	a5,a5
    80001ba0:	079e                	slli	a5,a5,0x7
  return c;
}
    80001ba2:	0000f517          	auipc	a0,0xf
    80001ba6:	05e50513          	addi	a0,a0,94 # 80010c00 <cpus>
    80001baa:	953e                	add	a0,a0,a5
    80001bac:	60a2                	ld	ra,8(sp)
    80001bae:	6402                	ld	s0,0(sp)
    80001bb0:	0141                	addi	sp,sp,16
    80001bb2:	8082                	ret

0000000080001bb4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001bb4:	1101                	addi	sp,sp,-32
    80001bb6:	ec06                	sd	ra,24(sp)
    80001bb8:	e822                	sd	s0,16(sp)
    80001bba:	e426                	sd	s1,8(sp)
    80001bbc:	1000                	addi	s0,sp,32
  push_off();
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	04e080e7          	jalr	78(ra) # 80000c0c <push_off>
    80001bc6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001bc8:	2781                	sext.w	a5,a5
    80001bca:	079e                	slli	a5,a5,0x7
    80001bcc:	0000f717          	auipc	a4,0xf
    80001bd0:	00470713          	addi	a4,a4,4 # 80010bd0 <pid_lock>
    80001bd4:	97ba                	add	a5,a5,a4
    80001bd6:	7b9c                	ld	a5,48(a5)
    80001bd8:	84be                	mv	s1,a5
  pop_off();
    80001bda:	fffff097          	auipc	ra,0xfffff
    80001bde:	0d6080e7          	jalr	214(ra) # 80000cb0 <pop_off>
  return p;
}
    80001be2:	8526                	mv	a0,s1
    80001be4:	60e2                	ld	ra,24(sp)
    80001be6:	6442                	ld	s0,16(sp)
    80001be8:	64a2                	ld	s1,8(sp)
    80001bea:	6105                	addi	sp,sp,32
    80001bec:	8082                	ret

0000000080001bee <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001bee:	1141                	addi	sp,sp,-16
    80001bf0:	e406                	sd	ra,8(sp)
    80001bf2:	e022                	sd	s0,0(sp)
    80001bf4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	fbe080e7          	jalr	-66(ra) # 80001bb4 <myproc>
    80001bfe:	fffff097          	auipc	ra,0xfffff
    80001c02:	10e080e7          	jalr	270(ra) # 80000d0c <release>

  if (first) {
    80001c06:	00007797          	auipc	a5,0x7
    80001c0a:	cda7a783          	lw	a5,-806(a5) # 800088e0 <first.1>
    80001c0e:	eb89                	bnez	a5,80001c20 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001c10:	00001097          	auipc	ra,0x1
    80001c14:	c62080e7          	jalr	-926(ra) # 80002872 <usertrapret>
}
    80001c18:	60a2                	ld	ra,8(sp)
    80001c1a:	6402                	ld	s0,0(sp)
    80001c1c:	0141                	addi	sp,sp,16
    80001c1e:	8082                	ret
    first = 0;
    80001c20:	00007797          	auipc	a5,0x7
    80001c24:	cc07a023          	sw	zero,-832(a5) # 800088e0 <first.1>
    fsinit(ROOTDEV);
    80001c28:	4505                	li	a0,1
    80001c2a:	00002097          	auipc	ra,0x2
    80001c2e:	99e080e7          	jalr	-1634(ra) # 800035c8 <fsinit>
    80001c32:	bff9                	j	80001c10 <forkret+0x22>

0000000080001c34 <allocpid>:
{
    80001c34:	1101                	addi	sp,sp,-32
    80001c36:	ec06                	sd	ra,24(sp)
    80001c38:	e822                	sd	s0,16(sp)
    80001c3a:	e426                	sd	s1,8(sp)
    80001c3c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c3e:	0000f517          	auipc	a0,0xf
    80001c42:	f9250513          	addi	a0,a0,-110 # 80010bd0 <pid_lock>
    80001c46:	fffff097          	auipc	ra,0xfffff
    80001c4a:	016080e7          	jalr	22(ra) # 80000c5c <acquire>
  pid = nextpid;
    80001c4e:	00007797          	auipc	a5,0x7
    80001c52:	c9678793          	addi	a5,a5,-874 # 800088e4 <nextpid>
    80001c56:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c58:	0014871b          	addiw	a4,s1,1
    80001c5c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c5e:	0000f517          	auipc	a0,0xf
    80001c62:	f7250513          	addi	a0,a0,-142 # 80010bd0 <pid_lock>
    80001c66:	fffff097          	auipc	ra,0xfffff
    80001c6a:	0a6080e7          	jalr	166(ra) # 80000d0c <release>
}
    80001c6e:	8526                	mv	a0,s1
    80001c70:	60e2                	ld	ra,24(sp)
    80001c72:	6442                	ld	s0,16(sp)
    80001c74:	64a2                	ld	s1,8(sp)
    80001c76:	6105                	addi	sp,sp,32
    80001c78:	8082                	ret

0000000080001c7a <proc_pagetable>:
{
    80001c7a:	1101                	addi	sp,sp,-32
    80001c7c:	ec06                	sd	ra,24(sp)
    80001c7e:	e822                	sd	s0,16(sp)
    80001c80:	e426                	sd	s1,8(sp)
    80001c82:	e04a                	sd	s2,0(sp)
    80001c84:	1000                	addi	s0,sp,32
    80001c86:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c88:	00000097          	auipc	ra,0x0
    80001c8c:	82c080e7          	jalr	-2004(ra) # 800014b4 <uvmcreate>
    80001c90:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c92:	c121                	beqz	a0,80001cd2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c94:	4729                	li	a4,10
    80001c96:	00005697          	auipc	a3,0x5
    80001c9a:	36a68693          	addi	a3,a3,874 # 80007000 <_trampoline>
    80001c9e:	6605                	lui	a2,0x1
    80001ca0:	040005b7          	lui	a1,0x4000
    80001ca4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ca6:	05b2                	slli	a1,a1,0xc
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	560080e7          	jalr	1376(ra) # 80001208 <mappages>
    80001cb0:	02054863          	bltz	a0,80001ce0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001cb4:	4719                	li	a4,6
    80001cb6:	05893683          	ld	a3,88(s2)
    80001cba:	6605                	lui	a2,0x1
    80001cbc:	020005b7          	lui	a1,0x2000
    80001cc0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cc2:	05b6                	slli	a1,a1,0xd
    80001cc4:	8526                	mv	a0,s1
    80001cc6:	fffff097          	auipc	ra,0xfffff
    80001cca:	542080e7          	jalr	1346(ra) # 80001208 <mappages>
    80001cce:	02054163          	bltz	a0,80001cf0 <proc_pagetable+0x76>
}
    80001cd2:	8526                	mv	a0,s1
    80001cd4:	60e2                	ld	ra,24(sp)
    80001cd6:	6442                	ld	s0,16(sp)
    80001cd8:	64a2                	ld	s1,8(sp)
    80001cda:	6902                	ld	s2,0(sp)
    80001cdc:	6105                	addi	sp,sp,32
    80001cde:	8082                	ret
    uvmfree(pagetable, 0);
    80001ce0:	4581                	li	a1,0
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	00000097          	auipc	ra,0x0
    80001ce8:	9e2080e7          	jalr	-1566(ra) # 800016c6 <uvmfree>
    return 0;
    80001cec:	4481                	li	s1,0
    80001cee:	b7d5                	j	80001cd2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cf0:	4681                	li	a3,0
    80001cf2:	4605                	li	a2,1
    80001cf4:	040005b7          	lui	a1,0x4000
    80001cf8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cfa:	05b2                	slli	a1,a1,0xc
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	fffff097          	auipc	ra,0xfffff
    80001d02:	6e2080e7          	jalr	1762(ra) # 800013e0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001d06:	4581                	li	a1,0
    80001d08:	8526                	mv	a0,s1
    80001d0a:	00000097          	auipc	ra,0x0
    80001d0e:	9bc080e7          	jalr	-1604(ra) # 800016c6 <uvmfree>
    return 0;
    80001d12:	4481                	li	s1,0
    80001d14:	bf7d                	j	80001cd2 <proc_pagetable+0x58>

0000000080001d16 <proc_freepagetable>:
{
    80001d16:	1101                	addi	sp,sp,-32
    80001d18:	ec06                	sd	ra,24(sp)
    80001d1a:	e822                	sd	s0,16(sp)
    80001d1c:	e426                	sd	s1,8(sp)
    80001d1e:	e04a                	sd	s2,0(sp)
    80001d20:	1000                	addi	s0,sp,32
    80001d22:	84aa                	mv	s1,a0
    80001d24:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d26:	4681                	li	a3,0
    80001d28:	4605                	li	a2,1
    80001d2a:	040005b7          	lui	a1,0x4000
    80001d2e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d30:	05b2                	slli	a1,a1,0xc
    80001d32:	fffff097          	auipc	ra,0xfffff
    80001d36:	6ae080e7          	jalr	1710(ra) # 800013e0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d3a:	4681                	li	a3,0
    80001d3c:	4605                	li	a2,1
    80001d3e:	020005b7          	lui	a1,0x2000
    80001d42:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d44:	05b6                	slli	a1,a1,0xd
    80001d46:	8526                	mv	a0,s1
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	698080e7          	jalr	1688(ra) # 800013e0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d50:	85ca                	mv	a1,s2
    80001d52:	8526                	mv	a0,s1
    80001d54:	00000097          	auipc	ra,0x0
    80001d58:	972080e7          	jalr	-1678(ra) # 800016c6 <uvmfree>
}
    80001d5c:	60e2                	ld	ra,24(sp)
    80001d5e:	6442                	ld	s0,16(sp)
    80001d60:	64a2                	ld	s1,8(sp)
    80001d62:	6902                	ld	s2,0(sp)
    80001d64:	6105                	addi	sp,sp,32
    80001d66:	8082                	ret

0000000080001d68 <freeproc>:
{
    80001d68:	1101                	addi	sp,sp,-32
    80001d6a:	ec06                	sd	ra,24(sp)
    80001d6c:	e822                	sd	s0,16(sp)
    80001d6e:	e426                	sd	s1,8(sp)
    80001d70:	1000                	addi	s0,sp,32
    80001d72:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001d74:	6d28                	ld	a0,88(a0)
    80001d76:	c509                	beqz	a0,80001d80 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001d78:	fffff097          	auipc	ra,0xfffff
    80001d7c:	cdc080e7          	jalr	-804(ra) # 80000a54 <kfree>
  p->trapframe = 0;
    80001d80:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001d84:	68a8                	ld	a0,80(s1)
    80001d86:	c511                	beqz	a0,80001d92 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001d88:	64ac                	ld	a1,72(s1)
    80001d8a:	00000097          	auipc	ra,0x0
    80001d8e:	f8c080e7          	jalr	-116(ra) # 80001d16 <proc_freepagetable>
  p->pagetable = 0;
    80001d92:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d96:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d9a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001d9e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001da2:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001da6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001daa:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001dae:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001db2:	0004ac23          	sw	zero,24(s1)
}
    80001db6:	60e2                	ld	ra,24(sp)
    80001db8:	6442                	ld	s0,16(sp)
    80001dba:	64a2                	ld	s1,8(sp)
    80001dbc:	6105                	addi	sp,sp,32
    80001dbe:	8082                	ret

0000000080001dc0 <allocproc>:
{
    80001dc0:	1101                	addi	sp,sp,-32
    80001dc2:	ec06                	sd	ra,24(sp)
    80001dc4:	e822                	sd	s0,16(sp)
    80001dc6:	e426                	sd	s1,8(sp)
    80001dc8:	e04a                	sd	s2,0(sp)
    80001dca:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dcc:	0000f497          	auipc	s1,0xf
    80001dd0:	23448493          	addi	s1,s1,564 # 80011000 <proc>
    80001dd4:	00015917          	auipc	s2,0x15
    80001dd8:	c2c90913          	addi	s2,s2,-980 # 80016a00 <tickslock>
    acquire(&p->lock);
    80001ddc:	8526                	mv	a0,s1
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	e7e080e7          	jalr	-386(ra) # 80000c5c <acquire>
    if(p->state == UNUSED) {
    80001de6:	4c9c                	lw	a5,24(s1)
    80001de8:	cf81                	beqz	a5,80001e00 <allocproc+0x40>
      release(&p->lock);
    80001dea:	8526                	mv	a0,s1
    80001dec:	fffff097          	auipc	ra,0xfffff
    80001df0:	f20080e7          	jalr	-224(ra) # 80000d0c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001df4:	16848493          	addi	s1,s1,360
    80001df8:	ff2492e3          	bne	s1,s2,80001ddc <allocproc+0x1c>
  return 0;
    80001dfc:	4481                	li	s1,0
    80001dfe:	a889                	j	80001e50 <allocproc+0x90>
  p->pid = allocpid();
    80001e00:	00000097          	auipc	ra,0x0
    80001e04:	e34080e7          	jalr	-460(ra) # 80001c34 <allocpid>
    80001e08:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001e0a:	4785                	li	a5,1
    80001e0c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001e0e:	fffff097          	auipc	ra,0xfffff
    80001e12:	d4a080e7          	jalr	-694(ra) # 80000b58 <kalloc>
    80001e16:	892a                	mv	s2,a0
    80001e18:	eca8                	sd	a0,88(s1)
    80001e1a:	c131                	beqz	a0,80001e5e <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001e1c:	8526                	mv	a0,s1
    80001e1e:	00000097          	auipc	ra,0x0
    80001e22:	e5c080e7          	jalr	-420(ra) # 80001c7a <proc_pagetable>
    80001e26:	892a                	mv	s2,a0
    80001e28:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001e2a:	c531                	beqz	a0,80001e76 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001e2c:	07000613          	li	a2,112
    80001e30:	4581                	li	a1,0
    80001e32:	06048513          	addi	a0,s1,96
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	f1e080e7          	jalr	-226(ra) # 80000d54 <memset>
  p->context.ra = (uint64)forkret;
    80001e3e:	00000797          	auipc	a5,0x0
    80001e42:	db078793          	addi	a5,a5,-592 # 80001bee <forkret>
    80001e46:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001e48:	60bc                	ld	a5,64(s1)
    80001e4a:	6705                	lui	a4,0x1
    80001e4c:	97ba                	add	a5,a5,a4
    80001e4e:	f4bc                	sd	a5,104(s1)
}
    80001e50:	8526                	mv	a0,s1
    80001e52:	60e2                	ld	ra,24(sp)
    80001e54:	6442                	ld	s0,16(sp)
    80001e56:	64a2                	ld	s1,8(sp)
    80001e58:	6902                	ld	s2,0(sp)
    80001e5a:	6105                	addi	sp,sp,32
    80001e5c:	8082                	ret
    freeproc(p);
    80001e5e:	8526                	mv	a0,s1
    80001e60:	00000097          	auipc	ra,0x0
    80001e64:	f08080e7          	jalr	-248(ra) # 80001d68 <freeproc>
    release(&p->lock);
    80001e68:	8526                	mv	a0,s1
    80001e6a:	fffff097          	auipc	ra,0xfffff
    80001e6e:	ea2080e7          	jalr	-350(ra) # 80000d0c <release>
    return 0;
    80001e72:	84ca                	mv	s1,s2
    80001e74:	bff1                	j	80001e50 <allocproc+0x90>
    freeproc(p);
    80001e76:	8526                	mv	a0,s1
    80001e78:	00000097          	auipc	ra,0x0
    80001e7c:	ef0080e7          	jalr	-272(ra) # 80001d68 <freeproc>
    release(&p->lock);
    80001e80:	8526                	mv	a0,s1
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	e8a080e7          	jalr	-374(ra) # 80000d0c <release>
    return 0;
    80001e8a:	84ca                	mv	s1,s2
    80001e8c:	b7d1                	j	80001e50 <allocproc+0x90>

0000000080001e8e <userinit>:
{
    80001e8e:	1101                	addi	sp,sp,-32
    80001e90:	ec06                	sd	ra,24(sp)
    80001e92:	e822                	sd	s0,16(sp)
    80001e94:	e426                	sd	s1,8(sp)
    80001e96:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e98:	00000097          	auipc	ra,0x0
    80001e9c:	f28080e7          	jalr	-216(ra) # 80001dc0 <allocproc>
    80001ea0:	84aa                	mv	s1,a0
  initproc = p;
    80001ea2:	00007797          	auipc	a5,0x7
    80001ea6:	aaa7bb23          	sd	a0,-1354(a5) # 80008958 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001eaa:	03400613          	li	a2,52
    80001eae:	00007597          	auipc	a1,0x7
    80001eb2:	a4258593          	addi	a1,a1,-1470 # 800088f0 <initcode>
    80001eb6:	6928                	ld	a0,80(a0)
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	62a080e7          	jalr	1578(ra) # 800014e2 <uvmfirst>
  p->sz = PGSIZE;
    80001ec0:	6785                	lui	a5,0x1
    80001ec2:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001ec4:	6cb8                	ld	a4,88(s1)
    80001ec6:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001eca:	6cb8                	ld	a4,88(s1)
    80001ecc:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ece:	4641                	li	a2,16
    80001ed0:	00006597          	auipc	a1,0x6
    80001ed4:	3a858593          	addi	a1,a1,936 # 80008278 <etext+0x278>
    80001ed8:	15848513          	addi	a0,s1,344
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	fd0080e7          	jalr	-48(ra) # 80000eac <safestrcpy>
  p->cwd = namei("/");
    80001ee4:	00006517          	auipc	a0,0x6
    80001ee8:	3a450513          	addi	a0,a0,932 # 80008288 <etext+0x288>
    80001eec:	00002097          	auipc	ra,0x2
    80001ef0:	148080e7          	jalr	328(ra) # 80004034 <namei>
    80001ef4:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ef8:	478d                	li	a5,3
    80001efa:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001efc:	8526                	mv	a0,s1
    80001efe:	fffff097          	auipc	ra,0xfffff
    80001f02:	e0e080e7          	jalr	-498(ra) # 80000d0c <release>
}
    80001f06:	60e2                	ld	ra,24(sp)
    80001f08:	6442                	ld	s0,16(sp)
    80001f0a:	64a2                	ld	s1,8(sp)
    80001f0c:	6105                	addi	sp,sp,32
    80001f0e:	8082                	ret

0000000080001f10 <growproc>:
{
    80001f10:	1101                	addi	sp,sp,-32
    80001f12:	ec06                	sd	ra,24(sp)
    80001f14:	e822                	sd	s0,16(sp)
    80001f16:	e426                	sd	s1,8(sp)
    80001f18:	e04a                	sd	s2,0(sp)
    80001f1a:	1000                	addi	s0,sp,32
    80001f1c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001f1e:	00000097          	auipc	ra,0x0
    80001f22:	c96080e7          	jalr	-874(ra) # 80001bb4 <myproc>
    80001f26:	84aa                	mv	s1,a0
  sz = p->sz;
    80001f28:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001f2a:	01204c63          	bgtz	s2,80001f42 <growproc+0x32>
  } else if(n < 0){
    80001f2e:	02094663          	bltz	s2,80001f5a <growproc+0x4a>
  p->sz = sz;
    80001f32:	e4ac                	sd	a1,72(s1)
  return 0;
    80001f34:	4501                	li	a0,0
}
    80001f36:	60e2                	ld	ra,24(sp)
    80001f38:	6442                	ld	s0,16(sp)
    80001f3a:	64a2                	ld	s1,8(sp)
    80001f3c:	6902                	ld	s2,0(sp)
    80001f3e:	6105                	addi	sp,sp,32
    80001f40:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001f42:	4691                	li	a3,4
    80001f44:	00b90633          	add	a2,s2,a1
    80001f48:	6928                	ld	a0,80(a0)
    80001f4a:	fffff097          	auipc	ra,0xfffff
    80001f4e:	652080e7          	jalr	1618(ra) # 8000159c <uvmalloc>
    80001f52:	85aa                	mv	a1,a0
    80001f54:	fd79                	bnez	a0,80001f32 <growproc+0x22>
      return -1;
    80001f56:	557d                	li	a0,-1
    80001f58:	bff9                	j	80001f36 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f5a:	00b90633          	add	a2,s2,a1
    80001f5e:	6928                	ld	a0,80(a0)
    80001f60:	fffff097          	auipc	ra,0xfffff
    80001f64:	5f4080e7          	jalr	1524(ra) # 80001554 <uvmdealloc>
    80001f68:	85aa                	mv	a1,a0
    80001f6a:	b7e1                	j	80001f32 <growproc+0x22>

0000000080001f6c <fork>:
{
    80001f6c:	7139                	addi	sp,sp,-64
    80001f6e:	fc06                	sd	ra,56(sp)
    80001f70:	f822                	sd	s0,48(sp)
    80001f72:	f426                	sd	s1,40(sp)
    80001f74:	e456                	sd	s5,8(sp)
    80001f76:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001f78:	00000097          	auipc	ra,0x0
    80001f7c:	c3c080e7          	jalr	-964(ra) # 80001bb4 <myproc>
    80001f80:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001f82:	00000097          	auipc	ra,0x0
    80001f86:	e3e080e7          	jalr	-450(ra) # 80001dc0 <allocproc>
    80001f8a:	12050063          	beqz	a0,800020aa <fork+0x13e>
    80001f8e:	e852                	sd	s4,16(sp)
    80001f90:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f92:	048ab603          	ld	a2,72(s5)
    80001f96:	692c                	ld	a1,80(a0)
    80001f98:	050ab503          	ld	a0,80(s5)
    80001f9c:	fffff097          	auipc	ra,0xfffff
    80001fa0:	764080e7          	jalr	1892(ra) # 80001700 <uvmcopy>
    80001fa4:	04054863          	bltz	a0,80001ff4 <fork+0x88>
    80001fa8:	f04a                	sd	s2,32(sp)
    80001faa:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001fac:	048ab783          	ld	a5,72(s5)
    80001fb0:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001fb4:	058ab683          	ld	a3,88(s5)
    80001fb8:	87b6                	mv	a5,a3
    80001fba:	058a3703          	ld	a4,88(s4)
    80001fbe:	12068693          	addi	a3,a3,288
    80001fc2:	6388                	ld	a0,0(a5)
    80001fc4:	678c                	ld	a1,8(a5)
    80001fc6:	6b90                	ld	a2,16(a5)
    80001fc8:	e308                	sd	a0,0(a4)
    80001fca:	e70c                	sd	a1,8(a4)
    80001fcc:	eb10                	sd	a2,16(a4)
    80001fce:	6f90                	ld	a2,24(a5)
    80001fd0:	ef10                	sd	a2,24(a4)
    80001fd2:	02078793          	addi	a5,a5,32 # 1020 <_entry-0x7fffefe0>
    80001fd6:	02070713          	addi	a4,a4,32
    80001fda:	fed794e3          	bne	a5,a3,80001fc2 <fork+0x56>
  np->trapframe->a0 = 0;
    80001fde:	058a3783          	ld	a5,88(s4)
    80001fe2:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001fe6:	0d0a8493          	addi	s1,s5,208
    80001fea:	0d0a0913          	addi	s2,s4,208
    80001fee:	150a8993          	addi	s3,s5,336
    80001ff2:	a015                	j	80002016 <fork+0xaa>
    freeproc(np);
    80001ff4:	8552                	mv	a0,s4
    80001ff6:	00000097          	auipc	ra,0x0
    80001ffa:	d72080e7          	jalr	-654(ra) # 80001d68 <freeproc>
    release(&np->lock);
    80001ffe:	8552                	mv	a0,s4
    80002000:	fffff097          	auipc	ra,0xfffff
    80002004:	d0c080e7          	jalr	-756(ra) # 80000d0c <release>
    return -1;
    80002008:	54fd                	li	s1,-1
    8000200a:	6a42                	ld	s4,16(sp)
    8000200c:	a841                	j	8000209c <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    8000200e:	04a1                	addi	s1,s1,8
    80002010:	0921                	addi	s2,s2,8
    80002012:	01348b63          	beq	s1,s3,80002028 <fork+0xbc>
    if(p->ofile[i])
    80002016:	6088                	ld	a0,0(s1)
    80002018:	d97d                	beqz	a0,8000200e <fork+0xa2>
      np->ofile[i] = filedup(p->ofile[i]);
    8000201a:	00002097          	auipc	ra,0x2
    8000201e:	6b0080e7          	jalr	1712(ra) # 800046ca <filedup>
    80002022:	00a93023          	sd	a0,0(s2)
    80002026:	b7e5                	j	8000200e <fork+0xa2>
  np->cwd = idup(p->cwd);
    80002028:	150ab503          	ld	a0,336(s5)
    8000202c:	00001097          	auipc	ra,0x1
    80002030:	7e0080e7          	jalr	2016(ra) # 8000380c <idup>
    80002034:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002038:	4641                	li	a2,16
    8000203a:	158a8593          	addi	a1,s5,344
    8000203e:	158a0513          	addi	a0,s4,344
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	e6a080e7          	jalr	-406(ra) # 80000eac <safestrcpy>
  pid = np->pid;
    8000204a:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    8000204e:	8552                	mv	a0,s4
    80002050:	fffff097          	auipc	ra,0xfffff
    80002054:	cbc080e7          	jalr	-836(ra) # 80000d0c <release>
  acquire(&wait_lock);
    80002058:	0000f517          	auipc	a0,0xf
    8000205c:	b9050513          	addi	a0,a0,-1136 # 80010be8 <wait_lock>
    80002060:	fffff097          	auipc	ra,0xfffff
    80002064:	bfc080e7          	jalr	-1028(ra) # 80000c5c <acquire>
  np->parent = p;
    80002068:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    8000206c:	0000f517          	auipc	a0,0xf
    80002070:	b7c50513          	addi	a0,a0,-1156 # 80010be8 <wait_lock>
    80002074:	fffff097          	auipc	ra,0xfffff
    80002078:	c98080e7          	jalr	-872(ra) # 80000d0c <release>
  acquire(&np->lock);
    8000207c:	8552                	mv	a0,s4
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	bde080e7          	jalr	-1058(ra) # 80000c5c <acquire>
  np->state = RUNNABLE;
    80002086:	478d                	li	a5,3
    80002088:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    8000208c:	8552                	mv	a0,s4
    8000208e:	fffff097          	auipc	ra,0xfffff
    80002092:	c7e080e7          	jalr	-898(ra) # 80000d0c <release>
  return pid;
    80002096:	7902                	ld	s2,32(sp)
    80002098:	69e2                	ld	s3,24(sp)
    8000209a:	6a42                	ld	s4,16(sp)
}
    8000209c:	8526                	mv	a0,s1
    8000209e:	70e2                	ld	ra,56(sp)
    800020a0:	7442                	ld	s0,48(sp)
    800020a2:	74a2                	ld	s1,40(sp)
    800020a4:	6aa2                	ld	s5,8(sp)
    800020a6:	6121                	addi	sp,sp,64
    800020a8:	8082                	ret
    return -1;
    800020aa:	54fd                	li	s1,-1
    800020ac:	bfc5                	j	8000209c <fork+0x130>

00000000800020ae <scheduler>:
{
    800020ae:	7139                	addi	sp,sp,-64
    800020b0:	fc06                	sd	ra,56(sp)
    800020b2:	f822                	sd	s0,48(sp)
    800020b4:	f426                	sd	s1,40(sp)
    800020b6:	f04a                	sd	s2,32(sp)
    800020b8:	ec4e                	sd	s3,24(sp)
    800020ba:	e852                	sd	s4,16(sp)
    800020bc:	e456                	sd	s5,8(sp)
    800020be:	e05a                	sd	s6,0(sp)
    800020c0:	0080                	addi	s0,sp,64
    800020c2:	8792                	mv	a5,tp
  int id = r_tp();
    800020c4:	2781                	sext.w	a5,a5
  c->proc = 0;
    800020c6:	00779a93          	slli	s5,a5,0x7
    800020ca:	0000f717          	auipc	a4,0xf
    800020ce:	b0670713          	addi	a4,a4,-1274 # 80010bd0 <pid_lock>
    800020d2:	9756                	add	a4,a4,s5
    800020d4:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800020d8:	0000f717          	auipc	a4,0xf
    800020dc:	b3070713          	addi	a4,a4,-1232 # 80010c08 <cpus+0x8>
    800020e0:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    800020e2:	498d                	li	s3,3
        p->state = RUNNING;
    800020e4:	4b11                	li	s6,4
        c->proc = p;
    800020e6:	079e                	slli	a5,a5,0x7
    800020e8:	0000fa17          	auipc	s4,0xf
    800020ec:	ae8a0a13          	addi	s4,s4,-1304 # 80010bd0 <pid_lock>
    800020f0:	9a3e                	add	s4,s4,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020f2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020f6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020fa:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800020fe:	0000f497          	auipc	s1,0xf
    80002102:	f0248493          	addi	s1,s1,-254 # 80011000 <proc>
    80002106:	00015917          	auipc	s2,0x15
    8000210a:	8fa90913          	addi	s2,s2,-1798 # 80016a00 <tickslock>
    8000210e:	a811                	j	80002122 <scheduler+0x74>
      release(&p->lock);
    80002110:	8526                	mv	a0,s1
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	bfa080e7          	jalr	-1030(ra) # 80000d0c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000211a:	16848493          	addi	s1,s1,360
    8000211e:	fd248ae3          	beq	s1,s2,800020f2 <scheduler+0x44>
      acquire(&p->lock);
    80002122:	8526                	mv	a0,s1
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	b38080e7          	jalr	-1224(ra) # 80000c5c <acquire>
      if(p->state == RUNNABLE) {
    8000212c:	4c9c                	lw	a5,24(s1)
    8000212e:	ff3791e3          	bne	a5,s3,80002110 <scheduler+0x62>
        p->state = RUNNING;
    80002132:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002136:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000213a:	06048593          	addi	a1,s1,96
    8000213e:	8556                	mv	a0,s5
    80002140:	00000097          	auipc	ra,0x0
    80002144:	684080e7          	jalr	1668(ra) # 800027c4 <swtch>
        c->proc = 0;
    80002148:	020a3823          	sd	zero,48(s4)
    8000214c:	b7d1                	j	80002110 <scheduler+0x62>

000000008000214e <sched>:
{
    8000214e:	7179                	addi	sp,sp,-48
    80002150:	f406                	sd	ra,40(sp)
    80002152:	f022                	sd	s0,32(sp)
    80002154:	ec26                	sd	s1,24(sp)
    80002156:	e84a                	sd	s2,16(sp)
    80002158:	e44e                	sd	s3,8(sp)
    8000215a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000215c:	00000097          	auipc	ra,0x0
    80002160:	a58080e7          	jalr	-1448(ra) # 80001bb4 <myproc>
    80002164:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002166:	fffff097          	auipc	ra,0xfffff
    8000216a:	a76080e7          	jalr	-1418(ra) # 80000bdc <holding>
    8000216e:	cd25                	beqz	a0,800021e6 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002170:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002172:	2781                	sext.w	a5,a5
    80002174:	079e                	slli	a5,a5,0x7
    80002176:	0000f717          	auipc	a4,0xf
    8000217a:	a5a70713          	addi	a4,a4,-1446 # 80010bd0 <pid_lock>
    8000217e:	97ba                	add	a5,a5,a4
    80002180:	0a87a703          	lw	a4,168(a5)
    80002184:	4785                	li	a5,1
    80002186:	06f71863          	bne	a4,a5,800021f6 <sched+0xa8>
  if(p->state == RUNNING)
    8000218a:	4c98                	lw	a4,24(s1)
    8000218c:	4791                	li	a5,4
    8000218e:	06f70c63          	beq	a4,a5,80002206 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002192:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002196:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002198:	efbd                	bnez	a5,80002216 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000219a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000219c:	0000f917          	auipc	s2,0xf
    800021a0:	a3490913          	addi	s2,s2,-1484 # 80010bd0 <pid_lock>
    800021a4:	2781                	sext.w	a5,a5
    800021a6:	079e                	slli	a5,a5,0x7
    800021a8:	97ca                	add	a5,a5,s2
    800021aa:	0ac7a983          	lw	s3,172(a5)
    800021ae:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800021b0:	2781                	sext.w	a5,a5
    800021b2:	079e                	slli	a5,a5,0x7
    800021b4:	07a1                	addi	a5,a5,8
    800021b6:	0000f597          	auipc	a1,0xf
    800021ba:	a4a58593          	addi	a1,a1,-1462 # 80010c00 <cpus>
    800021be:	95be                	add	a1,a1,a5
    800021c0:	06048513          	addi	a0,s1,96
    800021c4:	00000097          	auipc	ra,0x0
    800021c8:	600080e7          	jalr	1536(ra) # 800027c4 <swtch>
    800021cc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021ce:	2781                	sext.w	a5,a5
    800021d0:	079e                	slli	a5,a5,0x7
    800021d2:	993e                	add	s2,s2,a5
    800021d4:	0b392623          	sw	s3,172(s2)
}
    800021d8:	70a2                	ld	ra,40(sp)
    800021da:	7402                	ld	s0,32(sp)
    800021dc:	64e2                	ld	s1,24(sp)
    800021de:	6942                	ld	s2,16(sp)
    800021e0:	69a2                	ld	s3,8(sp)
    800021e2:	6145                	addi	sp,sp,48
    800021e4:	8082                	ret
    panic("sched p->lock");
    800021e6:	00006517          	auipc	a0,0x6
    800021ea:	0aa50513          	addi	a0,a0,170 # 80008290 <etext+0x290>
    800021ee:	ffffe097          	auipc	ra,0xffffe
    800021f2:	370080e7          	jalr	880(ra) # 8000055e <panic>
    panic("sched locks");
    800021f6:	00006517          	auipc	a0,0x6
    800021fa:	0aa50513          	addi	a0,a0,170 # 800082a0 <etext+0x2a0>
    800021fe:	ffffe097          	auipc	ra,0xffffe
    80002202:	360080e7          	jalr	864(ra) # 8000055e <panic>
    panic("sched running");
    80002206:	00006517          	auipc	a0,0x6
    8000220a:	0aa50513          	addi	a0,a0,170 # 800082b0 <etext+0x2b0>
    8000220e:	ffffe097          	auipc	ra,0xffffe
    80002212:	350080e7          	jalr	848(ra) # 8000055e <panic>
    panic("sched interruptible");
    80002216:	00006517          	auipc	a0,0x6
    8000221a:	0aa50513          	addi	a0,a0,170 # 800082c0 <etext+0x2c0>
    8000221e:	ffffe097          	auipc	ra,0xffffe
    80002222:	340080e7          	jalr	832(ra) # 8000055e <panic>

0000000080002226 <yield>:
{
    80002226:	1101                	addi	sp,sp,-32
    80002228:	ec06                	sd	ra,24(sp)
    8000222a:	e822                	sd	s0,16(sp)
    8000222c:	e426                	sd	s1,8(sp)
    8000222e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002230:	00000097          	auipc	ra,0x0
    80002234:	984080e7          	jalr	-1660(ra) # 80001bb4 <myproc>
    80002238:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000223a:	fffff097          	auipc	ra,0xfffff
    8000223e:	a22080e7          	jalr	-1502(ra) # 80000c5c <acquire>
  p->state = RUNNABLE;
    80002242:	478d                	li	a5,3
    80002244:	cc9c                	sw	a5,24(s1)
  sched();
    80002246:	00000097          	auipc	ra,0x0
    8000224a:	f08080e7          	jalr	-248(ra) # 8000214e <sched>
  release(&p->lock);
    8000224e:	8526                	mv	a0,s1
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	abc080e7          	jalr	-1348(ra) # 80000d0c <release>
}
    80002258:	60e2                	ld	ra,24(sp)
    8000225a:	6442                	ld	s0,16(sp)
    8000225c:	64a2                	ld	s1,8(sp)
    8000225e:	6105                	addi	sp,sp,32
    80002260:	8082                	ret

0000000080002262 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002262:	7179                	addi	sp,sp,-48
    80002264:	f406                	sd	ra,40(sp)
    80002266:	f022                	sd	s0,32(sp)
    80002268:	ec26                	sd	s1,24(sp)
    8000226a:	e84a                	sd	s2,16(sp)
    8000226c:	e44e                	sd	s3,8(sp)
    8000226e:	1800                	addi	s0,sp,48
    80002270:	89aa                	mv	s3,a0
    80002272:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002274:	00000097          	auipc	ra,0x0
    80002278:	940080e7          	jalr	-1728(ra) # 80001bb4 <myproc>
    8000227c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	9de080e7          	jalr	-1570(ra) # 80000c5c <acquire>
  release(lk);
    80002286:	854a                	mv	a0,s2
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	a84080e7          	jalr	-1404(ra) # 80000d0c <release>

  // Go to sleep.
  p->chan = chan;
    80002290:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002294:	4789                	li	a5,2
    80002296:	cc9c                	sw	a5,24(s1)

  sched();
    80002298:	00000097          	auipc	ra,0x0
    8000229c:	eb6080e7          	jalr	-330(ra) # 8000214e <sched>

  // Tidy up.
  p->chan = 0;
    800022a0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800022a4:	8526                	mv	a0,s1
    800022a6:	fffff097          	auipc	ra,0xfffff
    800022aa:	a66080e7          	jalr	-1434(ra) # 80000d0c <release>
  acquire(lk);
    800022ae:	854a                	mv	a0,s2
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	9ac080e7          	jalr	-1620(ra) # 80000c5c <acquire>
}
    800022b8:	70a2                	ld	ra,40(sp)
    800022ba:	7402                	ld	s0,32(sp)
    800022bc:	64e2                	ld	s1,24(sp)
    800022be:	6942                	ld	s2,16(sp)
    800022c0:	69a2                	ld	s3,8(sp)
    800022c2:	6145                	addi	sp,sp,48
    800022c4:	8082                	ret

00000000800022c6 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800022c6:	7139                	addi	sp,sp,-64
    800022c8:	fc06                	sd	ra,56(sp)
    800022ca:	f822                	sd	s0,48(sp)
    800022cc:	f426                	sd	s1,40(sp)
    800022ce:	f04a                	sd	s2,32(sp)
    800022d0:	ec4e                	sd	s3,24(sp)
    800022d2:	e852                	sd	s4,16(sp)
    800022d4:	e456                	sd	s5,8(sp)
    800022d6:	0080                	addi	s0,sp,64
    800022d8:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800022da:	0000f497          	auipc	s1,0xf
    800022de:	d2648493          	addi	s1,s1,-730 # 80011000 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800022e2:	4989                	li	s3,2
        p->state = RUNNABLE;
    800022e4:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800022e6:	00014917          	auipc	s2,0x14
    800022ea:	71a90913          	addi	s2,s2,1818 # 80016a00 <tickslock>
    800022ee:	a811                	j	80002302 <wakeup+0x3c>
      }
      release(&p->lock);
    800022f0:	8526                	mv	a0,s1
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	a1a080e7          	jalr	-1510(ra) # 80000d0c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022fa:	16848493          	addi	s1,s1,360
    800022fe:	03248663          	beq	s1,s2,8000232a <wakeup+0x64>
    if(p != myproc()){
    80002302:	00000097          	auipc	ra,0x0
    80002306:	8b2080e7          	jalr	-1870(ra) # 80001bb4 <myproc>
    8000230a:	fe9508e3          	beq	a0,s1,800022fa <wakeup+0x34>
      acquire(&p->lock);
    8000230e:	8526                	mv	a0,s1
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	94c080e7          	jalr	-1716(ra) # 80000c5c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002318:	4c9c                	lw	a5,24(s1)
    8000231a:	fd379be3          	bne	a5,s3,800022f0 <wakeup+0x2a>
    8000231e:	709c                	ld	a5,32(s1)
    80002320:	fd4798e3          	bne	a5,s4,800022f0 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002324:	0154ac23          	sw	s5,24(s1)
    80002328:	b7e1                	j	800022f0 <wakeup+0x2a>
    }
  }
}
    8000232a:	70e2                	ld	ra,56(sp)
    8000232c:	7442                	ld	s0,48(sp)
    8000232e:	74a2                	ld	s1,40(sp)
    80002330:	7902                	ld	s2,32(sp)
    80002332:	69e2                	ld	s3,24(sp)
    80002334:	6a42                	ld	s4,16(sp)
    80002336:	6aa2                	ld	s5,8(sp)
    80002338:	6121                	addi	sp,sp,64
    8000233a:	8082                	ret

000000008000233c <reparent>:
{
    8000233c:	7179                	addi	sp,sp,-48
    8000233e:	f406                	sd	ra,40(sp)
    80002340:	f022                	sd	s0,32(sp)
    80002342:	ec26                	sd	s1,24(sp)
    80002344:	e84a                	sd	s2,16(sp)
    80002346:	e44e                	sd	s3,8(sp)
    80002348:	e052                	sd	s4,0(sp)
    8000234a:	1800                	addi	s0,sp,48
    8000234c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000234e:	0000f497          	auipc	s1,0xf
    80002352:	cb248493          	addi	s1,s1,-846 # 80011000 <proc>
      pp->parent = initproc;
    80002356:	00006a17          	auipc	s4,0x6
    8000235a:	602a0a13          	addi	s4,s4,1538 # 80008958 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000235e:	00014997          	auipc	s3,0x14
    80002362:	6a298993          	addi	s3,s3,1698 # 80016a00 <tickslock>
    80002366:	a029                	j	80002370 <reparent+0x34>
    80002368:	16848493          	addi	s1,s1,360
    8000236c:	01348d63          	beq	s1,s3,80002386 <reparent+0x4a>
    if(pp->parent == p){
    80002370:	7c9c                	ld	a5,56(s1)
    80002372:	ff279be3          	bne	a5,s2,80002368 <reparent+0x2c>
      pp->parent = initproc;
    80002376:	000a3503          	ld	a0,0(s4)
    8000237a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000237c:	00000097          	auipc	ra,0x0
    80002380:	f4a080e7          	jalr	-182(ra) # 800022c6 <wakeup>
    80002384:	b7d5                	j	80002368 <reparent+0x2c>
}
    80002386:	70a2                	ld	ra,40(sp)
    80002388:	7402                	ld	s0,32(sp)
    8000238a:	64e2                	ld	s1,24(sp)
    8000238c:	6942                	ld	s2,16(sp)
    8000238e:	69a2                	ld	s3,8(sp)
    80002390:	6a02                	ld	s4,0(sp)
    80002392:	6145                	addi	sp,sp,48
    80002394:	8082                	ret

0000000080002396 <exit>:
{
    80002396:	7179                	addi	sp,sp,-48
    80002398:	f406                	sd	ra,40(sp)
    8000239a:	f022                	sd	s0,32(sp)
    8000239c:	ec26                	sd	s1,24(sp)
    8000239e:	e84a                	sd	s2,16(sp)
    800023a0:	e44e                	sd	s3,8(sp)
    800023a2:	e052                	sd	s4,0(sp)
    800023a4:	1800                	addi	s0,sp,48
    800023a6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800023a8:	00000097          	auipc	ra,0x0
    800023ac:	80c080e7          	jalr	-2036(ra) # 80001bb4 <myproc>
    800023b0:	89aa                	mv	s3,a0
  if(p == initproc)
    800023b2:	00006797          	auipc	a5,0x6
    800023b6:	5a67b783          	ld	a5,1446(a5) # 80008958 <initproc>
    800023ba:	0d050493          	addi	s1,a0,208
    800023be:	15050913          	addi	s2,a0,336
    800023c2:	00a79d63          	bne	a5,a0,800023dc <exit+0x46>
    panic("init exiting");
    800023c6:	00006517          	auipc	a0,0x6
    800023ca:	f1250513          	addi	a0,a0,-238 # 800082d8 <etext+0x2d8>
    800023ce:	ffffe097          	auipc	ra,0xffffe
    800023d2:	190080e7          	jalr	400(ra) # 8000055e <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    800023d6:	04a1                	addi	s1,s1,8
    800023d8:	01248b63          	beq	s1,s2,800023ee <exit+0x58>
    if(p->ofile[fd]){
    800023dc:	6088                	ld	a0,0(s1)
    800023de:	dd65                	beqz	a0,800023d6 <exit+0x40>
      fileclose(f);
    800023e0:	00002097          	auipc	ra,0x2
    800023e4:	33c080e7          	jalr	828(ra) # 8000471c <fileclose>
      p->ofile[fd] = 0;
    800023e8:	0004b023          	sd	zero,0(s1)
    800023ec:	b7ed                	j	800023d6 <exit+0x40>
  begin_op();
    800023ee:	00002097          	auipc	ra,0x2
    800023f2:	e4c080e7          	jalr	-436(ra) # 8000423a <begin_op>
  iput(p->cwd);
    800023f6:	1509b503          	ld	a0,336(s3)
    800023fa:	00001097          	auipc	ra,0x1
    800023fe:	60e080e7          	jalr	1550(ra) # 80003a08 <iput>
  end_op();
    80002402:	00002097          	auipc	ra,0x2
    80002406:	eb8080e7          	jalr	-328(ra) # 800042ba <end_op>
  p->cwd = 0;
    8000240a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000240e:	0000e517          	auipc	a0,0xe
    80002412:	7da50513          	addi	a0,a0,2010 # 80010be8 <wait_lock>
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	846080e7          	jalr	-1978(ra) # 80000c5c <acquire>
  reparent(p);
    8000241e:	854e                	mv	a0,s3
    80002420:	00000097          	auipc	ra,0x0
    80002424:	f1c080e7          	jalr	-228(ra) # 8000233c <reparent>
  wakeup(p->parent);
    80002428:	0389b503          	ld	a0,56(s3)
    8000242c:	00000097          	auipc	ra,0x0
    80002430:	e9a080e7          	jalr	-358(ra) # 800022c6 <wakeup>
  acquire(&p->lock);
    80002434:	854e                	mv	a0,s3
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	826080e7          	jalr	-2010(ra) # 80000c5c <acquire>
  p->xstate = status;
    8000243e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002442:	4795                	li	a5,5
    80002444:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002448:	0000e517          	auipc	a0,0xe
    8000244c:	7a050513          	addi	a0,a0,1952 # 80010be8 <wait_lock>
    80002450:	fffff097          	auipc	ra,0xfffff
    80002454:	8bc080e7          	jalr	-1860(ra) # 80000d0c <release>
  sched();
    80002458:	00000097          	auipc	ra,0x0
    8000245c:	cf6080e7          	jalr	-778(ra) # 8000214e <sched>
  panic("zombie exit");
    80002460:	00006517          	auipc	a0,0x6
    80002464:	e8850513          	addi	a0,a0,-376 # 800082e8 <etext+0x2e8>
    80002468:	ffffe097          	auipc	ra,0xffffe
    8000246c:	0f6080e7          	jalr	246(ra) # 8000055e <panic>

0000000080002470 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002470:	7179                	addi	sp,sp,-48
    80002472:	f406                	sd	ra,40(sp)
    80002474:	f022                	sd	s0,32(sp)
    80002476:	ec26                	sd	s1,24(sp)
    80002478:	e84a                	sd	s2,16(sp)
    8000247a:	e44e                	sd	s3,8(sp)
    8000247c:	1800                	addi	s0,sp,48
    8000247e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002480:	0000f497          	auipc	s1,0xf
    80002484:	b8048493          	addi	s1,s1,-1152 # 80011000 <proc>
    80002488:	00014997          	auipc	s3,0x14
    8000248c:	57898993          	addi	s3,s3,1400 # 80016a00 <tickslock>
    acquire(&p->lock);
    80002490:	8526                	mv	a0,s1
    80002492:	ffffe097          	auipc	ra,0xffffe
    80002496:	7ca080e7          	jalr	1994(ra) # 80000c5c <acquire>
    if(p->pid == pid){
    8000249a:	589c                	lw	a5,48(s1)
    8000249c:	01278d63          	beq	a5,s2,800024b6 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024a0:	8526                	mv	a0,s1
    800024a2:	fffff097          	auipc	ra,0xfffff
    800024a6:	86a080e7          	jalr	-1942(ra) # 80000d0c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024aa:	16848493          	addi	s1,s1,360
    800024ae:	ff3491e3          	bne	s1,s3,80002490 <kill+0x20>
  }
  return -1;
    800024b2:	557d                	li	a0,-1
    800024b4:	a829                	j	800024ce <kill+0x5e>
      p->killed = 1;
    800024b6:	4785                	li	a5,1
    800024b8:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800024ba:	4c98                	lw	a4,24(s1)
    800024bc:	4789                	li	a5,2
    800024be:	00f70f63          	beq	a4,a5,800024dc <kill+0x6c>
      release(&p->lock);
    800024c2:	8526                	mv	a0,s1
    800024c4:	fffff097          	auipc	ra,0xfffff
    800024c8:	848080e7          	jalr	-1976(ra) # 80000d0c <release>
      return 0;
    800024cc:	4501                	li	a0,0
}
    800024ce:	70a2                	ld	ra,40(sp)
    800024d0:	7402                	ld	s0,32(sp)
    800024d2:	64e2                	ld	s1,24(sp)
    800024d4:	6942                	ld	s2,16(sp)
    800024d6:	69a2                	ld	s3,8(sp)
    800024d8:	6145                	addi	sp,sp,48
    800024da:	8082                	ret
        p->state = RUNNABLE;
    800024dc:	478d                	li	a5,3
    800024de:	cc9c                	sw	a5,24(s1)
    800024e0:	b7cd                	j	800024c2 <kill+0x52>

00000000800024e2 <setkilled>:

void
setkilled(struct proc *p)
{
    800024e2:	1101                	addi	sp,sp,-32
    800024e4:	ec06                	sd	ra,24(sp)
    800024e6:	e822                	sd	s0,16(sp)
    800024e8:	e426                	sd	s1,8(sp)
    800024ea:	1000                	addi	s0,sp,32
    800024ec:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024ee:	ffffe097          	auipc	ra,0xffffe
    800024f2:	76e080e7          	jalr	1902(ra) # 80000c5c <acquire>
  p->killed = 1;
    800024f6:	4785                	li	a5,1
    800024f8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800024fa:	8526                	mv	a0,s1
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	810080e7          	jalr	-2032(ra) # 80000d0c <release>
}
    80002504:	60e2                	ld	ra,24(sp)
    80002506:	6442                	ld	s0,16(sp)
    80002508:	64a2                	ld	s1,8(sp)
    8000250a:	6105                	addi	sp,sp,32
    8000250c:	8082                	ret

000000008000250e <killed>:

int
killed(struct proc *p)
{
    8000250e:	1101                	addi	sp,sp,-32
    80002510:	ec06                	sd	ra,24(sp)
    80002512:	e822                	sd	s0,16(sp)
    80002514:	e426                	sd	s1,8(sp)
    80002516:	e04a                	sd	s2,0(sp)
    80002518:	1000                	addi	s0,sp,32
    8000251a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000251c:	ffffe097          	auipc	ra,0xffffe
    80002520:	740080e7          	jalr	1856(ra) # 80000c5c <acquire>
  k = p->killed;
    80002524:	549c                	lw	a5,40(s1)
    80002526:	893e                	mv	s2,a5
  release(&p->lock);
    80002528:	8526                	mv	a0,s1
    8000252a:	ffffe097          	auipc	ra,0xffffe
    8000252e:	7e2080e7          	jalr	2018(ra) # 80000d0c <release>
  return k;
}
    80002532:	854a                	mv	a0,s2
    80002534:	60e2                	ld	ra,24(sp)
    80002536:	6442                	ld	s0,16(sp)
    80002538:	64a2                	ld	s1,8(sp)
    8000253a:	6902                	ld	s2,0(sp)
    8000253c:	6105                	addi	sp,sp,32
    8000253e:	8082                	ret

0000000080002540 <wait>:
{
    80002540:	715d                	addi	sp,sp,-80
    80002542:	e486                	sd	ra,72(sp)
    80002544:	e0a2                	sd	s0,64(sp)
    80002546:	fc26                	sd	s1,56(sp)
    80002548:	f84a                	sd	s2,48(sp)
    8000254a:	f44e                	sd	s3,40(sp)
    8000254c:	f052                	sd	s4,32(sp)
    8000254e:	ec56                	sd	s5,24(sp)
    80002550:	e85a                	sd	s6,16(sp)
    80002552:	e45e                	sd	s7,8(sp)
    80002554:	0880                	addi	s0,sp,80
    80002556:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002558:	fffff097          	auipc	ra,0xfffff
    8000255c:	65c080e7          	jalr	1628(ra) # 80001bb4 <myproc>
    80002560:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002562:	0000e517          	auipc	a0,0xe
    80002566:	68650513          	addi	a0,a0,1670 # 80010be8 <wait_lock>
    8000256a:	ffffe097          	auipc	ra,0xffffe
    8000256e:	6f2080e7          	jalr	1778(ra) # 80000c5c <acquire>
        if(pp->state == ZOMBIE){
    80002572:	4a15                	li	s4,5
        havekids = 1;
    80002574:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002576:	00014997          	auipc	s3,0x14
    8000257a:	48a98993          	addi	s3,s3,1162 # 80016a00 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000257e:	0000eb17          	auipc	s6,0xe
    80002582:	66ab0b13          	addi	s6,s6,1642 # 80010be8 <wait_lock>
    80002586:	a0c9                	j	80002648 <wait+0x108>
          pid = pp->pid;
    80002588:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000258c:	000b8e63          	beqz	s7,800025a8 <wait+0x68>
    80002590:	4691                	li	a3,4
    80002592:	02c48613          	addi	a2,s1,44
    80002596:	85de                	mv	a1,s7
    80002598:	05093503          	ld	a0,80(s2)
    8000259c:	fffff097          	auipc	ra,0xfffff
    800025a0:	264080e7          	jalr	612(ra) # 80001800 <copyout>
    800025a4:	04054063          	bltz	a0,800025e4 <wait+0xa4>
          freeproc(pp);
    800025a8:	8526                	mv	a0,s1
    800025aa:	fffff097          	auipc	ra,0xfffff
    800025ae:	7be080e7          	jalr	1982(ra) # 80001d68 <freeproc>
          release(&pp->lock);
    800025b2:	8526                	mv	a0,s1
    800025b4:	ffffe097          	auipc	ra,0xffffe
    800025b8:	758080e7          	jalr	1880(ra) # 80000d0c <release>
          release(&wait_lock);
    800025bc:	0000e517          	auipc	a0,0xe
    800025c0:	62c50513          	addi	a0,a0,1580 # 80010be8 <wait_lock>
    800025c4:	ffffe097          	auipc	ra,0xffffe
    800025c8:	748080e7          	jalr	1864(ra) # 80000d0c <release>
}
    800025cc:	854e                	mv	a0,s3
    800025ce:	60a6                	ld	ra,72(sp)
    800025d0:	6406                	ld	s0,64(sp)
    800025d2:	74e2                	ld	s1,56(sp)
    800025d4:	7942                	ld	s2,48(sp)
    800025d6:	79a2                	ld	s3,40(sp)
    800025d8:	7a02                	ld	s4,32(sp)
    800025da:	6ae2                	ld	s5,24(sp)
    800025dc:	6b42                	ld	s6,16(sp)
    800025de:	6ba2                	ld	s7,8(sp)
    800025e0:	6161                	addi	sp,sp,80
    800025e2:	8082                	ret
            release(&pp->lock);
    800025e4:	8526                	mv	a0,s1
    800025e6:	ffffe097          	auipc	ra,0xffffe
    800025ea:	726080e7          	jalr	1830(ra) # 80000d0c <release>
            release(&wait_lock);
    800025ee:	0000e517          	auipc	a0,0xe
    800025f2:	5fa50513          	addi	a0,a0,1530 # 80010be8 <wait_lock>
    800025f6:	ffffe097          	auipc	ra,0xffffe
    800025fa:	716080e7          	jalr	1814(ra) # 80000d0c <release>
            return -1;
    800025fe:	59fd                	li	s3,-1
    80002600:	b7f1                	j	800025cc <wait+0x8c>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002602:	16848493          	addi	s1,s1,360
    80002606:	03348463          	beq	s1,s3,8000262e <wait+0xee>
      if(pp->parent == p){
    8000260a:	7c9c                	ld	a5,56(s1)
    8000260c:	ff279be3          	bne	a5,s2,80002602 <wait+0xc2>
        acquire(&pp->lock);
    80002610:	8526                	mv	a0,s1
    80002612:	ffffe097          	auipc	ra,0xffffe
    80002616:	64a080e7          	jalr	1610(ra) # 80000c5c <acquire>
        if(pp->state == ZOMBIE){
    8000261a:	4c9c                	lw	a5,24(s1)
    8000261c:	f74786e3          	beq	a5,s4,80002588 <wait+0x48>
        release(&pp->lock);
    80002620:	8526                	mv	a0,s1
    80002622:	ffffe097          	auipc	ra,0xffffe
    80002626:	6ea080e7          	jalr	1770(ra) # 80000d0c <release>
        havekids = 1;
    8000262a:	8756                	mv	a4,s5
    8000262c:	bfd9                	j	80002602 <wait+0xc2>
    if(!havekids || killed(p)){
    8000262e:	c31d                	beqz	a4,80002654 <wait+0x114>
    80002630:	854a                	mv	a0,s2
    80002632:	00000097          	auipc	ra,0x0
    80002636:	edc080e7          	jalr	-292(ra) # 8000250e <killed>
    8000263a:	ed09                	bnez	a0,80002654 <wait+0x114>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000263c:	85da                	mv	a1,s6
    8000263e:	854a                	mv	a0,s2
    80002640:	00000097          	auipc	ra,0x0
    80002644:	c22080e7          	jalr	-990(ra) # 80002262 <sleep>
    havekids = 0;
    80002648:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000264a:	0000f497          	auipc	s1,0xf
    8000264e:	9b648493          	addi	s1,s1,-1610 # 80011000 <proc>
    80002652:	bf65                	j	8000260a <wait+0xca>
      release(&wait_lock);
    80002654:	0000e517          	auipc	a0,0xe
    80002658:	59450513          	addi	a0,a0,1428 # 80010be8 <wait_lock>
    8000265c:	ffffe097          	auipc	ra,0xffffe
    80002660:	6b0080e7          	jalr	1712(ra) # 80000d0c <release>
      return -1;
    80002664:	59fd                	li	s3,-1
    80002666:	b79d                	j	800025cc <wait+0x8c>

0000000080002668 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002668:	7179                	addi	sp,sp,-48
    8000266a:	f406                	sd	ra,40(sp)
    8000266c:	f022                	sd	s0,32(sp)
    8000266e:	ec26                	sd	s1,24(sp)
    80002670:	e84a                	sd	s2,16(sp)
    80002672:	e44e                	sd	s3,8(sp)
    80002674:	e052                	sd	s4,0(sp)
    80002676:	1800                	addi	s0,sp,48
    80002678:	84aa                	mv	s1,a0
    8000267a:	8a2e                	mv	s4,a1
    8000267c:	89b2                	mv	s3,a2
    8000267e:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002680:	fffff097          	auipc	ra,0xfffff
    80002684:	534080e7          	jalr	1332(ra) # 80001bb4 <myproc>
  if(user_dst){
    80002688:	c08d                	beqz	s1,800026aa <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000268a:	86ca                	mv	a3,s2
    8000268c:	864e                	mv	a2,s3
    8000268e:	85d2                	mv	a1,s4
    80002690:	6928                	ld	a0,80(a0)
    80002692:	fffff097          	auipc	ra,0xfffff
    80002696:	16e080e7          	jalr	366(ra) # 80001800 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000269a:	70a2                	ld	ra,40(sp)
    8000269c:	7402                	ld	s0,32(sp)
    8000269e:	64e2                	ld	s1,24(sp)
    800026a0:	6942                	ld	s2,16(sp)
    800026a2:	69a2                	ld	s3,8(sp)
    800026a4:	6a02                	ld	s4,0(sp)
    800026a6:	6145                	addi	sp,sp,48
    800026a8:	8082                	ret
    memmove((char *)dst, src, len);
    800026aa:	0009061b          	sext.w	a2,s2
    800026ae:	85ce                	mv	a1,s3
    800026b0:	8552                	mv	a0,s4
    800026b2:	ffffe097          	auipc	ra,0xffffe
    800026b6:	702080e7          	jalr	1794(ra) # 80000db4 <memmove>
    return 0;
    800026ba:	8526                	mv	a0,s1
    800026bc:	bff9                	j	8000269a <either_copyout+0x32>

00000000800026be <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026be:	7179                	addi	sp,sp,-48
    800026c0:	f406                	sd	ra,40(sp)
    800026c2:	f022                	sd	s0,32(sp)
    800026c4:	ec26                	sd	s1,24(sp)
    800026c6:	e84a                	sd	s2,16(sp)
    800026c8:	e44e                	sd	s3,8(sp)
    800026ca:	e052                	sd	s4,0(sp)
    800026cc:	1800                	addi	s0,sp,48
    800026ce:	8a2a                	mv	s4,a0
    800026d0:	84ae                	mv	s1,a1
    800026d2:	89b2                	mv	s3,a2
    800026d4:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800026d6:	fffff097          	auipc	ra,0xfffff
    800026da:	4de080e7          	jalr	1246(ra) # 80001bb4 <myproc>
  if(user_src){
    800026de:	c08d                	beqz	s1,80002700 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800026e0:	86ca                	mv	a3,s2
    800026e2:	864e                	mv	a2,s3
    800026e4:	85d2                	mv	a1,s4
    800026e6:	6928                	ld	a0,80(a0)
    800026e8:	fffff097          	auipc	ra,0xfffff
    800026ec:	1a4080e7          	jalr	420(ra) # 8000188c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026f0:	70a2                	ld	ra,40(sp)
    800026f2:	7402                	ld	s0,32(sp)
    800026f4:	64e2                	ld	s1,24(sp)
    800026f6:	6942                	ld	s2,16(sp)
    800026f8:	69a2                	ld	s3,8(sp)
    800026fa:	6a02                	ld	s4,0(sp)
    800026fc:	6145                	addi	sp,sp,48
    800026fe:	8082                	ret
    memmove(dst, (char*)src, len);
    80002700:	0009061b          	sext.w	a2,s2
    80002704:	85ce                	mv	a1,s3
    80002706:	8552                	mv	a0,s4
    80002708:	ffffe097          	auipc	ra,0xffffe
    8000270c:	6ac080e7          	jalr	1708(ra) # 80000db4 <memmove>
    return 0;
    80002710:	8526                	mv	a0,s1
    80002712:	bff9                	j	800026f0 <either_copyin+0x32>

0000000080002714 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002714:	715d                	addi	sp,sp,-80
    80002716:	e486                	sd	ra,72(sp)
    80002718:	e0a2                	sd	s0,64(sp)
    8000271a:	fc26                	sd	s1,56(sp)
    8000271c:	f84a                	sd	s2,48(sp)
    8000271e:	f44e                	sd	s3,40(sp)
    80002720:	f052                	sd	s4,32(sp)
    80002722:	ec56                	sd	s5,24(sp)
    80002724:	e85a                	sd	s6,16(sp)
    80002726:	e45e                	sd	s7,8(sp)
    80002728:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000272a:	00006517          	auipc	a0,0x6
    8000272e:	8e650513          	addi	a0,a0,-1818 # 80008010 <etext+0x10>
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	e76080e7          	jalr	-394(ra) # 800005a8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000273a:	0000f497          	auipc	s1,0xf
    8000273e:	a1e48493          	addi	s1,s1,-1506 # 80011158 <proc+0x158>
    80002742:	00014917          	auipc	s2,0x14
    80002746:	41690913          	addi	s2,s2,1046 # 80016b58 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000274a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000274c:	00006997          	auipc	s3,0x6
    80002750:	bac98993          	addi	s3,s3,-1108 # 800082f8 <etext+0x2f8>
    printf("%d %s %s", p->pid, state, p->name);
    80002754:	00006a97          	auipc	s5,0x6
    80002758:	baca8a93          	addi	s5,s5,-1108 # 80008300 <etext+0x300>
    printf("\n");
    8000275c:	00006a17          	auipc	s4,0x6
    80002760:	8b4a0a13          	addi	s4,s4,-1868 # 80008010 <etext+0x10>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002764:	00006b97          	auipc	s7,0x6
    80002768:	074b8b93          	addi	s7,s7,116 # 800087d8 <states.0>
    8000276c:	a00d                	j	8000278e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000276e:	ed86a583          	lw	a1,-296(a3)
    80002772:	8556                	mv	a0,s5
    80002774:	ffffe097          	auipc	ra,0xffffe
    80002778:	e34080e7          	jalr	-460(ra) # 800005a8 <printf>
    printf("\n");
    8000277c:	8552                	mv	a0,s4
    8000277e:	ffffe097          	auipc	ra,0xffffe
    80002782:	e2a080e7          	jalr	-470(ra) # 800005a8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002786:	16848493          	addi	s1,s1,360
    8000278a:	03248263          	beq	s1,s2,800027ae <procdump+0x9a>
    if(p->state == UNUSED)
    8000278e:	86a6                	mv	a3,s1
    80002790:	ec04a783          	lw	a5,-320(s1)
    80002794:	dbed                	beqz	a5,80002786 <procdump+0x72>
      state = "???";
    80002796:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002798:	fcfb6be3          	bltu	s6,a5,8000276e <procdump+0x5a>
    8000279c:	02079713          	slli	a4,a5,0x20
    800027a0:	01d75793          	srli	a5,a4,0x1d
    800027a4:	97de                	add	a5,a5,s7
    800027a6:	6390                	ld	a2,0(a5)
    800027a8:	f279                	bnez	a2,8000276e <procdump+0x5a>
      state = "???";
    800027aa:	864e                	mv	a2,s3
    800027ac:	b7c9                	j	8000276e <procdump+0x5a>
  }
}
    800027ae:	60a6                	ld	ra,72(sp)
    800027b0:	6406                	ld	s0,64(sp)
    800027b2:	74e2                	ld	s1,56(sp)
    800027b4:	7942                	ld	s2,48(sp)
    800027b6:	79a2                	ld	s3,40(sp)
    800027b8:	7a02                	ld	s4,32(sp)
    800027ba:	6ae2                	ld	s5,24(sp)
    800027bc:	6b42                	ld	s6,16(sp)
    800027be:	6ba2                	ld	s7,8(sp)
    800027c0:	6161                	addi	sp,sp,80
    800027c2:	8082                	ret

00000000800027c4 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800027c4:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800027c8:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800027cc:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800027ce:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800027d0:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800027d4:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800027d8:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800027dc:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800027e0:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800027e4:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800027e8:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800027ec:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800027f0:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800027f4:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800027f8:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800027fc:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002800:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002802:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002804:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002808:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000280c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002810:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002814:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002818:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000281c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002820:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002824:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002828:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000282c:	8082                	ret

000000008000282e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000282e:	1141                	addi	sp,sp,-16
    80002830:	e406                	sd	ra,8(sp)
    80002832:	e022                	sd	s0,0(sp)
    80002834:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002836:	00006597          	auipc	a1,0x6
    8000283a:	b0a58593          	addi	a1,a1,-1270 # 80008340 <etext+0x340>
    8000283e:	00014517          	auipc	a0,0x14
    80002842:	1c250513          	addi	a0,a0,450 # 80016a00 <tickslock>
    80002846:	ffffe097          	auipc	ra,0xffffe
    8000284a:	37c080e7          	jalr	892(ra) # 80000bc2 <initlock>
}
    8000284e:	60a2                	ld	ra,8(sp)
    80002850:	6402                	ld	s0,0(sp)
    80002852:	0141                	addi	sp,sp,16
    80002854:	8082                	ret

0000000080002856 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002856:	1141                	addi	sp,sp,-16
    80002858:	e406                	sd	ra,8(sp)
    8000285a:	e022                	sd	s0,0(sp)
    8000285c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000285e:	00003797          	auipc	a5,0x3
    80002862:	62278793          	addi	a5,a5,1570 # 80005e80 <kernelvec>
    80002866:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000286a:	60a2                	ld	ra,8(sp)
    8000286c:	6402                	ld	s0,0(sp)
    8000286e:	0141                	addi	sp,sp,16
    80002870:	8082                	ret

0000000080002872 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002872:	1141                	addi	sp,sp,-16
    80002874:	e406                	sd	ra,8(sp)
    80002876:	e022                	sd	s0,0(sp)
    80002878:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000287a:	fffff097          	auipc	ra,0xfffff
    8000287e:	33a080e7          	jalr	826(ra) # 80001bb4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002882:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002886:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002888:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000288c:	00004697          	auipc	a3,0x4
    80002890:	77468693          	addi	a3,a3,1908 # 80007000 <_trampoline>
    80002894:	00004717          	auipc	a4,0x4
    80002898:	76c70713          	addi	a4,a4,1900 # 80007000 <_trampoline>
    8000289c:	8f15                	sub	a4,a4,a3
    8000289e:	040007b7          	lui	a5,0x4000
    800028a2:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800028a4:	07b2                	slli	a5,a5,0xc
    800028a6:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028a8:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028ac:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028ae:	18002673          	csrr	a2,satp
    800028b2:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028b4:	6d30                	ld	a2,88(a0)
    800028b6:	6138                	ld	a4,64(a0)
    800028b8:	6585                	lui	a1,0x1
    800028ba:	972e                	add	a4,a4,a1
    800028bc:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800028be:	6d38                	ld	a4,88(a0)
    800028c0:	00000617          	auipc	a2,0x0
    800028c4:	13c60613          	addi	a2,a2,316 # 800029fc <usertrap>
    800028c8:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800028ca:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028cc:	8612                	mv	a2,tp
    800028ce:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028d0:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028d4:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028d8:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028dc:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800028e0:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028e2:	6f18                	ld	a4,24(a4)
    800028e4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800028e8:	6928                	ld	a0,80(a0)
    800028ea:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800028ec:	00004717          	auipc	a4,0x4
    800028f0:	7b070713          	addi	a4,a4,1968 # 8000709c <userret>
    800028f4:	8f15                	sub	a4,a4,a3
    800028f6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800028f8:	577d                	li	a4,-1
    800028fa:	177e                	slli	a4,a4,0x3f
    800028fc:	8d59                	or	a0,a0,a4
    800028fe:	9782                	jalr	a5
}
    80002900:	60a2                	ld	ra,8(sp)
    80002902:	6402                	ld	s0,0(sp)
    80002904:	0141                	addi	sp,sp,16
    80002906:	8082                	ret

0000000080002908 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002908:	1141                	addi	sp,sp,-16
    8000290a:	e406                	sd	ra,8(sp)
    8000290c:	e022                	sd	s0,0(sp)
    8000290e:	0800                	addi	s0,sp,16
  acquire(&tickslock);
    80002910:	00014517          	auipc	a0,0x14
    80002914:	0f050513          	addi	a0,a0,240 # 80016a00 <tickslock>
    80002918:	ffffe097          	auipc	ra,0xffffe
    8000291c:	344080e7          	jalr	836(ra) # 80000c5c <acquire>
  ticks++;
    80002920:	00006717          	auipc	a4,0x6
    80002924:	04070713          	addi	a4,a4,64 # 80008960 <ticks>
    80002928:	431c                	lw	a5,0(a4)
    8000292a:	2785                	addiw	a5,a5,1
    8000292c:	c31c                	sw	a5,0(a4)
  wakeup(&ticks);
    8000292e:	853a                	mv	a0,a4
    80002930:	00000097          	auipc	ra,0x0
    80002934:	996080e7          	jalr	-1642(ra) # 800022c6 <wakeup>
  release(&tickslock);
    80002938:	00014517          	auipc	a0,0x14
    8000293c:	0c850513          	addi	a0,a0,200 # 80016a00 <tickslock>
    80002940:	ffffe097          	auipc	ra,0xffffe
    80002944:	3cc080e7          	jalr	972(ra) # 80000d0c <release>
}
    80002948:	60a2                	ld	ra,8(sp)
    8000294a:	6402                	ld	s0,0(sp)
    8000294c:	0141                	addi	sp,sp,16
    8000294e:	8082                	ret

0000000080002950 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002950:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002954:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002956:	0a07d263          	bgez	a5,800029fa <devintr+0xaa>
{
    8000295a:	1101                	addi	sp,sp,-32
    8000295c:	ec06                	sd	ra,24(sp)
    8000295e:	e822                	sd	s0,16(sp)
    80002960:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002962:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002966:	46a5                	li	a3,9
    80002968:	00d70c63          	beq	a4,a3,80002980 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    8000296c:	577d                	li	a4,-1
    8000296e:	177e                	slli	a4,a4,0x3f
    80002970:	0705                	addi	a4,a4,1
    return 0;
    80002972:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002974:	06e78263          	beq	a5,a4,800029d8 <devintr+0x88>
  }
}
    80002978:	60e2                	ld	ra,24(sp)
    8000297a:	6442                	ld	s0,16(sp)
    8000297c:	6105                	addi	sp,sp,32
    8000297e:	8082                	ret
    80002980:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002982:	00003097          	auipc	ra,0x3
    80002986:	60a080e7          	jalr	1546(ra) # 80005f8c <plic_claim>
    8000298a:	872a                	mv	a4,a0
    8000298c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000298e:	47a9                	li	a5,10
    80002990:	00f50963          	beq	a0,a5,800029a2 <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ){
    80002994:	4785                	li	a5,1
    80002996:	00f50b63          	beq	a0,a5,800029ac <devintr+0x5c>
    return 1;
    8000299a:	4505                	li	a0,1
    } else if(irq){
    8000299c:	ef09                	bnez	a4,800029b6 <devintr+0x66>
    8000299e:	64a2                	ld	s1,8(sp)
    800029a0:	bfe1                	j	80002978 <devintr+0x28>
      uartintr();
    800029a2:	ffffe097          	auipc	ra,0xffffe
    800029a6:	05e080e7          	jalr	94(ra) # 80000a00 <uartintr>
    if(irq)
    800029aa:	a839                	j	800029c8 <devintr+0x78>
      virtio_disk_intr();
    800029ac:	00004097          	auipc	ra,0x4
    800029b0:	ada080e7          	jalr	-1318(ra) # 80006486 <virtio_disk_intr>
    if(irq)
    800029b4:	a811                	j	800029c8 <devintr+0x78>
      printf("unexpected interrupt irq=%d\n", irq);
    800029b6:	85ba                	mv	a1,a4
    800029b8:	00006517          	auipc	a0,0x6
    800029bc:	99050513          	addi	a0,a0,-1648 # 80008348 <etext+0x348>
    800029c0:	ffffe097          	auipc	ra,0xffffe
    800029c4:	be8080e7          	jalr	-1048(ra) # 800005a8 <printf>
      plic_complete(irq);
    800029c8:	8526                	mv	a0,s1
    800029ca:	00003097          	auipc	ra,0x3
    800029ce:	5e6080e7          	jalr	1510(ra) # 80005fb0 <plic_complete>
    return 1;
    800029d2:	4505                	li	a0,1
    800029d4:	64a2                	ld	s1,8(sp)
    800029d6:	b74d                	j	80002978 <devintr+0x28>
    if(cpuid() == 0){
    800029d8:	fffff097          	auipc	ra,0xfffff
    800029dc:	1a8080e7          	jalr	424(ra) # 80001b80 <cpuid>
    800029e0:	c901                	beqz	a0,800029f0 <devintr+0xa0>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800029e2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800029e6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800029e8:	14479073          	csrw	sip,a5
    return 2;
    800029ec:	4509                	li	a0,2
    800029ee:	b769                	j	80002978 <devintr+0x28>
      clockintr();
    800029f0:	00000097          	auipc	ra,0x0
    800029f4:	f18080e7          	jalr	-232(ra) # 80002908 <clockintr>
    800029f8:	b7ed                	j	800029e2 <devintr+0x92>
}
    800029fa:	8082                	ret

00000000800029fc <usertrap>:
{
    800029fc:	1101                	addi	sp,sp,-32
    800029fe:	ec06                	sd	ra,24(sp)
    80002a00:	e822                	sd	s0,16(sp)
    80002a02:	e426                	sd	s1,8(sp)
    80002a04:	e04a                	sd	s2,0(sp)
    80002a06:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a08:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a0c:	1007f793          	andi	a5,a5,256
    80002a10:	e3b1                	bnez	a5,80002a54 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a12:	00003797          	auipc	a5,0x3
    80002a16:	46e78793          	addi	a5,a5,1134 # 80005e80 <kernelvec>
    80002a1a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a1e:	fffff097          	auipc	ra,0xfffff
    80002a22:	196080e7          	jalr	406(ra) # 80001bb4 <myproc>
    80002a26:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a28:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a2a:	14102773          	csrr	a4,sepc
    80002a2e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a30:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a34:	47a1                	li	a5,8
    80002a36:	02f70763          	beq	a4,a5,80002a64 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002a3a:	00000097          	auipc	ra,0x0
    80002a3e:	f16080e7          	jalr	-234(ra) # 80002950 <devintr>
    80002a42:	892a                	mv	s2,a0
    80002a44:	c151                	beqz	a0,80002ac8 <usertrap+0xcc>
  if(killed(p))
    80002a46:	8526                	mv	a0,s1
    80002a48:	00000097          	auipc	ra,0x0
    80002a4c:	ac6080e7          	jalr	-1338(ra) # 8000250e <killed>
    80002a50:	c929                	beqz	a0,80002aa2 <usertrap+0xa6>
    80002a52:	a099                	j	80002a98 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002a54:	00006517          	auipc	a0,0x6
    80002a58:	91450513          	addi	a0,a0,-1772 # 80008368 <etext+0x368>
    80002a5c:	ffffe097          	auipc	ra,0xffffe
    80002a60:	b02080e7          	jalr	-1278(ra) # 8000055e <panic>
    if(killed(p))
    80002a64:	00000097          	auipc	ra,0x0
    80002a68:	aaa080e7          	jalr	-1366(ra) # 8000250e <killed>
    80002a6c:	e921                	bnez	a0,80002abc <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002a6e:	6cb8                	ld	a4,88(s1)
    80002a70:	6f1c                	ld	a5,24(a4)
    80002a72:	0791                	addi	a5,a5,4
    80002a74:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a76:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a7a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a7e:	10079073          	csrw	sstatus,a5
    syscall();
    80002a82:	00000097          	auipc	ra,0x0
    80002a86:	2ce080e7          	jalr	718(ra) # 80002d50 <syscall>
  if(killed(p))
    80002a8a:	8526                	mv	a0,s1
    80002a8c:	00000097          	auipc	ra,0x0
    80002a90:	a82080e7          	jalr	-1406(ra) # 8000250e <killed>
    80002a94:	c911                	beqz	a0,80002aa8 <usertrap+0xac>
    80002a96:	4901                	li	s2,0
    exit(-1);
    80002a98:	557d                	li	a0,-1
    80002a9a:	00000097          	auipc	ra,0x0
    80002a9e:	8fc080e7          	jalr	-1796(ra) # 80002396 <exit>
  if(which_dev == 2)
    80002aa2:	4789                	li	a5,2
    80002aa4:	04f90f63          	beq	s2,a5,80002b02 <usertrap+0x106>
  usertrapret();
    80002aa8:	00000097          	auipc	ra,0x0
    80002aac:	dca080e7          	jalr	-566(ra) # 80002872 <usertrapret>
}
    80002ab0:	60e2                	ld	ra,24(sp)
    80002ab2:	6442                	ld	s0,16(sp)
    80002ab4:	64a2                	ld	s1,8(sp)
    80002ab6:	6902                	ld	s2,0(sp)
    80002ab8:	6105                	addi	sp,sp,32
    80002aba:	8082                	ret
      exit(-1);
    80002abc:	557d                	li	a0,-1
    80002abe:	00000097          	auipc	ra,0x0
    80002ac2:	8d8080e7          	jalr	-1832(ra) # 80002396 <exit>
    80002ac6:	b765                	j	80002a6e <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ac8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002acc:	5890                	lw	a2,48(s1)
    80002ace:	00006517          	auipc	a0,0x6
    80002ad2:	8ba50513          	addi	a0,a0,-1862 # 80008388 <etext+0x388>
    80002ad6:	ffffe097          	auipc	ra,0xffffe
    80002ada:	ad2080e7          	jalr	-1326(ra) # 800005a8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ade:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ae2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ae6:	00006517          	auipc	a0,0x6
    80002aea:	8d250513          	addi	a0,a0,-1838 # 800083b8 <etext+0x3b8>
    80002aee:	ffffe097          	auipc	ra,0xffffe
    80002af2:	aba080e7          	jalr	-1350(ra) # 800005a8 <printf>
    setkilled(p);
    80002af6:	8526                	mv	a0,s1
    80002af8:	00000097          	auipc	ra,0x0
    80002afc:	9ea080e7          	jalr	-1558(ra) # 800024e2 <setkilled>
    80002b00:	b769                	j	80002a8a <usertrap+0x8e>
    yield();
    80002b02:	fffff097          	auipc	ra,0xfffff
    80002b06:	724080e7          	jalr	1828(ra) # 80002226 <yield>
    80002b0a:	bf79                	j	80002aa8 <usertrap+0xac>

0000000080002b0c <kerneltrap>:
{
    80002b0c:	7179                	addi	sp,sp,-48
    80002b0e:	f406                	sd	ra,40(sp)
    80002b10:	f022                	sd	s0,32(sp)
    80002b12:	ec26                	sd	s1,24(sp)
    80002b14:	e84a                	sd	s2,16(sp)
    80002b16:	e44e                	sd	s3,8(sp)
    80002b18:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b1a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b1e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b22:	142027f3          	csrr	a5,scause
    80002b26:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002b28:	1004f793          	andi	a5,s1,256
    80002b2c:	cb85                	beqz	a5,80002b5c <kerneltrap+0x50>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b2e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b32:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b34:	ef85                	bnez	a5,80002b6c <kerneltrap+0x60>
  if((which_dev = devintr()) == 0){
    80002b36:	00000097          	auipc	ra,0x0
    80002b3a:	e1a080e7          	jalr	-486(ra) # 80002950 <devintr>
    80002b3e:	cd1d                	beqz	a0,80002b7c <kerneltrap+0x70>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b40:	4789                	li	a5,2
    80002b42:	06f50a63          	beq	a0,a5,80002bb6 <kerneltrap+0xaa>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b46:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b4a:	10049073          	csrw	sstatus,s1
}
    80002b4e:	70a2                	ld	ra,40(sp)
    80002b50:	7402                	ld	s0,32(sp)
    80002b52:	64e2                	ld	s1,24(sp)
    80002b54:	6942                	ld	s2,16(sp)
    80002b56:	69a2                	ld	s3,8(sp)
    80002b58:	6145                	addi	sp,sp,48
    80002b5a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b5c:	00006517          	auipc	a0,0x6
    80002b60:	87c50513          	addi	a0,a0,-1924 # 800083d8 <etext+0x3d8>
    80002b64:	ffffe097          	auipc	ra,0xffffe
    80002b68:	9fa080e7          	jalr	-1542(ra) # 8000055e <panic>
    panic("kerneltrap: interrupts enabled");
    80002b6c:	00006517          	auipc	a0,0x6
    80002b70:	89450513          	addi	a0,a0,-1900 # 80008400 <etext+0x400>
    80002b74:	ffffe097          	auipc	ra,0xffffe
    80002b78:	9ea080e7          	jalr	-1558(ra) # 8000055e <panic>
    printf("scause %p\n", scause);
    80002b7c:	85ce                	mv	a1,s3
    80002b7e:	00006517          	auipc	a0,0x6
    80002b82:	8a250513          	addi	a0,a0,-1886 # 80008420 <etext+0x420>
    80002b86:	ffffe097          	auipc	ra,0xffffe
    80002b8a:	a22080e7          	jalr	-1502(ra) # 800005a8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b8e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b92:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b96:	00006517          	auipc	a0,0x6
    80002b9a:	89a50513          	addi	a0,a0,-1894 # 80008430 <etext+0x430>
    80002b9e:	ffffe097          	auipc	ra,0xffffe
    80002ba2:	a0a080e7          	jalr	-1526(ra) # 800005a8 <printf>
    panic("kerneltrap");
    80002ba6:	00006517          	auipc	a0,0x6
    80002baa:	8a250513          	addi	a0,a0,-1886 # 80008448 <etext+0x448>
    80002bae:	ffffe097          	auipc	ra,0xffffe
    80002bb2:	9b0080e7          	jalr	-1616(ra) # 8000055e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bb6:	fffff097          	auipc	ra,0xfffff
    80002bba:	ffe080e7          	jalr	-2(ra) # 80001bb4 <myproc>
    80002bbe:	d541                	beqz	a0,80002b46 <kerneltrap+0x3a>
    80002bc0:	fffff097          	auipc	ra,0xfffff
    80002bc4:	ff4080e7          	jalr	-12(ra) # 80001bb4 <myproc>
    80002bc8:	4d18                	lw	a4,24(a0)
    80002bca:	4791                	li	a5,4
    80002bcc:	f6f71de3          	bne	a4,a5,80002b46 <kerneltrap+0x3a>
    yield();
    80002bd0:	fffff097          	auipc	ra,0xfffff
    80002bd4:	656080e7          	jalr	1622(ra) # 80002226 <yield>
    80002bd8:	b7bd                	j	80002b46 <kerneltrap+0x3a>

0000000080002bda <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002bda:	1101                	addi	sp,sp,-32
    80002bdc:	ec06                	sd	ra,24(sp)
    80002bde:	e822                	sd	s0,16(sp)
    80002be0:	e426                	sd	s1,8(sp)
    80002be2:	1000                	addi	s0,sp,32
    80002be4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002be6:	fffff097          	auipc	ra,0xfffff
    80002bea:	fce080e7          	jalr	-50(ra) # 80001bb4 <myproc>
  switch (n)
    80002bee:	4795                	li	a5,5
    80002bf0:	0497e163          	bltu	a5,s1,80002c32 <argraw+0x58>
    80002bf4:	048a                	slli	s1,s1,0x2
    80002bf6:	00006717          	auipc	a4,0x6
    80002bfa:	c1270713          	addi	a4,a4,-1006 # 80008808 <states.0+0x30>
    80002bfe:	94ba                	add	s1,s1,a4
    80002c00:	409c                	lw	a5,0(s1)
    80002c02:	97ba                	add	a5,a5,a4
    80002c04:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002c06:	6d3c                	ld	a5,88(a0)
    80002c08:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c0a:	60e2                	ld	ra,24(sp)
    80002c0c:	6442                	ld	s0,16(sp)
    80002c0e:	64a2                	ld	s1,8(sp)
    80002c10:	6105                	addi	sp,sp,32
    80002c12:	8082                	ret
    return p->trapframe->a1;
    80002c14:	6d3c                	ld	a5,88(a0)
    80002c16:	7fa8                	ld	a0,120(a5)
    80002c18:	bfcd                	j	80002c0a <argraw+0x30>
    return p->trapframe->a2;
    80002c1a:	6d3c                	ld	a5,88(a0)
    80002c1c:	63c8                	ld	a0,128(a5)
    80002c1e:	b7f5                	j	80002c0a <argraw+0x30>
    return p->trapframe->a3;
    80002c20:	6d3c                	ld	a5,88(a0)
    80002c22:	67c8                	ld	a0,136(a5)
    80002c24:	b7dd                	j	80002c0a <argraw+0x30>
    return p->trapframe->a4;
    80002c26:	6d3c                	ld	a5,88(a0)
    80002c28:	6bc8                	ld	a0,144(a5)
    80002c2a:	b7c5                	j	80002c0a <argraw+0x30>
    return p->trapframe->a5;
    80002c2c:	6d3c                	ld	a5,88(a0)
    80002c2e:	6fc8                	ld	a0,152(a5)
    80002c30:	bfe9                	j	80002c0a <argraw+0x30>
  panic("argraw");
    80002c32:	00006517          	auipc	a0,0x6
    80002c36:	82650513          	addi	a0,a0,-2010 # 80008458 <etext+0x458>
    80002c3a:	ffffe097          	auipc	ra,0xffffe
    80002c3e:	924080e7          	jalr	-1756(ra) # 8000055e <panic>

0000000080002c42 <fetchaddr>:
{
    80002c42:	1101                	addi	sp,sp,-32
    80002c44:	ec06                	sd	ra,24(sp)
    80002c46:	e822                	sd	s0,16(sp)
    80002c48:	e426                	sd	s1,8(sp)
    80002c4a:	e04a                	sd	s2,0(sp)
    80002c4c:	1000                	addi	s0,sp,32
    80002c4e:	84aa                	mv	s1,a0
    80002c50:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c52:	fffff097          	auipc	ra,0xfffff
    80002c56:	f62080e7          	jalr	-158(ra) # 80001bb4 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002c5a:	653c                	ld	a5,72(a0)
    80002c5c:	02f4f863          	bgeu	s1,a5,80002c8c <fetchaddr+0x4a>
    80002c60:	00848713          	addi	a4,s1,8
    80002c64:	02e7e663          	bltu	a5,a4,80002c90 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c68:	46a1                	li	a3,8
    80002c6a:	8626                	mv	a2,s1
    80002c6c:	85ca                	mv	a1,s2
    80002c6e:	6928                	ld	a0,80(a0)
    80002c70:	fffff097          	auipc	ra,0xfffff
    80002c74:	c1c080e7          	jalr	-996(ra) # 8000188c <copyin>
    80002c78:	00a03533          	snez	a0,a0
    80002c7c:	40a0053b          	negw	a0,a0
}
    80002c80:	60e2                	ld	ra,24(sp)
    80002c82:	6442                	ld	s0,16(sp)
    80002c84:	64a2                	ld	s1,8(sp)
    80002c86:	6902                	ld	s2,0(sp)
    80002c88:	6105                	addi	sp,sp,32
    80002c8a:	8082                	ret
    return -1;
    80002c8c:	557d                	li	a0,-1
    80002c8e:	bfcd                	j	80002c80 <fetchaddr+0x3e>
    80002c90:	557d                	li	a0,-1
    80002c92:	b7fd                	j	80002c80 <fetchaddr+0x3e>

0000000080002c94 <fetchstr>:
{
    80002c94:	7179                	addi	sp,sp,-48
    80002c96:	f406                	sd	ra,40(sp)
    80002c98:	f022                	sd	s0,32(sp)
    80002c9a:	ec26                	sd	s1,24(sp)
    80002c9c:	e84a                	sd	s2,16(sp)
    80002c9e:	e44e                	sd	s3,8(sp)
    80002ca0:	1800                	addi	s0,sp,48
    80002ca2:	89aa                	mv	s3,a0
    80002ca4:	84ae                	mv	s1,a1
    80002ca6:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	f0c080e7          	jalr	-244(ra) # 80001bb4 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002cb0:	86ca                	mv	a3,s2
    80002cb2:	864e                	mv	a2,s3
    80002cb4:	85a6                	mv	a1,s1
    80002cb6:	6928                	ld	a0,80(a0)
    80002cb8:	fffff097          	auipc	ra,0xfffff
    80002cbc:	c62080e7          	jalr	-926(ra) # 8000191a <copyinstr>
    80002cc0:	00054e63          	bltz	a0,80002cdc <fetchstr+0x48>
  return strlen(buf);
    80002cc4:	8526                	mv	a0,s1
    80002cc6:	ffffe097          	auipc	ra,0xffffe
    80002cca:	21c080e7          	jalr	540(ra) # 80000ee2 <strlen>
}
    80002cce:	70a2                	ld	ra,40(sp)
    80002cd0:	7402                	ld	s0,32(sp)
    80002cd2:	64e2                	ld	s1,24(sp)
    80002cd4:	6942                	ld	s2,16(sp)
    80002cd6:	69a2                	ld	s3,8(sp)
    80002cd8:	6145                	addi	sp,sp,48
    80002cda:	8082                	ret
    return -1;
    80002cdc:	557d                	li	a0,-1
    80002cde:	bfc5                	j	80002cce <fetchstr+0x3a>

0000000080002ce0 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002ce0:	1101                	addi	sp,sp,-32
    80002ce2:	ec06                	sd	ra,24(sp)
    80002ce4:	e822                	sd	s0,16(sp)
    80002ce6:	e426                	sd	s1,8(sp)
    80002ce8:	1000                	addi	s0,sp,32
    80002cea:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cec:	00000097          	auipc	ra,0x0
    80002cf0:	eee080e7          	jalr	-274(ra) # 80002bda <argraw>
    80002cf4:	c088                	sw	a0,0(s1)
}
    80002cf6:	60e2                	ld	ra,24(sp)
    80002cf8:	6442                	ld	s0,16(sp)
    80002cfa:	64a2                	ld	s1,8(sp)
    80002cfc:	6105                	addi	sp,sp,32
    80002cfe:	8082                	ret

0000000080002d00 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002d00:	1101                	addi	sp,sp,-32
    80002d02:	ec06                	sd	ra,24(sp)
    80002d04:	e822                	sd	s0,16(sp)
    80002d06:	e426                	sd	s1,8(sp)
    80002d08:	1000                	addi	s0,sp,32
    80002d0a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d0c:	00000097          	auipc	ra,0x0
    80002d10:	ece080e7          	jalr	-306(ra) # 80002bda <argraw>
    80002d14:	e088                	sd	a0,0(s1)
}
    80002d16:	60e2                	ld	ra,24(sp)
    80002d18:	6442                	ld	s0,16(sp)
    80002d1a:	64a2                	ld	s1,8(sp)
    80002d1c:	6105                	addi	sp,sp,32
    80002d1e:	8082                	ret

0000000080002d20 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002d20:	1101                	addi	sp,sp,-32
    80002d22:	ec06                	sd	ra,24(sp)
    80002d24:	e822                	sd	s0,16(sp)
    80002d26:	e426                	sd	s1,8(sp)
    80002d28:	e04a                	sd	s2,0(sp)
    80002d2a:	1000                	addi	s0,sp,32
    80002d2c:	892e                	mv	s2,a1
    80002d2e:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002d30:	00000097          	auipc	ra,0x0
    80002d34:	eaa080e7          	jalr	-342(ra) # 80002bda <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002d38:	8626                	mv	a2,s1
    80002d3a:	85ca                	mv	a1,s2
    80002d3c:	00000097          	auipc	ra,0x0
    80002d40:	f58080e7          	jalr	-168(ra) # 80002c94 <fetchstr>
}
    80002d44:	60e2                	ld	ra,24(sp)
    80002d46:	6442                	ld	s0,16(sp)
    80002d48:	64a2                	ld	s1,8(sp)
    80002d4a:	6902                	ld	s2,0(sp)
    80002d4c:	6105                	addi	sp,sp,32
    80002d4e:	8082                	ret

0000000080002d50 <syscall>:
    [SYS_close] sys_close,
    [SYS_nanotime] sys_nanotime,
};

void syscall(void)
{
    80002d50:	1101                	addi	sp,sp,-32
    80002d52:	ec06                	sd	ra,24(sp)
    80002d54:	e822                	sd	s0,16(sp)
    80002d56:	e426                	sd	s1,8(sp)
    80002d58:	e04a                	sd	s2,0(sp)
    80002d5a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d5c:	fffff097          	auipc	ra,0xfffff
    80002d60:	e58080e7          	jalr	-424(ra) # 80001bb4 <myproc>
    80002d64:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d66:	05853903          	ld	s2,88(a0)
    80002d6a:	0a893783          	ld	a5,168(s2)
    80002d6e:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002d72:	37fd                	addiw	a5,a5,-1
    80002d74:	4755                	li	a4,21
    80002d76:	00f76f63          	bltu	a4,a5,80002d94 <syscall+0x44>
    80002d7a:	00369713          	slli	a4,a3,0x3
    80002d7e:	00006797          	auipc	a5,0x6
    80002d82:	aa278793          	addi	a5,a5,-1374 # 80008820 <syscalls>
    80002d86:	97ba                	add	a5,a5,a4
    80002d88:	639c                	ld	a5,0(a5)
    80002d8a:	c789                	beqz	a5,80002d94 <syscall+0x44>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002d8c:	9782                	jalr	a5
    80002d8e:	06a93823          	sd	a0,112(s2)
    80002d92:	a839                	j	80002db0 <syscall+0x60>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002d94:	15848613          	addi	a2,s1,344
    80002d98:	588c                	lw	a1,48(s1)
    80002d9a:	00005517          	auipc	a0,0x5
    80002d9e:	6c650513          	addi	a0,a0,1734 # 80008460 <etext+0x460>
    80002da2:	ffffe097          	auipc	ra,0xffffe
    80002da6:	806080e7          	jalr	-2042(ra) # 800005a8 <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002daa:	6cbc                	ld	a5,88(s1)
    80002dac:	577d                	li	a4,-1
    80002dae:	fbb8                	sd	a4,112(a5)
  }
}
    80002db0:	60e2                	ld	ra,24(sp)
    80002db2:	6442                	ld	s0,16(sp)
    80002db4:	64a2                	ld	s1,8(sp)
    80002db6:	6902                	ld	s2,0(sp)
    80002db8:	6105                	addi	sp,sp,32
    80002dba:	8082                	ret

0000000080002dbc <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002dbc:	1101                	addi	sp,sp,-32
    80002dbe:	ec06                	sd	ra,24(sp)
    80002dc0:	e822                	sd	s0,16(sp)
    80002dc2:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002dc4:	fec40593          	addi	a1,s0,-20
    80002dc8:	4501                	li	a0,0
    80002dca:	00000097          	auipc	ra,0x0
    80002dce:	f16080e7          	jalr	-234(ra) # 80002ce0 <argint>
  exit(n);
    80002dd2:	fec42503          	lw	a0,-20(s0)
    80002dd6:	fffff097          	auipc	ra,0xfffff
    80002dda:	5c0080e7          	jalr	1472(ra) # 80002396 <exit>
  return 0; // not reached
}
    80002dde:	4501                	li	a0,0
    80002de0:	60e2                	ld	ra,24(sp)
    80002de2:	6442                	ld	s0,16(sp)
    80002de4:	6105                	addi	sp,sp,32
    80002de6:	8082                	ret

0000000080002de8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002de8:	1141                	addi	sp,sp,-16
    80002dea:	e406                	sd	ra,8(sp)
    80002dec:	e022                	sd	s0,0(sp)
    80002dee:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002df0:	fffff097          	auipc	ra,0xfffff
    80002df4:	dc4080e7          	jalr	-572(ra) # 80001bb4 <myproc>
}
    80002df8:	5908                	lw	a0,48(a0)
    80002dfa:	60a2                	ld	ra,8(sp)
    80002dfc:	6402                	ld	s0,0(sp)
    80002dfe:	0141                	addi	sp,sp,16
    80002e00:	8082                	ret

0000000080002e02 <sys_fork>:

uint64
sys_fork(void)
{
    80002e02:	1141                	addi	sp,sp,-16
    80002e04:	e406                	sd	ra,8(sp)
    80002e06:	e022                	sd	s0,0(sp)
    80002e08:	0800                	addi	s0,sp,16
  return fork();
    80002e0a:	fffff097          	auipc	ra,0xfffff
    80002e0e:	162080e7          	jalr	354(ra) # 80001f6c <fork>
}
    80002e12:	60a2                	ld	ra,8(sp)
    80002e14:	6402                	ld	s0,0(sp)
    80002e16:	0141                	addi	sp,sp,16
    80002e18:	8082                	ret

0000000080002e1a <sys_wait>:

uint64
sys_wait(void)
{
    80002e1a:	1101                	addi	sp,sp,-32
    80002e1c:	ec06                	sd	ra,24(sp)
    80002e1e:	e822                	sd	s0,16(sp)
    80002e20:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e22:	fe840593          	addi	a1,s0,-24
    80002e26:	4501                	li	a0,0
    80002e28:	00000097          	auipc	ra,0x0
    80002e2c:	ed8080e7          	jalr	-296(ra) # 80002d00 <argaddr>
  return wait(p);
    80002e30:	fe843503          	ld	a0,-24(s0)
    80002e34:	fffff097          	auipc	ra,0xfffff
    80002e38:	70c080e7          	jalr	1804(ra) # 80002540 <wait>
}
    80002e3c:	60e2                	ld	ra,24(sp)
    80002e3e:	6442                	ld	s0,16(sp)
    80002e40:	6105                	addi	sp,sp,32
    80002e42:	8082                	ret

0000000080002e44 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e44:	7179                	addi	sp,sp,-48
    80002e46:	f406                	sd	ra,40(sp)
    80002e48:	f022                	sd	s0,32(sp)
    80002e4a:	ec26                	sd	s1,24(sp)
    80002e4c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002e4e:	fdc40593          	addi	a1,s0,-36
    80002e52:	4501                	li	a0,0
    80002e54:	00000097          	auipc	ra,0x0
    80002e58:	e8c080e7          	jalr	-372(ra) # 80002ce0 <argint>
  addr = myproc()->sz;
    80002e5c:	fffff097          	auipc	ra,0xfffff
    80002e60:	d58080e7          	jalr	-680(ra) # 80001bb4 <myproc>
    80002e64:	653c                	ld	a5,72(a0)
    80002e66:	84be                	mv	s1,a5
  if (growproc(n) < 0)
    80002e68:	fdc42503          	lw	a0,-36(s0)
    80002e6c:	fffff097          	auipc	ra,0xfffff
    80002e70:	0a4080e7          	jalr	164(ra) # 80001f10 <growproc>
    80002e74:	00054863          	bltz	a0,80002e84 <sys_sbrk+0x40>
    return -1;
  return addr;
}
    80002e78:	8526                	mv	a0,s1
    80002e7a:	70a2                	ld	ra,40(sp)
    80002e7c:	7402                	ld	s0,32(sp)
    80002e7e:	64e2                	ld	s1,24(sp)
    80002e80:	6145                	addi	sp,sp,48
    80002e82:	8082                	ret
    return -1;
    80002e84:	57fd                	li	a5,-1
    80002e86:	84be                	mv	s1,a5
    80002e88:	bfc5                	j	80002e78 <sys_sbrk+0x34>

0000000080002e8a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e8a:	7139                	addi	sp,sp,-64
    80002e8c:	fc06                	sd	ra,56(sp)
    80002e8e:	f822                	sd	s0,48(sp)
    80002e90:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002e92:	fcc40593          	addi	a1,s0,-52
    80002e96:	4501                	li	a0,0
    80002e98:	00000097          	auipc	ra,0x0
    80002e9c:	e48080e7          	jalr	-440(ra) # 80002ce0 <argint>
  acquire(&tickslock);
    80002ea0:	00014517          	auipc	a0,0x14
    80002ea4:	b6050513          	addi	a0,a0,-1184 # 80016a00 <tickslock>
    80002ea8:	ffffe097          	auipc	ra,0xffffe
    80002eac:	db4080e7          	jalr	-588(ra) # 80000c5c <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n)
    80002eb0:	fcc42783          	lw	a5,-52(s0)
    80002eb4:	cba9                	beqz	a5,80002f06 <sys_sleep+0x7c>
    80002eb6:	f426                	sd	s1,40(sp)
    80002eb8:	f04a                	sd	s2,32(sp)
    80002eba:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002ebc:	00006997          	auipc	s3,0x6
    80002ec0:	aa49a983          	lw	s3,-1372(s3) # 80008960 <ticks>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002ec4:	00014917          	auipc	s2,0x14
    80002ec8:	b3c90913          	addi	s2,s2,-1220 # 80016a00 <tickslock>
    80002ecc:	00006497          	auipc	s1,0x6
    80002ed0:	a9448493          	addi	s1,s1,-1388 # 80008960 <ticks>
    if (killed(myproc()))
    80002ed4:	fffff097          	auipc	ra,0xfffff
    80002ed8:	ce0080e7          	jalr	-800(ra) # 80001bb4 <myproc>
    80002edc:	fffff097          	auipc	ra,0xfffff
    80002ee0:	632080e7          	jalr	1586(ra) # 8000250e <killed>
    80002ee4:	ed15                	bnez	a0,80002f20 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002ee6:	85ca                	mv	a1,s2
    80002ee8:	8526                	mv	a0,s1
    80002eea:	fffff097          	auipc	ra,0xfffff
    80002eee:	378080e7          	jalr	888(ra) # 80002262 <sleep>
  while (ticks - ticks0 < n)
    80002ef2:	409c                	lw	a5,0(s1)
    80002ef4:	413787bb          	subw	a5,a5,s3
    80002ef8:	fcc42703          	lw	a4,-52(s0)
    80002efc:	fce7ece3          	bltu	a5,a4,80002ed4 <sys_sleep+0x4a>
    80002f00:	74a2                	ld	s1,40(sp)
    80002f02:	7902                	ld	s2,32(sp)
    80002f04:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002f06:	00014517          	auipc	a0,0x14
    80002f0a:	afa50513          	addi	a0,a0,-1286 # 80016a00 <tickslock>
    80002f0e:	ffffe097          	auipc	ra,0xffffe
    80002f12:	dfe080e7          	jalr	-514(ra) # 80000d0c <release>
  return 0;
    80002f16:	4501                	li	a0,0
}
    80002f18:	70e2                	ld	ra,56(sp)
    80002f1a:	7442                	ld	s0,48(sp)
    80002f1c:	6121                	addi	sp,sp,64
    80002f1e:	8082                	ret
      release(&tickslock);
    80002f20:	00014517          	auipc	a0,0x14
    80002f24:	ae050513          	addi	a0,a0,-1312 # 80016a00 <tickslock>
    80002f28:	ffffe097          	auipc	ra,0xffffe
    80002f2c:	de4080e7          	jalr	-540(ra) # 80000d0c <release>
      return -1;
    80002f30:	557d                	li	a0,-1
    80002f32:	74a2                	ld	s1,40(sp)
    80002f34:	7902                	ld	s2,32(sp)
    80002f36:	69e2                	ld	s3,24(sp)
    80002f38:	b7c5                	j	80002f18 <sys_sleep+0x8e>

0000000080002f3a <sys_kill>:

uint64
sys_kill(void)
{
    80002f3a:	1101                	addi	sp,sp,-32
    80002f3c:	ec06                	sd	ra,24(sp)
    80002f3e:	e822                	sd	s0,16(sp)
    80002f40:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002f42:	fec40593          	addi	a1,s0,-20
    80002f46:	4501                	li	a0,0
    80002f48:	00000097          	auipc	ra,0x0
    80002f4c:	d98080e7          	jalr	-616(ra) # 80002ce0 <argint>
  return kill(pid);
    80002f50:	fec42503          	lw	a0,-20(s0)
    80002f54:	fffff097          	auipc	ra,0xfffff
    80002f58:	51c080e7          	jalr	1308(ra) # 80002470 <kill>
}
    80002f5c:	60e2                	ld	ra,24(sp)
    80002f5e:	6442                	ld	s0,16(sp)
    80002f60:	6105                	addi	sp,sp,32
    80002f62:	8082                	ret

0000000080002f64 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f64:	1101                	addi	sp,sp,-32
    80002f66:	ec06                	sd	ra,24(sp)
    80002f68:	e822                	sd	s0,16(sp)
    80002f6a:	e426                	sd	s1,8(sp)
    80002f6c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f6e:	00014517          	auipc	a0,0x14
    80002f72:	a9250513          	addi	a0,a0,-1390 # 80016a00 <tickslock>
    80002f76:	ffffe097          	auipc	ra,0xffffe
    80002f7a:	ce6080e7          	jalr	-794(ra) # 80000c5c <acquire>
  xticks = ticks;
    80002f7e:	00006797          	auipc	a5,0x6
    80002f82:	9e27a783          	lw	a5,-1566(a5) # 80008960 <ticks>
    80002f86:	84be                	mv	s1,a5
  release(&tickslock);
    80002f88:	00014517          	auipc	a0,0x14
    80002f8c:	a7850513          	addi	a0,a0,-1416 # 80016a00 <tickslock>
    80002f90:	ffffe097          	auipc	ra,0xffffe
    80002f94:	d7c080e7          	jalr	-644(ra) # 80000d0c <release>
  return xticks;
}
    80002f98:	02049513          	slli	a0,s1,0x20
    80002f9c:	9101                	srli	a0,a0,0x20
    80002f9e:	60e2                	ld	ra,24(sp)
    80002fa0:	6442                	ld	s0,16(sp)
    80002fa2:	64a2                	ld	s1,8(sp)
    80002fa4:	6105                	addi	sp,sp,32
    80002fa6:	8082                	ret

0000000080002fa8 <sys_nanotime>:

// return the time in nanoseconds since the UNIX epoch
uint64
sys_nanotime(void) // added by John Hughes
{
    80002fa8:	1141                	addi	sp,sp,-16
    80002faa:	e406                	sd	ra,8(sp)
    80002fac:	e022                	sd	s0,0(sp)
    80002fae:	0800                	addi	s0,sp,16
  return *(uint64 *)GOLDFISH; // read the nanosecond timer from the GOLDFISH address
}
    80002fb0:	001017b7          	lui	a5,0x101
    80002fb4:	6388                	ld	a0,0(a5)
    80002fb6:	60a2                	ld	ra,8(sp)
    80002fb8:	6402                	ld	s0,0(sp)
    80002fba:	0141                	addi	sp,sp,16
    80002fbc:	8082                	ret

0000000080002fbe <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002fbe:	7179                	addi	sp,sp,-48
    80002fc0:	f406                	sd	ra,40(sp)
    80002fc2:	f022                	sd	s0,32(sp)
    80002fc4:	ec26                	sd	s1,24(sp)
    80002fc6:	e84a                	sd	s2,16(sp)
    80002fc8:	e44e                	sd	s3,8(sp)
    80002fca:	e052                	sd	s4,0(sp)
    80002fcc:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002fce:	00005597          	auipc	a1,0x5
    80002fd2:	4b258593          	addi	a1,a1,1202 # 80008480 <etext+0x480>
    80002fd6:	00014517          	auipc	a0,0x14
    80002fda:	a4250513          	addi	a0,a0,-1470 # 80016a18 <bcache>
    80002fde:	ffffe097          	auipc	ra,0xffffe
    80002fe2:	be4080e7          	jalr	-1052(ra) # 80000bc2 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002fe6:	0001c797          	auipc	a5,0x1c
    80002fea:	a3278793          	addi	a5,a5,-1486 # 8001ea18 <bcache+0x8000>
    80002fee:	0001c717          	auipc	a4,0x1c
    80002ff2:	c9270713          	addi	a4,a4,-878 # 8001ec80 <bcache+0x8268>
    80002ff6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ffa:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ffe:	00014497          	auipc	s1,0x14
    80003002:	a3248493          	addi	s1,s1,-1486 # 80016a30 <bcache+0x18>
    b->next = bcache.head.next;
    80003006:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003008:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000300a:	00005a17          	auipc	s4,0x5
    8000300e:	47ea0a13          	addi	s4,s4,1150 # 80008488 <etext+0x488>
    b->next = bcache.head.next;
    80003012:	2b893783          	ld	a5,696(s2)
    80003016:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003018:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000301c:	85d2                	mv	a1,s4
    8000301e:	01048513          	addi	a0,s1,16
    80003022:	00001097          	auipc	ra,0x1
    80003026:	4ec080e7          	jalr	1260(ra) # 8000450e <initsleeplock>
    bcache.head.next->prev = b;
    8000302a:	2b893783          	ld	a5,696(s2)
    8000302e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003030:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003034:	45848493          	addi	s1,s1,1112
    80003038:	fd349de3          	bne	s1,s3,80003012 <binit+0x54>
  }
}
    8000303c:	70a2                	ld	ra,40(sp)
    8000303e:	7402                	ld	s0,32(sp)
    80003040:	64e2                	ld	s1,24(sp)
    80003042:	6942                	ld	s2,16(sp)
    80003044:	69a2                	ld	s3,8(sp)
    80003046:	6a02                	ld	s4,0(sp)
    80003048:	6145                	addi	sp,sp,48
    8000304a:	8082                	ret

000000008000304c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000304c:	7179                	addi	sp,sp,-48
    8000304e:	f406                	sd	ra,40(sp)
    80003050:	f022                	sd	s0,32(sp)
    80003052:	ec26                	sd	s1,24(sp)
    80003054:	e84a                	sd	s2,16(sp)
    80003056:	e44e                	sd	s3,8(sp)
    80003058:	1800                	addi	s0,sp,48
    8000305a:	892a                	mv	s2,a0
    8000305c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000305e:	00014517          	auipc	a0,0x14
    80003062:	9ba50513          	addi	a0,a0,-1606 # 80016a18 <bcache>
    80003066:	ffffe097          	auipc	ra,0xffffe
    8000306a:	bf6080e7          	jalr	-1034(ra) # 80000c5c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000306e:	0001c497          	auipc	s1,0x1c
    80003072:	c624b483          	ld	s1,-926(s1) # 8001ecd0 <bcache+0x82b8>
    80003076:	0001c797          	auipc	a5,0x1c
    8000307a:	c0a78793          	addi	a5,a5,-1014 # 8001ec80 <bcache+0x8268>
    8000307e:	02f48f63          	beq	s1,a5,800030bc <bread+0x70>
    80003082:	873e                	mv	a4,a5
    80003084:	a021                	j	8000308c <bread+0x40>
    80003086:	68a4                	ld	s1,80(s1)
    80003088:	02e48a63          	beq	s1,a4,800030bc <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000308c:	449c                	lw	a5,8(s1)
    8000308e:	ff279ce3          	bne	a5,s2,80003086 <bread+0x3a>
    80003092:	44dc                	lw	a5,12(s1)
    80003094:	ff3799e3          	bne	a5,s3,80003086 <bread+0x3a>
      b->refcnt++;
    80003098:	40bc                	lw	a5,64(s1)
    8000309a:	2785                	addiw	a5,a5,1
    8000309c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000309e:	00014517          	auipc	a0,0x14
    800030a2:	97a50513          	addi	a0,a0,-1670 # 80016a18 <bcache>
    800030a6:	ffffe097          	auipc	ra,0xffffe
    800030aa:	c66080e7          	jalr	-922(ra) # 80000d0c <release>
      acquiresleep(&b->lock);
    800030ae:	01048513          	addi	a0,s1,16
    800030b2:	00001097          	auipc	ra,0x1
    800030b6:	496080e7          	jalr	1174(ra) # 80004548 <acquiresleep>
      return b;
    800030ba:	a8b9                	j	80003118 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030bc:	0001c497          	auipc	s1,0x1c
    800030c0:	c0c4b483          	ld	s1,-1012(s1) # 8001ecc8 <bcache+0x82b0>
    800030c4:	0001c797          	auipc	a5,0x1c
    800030c8:	bbc78793          	addi	a5,a5,-1092 # 8001ec80 <bcache+0x8268>
    800030cc:	00f48863          	beq	s1,a5,800030dc <bread+0x90>
    800030d0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800030d2:	40bc                	lw	a5,64(s1)
    800030d4:	cf81                	beqz	a5,800030ec <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030d6:	64a4                	ld	s1,72(s1)
    800030d8:	fee49de3          	bne	s1,a4,800030d2 <bread+0x86>
  panic("bget: no buffers");
    800030dc:	00005517          	auipc	a0,0x5
    800030e0:	3b450513          	addi	a0,a0,948 # 80008490 <etext+0x490>
    800030e4:	ffffd097          	auipc	ra,0xffffd
    800030e8:	47a080e7          	jalr	1146(ra) # 8000055e <panic>
      b->dev = dev;
    800030ec:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800030f0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800030f4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800030f8:	4785                	li	a5,1
    800030fa:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030fc:	00014517          	auipc	a0,0x14
    80003100:	91c50513          	addi	a0,a0,-1764 # 80016a18 <bcache>
    80003104:	ffffe097          	auipc	ra,0xffffe
    80003108:	c08080e7          	jalr	-1016(ra) # 80000d0c <release>
      acquiresleep(&b->lock);
    8000310c:	01048513          	addi	a0,s1,16
    80003110:	00001097          	auipc	ra,0x1
    80003114:	438080e7          	jalr	1080(ra) # 80004548 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003118:	409c                	lw	a5,0(s1)
    8000311a:	cb89                	beqz	a5,8000312c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000311c:	8526                	mv	a0,s1
    8000311e:	70a2                	ld	ra,40(sp)
    80003120:	7402                	ld	s0,32(sp)
    80003122:	64e2                	ld	s1,24(sp)
    80003124:	6942                	ld	s2,16(sp)
    80003126:	69a2                	ld	s3,8(sp)
    80003128:	6145                	addi	sp,sp,48
    8000312a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000312c:	4581                	li	a1,0
    8000312e:	8526                	mv	a0,s1
    80003130:	00003097          	auipc	ra,0x3
    80003134:	128080e7          	jalr	296(ra) # 80006258 <virtio_disk_rw>
    b->valid = 1;
    80003138:	4785                	li	a5,1
    8000313a:	c09c                	sw	a5,0(s1)
  return b;
    8000313c:	b7c5                	j	8000311c <bread+0xd0>

000000008000313e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000313e:	1101                	addi	sp,sp,-32
    80003140:	ec06                	sd	ra,24(sp)
    80003142:	e822                	sd	s0,16(sp)
    80003144:	e426                	sd	s1,8(sp)
    80003146:	1000                	addi	s0,sp,32
    80003148:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000314a:	0541                	addi	a0,a0,16
    8000314c:	00001097          	auipc	ra,0x1
    80003150:	496080e7          	jalr	1174(ra) # 800045e2 <holdingsleep>
    80003154:	cd01                	beqz	a0,8000316c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003156:	4585                	li	a1,1
    80003158:	8526                	mv	a0,s1
    8000315a:	00003097          	auipc	ra,0x3
    8000315e:	0fe080e7          	jalr	254(ra) # 80006258 <virtio_disk_rw>
}
    80003162:	60e2                	ld	ra,24(sp)
    80003164:	6442                	ld	s0,16(sp)
    80003166:	64a2                	ld	s1,8(sp)
    80003168:	6105                	addi	sp,sp,32
    8000316a:	8082                	ret
    panic("bwrite");
    8000316c:	00005517          	auipc	a0,0x5
    80003170:	33c50513          	addi	a0,a0,828 # 800084a8 <etext+0x4a8>
    80003174:	ffffd097          	auipc	ra,0xffffd
    80003178:	3ea080e7          	jalr	1002(ra) # 8000055e <panic>

000000008000317c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000317c:	1101                	addi	sp,sp,-32
    8000317e:	ec06                	sd	ra,24(sp)
    80003180:	e822                	sd	s0,16(sp)
    80003182:	e426                	sd	s1,8(sp)
    80003184:	e04a                	sd	s2,0(sp)
    80003186:	1000                	addi	s0,sp,32
    80003188:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000318a:	01050913          	addi	s2,a0,16
    8000318e:	854a                	mv	a0,s2
    80003190:	00001097          	auipc	ra,0x1
    80003194:	452080e7          	jalr	1106(ra) # 800045e2 <holdingsleep>
    80003198:	c535                	beqz	a0,80003204 <brelse+0x88>
    panic("brelse");

  releasesleep(&b->lock);
    8000319a:	854a                	mv	a0,s2
    8000319c:	00001097          	auipc	ra,0x1
    800031a0:	402080e7          	jalr	1026(ra) # 8000459e <releasesleep>

  acquire(&bcache.lock);
    800031a4:	00014517          	auipc	a0,0x14
    800031a8:	87450513          	addi	a0,a0,-1932 # 80016a18 <bcache>
    800031ac:	ffffe097          	auipc	ra,0xffffe
    800031b0:	ab0080e7          	jalr	-1360(ra) # 80000c5c <acquire>
  b->refcnt--;
    800031b4:	40bc                	lw	a5,64(s1)
    800031b6:	37fd                	addiw	a5,a5,-1
    800031b8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031ba:	e79d                	bnez	a5,800031e8 <brelse+0x6c>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031bc:	68b8                	ld	a4,80(s1)
    800031be:	64bc                	ld	a5,72(s1)
    800031c0:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800031c2:	68b8                	ld	a4,80(s1)
    800031c4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031c6:	0001c797          	auipc	a5,0x1c
    800031ca:	85278793          	addi	a5,a5,-1966 # 8001ea18 <bcache+0x8000>
    800031ce:	2b87b703          	ld	a4,696(a5)
    800031d2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800031d4:	0001c717          	auipc	a4,0x1c
    800031d8:	aac70713          	addi	a4,a4,-1364 # 8001ec80 <bcache+0x8268>
    800031dc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800031de:	2b87b703          	ld	a4,696(a5)
    800031e2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800031e4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800031e8:	00014517          	auipc	a0,0x14
    800031ec:	83050513          	addi	a0,a0,-2000 # 80016a18 <bcache>
    800031f0:	ffffe097          	auipc	ra,0xffffe
    800031f4:	b1c080e7          	jalr	-1252(ra) # 80000d0c <release>
}
    800031f8:	60e2                	ld	ra,24(sp)
    800031fa:	6442                	ld	s0,16(sp)
    800031fc:	64a2                	ld	s1,8(sp)
    800031fe:	6902                	ld	s2,0(sp)
    80003200:	6105                	addi	sp,sp,32
    80003202:	8082                	ret
    panic("brelse");
    80003204:	00005517          	auipc	a0,0x5
    80003208:	2ac50513          	addi	a0,a0,684 # 800084b0 <etext+0x4b0>
    8000320c:	ffffd097          	auipc	ra,0xffffd
    80003210:	352080e7          	jalr	850(ra) # 8000055e <panic>

0000000080003214 <bpin>:

void
bpin(struct buf *b) {
    80003214:	1101                	addi	sp,sp,-32
    80003216:	ec06                	sd	ra,24(sp)
    80003218:	e822                	sd	s0,16(sp)
    8000321a:	e426                	sd	s1,8(sp)
    8000321c:	1000                	addi	s0,sp,32
    8000321e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003220:	00013517          	auipc	a0,0x13
    80003224:	7f850513          	addi	a0,a0,2040 # 80016a18 <bcache>
    80003228:	ffffe097          	auipc	ra,0xffffe
    8000322c:	a34080e7          	jalr	-1484(ra) # 80000c5c <acquire>
  b->refcnt++;
    80003230:	40bc                	lw	a5,64(s1)
    80003232:	2785                	addiw	a5,a5,1
    80003234:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003236:	00013517          	auipc	a0,0x13
    8000323a:	7e250513          	addi	a0,a0,2018 # 80016a18 <bcache>
    8000323e:	ffffe097          	auipc	ra,0xffffe
    80003242:	ace080e7          	jalr	-1330(ra) # 80000d0c <release>
}
    80003246:	60e2                	ld	ra,24(sp)
    80003248:	6442                	ld	s0,16(sp)
    8000324a:	64a2                	ld	s1,8(sp)
    8000324c:	6105                	addi	sp,sp,32
    8000324e:	8082                	ret

0000000080003250 <bunpin>:

void
bunpin(struct buf *b) {
    80003250:	1101                	addi	sp,sp,-32
    80003252:	ec06                	sd	ra,24(sp)
    80003254:	e822                	sd	s0,16(sp)
    80003256:	e426                	sd	s1,8(sp)
    80003258:	1000                	addi	s0,sp,32
    8000325a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000325c:	00013517          	auipc	a0,0x13
    80003260:	7bc50513          	addi	a0,a0,1980 # 80016a18 <bcache>
    80003264:	ffffe097          	auipc	ra,0xffffe
    80003268:	9f8080e7          	jalr	-1544(ra) # 80000c5c <acquire>
  b->refcnt--;
    8000326c:	40bc                	lw	a5,64(s1)
    8000326e:	37fd                	addiw	a5,a5,-1
    80003270:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003272:	00013517          	auipc	a0,0x13
    80003276:	7a650513          	addi	a0,a0,1958 # 80016a18 <bcache>
    8000327a:	ffffe097          	auipc	ra,0xffffe
    8000327e:	a92080e7          	jalr	-1390(ra) # 80000d0c <release>
}
    80003282:	60e2                	ld	ra,24(sp)
    80003284:	6442                	ld	s0,16(sp)
    80003286:	64a2                	ld	s1,8(sp)
    80003288:	6105                	addi	sp,sp,32
    8000328a:	8082                	ret

000000008000328c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000328c:	1101                	addi	sp,sp,-32
    8000328e:	ec06                	sd	ra,24(sp)
    80003290:	e822                	sd	s0,16(sp)
    80003292:	e426                	sd	s1,8(sp)
    80003294:	e04a                	sd	s2,0(sp)
    80003296:	1000                	addi	s0,sp,32
    80003298:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000329a:	00d5d79b          	srliw	a5,a1,0xd
    8000329e:	0001c597          	auipc	a1,0x1c
    800032a2:	e565a583          	lw	a1,-426(a1) # 8001f0f4 <sb+0x1c>
    800032a6:	9dbd                	addw	a1,a1,a5
    800032a8:	00000097          	auipc	ra,0x0
    800032ac:	da4080e7          	jalr	-604(ra) # 8000304c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032b0:	0074f713          	andi	a4,s1,7
    800032b4:	4785                	li	a5,1
    800032b6:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    800032ba:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    800032bc:	90d9                	srli	s1,s1,0x36
    800032be:	00950733          	add	a4,a0,s1
    800032c2:	05874703          	lbu	a4,88(a4)
    800032c6:	00e7f6b3          	and	a3,a5,a4
    800032ca:	c69d                	beqz	a3,800032f8 <bfree+0x6c>
    800032cc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032ce:	94aa                	add	s1,s1,a0
    800032d0:	fff7c793          	not	a5,a5
    800032d4:	8f7d                	and	a4,a4,a5
    800032d6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800032da:	00001097          	auipc	ra,0x1
    800032de:	14e080e7          	jalr	334(ra) # 80004428 <log_write>
  brelse(bp);
    800032e2:	854a                	mv	a0,s2
    800032e4:	00000097          	auipc	ra,0x0
    800032e8:	e98080e7          	jalr	-360(ra) # 8000317c <brelse>
}
    800032ec:	60e2                	ld	ra,24(sp)
    800032ee:	6442                	ld	s0,16(sp)
    800032f0:	64a2                	ld	s1,8(sp)
    800032f2:	6902                	ld	s2,0(sp)
    800032f4:	6105                	addi	sp,sp,32
    800032f6:	8082                	ret
    panic("freeing free block");
    800032f8:	00005517          	auipc	a0,0x5
    800032fc:	1c050513          	addi	a0,a0,448 # 800084b8 <etext+0x4b8>
    80003300:	ffffd097          	auipc	ra,0xffffd
    80003304:	25e080e7          	jalr	606(ra) # 8000055e <panic>

0000000080003308 <balloc>:
{
    80003308:	715d                	addi	sp,sp,-80
    8000330a:	e486                	sd	ra,72(sp)
    8000330c:	e0a2                	sd	s0,64(sp)
    8000330e:	fc26                	sd	s1,56(sp)
    80003310:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003312:	0001c797          	auipc	a5,0x1c
    80003316:	dca7a783          	lw	a5,-566(a5) # 8001f0dc <sb+0x4>
    8000331a:	10078263          	beqz	a5,8000341e <balloc+0x116>
    8000331e:	f84a                	sd	s2,48(sp)
    80003320:	f44e                	sd	s3,40(sp)
    80003322:	f052                	sd	s4,32(sp)
    80003324:	ec56                	sd	s5,24(sp)
    80003326:	e85a                	sd	s6,16(sp)
    80003328:	e45e                	sd	s7,8(sp)
    8000332a:	e062                	sd	s8,0(sp)
    8000332c:	8baa                	mv	s7,a0
    8000332e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003330:	0001cb17          	auipc	s6,0x1c
    80003334:	da8b0b13          	addi	s6,s6,-600 # 8001f0d8 <sb>
      m = 1 << (bi % 8);
    80003338:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000333a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000333c:	6c09                	lui	s8,0x2
    8000333e:	a049                	j	800033c0 <balloc+0xb8>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003340:	97ca                	add	a5,a5,s2
    80003342:	8e55                	or	a2,a2,a3
    80003344:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003348:	854a                	mv	a0,s2
    8000334a:	00001097          	auipc	ra,0x1
    8000334e:	0de080e7          	jalr	222(ra) # 80004428 <log_write>
        brelse(bp);
    80003352:	854a                	mv	a0,s2
    80003354:	00000097          	auipc	ra,0x0
    80003358:	e28080e7          	jalr	-472(ra) # 8000317c <brelse>
  bp = bread(dev, bno);
    8000335c:	85a6                	mv	a1,s1
    8000335e:	855e                	mv	a0,s7
    80003360:	00000097          	auipc	ra,0x0
    80003364:	cec080e7          	jalr	-788(ra) # 8000304c <bread>
    80003368:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000336a:	40000613          	li	a2,1024
    8000336e:	4581                	li	a1,0
    80003370:	05850513          	addi	a0,a0,88
    80003374:	ffffe097          	auipc	ra,0xffffe
    80003378:	9e0080e7          	jalr	-1568(ra) # 80000d54 <memset>
  log_write(bp);
    8000337c:	854a                	mv	a0,s2
    8000337e:	00001097          	auipc	ra,0x1
    80003382:	0aa080e7          	jalr	170(ra) # 80004428 <log_write>
  brelse(bp);
    80003386:	854a                	mv	a0,s2
    80003388:	00000097          	auipc	ra,0x0
    8000338c:	df4080e7          	jalr	-524(ra) # 8000317c <brelse>
}
    80003390:	7942                	ld	s2,48(sp)
    80003392:	79a2                	ld	s3,40(sp)
    80003394:	7a02                	ld	s4,32(sp)
    80003396:	6ae2                	ld	s5,24(sp)
    80003398:	6b42                	ld	s6,16(sp)
    8000339a:	6ba2                	ld	s7,8(sp)
    8000339c:	6c02                	ld	s8,0(sp)
}
    8000339e:	8526                	mv	a0,s1
    800033a0:	60a6                	ld	ra,72(sp)
    800033a2:	6406                	ld	s0,64(sp)
    800033a4:	74e2                	ld	s1,56(sp)
    800033a6:	6161                	addi	sp,sp,80
    800033a8:	8082                	ret
    brelse(bp);
    800033aa:	854a                	mv	a0,s2
    800033ac:	00000097          	auipc	ra,0x0
    800033b0:	dd0080e7          	jalr	-560(ra) # 8000317c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033b4:	015c0abb          	addw	s5,s8,s5
    800033b8:	004b2783          	lw	a5,4(s6)
    800033bc:	04fafa63          	bgeu	s5,a5,80003410 <balloc+0x108>
    bp = bread(dev, BBLOCK(b, sb));
    800033c0:	40dad59b          	sraiw	a1,s5,0xd
    800033c4:	01cb2783          	lw	a5,28(s6)
    800033c8:	9dbd                	addw	a1,a1,a5
    800033ca:	855e                	mv	a0,s7
    800033cc:	00000097          	auipc	ra,0x0
    800033d0:	c80080e7          	jalr	-896(ra) # 8000304c <bread>
    800033d4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033d6:	004b2503          	lw	a0,4(s6)
    800033da:	84d6                	mv	s1,s5
    800033dc:	4701                	li	a4,0
    800033de:	fca4f6e3          	bgeu	s1,a0,800033aa <balloc+0xa2>
      m = 1 << (bi % 8);
    800033e2:	00777693          	andi	a3,a4,7
    800033e6:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800033ea:	41f7579b          	sraiw	a5,a4,0x1f
    800033ee:	01d7d79b          	srliw	a5,a5,0x1d
    800033f2:	9fb9                	addw	a5,a5,a4
    800033f4:	4037d79b          	sraiw	a5,a5,0x3
    800033f8:	00f90633          	add	a2,s2,a5
    800033fc:	05864603          	lbu	a2,88(a2)
    80003400:	00c6f5b3          	and	a1,a3,a2
    80003404:	dd95                	beqz	a1,80003340 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003406:	2705                	addiw	a4,a4,1
    80003408:	2485                	addiw	s1,s1,1
    8000340a:	fd471ae3          	bne	a4,s4,800033de <balloc+0xd6>
    8000340e:	bf71                	j	800033aa <balloc+0xa2>
    80003410:	7942                	ld	s2,48(sp)
    80003412:	79a2                	ld	s3,40(sp)
    80003414:	7a02                	ld	s4,32(sp)
    80003416:	6ae2                	ld	s5,24(sp)
    80003418:	6b42                	ld	s6,16(sp)
    8000341a:	6ba2                	ld	s7,8(sp)
    8000341c:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    8000341e:	00005517          	auipc	a0,0x5
    80003422:	0b250513          	addi	a0,a0,178 # 800084d0 <etext+0x4d0>
    80003426:	ffffd097          	auipc	ra,0xffffd
    8000342a:	182080e7          	jalr	386(ra) # 800005a8 <printf>
  return 0;
    8000342e:	4481                	li	s1,0
    80003430:	b7bd                	j	8000339e <balloc+0x96>

0000000080003432 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003432:	7179                	addi	sp,sp,-48
    80003434:	f406                	sd	ra,40(sp)
    80003436:	f022                	sd	s0,32(sp)
    80003438:	ec26                	sd	s1,24(sp)
    8000343a:	e84a                	sd	s2,16(sp)
    8000343c:	e44e                	sd	s3,8(sp)
    8000343e:	1800                	addi	s0,sp,48
    80003440:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003442:	47ad                	li	a5,11
    80003444:	02b7e563          	bltu	a5,a1,8000346e <bmap+0x3c>
    if((addr = ip->addrs[bn]) == 0){
    80003448:	02059793          	slli	a5,a1,0x20
    8000344c:	01e7d593          	srli	a1,a5,0x1e
    80003450:	00b509b3          	add	s3,a0,a1
    80003454:	0509a483          	lw	s1,80(s3)
    80003458:	e8b5                	bnez	s1,800034cc <bmap+0x9a>
      addr = balloc(ip->dev);
    8000345a:	4108                	lw	a0,0(a0)
    8000345c:	00000097          	auipc	ra,0x0
    80003460:	eac080e7          	jalr	-340(ra) # 80003308 <balloc>
    80003464:	84aa                	mv	s1,a0
      if(addr == 0)
    80003466:	c13d                	beqz	a0,800034cc <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003468:	04a9a823          	sw	a0,80(s3)
    8000346c:	a085                	j	800034cc <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000346e:	ff45879b          	addiw	a5,a1,-12
    80003472:	873e                	mv	a4,a5
    80003474:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80003476:	0ff00793          	li	a5,255
    8000347a:	08e7e163          	bltu	a5,a4,800034fc <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000347e:	08052483          	lw	s1,128(a0)
    80003482:	ec81                	bnez	s1,8000349a <bmap+0x68>
      addr = balloc(ip->dev);
    80003484:	4108                	lw	a0,0(a0)
    80003486:	00000097          	auipc	ra,0x0
    8000348a:	e82080e7          	jalr	-382(ra) # 80003308 <balloc>
    8000348e:	84aa                	mv	s1,a0
      if(addr == 0)
    80003490:	cd15                	beqz	a0,800034cc <bmap+0x9a>
    80003492:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003494:	08a92023          	sw	a0,128(s2)
    80003498:	a011                	j	8000349c <bmap+0x6a>
    8000349a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000349c:	85a6                	mv	a1,s1
    8000349e:	00092503          	lw	a0,0(s2)
    800034a2:	00000097          	auipc	ra,0x0
    800034a6:	baa080e7          	jalr	-1110(ra) # 8000304c <bread>
    800034aa:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034ac:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800034b0:	02099713          	slli	a4,s3,0x20
    800034b4:	01e75593          	srli	a1,a4,0x1e
    800034b8:	97ae                	add	a5,a5,a1
    800034ba:	89be                	mv	s3,a5
    800034bc:	4384                	lw	s1,0(a5)
    800034be:	cc99                	beqz	s1,800034dc <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800034c0:	8552                	mv	a0,s4
    800034c2:	00000097          	auipc	ra,0x0
    800034c6:	cba080e7          	jalr	-838(ra) # 8000317c <brelse>
    return addr;
    800034ca:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800034cc:	8526                	mv	a0,s1
    800034ce:	70a2                	ld	ra,40(sp)
    800034d0:	7402                	ld	s0,32(sp)
    800034d2:	64e2                	ld	s1,24(sp)
    800034d4:	6942                	ld	s2,16(sp)
    800034d6:	69a2                	ld	s3,8(sp)
    800034d8:	6145                	addi	sp,sp,48
    800034da:	8082                	ret
      addr = balloc(ip->dev);
    800034dc:	00092503          	lw	a0,0(s2)
    800034e0:	00000097          	auipc	ra,0x0
    800034e4:	e28080e7          	jalr	-472(ra) # 80003308 <balloc>
    800034e8:	84aa                	mv	s1,a0
      if(addr){
    800034ea:	d979                	beqz	a0,800034c0 <bmap+0x8e>
        a[bn] = addr;
    800034ec:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800034f0:	8552                	mv	a0,s4
    800034f2:	00001097          	auipc	ra,0x1
    800034f6:	f36080e7          	jalr	-202(ra) # 80004428 <log_write>
    800034fa:	b7d9                	j	800034c0 <bmap+0x8e>
    800034fc:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800034fe:	00005517          	auipc	a0,0x5
    80003502:	fea50513          	addi	a0,a0,-22 # 800084e8 <etext+0x4e8>
    80003506:	ffffd097          	auipc	ra,0xffffd
    8000350a:	058080e7          	jalr	88(ra) # 8000055e <panic>

000000008000350e <iget>:
{
    8000350e:	7179                	addi	sp,sp,-48
    80003510:	f406                	sd	ra,40(sp)
    80003512:	f022                	sd	s0,32(sp)
    80003514:	ec26                	sd	s1,24(sp)
    80003516:	e84a                	sd	s2,16(sp)
    80003518:	e44e                	sd	s3,8(sp)
    8000351a:	e052                	sd	s4,0(sp)
    8000351c:	1800                	addi	s0,sp,48
    8000351e:	892a                	mv	s2,a0
    80003520:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003522:	0001c517          	auipc	a0,0x1c
    80003526:	bd650513          	addi	a0,a0,-1066 # 8001f0f8 <itable>
    8000352a:	ffffd097          	auipc	ra,0xffffd
    8000352e:	732080e7          	jalr	1842(ra) # 80000c5c <acquire>
  empty = 0;
    80003532:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003534:	0001c497          	auipc	s1,0x1c
    80003538:	bdc48493          	addi	s1,s1,-1060 # 8001f110 <itable+0x18>
    8000353c:	0001d697          	auipc	a3,0x1d
    80003540:	66468693          	addi	a3,a3,1636 # 80020ba0 <log>
    80003544:	a809                	j	80003556 <iget+0x48>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003546:	e781                	bnez	a5,8000354e <iget+0x40>
    80003548:	00099363          	bnez	s3,8000354e <iget+0x40>
      empty = ip;
    8000354c:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000354e:	08848493          	addi	s1,s1,136
    80003552:	02d48763          	beq	s1,a3,80003580 <iget+0x72>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003556:	449c                	lw	a5,8(s1)
    80003558:	fef057e3          	blez	a5,80003546 <iget+0x38>
    8000355c:	4098                	lw	a4,0(s1)
    8000355e:	ff2718e3          	bne	a4,s2,8000354e <iget+0x40>
    80003562:	40d8                	lw	a4,4(s1)
    80003564:	ff4715e3          	bne	a4,s4,8000354e <iget+0x40>
      ip->ref++;
    80003568:	2785                	addiw	a5,a5,1
    8000356a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000356c:	0001c517          	auipc	a0,0x1c
    80003570:	b8c50513          	addi	a0,a0,-1140 # 8001f0f8 <itable>
    80003574:	ffffd097          	auipc	ra,0xffffd
    80003578:	798080e7          	jalr	1944(ra) # 80000d0c <release>
      return ip;
    8000357c:	89a6                	mv	s3,s1
    8000357e:	a025                	j	800035a6 <iget+0x98>
  if(empty == 0)
    80003580:	02098c63          	beqz	s3,800035b8 <iget+0xaa>
  ip->dev = dev;
    80003584:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003588:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    8000358c:	4785                	li	a5,1
    8000358e:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003592:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003596:	0001c517          	auipc	a0,0x1c
    8000359a:	b6250513          	addi	a0,a0,-1182 # 8001f0f8 <itable>
    8000359e:	ffffd097          	auipc	ra,0xffffd
    800035a2:	76e080e7          	jalr	1902(ra) # 80000d0c <release>
}
    800035a6:	854e                	mv	a0,s3
    800035a8:	70a2                	ld	ra,40(sp)
    800035aa:	7402                	ld	s0,32(sp)
    800035ac:	64e2                	ld	s1,24(sp)
    800035ae:	6942                	ld	s2,16(sp)
    800035b0:	69a2                	ld	s3,8(sp)
    800035b2:	6a02                	ld	s4,0(sp)
    800035b4:	6145                	addi	sp,sp,48
    800035b6:	8082                	ret
    panic("iget: no inodes");
    800035b8:	00005517          	auipc	a0,0x5
    800035bc:	f4850513          	addi	a0,a0,-184 # 80008500 <etext+0x500>
    800035c0:	ffffd097          	auipc	ra,0xffffd
    800035c4:	f9e080e7          	jalr	-98(ra) # 8000055e <panic>

00000000800035c8 <fsinit>:
fsinit(int dev) {
    800035c8:	1101                	addi	sp,sp,-32
    800035ca:	ec06                	sd	ra,24(sp)
    800035cc:	e822                	sd	s0,16(sp)
    800035ce:	e426                	sd	s1,8(sp)
    800035d0:	e04a                	sd	s2,0(sp)
    800035d2:	1000                	addi	s0,sp,32
    800035d4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800035d6:	4585                	li	a1,1
    800035d8:	00000097          	auipc	ra,0x0
    800035dc:	a74080e7          	jalr	-1420(ra) # 8000304c <bread>
    800035e0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800035e2:	02000613          	li	a2,32
    800035e6:	05850593          	addi	a1,a0,88
    800035ea:	0001c517          	auipc	a0,0x1c
    800035ee:	aee50513          	addi	a0,a0,-1298 # 8001f0d8 <sb>
    800035f2:	ffffd097          	auipc	ra,0xffffd
    800035f6:	7c2080e7          	jalr	1986(ra) # 80000db4 <memmove>
  brelse(bp);
    800035fa:	8526                	mv	a0,s1
    800035fc:	00000097          	auipc	ra,0x0
    80003600:	b80080e7          	jalr	-1152(ra) # 8000317c <brelse>
  if(sb.magic != FSMAGIC)
    80003604:	0001c717          	auipc	a4,0x1c
    80003608:	ad472703          	lw	a4,-1324(a4) # 8001f0d8 <sb>
    8000360c:	102037b7          	lui	a5,0x10203
    80003610:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003614:	02f71163          	bne	a4,a5,80003636 <fsinit+0x6e>
  initlog(dev, &sb);
    80003618:	0001c597          	auipc	a1,0x1c
    8000361c:	ac058593          	addi	a1,a1,-1344 # 8001f0d8 <sb>
    80003620:	854a                	mv	a0,s2
    80003622:	00001097          	auipc	ra,0x1
    80003626:	b80080e7          	jalr	-1152(ra) # 800041a2 <initlog>
}
    8000362a:	60e2                	ld	ra,24(sp)
    8000362c:	6442                	ld	s0,16(sp)
    8000362e:	64a2                	ld	s1,8(sp)
    80003630:	6902                	ld	s2,0(sp)
    80003632:	6105                	addi	sp,sp,32
    80003634:	8082                	ret
    panic("invalid file system");
    80003636:	00005517          	auipc	a0,0x5
    8000363a:	eda50513          	addi	a0,a0,-294 # 80008510 <etext+0x510>
    8000363e:	ffffd097          	auipc	ra,0xffffd
    80003642:	f20080e7          	jalr	-224(ra) # 8000055e <panic>

0000000080003646 <iinit>:
{
    80003646:	7179                	addi	sp,sp,-48
    80003648:	f406                	sd	ra,40(sp)
    8000364a:	f022                	sd	s0,32(sp)
    8000364c:	ec26                	sd	s1,24(sp)
    8000364e:	e84a                	sd	s2,16(sp)
    80003650:	e44e                	sd	s3,8(sp)
    80003652:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003654:	00005597          	auipc	a1,0x5
    80003658:	ed458593          	addi	a1,a1,-300 # 80008528 <etext+0x528>
    8000365c:	0001c517          	auipc	a0,0x1c
    80003660:	a9c50513          	addi	a0,a0,-1380 # 8001f0f8 <itable>
    80003664:	ffffd097          	auipc	ra,0xffffd
    80003668:	55e080e7          	jalr	1374(ra) # 80000bc2 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000366c:	0001c497          	auipc	s1,0x1c
    80003670:	ab448493          	addi	s1,s1,-1356 # 8001f120 <itable+0x28>
    80003674:	0001d997          	auipc	s3,0x1d
    80003678:	53c98993          	addi	s3,s3,1340 # 80020bb0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000367c:	00005917          	auipc	s2,0x5
    80003680:	eb490913          	addi	s2,s2,-332 # 80008530 <etext+0x530>
    80003684:	85ca                	mv	a1,s2
    80003686:	8526                	mv	a0,s1
    80003688:	00001097          	auipc	ra,0x1
    8000368c:	e86080e7          	jalr	-378(ra) # 8000450e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003690:	08848493          	addi	s1,s1,136
    80003694:	ff3498e3          	bne	s1,s3,80003684 <iinit+0x3e>
}
    80003698:	70a2                	ld	ra,40(sp)
    8000369a:	7402                	ld	s0,32(sp)
    8000369c:	64e2                	ld	s1,24(sp)
    8000369e:	6942                	ld	s2,16(sp)
    800036a0:	69a2                	ld	s3,8(sp)
    800036a2:	6145                	addi	sp,sp,48
    800036a4:	8082                	ret

00000000800036a6 <ialloc>:
{
    800036a6:	7139                	addi	sp,sp,-64
    800036a8:	fc06                	sd	ra,56(sp)
    800036aa:	f822                	sd	s0,48(sp)
    800036ac:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800036ae:	0001c717          	auipc	a4,0x1c
    800036b2:	a3672703          	lw	a4,-1482(a4) # 8001f0e4 <sb+0xc>
    800036b6:	4785                	li	a5,1
    800036b8:	06e7f463          	bgeu	a5,a4,80003720 <ialloc+0x7a>
    800036bc:	f426                	sd	s1,40(sp)
    800036be:	f04a                	sd	s2,32(sp)
    800036c0:	ec4e                	sd	s3,24(sp)
    800036c2:	e852                	sd	s4,16(sp)
    800036c4:	e456                	sd	s5,8(sp)
    800036c6:	e05a                	sd	s6,0(sp)
    800036c8:	8aaa                	mv	s5,a0
    800036ca:	8b2e                	mv	s6,a1
    800036cc:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800036ce:	0001ca17          	auipc	s4,0x1c
    800036d2:	a0aa0a13          	addi	s4,s4,-1526 # 8001f0d8 <sb>
    800036d6:	00495593          	srli	a1,s2,0x4
    800036da:	018a2783          	lw	a5,24(s4)
    800036de:	9dbd                	addw	a1,a1,a5
    800036e0:	8556                	mv	a0,s5
    800036e2:	00000097          	auipc	ra,0x0
    800036e6:	96a080e7          	jalr	-1686(ra) # 8000304c <bread>
    800036ea:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800036ec:	05850993          	addi	s3,a0,88
    800036f0:	00f97793          	andi	a5,s2,15
    800036f4:	079a                	slli	a5,a5,0x6
    800036f6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800036f8:	00099783          	lh	a5,0(s3)
    800036fc:	cf9d                	beqz	a5,8000373a <ialloc+0x94>
    brelse(bp);
    800036fe:	00000097          	auipc	ra,0x0
    80003702:	a7e080e7          	jalr	-1410(ra) # 8000317c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003706:	0905                	addi	s2,s2,1
    80003708:	00ca2703          	lw	a4,12(s4)
    8000370c:	0009079b          	sext.w	a5,s2
    80003710:	fce7e3e3          	bltu	a5,a4,800036d6 <ialloc+0x30>
    80003714:	74a2                	ld	s1,40(sp)
    80003716:	7902                	ld	s2,32(sp)
    80003718:	69e2                	ld	s3,24(sp)
    8000371a:	6a42                	ld	s4,16(sp)
    8000371c:	6aa2                	ld	s5,8(sp)
    8000371e:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003720:	00005517          	auipc	a0,0x5
    80003724:	e1850513          	addi	a0,a0,-488 # 80008538 <etext+0x538>
    80003728:	ffffd097          	auipc	ra,0xffffd
    8000372c:	e80080e7          	jalr	-384(ra) # 800005a8 <printf>
  return 0;
    80003730:	4501                	li	a0,0
}
    80003732:	70e2                	ld	ra,56(sp)
    80003734:	7442                	ld	s0,48(sp)
    80003736:	6121                	addi	sp,sp,64
    80003738:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000373a:	04000613          	li	a2,64
    8000373e:	4581                	li	a1,0
    80003740:	854e                	mv	a0,s3
    80003742:	ffffd097          	auipc	ra,0xffffd
    80003746:	612080e7          	jalr	1554(ra) # 80000d54 <memset>
      dip->type = type;
    8000374a:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000374e:	8526                	mv	a0,s1
    80003750:	00001097          	auipc	ra,0x1
    80003754:	cd8080e7          	jalr	-808(ra) # 80004428 <log_write>
      brelse(bp);
    80003758:	8526                	mv	a0,s1
    8000375a:	00000097          	auipc	ra,0x0
    8000375e:	a22080e7          	jalr	-1502(ra) # 8000317c <brelse>
      return iget(dev, inum);
    80003762:	0009059b          	sext.w	a1,s2
    80003766:	8556                	mv	a0,s5
    80003768:	00000097          	auipc	ra,0x0
    8000376c:	da6080e7          	jalr	-602(ra) # 8000350e <iget>
    80003770:	74a2                	ld	s1,40(sp)
    80003772:	7902                	ld	s2,32(sp)
    80003774:	69e2                	ld	s3,24(sp)
    80003776:	6a42                	ld	s4,16(sp)
    80003778:	6aa2                	ld	s5,8(sp)
    8000377a:	6b02                	ld	s6,0(sp)
    8000377c:	bf5d                	j	80003732 <ialloc+0x8c>

000000008000377e <iupdate>:
{
    8000377e:	1101                	addi	sp,sp,-32
    80003780:	ec06                	sd	ra,24(sp)
    80003782:	e822                	sd	s0,16(sp)
    80003784:	e426                	sd	s1,8(sp)
    80003786:	e04a                	sd	s2,0(sp)
    80003788:	1000                	addi	s0,sp,32
    8000378a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000378c:	415c                	lw	a5,4(a0)
    8000378e:	0047d79b          	srliw	a5,a5,0x4
    80003792:	0001c597          	auipc	a1,0x1c
    80003796:	95e5a583          	lw	a1,-1698(a1) # 8001f0f0 <sb+0x18>
    8000379a:	9dbd                	addw	a1,a1,a5
    8000379c:	4108                	lw	a0,0(a0)
    8000379e:	00000097          	auipc	ra,0x0
    800037a2:	8ae080e7          	jalr	-1874(ra) # 8000304c <bread>
    800037a6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037a8:	05850793          	addi	a5,a0,88
    800037ac:	40d8                	lw	a4,4(s1)
    800037ae:	8b3d                	andi	a4,a4,15
    800037b0:	071a                	slli	a4,a4,0x6
    800037b2:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800037b4:	04449703          	lh	a4,68(s1)
    800037b8:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800037bc:	04649703          	lh	a4,70(s1)
    800037c0:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800037c4:	04849703          	lh	a4,72(s1)
    800037c8:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800037cc:	04a49703          	lh	a4,74(s1)
    800037d0:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800037d4:	44f8                	lw	a4,76(s1)
    800037d6:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800037d8:	03400613          	li	a2,52
    800037dc:	05048593          	addi	a1,s1,80
    800037e0:	00c78513          	addi	a0,a5,12
    800037e4:	ffffd097          	auipc	ra,0xffffd
    800037e8:	5d0080e7          	jalr	1488(ra) # 80000db4 <memmove>
  log_write(bp);
    800037ec:	854a                	mv	a0,s2
    800037ee:	00001097          	auipc	ra,0x1
    800037f2:	c3a080e7          	jalr	-966(ra) # 80004428 <log_write>
  brelse(bp);
    800037f6:	854a                	mv	a0,s2
    800037f8:	00000097          	auipc	ra,0x0
    800037fc:	984080e7          	jalr	-1660(ra) # 8000317c <brelse>
}
    80003800:	60e2                	ld	ra,24(sp)
    80003802:	6442                	ld	s0,16(sp)
    80003804:	64a2                	ld	s1,8(sp)
    80003806:	6902                	ld	s2,0(sp)
    80003808:	6105                	addi	sp,sp,32
    8000380a:	8082                	ret

000000008000380c <idup>:
{
    8000380c:	1101                	addi	sp,sp,-32
    8000380e:	ec06                	sd	ra,24(sp)
    80003810:	e822                	sd	s0,16(sp)
    80003812:	e426                	sd	s1,8(sp)
    80003814:	1000                	addi	s0,sp,32
    80003816:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003818:	0001c517          	auipc	a0,0x1c
    8000381c:	8e050513          	addi	a0,a0,-1824 # 8001f0f8 <itable>
    80003820:	ffffd097          	auipc	ra,0xffffd
    80003824:	43c080e7          	jalr	1084(ra) # 80000c5c <acquire>
  ip->ref++;
    80003828:	449c                	lw	a5,8(s1)
    8000382a:	2785                	addiw	a5,a5,1
    8000382c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000382e:	0001c517          	auipc	a0,0x1c
    80003832:	8ca50513          	addi	a0,a0,-1846 # 8001f0f8 <itable>
    80003836:	ffffd097          	auipc	ra,0xffffd
    8000383a:	4d6080e7          	jalr	1238(ra) # 80000d0c <release>
}
    8000383e:	8526                	mv	a0,s1
    80003840:	60e2                	ld	ra,24(sp)
    80003842:	6442                	ld	s0,16(sp)
    80003844:	64a2                	ld	s1,8(sp)
    80003846:	6105                	addi	sp,sp,32
    80003848:	8082                	ret

000000008000384a <ilock>:
{
    8000384a:	1101                	addi	sp,sp,-32
    8000384c:	ec06                	sd	ra,24(sp)
    8000384e:	e822                	sd	s0,16(sp)
    80003850:	e426                	sd	s1,8(sp)
    80003852:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003854:	c10d                	beqz	a0,80003876 <ilock+0x2c>
    80003856:	84aa                	mv	s1,a0
    80003858:	451c                	lw	a5,8(a0)
    8000385a:	00f05e63          	blez	a5,80003876 <ilock+0x2c>
  acquiresleep(&ip->lock);
    8000385e:	0541                	addi	a0,a0,16
    80003860:	00001097          	auipc	ra,0x1
    80003864:	ce8080e7          	jalr	-792(ra) # 80004548 <acquiresleep>
  if(ip->valid == 0){
    80003868:	40bc                	lw	a5,64(s1)
    8000386a:	cf99                	beqz	a5,80003888 <ilock+0x3e>
}
    8000386c:	60e2                	ld	ra,24(sp)
    8000386e:	6442                	ld	s0,16(sp)
    80003870:	64a2                	ld	s1,8(sp)
    80003872:	6105                	addi	sp,sp,32
    80003874:	8082                	ret
    80003876:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003878:	00005517          	auipc	a0,0x5
    8000387c:	cd850513          	addi	a0,a0,-808 # 80008550 <etext+0x550>
    80003880:	ffffd097          	auipc	ra,0xffffd
    80003884:	cde080e7          	jalr	-802(ra) # 8000055e <panic>
    80003888:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000388a:	40dc                	lw	a5,4(s1)
    8000388c:	0047d79b          	srliw	a5,a5,0x4
    80003890:	0001c597          	auipc	a1,0x1c
    80003894:	8605a583          	lw	a1,-1952(a1) # 8001f0f0 <sb+0x18>
    80003898:	9dbd                	addw	a1,a1,a5
    8000389a:	4088                	lw	a0,0(s1)
    8000389c:	fffff097          	auipc	ra,0xfffff
    800038a0:	7b0080e7          	jalr	1968(ra) # 8000304c <bread>
    800038a4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038a6:	05850593          	addi	a1,a0,88
    800038aa:	40dc                	lw	a5,4(s1)
    800038ac:	8bbd                	andi	a5,a5,15
    800038ae:	079a                	slli	a5,a5,0x6
    800038b0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038b2:	00059783          	lh	a5,0(a1)
    800038b6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038ba:	00259783          	lh	a5,2(a1)
    800038be:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038c2:	00459783          	lh	a5,4(a1)
    800038c6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800038ca:	00659783          	lh	a5,6(a1)
    800038ce:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800038d2:	459c                	lw	a5,8(a1)
    800038d4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800038d6:	03400613          	li	a2,52
    800038da:	05b1                	addi	a1,a1,12
    800038dc:	05048513          	addi	a0,s1,80
    800038e0:	ffffd097          	auipc	ra,0xffffd
    800038e4:	4d4080e7          	jalr	1236(ra) # 80000db4 <memmove>
    brelse(bp);
    800038e8:	854a                	mv	a0,s2
    800038ea:	00000097          	auipc	ra,0x0
    800038ee:	892080e7          	jalr	-1902(ra) # 8000317c <brelse>
    ip->valid = 1;
    800038f2:	4785                	li	a5,1
    800038f4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800038f6:	04449783          	lh	a5,68(s1)
    800038fa:	c399                	beqz	a5,80003900 <ilock+0xb6>
    800038fc:	6902                	ld	s2,0(sp)
    800038fe:	b7bd                	j	8000386c <ilock+0x22>
      panic("ilock: no type");
    80003900:	00005517          	auipc	a0,0x5
    80003904:	c5850513          	addi	a0,a0,-936 # 80008558 <etext+0x558>
    80003908:	ffffd097          	auipc	ra,0xffffd
    8000390c:	c56080e7          	jalr	-938(ra) # 8000055e <panic>

0000000080003910 <iunlock>:
{
    80003910:	1101                	addi	sp,sp,-32
    80003912:	ec06                	sd	ra,24(sp)
    80003914:	e822                	sd	s0,16(sp)
    80003916:	e426                	sd	s1,8(sp)
    80003918:	e04a                	sd	s2,0(sp)
    8000391a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000391c:	c905                	beqz	a0,8000394c <iunlock+0x3c>
    8000391e:	84aa                	mv	s1,a0
    80003920:	01050913          	addi	s2,a0,16
    80003924:	854a                	mv	a0,s2
    80003926:	00001097          	auipc	ra,0x1
    8000392a:	cbc080e7          	jalr	-836(ra) # 800045e2 <holdingsleep>
    8000392e:	cd19                	beqz	a0,8000394c <iunlock+0x3c>
    80003930:	449c                	lw	a5,8(s1)
    80003932:	00f05d63          	blez	a5,8000394c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003936:	854a                	mv	a0,s2
    80003938:	00001097          	auipc	ra,0x1
    8000393c:	c66080e7          	jalr	-922(ra) # 8000459e <releasesleep>
}
    80003940:	60e2                	ld	ra,24(sp)
    80003942:	6442                	ld	s0,16(sp)
    80003944:	64a2                	ld	s1,8(sp)
    80003946:	6902                	ld	s2,0(sp)
    80003948:	6105                	addi	sp,sp,32
    8000394a:	8082                	ret
    panic("iunlock");
    8000394c:	00005517          	auipc	a0,0x5
    80003950:	c1c50513          	addi	a0,a0,-996 # 80008568 <etext+0x568>
    80003954:	ffffd097          	auipc	ra,0xffffd
    80003958:	c0a080e7          	jalr	-1014(ra) # 8000055e <panic>

000000008000395c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000395c:	7179                	addi	sp,sp,-48
    8000395e:	f406                	sd	ra,40(sp)
    80003960:	f022                	sd	s0,32(sp)
    80003962:	ec26                	sd	s1,24(sp)
    80003964:	e84a                	sd	s2,16(sp)
    80003966:	e44e                	sd	s3,8(sp)
    80003968:	1800                	addi	s0,sp,48
    8000396a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000396c:	05050493          	addi	s1,a0,80
    80003970:	08050913          	addi	s2,a0,128
    80003974:	a021                	j	8000397c <itrunc+0x20>
    80003976:	0491                	addi	s1,s1,4
    80003978:	01248d63          	beq	s1,s2,80003992 <itrunc+0x36>
    if(ip->addrs[i]){
    8000397c:	408c                	lw	a1,0(s1)
    8000397e:	dde5                	beqz	a1,80003976 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003980:	0009a503          	lw	a0,0(s3)
    80003984:	00000097          	auipc	ra,0x0
    80003988:	908080e7          	jalr	-1784(ra) # 8000328c <bfree>
      ip->addrs[i] = 0;
    8000398c:	0004a023          	sw	zero,0(s1)
    80003990:	b7dd                	j	80003976 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003992:	0809a583          	lw	a1,128(s3)
    80003996:	ed99                	bnez	a1,800039b4 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003998:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000399c:	854e                	mv	a0,s3
    8000399e:	00000097          	auipc	ra,0x0
    800039a2:	de0080e7          	jalr	-544(ra) # 8000377e <iupdate>
}
    800039a6:	70a2                	ld	ra,40(sp)
    800039a8:	7402                	ld	s0,32(sp)
    800039aa:	64e2                	ld	s1,24(sp)
    800039ac:	6942                	ld	s2,16(sp)
    800039ae:	69a2                	ld	s3,8(sp)
    800039b0:	6145                	addi	sp,sp,48
    800039b2:	8082                	ret
    800039b4:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039b6:	0009a503          	lw	a0,0(s3)
    800039ba:	fffff097          	auipc	ra,0xfffff
    800039be:	692080e7          	jalr	1682(ra) # 8000304c <bread>
    800039c2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039c4:	05850493          	addi	s1,a0,88
    800039c8:	45850913          	addi	s2,a0,1112
    800039cc:	a021                	j	800039d4 <itrunc+0x78>
    800039ce:	0491                	addi	s1,s1,4
    800039d0:	01248b63          	beq	s1,s2,800039e6 <itrunc+0x8a>
      if(a[j])
    800039d4:	408c                	lw	a1,0(s1)
    800039d6:	dde5                	beqz	a1,800039ce <itrunc+0x72>
        bfree(ip->dev, a[j]);
    800039d8:	0009a503          	lw	a0,0(s3)
    800039dc:	00000097          	auipc	ra,0x0
    800039e0:	8b0080e7          	jalr	-1872(ra) # 8000328c <bfree>
    800039e4:	b7ed                	j	800039ce <itrunc+0x72>
    brelse(bp);
    800039e6:	8552                	mv	a0,s4
    800039e8:	fffff097          	auipc	ra,0xfffff
    800039ec:	794080e7          	jalr	1940(ra) # 8000317c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800039f0:	0809a583          	lw	a1,128(s3)
    800039f4:	0009a503          	lw	a0,0(s3)
    800039f8:	00000097          	auipc	ra,0x0
    800039fc:	894080e7          	jalr	-1900(ra) # 8000328c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a00:	0809a023          	sw	zero,128(s3)
    80003a04:	6a02                	ld	s4,0(sp)
    80003a06:	bf49                	j	80003998 <itrunc+0x3c>

0000000080003a08 <iput>:
{
    80003a08:	1101                	addi	sp,sp,-32
    80003a0a:	ec06                	sd	ra,24(sp)
    80003a0c:	e822                	sd	s0,16(sp)
    80003a0e:	e426                	sd	s1,8(sp)
    80003a10:	1000                	addi	s0,sp,32
    80003a12:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a14:	0001b517          	auipc	a0,0x1b
    80003a18:	6e450513          	addi	a0,a0,1764 # 8001f0f8 <itable>
    80003a1c:	ffffd097          	auipc	ra,0xffffd
    80003a20:	240080e7          	jalr	576(ra) # 80000c5c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a24:	4498                	lw	a4,8(s1)
    80003a26:	4785                	li	a5,1
    80003a28:	02f70263          	beq	a4,a5,80003a4c <iput+0x44>
  ip->ref--;
    80003a2c:	449c                	lw	a5,8(s1)
    80003a2e:	37fd                	addiw	a5,a5,-1
    80003a30:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a32:	0001b517          	auipc	a0,0x1b
    80003a36:	6c650513          	addi	a0,a0,1734 # 8001f0f8 <itable>
    80003a3a:	ffffd097          	auipc	ra,0xffffd
    80003a3e:	2d2080e7          	jalr	722(ra) # 80000d0c <release>
}
    80003a42:	60e2                	ld	ra,24(sp)
    80003a44:	6442                	ld	s0,16(sp)
    80003a46:	64a2                	ld	s1,8(sp)
    80003a48:	6105                	addi	sp,sp,32
    80003a4a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a4c:	40bc                	lw	a5,64(s1)
    80003a4e:	dff9                	beqz	a5,80003a2c <iput+0x24>
    80003a50:	04a49783          	lh	a5,74(s1)
    80003a54:	ffe1                	bnez	a5,80003a2c <iput+0x24>
    80003a56:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003a58:	01048793          	addi	a5,s1,16
    80003a5c:	893e                	mv	s2,a5
    80003a5e:	853e                	mv	a0,a5
    80003a60:	00001097          	auipc	ra,0x1
    80003a64:	ae8080e7          	jalr	-1304(ra) # 80004548 <acquiresleep>
    release(&itable.lock);
    80003a68:	0001b517          	auipc	a0,0x1b
    80003a6c:	69050513          	addi	a0,a0,1680 # 8001f0f8 <itable>
    80003a70:	ffffd097          	auipc	ra,0xffffd
    80003a74:	29c080e7          	jalr	668(ra) # 80000d0c <release>
    itrunc(ip);
    80003a78:	8526                	mv	a0,s1
    80003a7a:	00000097          	auipc	ra,0x0
    80003a7e:	ee2080e7          	jalr	-286(ra) # 8000395c <itrunc>
    ip->type = 0;
    80003a82:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a86:	8526                	mv	a0,s1
    80003a88:	00000097          	auipc	ra,0x0
    80003a8c:	cf6080e7          	jalr	-778(ra) # 8000377e <iupdate>
    ip->valid = 0;
    80003a90:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a94:	854a                	mv	a0,s2
    80003a96:	00001097          	auipc	ra,0x1
    80003a9a:	b08080e7          	jalr	-1272(ra) # 8000459e <releasesleep>
    acquire(&itable.lock);
    80003a9e:	0001b517          	auipc	a0,0x1b
    80003aa2:	65a50513          	addi	a0,a0,1626 # 8001f0f8 <itable>
    80003aa6:	ffffd097          	auipc	ra,0xffffd
    80003aaa:	1b6080e7          	jalr	438(ra) # 80000c5c <acquire>
    80003aae:	6902                	ld	s2,0(sp)
    80003ab0:	bfb5                	j	80003a2c <iput+0x24>

0000000080003ab2 <iunlockput>:
{
    80003ab2:	1101                	addi	sp,sp,-32
    80003ab4:	ec06                	sd	ra,24(sp)
    80003ab6:	e822                	sd	s0,16(sp)
    80003ab8:	e426                	sd	s1,8(sp)
    80003aba:	1000                	addi	s0,sp,32
    80003abc:	84aa                	mv	s1,a0
  iunlock(ip);
    80003abe:	00000097          	auipc	ra,0x0
    80003ac2:	e52080e7          	jalr	-430(ra) # 80003910 <iunlock>
  iput(ip);
    80003ac6:	8526                	mv	a0,s1
    80003ac8:	00000097          	auipc	ra,0x0
    80003acc:	f40080e7          	jalr	-192(ra) # 80003a08 <iput>
}
    80003ad0:	60e2                	ld	ra,24(sp)
    80003ad2:	6442                	ld	s0,16(sp)
    80003ad4:	64a2                	ld	s1,8(sp)
    80003ad6:	6105                	addi	sp,sp,32
    80003ad8:	8082                	ret

0000000080003ada <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ada:	1141                	addi	sp,sp,-16
    80003adc:	e406                	sd	ra,8(sp)
    80003ade:	e022                	sd	s0,0(sp)
    80003ae0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ae2:	411c                	lw	a5,0(a0)
    80003ae4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ae6:	415c                	lw	a5,4(a0)
    80003ae8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003aea:	04451783          	lh	a5,68(a0)
    80003aee:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003af2:	04a51783          	lh	a5,74(a0)
    80003af6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003afa:	04c56783          	lwu	a5,76(a0)
    80003afe:	e99c                	sd	a5,16(a1)
}
    80003b00:	60a2                	ld	ra,8(sp)
    80003b02:	6402                	ld	s0,0(sp)
    80003b04:	0141                	addi	sp,sp,16
    80003b06:	8082                	ret

0000000080003b08 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b08:	457c                	lw	a5,76(a0)
    80003b0a:	10d7e063          	bltu	a5,a3,80003c0a <readi+0x102>
{
    80003b0e:	7159                	addi	sp,sp,-112
    80003b10:	f486                	sd	ra,104(sp)
    80003b12:	f0a2                	sd	s0,96(sp)
    80003b14:	eca6                	sd	s1,88(sp)
    80003b16:	e0d2                	sd	s4,64(sp)
    80003b18:	fc56                	sd	s5,56(sp)
    80003b1a:	f85a                	sd	s6,48(sp)
    80003b1c:	f45e                	sd	s7,40(sp)
    80003b1e:	1880                	addi	s0,sp,112
    80003b20:	8b2a                	mv	s6,a0
    80003b22:	8bae                	mv	s7,a1
    80003b24:	8a32                	mv	s4,a2
    80003b26:	84b6                	mv	s1,a3
    80003b28:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003b2a:	9f35                	addw	a4,a4,a3
    return 0;
    80003b2c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b2e:	0cd76563          	bltu	a4,a3,80003bf8 <readi+0xf0>
    80003b32:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003b34:	00e7f463          	bgeu	a5,a4,80003b3c <readi+0x34>
    n = ip->size - off;
    80003b38:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b3c:	0a0a8563          	beqz	s5,80003be6 <readi+0xde>
    80003b40:	e8ca                	sd	s2,80(sp)
    80003b42:	f062                	sd	s8,32(sp)
    80003b44:	ec66                	sd	s9,24(sp)
    80003b46:	e86a                	sd	s10,16(sp)
    80003b48:	e46e                	sd	s11,8(sp)
    80003b4a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b4c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b50:	5c7d                	li	s8,-1
    80003b52:	a82d                	j	80003b8c <readi+0x84>
    80003b54:	020d1d93          	slli	s11,s10,0x20
    80003b58:	020ddd93          	srli	s11,s11,0x20
    80003b5c:	05890613          	addi	a2,s2,88
    80003b60:	86ee                	mv	a3,s11
    80003b62:	963e                	add	a2,a2,a5
    80003b64:	85d2                	mv	a1,s4
    80003b66:	855e                	mv	a0,s7
    80003b68:	fffff097          	auipc	ra,0xfffff
    80003b6c:	b00080e7          	jalr	-1280(ra) # 80002668 <either_copyout>
    80003b70:	05850963          	beq	a0,s8,80003bc2 <readi+0xba>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b74:	854a                	mv	a0,s2
    80003b76:	fffff097          	auipc	ra,0xfffff
    80003b7a:	606080e7          	jalr	1542(ra) # 8000317c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b7e:	013d09bb          	addw	s3,s10,s3
    80003b82:	009d04bb          	addw	s1,s10,s1
    80003b86:	9a6e                	add	s4,s4,s11
    80003b88:	0559f963          	bgeu	s3,s5,80003bda <readi+0xd2>
    uint addr = bmap(ip, off/BSIZE);
    80003b8c:	00a4d59b          	srliw	a1,s1,0xa
    80003b90:	855a                	mv	a0,s6
    80003b92:	00000097          	auipc	ra,0x0
    80003b96:	8a0080e7          	jalr	-1888(ra) # 80003432 <bmap>
    80003b9a:	85aa                	mv	a1,a0
    if(addr == 0)
    80003b9c:	c539                	beqz	a0,80003bea <readi+0xe2>
    bp = bread(ip->dev, addr);
    80003b9e:	000b2503          	lw	a0,0(s6)
    80003ba2:	fffff097          	auipc	ra,0xfffff
    80003ba6:	4aa080e7          	jalr	1194(ra) # 8000304c <bread>
    80003baa:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bac:	3ff4f793          	andi	a5,s1,1023
    80003bb0:	40fc873b          	subw	a4,s9,a5
    80003bb4:	413a86bb          	subw	a3,s5,s3
    80003bb8:	8d3a                	mv	s10,a4
    80003bba:	f8e6fde3          	bgeu	a3,a4,80003b54 <readi+0x4c>
    80003bbe:	8d36                	mv	s10,a3
    80003bc0:	bf51                	j	80003b54 <readi+0x4c>
      brelse(bp);
    80003bc2:	854a                	mv	a0,s2
    80003bc4:	fffff097          	auipc	ra,0xfffff
    80003bc8:	5b8080e7          	jalr	1464(ra) # 8000317c <brelse>
      tot = -1;
    80003bcc:	59fd                	li	s3,-1
      break;
    80003bce:	6946                	ld	s2,80(sp)
    80003bd0:	7c02                	ld	s8,32(sp)
    80003bd2:	6ce2                	ld	s9,24(sp)
    80003bd4:	6d42                	ld	s10,16(sp)
    80003bd6:	6da2                	ld	s11,8(sp)
    80003bd8:	a831                	j	80003bf4 <readi+0xec>
    80003bda:	6946                	ld	s2,80(sp)
    80003bdc:	7c02                	ld	s8,32(sp)
    80003bde:	6ce2                	ld	s9,24(sp)
    80003be0:	6d42                	ld	s10,16(sp)
    80003be2:	6da2                	ld	s11,8(sp)
    80003be4:	a801                	j	80003bf4 <readi+0xec>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003be6:	89d6                	mv	s3,s5
    80003be8:	a031                	j	80003bf4 <readi+0xec>
    80003bea:	6946                	ld	s2,80(sp)
    80003bec:	7c02                	ld	s8,32(sp)
    80003bee:	6ce2                	ld	s9,24(sp)
    80003bf0:	6d42                	ld	s10,16(sp)
    80003bf2:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003bf4:	854e                	mv	a0,s3
    80003bf6:	69a6                	ld	s3,72(sp)
}
    80003bf8:	70a6                	ld	ra,104(sp)
    80003bfa:	7406                	ld	s0,96(sp)
    80003bfc:	64e6                	ld	s1,88(sp)
    80003bfe:	6a06                	ld	s4,64(sp)
    80003c00:	7ae2                	ld	s5,56(sp)
    80003c02:	7b42                	ld	s6,48(sp)
    80003c04:	7ba2                	ld	s7,40(sp)
    80003c06:	6165                	addi	sp,sp,112
    80003c08:	8082                	ret
    return 0;
    80003c0a:	4501                	li	a0,0
}
    80003c0c:	8082                	ret

0000000080003c0e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c0e:	457c                	lw	a5,76(a0)
    80003c10:	10d7e963          	bltu	a5,a3,80003d22 <writei+0x114>
{
    80003c14:	7159                	addi	sp,sp,-112
    80003c16:	f486                	sd	ra,104(sp)
    80003c18:	f0a2                	sd	s0,96(sp)
    80003c1a:	e8ca                	sd	s2,80(sp)
    80003c1c:	e0d2                	sd	s4,64(sp)
    80003c1e:	fc56                	sd	s5,56(sp)
    80003c20:	f85a                	sd	s6,48(sp)
    80003c22:	f45e                	sd	s7,40(sp)
    80003c24:	1880                	addi	s0,sp,112
    80003c26:	8aaa                	mv	s5,a0
    80003c28:	8bae                	mv	s7,a1
    80003c2a:	8a32                	mv	s4,a2
    80003c2c:	8936                	mv	s2,a3
    80003c2e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c30:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c34:	00043737          	lui	a4,0x43
    80003c38:	0ef76763          	bltu	a4,a5,80003d26 <writei+0x118>
    80003c3c:	0ed7e563          	bltu	a5,a3,80003d26 <writei+0x118>
    80003c40:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c42:	0c0b0863          	beqz	s6,80003d12 <writei+0x104>
    80003c46:	eca6                	sd	s1,88(sp)
    80003c48:	f062                	sd	s8,32(sp)
    80003c4a:	ec66                	sd	s9,24(sp)
    80003c4c:	e86a                	sd	s10,16(sp)
    80003c4e:	e46e                	sd	s11,8(sp)
    80003c50:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c52:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c56:	5c7d                	li	s8,-1
    80003c58:	a091                	j	80003c9c <writei+0x8e>
    80003c5a:	020d1d93          	slli	s11,s10,0x20
    80003c5e:	020ddd93          	srli	s11,s11,0x20
    80003c62:	05848513          	addi	a0,s1,88
    80003c66:	86ee                	mv	a3,s11
    80003c68:	8652                	mv	a2,s4
    80003c6a:	85de                	mv	a1,s7
    80003c6c:	953e                	add	a0,a0,a5
    80003c6e:	fffff097          	auipc	ra,0xfffff
    80003c72:	a50080e7          	jalr	-1456(ra) # 800026be <either_copyin>
    80003c76:	05850e63          	beq	a0,s8,80003cd2 <writei+0xc4>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c7a:	8526                	mv	a0,s1
    80003c7c:	00000097          	auipc	ra,0x0
    80003c80:	7ac080e7          	jalr	1964(ra) # 80004428 <log_write>
    brelse(bp);
    80003c84:	8526                	mv	a0,s1
    80003c86:	fffff097          	auipc	ra,0xfffff
    80003c8a:	4f6080e7          	jalr	1270(ra) # 8000317c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c8e:	013d09bb          	addw	s3,s10,s3
    80003c92:	012d093b          	addw	s2,s10,s2
    80003c96:	9a6e                	add	s4,s4,s11
    80003c98:	0569f263          	bgeu	s3,s6,80003cdc <writei+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003c9c:	00a9559b          	srliw	a1,s2,0xa
    80003ca0:	8556                	mv	a0,s5
    80003ca2:	fffff097          	auipc	ra,0xfffff
    80003ca6:	790080e7          	jalr	1936(ra) # 80003432 <bmap>
    80003caa:	85aa                	mv	a1,a0
    if(addr == 0)
    80003cac:	c905                	beqz	a0,80003cdc <writei+0xce>
    bp = bread(ip->dev, addr);
    80003cae:	000aa503          	lw	a0,0(s5)
    80003cb2:	fffff097          	auipc	ra,0xfffff
    80003cb6:	39a080e7          	jalr	922(ra) # 8000304c <bread>
    80003cba:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cbc:	3ff97793          	andi	a5,s2,1023
    80003cc0:	40fc873b          	subw	a4,s9,a5
    80003cc4:	413b06bb          	subw	a3,s6,s3
    80003cc8:	8d3a                	mv	s10,a4
    80003cca:	f8e6f8e3          	bgeu	a3,a4,80003c5a <writei+0x4c>
    80003cce:	8d36                	mv	s10,a3
    80003cd0:	b769                	j	80003c5a <writei+0x4c>
      brelse(bp);
    80003cd2:	8526                	mv	a0,s1
    80003cd4:	fffff097          	auipc	ra,0xfffff
    80003cd8:	4a8080e7          	jalr	1192(ra) # 8000317c <brelse>
  }

  if(off > ip->size)
    80003cdc:	04caa783          	lw	a5,76(s5)
    80003ce0:	0327fb63          	bgeu	a5,s2,80003d16 <writei+0x108>
    ip->size = off;
    80003ce4:	052aa623          	sw	s2,76(s5)
    80003ce8:	64e6                	ld	s1,88(sp)
    80003cea:	7c02                	ld	s8,32(sp)
    80003cec:	6ce2                	ld	s9,24(sp)
    80003cee:	6d42                	ld	s10,16(sp)
    80003cf0:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003cf2:	8556                	mv	a0,s5
    80003cf4:	00000097          	auipc	ra,0x0
    80003cf8:	a8a080e7          	jalr	-1398(ra) # 8000377e <iupdate>

  return tot;
    80003cfc:	854e                	mv	a0,s3
    80003cfe:	69a6                	ld	s3,72(sp)
}
    80003d00:	70a6                	ld	ra,104(sp)
    80003d02:	7406                	ld	s0,96(sp)
    80003d04:	6946                	ld	s2,80(sp)
    80003d06:	6a06                	ld	s4,64(sp)
    80003d08:	7ae2                	ld	s5,56(sp)
    80003d0a:	7b42                	ld	s6,48(sp)
    80003d0c:	7ba2                	ld	s7,40(sp)
    80003d0e:	6165                	addi	sp,sp,112
    80003d10:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d12:	89da                	mv	s3,s6
    80003d14:	bff9                	j	80003cf2 <writei+0xe4>
    80003d16:	64e6                	ld	s1,88(sp)
    80003d18:	7c02                	ld	s8,32(sp)
    80003d1a:	6ce2                	ld	s9,24(sp)
    80003d1c:	6d42                	ld	s10,16(sp)
    80003d1e:	6da2                	ld	s11,8(sp)
    80003d20:	bfc9                	j	80003cf2 <writei+0xe4>
    return -1;
    80003d22:	557d                	li	a0,-1
}
    80003d24:	8082                	ret
    return -1;
    80003d26:	557d                	li	a0,-1
    80003d28:	bfe1                	j	80003d00 <writei+0xf2>

0000000080003d2a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d2a:	1141                	addi	sp,sp,-16
    80003d2c:	e406                	sd	ra,8(sp)
    80003d2e:	e022                	sd	s0,0(sp)
    80003d30:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d32:	4639                	li	a2,14
    80003d34:	ffffd097          	auipc	ra,0xffffd
    80003d38:	0f8080e7          	jalr	248(ra) # 80000e2c <strncmp>
}
    80003d3c:	60a2                	ld	ra,8(sp)
    80003d3e:	6402                	ld	s0,0(sp)
    80003d40:	0141                	addi	sp,sp,16
    80003d42:	8082                	ret

0000000080003d44 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d44:	711d                	addi	sp,sp,-96
    80003d46:	ec86                	sd	ra,88(sp)
    80003d48:	e8a2                	sd	s0,80(sp)
    80003d4a:	e4a6                	sd	s1,72(sp)
    80003d4c:	e0ca                	sd	s2,64(sp)
    80003d4e:	fc4e                	sd	s3,56(sp)
    80003d50:	f852                	sd	s4,48(sp)
    80003d52:	f456                	sd	s5,40(sp)
    80003d54:	f05a                	sd	s6,32(sp)
    80003d56:	ec5e                	sd	s7,24(sp)
    80003d58:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d5a:	04451703          	lh	a4,68(a0)
    80003d5e:	4785                	li	a5,1
    80003d60:	00f71f63          	bne	a4,a5,80003d7e <dirlookup+0x3a>
    80003d64:	892a                	mv	s2,a0
    80003d66:	8aae                	mv	s5,a1
    80003d68:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d6a:	457c                	lw	a5,76(a0)
    80003d6c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d6e:	fa040a13          	addi	s4,s0,-96
    80003d72:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003d74:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d78:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d7a:	e79d                	bnez	a5,80003da8 <dirlookup+0x64>
    80003d7c:	a88d                	j	80003dee <dirlookup+0xaa>
    panic("dirlookup not DIR");
    80003d7e:	00004517          	auipc	a0,0x4
    80003d82:	7f250513          	addi	a0,a0,2034 # 80008570 <etext+0x570>
    80003d86:	ffffc097          	auipc	ra,0xffffc
    80003d8a:	7d8080e7          	jalr	2008(ra) # 8000055e <panic>
      panic("dirlookup read");
    80003d8e:	00004517          	auipc	a0,0x4
    80003d92:	7fa50513          	addi	a0,a0,2042 # 80008588 <etext+0x588>
    80003d96:	ffffc097          	auipc	ra,0xffffc
    80003d9a:	7c8080e7          	jalr	1992(ra) # 8000055e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d9e:	24c1                	addiw	s1,s1,16
    80003da0:	04c92783          	lw	a5,76(s2)
    80003da4:	04f4f463          	bgeu	s1,a5,80003dec <dirlookup+0xa8>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003da8:	874e                	mv	a4,s3
    80003daa:	86a6                	mv	a3,s1
    80003dac:	8652                	mv	a2,s4
    80003dae:	4581                	li	a1,0
    80003db0:	854a                	mv	a0,s2
    80003db2:	00000097          	auipc	ra,0x0
    80003db6:	d56080e7          	jalr	-682(ra) # 80003b08 <readi>
    80003dba:	fd351ae3          	bne	a0,s3,80003d8e <dirlookup+0x4a>
    if(de.inum == 0)
    80003dbe:	fa045783          	lhu	a5,-96(s0)
    80003dc2:	dff1                	beqz	a5,80003d9e <dirlookup+0x5a>
    if(namecmp(name, de.name) == 0){
    80003dc4:	85da                	mv	a1,s6
    80003dc6:	8556                	mv	a0,s5
    80003dc8:	00000097          	auipc	ra,0x0
    80003dcc:	f62080e7          	jalr	-158(ra) # 80003d2a <namecmp>
    80003dd0:	f579                	bnez	a0,80003d9e <dirlookup+0x5a>
      if(poff)
    80003dd2:	000b8463          	beqz	s7,80003dda <dirlookup+0x96>
        *poff = off;
    80003dd6:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003dda:	fa045583          	lhu	a1,-96(s0)
    80003dde:	00092503          	lw	a0,0(s2)
    80003de2:	fffff097          	auipc	ra,0xfffff
    80003de6:	72c080e7          	jalr	1836(ra) # 8000350e <iget>
    80003dea:	a011                	j	80003dee <dirlookup+0xaa>
  return 0;
    80003dec:	4501                	li	a0,0
}
    80003dee:	60e6                	ld	ra,88(sp)
    80003df0:	6446                	ld	s0,80(sp)
    80003df2:	64a6                	ld	s1,72(sp)
    80003df4:	6906                	ld	s2,64(sp)
    80003df6:	79e2                	ld	s3,56(sp)
    80003df8:	7a42                	ld	s4,48(sp)
    80003dfa:	7aa2                	ld	s5,40(sp)
    80003dfc:	7b02                	ld	s6,32(sp)
    80003dfe:	6be2                	ld	s7,24(sp)
    80003e00:	6125                	addi	sp,sp,96
    80003e02:	8082                	ret

0000000080003e04 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e04:	711d                	addi	sp,sp,-96
    80003e06:	ec86                	sd	ra,88(sp)
    80003e08:	e8a2                	sd	s0,80(sp)
    80003e0a:	e4a6                	sd	s1,72(sp)
    80003e0c:	e0ca                	sd	s2,64(sp)
    80003e0e:	fc4e                	sd	s3,56(sp)
    80003e10:	f852                	sd	s4,48(sp)
    80003e12:	f456                	sd	s5,40(sp)
    80003e14:	f05a                	sd	s6,32(sp)
    80003e16:	ec5e                	sd	s7,24(sp)
    80003e18:	e862                	sd	s8,16(sp)
    80003e1a:	e466                	sd	s9,8(sp)
    80003e1c:	e06a                	sd	s10,0(sp)
    80003e1e:	1080                	addi	s0,sp,96
    80003e20:	84aa                	mv	s1,a0
    80003e22:	8b2e                	mv	s6,a1
    80003e24:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e26:	00054703          	lbu	a4,0(a0)
    80003e2a:	02f00793          	li	a5,47
    80003e2e:	02f70363          	beq	a4,a5,80003e54 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e32:	ffffe097          	auipc	ra,0xffffe
    80003e36:	d82080e7          	jalr	-638(ra) # 80001bb4 <myproc>
    80003e3a:	15053503          	ld	a0,336(a0)
    80003e3e:	00000097          	auipc	ra,0x0
    80003e42:	9ce080e7          	jalr	-1586(ra) # 8000380c <idup>
    80003e46:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003e48:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003e4c:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003e4e:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e50:	4b85                	li	s7,1
    80003e52:	a87d                	j	80003f10 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003e54:	4585                	li	a1,1
    80003e56:	852e                	mv	a0,a1
    80003e58:	fffff097          	auipc	ra,0xfffff
    80003e5c:	6b6080e7          	jalr	1718(ra) # 8000350e <iget>
    80003e60:	8a2a                	mv	s4,a0
    80003e62:	b7dd                	j	80003e48 <namex+0x44>
      iunlockput(ip);
    80003e64:	8552                	mv	a0,s4
    80003e66:	00000097          	auipc	ra,0x0
    80003e6a:	c4c080e7          	jalr	-948(ra) # 80003ab2 <iunlockput>
      return 0;
    80003e6e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e70:	8552                	mv	a0,s4
    80003e72:	60e6                	ld	ra,88(sp)
    80003e74:	6446                	ld	s0,80(sp)
    80003e76:	64a6                	ld	s1,72(sp)
    80003e78:	6906                	ld	s2,64(sp)
    80003e7a:	79e2                	ld	s3,56(sp)
    80003e7c:	7a42                	ld	s4,48(sp)
    80003e7e:	7aa2                	ld	s5,40(sp)
    80003e80:	7b02                	ld	s6,32(sp)
    80003e82:	6be2                	ld	s7,24(sp)
    80003e84:	6c42                	ld	s8,16(sp)
    80003e86:	6ca2                	ld	s9,8(sp)
    80003e88:	6d02                	ld	s10,0(sp)
    80003e8a:	6125                	addi	sp,sp,96
    80003e8c:	8082                	ret
      iunlock(ip);
    80003e8e:	8552                	mv	a0,s4
    80003e90:	00000097          	auipc	ra,0x0
    80003e94:	a80080e7          	jalr	-1408(ra) # 80003910 <iunlock>
      return ip;
    80003e98:	bfe1                	j	80003e70 <namex+0x6c>
      iunlockput(ip);
    80003e9a:	8552                	mv	a0,s4
    80003e9c:	00000097          	auipc	ra,0x0
    80003ea0:	c16080e7          	jalr	-1002(ra) # 80003ab2 <iunlockput>
      return 0;
    80003ea4:	8a4a                	mv	s4,s2
    80003ea6:	b7e9                	j	80003e70 <namex+0x6c>
  len = path - s;
    80003ea8:	40990633          	sub	a2,s2,s1
    80003eac:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003eb0:	09ac5c63          	bge	s8,s10,80003f48 <namex+0x144>
    memmove(name, s, DIRSIZ);
    80003eb4:	8666                	mv	a2,s9
    80003eb6:	85a6                	mv	a1,s1
    80003eb8:	8556                	mv	a0,s5
    80003eba:	ffffd097          	auipc	ra,0xffffd
    80003ebe:	efa080e7          	jalr	-262(ra) # 80000db4 <memmove>
    80003ec2:	84ca                	mv	s1,s2
  while(*path == '/')
    80003ec4:	0004c783          	lbu	a5,0(s1)
    80003ec8:	01379763          	bne	a5,s3,80003ed6 <namex+0xd2>
    path++;
    80003ecc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ece:	0004c783          	lbu	a5,0(s1)
    80003ed2:	ff378de3          	beq	a5,s3,80003ecc <namex+0xc8>
    ilock(ip);
    80003ed6:	8552                	mv	a0,s4
    80003ed8:	00000097          	auipc	ra,0x0
    80003edc:	972080e7          	jalr	-1678(ra) # 8000384a <ilock>
    if(ip->type != T_DIR){
    80003ee0:	044a1783          	lh	a5,68(s4)
    80003ee4:	f97790e3          	bne	a5,s7,80003e64 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003ee8:	000b0563          	beqz	s6,80003ef2 <namex+0xee>
    80003eec:	0004c783          	lbu	a5,0(s1)
    80003ef0:	dfd9                	beqz	a5,80003e8e <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ef2:	4601                	li	a2,0
    80003ef4:	85d6                	mv	a1,s5
    80003ef6:	8552                	mv	a0,s4
    80003ef8:	00000097          	auipc	ra,0x0
    80003efc:	e4c080e7          	jalr	-436(ra) # 80003d44 <dirlookup>
    80003f00:	892a                	mv	s2,a0
    80003f02:	dd41                	beqz	a0,80003e9a <namex+0x96>
    iunlockput(ip);
    80003f04:	8552                	mv	a0,s4
    80003f06:	00000097          	auipc	ra,0x0
    80003f0a:	bac080e7          	jalr	-1108(ra) # 80003ab2 <iunlockput>
    ip = next;
    80003f0e:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003f10:	0004c783          	lbu	a5,0(s1)
    80003f14:	01379763          	bne	a5,s3,80003f22 <namex+0x11e>
    path++;
    80003f18:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f1a:	0004c783          	lbu	a5,0(s1)
    80003f1e:	ff378de3          	beq	a5,s3,80003f18 <namex+0x114>
  if(*path == 0)
    80003f22:	cf9d                	beqz	a5,80003f60 <namex+0x15c>
  while(*path != '/' && *path != 0)
    80003f24:	0004c783          	lbu	a5,0(s1)
    80003f28:	fd178713          	addi	a4,a5,-47
    80003f2c:	cb19                	beqz	a4,80003f42 <namex+0x13e>
    80003f2e:	cb91                	beqz	a5,80003f42 <namex+0x13e>
    80003f30:	8926                	mv	s2,s1
    path++;
    80003f32:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003f34:	00094783          	lbu	a5,0(s2)
    80003f38:	fd178713          	addi	a4,a5,-47
    80003f3c:	d735                	beqz	a4,80003ea8 <namex+0xa4>
    80003f3e:	fbf5                	bnez	a5,80003f32 <namex+0x12e>
    80003f40:	b7a5                	j	80003ea8 <namex+0xa4>
    80003f42:	8926                	mv	s2,s1
  len = path - s;
    80003f44:	4d01                	li	s10,0
    80003f46:	4601                	li	a2,0
    memmove(name, s, len);
    80003f48:	2601                	sext.w	a2,a2
    80003f4a:	85a6                	mv	a1,s1
    80003f4c:	8556                	mv	a0,s5
    80003f4e:	ffffd097          	auipc	ra,0xffffd
    80003f52:	e66080e7          	jalr	-410(ra) # 80000db4 <memmove>
    name[len] = 0;
    80003f56:	9d56                	add	s10,s10,s5
    80003f58:	000d0023          	sb	zero,0(s10)
    80003f5c:	84ca                	mv	s1,s2
    80003f5e:	b79d                	j	80003ec4 <namex+0xc0>
  if(nameiparent){
    80003f60:	f00b08e3          	beqz	s6,80003e70 <namex+0x6c>
    iput(ip);
    80003f64:	8552                	mv	a0,s4
    80003f66:	00000097          	auipc	ra,0x0
    80003f6a:	aa2080e7          	jalr	-1374(ra) # 80003a08 <iput>
    return 0;
    80003f6e:	4a01                	li	s4,0
    80003f70:	b701                	j	80003e70 <namex+0x6c>

0000000080003f72 <dirlink>:
{
    80003f72:	715d                	addi	sp,sp,-80
    80003f74:	e486                	sd	ra,72(sp)
    80003f76:	e0a2                	sd	s0,64(sp)
    80003f78:	f84a                	sd	s2,48(sp)
    80003f7a:	ec56                	sd	s5,24(sp)
    80003f7c:	e85a                	sd	s6,16(sp)
    80003f7e:	0880                	addi	s0,sp,80
    80003f80:	892a                	mv	s2,a0
    80003f82:	8aae                	mv	s5,a1
    80003f84:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f86:	4601                	li	a2,0
    80003f88:	00000097          	auipc	ra,0x0
    80003f8c:	dbc080e7          	jalr	-580(ra) # 80003d44 <dirlookup>
    80003f90:	e129                	bnez	a0,80003fd2 <dirlink+0x60>
    80003f92:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f94:	04c92483          	lw	s1,76(s2)
    80003f98:	cca9                	beqz	s1,80003ff2 <dirlink+0x80>
    80003f9a:	f44e                	sd	s3,40(sp)
    80003f9c:	f052                	sd	s4,32(sp)
    80003f9e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fa0:	fb040a13          	addi	s4,s0,-80
    80003fa4:	49c1                	li	s3,16
    80003fa6:	874e                	mv	a4,s3
    80003fa8:	86a6                	mv	a3,s1
    80003faa:	8652                	mv	a2,s4
    80003fac:	4581                	li	a1,0
    80003fae:	854a                	mv	a0,s2
    80003fb0:	00000097          	auipc	ra,0x0
    80003fb4:	b58080e7          	jalr	-1192(ra) # 80003b08 <readi>
    80003fb8:	03351363          	bne	a0,s3,80003fde <dirlink+0x6c>
    if(de.inum == 0)
    80003fbc:	fb045783          	lhu	a5,-80(s0)
    80003fc0:	c79d                	beqz	a5,80003fee <dirlink+0x7c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fc2:	24c1                	addiw	s1,s1,16
    80003fc4:	04c92783          	lw	a5,76(s2)
    80003fc8:	fcf4efe3          	bltu	s1,a5,80003fa6 <dirlink+0x34>
    80003fcc:	79a2                	ld	s3,40(sp)
    80003fce:	7a02                	ld	s4,32(sp)
    80003fd0:	a00d                	j	80003ff2 <dirlink+0x80>
    iput(ip);
    80003fd2:	00000097          	auipc	ra,0x0
    80003fd6:	a36080e7          	jalr	-1482(ra) # 80003a08 <iput>
    return -1;
    80003fda:	557d                	li	a0,-1
    80003fdc:	a0a9                	j	80004026 <dirlink+0xb4>
      panic("dirlink read");
    80003fde:	00004517          	auipc	a0,0x4
    80003fe2:	5ba50513          	addi	a0,a0,1466 # 80008598 <etext+0x598>
    80003fe6:	ffffc097          	auipc	ra,0xffffc
    80003fea:	578080e7          	jalr	1400(ra) # 8000055e <panic>
    80003fee:	79a2                	ld	s3,40(sp)
    80003ff0:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003ff2:	4639                	li	a2,14
    80003ff4:	85d6                	mv	a1,s5
    80003ff6:	fb240513          	addi	a0,s0,-78
    80003ffa:	ffffd097          	auipc	ra,0xffffd
    80003ffe:	e6c080e7          	jalr	-404(ra) # 80000e66 <strncpy>
  de.inum = inum;
    80004002:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004006:	4741                	li	a4,16
    80004008:	86a6                	mv	a3,s1
    8000400a:	fb040613          	addi	a2,s0,-80
    8000400e:	4581                	li	a1,0
    80004010:	854a                	mv	a0,s2
    80004012:	00000097          	auipc	ra,0x0
    80004016:	bfc080e7          	jalr	-1028(ra) # 80003c0e <writei>
    8000401a:	1541                	addi	a0,a0,-16
    8000401c:	00a03533          	snez	a0,a0
    80004020:	40a0053b          	negw	a0,a0
    80004024:	74e2                	ld	s1,56(sp)
}
    80004026:	60a6                	ld	ra,72(sp)
    80004028:	6406                	ld	s0,64(sp)
    8000402a:	7942                	ld	s2,48(sp)
    8000402c:	6ae2                	ld	s5,24(sp)
    8000402e:	6b42                	ld	s6,16(sp)
    80004030:	6161                	addi	sp,sp,80
    80004032:	8082                	ret

0000000080004034 <namei>:

struct inode*
namei(char *path)
{
    80004034:	1101                	addi	sp,sp,-32
    80004036:	ec06                	sd	ra,24(sp)
    80004038:	e822                	sd	s0,16(sp)
    8000403a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000403c:	fe040613          	addi	a2,s0,-32
    80004040:	4581                	li	a1,0
    80004042:	00000097          	auipc	ra,0x0
    80004046:	dc2080e7          	jalr	-574(ra) # 80003e04 <namex>
}
    8000404a:	60e2                	ld	ra,24(sp)
    8000404c:	6442                	ld	s0,16(sp)
    8000404e:	6105                	addi	sp,sp,32
    80004050:	8082                	ret

0000000080004052 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004052:	1141                	addi	sp,sp,-16
    80004054:	e406                	sd	ra,8(sp)
    80004056:	e022                	sd	s0,0(sp)
    80004058:	0800                	addi	s0,sp,16
    8000405a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000405c:	4585                	li	a1,1
    8000405e:	00000097          	auipc	ra,0x0
    80004062:	da6080e7          	jalr	-602(ra) # 80003e04 <namex>
}
    80004066:	60a2                	ld	ra,8(sp)
    80004068:	6402                	ld	s0,0(sp)
    8000406a:	0141                	addi	sp,sp,16
    8000406c:	8082                	ret

000000008000406e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000406e:	1101                	addi	sp,sp,-32
    80004070:	ec06                	sd	ra,24(sp)
    80004072:	e822                	sd	s0,16(sp)
    80004074:	e426                	sd	s1,8(sp)
    80004076:	e04a                	sd	s2,0(sp)
    80004078:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000407a:	0001d917          	auipc	s2,0x1d
    8000407e:	b2690913          	addi	s2,s2,-1242 # 80020ba0 <log>
    80004082:	01892583          	lw	a1,24(s2)
    80004086:	02892503          	lw	a0,40(s2)
    8000408a:	fffff097          	auipc	ra,0xfffff
    8000408e:	fc2080e7          	jalr	-62(ra) # 8000304c <bread>
    80004092:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004094:	02c92603          	lw	a2,44(s2)
    80004098:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000409a:	00c05f63          	blez	a2,800040b8 <write_head+0x4a>
    8000409e:	0001d717          	auipc	a4,0x1d
    800040a2:	b3270713          	addi	a4,a4,-1230 # 80020bd0 <log+0x30>
    800040a6:	87aa                	mv	a5,a0
    800040a8:	060a                	slli	a2,a2,0x2
    800040aa:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800040ac:	4314                	lw	a3,0(a4)
    800040ae:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800040b0:	0711                	addi	a4,a4,4
    800040b2:	0791                	addi	a5,a5,4
    800040b4:	fec79ce3          	bne	a5,a2,800040ac <write_head+0x3e>
  }
  bwrite(buf);
    800040b8:	8526                	mv	a0,s1
    800040ba:	fffff097          	auipc	ra,0xfffff
    800040be:	084080e7          	jalr	132(ra) # 8000313e <bwrite>
  brelse(buf);
    800040c2:	8526                	mv	a0,s1
    800040c4:	fffff097          	auipc	ra,0xfffff
    800040c8:	0b8080e7          	jalr	184(ra) # 8000317c <brelse>
}
    800040cc:	60e2                	ld	ra,24(sp)
    800040ce:	6442                	ld	s0,16(sp)
    800040d0:	64a2                	ld	s1,8(sp)
    800040d2:	6902                	ld	s2,0(sp)
    800040d4:	6105                	addi	sp,sp,32
    800040d6:	8082                	ret

00000000800040d8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040d8:	0001d797          	auipc	a5,0x1d
    800040dc:	af47a783          	lw	a5,-1292(a5) # 80020bcc <log+0x2c>
    800040e0:	0cf05063          	blez	a5,800041a0 <install_trans+0xc8>
{
    800040e4:	715d                	addi	sp,sp,-80
    800040e6:	e486                	sd	ra,72(sp)
    800040e8:	e0a2                	sd	s0,64(sp)
    800040ea:	fc26                	sd	s1,56(sp)
    800040ec:	f84a                	sd	s2,48(sp)
    800040ee:	f44e                	sd	s3,40(sp)
    800040f0:	f052                	sd	s4,32(sp)
    800040f2:	ec56                	sd	s5,24(sp)
    800040f4:	e85a                	sd	s6,16(sp)
    800040f6:	e45e                	sd	s7,8(sp)
    800040f8:	0880                	addi	s0,sp,80
    800040fa:	8b2a                	mv	s6,a0
    800040fc:	0001da97          	auipc	s5,0x1d
    80004100:	ad4a8a93          	addi	s5,s5,-1324 # 80020bd0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004104:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004106:	0001d997          	auipc	s3,0x1d
    8000410a:	a9a98993          	addi	s3,s3,-1382 # 80020ba0 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000410e:	40000b93          	li	s7,1024
    80004112:	a00d                	j	80004134 <install_trans+0x5c>
    brelse(lbuf);
    80004114:	854a                	mv	a0,s2
    80004116:	fffff097          	auipc	ra,0xfffff
    8000411a:	066080e7          	jalr	102(ra) # 8000317c <brelse>
    brelse(dbuf);
    8000411e:	8526                	mv	a0,s1
    80004120:	fffff097          	auipc	ra,0xfffff
    80004124:	05c080e7          	jalr	92(ra) # 8000317c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004128:	2a05                	addiw	s4,s4,1
    8000412a:	0a91                	addi	s5,s5,4
    8000412c:	02c9a783          	lw	a5,44(s3)
    80004130:	04fa5d63          	bge	s4,a5,8000418a <install_trans+0xb2>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004134:	0189a583          	lw	a1,24(s3)
    80004138:	014585bb          	addw	a1,a1,s4
    8000413c:	2585                	addiw	a1,a1,1
    8000413e:	0289a503          	lw	a0,40(s3)
    80004142:	fffff097          	auipc	ra,0xfffff
    80004146:	f0a080e7          	jalr	-246(ra) # 8000304c <bread>
    8000414a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000414c:	000aa583          	lw	a1,0(s5)
    80004150:	0289a503          	lw	a0,40(s3)
    80004154:	fffff097          	auipc	ra,0xfffff
    80004158:	ef8080e7          	jalr	-264(ra) # 8000304c <bread>
    8000415c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000415e:	865e                	mv	a2,s7
    80004160:	05890593          	addi	a1,s2,88
    80004164:	05850513          	addi	a0,a0,88
    80004168:	ffffd097          	auipc	ra,0xffffd
    8000416c:	c4c080e7          	jalr	-948(ra) # 80000db4 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004170:	8526                	mv	a0,s1
    80004172:	fffff097          	auipc	ra,0xfffff
    80004176:	fcc080e7          	jalr	-52(ra) # 8000313e <bwrite>
    if(recovering == 0)
    8000417a:	f80b1de3          	bnez	s6,80004114 <install_trans+0x3c>
      bunpin(dbuf);
    8000417e:	8526                	mv	a0,s1
    80004180:	fffff097          	auipc	ra,0xfffff
    80004184:	0d0080e7          	jalr	208(ra) # 80003250 <bunpin>
    80004188:	b771                	j	80004114 <install_trans+0x3c>
}
    8000418a:	60a6                	ld	ra,72(sp)
    8000418c:	6406                	ld	s0,64(sp)
    8000418e:	74e2                	ld	s1,56(sp)
    80004190:	7942                	ld	s2,48(sp)
    80004192:	79a2                	ld	s3,40(sp)
    80004194:	7a02                	ld	s4,32(sp)
    80004196:	6ae2                	ld	s5,24(sp)
    80004198:	6b42                	ld	s6,16(sp)
    8000419a:	6ba2                	ld	s7,8(sp)
    8000419c:	6161                	addi	sp,sp,80
    8000419e:	8082                	ret
    800041a0:	8082                	ret

00000000800041a2 <initlog>:
{
    800041a2:	7179                	addi	sp,sp,-48
    800041a4:	f406                	sd	ra,40(sp)
    800041a6:	f022                	sd	s0,32(sp)
    800041a8:	ec26                	sd	s1,24(sp)
    800041aa:	e84a                	sd	s2,16(sp)
    800041ac:	e44e                	sd	s3,8(sp)
    800041ae:	1800                	addi	s0,sp,48
    800041b0:	892a                	mv	s2,a0
    800041b2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041b4:	0001d497          	auipc	s1,0x1d
    800041b8:	9ec48493          	addi	s1,s1,-1556 # 80020ba0 <log>
    800041bc:	00004597          	auipc	a1,0x4
    800041c0:	3ec58593          	addi	a1,a1,1004 # 800085a8 <etext+0x5a8>
    800041c4:	8526                	mv	a0,s1
    800041c6:	ffffd097          	auipc	ra,0xffffd
    800041ca:	9fc080e7          	jalr	-1540(ra) # 80000bc2 <initlock>
  log.start = sb->logstart;
    800041ce:	0149a583          	lw	a1,20(s3)
    800041d2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041d4:	0109a783          	lw	a5,16(s3)
    800041d8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041da:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041de:	854a                	mv	a0,s2
    800041e0:	fffff097          	auipc	ra,0xfffff
    800041e4:	e6c080e7          	jalr	-404(ra) # 8000304c <bread>
  log.lh.n = lh->n;
    800041e8:	4d30                	lw	a2,88(a0)
    800041ea:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041ec:	00c05f63          	blez	a2,8000420a <initlog+0x68>
    800041f0:	87aa                	mv	a5,a0
    800041f2:	0001d717          	auipc	a4,0x1d
    800041f6:	9de70713          	addi	a4,a4,-1570 # 80020bd0 <log+0x30>
    800041fa:	060a                	slli	a2,a2,0x2
    800041fc:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800041fe:	4ff4                	lw	a3,92(a5)
    80004200:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004202:	0791                	addi	a5,a5,4
    80004204:	0711                	addi	a4,a4,4
    80004206:	fec79ce3          	bne	a5,a2,800041fe <initlog+0x5c>
  brelse(buf);
    8000420a:	fffff097          	auipc	ra,0xfffff
    8000420e:	f72080e7          	jalr	-142(ra) # 8000317c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004212:	4505                	li	a0,1
    80004214:	00000097          	auipc	ra,0x0
    80004218:	ec4080e7          	jalr	-316(ra) # 800040d8 <install_trans>
  log.lh.n = 0;
    8000421c:	0001d797          	auipc	a5,0x1d
    80004220:	9a07a823          	sw	zero,-1616(a5) # 80020bcc <log+0x2c>
  write_head(); // clear the log
    80004224:	00000097          	auipc	ra,0x0
    80004228:	e4a080e7          	jalr	-438(ra) # 8000406e <write_head>
}
    8000422c:	70a2                	ld	ra,40(sp)
    8000422e:	7402                	ld	s0,32(sp)
    80004230:	64e2                	ld	s1,24(sp)
    80004232:	6942                	ld	s2,16(sp)
    80004234:	69a2                	ld	s3,8(sp)
    80004236:	6145                	addi	sp,sp,48
    80004238:	8082                	ret

000000008000423a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000423a:	1101                	addi	sp,sp,-32
    8000423c:	ec06                	sd	ra,24(sp)
    8000423e:	e822                	sd	s0,16(sp)
    80004240:	e426                	sd	s1,8(sp)
    80004242:	e04a                	sd	s2,0(sp)
    80004244:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004246:	0001d517          	auipc	a0,0x1d
    8000424a:	95a50513          	addi	a0,a0,-1702 # 80020ba0 <log>
    8000424e:	ffffd097          	auipc	ra,0xffffd
    80004252:	a0e080e7          	jalr	-1522(ra) # 80000c5c <acquire>
  while(1){
    if(log.committing){
    80004256:	0001d497          	auipc	s1,0x1d
    8000425a:	94a48493          	addi	s1,s1,-1718 # 80020ba0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000425e:	4979                	li	s2,30
    80004260:	a039                	j	8000426e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004262:	85a6                	mv	a1,s1
    80004264:	8526                	mv	a0,s1
    80004266:	ffffe097          	auipc	ra,0xffffe
    8000426a:	ffc080e7          	jalr	-4(ra) # 80002262 <sleep>
    if(log.committing){
    8000426e:	50dc                	lw	a5,36(s1)
    80004270:	fbed                	bnez	a5,80004262 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004272:	5098                	lw	a4,32(s1)
    80004274:	2705                	addiw	a4,a4,1
    80004276:	0027179b          	slliw	a5,a4,0x2
    8000427a:	9fb9                	addw	a5,a5,a4
    8000427c:	0017979b          	slliw	a5,a5,0x1
    80004280:	54d4                	lw	a3,44(s1)
    80004282:	9fb5                	addw	a5,a5,a3
    80004284:	00f95963          	bge	s2,a5,80004296 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004288:	85a6                	mv	a1,s1
    8000428a:	8526                	mv	a0,s1
    8000428c:	ffffe097          	auipc	ra,0xffffe
    80004290:	fd6080e7          	jalr	-42(ra) # 80002262 <sleep>
    80004294:	bfe9                	j	8000426e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004296:	0001d797          	auipc	a5,0x1d
    8000429a:	92e7a523          	sw	a4,-1750(a5) # 80020bc0 <log+0x20>
      release(&log.lock);
    8000429e:	0001d517          	auipc	a0,0x1d
    800042a2:	90250513          	addi	a0,a0,-1790 # 80020ba0 <log>
    800042a6:	ffffd097          	auipc	ra,0xffffd
    800042aa:	a66080e7          	jalr	-1434(ra) # 80000d0c <release>
      break;
    }
  }
}
    800042ae:	60e2                	ld	ra,24(sp)
    800042b0:	6442                	ld	s0,16(sp)
    800042b2:	64a2                	ld	s1,8(sp)
    800042b4:	6902                	ld	s2,0(sp)
    800042b6:	6105                	addi	sp,sp,32
    800042b8:	8082                	ret

00000000800042ba <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042ba:	7139                	addi	sp,sp,-64
    800042bc:	fc06                	sd	ra,56(sp)
    800042be:	f822                	sd	s0,48(sp)
    800042c0:	f426                	sd	s1,40(sp)
    800042c2:	f04a                	sd	s2,32(sp)
    800042c4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042c6:	0001d497          	auipc	s1,0x1d
    800042ca:	8da48493          	addi	s1,s1,-1830 # 80020ba0 <log>
    800042ce:	8526                	mv	a0,s1
    800042d0:	ffffd097          	auipc	ra,0xffffd
    800042d4:	98c080e7          	jalr	-1652(ra) # 80000c5c <acquire>
  log.outstanding -= 1;
    800042d8:	509c                	lw	a5,32(s1)
    800042da:	37fd                	addiw	a5,a5,-1
    800042dc:	893e                	mv	s2,a5
    800042de:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800042e0:	50dc                	lw	a5,36(s1)
    800042e2:	efb1                	bnez	a5,8000433e <end_op+0x84>
    panic("log.committing");
  if(log.outstanding == 0){
    800042e4:	06091863          	bnez	s2,80004354 <end_op+0x9a>
    do_commit = 1;
    log.committing = 1;
    800042e8:	0001d497          	auipc	s1,0x1d
    800042ec:	8b848493          	addi	s1,s1,-1864 # 80020ba0 <log>
    800042f0:	4785                	li	a5,1
    800042f2:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042f4:	8526                	mv	a0,s1
    800042f6:	ffffd097          	auipc	ra,0xffffd
    800042fa:	a16080e7          	jalr	-1514(ra) # 80000d0c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800042fe:	54dc                	lw	a5,44(s1)
    80004300:	08f04063          	bgtz	a5,80004380 <end_op+0xc6>
    acquire(&log.lock);
    80004304:	0001d517          	auipc	a0,0x1d
    80004308:	89c50513          	addi	a0,a0,-1892 # 80020ba0 <log>
    8000430c:	ffffd097          	auipc	ra,0xffffd
    80004310:	950080e7          	jalr	-1712(ra) # 80000c5c <acquire>
    log.committing = 0;
    80004314:	0001d797          	auipc	a5,0x1d
    80004318:	8a07a823          	sw	zero,-1872(a5) # 80020bc4 <log+0x24>
    wakeup(&log);
    8000431c:	0001d517          	auipc	a0,0x1d
    80004320:	88450513          	addi	a0,a0,-1916 # 80020ba0 <log>
    80004324:	ffffe097          	auipc	ra,0xffffe
    80004328:	fa2080e7          	jalr	-94(ra) # 800022c6 <wakeup>
    release(&log.lock);
    8000432c:	0001d517          	auipc	a0,0x1d
    80004330:	87450513          	addi	a0,a0,-1932 # 80020ba0 <log>
    80004334:	ffffd097          	auipc	ra,0xffffd
    80004338:	9d8080e7          	jalr	-1576(ra) # 80000d0c <release>
}
    8000433c:	a825                	j	80004374 <end_op+0xba>
    8000433e:	ec4e                	sd	s3,24(sp)
    80004340:	e852                	sd	s4,16(sp)
    80004342:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004344:	00004517          	auipc	a0,0x4
    80004348:	26c50513          	addi	a0,a0,620 # 800085b0 <etext+0x5b0>
    8000434c:	ffffc097          	auipc	ra,0xffffc
    80004350:	212080e7          	jalr	530(ra) # 8000055e <panic>
    wakeup(&log);
    80004354:	0001d517          	auipc	a0,0x1d
    80004358:	84c50513          	addi	a0,a0,-1972 # 80020ba0 <log>
    8000435c:	ffffe097          	auipc	ra,0xffffe
    80004360:	f6a080e7          	jalr	-150(ra) # 800022c6 <wakeup>
  release(&log.lock);
    80004364:	0001d517          	auipc	a0,0x1d
    80004368:	83c50513          	addi	a0,a0,-1988 # 80020ba0 <log>
    8000436c:	ffffd097          	auipc	ra,0xffffd
    80004370:	9a0080e7          	jalr	-1632(ra) # 80000d0c <release>
}
    80004374:	70e2                	ld	ra,56(sp)
    80004376:	7442                	ld	s0,48(sp)
    80004378:	74a2                	ld	s1,40(sp)
    8000437a:	7902                	ld	s2,32(sp)
    8000437c:	6121                	addi	sp,sp,64
    8000437e:	8082                	ret
    80004380:	ec4e                	sd	s3,24(sp)
    80004382:	e852                	sd	s4,16(sp)
    80004384:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004386:	0001da97          	auipc	s5,0x1d
    8000438a:	84aa8a93          	addi	s5,s5,-1974 # 80020bd0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000438e:	0001da17          	auipc	s4,0x1d
    80004392:	812a0a13          	addi	s4,s4,-2030 # 80020ba0 <log>
    80004396:	018a2583          	lw	a1,24(s4)
    8000439a:	012585bb          	addw	a1,a1,s2
    8000439e:	2585                	addiw	a1,a1,1
    800043a0:	028a2503          	lw	a0,40(s4)
    800043a4:	fffff097          	auipc	ra,0xfffff
    800043a8:	ca8080e7          	jalr	-856(ra) # 8000304c <bread>
    800043ac:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043ae:	000aa583          	lw	a1,0(s5)
    800043b2:	028a2503          	lw	a0,40(s4)
    800043b6:	fffff097          	auipc	ra,0xfffff
    800043ba:	c96080e7          	jalr	-874(ra) # 8000304c <bread>
    800043be:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800043c0:	40000613          	li	a2,1024
    800043c4:	05850593          	addi	a1,a0,88
    800043c8:	05848513          	addi	a0,s1,88
    800043cc:	ffffd097          	auipc	ra,0xffffd
    800043d0:	9e8080e7          	jalr	-1560(ra) # 80000db4 <memmove>
    bwrite(to);  // write the log
    800043d4:	8526                	mv	a0,s1
    800043d6:	fffff097          	auipc	ra,0xfffff
    800043da:	d68080e7          	jalr	-664(ra) # 8000313e <bwrite>
    brelse(from);
    800043de:	854e                	mv	a0,s3
    800043e0:	fffff097          	auipc	ra,0xfffff
    800043e4:	d9c080e7          	jalr	-612(ra) # 8000317c <brelse>
    brelse(to);
    800043e8:	8526                	mv	a0,s1
    800043ea:	fffff097          	auipc	ra,0xfffff
    800043ee:	d92080e7          	jalr	-622(ra) # 8000317c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043f2:	2905                	addiw	s2,s2,1
    800043f4:	0a91                	addi	s5,s5,4
    800043f6:	02ca2783          	lw	a5,44(s4)
    800043fa:	f8f94ee3          	blt	s2,a5,80004396 <end_op+0xdc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043fe:	00000097          	auipc	ra,0x0
    80004402:	c70080e7          	jalr	-912(ra) # 8000406e <write_head>
    install_trans(0); // Now install writes to home locations
    80004406:	4501                	li	a0,0
    80004408:	00000097          	auipc	ra,0x0
    8000440c:	cd0080e7          	jalr	-816(ra) # 800040d8 <install_trans>
    log.lh.n = 0;
    80004410:	0001c797          	auipc	a5,0x1c
    80004414:	7a07ae23          	sw	zero,1980(a5) # 80020bcc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004418:	00000097          	auipc	ra,0x0
    8000441c:	c56080e7          	jalr	-938(ra) # 8000406e <write_head>
    80004420:	69e2                	ld	s3,24(sp)
    80004422:	6a42                	ld	s4,16(sp)
    80004424:	6aa2                	ld	s5,8(sp)
    80004426:	bdf9                	j	80004304 <end_op+0x4a>

0000000080004428 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004428:	1101                	addi	sp,sp,-32
    8000442a:	ec06                	sd	ra,24(sp)
    8000442c:	e822                	sd	s0,16(sp)
    8000442e:	e426                	sd	s1,8(sp)
    80004430:	1000                	addi	s0,sp,32
    80004432:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004434:	0001c517          	auipc	a0,0x1c
    80004438:	76c50513          	addi	a0,a0,1900 # 80020ba0 <log>
    8000443c:	ffffd097          	auipc	ra,0xffffd
    80004440:	820080e7          	jalr	-2016(ra) # 80000c5c <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004444:	0001c617          	auipc	a2,0x1c
    80004448:	78862603          	lw	a2,1928(a2) # 80020bcc <log+0x2c>
    8000444c:	47f5                	li	a5,29
    8000444e:	06c7c663          	blt	a5,a2,800044ba <log_write+0x92>
    80004452:	0001c797          	auipc	a5,0x1c
    80004456:	76a7a783          	lw	a5,1898(a5) # 80020bbc <log+0x1c>
    8000445a:	37fd                	addiw	a5,a5,-1
    8000445c:	04f65f63          	bge	a2,a5,800044ba <log_write+0x92>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004460:	0001c797          	auipc	a5,0x1c
    80004464:	7607a783          	lw	a5,1888(a5) # 80020bc0 <log+0x20>
    80004468:	06f05163          	blez	a5,800044ca <log_write+0xa2>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000446c:	4781                	li	a5,0
    8000446e:	06c05663          	blez	a2,800044da <log_write+0xb2>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004472:	44cc                	lw	a1,12(s1)
    80004474:	0001c717          	auipc	a4,0x1c
    80004478:	75c70713          	addi	a4,a4,1884 # 80020bd0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000447c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000447e:	4314                	lw	a3,0(a4)
    80004480:	04b68d63          	beq	a3,a1,800044da <log_write+0xb2>
  for (i = 0; i < log.lh.n; i++) {
    80004484:	2785                	addiw	a5,a5,1
    80004486:	0711                	addi	a4,a4,4
    80004488:	fef61be3          	bne	a2,a5,8000447e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000448c:	060a                	slli	a2,a2,0x2
    8000448e:	02060613          	addi	a2,a2,32
    80004492:	0001c797          	auipc	a5,0x1c
    80004496:	70e78793          	addi	a5,a5,1806 # 80020ba0 <log>
    8000449a:	97b2                	add	a5,a5,a2
    8000449c:	44d8                	lw	a4,12(s1)
    8000449e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800044a0:	8526                	mv	a0,s1
    800044a2:	fffff097          	auipc	ra,0xfffff
    800044a6:	d72080e7          	jalr	-654(ra) # 80003214 <bpin>
    log.lh.n++;
    800044aa:	0001c717          	auipc	a4,0x1c
    800044ae:	6f670713          	addi	a4,a4,1782 # 80020ba0 <log>
    800044b2:	575c                	lw	a5,44(a4)
    800044b4:	2785                	addiw	a5,a5,1
    800044b6:	d75c                	sw	a5,44(a4)
    800044b8:	a835                	j	800044f4 <log_write+0xcc>
    panic("too big a transaction");
    800044ba:	00004517          	auipc	a0,0x4
    800044be:	10650513          	addi	a0,a0,262 # 800085c0 <etext+0x5c0>
    800044c2:	ffffc097          	auipc	ra,0xffffc
    800044c6:	09c080e7          	jalr	156(ra) # 8000055e <panic>
    panic("log_write outside of trans");
    800044ca:	00004517          	auipc	a0,0x4
    800044ce:	10e50513          	addi	a0,a0,270 # 800085d8 <etext+0x5d8>
    800044d2:	ffffc097          	auipc	ra,0xffffc
    800044d6:	08c080e7          	jalr	140(ra) # 8000055e <panic>
  log.lh.block[i] = b->blockno;
    800044da:	00279693          	slli	a3,a5,0x2
    800044de:	02068693          	addi	a3,a3,32
    800044e2:	0001c717          	auipc	a4,0x1c
    800044e6:	6be70713          	addi	a4,a4,1726 # 80020ba0 <log>
    800044ea:	9736                	add	a4,a4,a3
    800044ec:	44d4                	lw	a3,12(s1)
    800044ee:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800044f0:	faf608e3          	beq	a2,a5,800044a0 <log_write+0x78>
  }
  release(&log.lock);
    800044f4:	0001c517          	auipc	a0,0x1c
    800044f8:	6ac50513          	addi	a0,a0,1708 # 80020ba0 <log>
    800044fc:	ffffd097          	auipc	ra,0xffffd
    80004500:	810080e7          	jalr	-2032(ra) # 80000d0c <release>
}
    80004504:	60e2                	ld	ra,24(sp)
    80004506:	6442                	ld	s0,16(sp)
    80004508:	64a2                	ld	s1,8(sp)
    8000450a:	6105                	addi	sp,sp,32
    8000450c:	8082                	ret

000000008000450e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000450e:	1101                	addi	sp,sp,-32
    80004510:	ec06                	sd	ra,24(sp)
    80004512:	e822                	sd	s0,16(sp)
    80004514:	e426                	sd	s1,8(sp)
    80004516:	e04a                	sd	s2,0(sp)
    80004518:	1000                	addi	s0,sp,32
    8000451a:	84aa                	mv	s1,a0
    8000451c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000451e:	00004597          	auipc	a1,0x4
    80004522:	0da58593          	addi	a1,a1,218 # 800085f8 <etext+0x5f8>
    80004526:	0521                	addi	a0,a0,8
    80004528:	ffffc097          	auipc	ra,0xffffc
    8000452c:	69a080e7          	jalr	1690(ra) # 80000bc2 <initlock>
  lk->name = name;
    80004530:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004534:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004538:	0204a423          	sw	zero,40(s1)
}
    8000453c:	60e2                	ld	ra,24(sp)
    8000453e:	6442                	ld	s0,16(sp)
    80004540:	64a2                	ld	s1,8(sp)
    80004542:	6902                	ld	s2,0(sp)
    80004544:	6105                	addi	sp,sp,32
    80004546:	8082                	ret

0000000080004548 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004548:	1101                	addi	sp,sp,-32
    8000454a:	ec06                	sd	ra,24(sp)
    8000454c:	e822                	sd	s0,16(sp)
    8000454e:	e426                	sd	s1,8(sp)
    80004550:	e04a                	sd	s2,0(sp)
    80004552:	1000                	addi	s0,sp,32
    80004554:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004556:	00850913          	addi	s2,a0,8
    8000455a:	854a                	mv	a0,s2
    8000455c:	ffffc097          	auipc	ra,0xffffc
    80004560:	700080e7          	jalr	1792(ra) # 80000c5c <acquire>
  while (lk->locked) {
    80004564:	409c                	lw	a5,0(s1)
    80004566:	cb89                	beqz	a5,80004578 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004568:	85ca                	mv	a1,s2
    8000456a:	8526                	mv	a0,s1
    8000456c:	ffffe097          	auipc	ra,0xffffe
    80004570:	cf6080e7          	jalr	-778(ra) # 80002262 <sleep>
  while (lk->locked) {
    80004574:	409c                	lw	a5,0(s1)
    80004576:	fbed                	bnez	a5,80004568 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004578:	4785                	li	a5,1
    8000457a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000457c:	ffffd097          	auipc	ra,0xffffd
    80004580:	638080e7          	jalr	1592(ra) # 80001bb4 <myproc>
    80004584:	591c                	lw	a5,48(a0)
    80004586:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004588:	854a                	mv	a0,s2
    8000458a:	ffffc097          	auipc	ra,0xffffc
    8000458e:	782080e7          	jalr	1922(ra) # 80000d0c <release>
}
    80004592:	60e2                	ld	ra,24(sp)
    80004594:	6442                	ld	s0,16(sp)
    80004596:	64a2                	ld	s1,8(sp)
    80004598:	6902                	ld	s2,0(sp)
    8000459a:	6105                	addi	sp,sp,32
    8000459c:	8082                	ret

000000008000459e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000459e:	1101                	addi	sp,sp,-32
    800045a0:	ec06                	sd	ra,24(sp)
    800045a2:	e822                	sd	s0,16(sp)
    800045a4:	e426                	sd	s1,8(sp)
    800045a6:	e04a                	sd	s2,0(sp)
    800045a8:	1000                	addi	s0,sp,32
    800045aa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045ac:	00850913          	addi	s2,a0,8
    800045b0:	854a                	mv	a0,s2
    800045b2:	ffffc097          	auipc	ra,0xffffc
    800045b6:	6aa080e7          	jalr	1706(ra) # 80000c5c <acquire>
  lk->locked = 0;
    800045ba:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045be:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800045c2:	8526                	mv	a0,s1
    800045c4:	ffffe097          	auipc	ra,0xffffe
    800045c8:	d02080e7          	jalr	-766(ra) # 800022c6 <wakeup>
  release(&lk->lk);
    800045cc:	854a                	mv	a0,s2
    800045ce:	ffffc097          	auipc	ra,0xffffc
    800045d2:	73e080e7          	jalr	1854(ra) # 80000d0c <release>
}
    800045d6:	60e2                	ld	ra,24(sp)
    800045d8:	6442                	ld	s0,16(sp)
    800045da:	64a2                	ld	s1,8(sp)
    800045dc:	6902                	ld	s2,0(sp)
    800045de:	6105                	addi	sp,sp,32
    800045e0:	8082                	ret

00000000800045e2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045e2:	7179                	addi	sp,sp,-48
    800045e4:	f406                	sd	ra,40(sp)
    800045e6:	f022                	sd	s0,32(sp)
    800045e8:	ec26                	sd	s1,24(sp)
    800045ea:	e84a                	sd	s2,16(sp)
    800045ec:	1800                	addi	s0,sp,48
    800045ee:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800045f0:	00850913          	addi	s2,a0,8
    800045f4:	854a                	mv	a0,s2
    800045f6:	ffffc097          	auipc	ra,0xffffc
    800045fa:	666080e7          	jalr	1638(ra) # 80000c5c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800045fe:	409c                	lw	a5,0(s1)
    80004600:	ef91                	bnez	a5,8000461c <holdingsleep+0x3a>
    80004602:	4481                	li	s1,0
  release(&lk->lk);
    80004604:	854a                	mv	a0,s2
    80004606:	ffffc097          	auipc	ra,0xffffc
    8000460a:	706080e7          	jalr	1798(ra) # 80000d0c <release>
  return r;
}
    8000460e:	8526                	mv	a0,s1
    80004610:	70a2                	ld	ra,40(sp)
    80004612:	7402                	ld	s0,32(sp)
    80004614:	64e2                	ld	s1,24(sp)
    80004616:	6942                	ld	s2,16(sp)
    80004618:	6145                	addi	sp,sp,48
    8000461a:	8082                	ret
    8000461c:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000461e:	0284a983          	lw	s3,40(s1)
    80004622:	ffffd097          	auipc	ra,0xffffd
    80004626:	592080e7          	jalr	1426(ra) # 80001bb4 <myproc>
    8000462a:	5904                	lw	s1,48(a0)
    8000462c:	413484b3          	sub	s1,s1,s3
    80004630:	0014b493          	seqz	s1,s1
    80004634:	69a2                	ld	s3,8(sp)
    80004636:	b7f9                	j	80004604 <holdingsleep+0x22>

0000000080004638 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004638:	1141                	addi	sp,sp,-16
    8000463a:	e406                	sd	ra,8(sp)
    8000463c:	e022                	sd	s0,0(sp)
    8000463e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004640:	00004597          	auipc	a1,0x4
    80004644:	fc858593          	addi	a1,a1,-56 # 80008608 <etext+0x608>
    80004648:	0001c517          	auipc	a0,0x1c
    8000464c:	6a050513          	addi	a0,a0,1696 # 80020ce8 <ftable>
    80004650:	ffffc097          	auipc	ra,0xffffc
    80004654:	572080e7          	jalr	1394(ra) # 80000bc2 <initlock>
}
    80004658:	60a2                	ld	ra,8(sp)
    8000465a:	6402                	ld	s0,0(sp)
    8000465c:	0141                	addi	sp,sp,16
    8000465e:	8082                	ret

0000000080004660 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004660:	1101                	addi	sp,sp,-32
    80004662:	ec06                	sd	ra,24(sp)
    80004664:	e822                	sd	s0,16(sp)
    80004666:	e426                	sd	s1,8(sp)
    80004668:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000466a:	0001c517          	auipc	a0,0x1c
    8000466e:	67e50513          	addi	a0,a0,1662 # 80020ce8 <ftable>
    80004672:	ffffc097          	auipc	ra,0xffffc
    80004676:	5ea080e7          	jalr	1514(ra) # 80000c5c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000467a:	0001c497          	auipc	s1,0x1c
    8000467e:	68648493          	addi	s1,s1,1670 # 80020d00 <ftable+0x18>
    80004682:	0001d717          	auipc	a4,0x1d
    80004686:	61e70713          	addi	a4,a4,1566 # 80021ca0 <disk>
    if(f->ref == 0){
    8000468a:	40dc                	lw	a5,4(s1)
    8000468c:	cf99                	beqz	a5,800046aa <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000468e:	02848493          	addi	s1,s1,40
    80004692:	fee49ce3          	bne	s1,a4,8000468a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004696:	0001c517          	auipc	a0,0x1c
    8000469a:	65250513          	addi	a0,a0,1618 # 80020ce8 <ftable>
    8000469e:	ffffc097          	auipc	ra,0xffffc
    800046a2:	66e080e7          	jalr	1646(ra) # 80000d0c <release>
  return 0;
    800046a6:	4481                	li	s1,0
    800046a8:	a819                	j	800046be <filealloc+0x5e>
      f->ref = 1;
    800046aa:	4785                	li	a5,1
    800046ac:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046ae:	0001c517          	auipc	a0,0x1c
    800046b2:	63a50513          	addi	a0,a0,1594 # 80020ce8 <ftable>
    800046b6:	ffffc097          	auipc	ra,0xffffc
    800046ba:	656080e7          	jalr	1622(ra) # 80000d0c <release>
}
    800046be:	8526                	mv	a0,s1
    800046c0:	60e2                	ld	ra,24(sp)
    800046c2:	6442                	ld	s0,16(sp)
    800046c4:	64a2                	ld	s1,8(sp)
    800046c6:	6105                	addi	sp,sp,32
    800046c8:	8082                	ret

00000000800046ca <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046ca:	1101                	addi	sp,sp,-32
    800046cc:	ec06                	sd	ra,24(sp)
    800046ce:	e822                	sd	s0,16(sp)
    800046d0:	e426                	sd	s1,8(sp)
    800046d2:	1000                	addi	s0,sp,32
    800046d4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046d6:	0001c517          	auipc	a0,0x1c
    800046da:	61250513          	addi	a0,a0,1554 # 80020ce8 <ftable>
    800046de:	ffffc097          	auipc	ra,0xffffc
    800046e2:	57e080e7          	jalr	1406(ra) # 80000c5c <acquire>
  if(f->ref < 1)
    800046e6:	40dc                	lw	a5,4(s1)
    800046e8:	02f05263          	blez	a5,8000470c <filedup+0x42>
    panic("filedup");
  f->ref++;
    800046ec:	2785                	addiw	a5,a5,1
    800046ee:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800046f0:	0001c517          	auipc	a0,0x1c
    800046f4:	5f850513          	addi	a0,a0,1528 # 80020ce8 <ftable>
    800046f8:	ffffc097          	auipc	ra,0xffffc
    800046fc:	614080e7          	jalr	1556(ra) # 80000d0c <release>
  return f;
}
    80004700:	8526                	mv	a0,s1
    80004702:	60e2                	ld	ra,24(sp)
    80004704:	6442                	ld	s0,16(sp)
    80004706:	64a2                	ld	s1,8(sp)
    80004708:	6105                	addi	sp,sp,32
    8000470a:	8082                	ret
    panic("filedup");
    8000470c:	00004517          	auipc	a0,0x4
    80004710:	f0450513          	addi	a0,a0,-252 # 80008610 <etext+0x610>
    80004714:	ffffc097          	auipc	ra,0xffffc
    80004718:	e4a080e7          	jalr	-438(ra) # 8000055e <panic>

000000008000471c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000471c:	7139                	addi	sp,sp,-64
    8000471e:	fc06                	sd	ra,56(sp)
    80004720:	f822                	sd	s0,48(sp)
    80004722:	f426                	sd	s1,40(sp)
    80004724:	0080                	addi	s0,sp,64
    80004726:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004728:	0001c517          	auipc	a0,0x1c
    8000472c:	5c050513          	addi	a0,a0,1472 # 80020ce8 <ftable>
    80004730:	ffffc097          	auipc	ra,0xffffc
    80004734:	52c080e7          	jalr	1324(ra) # 80000c5c <acquire>
  if(f->ref < 1)
    80004738:	40dc                	lw	a5,4(s1)
    8000473a:	04f05c63          	blez	a5,80004792 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    8000473e:	37fd                	addiw	a5,a5,-1
    80004740:	c0dc                	sw	a5,4(s1)
    80004742:	06f04463          	bgtz	a5,800047aa <fileclose+0x8e>
    80004746:	f04a                	sd	s2,32(sp)
    80004748:	ec4e                	sd	s3,24(sp)
    8000474a:	e852                	sd	s4,16(sp)
    8000474c:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000474e:	0004a903          	lw	s2,0(s1)
    80004752:	0094c783          	lbu	a5,9(s1)
    80004756:	89be                	mv	s3,a5
    80004758:	689c                	ld	a5,16(s1)
    8000475a:	8a3e                	mv	s4,a5
    8000475c:	6c9c                	ld	a5,24(s1)
    8000475e:	8abe                	mv	s5,a5
  f->ref = 0;
    80004760:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004764:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004768:	0001c517          	auipc	a0,0x1c
    8000476c:	58050513          	addi	a0,a0,1408 # 80020ce8 <ftable>
    80004770:	ffffc097          	auipc	ra,0xffffc
    80004774:	59c080e7          	jalr	1436(ra) # 80000d0c <release>

  if(ff.type == FD_PIPE){
    80004778:	4785                	li	a5,1
    8000477a:	04f90563          	beq	s2,a5,800047c4 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000477e:	ffe9079b          	addiw	a5,s2,-2
    80004782:	4705                	li	a4,1
    80004784:	04f77b63          	bgeu	a4,a5,800047da <fileclose+0xbe>
    80004788:	7902                	ld	s2,32(sp)
    8000478a:	69e2                	ld	s3,24(sp)
    8000478c:	6a42                	ld	s4,16(sp)
    8000478e:	6aa2                	ld	s5,8(sp)
    80004790:	a02d                	j	800047ba <fileclose+0x9e>
    80004792:	f04a                	sd	s2,32(sp)
    80004794:	ec4e                	sd	s3,24(sp)
    80004796:	e852                	sd	s4,16(sp)
    80004798:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000479a:	00004517          	auipc	a0,0x4
    8000479e:	e7e50513          	addi	a0,a0,-386 # 80008618 <etext+0x618>
    800047a2:	ffffc097          	auipc	ra,0xffffc
    800047a6:	dbc080e7          	jalr	-580(ra) # 8000055e <panic>
    release(&ftable.lock);
    800047aa:	0001c517          	auipc	a0,0x1c
    800047ae:	53e50513          	addi	a0,a0,1342 # 80020ce8 <ftable>
    800047b2:	ffffc097          	auipc	ra,0xffffc
    800047b6:	55a080e7          	jalr	1370(ra) # 80000d0c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800047ba:	70e2                	ld	ra,56(sp)
    800047bc:	7442                	ld	s0,48(sp)
    800047be:	74a2                	ld	s1,40(sp)
    800047c0:	6121                	addi	sp,sp,64
    800047c2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047c4:	85ce                	mv	a1,s3
    800047c6:	8552                	mv	a0,s4
    800047c8:	00000097          	auipc	ra,0x0
    800047cc:	3b4080e7          	jalr	948(ra) # 80004b7c <pipeclose>
    800047d0:	7902                	ld	s2,32(sp)
    800047d2:	69e2                	ld	s3,24(sp)
    800047d4:	6a42                	ld	s4,16(sp)
    800047d6:	6aa2                	ld	s5,8(sp)
    800047d8:	b7cd                	j	800047ba <fileclose+0x9e>
    begin_op();
    800047da:	00000097          	auipc	ra,0x0
    800047de:	a60080e7          	jalr	-1440(ra) # 8000423a <begin_op>
    iput(ff.ip);
    800047e2:	8556                	mv	a0,s5
    800047e4:	fffff097          	auipc	ra,0xfffff
    800047e8:	224080e7          	jalr	548(ra) # 80003a08 <iput>
    end_op();
    800047ec:	00000097          	auipc	ra,0x0
    800047f0:	ace080e7          	jalr	-1330(ra) # 800042ba <end_op>
    800047f4:	7902                	ld	s2,32(sp)
    800047f6:	69e2                	ld	s3,24(sp)
    800047f8:	6a42                	ld	s4,16(sp)
    800047fa:	6aa2                	ld	s5,8(sp)
    800047fc:	bf7d                	j	800047ba <fileclose+0x9e>

00000000800047fe <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047fe:	715d                	addi	sp,sp,-80
    80004800:	e486                	sd	ra,72(sp)
    80004802:	e0a2                	sd	s0,64(sp)
    80004804:	fc26                	sd	s1,56(sp)
    80004806:	f052                	sd	s4,32(sp)
    80004808:	0880                	addi	s0,sp,80
    8000480a:	84aa                	mv	s1,a0
    8000480c:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000480e:	ffffd097          	auipc	ra,0xffffd
    80004812:	3a6080e7          	jalr	934(ra) # 80001bb4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004816:	409c                	lw	a5,0(s1)
    80004818:	37f9                	addiw	a5,a5,-2
    8000481a:	4705                	li	a4,1
    8000481c:	04f76a63          	bltu	a4,a5,80004870 <filestat+0x72>
    80004820:	f84a                	sd	s2,48(sp)
    80004822:	f44e                	sd	s3,40(sp)
    80004824:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004826:	6c88                	ld	a0,24(s1)
    80004828:	fffff097          	auipc	ra,0xfffff
    8000482c:	022080e7          	jalr	34(ra) # 8000384a <ilock>
    stati(f->ip, &st);
    80004830:	fb840913          	addi	s2,s0,-72
    80004834:	85ca                	mv	a1,s2
    80004836:	6c88                	ld	a0,24(s1)
    80004838:	fffff097          	auipc	ra,0xfffff
    8000483c:	2a2080e7          	jalr	674(ra) # 80003ada <stati>
    iunlock(f->ip);
    80004840:	6c88                	ld	a0,24(s1)
    80004842:	fffff097          	auipc	ra,0xfffff
    80004846:	0ce080e7          	jalr	206(ra) # 80003910 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000484a:	46e1                	li	a3,24
    8000484c:	864a                	mv	a2,s2
    8000484e:	85d2                	mv	a1,s4
    80004850:	0509b503          	ld	a0,80(s3)
    80004854:	ffffd097          	auipc	ra,0xffffd
    80004858:	fac080e7          	jalr	-84(ra) # 80001800 <copyout>
    8000485c:	41f5551b          	sraiw	a0,a0,0x1f
    80004860:	7942                	ld	s2,48(sp)
    80004862:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004864:	60a6                	ld	ra,72(sp)
    80004866:	6406                	ld	s0,64(sp)
    80004868:	74e2                	ld	s1,56(sp)
    8000486a:	7a02                	ld	s4,32(sp)
    8000486c:	6161                	addi	sp,sp,80
    8000486e:	8082                	ret
  return -1;
    80004870:	557d                	li	a0,-1
    80004872:	bfcd                	j	80004864 <filestat+0x66>

0000000080004874 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004874:	7179                	addi	sp,sp,-48
    80004876:	f406                	sd	ra,40(sp)
    80004878:	f022                	sd	s0,32(sp)
    8000487a:	e84a                	sd	s2,16(sp)
    8000487c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000487e:	00854783          	lbu	a5,8(a0)
    80004882:	cbc5                	beqz	a5,80004932 <fileread+0xbe>
    80004884:	ec26                	sd	s1,24(sp)
    80004886:	e44e                	sd	s3,8(sp)
    80004888:	84aa                	mv	s1,a0
    8000488a:	892e                	mv	s2,a1
    8000488c:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    8000488e:	411c                	lw	a5,0(a0)
    80004890:	4705                	li	a4,1
    80004892:	04e78963          	beq	a5,a4,800048e4 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004896:	470d                	li	a4,3
    80004898:	04e78f63          	beq	a5,a4,800048f6 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000489c:	4709                	li	a4,2
    8000489e:	08e79263          	bne	a5,a4,80004922 <fileread+0xae>
    ilock(f->ip);
    800048a2:	6d08                	ld	a0,24(a0)
    800048a4:	fffff097          	auipc	ra,0xfffff
    800048a8:	fa6080e7          	jalr	-90(ra) # 8000384a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048ac:	874e                	mv	a4,s3
    800048ae:	5094                	lw	a3,32(s1)
    800048b0:	864a                	mv	a2,s2
    800048b2:	4585                	li	a1,1
    800048b4:	6c88                	ld	a0,24(s1)
    800048b6:	fffff097          	auipc	ra,0xfffff
    800048ba:	252080e7          	jalr	594(ra) # 80003b08 <readi>
    800048be:	892a                	mv	s2,a0
    800048c0:	00a05563          	blez	a0,800048ca <fileread+0x56>
      f->off += r;
    800048c4:	509c                	lw	a5,32(s1)
    800048c6:	9fa9                	addw	a5,a5,a0
    800048c8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048ca:	6c88                	ld	a0,24(s1)
    800048cc:	fffff097          	auipc	ra,0xfffff
    800048d0:	044080e7          	jalr	68(ra) # 80003910 <iunlock>
    800048d4:	64e2                	ld	s1,24(sp)
    800048d6:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800048d8:	854a                	mv	a0,s2
    800048da:	70a2                	ld	ra,40(sp)
    800048dc:	7402                	ld	s0,32(sp)
    800048de:	6942                	ld	s2,16(sp)
    800048e0:	6145                	addi	sp,sp,48
    800048e2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800048e4:	6908                	ld	a0,16(a0)
    800048e6:	00000097          	auipc	ra,0x0
    800048ea:	428080e7          	jalr	1064(ra) # 80004d0e <piperead>
    800048ee:	892a                	mv	s2,a0
    800048f0:	64e2                	ld	s1,24(sp)
    800048f2:	69a2                	ld	s3,8(sp)
    800048f4:	b7d5                	j	800048d8 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048f6:	02451783          	lh	a5,36(a0)
    800048fa:	03079693          	slli	a3,a5,0x30
    800048fe:	92c1                	srli	a3,a3,0x30
    80004900:	4725                	li	a4,9
    80004902:	02d76b63          	bltu	a4,a3,80004938 <fileread+0xc4>
    80004906:	0792                	slli	a5,a5,0x4
    80004908:	0001c717          	auipc	a4,0x1c
    8000490c:	34070713          	addi	a4,a4,832 # 80020c48 <devsw>
    80004910:	97ba                	add	a5,a5,a4
    80004912:	639c                	ld	a5,0(a5)
    80004914:	c79d                	beqz	a5,80004942 <fileread+0xce>
    r = devsw[f->major].read(1, addr, n);
    80004916:	4505                	li	a0,1
    80004918:	9782                	jalr	a5
    8000491a:	892a                	mv	s2,a0
    8000491c:	64e2                	ld	s1,24(sp)
    8000491e:	69a2                	ld	s3,8(sp)
    80004920:	bf65                	j	800048d8 <fileread+0x64>
    panic("fileread");
    80004922:	00004517          	auipc	a0,0x4
    80004926:	d0650513          	addi	a0,a0,-762 # 80008628 <etext+0x628>
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	c34080e7          	jalr	-972(ra) # 8000055e <panic>
    return -1;
    80004932:	57fd                	li	a5,-1
    80004934:	893e                	mv	s2,a5
    80004936:	b74d                	j	800048d8 <fileread+0x64>
      return -1;
    80004938:	57fd                	li	a5,-1
    8000493a:	893e                	mv	s2,a5
    8000493c:	64e2                	ld	s1,24(sp)
    8000493e:	69a2                	ld	s3,8(sp)
    80004940:	bf61                	j	800048d8 <fileread+0x64>
    80004942:	57fd                	li	a5,-1
    80004944:	893e                	mv	s2,a5
    80004946:	64e2                	ld	s1,24(sp)
    80004948:	69a2                	ld	s3,8(sp)
    8000494a:	b779                	j	800048d8 <fileread+0x64>

000000008000494c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000494c:	00954783          	lbu	a5,9(a0)
    80004950:	12078d63          	beqz	a5,80004a8a <filewrite+0x13e>
{
    80004954:	711d                	addi	sp,sp,-96
    80004956:	ec86                	sd	ra,88(sp)
    80004958:	e8a2                	sd	s0,80(sp)
    8000495a:	e0ca                	sd	s2,64(sp)
    8000495c:	f456                	sd	s5,40(sp)
    8000495e:	f05a                	sd	s6,32(sp)
    80004960:	1080                	addi	s0,sp,96
    80004962:	892a                	mv	s2,a0
    80004964:	8b2e                	mv	s6,a1
    80004966:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004968:	411c                	lw	a5,0(a0)
    8000496a:	4705                	li	a4,1
    8000496c:	02e78a63          	beq	a5,a4,800049a0 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004970:	470d                	li	a4,3
    80004972:	02e78d63          	beq	a5,a4,800049ac <filewrite+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004976:	4709                	li	a4,2
    80004978:	0ee79b63          	bne	a5,a4,80004a6e <filewrite+0x122>
    8000497c:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000497e:	0cc05663          	blez	a2,80004a4a <filewrite+0xfe>
    80004982:	e4a6                	sd	s1,72(sp)
    80004984:	fc4e                	sd	s3,56(sp)
    80004986:	ec5e                	sd	s7,24(sp)
    80004988:	e862                	sd	s8,16(sp)
    8000498a:	e466                	sd	s9,8(sp)
    int i = 0;
    8000498c:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    8000498e:	6b85                	lui	s7,0x1
    80004990:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004994:	6785                	lui	a5,0x1
    80004996:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    8000499a:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000499c:	4c05                	li	s8,1
    8000499e:	a849                	j	80004a30 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800049a0:	6908                	ld	a0,16(a0)
    800049a2:	00000097          	auipc	ra,0x0
    800049a6:	250080e7          	jalr	592(ra) # 80004bf2 <pipewrite>
    800049aa:	a85d                	j	80004a60 <filewrite+0x114>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049ac:	02451783          	lh	a5,36(a0)
    800049b0:	03079693          	slli	a3,a5,0x30
    800049b4:	92c1                	srli	a3,a3,0x30
    800049b6:	4725                	li	a4,9
    800049b8:	0cd76b63          	bltu	a4,a3,80004a8e <filewrite+0x142>
    800049bc:	0792                	slli	a5,a5,0x4
    800049be:	0001c717          	auipc	a4,0x1c
    800049c2:	28a70713          	addi	a4,a4,650 # 80020c48 <devsw>
    800049c6:	97ba                	add	a5,a5,a4
    800049c8:	679c                	ld	a5,8(a5)
    800049ca:	c7e1                	beqz	a5,80004a92 <filewrite+0x146>
    ret = devsw[f->major].write(1, addr, n);
    800049cc:	4505                	li	a0,1
    800049ce:	9782                	jalr	a5
    800049d0:	a841                	j	80004a60 <filewrite+0x114>
      if(n1 > max)
    800049d2:	2981                	sext.w	s3,s3
      begin_op();
    800049d4:	00000097          	auipc	ra,0x0
    800049d8:	866080e7          	jalr	-1946(ra) # 8000423a <begin_op>
      ilock(f->ip);
    800049dc:	01893503          	ld	a0,24(s2)
    800049e0:	fffff097          	auipc	ra,0xfffff
    800049e4:	e6a080e7          	jalr	-406(ra) # 8000384a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049e8:	874e                	mv	a4,s3
    800049ea:	02092683          	lw	a3,32(s2)
    800049ee:	016a0633          	add	a2,s4,s6
    800049f2:	85e2                	mv	a1,s8
    800049f4:	01893503          	ld	a0,24(s2)
    800049f8:	fffff097          	auipc	ra,0xfffff
    800049fc:	216080e7          	jalr	534(ra) # 80003c0e <writei>
    80004a00:	84aa                	mv	s1,a0
    80004a02:	00a05763          	blez	a0,80004a10 <filewrite+0xc4>
        f->off += r;
    80004a06:	02092783          	lw	a5,32(s2)
    80004a0a:	9fa9                	addw	a5,a5,a0
    80004a0c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a10:	01893503          	ld	a0,24(s2)
    80004a14:	fffff097          	auipc	ra,0xfffff
    80004a18:	efc080e7          	jalr	-260(ra) # 80003910 <iunlock>
      end_op();
    80004a1c:	00000097          	auipc	ra,0x0
    80004a20:	89e080e7          	jalr	-1890(ra) # 800042ba <end_op>

      if(r != n1){
    80004a24:	02999563          	bne	s3,s1,80004a4e <filewrite+0x102>
        // error from writei
        break;
      }
      i += r;
    80004a28:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004a2c:	015a5963          	bge	s4,s5,80004a3e <filewrite+0xf2>
      int n1 = n - i;
    80004a30:	414a87bb          	subw	a5,s5,s4
    80004a34:	89be                	mv	s3,a5
      if(n1 > max)
    80004a36:	f8fbdee3          	bge	s7,a5,800049d2 <filewrite+0x86>
    80004a3a:	89e6                	mv	s3,s9
    80004a3c:	bf59                	j	800049d2 <filewrite+0x86>
    80004a3e:	64a6                	ld	s1,72(sp)
    80004a40:	79e2                	ld	s3,56(sp)
    80004a42:	6be2                	ld	s7,24(sp)
    80004a44:	6c42                	ld	s8,16(sp)
    80004a46:	6ca2                	ld	s9,8(sp)
    80004a48:	a801                	j	80004a58 <filewrite+0x10c>
    int i = 0;
    80004a4a:	4a01                	li	s4,0
    80004a4c:	a031                	j	80004a58 <filewrite+0x10c>
    80004a4e:	64a6                	ld	s1,72(sp)
    80004a50:	79e2                	ld	s3,56(sp)
    80004a52:	6be2                	ld	s7,24(sp)
    80004a54:	6c42                	ld	s8,16(sp)
    80004a56:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004a58:	034a9f63          	bne	s5,s4,80004a96 <filewrite+0x14a>
    80004a5c:	8556                	mv	a0,s5
    80004a5e:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a60:	60e6                	ld	ra,88(sp)
    80004a62:	6446                	ld	s0,80(sp)
    80004a64:	6906                	ld	s2,64(sp)
    80004a66:	7aa2                	ld	s5,40(sp)
    80004a68:	7b02                	ld	s6,32(sp)
    80004a6a:	6125                	addi	sp,sp,96
    80004a6c:	8082                	ret
    80004a6e:	e4a6                	sd	s1,72(sp)
    80004a70:	fc4e                	sd	s3,56(sp)
    80004a72:	f852                	sd	s4,48(sp)
    80004a74:	ec5e                	sd	s7,24(sp)
    80004a76:	e862                	sd	s8,16(sp)
    80004a78:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004a7a:	00004517          	auipc	a0,0x4
    80004a7e:	bbe50513          	addi	a0,a0,-1090 # 80008638 <etext+0x638>
    80004a82:	ffffc097          	auipc	ra,0xffffc
    80004a86:	adc080e7          	jalr	-1316(ra) # 8000055e <panic>
    return -1;
    80004a8a:	557d                	li	a0,-1
}
    80004a8c:	8082                	ret
      return -1;
    80004a8e:	557d                	li	a0,-1
    80004a90:	bfc1                	j	80004a60 <filewrite+0x114>
    80004a92:	557d                	li	a0,-1
    80004a94:	b7f1                	j	80004a60 <filewrite+0x114>
    ret = (i == n ? n : -1);
    80004a96:	557d                	li	a0,-1
    80004a98:	7a42                	ld	s4,48(sp)
    80004a9a:	b7d9                	j	80004a60 <filewrite+0x114>

0000000080004a9c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a9c:	7179                	addi	sp,sp,-48
    80004a9e:	f406                	sd	ra,40(sp)
    80004aa0:	f022                	sd	s0,32(sp)
    80004aa2:	ec26                	sd	s1,24(sp)
    80004aa4:	e052                	sd	s4,0(sp)
    80004aa6:	1800                	addi	s0,sp,48
    80004aa8:	84aa                	mv	s1,a0
    80004aaa:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004aac:	0005b023          	sd	zero,0(a1)
    80004ab0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ab4:	00000097          	auipc	ra,0x0
    80004ab8:	bac080e7          	jalr	-1108(ra) # 80004660 <filealloc>
    80004abc:	e088                	sd	a0,0(s1)
    80004abe:	cd49                	beqz	a0,80004b58 <pipealloc+0xbc>
    80004ac0:	00000097          	auipc	ra,0x0
    80004ac4:	ba0080e7          	jalr	-1120(ra) # 80004660 <filealloc>
    80004ac8:	00aa3023          	sd	a0,0(s4)
    80004acc:	c141                	beqz	a0,80004b4c <pipealloc+0xb0>
    80004ace:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ad0:	ffffc097          	auipc	ra,0xffffc
    80004ad4:	088080e7          	jalr	136(ra) # 80000b58 <kalloc>
    80004ad8:	892a                	mv	s2,a0
    80004ada:	c13d                	beqz	a0,80004b40 <pipealloc+0xa4>
    80004adc:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004ade:	4985                	li	s3,1
    80004ae0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004ae4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ae8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004aec:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004af0:	00004597          	auipc	a1,0x4
    80004af4:	b5858593          	addi	a1,a1,-1192 # 80008648 <etext+0x648>
    80004af8:	ffffc097          	auipc	ra,0xffffc
    80004afc:	0ca080e7          	jalr	202(ra) # 80000bc2 <initlock>
  (*f0)->type = FD_PIPE;
    80004b00:	609c                	ld	a5,0(s1)
    80004b02:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b06:	609c                	ld	a5,0(s1)
    80004b08:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b0c:	609c                	ld	a5,0(s1)
    80004b0e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b12:	609c                	ld	a5,0(s1)
    80004b14:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b18:	000a3783          	ld	a5,0(s4)
    80004b1c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b20:	000a3783          	ld	a5,0(s4)
    80004b24:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b28:	000a3783          	ld	a5,0(s4)
    80004b2c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b30:	000a3783          	ld	a5,0(s4)
    80004b34:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b38:	4501                	li	a0,0
    80004b3a:	6942                	ld	s2,16(sp)
    80004b3c:	69a2                	ld	s3,8(sp)
    80004b3e:	a03d                	j	80004b6c <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b40:	6088                	ld	a0,0(s1)
    80004b42:	c119                	beqz	a0,80004b48 <pipealloc+0xac>
    80004b44:	6942                	ld	s2,16(sp)
    80004b46:	a029                	j	80004b50 <pipealloc+0xb4>
    80004b48:	6942                	ld	s2,16(sp)
    80004b4a:	a039                	j	80004b58 <pipealloc+0xbc>
    80004b4c:	6088                	ld	a0,0(s1)
    80004b4e:	c50d                	beqz	a0,80004b78 <pipealloc+0xdc>
    fileclose(*f0);
    80004b50:	00000097          	auipc	ra,0x0
    80004b54:	bcc080e7          	jalr	-1076(ra) # 8000471c <fileclose>
  if(*f1)
    80004b58:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b5c:	557d                	li	a0,-1
  if(*f1)
    80004b5e:	c799                	beqz	a5,80004b6c <pipealloc+0xd0>
    fileclose(*f1);
    80004b60:	853e                	mv	a0,a5
    80004b62:	00000097          	auipc	ra,0x0
    80004b66:	bba080e7          	jalr	-1094(ra) # 8000471c <fileclose>
  return -1;
    80004b6a:	557d                	li	a0,-1
}
    80004b6c:	70a2                	ld	ra,40(sp)
    80004b6e:	7402                	ld	s0,32(sp)
    80004b70:	64e2                	ld	s1,24(sp)
    80004b72:	6a02                	ld	s4,0(sp)
    80004b74:	6145                	addi	sp,sp,48
    80004b76:	8082                	ret
  return -1;
    80004b78:	557d                	li	a0,-1
    80004b7a:	bfcd                	j	80004b6c <pipealloc+0xd0>

0000000080004b7c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b7c:	1101                	addi	sp,sp,-32
    80004b7e:	ec06                	sd	ra,24(sp)
    80004b80:	e822                	sd	s0,16(sp)
    80004b82:	e426                	sd	s1,8(sp)
    80004b84:	e04a                	sd	s2,0(sp)
    80004b86:	1000                	addi	s0,sp,32
    80004b88:	84aa                	mv	s1,a0
    80004b8a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b8c:	ffffc097          	auipc	ra,0xffffc
    80004b90:	0d0080e7          	jalr	208(ra) # 80000c5c <acquire>
  if(writable){
    80004b94:	02090b63          	beqz	s2,80004bca <pipeclose+0x4e>
    pi->writeopen = 0;
    80004b98:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b9c:	21848513          	addi	a0,s1,536
    80004ba0:	ffffd097          	auipc	ra,0xffffd
    80004ba4:	726080e7          	jalr	1830(ra) # 800022c6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ba8:	2204a783          	lw	a5,544(s1)
    80004bac:	e781                	bnez	a5,80004bb4 <pipeclose+0x38>
    80004bae:	2244a783          	lw	a5,548(s1)
    80004bb2:	c78d                	beqz	a5,80004bdc <pipeclose+0x60>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80004bb4:	8526                	mv	a0,s1
    80004bb6:	ffffc097          	auipc	ra,0xffffc
    80004bba:	156080e7          	jalr	342(ra) # 80000d0c <release>
}
    80004bbe:	60e2                	ld	ra,24(sp)
    80004bc0:	6442                	ld	s0,16(sp)
    80004bc2:	64a2                	ld	s1,8(sp)
    80004bc4:	6902                	ld	s2,0(sp)
    80004bc6:	6105                	addi	sp,sp,32
    80004bc8:	8082                	ret
    pi->readopen = 0;
    80004bca:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004bce:	21c48513          	addi	a0,s1,540
    80004bd2:	ffffd097          	auipc	ra,0xffffd
    80004bd6:	6f4080e7          	jalr	1780(ra) # 800022c6 <wakeup>
    80004bda:	b7f9                	j	80004ba8 <pipeclose+0x2c>
    release(&pi->lock);
    80004bdc:	8526                	mv	a0,s1
    80004bde:	ffffc097          	auipc	ra,0xffffc
    80004be2:	12e080e7          	jalr	302(ra) # 80000d0c <release>
    kfree((char*)pi);
    80004be6:	8526                	mv	a0,s1
    80004be8:	ffffc097          	auipc	ra,0xffffc
    80004bec:	e6c080e7          	jalr	-404(ra) # 80000a54 <kfree>
    80004bf0:	b7f9                	j	80004bbe <pipeclose+0x42>

0000000080004bf2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004bf2:	7159                	addi	sp,sp,-112
    80004bf4:	f486                	sd	ra,104(sp)
    80004bf6:	f0a2                	sd	s0,96(sp)
    80004bf8:	eca6                	sd	s1,88(sp)
    80004bfa:	e8ca                	sd	s2,80(sp)
    80004bfc:	e4ce                	sd	s3,72(sp)
    80004bfe:	e0d2                	sd	s4,64(sp)
    80004c00:	fc56                	sd	s5,56(sp)
    80004c02:	1880                	addi	s0,sp,112
    80004c04:	84aa                	mv	s1,a0
    80004c06:	8aae                	mv	s5,a1
    80004c08:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c0a:	ffffd097          	auipc	ra,0xffffd
    80004c0e:	faa080e7          	jalr	-86(ra) # 80001bb4 <myproc>
    80004c12:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c14:	8526                	mv	a0,s1
    80004c16:	ffffc097          	auipc	ra,0xffffc
    80004c1a:	046080e7          	jalr	70(ra) # 80000c5c <acquire>
  while(i < n){
    80004c1e:	0f405063          	blez	s4,80004cfe <pipewrite+0x10c>
    80004c22:	f85a                	sd	s6,48(sp)
    80004c24:	f45e                	sd	s7,40(sp)
    80004c26:	f062                	sd	s8,32(sp)
    80004c28:	ec66                	sd	s9,24(sp)
    80004c2a:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004c2c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c2e:	f9f40c13          	addi	s8,s0,-97
    80004c32:	4b85                	li	s7,1
    80004c34:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c36:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c3a:	21c48c93          	addi	s9,s1,540
    80004c3e:	a099                	j	80004c84 <pipewrite+0x92>
      release(&pi->lock);
    80004c40:	8526                	mv	a0,s1
    80004c42:	ffffc097          	auipc	ra,0xffffc
    80004c46:	0ca080e7          	jalr	202(ra) # 80000d0c <release>
      return -1;
    80004c4a:	597d                	li	s2,-1
    80004c4c:	7b42                	ld	s6,48(sp)
    80004c4e:	7ba2                	ld	s7,40(sp)
    80004c50:	7c02                	ld	s8,32(sp)
    80004c52:	6ce2                	ld	s9,24(sp)
    80004c54:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c56:	854a                	mv	a0,s2
    80004c58:	70a6                	ld	ra,104(sp)
    80004c5a:	7406                	ld	s0,96(sp)
    80004c5c:	64e6                	ld	s1,88(sp)
    80004c5e:	6946                	ld	s2,80(sp)
    80004c60:	69a6                	ld	s3,72(sp)
    80004c62:	6a06                	ld	s4,64(sp)
    80004c64:	7ae2                	ld	s5,56(sp)
    80004c66:	6165                	addi	sp,sp,112
    80004c68:	8082                	ret
      wakeup(&pi->nread);
    80004c6a:	856a                	mv	a0,s10
    80004c6c:	ffffd097          	auipc	ra,0xffffd
    80004c70:	65a080e7          	jalr	1626(ra) # 800022c6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c74:	85a6                	mv	a1,s1
    80004c76:	8566                	mv	a0,s9
    80004c78:	ffffd097          	auipc	ra,0xffffd
    80004c7c:	5ea080e7          	jalr	1514(ra) # 80002262 <sleep>
  while(i < n){
    80004c80:	05495e63          	bge	s2,s4,80004cdc <pipewrite+0xea>
    if(pi->readopen == 0 || killed(pr)){
    80004c84:	2204a783          	lw	a5,544(s1)
    80004c88:	dfc5                	beqz	a5,80004c40 <pipewrite+0x4e>
    80004c8a:	854e                	mv	a0,s3
    80004c8c:	ffffe097          	auipc	ra,0xffffe
    80004c90:	882080e7          	jalr	-1918(ra) # 8000250e <killed>
    80004c94:	f555                	bnez	a0,80004c40 <pipewrite+0x4e>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c96:	2184a783          	lw	a5,536(s1)
    80004c9a:	21c4a703          	lw	a4,540(s1)
    80004c9e:	2007879b          	addiw	a5,a5,512
    80004ca2:	fcf704e3          	beq	a4,a5,80004c6a <pipewrite+0x78>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ca6:	86de                	mv	a3,s7
    80004ca8:	01590633          	add	a2,s2,s5
    80004cac:	85e2                	mv	a1,s8
    80004cae:	0509b503          	ld	a0,80(s3)
    80004cb2:	ffffd097          	auipc	ra,0xffffd
    80004cb6:	bda080e7          	jalr	-1062(ra) # 8000188c <copyin>
    80004cba:	05650463          	beq	a0,s6,80004d02 <pipewrite+0x110>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cbe:	21c4a783          	lw	a5,540(s1)
    80004cc2:	0017871b          	addiw	a4,a5,1
    80004cc6:	20e4ae23          	sw	a4,540(s1)
    80004cca:	1ff7f793          	andi	a5,a5,511
    80004cce:	97a6                	add	a5,a5,s1
    80004cd0:	f9f44703          	lbu	a4,-97(s0)
    80004cd4:	00e78c23          	sb	a4,24(a5)
      i++;
    80004cd8:	2905                	addiw	s2,s2,1
    80004cda:	b75d                	j	80004c80 <pipewrite+0x8e>
    80004cdc:	7b42                	ld	s6,48(sp)
    80004cde:	7ba2                	ld	s7,40(sp)
    80004ce0:	7c02                	ld	s8,32(sp)
    80004ce2:	6ce2                	ld	s9,24(sp)
    80004ce4:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004ce6:	21848513          	addi	a0,s1,536
    80004cea:	ffffd097          	auipc	ra,0xffffd
    80004cee:	5dc080e7          	jalr	1500(ra) # 800022c6 <wakeup>
  release(&pi->lock);
    80004cf2:	8526                	mv	a0,s1
    80004cf4:	ffffc097          	auipc	ra,0xffffc
    80004cf8:	018080e7          	jalr	24(ra) # 80000d0c <release>
  return i;
    80004cfc:	bfa9                	j	80004c56 <pipewrite+0x64>
  int i = 0;
    80004cfe:	4901                	li	s2,0
    80004d00:	b7dd                	j	80004ce6 <pipewrite+0xf4>
    80004d02:	7b42                	ld	s6,48(sp)
    80004d04:	7ba2                	ld	s7,40(sp)
    80004d06:	7c02                	ld	s8,32(sp)
    80004d08:	6ce2                	ld	s9,24(sp)
    80004d0a:	6d42                	ld	s10,16(sp)
    80004d0c:	bfe9                	j	80004ce6 <pipewrite+0xf4>

0000000080004d0e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d0e:	711d                	addi	sp,sp,-96
    80004d10:	ec86                	sd	ra,88(sp)
    80004d12:	e8a2                	sd	s0,80(sp)
    80004d14:	e4a6                	sd	s1,72(sp)
    80004d16:	e0ca                	sd	s2,64(sp)
    80004d18:	fc4e                	sd	s3,56(sp)
    80004d1a:	f852                	sd	s4,48(sp)
    80004d1c:	f456                	sd	s5,40(sp)
    80004d1e:	1080                	addi	s0,sp,96
    80004d20:	84aa                	mv	s1,a0
    80004d22:	892e                	mv	s2,a1
    80004d24:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d26:	ffffd097          	auipc	ra,0xffffd
    80004d2a:	e8e080e7          	jalr	-370(ra) # 80001bb4 <myproc>
    80004d2e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d30:	8526                	mv	a0,s1
    80004d32:	ffffc097          	auipc	ra,0xffffc
    80004d36:	f2a080e7          	jalr	-214(ra) # 80000c5c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d3a:	2184a703          	lw	a4,536(s1)
    80004d3e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d42:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d46:	02f71b63          	bne	a4,a5,80004d7c <piperead+0x6e>
    80004d4a:	2244a783          	lw	a5,548(s1)
    80004d4e:	c3b1                	beqz	a5,80004d92 <piperead+0x84>
    if(killed(pr)){
    80004d50:	8552                	mv	a0,s4
    80004d52:	ffffd097          	auipc	ra,0xffffd
    80004d56:	7bc080e7          	jalr	1980(ra) # 8000250e <killed>
    80004d5a:	e50d                	bnez	a0,80004d84 <piperead+0x76>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d5c:	85a6                	mv	a1,s1
    80004d5e:	854e                	mv	a0,s3
    80004d60:	ffffd097          	auipc	ra,0xffffd
    80004d64:	502080e7          	jalr	1282(ra) # 80002262 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d68:	2184a703          	lw	a4,536(s1)
    80004d6c:	21c4a783          	lw	a5,540(s1)
    80004d70:	fcf70de3          	beq	a4,a5,80004d4a <piperead+0x3c>
    80004d74:	f05a                	sd	s6,32(sp)
    80004d76:	ec5e                	sd	s7,24(sp)
    80004d78:	e862                	sd	s8,16(sp)
    80004d7a:	a839                	j	80004d98 <piperead+0x8a>
    80004d7c:	f05a                	sd	s6,32(sp)
    80004d7e:	ec5e                	sd	s7,24(sp)
    80004d80:	e862                	sd	s8,16(sp)
    80004d82:	a819                	j	80004d98 <piperead+0x8a>
      release(&pi->lock);
    80004d84:	8526                	mv	a0,s1
    80004d86:	ffffc097          	auipc	ra,0xffffc
    80004d8a:	f86080e7          	jalr	-122(ra) # 80000d0c <release>
      return -1;
    80004d8e:	59fd                	li	s3,-1
    80004d90:	a88d                	j	80004e02 <piperead+0xf4>
    80004d92:	f05a                	sd	s6,32(sp)
    80004d94:	ec5e                	sd	s7,24(sp)
    80004d96:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d98:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d9a:	faf40c13          	addi	s8,s0,-81
    80004d9e:	4b85                	li	s7,1
    80004da0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004da2:	05505263          	blez	s5,80004de6 <piperead+0xd8>
    if(pi->nread == pi->nwrite)
    80004da6:	2184a783          	lw	a5,536(s1)
    80004daa:	21c4a703          	lw	a4,540(s1)
    80004dae:	02f70c63          	beq	a4,a5,80004de6 <piperead+0xd8>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004db2:	0017871b          	addiw	a4,a5,1
    80004db6:	20e4ac23          	sw	a4,536(s1)
    80004dba:	1ff7f793          	andi	a5,a5,511
    80004dbe:	97a6                	add	a5,a5,s1
    80004dc0:	0187c783          	lbu	a5,24(a5)
    80004dc4:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dc8:	86de                	mv	a3,s7
    80004dca:	8662                	mv	a2,s8
    80004dcc:	85ca                	mv	a1,s2
    80004dce:	050a3503          	ld	a0,80(s4)
    80004dd2:	ffffd097          	auipc	ra,0xffffd
    80004dd6:	a2e080e7          	jalr	-1490(ra) # 80001800 <copyout>
    80004dda:	01650663          	beq	a0,s6,80004de6 <piperead+0xd8>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dde:	2985                	addiw	s3,s3,1
    80004de0:	0905                	addi	s2,s2,1
    80004de2:	fd3a92e3          	bne	s5,s3,80004da6 <piperead+0x98>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004de6:	21c48513          	addi	a0,s1,540
    80004dea:	ffffd097          	auipc	ra,0xffffd
    80004dee:	4dc080e7          	jalr	1244(ra) # 800022c6 <wakeup>
  release(&pi->lock);
    80004df2:	8526                	mv	a0,s1
    80004df4:	ffffc097          	auipc	ra,0xffffc
    80004df8:	f18080e7          	jalr	-232(ra) # 80000d0c <release>
    80004dfc:	7b02                	ld	s6,32(sp)
    80004dfe:	6be2                	ld	s7,24(sp)
    80004e00:	6c42                	ld	s8,16(sp)
  return i;
}
    80004e02:	854e                	mv	a0,s3
    80004e04:	60e6                	ld	ra,88(sp)
    80004e06:	6446                	ld	s0,80(sp)
    80004e08:	64a6                	ld	s1,72(sp)
    80004e0a:	6906                	ld	s2,64(sp)
    80004e0c:	79e2                	ld	s3,56(sp)
    80004e0e:	7a42                	ld	s4,48(sp)
    80004e10:	7aa2                	ld	s5,40(sp)
    80004e12:	6125                	addi	sp,sp,96
    80004e14:	8082                	ret

0000000080004e16 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e16:	1141                	addi	sp,sp,-16
    80004e18:	e406                	sd	ra,8(sp)
    80004e1a:	e022                	sd	s0,0(sp)
    80004e1c:	0800                	addi	s0,sp,16
    80004e1e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e20:	0035151b          	slliw	a0,a0,0x3
    80004e24:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004e26:	8b89                	andi	a5,a5,2
    80004e28:	c399                	beqz	a5,80004e2e <flags2perm+0x18>
      perm |= PTE_W;
    80004e2a:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e2e:	60a2                	ld	ra,8(sp)
    80004e30:	6402                	ld	s0,0(sp)
    80004e32:	0141                	addi	sp,sp,16
    80004e34:	8082                	ret

0000000080004e36 <exec>:

int
exec(char *path, char **argv)
{
    80004e36:	de010113          	addi	sp,sp,-544
    80004e3a:	20113c23          	sd	ra,536(sp)
    80004e3e:	20813823          	sd	s0,528(sp)
    80004e42:	20913423          	sd	s1,520(sp)
    80004e46:	21213023          	sd	s2,512(sp)
    80004e4a:	1400                	addi	s0,sp,544
    80004e4c:	892a                	mv	s2,a0
    80004e4e:	dea43823          	sd	a0,-528(s0)
    80004e52:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e56:	ffffd097          	auipc	ra,0xffffd
    80004e5a:	d5e080e7          	jalr	-674(ra) # 80001bb4 <myproc>
    80004e5e:	84aa                	mv	s1,a0

  begin_op();
    80004e60:	fffff097          	auipc	ra,0xfffff
    80004e64:	3da080e7          	jalr	986(ra) # 8000423a <begin_op>

  if((ip = namei(path)) == 0){
    80004e68:	854a                	mv	a0,s2
    80004e6a:	fffff097          	auipc	ra,0xfffff
    80004e6e:	1ca080e7          	jalr	458(ra) # 80004034 <namei>
    80004e72:	c525                	beqz	a0,80004eda <exec+0xa4>
    80004e74:	fbd2                	sd	s4,496(sp)
    80004e76:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e78:	fffff097          	auipc	ra,0xfffff
    80004e7c:	9d2080e7          	jalr	-1582(ra) # 8000384a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e80:	04000713          	li	a4,64
    80004e84:	4681                	li	a3,0
    80004e86:	e5040613          	addi	a2,s0,-432
    80004e8a:	4581                	li	a1,0
    80004e8c:	8552                	mv	a0,s4
    80004e8e:	fffff097          	auipc	ra,0xfffff
    80004e92:	c7a080e7          	jalr	-902(ra) # 80003b08 <readi>
    80004e96:	04000793          	li	a5,64
    80004e9a:	00f51a63          	bne	a0,a5,80004eae <exec+0x78>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004e9e:	e5042703          	lw	a4,-432(s0)
    80004ea2:	464c47b7          	lui	a5,0x464c4
    80004ea6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004eaa:	02f70e63          	beq	a4,a5,80004ee6 <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004eae:	8552                	mv	a0,s4
    80004eb0:	fffff097          	auipc	ra,0xfffff
    80004eb4:	c02080e7          	jalr	-1022(ra) # 80003ab2 <iunlockput>
    end_op();
    80004eb8:	fffff097          	auipc	ra,0xfffff
    80004ebc:	402080e7          	jalr	1026(ra) # 800042ba <end_op>
  }
  return -1;
    80004ec0:	557d                	li	a0,-1
    80004ec2:	7a5e                	ld	s4,496(sp)
}
    80004ec4:	21813083          	ld	ra,536(sp)
    80004ec8:	21013403          	ld	s0,528(sp)
    80004ecc:	20813483          	ld	s1,520(sp)
    80004ed0:	20013903          	ld	s2,512(sp)
    80004ed4:	22010113          	addi	sp,sp,544
    80004ed8:	8082                	ret
    end_op();
    80004eda:	fffff097          	auipc	ra,0xfffff
    80004ede:	3e0080e7          	jalr	992(ra) # 800042ba <end_op>
    return -1;
    80004ee2:	557d                	li	a0,-1
    80004ee4:	b7c5                	j	80004ec4 <exec+0x8e>
    80004ee6:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004ee8:	8526                	mv	a0,s1
    80004eea:	ffffd097          	auipc	ra,0xffffd
    80004eee:	d90080e7          	jalr	-624(ra) # 80001c7a <proc_pagetable>
    80004ef2:	8b2a                	mv	s6,a0
    80004ef4:	2c050f63          	beqz	a0,800051d2 <exec+0x39c>
    80004ef8:	ffce                	sd	s3,504(sp)
    80004efa:	f7d6                	sd	s5,488(sp)
    80004efc:	efde                	sd	s7,472(sp)
    80004efe:	ebe2                	sd	s8,464(sp)
    80004f00:	e7e6                	sd	s9,456(sp)
    80004f02:	e3ea                	sd	s10,448(sp)
    80004f04:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f06:	e8845783          	lhu	a5,-376(s0)
    80004f0a:	10078563          	beqz	a5,80005014 <exec+0x1de>
    80004f0e:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f12:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f14:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f16:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004f1a:	6c85                	lui	s9,0x1
    80004f1c:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004f20:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004f24:	6a85                	lui	s5,0x1
    80004f26:	a0b5                	j	80004f92 <exec+0x15c>
      panic("loadseg: address should exist");
    80004f28:	00003517          	auipc	a0,0x3
    80004f2c:	72850513          	addi	a0,a0,1832 # 80008650 <etext+0x650>
    80004f30:	ffffb097          	auipc	ra,0xffffb
    80004f34:	62e080e7          	jalr	1582(ra) # 8000055e <panic>
    if(sz - i < PGSIZE)
    80004f38:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f3a:	874a                	mv	a4,s2
    80004f3c:	009b86bb          	addw	a3,s7,s1
    80004f40:	4581                	li	a1,0
    80004f42:	8552                	mv	a0,s4
    80004f44:	fffff097          	auipc	ra,0xfffff
    80004f48:	bc4080e7          	jalr	-1084(ra) # 80003b08 <readi>
    80004f4c:	28a91763          	bne	s2,a0,800051da <exec+0x3a4>
  for(i = 0; i < sz; i += PGSIZE){
    80004f50:	009a84bb          	addw	s1,s5,s1
    80004f54:	0334f463          	bgeu	s1,s3,80004f7c <exec+0x146>
    pa = walkaddr(pagetable, va + i);
    80004f58:	02049593          	slli	a1,s1,0x20
    80004f5c:	9181                	srli	a1,a1,0x20
    80004f5e:	95e2                	add	a1,a1,s8
    80004f60:	855a                	mv	a0,s6
    80004f62:	ffffc097          	auipc	ra,0xffffc
    80004f66:	268080e7          	jalr	616(ra) # 800011ca <walkaddr>
    80004f6a:	862a                	mv	a2,a0
    if(pa == 0)
    80004f6c:	dd55                	beqz	a0,80004f28 <exec+0xf2>
    if(sz - i < PGSIZE)
    80004f6e:	409987bb          	subw	a5,s3,s1
    80004f72:	893e                	mv	s2,a5
    80004f74:	fcfcf2e3          	bgeu	s9,a5,80004f38 <exec+0x102>
    80004f78:	8956                	mv	s2,s5
    80004f7a:	bf7d                	j	80004f38 <exec+0x102>
    sz = sz1;
    80004f7c:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f80:	2d05                	addiw	s10,s10,1
    80004f82:	e0843783          	ld	a5,-504(s0)
    80004f86:	0387869b          	addiw	a3,a5,56
    80004f8a:	e8845783          	lhu	a5,-376(s0)
    80004f8e:	08fd5463          	bge	s10,a5,80005016 <exec+0x1e0>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f92:	e0d43423          	sd	a3,-504(s0)
    80004f96:	876e                	mv	a4,s11
    80004f98:	e1840613          	addi	a2,s0,-488
    80004f9c:	4581                	li	a1,0
    80004f9e:	8552                	mv	a0,s4
    80004fa0:	fffff097          	auipc	ra,0xfffff
    80004fa4:	b68080e7          	jalr	-1176(ra) # 80003b08 <readi>
    80004fa8:	23b51763          	bne	a0,s11,800051d6 <exec+0x3a0>
    if(ph.type != ELF_PROG_LOAD)
    80004fac:	e1842783          	lw	a5,-488(s0)
    80004fb0:	4705                	li	a4,1
    80004fb2:	fce797e3          	bne	a5,a4,80004f80 <exec+0x14a>
    if(ph.memsz < ph.filesz)
    80004fb6:	e4043483          	ld	s1,-448(s0)
    80004fba:	e3843783          	ld	a5,-456(s0)
    80004fbe:	22f4ee63          	bltu	s1,a5,800051fa <exec+0x3c4>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004fc2:	e2843783          	ld	a5,-472(s0)
    80004fc6:	94be                	add	s1,s1,a5
    80004fc8:	22f4ec63          	bltu	s1,a5,80005200 <exec+0x3ca>
    if(ph.vaddr % PGSIZE != 0)
    80004fcc:	de843703          	ld	a4,-536(s0)
    80004fd0:	8ff9                	and	a5,a5,a4
    80004fd2:	22079a63          	bnez	a5,80005206 <exec+0x3d0>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004fd6:	e1c42503          	lw	a0,-484(s0)
    80004fda:	00000097          	auipc	ra,0x0
    80004fde:	e3c080e7          	jalr	-452(ra) # 80004e16 <flags2perm>
    80004fe2:	86aa                	mv	a3,a0
    80004fe4:	8626                	mv	a2,s1
    80004fe6:	85ca                	mv	a1,s2
    80004fe8:	855a                	mv	a0,s6
    80004fea:	ffffc097          	auipc	ra,0xffffc
    80004fee:	5b2080e7          	jalr	1458(ra) # 8000159c <uvmalloc>
    80004ff2:	dea43c23          	sd	a0,-520(s0)
    80004ff6:	20050b63          	beqz	a0,8000520c <exec+0x3d6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ffa:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004ffe:	00098863          	beqz	s3,8000500e <exec+0x1d8>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005002:	e2843c03          	ld	s8,-472(s0)
    80005006:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000500a:	4481                	li	s1,0
    8000500c:	b7b1                	j	80004f58 <exec+0x122>
    sz = sz1;
    8000500e:	df843903          	ld	s2,-520(s0)
    80005012:	b7bd                	j	80004f80 <exec+0x14a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005014:	4901                	li	s2,0
  iunlockput(ip);
    80005016:	8552                	mv	a0,s4
    80005018:	fffff097          	auipc	ra,0xfffff
    8000501c:	a9a080e7          	jalr	-1382(ra) # 80003ab2 <iunlockput>
  end_op();
    80005020:	fffff097          	auipc	ra,0xfffff
    80005024:	29a080e7          	jalr	666(ra) # 800042ba <end_op>
  p = myproc();
    80005028:	ffffd097          	auipc	ra,0xffffd
    8000502c:	b8c080e7          	jalr	-1140(ra) # 80001bb4 <myproc>
    80005030:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005032:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005036:	6985                	lui	s3,0x1
    80005038:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000503a:	99ca                	add	s3,s3,s2
    8000503c:	77fd                	lui	a5,0xfffff
    8000503e:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005042:	4691                	li	a3,4
    80005044:	6609                	lui	a2,0x2
    80005046:	964e                	add	a2,a2,s3
    80005048:	85ce                	mv	a1,s3
    8000504a:	855a                	mv	a0,s6
    8000504c:	ffffc097          	auipc	ra,0xffffc
    80005050:	550080e7          	jalr	1360(ra) # 8000159c <uvmalloc>
    80005054:	8a2a                	mv	s4,a0
    80005056:	e115                	bnez	a0,8000507a <exec+0x244>
    proc_freepagetable(pagetable, sz);
    80005058:	85ce                	mv	a1,s3
    8000505a:	855a                	mv	a0,s6
    8000505c:	ffffd097          	auipc	ra,0xffffd
    80005060:	cba080e7          	jalr	-838(ra) # 80001d16 <proc_freepagetable>
  return -1;
    80005064:	557d                	li	a0,-1
    80005066:	79fe                	ld	s3,504(sp)
    80005068:	7a5e                	ld	s4,496(sp)
    8000506a:	7abe                	ld	s5,488(sp)
    8000506c:	7b1e                	ld	s6,480(sp)
    8000506e:	6bfe                	ld	s7,472(sp)
    80005070:	6c5e                	ld	s8,464(sp)
    80005072:	6cbe                	ld	s9,456(sp)
    80005074:	6d1e                	ld	s10,448(sp)
    80005076:	7dfa                	ld	s11,440(sp)
    80005078:	b5b1                	j	80004ec4 <exec+0x8e>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000507a:	75f9                	lui	a1,0xffffe
    8000507c:	95aa                	add	a1,a1,a0
    8000507e:	855a                	mv	a0,s6
    80005080:	ffffc097          	auipc	ra,0xffffc
    80005084:	74e080e7          	jalr	1870(ra) # 800017ce <uvmclear>
  stackbase = sp - PGSIZE;
    80005088:	800a0b93          	addi	s7,s4,-2048
    8000508c:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80005090:	e0043783          	ld	a5,-512(s0)
    80005094:	6388                	ld	a0,0(a5)
  sp = sz;
    80005096:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80005098:	4481                	li	s1,0
    ustack[argc] = sp;
    8000509a:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    8000509e:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    800050a2:	c135                	beqz	a0,80005106 <exec+0x2d0>
    sp -= strlen(argv[argc]) + 1;
    800050a4:	ffffc097          	auipc	ra,0xffffc
    800050a8:	e3e080e7          	jalr	-450(ra) # 80000ee2 <strlen>
    800050ac:	0015079b          	addiw	a5,a0,1
    800050b0:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050b4:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800050b8:	15796d63          	bltu	s2,s7,80005212 <exec+0x3dc>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050bc:	e0043d83          	ld	s11,-512(s0)
    800050c0:	000db983          	ld	s3,0(s11)
    800050c4:	854e                	mv	a0,s3
    800050c6:	ffffc097          	auipc	ra,0xffffc
    800050ca:	e1c080e7          	jalr	-484(ra) # 80000ee2 <strlen>
    800050ce:	0015069b          	addiw	a3,a0,1
    800050d2:	864e                	mv	a2,s3
    800050d4:	85ca                	mv	a1,s2
    800050d6:	855a                	mv	a0,s6
    800050d8:	ffffc097          	auipc	ra,0xffffc
    800050dc:	728080e7          	jalr	1832(ra) # 80001800 <copyout>
    800050e0:	12054b63          	bltz	a0,80005216 <exec+0x3e0>
    ustack[argc] = sp;
    800050e4:	00349793          	slli	a5,s1,0x3
    800050e8:	97e6                	add	a5,a5,s9
    800050ea:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffdd220>
  for(argc = 0; argv[argc]; argc++) {
    800050ee:	0485                	addi	s1,s1,1
    800050f0:	008d8793          	addi	a5,s11,8
    800050f4:	e0f43023          	sd	a5,-512(s0)
    800050f8:	008db503          	ld	a0,8(s11)
    800050fc:	c509                	beqz	a0,80005106 <exec+0x2d0>
    if(argc >= MAXARG)
    800050fe:	fb8493e3          	bne	s1,s8,800050a4 <exec+0x26e>
  sz = sz1;
    80005102:	89d2                	mv	s3,s4
    80005104:	bf91                	j	80005058 <exec+0x222>
  ustack[argc] = 0;
    80005106:	00349793          	slli	a5,s1,0x3
    8000510a:	f9078793          	addi	a5,a5,-112
    8000510e:	97a2                	add	a5,a5,s0
    80005110:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005114:	00349693          	slli	a3,s1,0x3
    80005118:	06a1                	addi	a3,a3,8
    8000511a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000511e:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005122:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80005124:	f3796ae3          	bltu	s2,s7,80005058 <exec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005128:	e9040613          	addi	a2,s0,-368
    8000512c:	85ca                	mv	a1,s2
    8000512e:	855a                	mv	a0,s6
    80005130:	ffffc097          	auipc	ra,0xffffc
    80005134:	6d0080e7          	jalr	1744(ra) # 80001800 <copyout>
    80005138:	f20540e3          	bltz	a0,80005058 <exec+0x222>
  p->trapframe->a1 = sp;
    8000513c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005140:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005144:	df043783          	ld	a5,-528(s0)
    80005148:	0007c703          	lbu	a4,0(a5)
    8000514c:	cf11                	beqz	a4,80005168 <exec+0x332>
    8000514e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005150:	02f00693          	li	a3,47
    80005154:	a029                	j	8000515e <exec+0x328>
  for(last=s=path; *s; s++)
    80005156:	0785                	addi	a5,a5,1
    80005158:	fff7c703          	lbu	a4,-1(a5)
    8000515c:	c711                	beqz	a4,80005168 <exec+0x332>
    if(*s == '/')
    8000515e:	fed71ce3          	bne	a4,a3,80005156 <exec+0x320>
      last = s+1;
    80005162:	def43823          	sd	a5,-528(s0)
    80005166:	bfc5                	j	80005156 <exec+0x320>
  safestrcpy(p->name, last, sizeof(p->name));
    80005168:	4641                	li	a2,16
    8000516a:	df043583          	ld	a1,-528(s0)
    8000516e:	158a8513          	addi	a0,s5,344
    80005172:	ffffc097          	auipc	ra,0xffffc
    80005176:	d3a080e7          	jalr	-710(ra) # 80000eac <safestrcpy>
  oldpagetable = p->pagetable;
    8000517a:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000517e:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005182:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005186:	058ab783          	ld	a5,88(s5)
    8000518a:	e6843703          	ld	a4,-408(s0)
    8000518e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005190:	058ab783          	ld	a5,88(s5)
    80005194:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005198:	85ea                	mv	a1,s10
    8000519a:	ffffd097          	auipc	ra,0xffffd
    8000519e:	b7c080e7          	jalr	-1156(ra) # 80001d16 <proc_freepagetable>
  if(p->pid==1) vmprint(p->pagetable);
    800051a2:	030aa703          	lw	a4,48(s5)
    800051a6:	4785                	li	a5,1
    800051a8:	00f70e63          	beq	a4,a5,800051c4 <exec+0x38e>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051ac:	0004851b          	sext.w	a0,s1
    800051b0:	79fe                	ld	s3,504(sp)
    800051b2:	7a5e                	ld	s4,496(sp)
    800051b4:	7abe                	ld	s5,488(sp)
    800051b6:	7b1e                	ld	s6,480(sp)
    800051b8:	6bfe                	ld	s7,472(sp)
    800051ba:	6c5e                	ld	s8,464(sp)
    800051bc:	6cbe                	ld	s9,456(sp)
    800051be:	6d1e                	ld	s10,448(sp)
    800051c0:	7dfa                	ld	s11,440(sp)
    800051c2:	b309                	j	80004ec4 <exec+0x8e>
  if(p->pid==1) vmprint(p->pagetable);
    800051c4:	050ab503          	ld	a0,80(s5)
    800051c8:	ffffd097          	auipc	ra,0xffffd
    800051cc:	812080e7          	jalr	-2030(ra) # 800019da <vmprint>
    800051d0:	bff1                	j	800051ac <exec+0x376>
    800051d2:	7b1e                	ld	s6,480(sp)
    800051d4:	b9e9                	j	80004eae <exec+0x78>
    800051d6:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800051da:	df843583          	ld	a1,-520(s0)
    800051de:	855a                	mv	a0,s6
    800051e0:	ffffd097          	auipc	ra,0xffffd
    800051e4:	b36080e7          	jalr	-1226(ra) # 80001d16 <proc_freepagetable>
  if(ip){
    800051e8:	79fe                	ld	s3,504(sp)
    800051ea:	7abe                	ld	s5,488(sp)
    800051ec:	7b1e                	ld	s6,480(sp)
    800051ee:	6bfe                	ld	s7,472(sp)
    800051f0:	6c5e                	ld	s8,464(sp)
    800051f2:	6cbe                	ld	s9,456(sp)
    800051f4:	6d1e                	ld	s10,448(sp)
    800051f6:	7dfa                	ld	s11,440(sp)
    800051f8:	b95d                	j	80004eae <exec+0x78>
    800051fa:	df243c23          	sd	s2,-520(s0)
    800051fe:	bff1                	j	800051da <exec+0x3a4>
    80005200:	df243c23          	sd	s2,-520(s0)
    80005204:	bfd9                	j	800051da <exec+0x3a4>
    80005206:	df243c23          	sd	s2,-520(s0)
    8000520a:	bfc1                	j	800051da <exec+0x3a4>
    8000520c:	df243c23          	sd	s2,-520(s0)
    80005210:	b7e9                	j	800051da <exec+0x3a4>
  sz = sz1;
    80005212:	89d2                	mv	s3,s4
    80005214:	b591                	j	80005058 <exec+0x222>
    80005216:	89d2                	mv	s3,s4
    80005218:	b581                	j	80005058 <exec+0x222>

000000008000521a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000521a:	7179                	addi	sp,sp,-48
    8000521c:	f406                	sd	ra,40(sp)
    8000521e:	f022                	sd	s0,32(sp)
    80005220:	ec26                	sd	s1,24(sp)
    80005222:	e84a                	sd	s2,16(sp)
    80005224:	1800                	addi	s0,sp,48
    80005226:	892e                	mv	s2,a1
    80005228:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000522a:	fdc40593          	addi	a1,s0,-36
    8000522e:	ffffe097          	auipc	ra,0xffffe
    80005232:	ab2080e7          	jalr	-1358(ra) # 80002ce0 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005236:	fdc42703          	lw	a4,-36(s0)
    8000523a:	47bd                	li	a5,15
    8000523c:	02e7ec63          	bltu	a5,a4,80005274 <argfd+0x5a>
    80005240:	ffffd097          	auipc	ra,0xffffd
    80005244:	974080e7          	jalr	-1676(ra) # 80001bb4 <myproc>
    80005248:	fdc42703          	lw	a4,-36(s0)
    8000524c:	00371793          	slli	a5,a4,0x3
    80005250:	0d078793          	addi	a5,a5,208
    80005254:	953e                	add	a0,a0,a5
    80005256:	611c                	ld	a5,0(a0)
    80005258:	c385                	beqz	a5,80005278 <argfd+0x5e>
    return -1;
  if(pfd)
    8000525a:	00090463          	beqz	s2,80005262 <argfd+0x48>
    *pfd = fd;
    8000525e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005262:	4501                	li	a0,0
  if(pf)
    80005264:	c091                	beqz	s1,80005268 <argfd+0x4e>
    *pf = f;
    80005266:	e09c                	sd	a5,0(s1)
}
    80005268:	70a2                	ld	ra,40(sp)
    8000526a:	7402                	ld	s0,32(sp)
    8000526c:	64e2                	ld	s1,24(sp)
    8000526e:	6942                	ld	s2,16(sp)
    80005270:	6145                	addi	sp,sp,48
    80005272:	8082                	ret
    return -1;
    80005274:	557d                	li	a0,-1
    80005276:	bfcd                	j	80005268 <argfd+0x4e>
    80005278:	557d                	li	a0,-1
    8000527a:	b7fd                	j	80005268 <argfd+0x4e>

000000008000527c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000527c:	1101                	addi	sp,sp,-32
    8000527e:	ec06                	sd	ra,24(sp)
    80005280:	e822                	sd	s0,16(sp)
    80005282:	e426                	sd	s1,8(sp)
    80005284:	1000                	addi	s0,sp,32
    80005286:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005288:	ffffd097          	auipc	ra,0xffffd
    8000528c:	92c080e7          	jalr	-1748(ra) # 80001bb4 <myproc>
    80005290:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005292:	0d050793          	addi	a5,a0,208
    80005296:	4501                	li	a0,0
    80005298:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000529a:	6398                	ld	a4,0(a5)
    8000529c:	cb19                	beqz	a4,800052b2 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000529e:	2505                	addiw	a0,a0,1
    800052a0:	07a1                	addi	a5,a5,8
    800052a2:	fed51ce3          	bne	a0,a3,8000529a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052a6:	557d                	li	a0,-1
}
    800052a8:	60e2                	ld	ra,24(sp)
    800052aa:	6442                	ld	s0,16(sp)
    800052ac:	64a2                	ld	s1,8(sp)
    800052ae:	6105                	addi	sp,sp,32
    800052b0:	8082                	ret
      p->ofile[fd] = f;
    800052b2:	00351793          	slli	a5,a0,0x3
    800052b6:	0d078793          	addi	a5,a5,208
    800052ba:	963e                	add	a2,a2,a5
    800052bc:	e204                	sd	s1,0(a2)
      return fd;
    800052be:	b7ed                	j	800052a8 <fdalloc+0x2c>

00000000800052c0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052c0:	715d                	addi	sp,sp,-80
    800052c2:	e486                	sd	ra,72(sp)
    800052c4:	e0a2                	sd	s0,64(sp)
    800052c6:	fc26                	sd	s1,56(sp)
    800052c8:	f84a                	sd	s2,48(sp)
    800052ca:	f44e                	sd	s3,40(sp)
    800052cc:	f052                	sd	s4,32(sp)
    800052ce:	ec56                	sd	s5,24(sp)
    800052d0:	e85a                	sd	s6,16(sp)
    800052d2:	0880                	addi	s0,sp,80
    800052d4:	892e                	mv	s2,a1
    800052d6:	8a2e                	mv	s4,a1
    800052d8:	8ab2                	mv	s5,a2
    800052da:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052dc:	fb040593          	addi	a1,s0,-80
    800052e0:	fffff097          	auipc	ra,0xfffff
    800052e4:	d72080e7          	jalr	-654(ra) # 80004052 <nameiparent>
    800052e8:	84aa                	mv	s1,a0
    800052ea:	14050b63          	beqz	a0,80005440 <create+0x180>
    return 0;

  ilock(dp);
    800052ee:	ffffe097          	auipc	ra,0xffffe
    800052f2:	55c080e7          	jalr	1372(ra) # 8000384a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052f6:	4601                	li	a2,0
    800052f8:	fb040593          	addi	a1,s0,-80
    800052fc:	8526                	mv	a0,s1
    800052fe:	fffff097          	auipc	ra,0xfffff
    80005302:	a46080e7          	jalr	-1466(ra) # 80003d44 <dirlookup>
    80005306:	89aa                	mv	s3,a0
    80005308:	c921                	beqz	a0,80005358 <create+0x98>
    iunlockput(dp);
    8000530a:	8526                	mv	a0,s1
    8000530c:	ffffe097          	auipc	ra,0xffffe
    80005310:	7a6080e7          	jalr	1958(ra) # 80003ab2 <iunlockput>
    ilock(ip);
    80005314:	854e                	mv	a0,s3
    80005316:	ffffe097          	auipc	ra,0xffffe
    8000531a:	534080e7          	jalr	1332(ra) # 8000384a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000531e:	4789                	li	a5,2
    80005320:	02f91563          	bne	s2,a5,8000534a <create+0x8a>
    80005324:	0449d783          	lhu	a5,68(s3)
    80005328:	37f9                	addiw	a5,a5,-2
    8000532a:	17c2                	slli	a5,a5,0x30
    8000532c:	93c1                	srli	a5,a5,0x30
    8000532e:	4705                	li	a4,1
    80005330:	00f76d63          	bltu	a4,a5,8000534a <create+0x8a>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005334:	854e                	mv	a0,s3
    80005336:	60a6                	ld	ra,72(sp)
    80005338:	6406                	ld	s0,64(sp)
    8000533a:	74e2                	ld	s1,56(sp)
    8000533c:	7942                	ld	s2,48(sp)
    8000533e:	79a2                	ld	s3,40(sp)
    80005340:	7a02                	ld	s4,32(sp)
    80005342:	6ae2                	ld	s5,24(sp)
    80005344:	6b42                	ld	s6,16(sp)
    80005346:	6161                	addi	sp,sp,80
    80005348:	8082                	ret
    iunlockput(ip);
    8000534a:	854e                	mv	a0,s3
    8000534c:	ffffe097          	auipc	ra,0xffffe
    80005350:	766080e7          	jalr	1894(ra) # 80003ab2 <iunlockput>
    return 0;
    80005354:	4981                	li	s3,0
    80005356:	bff9                	j	80005334 <create+0x74>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005358:	85ca                	mv	a1,s2
    8000535a:	4088                	lw	a0,0(s1)
    8000535c:	ffffe097          	auipc	ra,0xffffe
    80005360:	34a080e7          	jalr	842(ra) # 800036a6 <ialloc>
    80005364:	892a                	mv	s2,a0
    80005366:	c531                	beqz	a0,800053b2 <create+0xf2>
  ilock(ip);
    80005368:	ffffe097          	auipc	ra,0xffffe
    8000536c:	4e2080e7          	jalr	1250(ra) # 8000384a <ilock>
  ip->major = major;
    80005370:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80005374:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80005378:	4785                	li	a5,1
    8000537a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000537e:	854a                	mv	a0,s2
    80005380:	ffffe097          	auipc	ra,0xffffe
    80005384:	3fe080e7          	jalr	1022(ra) # 8000377e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005388:	4705                	li	a4,1
    8000538a:	02ea0a63          	beq	s4,a4,800053be <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000538e:	00492603          	lw	a2,4(s2)
    80005392:	fb040593          	addi	a1,s0,-80
    80005396:	8526                	mv	a0,s1
    80005398:	fffff097          	auipc	ra,0xfffff
    8000539c:	bda080e7          	jalr	-1062(ra) # 80003f72 <dirlink>
    800053a0:	06054e63          	bltz	a0,8000541c <create+0x15c>
  iunlockput(dp);
    800053a4:	8526                	mv	a0,s1
    800053a6:	ffffe097          	auipc	ra,0xffffe
    800053aa:	70c080e7          	jalr	1804(ra) # 80003ab2 <iunlockput>
  return ip;
    800053ae:	89ca                	mv	s3,s2
    800053b0:	b751                	j	80005334 <create+0x74>
    iunlockput(dp);
    800053b2:	8526                	mv	a0,s1
    800053b4:	ffffe097          	auipc	ra,0xffffe
    800053b8:	6fe080e7          	jalr	1790(ra) # 80003ab2 <iunlockput>
    return 0;
    800053bc:	bfa5                	j	80005334 <create+0x74>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053be:	00492603          	lw	a2,4(s2)
    800053c2:	00003597          	auipc	a1,0x3
    800053c6:	2ae58593          	addi	a1,a1,686 # 80008670 <etext+0x670>
    800053ca:	854a                	mv	a0,s2
    800053cc:	fffff097          	auipc	ra,0xfffff
    800053d0:	ba6080e7          	jalr	-1114(ra) # 80003f72 <dirlink>
    800053d4:	04054463          	bltz	a0,8000541c <create+0x15c>
    800053d8:	40d0                	lw	a2,4(s1)
    800053da:	00003597          	auipc	a1,0x3
    800053de:	29e58593          	addi	a1,a1,670 # 80008678 <etext+0x678>
    800053e2:	854a                	mv	a0,s2
    800053e4:	fffff097          	auipc	ra,0xfffff
    800053e8:	b8e080e7          	jalr	-1138(ra) # 80003f72 <dirlink>
    800053ec:	02054863          	bltz	a0,8000541c <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    800053f0:	00492603          	lw	a2,4(s2)
    800053f4:	fb040593          	addi	a1,s0,-80
    800053f8:	8526                	mv	a0,s1
    800053fa:	fffff097          	auipc	ra,0xfffff
    800053fe:	b78080e7          	jalr	-1160(ra) # 80003f72 <dirlink>
    80005402:	00054d63          	bltz	a0,8000541c <create+0x15c>
    dp->nlink++;  // for ".."
    80005406:	04a4d783          	lhu	a5,74(s1)
    8000540a:	2785                	addiw	a5,a5,1
    8000540c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005410:	8526                	mv	a0,s1
    80005412:	ffffe097          	auipc	ra,0xffffe
    80005416:	36c080e7          	jalr	876(ra) # 8000377e <iupdate>
    8000541a:	b769                	j	800053a4 <create+0xe4>
  ip->nlink = 0;
    8000541c:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80005420:	854a                	mv	a0,s2
    80005422:	ffffe097          	auipc	ra,0xffffe
    80005426:	35c080e7          	jalr	860(ra) # 8000377e <iupdate>
  iunlockput(ip);
    8000542a:	854a                	mv	a0,s2
    8000542c:	ffffe097          	auipc	ra,0xffffe
    80005430:	686080e7          	jalr	1670(ra) # 80003ab2 <iunlockput>
  iunlockput(dp);
    80005434:	8526                	mv	a0,s1
    80005436:	ffffe097          	auipc	ra,0xffffe
    8000543a:	67c080e7          	jalr	1660(ra) # 80003ab2 <iunlockput>
  return 0;
    8000543e:	bddd                	j	80005334 <create+0x74>
    return 0;
    80005440:	89aa                	mv	s3,a0
    80005442:	bdcd                	j	80005334 <create+0x74>

0000000080005444 <sys_dup>:
{
    80005444:	7179                	addi	sp,sp,-48
    80005446:	f406                	sd	ra,40(sp)
    80005448:	f022                	sd	s0,32(sp)
    8000544a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000544c:	fd840613          	addi	a2,s0,-40
    80005450:	4581                	li	a1,0
    80005452:	4501                	li	a0,0
    80005454:	00000097          	auipc	ra,0x0
    80005458:	dc6080e7          	jalr	-570(ra) # 8000521a <argfd>
    return -1;
    8000545c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000545e:	02054763          	bltz	a0,8000548c <sys_dup+0x48>
    80005462:	ec26                	sd	s1,24(sp)
    80005464:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005466:	fd843483          	ld	s1,-40(s0)
    8000546a:	8526                	mv	a0,s1
    8000546c:	00000097          	auipc	ra,0x0
    80005470:	e10080e7          	jalr	-496(ra) # 8000527c <fdalloc>
    80005474:	892a                	mv	s2,a0
    return -1;
    80005476:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005478:	00054f63          	bltz	a0,80005496 <sys_dup+0x52>
  filedup(f);
    8000547c:	8526                	mv	a0,s1
    8000547e:	fffff097          	auipc	ra,0xfffff
    80005482:	24c080e7          	jalr	588(ra) # 800046ca <filedup>
  return fd;
    80005486:	87ca                	mv	a5,s2
    80005488:	64e2                	ld	s1,24(sp)
    8000548a:	6942                	ld	s2,16(sp)
}
    8000548c:	853e                	mv	a0,a5
    8000548e:	70a2                	ld	ra,40(sp)
    80005490:	7402                	ld	s0,32(sp)
    80005492:	6145                	addi	sp,sp,48
    80005494:	8082                	ret
    80005496:	64e2                	ld	s1,24(sp)
    80005498:	6942                	ld	s2,16(sp)
    8000549a:	bfcd                	j	8000548c <sys_dup+0x48>

000000008000549c <sys_read>:
{
    8000549c:	7179                	addi	sp,sp,-48
    8000549e:	f406                	sd	ra,40(sp)
    800054a0:	f022                	sd	s0,32(sp)
    800054a2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054a4:	fd840593          	addi	a1,s0,-40
    800054a8:	4505                	li	a0,1
    800054aa:	ffffe097          	auipc	ra,0xffffe
    800054ae:	856080e7          	jalr	-1962(ra) # 80002d00 <argaddr>
  argint(2, &n);
    800054b2:	fe440593          	addi	a1,s0,-28
    800054b6:	4509                	li	a0,2
    800054b8:	ffffe097          	auipc	ra,0xffffe
    800054bc:	828080e7          	jalr	-2008(ra) # 80002ce0 <argint>
  if(argfd(0, 0, &f) < 0)
    800054c0:	fe840613          	addi	a2,s0,-24
    800054c4:	4581                	li	a1,0
    800054c6:	4501                	li	a0,0
    800054c8:	00000097          	auipc	ra,0x0
    800054cc:	d52080e7          	jalr	-686(ra) # 8000521a <argfd>
    800054d0:	87aa                	mv	a5,a0
    return -1;
    800054d2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054d4:	0007cc63          	bltz	a5,800054ec <sys_read+0x50>
  return fileread(f, p, n);
    800054d8:	fe442603          	lw	a2,-28(s0)
    800054dc:	fd843583          	ld	a1,-40(s0)
    800054e0:	fe843503          	ld	a0,-24(s0)
    800054e4:	fffff097          	auipc	ra,0xfffff
    800054e8:	390080e7          	jalr	912(ra) # 80004874 <fileread>
}
    800054ec:	70a2                	ld	ra,40(sp)
    800054ee:	7402                	ld	s0,32(sp)
    800054f0:	6145                	addi	sp,sp,48
    800054f2:	8082                	ret

00000000800054f4 <sys_write>:
{
    800054f4:	7179                	addi	sp,sp,-48
    800054f6:	f406                	sd	ra,40(sp)
    800054f8:	f022                	sd	s0,32(sp)
    800054fa:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054fc:	fd840593          	addi	a1,s0,-40
    80005500:	4505                	li	a0,1
    80005502:	ffffd097          	auipc	ra,0xffffd
    80005506:	7fe080e7          	jalr	2046(ra) # 80002d00 <argaddr>
  argint(2, &n);
    8000550a:	fe440593          	addi	a1,s0,-28
    8000550e:	4509                	li	a0,2
    80005510:	ffffd097          	auipc	ra,0xffffd
    80005514:	7d0080e7          	jalr	2000(ra) # 80002ce0 <argint>
  if(argfd(0, 0, &f) < 0)
    80005518:	fe840613          	addi	a2,s0,-24
    8000551c:	4581                	li	a1,0
    8000551e:	4501                	li	a0,0
    80005520:	00000097          	auipc	ra,0x0
    80005524:	cfa080e7          	jalr	-774(ra) # 8000521a <argfd>
    80005528:	87aa                	mv	a5,a0
    return -1;
    8000552a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000552c:	0007cc63          	bltz	a5,80005544 <sys_write+0x50>
  return filewrite(f, p, n);
    80005530:	fe442603          	lw	a2,-28(s0)
    80005534:	fd843583          	ld	a1,-40(s0)
    80005538:	fe843503          	ld	a0,-24(s0)
    8000553c:	fffff097          	auipc	ra,0xfffff
    80005540:	410080e7          	jalr	1040(ra) # 8000494c <filewrite>
}
    80005544:	70a2                	ld	ra,40(sp)
    80005546:	7402                	ld	s0,32(sp)
    80005548:	6145                	addi	sp,sp,48
    8000554a:	8082                	ret

000000008000554c <sys_close>:
{
    8000554c:	1101                	addi	sp,sp,-32
    8000554e:	ec06                	sd	ra,24(sp)
    80005550:	e822                	sd	s0,16(sp)
    80005552:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005554:	fe040613          	addi	a2,s0,-32
    80005558:	fec40593          	addi	a1,s0,-20
    8000555c:	4501                	li	a0,0
    8000555e:	00000097          	auipc	ra,0x0
    80005562:	cbc080e7          	jalr	-836(ra) # 8000521a <argfd>
    return -1;
    80005566:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005568:	02054563          	bltz	a0,80005592 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    8000556c:	ffffc097          	auipc	ra,0xffffc
    80005570:	648080e7          	jalr	1608(ra) # 80001bb4 <myproc>
    80005574:	fec42783          	lw	a5,-20(s0)
    80005578:	078e                	slli	a5,a5,0x3
    8000557a:	0d078793          	addi	a5,a5,208
    8000557e:	953e                	add	a0,a0,a5
    80005580:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005584:	fe043503          	ld	a0,-32(s0)
    80005588:	fffff097          	auipc	ra,0xfffff
    8000558c:	194080e7          	jalr	404(ra) # 8000471c <fileclose>
  return 0;
    80005590:	4781                	li	a5,0
}
    80005592:	853e                	mv	a0,a5
    80005594:	60e2                	ld	ra,24(sp)
    80005596:	6442                	ld	s0,16(sp)
    80005598:	6105                	addi	sp,sp,32
    8000559a:	8082                	ret

000000008000559c <sys_fstat>:
{
    8000559c:	1101                	addi	sp,sp,-32
    8000559e:	ec06                	sd	ra,24(sp)
    800055a0:	e822                	sd	s0,16(sp)
    800055a2:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800055a4:	fe040593          	addi	a1,s0,-32
    800055a8:	4505                	li	a0,1
    800055aa:	ffffd097          	auipc	ra,0xffffd
    800055ae:	756080e7          	jalr	1878(ra) # 80002d00 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800055b2:	fe840613          	addi	a2,s0,-24
    800055b6:	4581                	li	a1,0
    800055b8:	4501                	li	a0,0
    800055ba:	00000097          	auipc	ra,0x0
    800055be:	c60080e7          	jalr	-928(ra) # 8000521a <argfd>
    800055c2:	87aa                	mv	a5,a0
    return -1;
    800055c4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055c6:	0007ca63          	bltz	a5,800055da <sys_fstat+0x3e>
  return filestat(f, st);
    800055ca:	fe043583          	ld	a1,-32(s0)
    800055ce:	fe843503          	ld	a0,-24(s0)
    800055d2:	fffff097          	auipc	ra,0xfffff
    800055d6:	22c080e7          	jalr	556(ra) # 800047fe <filestat>
}
    800055da:	60e2                	ld	ra,24(sp)
    800055dc:	6442                	ld	s0,16(sp)
    800055de:	6105                	addi	sp,sp,32
    800055e0:	8082                	ret

00000000800055e2 <sys_link>:
{
    800055e2:	7169                	addi	sp,sp,-304
    800055e4:	f606                	sd	ra,296(sp)
    800055e6:	f222                	sd	s0,288(sp)
    800055e8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055ea:	08000613          	li	a2,128
    800055ee:	ed040593          	addi	a1,s0,-304
    800055f2:	4501                	li	a0,0
    800055f4:	ffffd097          	auipc	ra,0xffffd
    800055f8:	72c080e7          	jalr	1836(ra) # 80002d20 <argstr>
    return -1;
    800055fc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055fe:	12054663          	bltz	a0,8000572a <sys_link+0x148>
    80005602:	08000613          	li	a2,128
    80005606:	f5040593          	addi	a1,s0,-176
    8000560a:	4505                	li	a0,1
    8000560c:	ffffd097          	auipc	ra,0xffffd
    80005610:	714080e7          	jalr	1812(ra) # 80002d20 <argstr>
    return -1;
    80005614:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005616:	10054a63          	bltz	a0,8000572a <sys_link+0x148>
    8000561a:	ee26                	sd	s1,280(sp)
  begin_op();
    8000561c:	fffff097          	auipc	ra,0xfffff
    80005620:	c1e080e7          	jalr	-994(ra) # 8000423a <begin_op>
  if((ip = namei(old)) == 0){
    80005624:	ed040513          	addi	a0,s0,-304
    80005628:	fffff097          	auipc	ra,0xfffff
    8000562c:	a0c080e7          	jalr	-1524(ra) # 80004034 <namei>
    80005630:	84aa                	mv	s1,a0
    80005632:	c949                	beqz	a0,800056c4 <sys_link+0xe2>
  ilock(ip);
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	216080e7          	jalr	534(ra) # 8000384a <ilock>
  if(ip->type == T_DIR){
    8000563c:	04449703          	lh	a4,68(s1)
    80005640:	4785                	li	a5,1
    80005642:	08f70863          	beq	a4,a5,800056d2 <sys_link+0xf0>
    80005646:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005648:	04a4d783          	lhu	a5,74(s1)
    8000564c:	2785                	addiw	a5,a5,1
    8000564e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005652:	8526                	mv	a0,s1
    80005654:	ffffe097          	auipc	ra,0xffffe
    80005658:	12a080e7          	jalr	298(ra) # 8000377e <iupdate>
  iunlock(ip);
    8000565c:	8526                	mv	a0,s1
    8000565e:	ffffe097          	auipc	ra,0xffffe
    80005662:	2b2080e7          	jalr	690(ra) # 80003910 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005666:	fd040593          	addi	a1,s0,-48
    8000566a:	f5040513          	addi	a0,s0,-176
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	9e4080e7          	jalr	-1564(ra) # 80004052 <nameiparent>
    80005676:	892a                	mv	s2,a0
    80005678:	cd35                	beqz	a0,800056f4 <sys_link+0x112>
  ilock(dp);
    8000567a:	ffffe097          	auipc	ra,0xffffe
    8000567e:	1d0080e7          	jalr	464(ra) # 8000384a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005682:	854a                	mv	a0,s2
    80005684:	00092703          	lw	a4,0(s2)
    80005688:	409c                	lw	a5,0(s1)
    8000568a:	06f71063          	bne	a4,a5,800056ea <sys_link+0x108>
    8000568e:	40d0                	lw	a2,4(s1)
    80005690:	fd040593          	addi	a1,s0,-48
    80005694:	fffff097          	auipc	ra,0xfffff
    80005698:	8de080e7          	jalr	-1826(ra) # 80003f72 <dirlink>
    8000569c:	04054763          	bltz	a0,800056ea <sys_link+0x108>
  iunlockput(dp);
    800056a0:	854a                	mv	a0,s2
    800056a2:	ffffe097          	auipc	ra,0xffffe
    800056a6:	410080e7          	jalr	1040(ra) # 80003ab2 <iunlockput>
  iput(ip);
    800056aa:	8526                	mv	a0,s1
    800056ac:	ffffe097          	auipc	ra,0xffffe
    800056b0:	35c080e7          	jalr	860(ra) # 80003a08 <iput>
  end_op();
    800056b4:	fffff097          	auipc	ra,0xfffff
    800056b8:	c06080e7          	jalr	-1018(ra) # 800042ba <end_op>
  return 0;
    800056bc:	4781                	li	a5,0
    800056be:	64f2                	ld	s1,280(sp)
    800056c0:	6952                	ld	s2,272(sp)
    800056c2:	a0a5                	j	8000572a <sys_link+0x148>
    end_op();
    800056c4:	fffff097          	auipc	ra,0xfffff
    800056c8:	bf6080e7          	jalr	-1034(ra) # 800042ba <end_op>
    return -1;
    800056cc:	57fd                	li	a5,-1
    800056ce:	64f2                	ld	s1,280(sp)
    800056d0:	a8a9                	j	8000572a <sys_link+0x148>
    iunlockput(ip);
    800056d2:	8526                	mv	a0,s1
    800056d4:	ffffe097          	auipc	ra,0xffffe
    800056d8:	3de080e7          	jalr	990(ra) # 80003ab2 <iunlockput>
    end_op();
    800056dc:	fffff097          	auipc	ra,0xfffff
    800056e0:	bde080e7          	jalr	-1058(ra) # 800042ba <end_op>
    return -1;
    800056e4:	57fd                	li	a5,-1
    800056e6:	64f2                	ld	s1,280(sp)
    800056e8:	a089                	j	8000572a <sys_link+0x148>
    iunlockput(dp);
    800056ea:	854a                	mv	a0,s2
    800056ec:	ffffe097          	auipc	ra,0xffffe
    800056f0:	3c6080e7          	jalr	966(ra) # 80003ab2 <iunlockput>
  ilock(ip);
    800056f4:	8526                	mv	a0,s1
    800056f6:	ffffe097          	auipc	ra,0xffffe
    800056fa:	154080e7          	jalr	340(ra) # 8000384a <ilock>
  ip->nlink--;
    800056fe:	04a4d783          	lhu	a5,74(s1)
    80005702:	37fd                	addiw	a5,a5,-1
    80005704:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005708:	8526                	mv	a0,s1
    8000570a:	ffffe097          	auipc	ra,0xffffe
    8000570e:	074080e7          	jalr	116(ra) # 8000377e <iupdate>
  iunlockput(ip);
    80005712:	8526                	mv	a0,s1
    80005714:	ffffe097          	auipc	ra,0xffffe
    80005718:	39e080e7          	jalr	926(ra) # 80003ab2 <iunlockput>
  end_op();
    8000571c:	fffff097          	auipc	ra,0xfffff
    80005720:	b9e080e7          	jalr	-1122(ra) # 800042ba <end_op>
  return -1;
    80005724:	57fd                	li	a5,-1
    80005726:	64f2                	ld	s1,280(sp)
    80005728:	6952                	ld	s2,272(sp)
}
    8000572a:	853e                	mv	a0,a5
    8000572c:	70b2                	ld	ra,296(sp)
    8000572e:	7412                	ld	s0,288(sp)
    80005730:	6155                	addi	sp,sp,304
    80005732:	8082                	ret

0000000080005734 <sys_unlink>:
{
    80005734:	7151                	addi	sp,sp,-240
    80005736:	f586                	sd	ra,232(sp)
    80005738:	f1a2                	sd	s0,224(sp)
    8000573a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000573c:	08000613          	li	a2,128
    80005740:	f3040593          	addi	a1,s0,-208
    80005744:	4501                	li	a0,0
    80005746:	ffffd097          	auipc	ra,0xffffd
    8000574a:	5da080e7          	jalr	1498(ra) # 80002d20 <argstr>
    8000574e:	1a054763          	bltz	a0,800058fc <sys_unlink+0x1c8>
    80005752:	eda6                	sd	s1,216(sp)
  begin_op();
    80005754:	fffff097          	auipc	ra,0xfffff
    80005758:	ae6080e7          	jalr	-1306(ra) # 8000423a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000575c:	fb040593          	addi	a1,s0,-80
    80005760:	f3040513          	addi	a0,s0,-208
    80005764:	fffff097          	auipc	ra,0xfffff
    80005768:	8ee080e7          	jalr	-1810(ra) # 80004052 <nameiparent>
    8000576c:	84aa                	mv	s1,a0
    8000576e:	c165                	beqz	a0,8000584e <sys_unlink+0x11a>
  ilock(dp);
    80005770:	ffffe097          	auipc	ra,0xffffe
    80005774:	0da080e7          	jalr	218(ra) # 8000384a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005778:	00003597          	auipc	a1,0x3
    8000577c:	ef858593          	addi	a1,a1,-264 # 80008670 <etext+0x670>
    80005780:	fb040513          	addi	a0,s0,-80
    80005784:	ffffe097          	auipc	ra,0xffffe
    80005788:	5a6080e7          	jalr	1446(ra) # 80003d2a <namecmp>
    8000578c:	14050963          	beqz	a0,800058de <sys_unlink+0x1aa>
    80005790:	00003597          	auipc	a1,0x3
    80005794:	ee858593          	addi	a1,a1,-280 # 80008678 <etext+0x678>
    80005798:	fb040513          	addi	a0,s0,-80
    8000579c:	ffffe097          	auipc	ra,0xffffe
    800057a0:	58e080e7          	jalr	1422(ra) # 80003d2a <namecmp>
    800057a4:	12050d63          	beqz	a0,800058de <sys_unlink+0x1aa>
    800057a8:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057aa:	f2c40613          	addi	a2,s0,-212
    800057ae:	fb040593          	addi	a1,s0,-80
    800057b2:	8526                	mv	a0,s1
    800057b4:	ffffe097          	auipc	ra,0xffffe
    800057b8:	590080e7          	jalr	1424(ra) # 80003d44 <dirlookup>
    800057bc:	892a                	mv	s2,a0
    800057be:	10050f63          	beqz	a0,800058dc <sys_unlink+0x1a8>
    800057c2:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800057c4:	ffffe097          	auipc	ra,0xffffe
    800057c8:	086080e7          	jalr	134(ra) # 8000384a <ilock>
  if(ip->nlink < 1)
    800057cc:	04a91783          	lh	a5,74(s2)
    800057d0:	08f05663          	blez	a5,8000585c <sys_unlink+0x128>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057d4:	04491703          	lh	a4,68(s2)
    800057d8:	4785                	li	a5,1
    800057da:	08f70963          	beq	a4,a5,8000586c <sys_unlink+0x138>
  memset(&de, 0, sizeof(de));
    800057de:	fc040993          	addi	s3,s0,-64
    800057e2:	4641                	li	a2,16
    800057e4:	4581                	li	a1,0
    800057e6:	854e                	mv	a0,s3
    800057e8:	ffffb097          	auipc	ra,0xffffb
    800057ec:	56c080e7          	jalr	1388(ra) # 80000d54 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057f0:	4741                	li	a4,16
    800057f2:	f2c42683          	lw	a3,-212(s0)
    800057f6:	864e                	mv	a2,s3
    800057f8:	4581                	li	a1,0
    800057fa:	8526                	mv	a0,s1
    800057fc:	ffffe097          	auipc	ra,0xffffe
    80005800:	412080e7          	jalr	1042(ra) # 80003c0e <writei>
    80005804:	47c1                	li	a5,16
    80005806:	0af51863          	bne	a0,a5,800058b6 <sys_unlink+0x182>
  if(ip->type == T_DIR){
    8000580a:	04491703          	lh	a4,68(s2)
    8000580e:	4785                	li	a5,1
    80005810:	0af70b63          	beq	a4,a5,800058c6 <sys_unlink+0x192>
  iunlockput(dp);
    80005814:	8526                	mv	a0,s1
    80005816:	ffffe097          	auipc	ra,0xffffe
    8000581a:	29c080e7          	jalr	668(ra) # 80003ab2 <iunlockput>
  ip->nlink--;
    8000581e:	04a95783          	lhu	a5,74(s2)
    80005822:	37fd                	addiw	a5,a5,-1
    80005824:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005828:	854a                	mv	a0,s2
    8000582a:	ffffe097          	auipc	ra,0xffffe
    8000582e:	f54080e7          	jalr	-172(ra) # 8000377e <iupdate>
  iunlockput(ip);
    80005832:	854a                	mv	a0,s2
    80005834:	ffffe097          	auipc	ra,0xffffe
    80005838:	27e080e7          	jalr	638(ra) # 80003ab2 <iunlockput>
  end_op();
    8000583c:	fffff097          	auipc	ra,0xfffff
    80005840:	a7e080e7          	jalr	-1410(ra) # 800042ba <end_op>
  return 0;
    80005844:	4501                	li	a0,0
    80005846:	64ee                	ld	s1,216(sp)
    80005848:	694e                	ld	s2,208(sp)
    8000584a:	69ae                	ld	s3,200(sp)
    8000584c:	a065                	j	800058f4 <sys_unlink+0x1c0>
    end_op();
    8000584e:	fffff097          	auipc	ra,0xfffff
    80005852:	a6c080e7          	jalr	-1428(ra) # 800042ba <end_op>
    return -1;
    80005856:	557d                	li	a0,-1
    80005858:	64ee                	ld	s1,216(sp)
    8000585a:	a869                	j	800058f4 <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    8000585c:	00003517          	auipc	a0,0x3
    80005860:	e2450513          	addi	a0,a0,-476 # 80008680 <etext+0x680>
    80005864:	ffffb097          	auipc	ra,0xffffb
    80005868:	cfa080e7          	jalr	-774(ra) # 8000055e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000586c:	04c92703          	lw	a4,76(s2)
    80005870:	02000793          	li	a5,32
    80005874:	f6e7f5e3          	bgeu	a5,a4,800057de <sys_unlink+0xaa>
    80005878:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000587a:	4741                	li	a4,16
    8000587c:	86ce                	mv	a3,s3
    8000587e:	f1840613          	addi	a2,s0,-232
    80005882:	4581                	li	a1,0
    80005884:	854a                	mv	a0,s2
    80005886:	ffffe097          	auipc	ra,0xffffe
    8000588a:	282080e7          	jalr	642(ra) # 80003b08 <readi>
    8000588e:	47c1                	li	a5,16
    80005890:	00f51b63          	bne	a0,a5,800058a6 <sys_unlink+0x172>
    if(de.inum != 0)
    80005894:	f1845783          	lhu	a5,-232(s0)
    80005898:	e7a5                	bnez	a5,80005900 <sys_unlink+0x1cc>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000589a:	29c1                	addiw	s3,s3,16
    8000589c:	04c92783          	lw	a5,76(s2)
    800058a0:	fcf9ede3          	bltu	s3,a5,8000587a <sys_unlink+0x146>
    800058a4:	bf2d                	j	800057de <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058a6:	00003517          	auipc	a0,0x3
    800058aa:	df250513          	addi	a0,a0,-526 # 80008698 <etext+0x698>
    800058ae:	ffffb097          	auipc	ra,0xffffb
    800058b2:	cb0080e7          	jalr	-848(ra) # 8000055e <panic>
    panic("unlink: writei");
    800058b6:	00003517          	auipc	a0,0x3
    800058ba:	dfa50513          	addi	a0,a0,-518 # 800086b0 <etext+0x6b0>
    800058be:	ffffb097          	auipc	ra,0xffffb
    800058c2:	ca0080e7          	jalr	-864(ra) # 8000055e <panic>
    dp->nlink--;
    800058c6:	04a4d783          	lhu	a5,74(s1)
    800058ca:	37fd                	addiw	a5,a5,-1
    800058cc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058d0:	8526                	mv	a0,s1
    800058d2:	ffffe097          	auipc	ra,0xffffe
    800058d6:	eac080e7          	jalr	-340(ra) # 8000377e <iupdate>
    800058da:	bf2d                	j	80005814 <sys_unlink+0xe0>
    800058dc:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800058de:	8526                	mv	a0,s1
    800058e0:	ffffe097          	auipc	ra,0xffffe
    800058e4:	1d2080e7          	jalr	466(ra) # 80003ab2 <iunlockput>
  end_op();
    800058e8:	fffff097          	auipc	ra,0xfffff
    800058ec:	9d2080e7          	jalr	-1582(ra) # 800042ba <end_op>
  return -1;
    800058f0:	557d                	li	a0,-1
    800058f2:	64ee                	ld	s1,216(sp)
}
    800058f4:	70ae                	ld	ra,232(sp)
    800058f6:	740e                	ld	s0,224(sp)
    800058f8:	616d                	addi	sp,sp,240
    800058fa:	8082                	ret
    return -1;
    800058fc:	557d                	li	a0,-1
    800058fe:	bfdd                	j	800058f4 <sys_unlink+0x1c0>
    iunlockput(ip);
    80005900:	854a                	mv	a0,s2
    80005902:	ffffe097          	auipc	ra,0xffffe
    80005906:	1b0080e7          	jalr	432(ra) # 80003ab2 <iunlockput>
    goto bad;
    8000590a:	694e                	ld	s2,208(sp)
    8000590c:	69ae                	ld	s3,200(sp)
    8000590e:	bfc1                	j	800058de <sys_unlink+0x1aa>

0000000080005910 <sys_open>:

uint64
sys_open(void)
{
    80005910:	7131                	addi	sp,sp,-192
    80005912:	fd06                	sd	ra,184(sp)
    80005914:	f922                	sd	s0,176(sp)
    80005916:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005918:	f4c40593          	addi	a1,s0,-180
    8000591c:	4505                	li	a0,1
    8000591e:	ffffd097          	auipc	ra,0xffffd
    80005922:	3c2080e7          	jalr	962(ra) # 80002ce0 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005926:	08000613          	li	a2,128
    8000592a:	f5040593          	addi	a1,s0,-176
    8000592e:	4501                	li	a0,0
    80005930:	ffffd097          	auipc	ra,0xffffd
    80005934:	3f0080e7          	jalr	1008(ra) # 80002d20 <argstr>
    80005938:	87aa                	mv	a5,a0
    return -1;
    8000593a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000593c:	0a07cf63          	bltz	a5,800059fa <sys_open+0xea>
    80005940:	f526                	sd	s1,168(sp)

  begin_op();
    80005942:	fffff097          	auipc	ra,0xfffff
    80005946:	8f8080e7          	jalr	-1800(ra) # 8000423a <begin_op>

  if(omode & O_CREATE){
    8000594a:	f4c42783          	lw	a5,-180(s0)
    8000594e:	2007f793          	andi	a5,a5,512
    80005952:	cfdd                	beqz	a5,80005a10 <sys_open+0x100>
    ip = create(path, T_FILE, 0, 0);
    80005954:	4681                	li	a3,0
    80005956:	4601                	li	a2,0
    80005958:	4589                	li	a1,2
    8000595a:	f5040513          	addi	a0,s0,-176
    8000595e:	00000097          	auipc	ra,0x0
    80005962:	962080e7          	jalr	-1694(ra) # 800052c0 <create>
    80005966:	84aa                	mv	s1,a0
    if(ip == 0){
    80005968:	cd49                	beqz	a0,80005a02 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000596a:	04449703          	lh	a4,68(s1)
    8000596e:	478d                	li	a5,3
    80005970:	00f71763          	bne	a4,a5,8000597e <sys_open+0x6e>
    80005974:	0464d703          	lhu	a4,70(s1)
    80005978:	47a5                	li	a5,9
    8000597a:	0ee7e263          	bltu	a5,a4,80005a5e <sys_open+0x14e>
    8000597e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005980:	fffff097          	auipc	ra,0xfffff
    80005984:	ce0080e7          	jalr	-800(ra) # 80004660 <filealloc>
    80005988:	892a                	mv	s2,a0
    8000598a:	cd65                	beqz	a0,80005a82 <sys_open+0x172>
    8000598c:	ed4e                	sd	s3,152(sp)
    8000598e:	00000097          	auipc	ra,0x0
    80005992:	8ee080e7          	jalr	-1810(ra) # 8000527c <fdalloc>
    80005996:	89aa                	mv	s3,a0
    80005998:	0c054f63          	bltz	a0,80005a76 <sys_open+0x166>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000599c:	04449703          	lh	a4,68(s1)
    800059a0:	478d                	li	a5,3
    800059a2:	0ef70d63          	beq	a4,a5,80005a9c <sys_open+0x18c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800059a6:	4789                	li	a5,2
    800059a8:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800059ac:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800059b0:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800059b4:	f4c42783          	lw	a5,-180(s0)
    800059b8:	0017f713          	andi	a4,a5,1
    800059bc:	00174713          	xori	a4,a4,1
    800059c0:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059c4:	0037f713          	andi	a4,a5,3
    800059c8:	00e03733          	snez	a4,a4
    800059cc:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059d0:	4007f793          	andi	a5,a5,1024
    800059d4:	c791                	beqz	a5,800059e0 <sys_open+0xd0>
    800059d6:	04449703          	lh	a4,68(s1)
    800059da:	4789                	li	a5,2
    800059dc:	0cf70763          	beq	a4,a5,80005aaa <sys_open+0x19a>
    itrunc(ip);
  }

  iunlock(ip);
    800059e0:	8526                	mv	a0,s1
    800059e2:	ffffe097          	auipc	ra,0xffffe
    800059e6:	f2e080e7          	jalr	-210(ra) # 80003910 <iunlock>
  end_op();
    800059ea:	fffff097          	auipc	ra,0xfffff
    800059ee:	8d0080e7          	jalr	-1840(ra) # 800042ba <end_op>

  return fd;
    800059f2:	854e                	mv	a0,s3
    800059f4:	74aa                	ld	s1,168(sp)
    800059f6:	790a                	ld	s2,160(sp)
    800059f8:	69ea                	ld	s3,152(sp)
}
    800059fa:	70ea                	ld	ra,184(sp)
    800059fc:	744a                	ld	s0,176(sp)
    800059fe:	6129                	addi	sp,sp,192
    80005a00:	8082                	ret
      end_op();
    80005a02:	fffff097          	auipc	ra,0xfffff
    80005a06:	8b8080e7          	jalr	-1864(ra) # 800042ba <end_op>
      return -1;
    80005a0a:	557d                	li	a0,-1
    80005a0c:	74aa                	ld	s1,168(sp)
    80005a0e:	b7f5                	j	800059fa <sys_open+0xea>
    if((ip = namei(path)) == 0){
    80005a10:	f5040513          	addi	a0,s0,-176
    80005a14:	ffffe097          	auipc	ra,0xffffe
    80005a18:	620080e7          	jalr	1568(ra) # 80004034 <namei>
    80005a1c:	84aa                	mv	s1,a0
    80005a1e:	c90d                	beqz	a0,80005a50 <sys_open+0x140>
    ilock(ip);
    80005a20:	ffffe097          	auipc	ra,0xffffe
    80005a24:	e2a080e7          	jalr	-470(ra) # 8000384a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a28:	04449703          	lh	a4,68(s1)
    80005a2c:	4785                	li	a5,1
    80005a2e:	f2f71ee3          	bne	a4,a5,8000596a <sys_open+0x5a>
    80005a32:	f4c42783          	lw	a5,-180(s0)
    80005a36:	d7a1                	beqz	a5,8000597e <sys_open+0x6e>
      iunlockput(ip);
    80005a38:	8526                	mv	a0,s1
    80005a3a:	ffffe097          	auipc	ra,0xffffe
    80005a3e:	078080e7          	jalr	120(ra) # 80003ab2 <iunlockput>
      end_op();
    80005a42:	fffff097          	auipc	ra,0xfffff
    80005a46:	878080e7          	jalr	-1928(ra) # 800042ba <end_op>
      return -1;
    80005a4a:	557d                	li	a0,-1
    80005a4c:	74aa                	ld	s1,168(sp)
    80005a4e:	b775                	j	800059fa <sys_open+0xea>
      end_op();
    80005a50:	fffff097          	auipc	ra,0xfffff
    80005a54:	86a080e7          	jalr	-1942(ra) # 800042ba <end_op>
      return -1;
    80005a58:	557d                	li	a0,-1
    80005a5a:	74aa                	ld	s1,168(sp)
    80005a5c:	bf79                	j	800059fa <sys_open+0xea>
    iunlockput(ip);
    80005a5e:	8526                	mv	a0,s1
    80005a60:	ffffe097          	auipc	ra,0xffffe
    80005a64:	052080e7          	jalr	82(ra) # 80003ab2 <iunlockput>
    end_op();
    80005a68:	fffff097          	auipc	ra,0xfffff
    80005a6c:	852080e7          	jalr	-1966(ra) # 800042ba <end_op>
    return -1;
    80005a70:	557d                	li	a0,-1
    80005a72:	74aa                	ld	s1,168(sp)
    80005a74:	b759                	j	800059fa <sys_open+0xea>
      fileclose(f);
    80005a76:	854a                	mv	a0,s2
    80005a78:	fffff097          	auipc	ra,0xfffff
    80005a7c:	ca4080e7          	jalr	-860(ra) # 8000471c <fileclose>
    80005a80:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005a82:	8526                	mv	a0,s1
    80005a84:	ffffe097          	auipc	ra,0xffffe
    80005a88:	02e080e7          	jalr	46(ra) # 80003ab2 <iunlockput>
    end_op();
    80005a8c:	fffff097          	auipc	ra,0xfffff
    80005a90:	82e080e7          	jalr	-2002(ra) # 800042ba <end_op>
    return -1;
    80005a94:	557d                	li	a0,-1
    80005a96:	74aa                	ld	s1,168(sp)
    80005a98:	790a                	ld	s2,160(sp)
    80005a9a:	b785                	j	800059fa <sys_open+0xea>
    f->type = FD_DEVICE;
    80005a9c:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005aa0:	04649783          	lh	a5,70(s1)
    80005aa4:	02f91223          	sh	a5,36(s2)
    80005aa8:	b721                	j	800059b0 <sys_open+0xa0>
    itrunc(ip);
    80005aaa:	8526                	mv	a0,s1
    80005aac:	ffffe097          	auipc	ra,0xffffe
    80005ab0:	eb0080e7          	jalr	-336(ra) # 8000395c <itrunc>
    80005ab4:	b735                	j	800059e0 <sys_open+0xd0>

0000000080005ab6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ab6:	7175                	addi	sp,sp,-144
    80005ab8:	e506                	sd	ra,136(sp)
    80005aba:	e122                	sd	s0,128(sp)
    80005abc:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005abe:	ffffe097          	auipc	ra,0xffffe
    80005ac2:	77c080e7          	jalr	1916(ra) # 8000423a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ac6:	08000613          	li	a2,128
    80005aca:	f7040593          	addi	a1,s0,-144
    80005ace:	4501                	li	a0,0
    80005ad0:	ffffd097          	auipc	ra,0xffffd
    80005ad4:	250080e7          	jalr	592(ra) # 80002d20 <argstr>
    80005ad8:	02054963          	bltz	a0,80005b0a <sys_mkdir+0x54>
    80005adc:	4681                	li	a3,0
    80005ade:	4601                	li	a2,0
    80005ae0:	4585                	li	a1,1
    80005ae2:	f7040513          	addi	a0,s0,-144
    80005ae6:	fffff097          	auipc	ra,0xfffff
    80005aea:	7da080e7          	jalr	2010(ra) # 800052c0 <create>
    80005aee:	cd11                	beqz	a0,80005b0a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005af0:	ffffe097          	auipc	ra,0xffffe
    80005af4:	fc2080e7          	jalr	-62(ra) # 80003ab2 <iunlockput>
  end_op();
    80005af8:	ffffe097          	auipc	ra,0xffffe
    80005afc:	7c2080e7          	jalr	1986(ra) # 800042ba <end_op>
  return 0;
    80005b00:	4501                	li	a0,0
}
    80005b02:	60aa                	ld	ra,136(sp)
    80005b04:	640a                	ld	s0,128(sp)
    80005b06:	6149                	addi	sp,sp,144
    80005b08:	8082                	ret
    end_op();
    80005b0a:	ffffe097          	auipc	ra,0xffffe
    80005b0e:	7b0080e7          	jalr	1968(ra) # 800042ba <end_op>
    return -1;
    80005b12:	557d                	li	a0,-1
    80005b14:	b7fd                	j	80005b02 <sys_mkdir+0x4c>

0000000080005b16 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b16:	7135                	addi	sp,sp,-160
    80005b18:	ed06                	sd	ra,152(sp)
    80005b1a:	e922                	sd	s0,144(sp)
    80005b1c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	71c080e7          	jalr	1820(ra) # 8000423a <begin_op>
  argint(1, &major);
    80005b26:	f6c40593          	addi	a1,s0,-148
    80005b2a:	4505                	li	a0,1
    80005b2c:	ffffd097          	auipc	ra,0xffffd
    80005b30:	1b4080e7          	jalr	436(ra) # 80002ce0 <argint>
  argint(2, &minor);
    80005b34:	f6840593          	addi	a1,s0,-152
    80005b38:	4509                	li	a0,2
    80005b3a:	ffffd097          	auipc	ra,0xffffd
    80005b3e:	1a6080e7          	jalr	422(ra) # 80002ce0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b42:	08000613          	li	a2,128
    80005b46:	f7040593          	addi	a1,s0,-144
    80005b4a:	4501                	li	a0,0
    80005b4c:	ffffd097          	auipc	ra,0xffffd
    80005b50:	1d4080e7          	jalr	468(ra) # 80002d20 <argstr>
    80005b54:	02054b63          	bltz	a0,80005b8a <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b58:	f6841683          	lh	a3,-152(s0)
    80005b5c:	f6c41603          	lh	a2,-148(s0)
    80005b60:	458d                	li	a1,3
    80005b62:	f7040513          	addi	a0,s0,-144
    80005b66:	fffff097          	auipc	ra,0xfffff
    80005b6a:	75a080e7          	jalr	1882(ra) # 800052c0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b6e:	cd11                	beqz	a0,80005b8a <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b70:	ffffe097          	auipc	ra,0xffffe
    80005b74:	f42080e7          	jalr	-190(ra) # 80003ab2 <iunlockput>
  end_op();
    80005b78:	ffffe097          	auipc	ra,0xffffe
    80005b7c:	742080e7          	jalr	1858(ra) # 800042ba <end_op>
  return 0;
    80005b80:	4501                	li	a0,0
}
    80005b82:	60ea                	ld	ra,152(sp)
    80005b84:	644a                	ld	s0,144(sp)
    80005b86:	610d                	addi	sp,sp,160
    80005b88:	8082                	ret
    end_op();
    80005b8a:	ffffe097          	auipc	ra,0xffffe
    80005b8e:	730080e7          	jalr	1840(ra) # 800042ba <end_op>
    return -1;
    80005b92:	557d                	li	a0,-1
    80005b94:	b7fd                	j	80005b82 <sys_mknod+0x6c>

0000000080005b96 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b96:	7135                	addi	sp,sp,-160
    80005b98:	ed06                	sd	ra,152(sp)
    80005b9a:	e922                	sd	s0,144(sp)
    80005b9c:	e14a                	sd	s2,128(sp)
    80005b9e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ba0:	ffffc097          	auipc	ra,0xffffc
    80005ba4:	014080e7          	jalr	20(ra) # 80001bb4 <myproc>
    80005ba8:	892a                	mv	s2,a0
  
  begin_op();
    80005baa:	ffffe097          	auipc	ra,0xffffe
    80005bae:	690080e7          	jalr	1680(ra) # 8000423a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bb2:	08000613          	li	a2,128
    80005bb6:	f6040593          	addi	a1,s0,-160
    80005bba:	4501                	li	a0,0
    80005bbc:	ffffd097          	auipc	ra,0xffffd
    80005bc0:	164080e7          	jalr	356(ra) # 80002d20 <argstr>
    80005bc4:	04054d63          	bltz	a0,80005c1e <sys_chdir+0x88>
    80005bc8:	e526                	sd	s1,136(sp)
    80005bca:	f6040513          	addi	a0,s0,-160
    80005bce:	ffffe097          	auipc	ra,0xffffe
    80005bd2:	466080e7          	jalr	1126(ra) # 80004034 <namei>
    80005bd6:	84aa                	mv	s1,a0
    80005bd8:	c131                	beqz	a0,80005c1c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005bda:	ffffe097          	auipc	ra,0xffffe
    80005bde:	c70080e7          	jalr	-912(ra) # 8000384a <ilock>
  if(ip->type != T_DIR){
    80005be2:	04449703          	lh	a4,68(s1)
    80005be6:	4785                	li	a5,1
    80005be8:	04f71163          	bne	a4,a5,80005c2a <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005bec:	8526                	mv	a0,s1
    80005bee:	ffffe097          	auipc	ra,0xffffe
    80005bf2:	d22080e7          	jalr	-734(ra) # 80003910 <iunlock>
  iput(p->cwd);
    80005bf6:	15093503          	ld	a0,336(s2)
    80005bfa:	ffffe097          	auipc	ra,0xffffe
    80005bfe:	e0e080e7          	jalr	-498(ra) # 80003a08 <iput>
  end_op();
    80005c02:	ffffe097          	auipc	ra,0xffffe
    80005c06:	6b8080e7          	jalr	1720(ra) # 800042ba <end_op>
  p->cwd = ip;
    80005c0a:	14993823          	sd	s1,336(s2)
  return 0;
    80005c0e:	4501                	li	a0,0
    80005c10:	64aa                	ld	s1,136(sp)
}
    80005c12:	60ea                	ld	ra,152(sp)
    80005c14:	644a                	ld	s0,144(sp)
    80005c16:	690a                	ld	s2,128(sp)
    80005c18:	610d                	addi	sp,sp,160
    80005c1a:	8082                	ret
    80005c1c:	64aa                	ld	s1,136(sp)
    end_op();
    80005c1e:	ffffe097          	auipc	ra,0xffffe
    80005c22:	69c080e7          	jalr	1692(ra) # 800042ba <end_op>
    return -1;
    80005c26:	557d                	li	a0,-1
    80005c28:	b7ed                	j	80005c12 <sys_chdir+0x7c>
    iunlockput(ip);
    80005c2a:	8526                	mv	a0,s1
    80005c2c:	ffffe097          	auipc	ra,0xffffe
    80005c30:	e86080e7          	jalr	-378(ra) # 80003ab2 <iunlockput>
    end_op();
    80005c34:	ffffe097          	auipc	ra,0xffffe
    80005c38:	686080e7          	jalr	1670(ra) # 800042ba <end_op>
    return -1;
    80005c3c:	557d                	li	a0,-1
    80005c3e:	64aa                	ld	s1,136(sp)
    80005c40:	bfc9                	j	80005c12 <sys_chdir+0x7c>

0000000080005c42 <sys_exec>:

uint64
sys_exec(void)
{
    80005c42:	7105                	addi	sp,sp,-480
    80005c44:	ef86                	sd	ra,472(sp)
    80005c46:	eba2                	sd	s0,464(sp)
    80005c48:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c4a:	e2840593          	addi	a1,s0,-472
    80005c4e:	4505                	li	a0,1
    80005c50:	ffffd097          	auipc	ra,0xffffd
    80005c54:	0b0080e7          	jalr	176(ra) # 80002d00 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c58:	08000613          	li	a2,128
    80005c5c:	f3040593          	addi	a1,s0,-208
    80005c60:	4501                	li	a0,0
    80005c62:	ffffd097          	auipc	ra,0xffffd
    80005c66:	0be080e7          	jalr	190(ra) # 80002d20 <argstr>
    80005c6a:	87aa                	mv	a5,a0
    return -1;
    80005c6c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c6e:	0e07ce63          	bltz	a5,80005d6a <sys_exec+0x128>
    80005c72:	e7a6                	sd	s1,456(sp)
    80005c74:	e3ca                	sd	s2,448(sp)
    80005c76:	ff4e                	sd	s3,440(sp)
    80005c78:	fb52                	sd	s4,432(sp)
    80005c7a:	f756                	sd	s5,424(sp)
    80005c7c:	f35a                	sd	s6,416(sp)
    80005c7e:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005c80:	e3040a13          	addi	s4,s0,-464
    80005c84:	10000613          	li	a2,256
    80005c88:	4581                	li	a1,0
    80005c8a:	8552                	mv	a0,s4
    80005c8c:	ffffb097          	auipc	ra,0xffffb
    80005c90:	0c8080e7          	jalr	200(ra) # 80000d54 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c94:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005c96:	89d2                	mv	s3,s4
    80005c98:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c9a:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c9e:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005ca0:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ca4:	00391513          	slli	a0,s2,0x3
    80005ca8:	85d6                	mv	a1,s5
    80005caa:	e2843783          	ld	a5,-472(s0)
    80005cae:	953e                	add	a0,a0,a5
    80005cb0:	ffffd097          	auipc	ra,0xffffd
    80005cb4:	f92080e7          	jalr	-110(ra) # 80002c42 <fetchaddr>
    80005cb8:	02054a63          	bltz	a0,80005cec <sys_exec+0xaa>
    if(uarg == 0){
    80005cbc:	e2043783          	ld	a5,-480(s0)
    80005cc0:	cbb1                	beqz	a5,80005d14 <sys_exec+0xd2>
    argv[i] = kalloc();
    80005cc2:	ffffb097          	auipc	ra,0xffffb
    80005cc6:	e96080e7          	jalr	-362(ra) # 80000b58 <kalloc>
    80005cca:	85aa                	mv	a1,a0
    80005ccc:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005cd0:	cd11                	beqz	a0,80005cec <sys_exec+0xaa>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005cd2:	865a                	mv	a2,s6
    80005cd4:	e2043503          	ld	a0,-480(s0)
    80005cd8:	ffffd097          	auipc	ra,0xffffd
    80005cdc:	fbc080e7          	jalr	-68(ra) # 80002c94 <fetchstr>
    80005ce0:	00054663          	bltz	a0,80005cec <sys_exec+0xaa>
    if(i >= NELEM(argv)){
    80005ce4:	0905                	addi	s2,s2,1
    80005ce6:	09a1                	addi	s3,s3,8
    80005ce8:	fb791ee3          	bne	s2,s7,80005ca4 <sys_exec+0x62>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cec:	100a0a13          	addi	s4,s4,256
    80005cf0:	6088                	ld	a0,0(s1)
    80005cf2:	c525                	beqz	a0,80005d5a <sys_exec+0x118>
    kfree(argv[i]);
    80005cf4:	ffffb097          	auipc	ra,0xffffb
    80005cf8:	d60080e7          	jalr	-672(ra) # 80000a54 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cfc:	04a1                	addi	s1,s1,8
    80005cfe:	ff4499e3          	bne	s1,s4,80005cf0 <sys_exec+0xae>
  return -1;
    80005d02:	557d                	li	a0,-1
    80005d04:	64be                	ld	s1,456(sp)
    80005d06:	691e                	ld	s2,448(sp)
    80005d08:	79fa                	ld	s3,440(sp)
    80005d0a:	7a5a                	ld	s4,432(sp)
    80005d0c:	7aba                	ld	s5,424(sp)
    80005d0e:	7b1a                	ld	s6,416(sp)
    80005d10:	6bfa                	ld	s7,408(sp)
    80005d12:	a8a1                	j	80005d6a <sys_exec+0x128>
      argv[i] = 0;
    80005d14:	0009079b          	sext.w	a5,s2
    80005d18:	e3040593          	addi	a1,s0,-464
    80005d1c:	078e                	slli	a5,a5,0x3
    80005d1e:	97ae                	add	a5,a5,a1
    80005d20:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    80005d24:	f3040513          	addi	a0,s0,-208
    80005d28:	fffff097          	auipc	ra,0xfffff
    80005d2c:	10e080e7          	jalr	270(ra) # 80004e36 <exec>
    80005d30:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d32:	100a0a13          	addi	s4,s4,256
    80005d36:	6088                	ld	a0,0(s1)
    80005d38:	c901                	beqz	a0,80005d48 <sys_exec+0x106>
    kfree(argv[i]);
    80005d3a:	ffffb097          	auipc	ra,0xffffb
    80005d3e:	d1a080e7          	jalr	-742(ra) # 80000a54 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d42:	04a1                	addi	s1,s1,8
    80005d44:	ff4499e3          	bne	s1,s4,80005d36 <sys_exec+0xf4>
  return ret;
    80005d48:	854a                	mv	a0,s2
    80005d4a:	64be                	ld	s1,456(sp)
    80005d4c:	691e                	ld	s2,448(sp)
    80005d4e:	79fa                	ld	s3,440(sp)
    80005d50:	7a5a                	ld	s4,432(sp)
    80005d52:	7aba                	ld	s5,424(sp)
    80005d54:	7b1a                	ld	s6,416(sp)
    80005d56:	6bfa                	ld	s7,408(sp)
    80005d58:	a809                	j	80005d6a <sys_exec+0x128>
  return -1;
    80005d5a:	557d                	li	a0,-1
    80005d5c:	64be                	ld	s1,456(sp)
    80005d5e:	691e                	ld	s2,448(sp)
    80005d60:	79fa                	ld	s3,440(sp)
    80005d62:	7a5a                	ld	s4,432(sp)
    80005d64:	7aba                	ld	s5,424(sp)
    80005d66:	7b1a                	ld	s6,416(sp)
    80005d68:	6bfa                	ld	s7,408(sp)
}
    80005d6a:	60fe                	ld	ra,472(sp)
    80005d6c:	645e                	ld	s0,464(sp)
    80005d6e:	613d                	addi	sp,sp,480
    80005d70:	8082                	ret

0000000080005d72 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d72:	7139                	addi	sp,sp,-64
    80005d74:	fc06                	sd	ra,56(sp)
    80005d76:	f822                	sd	s0,48(sp)
    80005d78:	f426                	sd	s1,40(sp)
    80005d7a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d7c:	ffffc097          	auipc	ra,0xffffc
    80005d80:	e38080e7          	jalr	-456(ra) # 80001bb4 <myproc>
    80005d84:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d86:	fd840593          	addi	a1,s0,-40
    80005d8a:	4501                	li	a0,0
    80005d8c:	ffffd097          	auipc	ra,0xffffd
    80005d90:	f74080e7          	jalr	-140(ra) # 80002d00 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d94:	fc840593          	addi	a1,s0,-56
    80005d98:	fd040513          	addi	a0,s0,-48
    80005d9c:	fffff097          	auipc	ra,0xfffff
    80005da0:	d00080e7          	jalr	-768(ra) # 80004a9c <pipealloc>
    return -1;
    80005da4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005da6:	0c054763          	bltz	a0,80005e74 <sys_pipe+0x102>
  fd0 = -1;
    80005daa:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005dae:	fd043503          	ld	a0,-48(s0)
    80005db2:	fffff097          	auipc	ra,0xfffff
    80005db6:	4ca080e7          	jalr	1226(ra) # 8000527c <fdalloc>
    80005dba:	fca42223          	sw	a0,-60(s0)
    80005dbe:	08054e63          	bltz	a0,80005e5a <sys_pipe+0xe8>
    80005dc2:	fc843503          	ld	a0,-56(s0)
    80005dc6:	fffff097          	auipc	ra,0xfffff
    80005dca:	4b6080e7          	jalr	1206(ra) # 8000527c <fdalloc>
    80005dce:	fca42023          	sw	a0,-64(s0)
    80005dd2:	06054a63          	bltz	a0,80005e46 <sys_pipe+0xd4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dd6:	4691                	li	a3,4
    80005dd8:	fc440613          	addi	a2,s0,-60
    80005ddc:	fd843583          	ld	a1,-40(s0)
    80005de0:	68a8                	ld	a0,80(s1)
    80005de2:	ffffc097          	auipc	ra,0xffffc
    80005de6:	a1e080e7          	jalr	-1506(ra) # 80001800 <copyout>
    80005dea:	02054063          	bltz	a0,80005e0a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005dee:	4691                	li	a3,4
    80005df0:	fc040613          	addi	a2,s0,-64
    80005df4:	fd843583          	ld	a1,-40(s0)
    80005df8:	95b6                	add	a1,a1,a3
    80005dfa:	68a8                	ld	a0,80(s1)
    80005dfc:	ffffc097          	auipc	ra,0xffffc
    80005e00:	a04080e7          	jalr	-1532(ra) # 80001800 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e04:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e06:	06055763          	bgez	a0,80005e74 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005e0a:	fc442783          	lw	a5,-60(s0)
    80005e0e:	078e                	slli	a5,a5,0x3
    80005e10:	0d078793          	addi	a5,a5,208
    80005e14:	97a6                	add	a5,a5,s1
    80005e16:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e1a:	fc042783          	lw	a5,-64(s0)
    80005e1e:	078e                	slli	a5,a5,0x3
    80005e20:	0d078793          	addi	a5,a5,208
    80005e24:	97a6                	add	a5,a5,s1
    80005e26:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005e2a:	fd043503          	ld	a0,-48(s0)
    80005e2e:	fffff097          	auipc	ra,0xfffff
    80005e32:	8ee080e7          	jalr	-1810(ra) # 8000471c <fileclose>
    fileclose(wf);
    80005e36:	fc843503          	ld	a0,-56(s0)
    80005e3a:	fffff097          	auipc	ra,0xfffff
    80005e3e:	8e2080e7          	jalr	-1822(ra) # 8000471c <fileclose>
    return -1;
    80005e42:	57fd                	li	a5,-1
    80005e44:	a805                	j	80005e74 <sys_pipe+0x102>
    if(fd0 >= 0)
    80005e46:	fc442783          	lw	a5,-60(s0)
    80005e4a:	0007c863          	bltz	a5,80005e5a <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005e4e:	078e                	slli	a5,a5,0x3
    80005e50:	0d078793          	addi	a5,a5,208
    80005e54:	97a6                	add	a5,a5,s1
    80005e56:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005e5a:	fd043503          	ld	a0,-48(s0)
    80005e5e:	fffff097          	auipc	ra,0xfffff
    80005e62:	8be080e7          	jalr	-1858(ra) # 8000471c <fileclose>
    fileclose(wf);
    80005e66:	fc843503          	ld	a0,-56(s0)
    80005e6a:	fffff097          	auipc	ra,0xfffff
    80005e6e:	8b2080e7          	jalr	-1870(ra) # 8000471c <fileclose>
    return -1;
    80005e72:	57fd                	li	a5,-1
}
    80005e74:	853e                	mv	a0,a5
    80005e76:	70e2                	ld	ra,56(sp)
    80005e78:	7442                	ld	s0,48(sp)
    80005e7a:	74a2                	ld	s1,40(sp)
    80005e7c:	6121                	addi	sp,sp,64
    80005e7e:	8082                	ret

0000000080005e80 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005e80:	7111                	addi	sp,sp,-256

        # save the registers.
        sd ra, 0(sp)
    80005e82:	e006                	sd	ra,0(sp)
        sd sp, 8(sp)
    80005e84:	e40a                	sd	sp,8(sp)
        sd gp, 16(sp)
    80005e86:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005e88:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005e8a:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005e8c:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005e8e:	f81e                	sd	t2,48(sp)
        sd s0, 56(sp)
    80005e90:	fc22                	sd	s0,56(sp)
        sd s1, 64(sp)
    80005e92:	e0a6                	sd	s1,64(sp)
        sd a0, 72(sp)
    80005e94:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005e96:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005e98:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005e9a:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005e9c:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005e9e:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005ea0:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005ea2:	e146                	sd	a7,128(sp)
        sd s2, 136(sp)
    80005ea4:	e54a                	sd	s2,136(sp)
        sd s3, 144(sp)
    80005ea6:	e94e                	sd	s3,144(sp)
        sd s4, 152(sp)
    80005ea8:	ed52                	sd	s4,152(sp)
        sd s5, 160(sp)
    80005eaa:	f156                	sd	s5,160(sp)
        sd s6, 168(sp)
    80005eac:	f55a                	sd	s6,168(sp)
        sd s7, 176(sp)
    80005eae:	f95e                	sd	s7,176(sp)
        sd s8, 184(sp)
    80005eb0:	fd62                	sd	s8,184(sp)
        sd s9, 192(sp)
    80005eb2:	e1e6                	sd	s9,192(sp)
        sd s10, 200(sp)
    80005eb4:	e5ea                	sd	s10,200(sp)
        sd s11, 208(sp)
    80005eb6:	e9ee                	sd	s11,208(sp)
        sd t3, 216(sp)
    80005eb8:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005eba:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005ebc:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005ebe:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005ec0:	c4dfc0ef          	jal	80002b0c <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005ec4:	6082                	ld	ra,0(sp)
        ld sp, 8(sp)
    80005ec6:	6122                	ld	sp,8(sp)
        ld gp, 16(sp)
    80005ec8:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005eca:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005ecc:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005ece:	73c2                	ld	t2,48(sp)
        ld s0, 56(sp)
    80005ed0:	7462                	ld	s0,56(sp)
        ld s1, 64(sp)
    80005ed2:	6486                	ld	s1,64(sp)
        ld a0, 72(sp)
    80005ed4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005ed6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005ed8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005eda:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005edc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005ede:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005ee0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005ee2:	688a                	ld	a7,128(sp)
        ld s2, 136(sp)
    80005ee4:	692a                	ld	s2,136(sp)
        ld s3, 144(sp)
    80005ee6:	69ca                	ld	s3,144(sp)
        ld s4, 152(sp)
    80005ee8:	6a6a                	ld	s4,152(sp)
        ld s5, 160(sp)
    80005eea:	7a8a                	ld	s5,160(sp)
        ld s6, 168(sp)
    80005eec:	7b2a                	ld	s6,168(sp)
        ld s7, 176(sp)
    80005eee:	7bca                	ld	s7,176(sp)
        ld s8, 184(sp)
    80005ef0:	7c6a                	ld	s8,184(sp)
        ld s9, 192(sp)
    80005ef2:	6c8e                	ld	s9,192(sp)
        ld s10, 200(sp)
    80005ef4:	6d2e                	ld	s10,200(sp)
        ld s11, 208(sp)
    80005ef6:	6dce                	ld	s11,208(sp)
        ld t3, 216(sp)
    80005ef8:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005efa:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005efc:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005efe:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005f00:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005f02:	10200073          	sret
    80005f06:	00000013          	nop
    80005f0a:	00000013          	nop
    80005f0e:	0001                	nop

0000000080005f10 <timervec>:
        # start.c has set up the memory that mscratch points to:
        # scratch[0,8,16] : register save area.
        # scratch[24] : address of CLINT's MTIMECMP register.
        # scratch[32] : desired interval between interrupts.
        
        csrrw a0, mscratch, a0
    80005f10:	34051573          	csrrw	a0,mscratch,a0
        sd a1, 0(a0)
    80005f14:	e10c                	sd	a1,0(a0)
        sd a2, 8(a0)
    80005f16:	e510                	sd	a2,8(a0)
        sd a3, 16(a0)
    80005f18:	e914                	sd	a3,16(a0)

        # schedule the next timer interrupt
        # by adding interval to mtimecmp.
        ld a1, 24(a0) # CLINT_MTIMECMP(hart)
    80005f1a:	6d0c                	ld	a1,24(a0)
        ld a2, 32(a0) # interval
    80005f1c:	7110                	ld	a2,32(a0)
        ld a3, 0(a1)
    80005f1e:	6194                	ld	a3,0(a1)
        add a3, a3, a2
    80005f20:	96b2                	add	a3,a3,a2
        sd a3, 0(a1)
    80005f22:	e194                	sd	a3,0(a1)

        # arrange for a supervisor software interrupt
        # after this handler returns.
        li a1, 2
    80005f24:	4589                	li	a1,2
        csrw sip, a1
    80005f26:	14459073          	csrw	sip,a1

        ld a3, 16(a0)
    80005f2a:	6914                	ld	a3,16(a0)
        ld a2, 8(a0)
    80005f2c:	6510                	ld	a2,8(a0)
        ld a1, 0(a0)
    80005f2e:	610c                	ld	a1,0(a0)
        csrrw a0, mscratch, a0
    80005f30:	34051573          	csrrw	a0,mscratch,a0

        mret
    80005f34:	30200073          	mret
    80005f38:	0001                	nop

0000000080005f3a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f3a:	1141                	addi	sp,sp,-16
    80005f3c:	e406                	sd	ra,8(sp)
    80005f3e:	e022                	sd	s0,0(sp)
    80005f40:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f42:	0c000737          	lui	a4,0xc000
    80005f46:	4785                	li	a5,1
    80005f48:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f4a:	c35c                	sw	a5,4(a4)
}
    80005f4c:	60a2                	ld	ra,8(sp)
    80005f4e:	6402                	ld	s0,0(sp)
    80005f50:	0141                	addi	sp,sp,16
    80005f52:	8082                	ret

0000000080005f54 <plicinithart>:

void
plicinithart(void)
{
    80005f54:	1141                	addi	sp,sp,-16
    80005f56:	e406                	sd	ra,8(sp)
    80005f58:	e022                	sd	s0,0(sp)
    80005f5a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f5c:	ffffc097          	auipc	ra,0xffffc
    80005f60:	c24080e7          	jalr	-988(ra) # 80001b80 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f64:	0085171b          	slliw	a4,a0,0x8
    80005f68:	0c0027b7          	lui	a5,0xc002
    80005f6c:	97ba                	add	a5,a5,a4
    80005f6e:	40200713          	li	a4,1026
    80005f72:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f76:	00d5151b          	slliw	a0,a0,0xd
    80005f7a:	0c2017b7          	lui	a5,0xc201
    80005f7e:	97aa                	add	a5,a5,a0
    80005f80:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005f84:	60a2                	ld	ra,8(sp)
    80005f86:	6402                	ld	s0,0(sp)
    80005f88:	0141                	addi	sp,sp,16
    80005f8a:	8082                	ret

0000000080005f8c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f8c:	1141                	addi	sp,sp,-16
    80005f8e:	e406                	sd	ra,8(sp)
    80005f90:	e022                	sd	s0,0(sp)
    80005f92:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f94:	ffffc097          	auipc	ra,0xffffc
    80005f98:	bec080e7          	jalr	-1044(ra) # 80001b80 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f9c:	00d5151b          	slliw	a0,a0,0xd
    80005fa0:	0c2017b7          	lui	a5,0xc201
    80005fa4:	97aa                	add	a5,a5,a0
  return irq;
}
    80005fa6:	43c8                	lw	a0,4(a5)
    80005fa8:	60a2                	ld	ra,8(sp)
    80005faa:	6402                	ld	s0,0(sp)
    80005fac:	0141                	addi	sp,sp,16
    80005fae:	8082                	ret

0000000080005fb0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005fb0:	1101                	addi	sp,sp,-32
    80005fb2:	ec06                	sd	ra,24(sp)
    80005fb4:	e822                	sd	s0,16(sp)
    80005fb6:	e426                	sd	s1,8(sp)
    80005fb8:	1000                	addi	s0,sp,32
    80005fba:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fbc:	ffffc097          	auipc	ra,0xffffc
    80005fc0:	bc4080e7          	jalr	-1084(ra) # 80001b80 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fc4:	00d5179b          	slliw	a5,a0,0xd
    80005fc8:	0c201737          	lui	a4,0xc201
    80005fcc:	97ba                	add	a5,a5,a4
    80005fce:	c3c4                	sw	s1,4(a5)
}
    80005fd0:	60e2                	ld	ra,24(sp)
    80005fd2:	6442                	ld	s0,16(sp)
    80005fd4:	64a2                	ld	s1,8(sp)
    80005fd6:	6105                	addi	sp,sp,32
    80005fd8:	8082                	ret

0000000080005fda <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005fda:	1141                	addi	sp,sp,-16
    80005fdc:	e406                	sd	ra,8(sp)
    80005fde:	e022                	sd	s0,0(sp)
    80005fe0:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005fe2:	479d                	li	a5,7
    80005fe4:	04a7cc63          	blt	a5,a0,8000603c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005fe8:	0001c797          	auipc	a5,0x1c
    80005fec:	cb878793          	addi	a5,a5,-840 # 80021ca0 <disk>
    80005ff0:	97aa                	add	a5,a5,a0
    80005ff2:	0187c783          	lbu	a5,24(a5)
    80005ff6:	ebb9                	bnez	a5,8000604c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005ff8:	00451693          	slli	a3,a0,0x4
    80005ffc:	0001c797          	auipc	a5,0x1c
    80006000:	ca478793          	addi	a5,a5,-860 # 80021ca0 <disk>
    80006004:	6398                	ld	a4,0(a5)
    80006006:	9736                	add	a4,a4,a3
    80006008:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    8000600c:	6398                	ld	a4,0(a5)
    8000600e:	9736                	add	a4,a4,a3
    80006010:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006014:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006018:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000601c:	97aa                	add	a5,a5,a0
    8000601e:	4705                	li	a4,1
    80006020:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006024:	0001c517          	auipc	a0,0x1c
    80006028:	c9450513          	addi	a0,a0,-876 # 80021cb8 <disk+0x18>
    8000602c:	ffffc097          	auipc	ra,0xffffc
    80006030:	29a080e7          	jalr	666(ra) # 800022c6 <wakeup>
}
    80006034:	60a2                	ld	ra,8(sp)
    80006036:	6402                	ld	s0,0(sp)
    80006038:	0141                	addi	sp,sp,16
    8000603a:	8082                	ret
    panic("free_desc 1");
    8000603c:	00002517          	auipc	a0,0x2
    80006040:	68450513          	addi	a0,a0,1668 # 800086c0 <etext+0x6c0>
    80006044:	ffffa097          	auipc	ra,0xffffa
    80006048:	51a080e7          	jalr	1306(ra) # 8000055e <panic>
    panic("free_desc 2");
    8000604c:	00002517          	auipc	a0,0x2
    80006050:	68450513          	addi	a0,a0,1668 # 800086d0 <etext+0x6d0>
    80006054:	ffffa097          	auipc	ra,0xffffa
    80006058:	50a080e7          	jalr	1290(ra) # 8000055e <panic>

000000008000605c <virtio_disk_init>:
{
    8000605c:	1101                	addi	sp,sp,-32
    8000605e:	ec06                	sd	ra,24(sp)
    80006060:	e822                	sd	s0,16(sp)
    80006062:	e426                	sd	s1,8(sp)
    80006064:	e04a                	sd	s2,0(sp)
    80006066:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006068:	00002597          	auipc	a1,0x2
    8000606c:	67858593          	addi	a1,a1,1656 # 800086e0 <etext+0x6e0>
    80006070:	0001c517          	auipc	a0,0x1c
    80006074:	d5850513          	addi	a0,a0,-680 # 80021dc8 <disk+0x128>
    80006078:	ffffb097          	auipc	ra,0xffffb
    8000607c:	b4a080e7          	jalr	-1206(ra) # 80000bc2 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006080:	100017b7          	lui	a5,0x10001
    80006084:	4398                	lw	a4,0(a5)
    80006086:	2701                	sext.w	a4,a4
    80006088:	747277b7          	lui	a5,0x74727
    8000608c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006090:	16f71463          	bne	a4,a5,800061f8 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006094:	100017b7          	lui	a5,0x10001
    80006098:	43dc                	lw	a5,4(a5)
    8000609a:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000609c:	4709                	li	a4,2
    8000609e:	14e79d63          	bne	a5,a4,800061f8 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060a2:	100017b7          	lui	a5,0x10001
    800060a6:	479c                	lw	a5,8(a5)
    800060a8:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060aa:	14e79763          	bne	a5,a4,800061f8 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060ae:	100017b7          	lui	a5,0x10001
    800060b2:	47d8                	lw	a4,12(a5)
    800060b4:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060b6:	554d47b7          	lui	a5,0x554d4
    800060ba:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060be:	12f71d63          	bne	a4,a5,800061f8 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060c2:	100017b7          	lui	a5,0x10001
    800060c6:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ca:	4705                	li	a4,1
    800060cc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ce:	470d                	li	a4,3
    800060d0:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060d2:	10001737          	lui	a4,0x10001
    800060d6:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800060d8:	c7ffe6b7          	lui	a3,0xc7ffe
    800060dc:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc97f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060e0:	8f75                	and	a4,a4,a3
    800060e2:	100016b7          	lui	a3,0x10001
    800060e6:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060e8:	472d                	li	a4,11
    800060ea:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ec:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800060f0:	439c                	lw	a5,0(a5)
    800060f2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800060f6:	8ba1                	andi	a5,a5,8
    800060f8:	10078863          	beqz	a5,80006208 <virtio_disk_init+0x1ac>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060fc:	100017b7          	lui	a5,0x10001
    80006100:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006104:	43fc                	lw	a5,68(a5)
    80006106:	2781                	sext.w	a5,a5
    80006108:	10079863          	bnez	a5,80006218 <virtio_disk_init+0x1bc>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000610c:	100017b7          	lui	a5,0x10001
    80006110:	5bdc                	lw	a5,52(a5)
    80006112:	2781                	sext.w	a5,a5
  if(max == 0)
    80006114:	10078a63          	beqz	a5,80006228 <virtio_disk_init+0x1cc>
  if(max < NUM)
    80006118:	471d                	li	a4,7
    8000611a:	10f77f63          	bgeu	a4,a5,80006238 <virtio_disk_init+0x1dc>
  disk.desc = kalloc();
    8000611e:	ffffb097          	auipc	ra,0xffffb
    80006122:	a3a080e7          	jalr	-1478(ra) # 80000b58 <kalloc>
    80006126:	0001c497          	auipc	s1,0x1c
    8000612a:	b7a48493          	addi	s1,s1,-1158 # 80021ca0 <disk>
    8000612e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006130:	ffffb097          	auipc	ra,0xffffb
    80006134:	a28080e7          	jalr	-1496(ra) # 80000b58 <kalloc>
    80006138:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000613a:	ffffb097          	auipc	ra,0xffffb
    8000613e:	a1e080e7          	jalr	-1506(ra) # 80000b58 <kalloc>
    80006142:	87aa                	mv	a5,a0
    80006144:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006146:	6088                	ld	a0,0(s1)
    80006148:	10050063          	beqz	a0,80006248 <virtio_disk_init+0x1ec>
    8000614c:	0001c717          	auipc	a4,0x1c
    80006150:	b5c73703          	ld	a4,-1188(a4) # 80021ca8 <disk+0x8>
    80006154:	cb75                	beqz	a4,80006248 <virtio_disk_init+0x1ec>
    80006156:	cbed                	beqz	a5,80006248 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80006158:	6605                	lui	a2,0x1
    8000615a:	4581                	li	a1,0
    8000615c:	ffffb097          	auipc	ra,0xffffb
    80006160:	bf8080e7          	jalr	-1032(ra) # 80000d54 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006164:	0001c497          	auipc	s1,0x1c
    80006168:	b3c48493          	addi	s1,s1,-1220 # 80021ca0 <disk>
    8000616c:	6605                	lui	a2,0x1
    8000616e:	4581                	li	a1,0
    80006170:	6488                	ld	a0,8(s1)
    80006172:	ffffb097          	auipc	ra,0xffffb
    80006176:	be2080e7          	jalr	-1054(ra) # 80000d54 <memset>
  memset(disk.used, 0, PGSIZE);
    8000617a:	6605                	lui	a2,0x1
    8000617c:	4581                	li	a1,0
    8000617e:	6888                	ld	a0,16(s1)
    80006180:	ffffb097          	auipc	ra,0xffffb
    80006184:	bd4080e7          	jalr	-1068(ra) # 80000d54 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006188:	100017b7          	lui	a5,0x10001
    8000618c:	4721                	li	a4,8
    8000618e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006190:	4098                	lw	a4,0(s1)
    80006192:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006196:	40d8                	lw	a4,4(s1)
    80006198:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000619c:	649c                	ld	a5,8(s1)
    8000619e:	0007869b          	sext.w	a3,a5
    800061a2:	10001737          	lui	a4,0x10001
    800061a6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800061aa:	9781                	srai	a5,a5,0x20
    800061ac:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800061b0:	689c                	ld	a5,16(s1)
    800061b2:	0007869b          	sext.w	a3,a5
    800061b6:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800061ba:	9781                	srai	a5,a5,0x20
    800061bc:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800061c0:	4785                	li	a5,1
    800061c2:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800061c4:	00f48c23          	sb	a5,24(s1)
    800061c8:	00f48ca3          	sb	a5,25(s1)
    800061cc:	00f48d23          	sb	a5,26(s1)
    800061d0:	00f48da3          	sb	a5,27(s1)
    800061d4:	00f48e23          	sb	a5,28(s1)
    800061d8:	00f48ea3          	sb	a5,29(s1)
    800061dc:	00f48f23          	sb	a5,30(s1)
    800061e0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800061e4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800061e8:	07272823          	sw	s2,112(a4)
}
    800061ec:	60e2                	ld	ra,24(sp)
    800061ee:	6442                	ld	s0,16(sp)
    800061f0:	64a2                	ld	s1,8(sp)
    800061f2:	6902                	ld	s2,0(sp)
    800061f4:	6105                	addi	sp,sp,32
    800061f6:	8082                	ret
    panic("could not find virtio disk");
    800061f8:	00002517          	auipc	a0,0x2
    800061fc:	4f850513          	addi	a0,a0,1272 # 800086f0 <etext+0x6f0>
    80006200:	ffffa097          	auipc	ra,0xffffa
    80006204:	35e080e7          	jalr	862(ra) # 8000055e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006208:	00002517          	auipc	a0,0x2
    8000620c:	50850513          	addi	a0,a0,1288 # 80008710 <etext+0x710>
    80006210:	ffffa097          	auipc	ra,0xffffa
    80006214:	34e080e7          	jalr	846(ra) # 8000055e <panic>
    panic("virtio disk should not be ready");
    80006218:	00002517          	auipc	a0,0x2
    8000621c:	51850513          	addi	a0,a0,1304 # 80008730 <etext+0x730>
    80006220:	ffffa097          	auipc	ra,0xffffa
    80006224:	33e080e7          	jalr	830(ra) # 8000055e <panic>
    panic("virtio disk has no queue 0");
    80006228:	00002517          	auipc	a0,0x2
    8000622c:	52850513          	addi	a0,a0,1320 # 80008750 <etext+0x750>
    80006230:	ffffa097          	auipc	ra,0xffffa
    80006234:	32e080e7          	jalr	814(ra) # 8000055e <panic>
    panic("virtio disk max queue too short");
    80006238:	00002517          	auipc	a0,0x2
    8000623c:	53850513          	addi	a0,a0,1336 # 80008770 <etext+0x770>
    80006240:	ffffa097          	auipc	ra,0xffffa
    80006244:	31e080e7          	jalr	798(ra) # 8000055e <panic>
    panic("virtio disk kalloc");
    80006248:	00002517          	auipc	a0,0x2
    8000624c:	54850513          	addi	a0,a0,1352 # 80008790 <etext+0x790>
    80006250:	ffffa097          	auipc	ra,0xffffa
    80006254:	30e080e7          	jalr	782(ra) # 8000055e <panic>

0000000080006258 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006258:	711d                	addi	sp,sp,-96
    8000625a:	ec86                	sd	ra,88(sp)
    8000625c:	e8a2                	sd	s0,80(sp)
    8000625e:	e4a6                	sd	s1,72(sp)
    80006260:	e0ca                	sd	s2,64(sp)
    80006262:	fc4e                	sd	s3,56(sp)
    80006264:	f852                	sd	s4,48(sp)
    80006266:	f456                	sd	s5,40(sp)
    80006268:	f05a                	sd	s6,32(sp)
    8000626a:	ec5e                	sd	s7,24(sp)
    8000626c:	e862                	sd	s8,16(sp)
    8000626e:	1080                	addi	s0,sp,96
    80006270:	89aa                	mv	s3,a0
    80006272:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006274:	00c52b83          	lw	s7,12(a0)
    80006278:	001b9b9b          	slliw	s7,s7,0x1
    8000627c:	1b82                	slli	s7,s7,0x20
    8000627e:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80006282:	0001c517          	auipc	a0,0x1c
    80006286:	b4650513          	addi	a0,a0,-1210 # 80021dc8 <disk+0x128>
    8000628a:	ffffb097          	auipc	ra,0xffffb
    8000628e:	9d2080e7          	jalr	-1582(ra) # 80000c5c <acquire>
  for(int i = 0; i < NUM; i++){
    80006292:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006294:	0001ca97          	auipc	s5,0x1c
    80006298:	a0ca8a93          	addi	s5,s5,-1524 # 80021ca0 <disk>
  for(int i = 0; i < 3; i++){
    8000629c:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    8000629e:	5c7d                	li	s8,-1
    800062a0:	a885                	j	80006310 <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800062a2:	00fa8733          	add	a4,s5,a5
    800062a6:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800062aa:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800062ac:	0207c563          	bltz	a5,800062d6 <virtio_disk_rw+0x7e>
  for(int i = 0; i < 3; i++){
    800062b0:	2905                	addiw	s2,s2,1
    800062b2:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800062b4:	07490263          	beq	s2,s4,80006318 <virtio_disk_rw+0xc0>
    idx[i] = alloc_desc();
    800062b8:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800062ba:	0001c717          	auipc	a4,0x1c
    800062be:	9e670713          	addi	a4,a4,-1562 # 80021ca0 <disk>
    800062c2:	4781                	li	a5,0
    if(disk.free[i]){
    800062c4:	01874683          	lbu	a3,24(a4)
    800062c8:	fee9                	bnez	a3,800062a2 <virtio_disk_rw+0x4a>
  for(int i = 0; i < NUM; i++){
    800062ca:	2785                	addiw	a5,a5,1
    800062cc:	0705                	addi	a4,a4,1
    800062ce:	fe979be3          	bne	a5,s1,800062c4 <virtio_disk_rw+0x6c>
    idx[i] = alloc_desc();
    800062d2:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    800062d6:	03205163          	blez	s2,800062f8 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    800062da:	fa042503          	lw	a0,-96(s0)
    800062de:	00000097          	auipc	ra,0x0
    800062e2:	cfc080e7          	jalr	-772(ra) # 80005fda <free_desc>
      for(int j = 0; j < i; j++)
    800062e6:	4785                	li	a5,1
    800062e8:	0127d863          	bge	a5,s2,800062f8 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    800062ec:	fa442503          	lw	a0,-92(s0)
    800062f0:	00000097          	auipc	ra,0x0
    800062f4:	cea080e7          	jalr	-790(ra) # 80005fda <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062f8:	0001c597          	auipc	a1,0x1c
    800062fc:	ad058593          	addi	a1,a1,-1328 # 80021dc8 <disk+0x128>
    80006300:	0001c517          	auipc	a0,0x1c
    80006304:	9b850513          	addi	a0,a0,-1608 # 80021cb8 <disk+0x18>
    80006308:	ffffc097          	auipc	ra,0xffffc
    8000630c:	f5a080e7          	jalr	-166(ra) # 80002262 <sleep>
  for(int i = 0; i < 3; i++){
    80006310:	fa040613          	addi	a2,s0,-96
    80006314:	4901                	li	s2,0
    80006316:	b74d                	j	800062b8 <virtio_disk_rw+0x60>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006318:	fa042503          	lw	a0,-96(s0)
    8000631c:	00451693          	slli	a3,a0,0x4

  if(write)
    80006320:	0001c797          	auipc	a5,0x1c
    80006324:	98078793          	addi	a5,a5,-1664 # 80021ca0 <disk>
    80006328:	00451713          	slli	a4,a0,0x4
    8000632c:	0a070713          	addi	a4,a4,160
    80006330:	973e                	add	a4,a4,a5
    80006332:	01603633          	snez	a2,s6
    80006336:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006338:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000633c:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006340:	6398                	ld	a4,0(a5)
    80006342:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006344:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80006348:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000634a:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000634c:	6390                	ld	a2,0(a5)
    8000634e:	00d60833          	add	a6,a2,a3
    80006352:	4741                	li	a4,16
    80006354:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006358:	4585                	li	a1,1
    8000635a:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    8000635e:	fa442703          	lw	a4,-92(s0)
    80006362:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006366:	0712                	slli	a4,a4,0x4
    80006368:	963a                	add	a2,a2,a4
    8000636a:	05898813          	addi	a6,s3,88
    8000636e:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006372:	0007b883          	ld	a7,0(a5)
    80006376:	9746                	add	a4,a4,a7
    80006378:	40000613          	li	a2,1024
    8000637c:	c710                	sw	a2,8(a4)
  if(write)
    8000637e:	001b3613          	seqz	a2,s6
    80006382:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006386:	8e4d                	or	a2,a2,a1
    80006388:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000638c:	fa842603          	lw	a2,-88(s0)
    80006390:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006394:	00451813          	slli	a6,a0,0x4
    80006398:	02080813          	addi	a6,a6,32
    8000639c:	983e                	add	a6,a6,a5
    8000639e:	577d                	li	a4,-1
    800063a0:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800063a4:	0612                	slli	a2,a2,0x4
    800063a6:	98b2                	add	a7,a7,a2
    800063a8:	03068713          	addi	a4,a3,48
    800063ac:	973e                	add	a4,a4,a5
    800063ae:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800063b2:	6398                	ld	a4,0(a5)
    800063b4:	9732                	add	a4,a4,a2
    800063b6:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063b8:	4689                	li	a3,2
    800063ba:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800063be:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800063c2:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    800063c6:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800063ca:	6794                	ld	a3,8(a5)
    800063cc:	0026d703          	lhu	a4,2(a3)
    800063d0:	8b1d                	andi	a4,a4,7
    800063d2:	0706                	slli	a4,a4,0x1
    800063d4:	96ba                	add	a3,a3,a4
    800063d6:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800063da:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800063de:	6798                	ld	a4,8(a5)
    800063e0:	00275783          	lhu	a5,2(a4)
    800063e4:	2785                	addiw	a5,a5,1
    800063e6:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800063ea:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063ee:	100017b7          	lui	a5,0x10001
    800063f2:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800063f6:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    800063fa:	0001c917          	auipc	s2,0x1c
    800063fe:	9ce90913          	addi	s2,s2,-1586 # 80021dc8 <disk+0x128>
  while(b->disk == 1) {
    80006402:	84ae                	mv	s1,a1
    80006404:	00b79c63          	bne	a5,a1,8000641c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006408:	85ca                	mv	a1,s2
    8000640a:	854e                	mv	a0,s3
    8000640c:	ffffc097          	auipc	ra,0xffffc
    80006410:	e56080e7          	jalr	-426(ra) # 80002262 <sleep>
  while(b->disk == 1) {
    80006414:	0049a783          	lw	a5,4(s3)
    80006418:	fe9788e3          	beq	a5,s1,80006408 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000641c:	fa042903          	lw	s2,-96(s0)
    80006420:	00491713          	slli	a4,s2,0x4
    80006424:	02070713          	addi	a4,a4,32
    80006428:	0001c797          	auipc	a5,0x1c
    8000642c:	87878793          	addi	a5,a5,-1928 # 80021ca0 <disk>
    80006430:	97ba                	add	a5,a5,a4
    80006432:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006436:	0001c997          	auipc	s3,0x1c
    8000643a:	86a98993          	addi	s3,s3,-1942 # 80021ca0 <disk>
    8000643e:	00491713          	slli	a4,s2,0x4
    80006442:	0009b783          	ld	a5,0(s3)
    80006446:	97ba                	add	a5,a5,a4
    80006448:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000644c:	854a                	mv	a0,s2
    8000644e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006452:	00000097          	auipc	ra,0x0
    80006456:	b88080e7          	jalr	-1144(ra) # 80005fda <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000645a:	8885                	andi	s1,s1,1
    8000645c:	f0ed                	bnez	s1,8000643e <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000645e:	0001c517          	auipc	a0,0x1c
    80006462:	96a50513          	addi	a0,a0,-1686 # 80021dc8 <disk+0x128>
    80006466:	ffffb097          	auipc	ra,0xffffb
    8000646a:	8a6080e7          	jalr	-1882(ra) # 80000d0c <release>
}
    8000646e:	60e6                	ld	ra,88(sp)
    80006470:	6446                	ld	s0,80(sp)
    80006472:	64a6                	ld	s1,72(sp)
    80006474:	6906                	ld	s2,64(sp)
    80006476:	79e2                	ld	s3,56(sp)
    80006478:	7a42                	ld	s4,48(sp)
    8000647a:	7aa2                	ld	s5,40(sp)
    8000647c:	7b02                	ld	s6,32(sp)
    8000647e:	6be2                	ld	s7,24(sp)
    80006480:	6c42                	ld	s8,16(sp)
    80006482:	6125                	addi	sp,sp,96
    80006484:	8082                	ret

0000000080006486 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006486:	1101                	addi	sp,sp,-32
    80006488:	ec06                	sd	ra,24(sp)
    8000648a:	e822                	sd	s0,16(sp)
    8000648c:	e426                	sd	s1,8(sp)
    8000648e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006490:	0001c497          	auipc	s1,0x1c
    80006494:	81048493          	addi	s1,s1,-2032 # 80021ca0 <disk>
    80006498:	0001c517          	auipc	a0,0x1c
    8000649c:	93050513          	addi	a0,a0,-1744 # 80021dc8 <disk+0x128>
    800064a0:	ffffa097          	auipc	ra,0xffffa
    800064a4:	7bc080e7          	jalr	1980(ra) # 80000c5c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800064a8:	100017b7          	lui	a5,0x10001
    800064ac:	53bc                	lw	a5,96(a5)
    800064ae:	8b8d                	andi	a5,a5,3
    800064b0:	10001737          	lui	a4,0x10001
    800064b4:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800064b6:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800064ba:	689c                	ld	a5,16(s1)
    800064bc:	0204d703          	lhu	a4,32(s1)
    800064c0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800064c4:	04f70a63          	beq	a4,a5,80006518 <virtio_disk_intr+0x92>
    __sync_synchronize();
    800064c8:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800064cc:	6898                	ld	a4,16(s1)
    800064ce:	0204d783          	lhu	a5,32(s1)
    800064d2:	8b9d                	andi	a5,a5,7
    800064d4:	078e                	slli	a5,a5,0x3
    800064d6:	97ba                	add	a5,a5,a4
    800064d8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800064da:	00479713          	slli	a4,a5,0x4
    800064de:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    800064e2:	9726                	add	a4,a4,s1
    800064e4:	01074703          	lbu	a4,16(a4)
    800064e8:	e729                	bnez	a4,80006532 <virtio_disk_intr+0xac>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800064ea:	0792                	slli	a5,a5,0x4
    800064ec:	02078793          	addi	a5,a5,32
    800064f0:	97a6                	add	a5,a5,s1
    800064f2:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800064f4:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800064f8:	ffffc097          	auipc	ra,0xffffc
    800064fc:	dce080e7          	jalr	-562(ra) # 800022c6 <wakeup>

    disk.used_idx += 1;
    80006500:	0204d783          	lhu	a5,32(s1)
    80006504:	2785                	addiw	a5,a5,1
    80006506:	17c2                	slli	a5,a5,0x30
    80006508:	93c1                	srli	a5,a5,0x30
    8000650a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000650e:	6898                	ld	a4,16(s1)
    80006510:	00275703          	lhu	a4,2(a4)
    80006514:	faf71ae3          	bne	a4,a5,800064c8 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006518:	0001c517          	auipc	a0,0x1c
    8000651c:	8b050513          	addi	a0,a0,-1872 # 80021dc8 <disk+0x128>
    80006520:	ffffa097          	auipc	ra,0xffffa
    80006524:	7ec080e7          	jalr	2028(ra) # 80000d0c <release>
}
    80006528:	60e2                	ld	ra,24(sp)
    8000652a:	6442                	ld	s0,16(sp)
    8000652c:	64a2                	ld	s1,8(sp)
    8000652e:	6105                	addi	sp,sp,32
    80006530:	8082                	ret
      panic("virtio_disk_intr status");
    80006532:	00002517          	auipc	a0,0x2
    80006536:	27650513          	addi	a0,a0,630 # 800087a8 <etext+0x7a8>
    8000653a:	ffffa097          	auipc	ra,0xffffa
    8000653e:	024080e7          	jalr	36(ra) # 8000055e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
