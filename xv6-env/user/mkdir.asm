
user/_mkdir:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   8:	4785                	li	a5,1
   a:	02a7dd63          	bge	a5,a0,44 <main+0x44>
   e:	e426                	sd	s1,8(sp)
  10:	e04a                	sd	s2,0(sp)
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "Usage: mkdir files...\n");
    exit(1);
  }

  for(i = 1; i < argc; i++){
    if(mkdir(argv[i]) < 0){
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	362080e7          	jalr	866(ra) # 38a <mkdir>
  30:	02054a63          	bltz	a0,64 <main+0x64>
  for(i = 1; i < argc; i++){
  34:	04a1                	addi	s1,s1,8
  36:	ff2498e3          	bne	s1,s2,26 <main+0x26>
      fprintf(2, "mkdir: %s failed to create\n", argv[i]);
      break;
    }
  }

  exit(0);
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	2e6080e7          	jalr	742(ra) # 322 <exit>
  44:	e426                	sd	s1,8(sp)
  46:	e04a                	sd	s2,0(sp)
    fprintf(2, "Usage: mkdir files...\n");
  48:	00001597          	auipc	a1,0x1
  4c:	80858593          	addi	a1,a1,-2040 # 850 <malloc+0x104>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	610080e7          	jalr	1552(ra) # 662 <fprintf>
    exit(1);
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	2c6080e7          	jalr	710(ra) # 322 <exit>
      fprintf(2, "mkdir: %s failed to create\n", argv[i]);
  64:	6090                	ld	a2,0(s1)
  66:	00001597          	auipc	a1,0x1
  6a:	80258593          	addi	a1,a1,-2046 # 868 <malloc+0x11c>
  6e:	4509                	li	a0,2
  70:	00000097          	auipc	ra,0x0
  74:	5f2080e7          	jalr	1522(ra) # 662 <fprintf>
      break;
  78:	b7c9                	j	3a <main+0x3a>

000000000000007a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e406                	sd	ra,8(sp)
  7e:	e022                	sd	s0,0(sp)
  80:	0800                	addi	s0,sp,16
  extern int main();
  main();
  82:	00000097          	auipc	ra,0x0
  86:	f7e080e7          	jalr	-130(ra) # 0 <main>
  exit(0);
  8a:	4501                	li	a0,0
  8c:	00000097          	auipc	ra,0x0
  90:	296080e7          	jalr	662(ra) # 322 <exit>

0000000000000094 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  94:	1141                	addi	sp,sp,-16
  96:	e406                	sd	ra,8(sp)
  98:	e022                	sd	s0,0(sp)
  9a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  9c:	87aa                	mv	a5,a0
  9e:	0585                	addi	a1,a1,1
  a0:	0785                	addi	a5,a5,1
  a2:	fff5c703          	lbu	a4,-1(a1)
  a6:	fee78fa3          	sb	a4,-1(a5)
  aa:	fb75                	bnez	a4,9e <strcpy+0xa>
    ;
  return os;
}
  ac:	60a2                	ld	ra,8(sp)
  ae:	6402                	ld	s0,0(sp)
  b0:	0141                	addi	sp,sp,16
  b2:	8082                	ret

00000000000000b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b4:	1141                	addi	sp,sp,-16
  b6:	e406                	sd	ra,8(sp)
  b8:	e022                	sd	s0,0(sp)
  ba:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  bc:	00054783          	lbu	a5,0(a0)
  c0:	cb91                	beqz	a5,d4 <strcmp+0x20>
  c2:	0005c703          	lbu	a4,0(a1)
  c6:	00f71763          	bne	a4,a5,d4 <strcmp+0x20>
    p++, q++;
  ca:	0505                	addi	a0,a0,1
  cc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ce:	00054783          	lbu	a5,0(a0)
  d2:	fbe5                	bnez	a5,c2 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  d4:	0005c503          	lbu	a0,0(a1)
}
  d8:	40a7853b          	subw	a0,a5,a0
  dc:	60a2                	ld	ra,8(sp)
  de:	6402                	ld	s0,0(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret

00000000000000e4 <strlen>:

uint
strlen(const char *s)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e406                	sd	ra,8(sp)
  e8:	e022                	sd	s0,0(sp)
  ea:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ec:	00054783          	lbu	a5,0(a0)
  f0:	cf91                	beqz	a5,10c <strlen+0x28>
  f2:	00150793          	addi	a5,a0,1
  f6:	86be                	mv	a3,a5
  f8:	0785                	addi	a5,a5,1
  fa:	fff7c703          	lbu	a4,-1(a5)
  fe:	ff65                	bnez	a4,f6 <strlen+0x12>
 100:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 104:	60a2                	ld	ra,8(sp)
 106:	6402                	ld	s0,0(sp)
 108:	0141                	addi	sp,sp,16
 10a:	8082                	ret
  for(n = 0; s[n]; n++)
 10c:	4501                	li	a0,0
 10e:	bfdd                	j	104 <strlen+0x20>

0000000000000110 <memset>:

void*
memset(void *dst, int c, uint n)
{
 110:	1141                	addi	sp,sp,-16
 112:	e406                	sd	ra,8(sp)
 114:	e022                	sd	s0,0(sp)
 116:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 118:	ca19                	beqz	a2,12e <memset+0x1e>
 11a:	87aa                	mv	a5,a0
 11c:	1602                	slli	a2,a2,0x20
 11e:	9201                	srli	a2,a2,0x20
 120:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 124:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 128:	0785                	addi	a5,a5,1
 12a:	fee79de3          	bne	a5,a4,124 <memset+0x14>
  }
  return dst;
}
 12e:	60a2                	ld	ra,8(sp)
 130:	6402                	ld	s0,0(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret

0000000000000136 <strchr>:

char*
strchr(const char *s, char c)
{
 136:	1141                	addi	sp,sp,-16
 138:	e406                	sd	ra,8(sp)
 13a:	e022                	sd	s0,0(sp)
 13c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 13e:	00054783          	lbu	a5,0(a0)
 142:	cf81                	beqz	a5,15a <strchr+0x24>
    if(*s == c)
 144:	00f58763          	beq	a1,a5,152 <strchr+0x1c>
  for(; *s; s++)
 148:	0505                	addi	a0,a0,1
 14a:	00054783          	lbu	a5,0(a0)
 14e:	fbfd                	bnez	a5,144 <strchr+0xe>
      return (char*)s;
  return 0;
 150:	4501                	li	a0,0
}
 152:	60a2                	ld	ra,8(sp)
 154:	6402                	ld	s0,0(sp)
 156:	0141                	addi	sp,sp,16
 158:	8082                	ret
  return 0;
 15a:	4501                	li	a0,0
 15c:	bfdd                	j	152 <strchr+0x1c>

000000000000015e <gets>:

char*
gets(char *buf, int max)
{
 15e:	711d                	addi	sp,sp,-96
 160:	ec86                	sd	ra,88(sp)
 162:	e8a2                	sd	s0,80(sp)
 164:	e4a6                	sd	s1,72(sp)
 166:	e0ca                	sd	s2,64(sp)
 168:	fc4e                	sd	s3,56(sp)
 16a:	f852                	sd	s4,48(sp)
 16c:	f456                	sd	s5,40(sp)
 16e:	f05a                	sd	s6,32(sp)
 170:	ec5e                	sd	s7,24(sp)
 172:	e862                	sd	s8,16(sp)
 174:	1080                	addi	s0,sp,96
 176:	8baa                	mv	s7,a0
 178:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17a:	892a                	mv	s2,a0
 17c:	4481                	li	s1,0
    cc = read(0, &c, 1);
 17e:	faf40b13          	addi	s6,s0,-81
 182:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 184:	8c26                	mv	s8,s1
 186:	0014899b          	addiw	s3,s1,1
 18a:	84ce                	mv	s1,s3
 18c:	0349d663          	bge	s3,s4,1b8 <gets+0x5a>
    cc = read(0, &c, 1);
 190:	8656                	mv	a2,s5
 192:	85da                	mv	a1,s6
 194:	4501                	li	a0,0
 196:	00000097          	auipc	ra,0x0
 19a:	1a4080e7          	jalr	420(ra) # 33a <read>
    if(cc < 1)
 19e:	00a05d63          	blez	a0,1b8 <gets+0x5a>
      break;
    buf[i++] = c;
 1a2:	faf44783          	lbu	a5,-81(s0)
 1a6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1aa:	0905                	addi	s2,s2,1
 1ac:	ff678713          	addi	a4,a5,-10
 1b0:	c319                	beqz	a4,1b6 <gets+0x58>
 1b2:	17cd                	addi	a5,a5,-13
 1b4:	fbe1                	bnez	a5,184 <gets+0x26>
    buf[i++] = c;
 1b6:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1b8:	9c5e                	add	s8,s8,s7
 1ba:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1be:	855e                	mv	a0,s7
 1c0:	60e6                	ld	ra,88(sp)
 1c2:	6446                	ld	s0,80(sp)
 1c4:	64a6                	ld	s1,72(sp)
 1c6:	6906                	ld	s2,64(sp)
 1c8:	79e2                	ld	s3,56(sp)
 1ca:	7a42                	ld	s4,48(sp)
 1cc:	7aa2                	ld	s5,40(sp)
 1ce:	7b02                	ld	s6,32(sp)
 1d0:	6be2                	ld	s7,24(sp)
 1d2:	6c42                	ld	s8,16(sp)
 1d4:	6125                	addi	sp,sp,96
 1d6:	8082                	ret

00000000000001d8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d8:	1101                	addi	sp,sp,-32
 1da:	ec06                	sd	ra,24(sp)
 1dc:	e822                	sd	s0,16(sp)
 1de:	e04a                	sd	s2,0(sp)
 1e0:	1000                	addi	s0,sp,32
 1e2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e4:	4581                	li	a1,0
 1e6:	00000097          	auipc	ra,0x0
 1ea:	17c080e7          	jalr	380(ra) # 362 <open>
  if(fd < 0)
 1ee:	02054663          	bltz	a0,21a <stat+0x42>
 1f2:	e426                	sd	s1,8(sp)
 1f4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f6:	85ca                	mv	a1,s2
 1f8:	00000097          	auipc	ra,0x0
 1fc:	182080e7          	jalr	386(ra) # 37a <fstat>
 200:	892a                	mv	s2,a0
  close(fd);
 202:	8526                	mv	a0,s1
 204:	00000097          	auipc	ra,0x0
 208:	146080e7          	jalr	326(ra) # 34a <close>
  return r;
 20c:	64a2                	ld	s1,8(sp)
}
 20e:	854a                	mv	a0,s2
 210:	60e2                	ld	ra,24(sp)
 212:	6442                	ld	s0,16(sp)
 214:	6902                	ld	s2,0(sp)
 216:	6105                	addi	sp,sp,32
 218:	8082                	ret
    return -1;
 21a:	57fd                	li	a5,-1
 21c:	893e                	mv	s2,a5
 21e:	bfc5                	j	20e <stat+0x36>

0000000000000220 <atoi>:

int
atoi(const char *s)
{
 220:	1141                	addi	sp,sp,-16
 222:	e406                	sd	ra,8(sp)
 224:	e022                	sd	s0,0(sp)
 226:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 228:	00054683          	lbu	a3,0(a0)
 22c:	fd06879b          	addiw	a5,a3,-48
 230:	0ff7f793          	zext.b	a5,a5
 234:	4625                	li	a2,9
 236:	02f66963          	bltu	a2,a5,268 <atoi+0x48>
 23a:	872a                	mv	a4,a0
  n = 0;
 23c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 23e:	0705                	addi	a4,a4,1
 240:	0025179b          	slliw	a5,a0,0x2
 244:	9fa9                	addw	a5,a5,a0
 246:	0017979b          	slliw	a5,a5,0x1
 24a:	9fb5                	addw	a5,a5,a3
 24c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 250:	00074683          	lbu	a3,0(a4)
 254:	fd06879b          	addiw	a5,a3,-48
 258:	0ff7f793          	zext.b	a5,a5
 25c:	fef671e3          	bgeu	a2,a5,23e <atoi+0x1e>
  return n;
}
 260:	60a2                	ld	ra,8(sp)
 262:	6402                	ld	s0,0(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret
  n = 0;
 268:	4501                	li	a0,0
 26a:	bfdd                	j	260 <atoi+0x40>

000000000000026c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 274:	02b57563          	bgeu	a0,a1,29e <memmove+0x32>
    while(n-- > 0)
 278:	00c05f63          	blez	a2,296 <memmove+0x2a>
 27c:	1602                	slli	a2,a2,0x20
 27e:	9201                	srli	a2,a2,0x20
 280:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 284:	872a                	mv	a4,a0
      *dst++ = *src++;
 286:	0585                	addi	a1,a1,1
 288:	0705                	addi	a4,a4,1
 28a:	fff5c683          	lbu	a3,-1(a1)
 28e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 292:	fee79ae3          	bne	a5,a4,286 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 296:	60a2                	ld	ra,8(sp)
 298:	6402                	ld	s0,0(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret
    while(n-- > 0)
 29e:	fec05ce3          	blez	a2,296 <memmove+0x2a>
    dst += n;
 2a2:	00c50733          	add	a4,a0,a2
    src += n;
 2a6:	95b2                	add	a1,a1,a2
 2a8:	fff6079b          	addiw	a5,a2,-1
 2ac:	1782                	slli	a5,a5,0x20
 2ae:	9381                	srli	a5,a5,0x20
 2b0:	fff7c793          	not	a5,a5
 2b4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2b6:	15fd                	addi	a1,a1,-1
 2b8:	177d                	addi	a4,a4,-1
 2ba:	0005c683          	lbu	a3,0(a1)
 2be:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c2:	fef71ae3          	bne	a4,a5,2b6 <memmove+0x4a>
 2c6:	bfc1                	j	296 <memmove+0x2a>

00000000000002c8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e406                	sd	ra,8(sp)
 2cc:	e022                	sd	s0,0(sp)
 2ce:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2d0:	c61d                	beqz	a2,2fe <memcmp+0x36>
 2d2:	1602                	slli	a2,a2,0x20
 2d4:	9201                	srli	a2,a2,0x20
 2d6:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2da:	00054783          	lbu	a5,0(a0)
 2de:	0005c703          	lbu	a4,0(a1)
 2e2:	00e79863          	bne	a5,a4,2f2 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2e6:	0505                	addi	a0,a0,1
    p2++;
 2e8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ea:	fed518e3          	bne	a0,a3,2da <memcmp+0x12>
  }
  return 0;
 2ee:	4501                	li	a0,0
 2f0:	a019                	j	2f6 <memcmp+0x2e>
      return *p1 - *p2;
 2f2:	40e7853b          	subw	a0,a5,a4
}
 2f6:	60a2                	ld	ra,8(sp)
 2f8:	6402                	ld	s0,0(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret
  return 0;
 2fe:	4501                	li	a0,0
 300:	bfdd                	j	2f6 <memcmp+0x2e>

0000000000000302 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 302:	1141                	addi	sp,sp,-16
 304:	e406                	sd	ra,8(sp)
 306:	e022                	sd	s0,0(sp)
 308:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 30a:	00000097          	auipc	ra,0x0
 30e:	f62080e7          	jalr	-158(ra) # 26c <memmove>
}
 312:	60a2                	ld	ra,8(sp)
 314:	6402                	ld	s0,0(sp)
 316:	0141                	addi	sp,sp,16
 318:	8082                	ret

000000000000031a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 31a:	4885                	li	a7,1
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <exit>:
.global exit
exit:
 li a7, SYS_exit
 322:	4889                	li	a7,2
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <wait>:
.global wait
wait:
 li a7, SYS_wait
 32a:	488d                	li	a7,3
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 332:	4891                	li	a7,4
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <read>:
.global read
read:
 li a7, SYS_read
 33a:	4895                	li	a7,5
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <write>:
.global write
write:
 li a7, SYS_write
 342:	48c1                	li	a7,16
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <close>:
.global close
close:
 li a7, SYS_close
 34a:	48d5                	li	a7,21
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <kill>:
.global kill
kill:
 li a7, SYS_kill
 352:	4899                	li	a7,6
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <exec>:
.global exec
exec:
 li a7, SYS_exec
 35a:	489d                	li	a7,7
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <open>:
.global open
open:
 li a7, SYS_open
 362:	48bd                	li	a7,15
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 36a:	48c5                	li	a7,17
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 372:	48c9                	li	a7,18
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 37a:	48a1                	li	a7,8
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <link>:
.global link
link:
 li a7, SYS_link
 382:	48cd                	li	a7,19
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 38a:	48d1                	li	a7,20
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 392:	48a5                	li	a7,9
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <dup>:
.global dup
dup:
 li a7, SYS_dup
 39a:	48a9                	li	a7,10
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a2:	48ad                	li	a7,11
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3aa:	48b1                	li	a7,12
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3b2:	48b5                	li	a7,13
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ba:	48b9                	li	a7,14
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <nanotime>:
.global nanotime
nanotime:
 li a7, SYS_nanotime
 3c2:	48d9                	li	a7,22
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ca:	1101                	addi	sp,sp,-32
 3cc:	ec06                	sd	ra,24(sp)
 3ce:	e822                	sd	s0,16(sp)
 3d0:	1000                	addi	s0,sp,32
 3d2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3d6:	4605                	li	a2,1
 3d8:	fef40593          	addi	a1,s0,-17
 3dc:	00000097          	auipc	ra,0x0
 3e0:	f66080e7          	jalr	-154(ra) # 342 <write>
}
 3e4:	60e2                	ld	ra,24(sp)
 3e6:	6442                	ld	s0,16(sp)
 3e8:	6105                	addi	sp,sp,32
 3ea:	8082                	ret

00000000000003ec <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ec:	7139                	addi	sp,sp,-64
 3ee:	fc06                	sd	ra,56(sp)
 3f0:	f822                	sd	s0,48(sp)
 3f2:	f04a                	sd	s2,32(sp)
 3f4:	ec4e                	sd	s3,24(sp)
 3f6:	0080                	addi	s0,sp,64
 3f8:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3fa:	cad9                	beqz	a3,490 <printint+0xa4>
 3fc:	01f5d79b          	srliw	a5,a1,0x1f
 400:	cbc1                	beqz	a5,490 <printint+0xa4>
    neg = 1;
    x = -xx;
 402:	40b005bb          	negw	a1,a1
    neg = 1;
 406:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 408:	fc040993          	addi	s3,s0,-64
  neg = 0;
 40c:	86ce                	mv	a3,s3
  i = 0;
 40e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 410:	00000817          	auipc	a6,0x0
 414:	4d880813          	addi	a6,a6,1240 # 8e8 <digits>
 418:	88ba                	mv	a7,a4
 41a:	0017051b          	addiw	a0,a4,1
 41e:	872a                	mv	a4,a0
 420:	02c5f7bb          	remuw	a5,a1,a2
 424:	1782                	slli	a5,a5,0x20
 426:	9381                	srli	a5,a5,0x20
 428:	97c2                	add	a5,a5,a6
 42a:	0007c783          	lbu	a5,0(a5)
 42e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 432:	87ae                	mv	a5,a1
 434:	02c5d5bb          	divuw	a1,a1,a2
 438:	0685                	addi	a3,a3,1
 43a:	fcc7ffe3          	bgeu	a5,a2,418 <printint+0x2c>
  if(neg)
 43e:	00030c63          	beqz	t1,456 <printint+0x6a>
    buf[i++] = '-';
 442:	fd050793          	addi	a5,a0,-48
 446:	00878533          	add	a0,a5,s0
 44a:	02d00793          	li	a5,45
 44e:	fef50823          	sb	a5,-16(a0)
 452:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 456:	02e05763          	blez	a4,484 <printint+0x98>
 45a:	f426                	sd	s1,40(sp)
 45c:	377d                	addiw	a4,a4,-1
 45e:	00e984b3          	add	s1,s3,a4
 462:	19fd                	addi	s3,s3,-1
 464:	99ba                	add	s3,s3,a4
 466:	1702                	slli	a4,a4,0x20
 468:	9301                	srli	a4,a4,0x20
 46a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 46e:	0004c583          	lbu	a1,0(s1)
 472:	854a                	mv	a0,s2
 474:	00000097          	auipc	ra,0x0
 478:	f56080e7          	jalr	-170(ra) # 3ca <putc>
  while(--i >= 0)
 47c:	14fd                	addi	s1,s1,-1
 47e:	ff3498e3          	bne	s1,s3,46e <printint+0x82>
 482:	74a2                	ld	s1,40(sp)
}
 484:	70e2                	ld	ra,56(sp)
 486:	7442                	ld	s0,48(sp)
 488:	7902                	ld	s2,32(sp)
 48a:	69e2                	ld	s3,24(sp)
 48c:	6121                	addi	sp,sp,64
 48e:	8082                	ret
  neg = 0;
 490:	4301                	li	t1,0
 492:	bf9d                	j	408 <printint+0x1c>

0000000000000494 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 494:	715d                	addi	sp,sp,-80
 496:	e486                	sd	ra,72(sp)
 498:	e0a2                	sd	s0,64(sp)
 49a:	f84a                	sd	s2,48(sp)
 49c:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 49e:	0005c903          	lbu	s2,0(a1)
 4a2:	1a090b63          	beqz	s2,658 <vprintf+0x1c4>
 4a6:	fc26                	sd	s1,56(sp)
 4a8:	f44e                	sd	s3,40(sp)
 4aa:	f052                	sd	s4,32(sp)
 4ac:	ec56                	sd	s5,24(sp)
 4ae:	e85a                	sd	s6,16(sp)
 4b0:	e45e                	sd	s7,8(sp)
 4b2:	8aaa                	mv	s5,a0
 4b4:	8bb2                	mv	s7,a2
 4b6:	00158493          	addi	s1,a1,1
  state = 0;
 4ba:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4bc:	02500a13          	li	s4,37
 4c0:	4b55                	li	s6,21
 4c2:	a839                	j	4e0 <vprintf+0x4c>
        putc(fd, c);
 4c4:	85ca                	mv	a1,s2
 4c6:	8556                	mv	a0,s5
 4c8:	00000097          	auipc	ra,0x0
 4cc:	f02080e7          	jalr	-254(ra) # 3ca <putc>
 4d0:	a019                	j	4d6 <vprintf+0x42>
    } else if(state == '%'){
 4d2:	01498d63          	beq	s3,s4,4ec <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4d6:	0485                	addi	s1,s1,1
 4d8:	fff4c903          	lbu	s2,-1(s1)
 4dc:	16090863          	beqz	s2,64c <vprintf+0x1b8>
    if(state == 0){
 4e0:	fe0999e3          	bnez	s3,4d2 <vprintf+0x3e>
      if(c == '%'){
 4e4:	ff4910e3          	bne	s2,s4,4c4 <vprintf+0x30>
        state = '%';
 4e8:	89d2                	mv	s3,s4
 4ea:	b7f5                	j	4d6 <vprintf+0x42>
      if(c == 'd'){
 4ec:	13490563          	beq	s2,s4,616 <vprintf+0x182>
 4f0:	f9d9079b          	addiw	a5,s2,-99
 4f4:	0ff7f793          	zext.b	a5,a5
 4f8:	12fb6863          	bltu	s6,a5,628 <vprintf+0x194>
 4fc:	f9d9079b          	addiw	a5,s2,-99
 500:	0ff7f713          	zext.b	a4,a5
 504:	12eb6263          	bltu	s6,a4,628 <vprintf+0x194>
 508:	00271793          	slli	a5,a4,0x2
 50c:	00000717          	auipc	a4,0x0
 510:	38470713          	addi	a4,a4,900 # 890 <malloc+0x144>
 514:	97ba                	add	a5,a5,a4
 516:	439c                	lw	a5,0(a5)
 518:	97ba                	add	a5,a5,a4
 51a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 51c:	008b8913          	addi	s2,s7,8
 520:	4685                	li	a3,1
 522:	4629                	li	a2,10
 524:	000ba583          	lw	a1,0(s7)
 528:	8556                	mv	a0,s5
 52a:	00000097          	auipc	ra,0x0
 52e:	ec2080e7          	jalr	-318(ra) # 3ec <printint>
 532:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 534:	4981                	li	s3,0
 536:	b745                	j	4d6 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 538:	008b8913          	addi	s2,s7,8
 53c:	4681                	li	a3,0
 53e:	4629                	li	a2,10
 540:	000ba583          	lw	a1,0(s7)
 544:	8556                	mv	a0,s5
 546:	00000097          	auipc	ra,0x0
 54a:	ea6080e7          	jalr	-346(ra) # 3ec <printint>
 54e:	8bca                	mv	s7,s2
      state = 0;
 550:	4981                	li	s3,0
 552:	b751                	j	4d6 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 554:	008b8913          	addi	s2,s7,8
 558:	4681                	li	a3,0
 55a:	4641                	li	a2,16
 55c:	000ba583          	lw	a1,0(s7)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	e8a080e7          	jalr	-374(ra) # 3ec <printint>
 56a:	8bca                	mv	s7,s2
      state = 0;
 56c:	4981                	li	s3,0
 56e:	b7a5                	j	4d6 <vprintf+0x42>
 570:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 572:	008b8793          	addi	a5,s7,8
 576:	8c3e                	mv	s8,a5
 578:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 57c:	03000593          	li	a1,48
 580:	8556                	mv	a0,s5
 582:	00000097          	auipc	ra,0x0
 586:	e48080e7          	jalr	-440(ra) # 3ca <putc>
  putc(fd, 'x');
 58a:	07800593          	li	a1,120
 58e:	8556                	mv	a0,s5
 590:	00000097          	auipc	ra,0x0
 594:	e3a080e7          	jalr	-454(ra) # 3ca <putc>
 598:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 59a:	00000b97          	auipc	s7,0x0
 59e:	34eb8b93          	addi	s7,s7,846 # 8e8 <digits>
 5a2:	03c9d793          	srli	a5,s3,0x3c
 5a6:	97de                	add	a5,a5,s7
 5a8:	0007c583          	lbu	a1,0(a5)
 5ac:	8556                	mv	a0,s5
 5ae:	00000097          	auipc	ra,0x0
 5b2:	e1c080e7          	jalr	-484(ra) # 3ca <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5b6:	0992                	slli	s3,s3,0x4
 5b8:	397d                	addiw	s2,s2,-1
 5ba:	fe0914e3          	bnez	s2,5a2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 5be:	8be2                	mv	s7,s8
      state = 0;
 5c0:	4981                	li	s3,0
 5c2:	6c02                	ld	s8,0(sp)
 5c4:	bf09                	j	4d6 <vprintf+0x42>
        s = va_arg(ap, char*);
 5c6:	008b8993          	addi	s3,s7,8
 5ca:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5ce:	02090163          	beqz	s2,5f0 <vprintf+0x15c>
        while(*s != 0){
 5d2:	00094583          	lbu	a1,0(s2)
 5d6:	c9a5                	beqz	a1,646 <vprintf+0x1b2>
          putc(fd, *s);
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	df0080e7          	jalr	-528(ra) # 3ca <putc>
          s++;
 5e2:	0905                	addi	s2,s2,1
        while(*s != 0){
 5e4:	00094583          	lbu	a1,0(s2)
 5e8:	f9e5                	bnez	a1,5d8 <vprintf+0x144>
        s = va_arg(ap, char*);
 5ea:	8bce                	mv	s7,s3
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	b5e5                	j	4d6 <vprintf+0x42>
          s = "(null)";
 5f0:	00000917          	auipc	s2,0x0
 5f4:	29890913          	addi	s2,s2,664 # 888 <malloc+0x13c>
        while(*s != 0){
 5f8:	02800593          	li	a1,40
 5fc:	bff1                	j	5d8 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 5fe:	008b8913          	addi	s2,s7,8
 602:	000bc583          	lbu	a1,0(s7)
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	dc2080e7          	jalr	-574(ra) # 3ca <putc>
 610:	8bca                	mv	s7,s2
      state = 0;
 612:	4981                	li	s3,0
 614:	b5c9                	j	4d6 <vprintf+0x42>
        putc(fd, c);
 616:	02500593          	li	a1,37
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	dae080e7          	jalr	-594(ra) # 3ca <putc>
      state = 0;
 624:	4981                	li	s3,0
 626:	bd45                	j	4d6 <vprintf+0x42>
        putc(fd, '%');
 628:	02500593          	li	a1,37
 62c:	8556                	mv	a0,s5
 62e:	00000097          	auipc	ra,0x0
 632:	d9c080e7          	jalr	-612(ra) # 3ca <putc>
        putc(fd, c);
 636:	85ca                	mv	a1,s2
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	d90080e7          	jalr	-624(ra) # 3ca <putc>
      state = 0;
 642:	4981                	li	s3,0
 644:	bd49                	j	4d6 <vprintf+0x42>
        s = va_arg(ap, char*);
 646:	8bce                	mv	s7,s3
      state = 0;
 648:	4981                	li	s3,0
 64a:	b571                	j	4d6 <vprintf+0x42>
 64c:	74e2                	ld	s1,56(sp)
 64e:	79a2                	ld	s3,40(sp)
 650:	7a02                	ld	s4,32(sp)
 652:	6ae2                	ld	s5,24(sp)
 654:	6b42                	ld	s6,16(sp)
 656:	6ba2                	ld	s7,8(sp)
    }
  }
}
 658:	60a6                	ld	ra,72(sp)
 65a:	6406                	ld	s0,64(sp)
 65c:	7942                	ld	s2,48(sp)
 65e:	6161                	addi	sp,sp,80
 660:	8082                	ret

0000000000000662 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 662:	715d                	addi	sp,sp,-80
 664:	ec06                	sd	ra,24(sp)
 666:	e822                	sd	s0,16(sp)
 668:	1000                	addi	s0,sp,32
 66a:	e010                	sd	a2,0(s0)
 66c:	e414                	sd	a3,8(s0)
 66e:	e818                	sd	a4,16(s0)
 670:	ec1c                	sd	a5,24(s0)
 672:	03043023          	sd	a6,32(s0)
 676:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 67a:	8622                	mv	a2,s0
 67c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 680:	00000097          	auipc	ra,0x0
 684:	e14080e7          	jalr	-492(ra) # 494 <vprintf>
}
 688:	60e2                	ld	ra,24(sp)
 68a:	6442                	ld	s0,16(sp)
 68c:	6161                	addi	sp,sp,80
 68e:	8082                	ret

0000000000000690 <printf>:

void
printf(const char *fmt, ...)
{
 690:	711d                	addi	sp,sp,-96
 692:	ec06                	sd	ra,24(sp)
 694:	e822                	sd	s0,16(sp)
 696:	1000                	addi	s0,sp,32
 698:	e40c                	sd	a1,8(s0)
 69a:	e810                	sd	a2,16(s0)
 69c:	ec14                	sd	a3,24(s0)
 69e:	f018                	sd	a4,32(s0)
 6a0:	f41c                	sd	a5,40(s0)
 6a2:	03043823          	sd	a6,48(s0)
 6a6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6aa:	00840613          	addi	a2,s0,8
 6ae:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6b2:	85aa                	mv	a1,a0
 6b4:	4505                	li	a0,1
 6b6:	00000097          	auipc	ra,0x0
 6ba:	dde080e7          	jalr	-546(ra) # 494 <vprintf>
}
 6be:	60e2                	ld	ra,24(sp)
 6c0:	6442                	ld	s0,16(sp)
 6c2:	6125                	addi	sp,sp,96
 6c4:	8082                	ret

00000000000006c6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6c6:	1141                	addi	sp,sp,-16
 6c8:	e406                	sd	ra,8(sp)
 6ca:	e022                	sd	s0,0(sp)
 6cc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ce:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d2:	00001797          	auipc	a5,0x1
 6d6:	92e7b783          	ld	a5,-1746(a5) # 1000 <freep>
 6da:	a039                	j	6e8 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6dc:	6398                	ld	a4,0(a5)
 6de:	00e7e463          	bltu	a5,a4,6e6 <free+0x20>
 6e2:	00e6ea63          	bltu	a3,a4,6f6 <free+0x30>
{
 6e6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e8:	fed7fae3          	bgeu	a5,a3,6dc <free+0x16>
 6ec:	6398                	ld	a4,0(a5)
 6ee:	00e6e463          	bltu	a3,a4,6f6 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f2:	fee7eae3          	bltu	a5,a4,6e6 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6f6:	ff852583          	lw	a1,-8(a0)
 6fa:	6390                	ld	a2,0(a5)
 6fc:	02059813          	slli	a6,a1,0x20
 700:	01c85713          	srli	a4,a6,0x1c
 704:	9736                	add	a4,a4,a3
 706:	02e60563          	beq	a2,a4,730 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 70a:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 70e:	4790                	lw	a2,8(a5)
 710:	02061593          	slli	a1,a2,0x20
 714:	01c5d713          	srli	a4,a1,0x1c
 718:	973e                	add	a4,a4,a5
 71a:	02e68263          	beq	a3,a4,73e <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 71e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 720:	00001717          	auipc	a4,0x1
 724:	8ef73023          	sd	a5,-1824(a4) # 1000 <freep>
}
 728:	60a2                	ld	ra,8(sp)
 72a:	6402                	ld	s0,0(sp)
 72c:	0141                	addi	sp,sp,16
 72e:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 730:	4618                	lw	a4,8(a2)
 732:	9f2d                	addw	a4,a4,a1
 734:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 738:	6398                	ld	a4,0(a5)
 73a:	6310                	ld	a2,0(a4)
 73c:	b7f9                	j	70a <free+0x44>
    p->s.size += bp->s.size;
 73e:	ff852703          	lw	a4,-8(a0)
 742:	9f31                	addw	a4,a4,a2
 744:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 746:	ff053683          	ld	a3,-16(a0)
 74a:	bfd1                	j	71e <free+0x58>

000000000000074c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 74c:	7139                	addi	sp,sp,-64
 74e:	fc06                	sd	ra,56(sp)
 750:	f822                	sd	s0,48(sp)
 752:	f04a                	sd	s2,32(sp)
 754:	ec4e                	sd	s3,24(sp)
 756:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 758:	02051993          	slli	s3,a0,0x20
 75c:	0209d993          	srli	s3,s3,0x20
 760:	09bd                	addi	s3,s3,15
 762:	0049d993          	srli	s3,s3,0x4
 766:	2985                	addiw	s3,s3,1
 768:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 76a:	00001517          	auipc	a0,0x1
 76e:	89653503          	ld	a0,-1898(a0) # 1000 <freep>
 772:	c905                	beqz	a0,7a2 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 774:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 776:	4798                	lw	a4,8(a5)
 778:	09377a63          	bgeu	a4,s3,80c <malloc+0xc0>
 77c:	f426                	sd	s1,40(sp)
 77e:	e852                	sd	s4,16(sp)
 780:	e456                	sd	s5,8(sp)
 782:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 784:	8a4e                	mv	s4,s3
 786:	6705                	lui	a4,0x1
 788:	00e9f363          	bgeu	s3,a4,78e <malloc+0x42>
 78c:	6a05                	lui	s4,0x1
 78e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 792:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 796:	00001497          	auipc	s1,0x1
 79a:	86a48493          	addi	s1,s1,-1942 # 1000 <freep>
  if(p == (char*)-1)
 79e:	5afd                	li	s5,-1
 7a0:	a089                	j	7e2 <malloc+0x96>
 7a2:	f426                	sd	s1,40(sp)
 7a4:	e852                	sd	s4,16(sp)
 7a6:	e456                	sd	s5,8(sp)
 7a8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7aa:	00001797          	auipc	a5,0x1
 7ae:	86678793          	addi	a5,a5,-1946 # 1010 <base>
 7b2:	00001717          	auipc	a4,0x1
 7b6:	84f73723          	sd	a5,-1970(a4) # 1000 <freep>
 7ba:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7bc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7c0:	b7d1                	j	784 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 7c2:	6398                	ld	a4,0(a5)
 7c4:	e118                	sd	a4,0(a0)
 7c6:	a8b9                	j	824 <malloc+0xd8>
  hp->s.size = nu;
 7c8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7cc:	0541                	addi	a0,a0,16
 7ce:	00000097          	auipc	ra,0x0
 7d2:	ef8080e7          	jalr	-264(ra) # 6c6 <free>
  return freep;
 7d6:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 7d8:	c135                	beqz	a0,83c <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7dc:	4798                	lw	a4,8(a5)
 7de:	03277363          	bgeu	a4,s2,804 <malloc+0xb8>
    if(p == freep)
 7e2:	6098                	ld	a4,0(s1)
 7e4:	853e                	mv	a0,a5
 7e6:	fef71ae3          	bne	a4,a5,7da <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 7ea:	8552                	mv	a0,s4
 7ec:	00000097          	auipc	ra,0x0
 7f0:	bbe080e7          	jalr	-1090(ra) # 3aa <sbrk>
  if(p == (char*)-1)
 7f4:	fd551ae3          	bne	a0,s5,7c8 <malloc+0x7c>
        return 0;
 7f8:	4501                	li	a0,0
 7fa:	74a2                	ld	s1,40(sp)
 7fc:	6a42                	ld	s4,16(sp)
 7fe:	6aa2                	ld	s5,8(sp)
 800:	6b02                	ld	s6,0(sp)
 802:	a03d                	j	830 <malloc+0xe4>
 804:	74a2                	ld	s1,40(sp)
 806:	6a42                	ld	s4,16(sp)
 808:	6aa2                	ld	s5,8(sp)
 80a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 80c:	fae90be3          	beq	s2,a4,7c2 <malloc+0x76>
        p->s.size -= nunits;
 810:	4137073b          	subw	a4,a4,s3
 814:	c798                	sw	a4,8(a5)
        p += p->s.size;
 816:	02071693          	slli	a3,a4,0x20
 81a:	01c6d713          	srli	a4,a3,0x1c
 81e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 820:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 824:	00000717          	auipc	a4,0x0
 828:	7ca73e23          	sd	a0,2012(a4) # 1000 <freep>
      return (void*)(p + 1);
 82c:	01078513          	addi	a0,a5,16
  }
}
 830:	70e2                	ld	ra,56(sp)
 832:	7442                	ld	s0,48(sp)
 834:	7902                	ld	s2,32(sp)
 836:	69e2                	ld	s3,24(sp)
 838:	6121                	addi	sp,sp,64
 83a:	8082                	ret
 83c:	74a2                	ld	s1,40(sp)
 83e:	6a42                	ld	s4,16(sp)
 840:	6aa2                	ld	s5,8(sp)
 842:	6b02                	ld	s6,0(sp)
 844:	b7f5                	j	830 <malloc+0xe4>
