
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	00000097          	auipc	ra,0x0
   c:	2c2080e7          	jalr	706(ra) # 2ca <fork>
  10:	00a04763          	bgtz	a0,1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  exit(0);
  14:	4501                	li	a0,0
  16:	00000097          	auipc	ra,0x0
  1a:	2bc080e7          	jalr	700(ra) # 2d2 <exit>
    sleep(5);  // Let child exit before parent.
  1e:	4515                	li	a0,5
  20:	00000097          	auipc	ra,0x0
  24:	342080e7          	jalr	834(ra) # 362 <sleep>
  28:	b7f5                	j	14 <main+0x14>

000000000000002a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e406                	sd	ra,8(sp)
  2e:	e022                	sd	s0,0(sp)
  30:	0800                	addi	s0,sp,16
  extern int main();
  main();
  32:	00000097          	auipc	ra,0x0
  36:	fce080e7          	jalr	-50(ra) # 0 <main>
  exit(0);
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	296080e7          	jalr	662(ra) # 2d2 <exit>

0000000000000044 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  44:	1141                	addi	sp,sp,-16
  46:	e406                	sd	ra,8(sp)
  48:	e022                	sd	s0,0(sp)
  4a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  4c:	87aa                	mv	a5,a0
  4e:	0585                	addi	a1,a1,1
  50:	0785                	addi	a5,a5,1
  52:	fff5c703          	lbu	a4,-1(a1)
  56:	fee78fa3          	sb	a4,-1(a5)
  5a:	fb75                	bnez	a4,4e <strcpy+0xa>
    ;
  return os;
}
  5c:	60a2                	ld	ra,8(sp)
  5e:	6402                	ld	s0,0(sp)
  60:	0141                	addi	sp,sp,16
  62:	8082                	ret

0000000000000064 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  64:	1141                	addi	sp,sp,-16
  66:	e406                	sd	ra,8(sp)
  68:	e022                	sd	s0,0(sp)
  6a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  6c:	00054783          	lbu	a5,0(a0)
  70:	cb91                	beqz	a5,84 <strcmp+0x20>
  72:	0005c703          	lbu	a4,0(a1)
  76:	00f71763          	bne	a4,a5,84 <strcmp+0x20>
    p++, q++;
  7a:	0505                	addi	a0,a0,1
  7c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  7e:	00054783          	lbu	a5,0(a0)
  82:	fbe5                	bnez	a5,72 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  84:	0005c503          	lbu	a0,0(a1)
}
  88:	40a7853b          	subw	a0,a5,a0
  8c:	60a2                	ld	ra,8(sp)
  8e:	6402                	ld	s0,0(sp)
  90:	0141                	addi	sp,sp,16
  92:	8082                	ret

0000000000000094 <strlen>:

uint
strlen(const char *s)
{
  94:	1141                	addi	sp,sp,-16
  96:	e406                	sd	ra,8(sp)
  98:	e022                	sd	s0,0(sp)
  9a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  9c:	00054783          	lbu	a5,0(a0)
  a0:	cf91                	beqz	a5,bc <strlen+0x28>
  a2:	00150793          	addi	a5,a0,1
  a6:	86be                	mv	a3,a5
  a8:	0785                	addi	a5,a5,1
  aa:	fff7c703          	lbu	a4,-1(a5)
  ae:	ff65                	bnez	a4,a6 <strlen+0x12>
  b0:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  b4:	60a2                	ld	ra,8(sp)
  b6:	6402                	ld	s0,0(sp)
  b8:	0141                	addi	sp,sp,16
  ba:	8082                	ret
  for(n = 0; s[n]; n++)
  bc:	4501                	li	a0,0
  be:	bfdd                	j	b4 <strlen+0x20>

00000000000000c0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e406                	sd	ra,8(sp)
  c4:	e022                	sd	s0,0(sp)
  c6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  c8:	ca19                	beqz	a2,de <memset+0x1e>
  ca:	87aa                	mv	a5,a0
  cc:	1602                	slli	a2,a2,0x20
  ce:	9201                	srli	a2,a2,0x20
  d0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  d4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  d8:	0785                	addi	a5,a5,1
  da:	fee79de3          	bne	a5,a4,d4 <memset+0x14>
  }
  return dst;
}
  de:	60a2                	ld	ra,8(sp)
  e0:	6402                	ld	s0,0(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret

00000000000000e6 <strchr>:

char*
strchr(const char *s, char c)
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e406                	sd	ra,8(sp)
  ea:	e022                	sd	s0,0(sp)
  ec:	0800                	addi	s0,sp,16
  for(; *s; s++)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	cf81                	beqz	a5,10a <strchr+0x24>
    if(*s == c)
  f4:	00f58763          	beq	a1,a5,102 <strchr+0x1c>
  for(; *s; s++)
  f8:	0505                	addi	a0,a0,1
  fa:	00054783          	lbu	a5,0(a0)
  fe:	fbfd                	bnez	a5,f4 <strchr+0xe>
      return (char*)s;
  return 0;
 100:	4501                	li	a0,0
}
 102:	60a2                	ld	ra,8(sp)
 104:	6402                	ld	s0,0(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret
  return 0;
 10a:	4501                	li	a0,0
 10c:	bfdd                	j	102 <strchr+0x1c>

000000000000010e <gets>:

char*
gets(char *buf, int max)
{
 10e:	711d                	addi	sp,sp,-96
 110:	ec86                	sd	ra,88(sp)
 112:	e8a2                	sd	s0,80(sp)
 114:	e4a6                	sd	s1,72(sp)
 116:	e0ca                	sd	s2,64(sp)
 118:	fc4e                	sd	s3,56(sp)
 11a:	f852                	sd	s4,48(sp)
 11c:	f456                	sd	s5,40(sp)
 11e:	f05a                	sd	s6,32(sp)
 120:	ec5e                	sd	s7,24(sp)
 122:	e862                	sd	s8,16(sp)
 124:	1080                	addi	s0,sp,96
 126:	8baa                	mv	s7,a0
 128:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 12a:	892a                	mv	s2,a0
 12c:	4481                	li	s1,0
    cc = read(0, &c, 1);
 12e:	faf40b13          	addi	s6,s0,-81
 132:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 134:	8c26                	mv	s8,s1
 136:	0014899b          	addiw	s3,s1,1
 13a:	84ce                	mv	s1,s3
 13c:	0349d663          	bge	s3,s4,168 <gets+0x5a>
    cc = read(0, &c, 1);
 140:	8656                	mv	a2,s5
 142:	85da                	mv	a1,s6
 144:	4501                	li	a0,0
 146:	00000097          	auipc	ra,0x0
 14a:	1a4080e7          	jalr	420(ra) # 2ea <read>
    if(cc < 1)
 14e:	00a05d63          	blez	a0,168 <gets+0x5a>
      break;
    buf[i++] = c;
 152:	faf44783          	lbu	a5,-81(s0)
 156:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 15a:	0905                	addi	s2,s2,1
 15c:	ff678713          	addi	a4,a5,-10
 160:	c319                	beqz	a4,166 <gets+0x58>
 162:	17cd                	addi	a5,a5,-13
 164:	fbe1                	bnez	a5,134 <gets+0x26>
    buf[i++] = c;
 166:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 168:	9c5e                	add	s8,s8,s7
 16a:	000c0023          	sb	zero,0(s8)
  return buf;
}
 16e:	855e                	mv	a0,s7
 170:	60e6                	ld	ra,88(sp)
 172:	6446                	ld	s0,80(sp)
 174:	64a6                	ld	s1,72(sp)
 176:	6906                	ld	s2,64(sp)
 178:	79e2                	ld	s3,56(sp)
 17a:	7a42                	ld	s4,48(sp)
 17c:	7aa2                	ld	s5,40(sp)
 17e:	7b02                	ld	s6,32(sp)
 180:	6be2                	ld	s7,24(sp)
 182:	6c42                	ld	s8,16(sp)
 184:	6125                	addi	sp,sp,96
 186:	8082                	ret

0000000000000188 <stat>:

int
stat(const char *n, struct stat *st)
{
 188:	1101                	addi	sp,sp,-32
 18a:	ec06                	sd	ra,24(sp)
 18c:	e822                	sd	s0,16(sp)
 18e:	e04a                	sd	s2,0(sp)
 190:	1000                	addi	s0,sp,32
 192:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 194:	4581                	li	a1,0
 196:	00000097          	auipc	ra,0x0
 19a:	17c080e7          	jalr	380(ra) # 312 <open>
  if(fd < 0)
 19e:	02054663          	bltz	a0,1ca <stat+0x42>
 1a2:	e426                	sd	s1,8(sp)
 1a4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a6:	85ca                	mv	a1,s2
 1a8:	00000097          	auipc	ra,0x0
 1ac:	182080e7          	jalr	386(ra) # 32a <fstat>
 1b0:	892a                	mv	s2,a0
  close(fd);
 1b2:	8526                	mv	a0,s1
 1b4:	00000097          	auipc	ra,0x0
 1b8:	146080e7          	jalr	326(ra) # 2fa <close>
  return r;
 1bc:	64a2                	ld	s1,8(sp)
}
 1be:	854a                	mv	a0,s2
 1c0:	60e2                	ld	ra,24(sp)
 1c2:	6442                	ld	s0,16(sp)
 1c4:	6902                	ld	s2,0(sp)
 1c6:	6105                	addi	sp,sp,32
 1c8:	8082                	ret
    return -1;
 1ca:	57fd                	li	a5,-1
 1cc:	893e                	mv	s2,a5
 1ce:	bfc5                	j	1be <stat+0x36>

00000000000001d0 <atoi>:

int
atoi(const char *s)
{
 1d0:	1141                	addi	sp,sp,-16
 1d2:	e406                	sd	ra,8(sp)
 1d4:	e022                	sd	s0,0(sp)
 1d6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1d8:	00054683          	lbu	a3,0(a0)
 1dc:	fd06879b          	addiw	a5,a3,-48
 1e0:	0ff7f793          	zext.b	a5,a5
 1e4:	4625                	li	a2,9
 1e6:	02f66963          	bltu	a2,a5,218 <atoi+0x48>
 1ea:	872a                	mv	a4,a0
  n = 0;
 1ec:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1ee:	0705                	addi	a4,a4,1
 1f0:	0025179b          	slliw	a5,a0,0x2
 1f4:	9fa9                	addw	a5,a5,a0
 1f6:	0017979b          	slliw	a5,a5,0x1
 1fa:	9fb5                	addw	a5,a5,a3
 1fc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 200:	00074683          	lbu	a3,0(a4)
 204:	fd06879b          	addiw	a5,a3,-48
 208:	0ff7f793          	zext.b	a5,a5
 20c:	fef671e3          	bgeu	a2,a5,1ee <atoi+0x1e>
  return n;
}
 210:	60a2                	ld	ra,8(sp)
 212:	6402                	ld	s0,0(sp)
 214:	0141                	addi	sp,sp,16
 216:	8082                	ret
  n = 0;
 218:	4501                	li	a0,0
 21a:	bfdd                	j	210 <atoi+0x40>

000000000000021c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e406                	sd	ra,8(sp)
 220:	e022                	sd	s0,0(sp)
 222:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 224:	02b57563          	bgeu	a0,a1,24e <memmove+0x32>
    while(n-- > 0)
 228:	00c05f63          	blez	a2,246 <memmove+0x2a>
 22c:	1602                	slli	a2,a2,0x20
 22e:	9201                	srli	a2,a2,0x20
 230:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 234:	872a                	mv	a4,a0
      *dst++ = *src++;
 236:	0585                	addi	a1,a1,1
 238:	0705                	addi	a4,a4,1
 23a:	fff5c683          	lbu	a3,-1(a1)
 23e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 242:	fee79ae3          	bne	a5,a4,236 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 246:	60a2                	ld	ra,8(sp)
 248:	6402                	ld	s0,0(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret
    while(n-- > 0)
 24e:	fec05ce3          	blez	a2,246 <memmove+0x2a>
    dst += n;
 252:	00c50733          	add	a4,a0,a2
    src += n;
 256:	95b2                	add	a1,a1,a2
 258:	fff6079b          	addiw	a5,a2,-1
 25c:	1782                	slli	a5,a5,0x20
 25e:	9381                	srli	a5,a5,0x20
 260:	fff7c793          	not	a5,a5
 264:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 266:	15fd                	addi	a1,a1,-1
 268:	177d                	addi	a4,a4,-1
 26a:	0005c683          	lbu	a3,0(a1)
 26e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 272:	fef71ae3          	bne	a4,a5,266 <memmove+0x4a>
 276:	bfc1                	j	246 <memmove+0x2a>

0000000000000278 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e406                	sd	ra,8(sp)
 27c:	e022                	sd	s0,0(sp)
 27e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 280:	c61d                	beqz	a2,2ae <memcmp+0x36>
 282:	1602                	slli	a2,a2,0x20
 284:	9201                	srli	a2,a2,0x20
 286:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 28a:	00054783          	lbu	a5,0(a0)
 28e:	0005c703          	lbu	a4,0(a1)
 292:	00e79863          	bne	a5,a4,2a2 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 296:	0505                	addi	a0,a0,1
    p2++;
 298:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 29a:	fed518e3          	bne	a0,a3,28a <memcmp+0x12>
  }
  return 0;
 29e:	4501                	li	a0,0
 2a0:	a019                	j	2a6 <memcmp+0x2e>
      return *p1 - *p2;
 2a2:	40e7853b          	subw	a0,a5,a4
}
 2a6:	60a2                	ld	ra,8(sp)
 2a8:	6402                	ld	s0,0(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret
  return 0;
 2ae:	4501                	li	a0,0
 2b0:	bfdd                	j	2a6 <memcmp+0x2e>

00000000000002b2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e406                	sd	ra,8(sp)
 2b6:	e022                	sd	s0,0(sp)
 2b8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ba:	00000097          	auipc	ra,0x0
 2be:	f62080e7          	jalr	-158(ra) # 21c <memmove>
}
 2c2:	60a2                	ld	ra,8(sp)
 2c4:	6402                	ld	s0,0(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret

00000000000002ca <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ca:	4885                	li	a7,1
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2d2:	4889                	li	a7,2
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <wait>:
.global wait
wait:
 li a7, SYS_wait
 2da:	488d                	li	a7,3
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2e2:	4891                	li	a7,4
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <read>:
.global read
read:
 li a7, SYS_read
 2ea:	4895                	li	a7,5
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <write>:
.global write
write:
 li a7, SYS_write
 2f2:	48c1                	li	a7,16
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <close>:
.global close
close:
 li a7, SYS_close
 2fa:	48d5                	li	a7,21
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <kill>:
.global kill
kill:
 li a7, SYS_kill
 302:	4899                	li	a7,6
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <exec>:
.global exec
exec:
 li a7, SYS_exec
 30a:	489d                	li	a7,7
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <open>:
.global open
open:
 li a7, SYS_open
 312:	48bd                	li	a7,15
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 31a:	48c5                	li	a7,17
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 322:	48c9                	li	a7,18
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 32a:	48a1                	li	a7,8
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <link>:
.global link
link:
 li a7, SYS_link
 332:	48cd                	li	a7,19
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 33a:	48d1                	li	a7,20
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 342:	48a5                	li	a7,9
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <dup>:
.global dup
dup:
 li a7, SYS_dup
 34a:	48a9                	li	a7,10
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 352:	48ad                	li	a7,11
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 35a:	48b1                	li	a7,12
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 362:	48b5                	li	a7,13
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 36a:	48b9                	li	a7,14
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <nanotime>:
.global nanotime
nanotime:
 li a7, SYS_nanotime
 372:	48d9                	li	a7,22
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 37a:	1101                	addi	sp,sp,-32
 37c:	ec06                	sd	ra,24(sp)
 37e:	e822                	sd	s0,16(sp)
 380:	1000                	addi	s0,sp,32
 382:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 386:	4605                	li	a2,1
 388:	fef40593          	addi	a1,s0,-17
 38c:	00000097          	auipc	ra,0x0
 390:	f66080e7          	jalr	-154(ra) # 2f2 <write>
}
 394:	60e2                	ld	ra,24(sp)
 396:	6442                	ld	s0,16(sp)
 398:	6105                	addi	sp,sp,32
 39a:	8082                	ret

000000000000039c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 39c:	7139                	addi	sp,sp,-64
 39e:	fc06                	sd	ra,56(sp)
 3a0:	f822                	sd	s0,48(sp)
 3a2:	f04a                	sd	s2,32(sp)
 3a4:	ec4e                	sd	s3,24(sp)
 3a6:	0080                	addi	s0,sp,64
 3a8:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3aa:	cad9                	beqz	a3,440 <printint+0xa4>
 3ac:	01f5d79b          	srliw	a5,a1,0x1f
 3b0:	cbc1                	beqz	a5,440 <printint+0xa4>
    neg = 1;
    x = -xx;
 3b2:	40b005bb          	negw	a1,a1
    neg = 1;
 3b6:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 3b8:	fc040993          	addi	s3,s0,-64
  neg = 0;
 3bc:	86ce                	mv	a3,s3
  i = 0;
 3be:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3c0:	00000817          	auipc	a6,0x0
 3c4:	4a080813          	addi	a6,a6,1184 # 860 <digits>
 3c8:	88ba                	mv	a7,a4
 3ca:	0017051b          	addiw	a0,a4,1
 3ce:	872a                	mv	a4,a0
 3d0:	02c5f7bb          	remuw	a5,a1,a2
 3d4:	1782                	slli	a5,a5,0x20
 3d6:	9381                	srli	a5,a5,0x20
 3d8:	97c2                	add	a5,a5,a6
 3da:	0007c783          	lbu	a5,0(a5)
 3de:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3e2:	87ae                	mv	a5,a1
 3e4:	02c5d5bb          	divuw	a1,a1,a2
 3e8:	0685                	addi	a3,a3,1
 3ea:	fcc7ffe3          	bgeu	a5,a2,3c8 <printint+0x2c>
  if(neg)
 3ee:	00030c63          	beqz	t1,406 <printint+0x6a>
    buf[i++] = '-';
 3f2:	fd050793          	addi	a5,a0,-48
 3f6:	00878533          	add	a0,a5,s0
 3fa:	02d00793          	li	a5,45
 3fe:	fef50823          	sb	a5,-16(a0)
 402:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 406:	02e05763          	blez	a4,434 <printint+0x98>
 40a:	f426                	sd	s1,40(sp)
 40c:	377d                	addiw	a4,a4,-1
 40e:	00e984b3          	add	s1,s3,a4
 412:	19fd                	addi	s3,s3,-1
 414:	99ba                	add	s3,s3,a4
 416:	1702                	slli	a4,a4,0x20
 418:	9301                	srli	a4,a4,0x20
 41a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 41e:	0004c583          	lbu	a1,0(s1)
 422:	854a                	mv	a0,s2
 424:	00000097          	auipc	ra,0x0
 428:	f56080e7          	jalr	-170(ra) # 37a <putc>
  while(--i >= 0)
 42c:	14fd                	addi	s1,s1,-1
 42e:	ff3498e3          	bne	s1,s3,41e <printint+0x82>
 432:	74a2                	ld	s1,40(sp)
}
 434:	70e2                	ld	ra,56(sp)
 436:	7442                	ld	s0,48(sp)
 438:	7902                	ld	s2,32(sp)
 43a:	69e2                	ld	s3,24(sp)
 43c:	6121                	addi	sp,sp,64
 43e:	8082                	ret
  neg = 0;
 440:	4301                	li	t1,0
 442:	bf9d                	j	3b8 <printint+0x1c>

0000000000000444 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 444:	715d                	addi	sp,sp,-80
 446:	e486                	sd	ra,72(sp)
 448:	e0a2                	sd	s0,64(sp)
 44a:	f84a                	sd	s2,48(sp)
 44c:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 44e:	0005c903          	lbu	s2,0(a1)
 452:	1a090b63          	beqz	s2,608 <vprintf+0x1c4>
 456:	fc26                	sd	s1,56(sp)
 458:	f44e                	sd	s3,40(sp)
 45a:	f052                	sd	s4,32(sp)
 45c:	ec56                	sd	s5,24(sp)
 45e:	e85a                	sd	s6,16(sp)
 460:	e45e                	sd	s7,8(sp)
 462:	8aaa                	mv	s5,a0
 464:	8bb2                	mv	s7,a2
 466:	00158493          	addi	s1,a1,1
  state = 0;
 46a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 46c:	02500a13          	li	s4,37
 470:	4b55                	li	s6,21
 472:	a839                	j	490 <vprintf+0x4c>
        putc(fd, c);
 474:	85ca                	mv	a1,s2
 476:	8556                	mv	a0,s5
 478:	00000097          	auipc	ra,0x0
 47c:	f02080e7          	jalr	-254(ra) # 37a <putc>
 480:	a019                	j	486 <vprintf+0x42>
    } else if(state == '%'){
 482:	01498d63          	beq	s3,s4,49c <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 486:	0485                	addi	s1,s1,1
 488:	fff4c903          	lbu	s2,-1(s1)
 48c:	16090863          	beqz	s2,5fc <vprintf+0x1b8>
    if(state == 0){
 490:	fe0999e3          	bnez	s3,482 <vprintf+0x3e>
      if(c == '%'){
 494:	ff4910e3          	bne	s2,s4,474 <vprintf+0x30>
        state = '%';
 498:	89d2                	mv	s3,s4
 49a:	b7f5                	j	486 <vprintf+0x42>
      if(c == 'd'){
 49c:	13490563          	beq	s2,s4,5c6 <vprintf+0x182>
 4a0:	f9d9079b          	addiw	a5,s2,-99
 4a4:	0ff7f793          	zext.b	a5,a5
 4a8:	12fb6863          	bltu	s6,a5,5d8 <vprintf+0x194>
 4ac:	f9d9079b          	addiw	a5,s2,-99
 4b0:	0ff7f713          	zext.b	a4,a5
 4b4:	12eb6263          	bltu	s6,a4,5d8 <vprintf+0x194>
 4b8:	00271793          	slli	a5,a4,0x2
 4bc:	00000717          	auipc	a4,0x0
 4c0:	34c70713          	addi	a4,a4,844 # 808 <malloc+0x10c>
 4c4:	97ba                	add	a5,a5,a4
 4c6:	439c                	lw	a5,0(a5)
 4c8:	97ba                	add	a5,a5,a4
 4ca:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4cc:	008b8913          	addi	s2,s7,8
 4d0:	4685                	li	a3,1
 4d2:	4629                	li	a2,10
 4d4:	000ba583          	lw	a1,0(s7)
 4d8:	8556                	mv	a0,s5
 4da:	00000097          	auipc	ra,0x0
 4de:	ec2080e7          	jalr	-318(ra) # 39c <printint>
 4e2:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4e4:	4981                	li	s3,0
 4e6:	b745                	j	486 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4e8:	008b8913          	addi	s2,s7,8
 4ec:	4681                	li	a3,0
 4ee:	4629                	li	a2,10
 4f0:	000ba583          	lw	a1,0(s7)
 4f4:	8556                	mv	a0,s5
 4f6:	00000097          	auipc	ra,0x0
 4fa:	ea6080e7          	jalr	-346(ra) # 39c <printint>
 4fe:	8bca                	mv	s7,s2
      state = 0;
 500:	4981                	li	s3,0
 502:	b751                	j	486 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 504:	008b8913          	addi	s2,s7,8
 508:	4681                	li	a3,0
 50a:	4641                	li	a2,16
 50c:	000ba583          	lw	a1,0(s7)
 510:	8556                	mv	a0,s5
 512:	00000097          	auipc	ra,0x0
 516:	e8a080e7          	jalr	-374(ra) # 39c <printint>
 51a:	8bca                	mv	s7,s2
      state = 0;
 51c:	4981                	li	s3,0
 51e:	b7a5                	j	486 <vprintf+0x42>
 520:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 522:	008b8793          	addi	a5,s7,8
 526:	8c3e                	mv	s8,a5
 528:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 52c:	03000593          	li	a1,48
 530:	8556                	mv	a0,s5
 532:	00000097          	auipc	ra,0x0
 536:	e48080e7          	jalr	-440(ra) # 37a <putc>
  putc(fd, 'x');
 53a:	07800593          	li	a1,120
 53e:	8556                	mv	a0,s5
 540:	00000097          	auipc	ra,0x0
 544:	e3a080e7          	jalr	-454(ra) # 37a <putc>
 548:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 54a:	00000b97          	auipc	s7,0x0
 54e:	316b8b93          	addi	s7,s7,790 # 860 <digits>
 552:	03c9d793          	srli	a5,s3,0x3c
 556:	97de                	add	a5,a5,s7
 558:	0007c583          	lbu	a1,0(a5)
 55c:	8556                	mv	a0,s5
 55e:	00000097          	auipc	ra,0x0
 562:	e1c080e7          	jalr	-484(ra) # 37a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 566:	0992                	slli	s3,s3,0x4
 568:	397d                	addiw	s2,s2,-1
 56a:	fe0914e3          	bnez	s2,552 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 56e:	8be2                	mv	s7,s8
      state = 0;
 570:	4981                	li	s3,0
 572:	6c02                	ld	s8,0(sp)
 574:	bf09                	j	486 <vprintf+0x42>
        s = va_arg(ap, char*);
 576:	008b8993          	addi	s3,s7,8
 57a:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 57e:	02090163          	beqz	s2,5a0 <vprintf+0x15c>
        while(*s != 0){
 582:	00094583          	lbu	a1,0(s2)
 586:	c9a5                	beqz	a1,5f6 <vprintf+0x1b2>
          putc(fd, *s);
 588:	8556                	mv	a0,s5
 58a:	00000097          	auipc	ra,0x0
 58e:	df0080e7          	jalr	-528(ra) # 37a <putc>
          s++;
 592:	0905                	addi	s2,s2,1
        while(*s != 0){
 594:	00094583          	lbu	a1,0(s2)
 598:	f9e5                	bnez	a1,588 <vprintf+0x144>
        s = va_arg(ap, char*);
 59a:	8bce                	mv	s7,s3
      state = 0;
 59c:	4981                	li	s3,0
 59e:	b5e5                	j	486 <vprintf+0x42>
          s = "(null)";
 5a0:	00000917          	auipc	s2,0x0
 5a4:	26090913          	addi	s2,s2,608 # 800 <malloc+0x104>
        while(*s != 0){
 5a8:	02800593          	li	a1,40
 5ac:	bff1                	j	588 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 5ae:	008b8913          	addi	s2,s7,8
 5b2:	000bc583          	lbu	a1,0(s7)
 5b6:	8556                	mv	a0,s5
 5b8:	00000097          	auipc	ra,0x0
 5bc:	dc2080e7          	jalr	-574(ra) # 37a <putc>
 5c0:	8bca                	mv	s7,s2
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	b5c9                	j	486 <vprintf+0x42>
        putc(fd, c);
 5c6:	02500593          	li	a1,37
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	dae080e7          	jalr	-594(ra) # 37a <putc>
      state = 0;
 5d4:	4981                	li	s3,0
 5d6:	bd45                	j	486 <vprintf+0x42>
        putc(fd, '%');
 5d8:	02500593          	li	a1,37
 5dc:	8556                	mv	a0,s5
 5de:	00000097          	auipc	ra,0x0
 5e2:	d9c080e7          	jalr	-612(ra) # 37a <putc>
        putc(fd, c);
 5e6:	85ca                	mv	a1,s2
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	d90080e7          	jalr	-624(ra) # 37a <putc>
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	bd49                	j	486 <vprintf+0x42>
        s = va_arg(ap, char*);
 5f6:	8bce                	mv	s7,s3
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	b571                	j	486 <vprintf+0x42>
 5fc:	74e2                	ld	s1,56(sp)
 5fe:	79a2                	ld	s3,40(sp)
 600:	7a02                	ld	s4,32(sp)
 602:	6ae2                	ld	s5,24(sp)
 604:	6b42                	ld	s6,16(sp)
 606:	6ba2                	ld	s7,8(sp)
    }
  }
}
 608:	60a6                	ld	ra,72(sp)
 60a:	6406                	ld	s0,64(sp)
 60c:	7942                	ld	s2,48(sp)
 60e:	6161                	addi	sp,sp,80
 610:	8082                	ret

0000000000000612 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 612:	715d                	addi	sp,sp,-80
 614:	ec06                	sd	ra,24(sp)
 616:	e822                	sd	s0,16(sp)
 618:	1000                	addi	s0,sp,32
 61a:	e010                	sd	a2,0(s0)
 61c:	e414                	sd	a3,8(s0)
 61e:	e818                	sd	a4,16(s0)
 620:	ec1c                	sd	a5,24(s0)
 622:	03043023          	sd	a6,32(s0)
 626:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 62a:	8622                	mv	a2,s0
 62c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 630:	00000097          	auipc	ra,0x0
 634:	e14080e7          	jalr	-492(ra) # 444 <vprintf>
}
 638:	60e2                	ld	ra,24(sp)
 63a:	6442                	ld	s0,16(sp)
 63c:	6161                	addi	sp,sp,80
 63e:	8082                	ret

0000000000000640 <printf>:

void
printf(const char *fmt, ...)
{
 640:	711d                	addi	sp,sp,-96
 642:	ec06                	sd	ra,24(sp)
 644:	e822                	sd	s0,16(sp)
 646:	1000                	addi	s0,sp,32
 648:	e40c                	sd	a1,8(s0)
 64a:	e810                	sd	a2,16(s0)
 64c:	ec14                	sd	a3,24(s0)
 64e:	f018                	sd	a4,32(s0)
 650:	f41c                	sd	a5,40(s0)
 652:	03043823          	sd	a6,48(s0)
 656:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 65a:	00840613          	addi	a2,s0,8
 65e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 662:	85aa                	mv	a1,a0
 664:	4505                	li	a0,1
 666:	00000097          	auipc	ra,0x0
 66a:	dde080e7          	jalr	-546(ra) # 444 <vprintf>
}
 66e:	60e2                	ld	ra,24(sp)
 670:	6442                	ld	s0,16(sp)
 672:	6125                	addi	sp,sp,96
 674:	8082                	ret

0000000000000676 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 676:	1141                	addi	sp,sp,-16
 678:	e406                	sd	ra,8(sp)
 67a:	e022                	sd	s0,0(sp)
 67c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 67e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 682:	00001797          	auipc	a5,0x1
 686:	97e7b783          	ld	a5,-1666(a5) # 1000 <freep>
 68a:	a039                	j	698 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 68c:	6398                	ld	a4,0(a5)
 68e:	00e7e463          	bltu	a5,a4,696 <free+0x20>
 692:	00e6ea63          	bltu	a3,a4,6a6 <free+0x30>
{
 696:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 698:	fed7fae3          	bgeu	a5,a3,68c <free+0x16>
 69c:	6398                	ld	a4,0(a5)
 69e:	00e6e463          	bltu	a3,a4,6a6 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6a2:	fee7eae3          	bltu	a5,a4,696 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6a6:	ff852583          	lw	a1,-8(a0)
 6aa:	6390                	ld	a2,0(a5)
 6ac:	02059813          	slli	a6,a1,0x20
 6b0:	01c85713          	srli	a4,a6,0x1c
 6b4:	9736                	add	a4,a4,a3
 6b6:	02e60563          	beq	a2,a4,6e0 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 6ba:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 6be:	4790                	lw	a2,8(a5)
 6c0:	02061593          	slli	a1,a2,0x20
 6c4:	01c5d713          	srli	a4,a1,0x1c
 6c8:	973e                	add	a4,a4,a5
 6ca:	02e68263          	beq	a3,a4,6ee <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 6ce:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6d0:	00001717          	auipc	a4,0x1
 6d4:	92f73823          	sd	a5,-1744(a4) # 1000 <freep>
}
 6d8:	60a2                	ld	ra,8(sp)
 6da:	6402                	ld	s0,0(sp)
 6dc:	0141                	addi	sp,sp,16
 6de:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 6e0:	4618                	lw	a4,8(a2)
 6e2:	9f2d                	addw	a4,a4,a1
 6e4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6e8:	6398                	ld	a4,0(a5)
 6ea:	6310                	ld	a2,0(a4)
 6ec:	b7f9                	j	6ba <free+0x44>
    p->s.size += bp->s.size;
 6ee:	ff852703          	lw	a4,-8(a0)
 6f2:	9f31                	addw	a4,a4,a2
 6f4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6f6:	ff053683          	ld	a3,-16(a0)
 6fa:	bfd1                	j	6ce <free+0x58>

00000000000006fc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6fc:	7139                	addi	sp,sp,-64
 6fe:	fc06                	sd	ra,56(sp)
 700:	f822                	sd	s0,48(sp)
 702:	f04a                	sd	s2,32(sp)
 704:	ec4e                	sd	s3,24(sp)
 706:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 708:	02051993          	slli	s3,a0,0x20
 70c:	0209d993          	srli	s3,s3,0x20
 710:	09bd                	addi	s3,s3,15
 712:	0049d993          	srli	s3,s3,0x4
 716:	2985                	addiw	s3,s3,1
 718:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 71a:	00001517          	auipc	a0,0x1
 71e:	8e653503          	ld	a0,-1818(a0) # 1000 <freep>
 722:	c905                	beqz	a0,752 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 724:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 726:	4798                	lw	a4,8(a5)
 728:	09377a63          	bgeu	a4,s3,7bc <malloc+0xc0>
 72c:	f426                	sd	s1,40(sp)
 72e:	e852                	sd	s4,16(sp)
 730:	e456                	sd	s5,8(sp)
 732:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 734:	8a4e                	mv	s4,s3
 736:	6705                	lui	a4,0x1
 738:	00e9f363          	bgeu	s3,a4,73e <malloc+0x42>
 73c:	6a05                	lui	s4,0x1
 73e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 742:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 746:	00001497          	auipc	s1,0x1
 74a:	8ba48493          	addi	s1,s1,-1862 # 1000 <freep>
  if(p == (char*)-1)
 74e:	5afd                	li	s5,-1
 750:	a089                	j	792 <malloc+0x96>
 752:	f426                	sd	s1,40(sp)
 754:	e852                	sd	s4,16(sp)
 756:	e456                	sd	s5,8(sp)
 758:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 75a:	00001797          	auipc	a5,0x1
 75e:	8b678793          	addi	a5,a5,-1866 # 1010 <base>
 762:	00001717          	auipc	a4,0x1
 766:	88f73f23          	sd	a5,-1890(a4) # 1000 <freep>
 76a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 76c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 770:	b7d1                	j	734 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 772:	6398                	ld	a4,0(a5)
 774:	e118                	sd	a4,0(a0)
 776:	a8b9                	j	7d4 <malloc+0xd8>
  hp->s.size = nu;
 778:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 77c:	0541                	addi	a0,a0,16
 77e:	00000097          	auipc	ra,0x0
 782:	ef8080e7          	jalr	-264(ra) # 676 <free>
  return freep;
 786:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 788:	c135                	beqz	a0,7ec <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 78a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 78c:	4798                	lw	a4,8(a5)
 78e:	03277363          	bgeu	a4,s2,7b4 <malloc+0xb8>
    if(p == freep)
 792:	6098                	ld	a4,0(s1)
 794:	853e                	mv	a0,a5
 796:	fef71ae3          	bne	a4,a5,78a <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 79a:	8552                	mv	a0,s4
 79c:	00000097          	auipc	ra,0x0
 7a0:	bbe080e7          	jalr	-1090(ra) # 35a <sbrk>
  if(p == (char*)-1)
 7a4:	fd551ae3          	bne	a0,s5,778 <malloc+0x7c>
        return 0;
 7a8:	4501                	li	a0,0
 7aa:	74a2                	ld	s1,40(sp)
 7ac:	6a42                	ld	s4,16(sp)
 7ae:	6aa2                	ld	s5,8(sp)
 7b0:	6b02                	ld	s6,0(sp)
 7b2:	a03d                	j	7e0 <malloc+0xe4>
 7b4:	74a2                	ld	s1,40(sp)
 7b6:	6a42                	ld	s4,16(sp)
 7b8:	6aa2                	ld	s5,8(sp)
 7ba:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7bc:	fae90be3          	beq	s2,a4,772 <malloc+0x76>
        p->s.size -= nunits;
 7c0:	4137073b          	subw	a4,a4,s3
 7c4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7c6:	02071693          	slli	a3,a4,0x20
 7ca:	01c6d713          	srli	a4,a3,0x1c
 7ce:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7d0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7d4:	00001717          	auipc	a4,0x1
 7d8:	82a73623          	sd	a0,-2004(a4) # 1000 <freep>
      return (void*)(p + 1);
 7dc:	01078513          	addi	a0,a5,16
  }
}
 7e0:	70e2                	ld	ra,56(sp)
 7e2:	7442                	ld	s0,48(sp)
 7e4:	7902                	ld	s2,32(sp)
 7e6:	69e2                	ld	s3,24(sp)
 7e8:	6121                	addi	sp,sp,64
 7ea:	8082                	ret
 7ec:	74a2                	ld	s1,40(sp)
 7ee:	6a42                	ld	s4,16(sp)
 7f0:	6aa2                	ld	s5,8(sp)
 7f2:	6b02                	ld	s6,0(sp)
 7f4:	b7f5                	j	7e0 <malloc+0xe4>
