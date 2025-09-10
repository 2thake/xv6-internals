
user/_ln:     file format elf64-littleriscv


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
  if(argc != 3){
   8:	478d                	li	a5,3
   a:	02f50163          	beq	a0,a5,2c <main+0x2c>
   e:	e426                	sd	s1,8(sp)
    fprintf(2, "Usage: ln old new\n");
  10:	00001597          	auipc	a1,0x1
  14:	82058593          	addi	a1,a1,-2016 # 830 <malloc+0xfc>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	630080e7          	jalr	1584(ra) # 64a <fprintf>
    exit(1);
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	2e6080e7          	jalr	742(ra) # 30a <exit>
  2c:	e426                	sd	s1,8(sp)
  2e:	84ae                	mv	s1,a1
  }
  if(link(argv[1], argv[2]) < 0)
  30:	698c                	ld	a1,16(a1)
  32:	6488                	ld	a0,8(s1)
  34:	00000097          	auipc	ra,0x0
  38:	336080e7          	jalr	822(ra) # 36a <link>
  3c:	00054763          	bltz	a0,4a <main+0x4a>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  40:	4501                	li	a0,0
  42:	00000097          	auipc	ra,0x0
  46:	2c8080e7          	jalr	712(ra) # 30a <exit>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  4a:	6894                	ld	a3,16(s1)
  4c:	6490                	ld	a2,8(s1)
  4e:	00000597          	auipc	a1,0x0
  52:	7fa58593          	addi	a1,a1,2042 # 848 <malloc+0x114>
  56:	4509                	li	a0,2
  58:	00000097          	auipc	ra,0x0
  5c:	5f2080e7          	jalr	1522(ra) # 64a <fprintf>
  60:	b7c5                	j	40 <main+0x40>

0000000000000062 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  62:	1141                	addi	sp,sp,-16
  64:	e406                	sd	ra,8(sp)
  66:	e022                	sd	s0,0(sp)
  68:	0800                	addi	s0,sp,16
  extern int main();
  main();
  6a:	00000097          	auipc	ra,0x0
  6e:	f96080e7          	jalr	-106(ra) # 0 <main>
  exit(0);
  72:	4501                	li	a0,0
  74:	00000097          	auipc	ra,0x0
  78:	296080e7          	jalr	662(ra) # 30a <exit>

000000000000007c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  7c:	1141                	addi	sp,sp,-16
  7e:	e406                	sd	ra,8(sp)
  80:	e022                	sd	s0,0(sp)
  82:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  84:	87aa                	mv	a5,a0
  86:	0585                	addi	a1,a1,1
  88:	0785                	addi	a5,a5,1
  8a:	fff5c703          	lbu	a4,-1(a1)
  8e:	fee78fa3          	sb	a4,-1(a5)
  92:	fb75                	bnez	a4,86 <strcpy+0xa>
    ;
  return os;
}
  94:	60a2                	ld	ra,8(sp)
  96:	6402                	ld	s0,0(sp)
  98:	0141                	addi	sp,sp,16
  9a:	8082                	ret

000000000000009c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  9c:	1141                	addi	sp,sp,-16
  9e:	e406                	sd	ra,8(sp)
  a0:	e022                	sd	s0,0(sp)
  a2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a4:	00054783          	lbu	a5,0(a0)
  a8:	cb91                	beqz	a5,bc <strcmp+0x20>
  aa:	0005c703          	lbu	a4,0(a1)
  ae:	00f71763          	bne	a4,a5,bc <strcmp+0x20>
    p++, q++;
  b2:	0505                	addi	a0,a0,1
  b4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b6:	00054783          	lbu	a5,0(a0)
  ba:	fbe5                	bnez	a5,aa <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  bc:	0005c503          	lbu	a0,0(a1)
}
  c0:	40a7853b          	subw	a0,a5,a0
  c4:	60a2                	ld	ra,8(sp)
  c6:	6402                	ld	s0,0(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret

00000000000000cc <strlen>:

uint
strlen(const char *s)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e406                	sd	ra,8(sp)
  d0:	e022                	sd	s0,0(sp)
  d2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d4:	00054783          	lbu	a5,0(a0)
  d8:	cf91                	beqz	a5,f4 <strlen+0x28>
  da:	00150793          	addi	a5,a0,1
  de:	86be                	mv	a3,a5
  e0:	0785                	addi	a5,a5,1
  e2:	fff7c703          	lbu	a4,-1(a5)
  e6:	ff65                	bnez	a4,de <strlen+0x12>
  e8:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  ec:	60a2                	ld	ra,8(sp)
  ee:	6402                	ld	s0,0(sp)
  f0:	0141                	addi	sp,sp,16
  f2:	8082                	ret
  for(n = 0; s[n]; n++)
  f4:	4501                	li	a0,0
  f6:	bfdd                	j	ec <strlen+0x20>

00000000000000f8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e406                	sd	ra,8(sp)
  fc:	e022                	sd	s0,0(sp)
  fe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 100:	ca19                	beqz	a2,116 <memset+0x1e>
 102:	87aa                	mv	a5,a0
 104:	1602                	slli	a2,a2,0x20
 106:	9201                	srli	a2,a2,0x20
 108:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 10c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 110:	0785                	addi	a5,a5,1
 112:	fee79de3          	bne	a5,a4,10c <memset+0x14>
  }
  return dst;
}
 116:	60a2                	ld	ra,8(sp)
 118:	6402                	ld	s0,0(sp)
 11a:	0141                	addi	sp,sp,16
 11c:	8082                	ret

000000000000011e <strchr>:

char*
strchr(const char *s, char c)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e406                	sd	ra,8(sp)
 122:	e022                	sd	s0,0(sp)
 124:	0800                	addi	s0,sp,16
  for(; *s; s++)
 126:	00054783          	lbu	a5,0(a0)
 12a:	cf81                	beqz	a5,142 <strchr+0x24>
    if(*s == c)
 12c:	00f58763          	beq	a1,a5,13a <strchr+0x1c>
  for(; *s; s++)
 130:	0505                	addi	a0,a0,1
 132:	00054783          	lbu	a5,0(a0)
 136:	fbfd                	bnez	a5,12c <strchr+0xe>
      return (char*)s;
  return 0;
 138:	4501                	li	a0,0
}
 13a:	60a2                	ld	ra,8(sp)
 13c:	6402                	ld	s0,0(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret
  return 0;
 142:	4501                	li	a0,0
 144:	bfdd                	j	13a <strchr+0x1c>

0000000000000146 <gets>:

char*
gets(char *buf, int max)
{
 146:	711d                	addi	sp,sp,-96
 148:	ec86                	sd	ra,88(sp)
 14a:	e8a2                	sd	s0,80(sp)
 14c:	e4a6                	sd	s1,72(sp)
 14e:	e0ca                	sd	s2,64(sp)
 150:	fc4e                	sd	s3,56(sp)
 152:	f852                	sd	s4,48(sp)
 154:	f456                	sd	s5,40(sp)
 156:	f05a                	sd	s6,32(sp)
 158:	ec5e                	sd	s7,24(sp)
 15a:	e862                	sd	s8,16(sp)
 15c:	1080                	addi	s0,sp,96
 15e:	8baa                	mv	s7,a0
 160:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 162:	892a                	mv	s2,a0
 164:	4481                	li	s1,0
    cc = read(0, &c, 1);
 166:	faf40b13          	addi	s6,s0,-81
 16a:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 16c:	8c26                	mv	s8,s1
 16e:	0014899b          	addiw	s3,s1,1
 172:	84ce                	mv	s1,s3
 174:	0349d663          	bge	s3,s4,1a0 <gets+0x5a>
    cc = read(0, &c, 1);
 178:	8656                	mv	a2,s5
 17a:	85da                	mv	a1,s6
 17c:	4501                	li	a0,0
 17e:	00000097          	auipc	ra,0x0
 182:	1a4080e7          	jalr	420(ra) # 322 <read>
    if(cc < 1)
 186:	00a05d63          	blez	a0,1a0 <gets+0x5a>
      break;
    buf[i++] = c;
 18a:	faf44783          	lbu	a5,-81(s0)
 18e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 192:	0905                	addi	s2,s2,1
 194:	ff678713          	addi	a4,a5,-10
 198:	c319                	beqz	a4,19e <gets+0x58>
 19a:	17cd                	addi	a5,a5,-13
 19c:	fbe1                	bnez	a5,16c <gets+0x26>
    buf[i++] = c;
 19e:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1a0:	9c5e                	add	s8,s8,s7
 1a2:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1a6:	855e                	mv	a0,s7
 1a8:	60e6                	ld	ra,88(sp)
 1aa:	6446                	ld	s0,80(sp)
 1ac:	64a6                	ld	s1,72(sp)
 1ae:	6906                	ld	s2,64(sp)
 1b0:	79e2                	ld	s3,56(sp)
 1b2:	7a42                	ld	s4,48(sp)
 1b4:	7aa2                	ld	s5,40(sp)
 1b6:	7b02                	ld	s6,32(sp)
 1b8:	6be2                	ld	s7,24(sp)
 1ba:	6c42                	ld	s8,16(sp)
 1bc:	6125                	addi	sp,sp,96
 1be:	8082                	ret

00000000000001c0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c0:	1101                	addi	sp,sp,-32
 1c2:	ec06                	sd	ra,24(sp)
 1c4:	e822                	sd	s0,16(sp)
 1c6:	e04a                	sd	s2,0(sp)
 1c8:	1000                	addi	s0,sp,32
 1ca:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1cc:	4581                	li	a1,0
 1ce:	00000097          	auipc	ra,0x0
 1d2:	17c080e7          	jalr	380(ra) # 34a <open>
  if(fd < 0)
 1d6:	02054663          	bltz	a0,202 <stat+0x42>
 1da:	e426                	sd	s1,8(sp)
 1dc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1de:	85ca                	mv	a1,s2
 1e0:	00000097          	auipc	ra,0x0
 1e4:	182080e7          	jalr	386(ra) # 362 <fstat>
 1e8:	892a                	mv	s2,a0
  close(fd);
 1ea:	8526                	mv	a0,s1
 1ec:	00000097          	auipc	ra,0x0
 1f0:	146080e7          	jalr	326(ra) # 332 <close>
  return r;
 1f4:	64a2                	ld	s1,8(sp)
}
 1f6:	854a                	mv	a0,s2
 1f8:	60e2                	ld	ra,24(sp)
 1fa:	6442                	ld	s0,16(sp)
 1fc:	6902                	ld	s2,0(sp)
 1fe:	6105                	addi	sp,sp,32
 200:	8082                	ret
    return -1;
 202:	57fd                	li	a5,-1
 204:	893e                	mv	s2,a5
 206:	bfc5                	j	1f6 <stat+0x36>

0000000000000208 <atoi>:

int
atoi(const char *s)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e406                	sd	ra,8(sp)
 20c:	e022                	sd	s0,0(sp)
 20e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 210:	00054683          	lbu	a3,0(a0)
 214:	fd06879b          	addiw	a5,a3,-48
 218:	0ff7f793          	zext.b	a5,a5
 21c:	4625                	li	a2,9
 21e:	02f66963          	bltu	a2,a5,250 <atoi+0x48>
 222:	872a                	mv	a4,a0
  n = 0;
 224:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 226:	0705                	addi	a4,a4,1
 228:	0025179b          	slliw	a5,a0,0x2
 22c:	9fa9                	addw	a5,a5,a0
 22e:	0017979b          	slliw	a5,a5,0x1
 232:	9fb5                	addw	a5,a5,a3
 234:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 238:	00074683          	lbu	a3,0(a4)
 23c:	fd06879b          	addiw	a5,a3,-48
 240:	0ff7f793          	zext.b	a5,a5
 244:	fef671e3          	bgeu	a2,a5,226 <atoi+0x1e>
  return n;
}
 248:	60a2                	ld	ra,8(sp)
 24a:	6402                	ld	s0,0(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret
  n = 0;
 250:	4501                	li	a0,0
 252:	bfdd                	j	248 <atoi+0x40>

0000000000000254 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 254:	1141                	addi	sp,sp,-16
 256:	e406                	sd	ra,8(sp)
 258:	e022                	sd	s0,0(sp)
 25a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 25c:	02b57563          	bgeu	a0,a1,286 <memmove+0x32>
    while(n-- > 0)
 260:	00c05f63          	blez	a2,27e <memmove+0x2a>
 264:	1602                	slli	a2,a2,0x20
 266:	9201                	srli	a2,a2,0x20
 268:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 26c:	872a                	mv	a4,a0
      *dst++ = *src++;
 26e:	0585                	addi	a1,a1,1
 270:	0705                	addi	a4,a4,1
 272:	fff5c683          	lbu	a3,-1(a1)
 276:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 27a:	fee79ae3          	bne	a5,a4,26e <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 27e:	60a2                	ld	ra,8(sp)
 280:	6402                	ld	s0,0(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret
    while(n-- > 0)
 286:	fec05ce3          	blez	a2,27e <memmove+0x2a>
    dst += n;
 28a:	00c50733          	add	a4,a0,a2
    src += n;
 28e:	95b2                	add	a1,a1,a2
 290:	fff6079b          	addiw	a5,a2,-1
 294:	1782                	slli	a5,a5,0x20
 296:	9381                	srli	a5,a5,0x20
 298:	fff7c793          	not	a5,a5
 29c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 29e:	15fd                	addi	a1,a1,-1
 2a0:	177d                	addi	a4,a4,-1
 2a2:	0005c683          	lbu	a3,0(a1)
 2a6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2aa:	fef71ae3          	bne	a4,a5,29e <memmove+0x4a>
 2ae:	bfc1                	j	27e <memmove+0x2a>

00000000000002b0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b0:	1141                	addi	sp,sp,-16
 2b2:	e406                	sd	ra,8(sp)
 2b4:	e022                	sd	s0,0(sp)
 2b6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2b8:	c61d                	beqz	a2,2e6 <memcmp+0x36>
 2ba:	1602                	slli	a2,a2,0x20
 2bc:	9201                	srli	a2,a2,0x20
 2be:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2c2:	00054783          	lbu	a5,0(a0)
 2c6:	0005c703          	lbu	a4,0(a1)
 2ca:	00e79863          	bne	a5,a4,2da <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2ce:	0505                	addi	a0,a0,1
    p2++;
 2d0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2d2:	fed518e3          	bne	a0,a3,2c2 <memcmp+0x12>
  }
  return 0;
 2d6:	4501                	li	a0,0
 2d8:	a019                	j	2de <memcmp+0x2e>
      return *p1 - *p2;
 2da:	40e7853b          	subw	a0,a5,a4
}
 2de:	60a2                	ld	ra,8(sp)
 2e0:	6402                	ld	s0,0(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
  return 0;
 2e6:	4501                	li	a0,0
 2e8:	bfdd                	j	2de <memcmp+0x2e>

00000000000002ea <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e406                	sd	ra,8(sp)
 2ee:	e022                	sd	s0,0(sp)
 2f0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2f2:	00000097          	auipc	ra,0x0
 2f6:	f62080e7          	jalr	-158(ra) # 254 <memmove>
}
 2fa:	60a2                	ld	ra,8(sp)
 2fc:	6402                	ld	s0,0(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret

0000000000000302 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 302:	4885                	li	a7,1
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <exit>:
.global exit
exit:
 li a7, SYS_exit
 30a:	4889                	li	a7,2
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <wait>:
.global wait
wait:
 li a7, SYS_wait
 312:	488d                	li	a7,3
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 31a:	4891                	li	a7,4
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <read>:
.global read
read:
 li a7, SYS_read
 322:	4895                	li	a7,5
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <write>:
.global write
write:
 li a7, SYS_write
 32a:	48c1                	li	a7,16
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <close>:
.global close
close:
 li a7, SYS_close
 332:	48d5                	li	a7,21
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <kill>:
.global kill
kill:
 li a7, SYS_kill
 33a:	4899                	li	a7,6
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <exec>:
.global exec
exec:
 li a7, SYS_exec
 342:	489d                	li	a7,7
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <open>:
.global open
open:
 li a7, SYS_open
 34a:	48bd                	li	a7,15
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 352:	48c5                	li	a7,17
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 35a:	48c9                	li	a7,18
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 362:	48a1                	li	a7,8
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <link>:
.global link
link:
 li a7, SYS_link
 36a:	48cd                	li	a7,19
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 372:	48d1                	li	a7,20
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 37a:	48a5                	li	a7,9
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <dup>:
.global dup
dup:
 li a7, SYS_dup
 382:	48a9                	li	a7,10
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 38a:	48ad                	li	a7,11
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 392:	48b1                	li	a7,12
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 39a:	48b5                	li	a7,13
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3a2:	48b9                	li	a7,14
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <nanotime>:
.global nanotime
nanotime:
 li a7, SYS_nanotime
 3aa:	48d9                	li	a7,22
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3b2:	1101                	addi	sp,sp,-32
 3b4:	ec06                	sd	ra,24(sp)
 3b6:	e822                	sd	s0,16(sp)
 3b8:	1000                	addi	s0,sp,32
 3ba:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3be:	4605                	li	a2,1
 3c0:	fef40593          	addi	a1,s0,-17
 3c4:	00000097          	auipc	ra,0x0
 3c8:	f66080e7          	jalr	-154(ra) # 32a <write>
}
 3cc:	60e2                	ld	ra,24(sp)
 3ce:	6442                	ld	s0,16(sp)
 3d0:	6105                	addi	sp,sp,32
 3d2:	8082                	ret

00000000000003d4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d4:	7139                	addi	sp,sp,-64
 3d6:	fc06                	sd	ra,56(sp)
 3d8:	f822                	sd	s0,48(sp)
 3da:	f04a                	sd	s2,32(sp)
 3dc:	ec4e                	sd	s3,24(sp)
 3de:	0080                	addi	s0,sp,64
 3e0:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3e2:	cad9                	beqz	a3,478 <printint+0xa4>
 3e4:	01f5d79b          	srliw	a5,a1,0x1f
 3e8:	cbc1                	beqz	a5,478 <printint+0xa4>
    neg = 1;
    x = -xx;
 3ea:	40b005bb          	negw	a1,a1
    neg = 1;
 3ee:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 3f0:	fc040993          	addi	s3,s0,-64
  neg = 0;
 3f4:	86ce                	mv	a3,s3
  i = 0;
 3f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3f8:	00000817          	auipc	a6,0x0
 3fc:	4c880813          	addi	a6,a6,1224 # 8c0 <digits>
 400:	88ba                	mv	a7,a4
 402:	0017051b          	addiw	a0,a4,1
 406:	872a                	mv	a4,a0
 408:	02c5f7bb          	remuw	a5,a1,a2
 40c:	1782                	slli	a5,a5,0x20
 40e:	9381                	srli	a5,a5,0x20
 410:	97c2                	add	a5,a5,a6
 412:	0007c783          	lbu	a5,0(a5)
 416:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 41a:	87ae                	mv	a5,a1
 41c:	02c5d5bb          	divuw	a1,a1,a2
 420:	0685                	addi	a3,a3,1
 422:	fcc7ffe3          	bgeu	a5,a2,400 <printint+0x2c>
  if(neg)
 426:	00030c63          	beqz	t1,43e <printint+0x6a>
    buf[i++] = '-';
 42a:	fd050793          	addi	a5,a0,-48
 42e:	00878533          	add	a0,a5,s0
 432:	02d00793          	li	a5,45
 436:	fef50823          	sb	a5,-16(a0)
 43a:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 43e:	02e05763          	blez	a4,46c <printint+0x98>
 442:	f426                	sd	s1,40(sp)
 444:	377d                	addiw	a4,a4,-1
 446:	00e984b3          	add	s1,s3,a4
 44a:	19fd                	addi	s3,s3,-1
 44c:	99ba                	add	s3,s3,a4
 44e:	1702                	slli	a4,a4,0x20
 450:	9301                	srli	a4,a4,0x20
 452:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 456:	0004c583          	lbu	a1,0(s1)
 45a:	854a                	mv	a0,s2
 45c:	00000097          	auipc	ra,0x0
 460:	f56080e7          	jalr	-170(ra) # 3b2 <putc>
  while(--i >= 0)
 464:	14fd                	addi	s1,s1,-1
 466:	ff3498e3          	bne	s1,s3,456 <printint+0x82>
 46a:	74a2                	ld	s1,40(sp)
}
 46c:	70e2                	ld	ra,56(sp)
 46e:	7442                	ld	s0,48(sp)
 470:	7902                	ld	s2,32(sp)
 472:	69e2                	ld	s3,24(sp)
 474:	6121                	addi	sp,sp,64
 476:	8082                	ret
  neg = 0;
 478:	4301                	li	t1,0
 47a:	bf9d                	j	3f0 <printint+0x1c>

000000000000047c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 47c:	715d                	addi	sp,sp,-80
 47e:	e486                	sd	ra,72(sp)
 480:	e0a2                	sd	s0,64(sp)
 482:	f84a                	sd	s2,48(sp)
 484:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 486:	0005c903          	lbu	s2,0(a1)
 48a:	1a090b63          	beqz	s2,640 <vprintf+0x1c4>
 48e:	fc26                	sd	s1,56(sp)
 490:	f44e                	sd	s3,40(sp)
 492:	f052                	sd	s4,32(sp)
 494:	ec56                	sd	s5,24(sp)
 496:	e85a                	sd	s6,16(sp)
 498:	e45e                	sd	s7,8(sp)
 49a:	8aaa                	mv	s5,a0
 49c:	8bb2                	mv	s7,a2
 49e:	00158493          	addi	s1,a1,1
  state = 0;
 4a2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4a4:	02500a13          	li	s4,37
 4a8:	4b55                	li	s6,21
 4aa:	a839                	j	4c8 <vprintf+0x4c>
        putc(fd, c);
 4ac:	85ca                	mv	a1,s2
 4ae:	8556                	mv	a0,s5
 4b0:	00000097          	auipc	ra,0x0
 4b4:	f02080e7          	jalr	-254(ra) # 3b2 <putc>
 4b8:	a019                	j	4be <vprintf+0x42>
    } else if(state == '%'){
 4ba:	01498d63          	beq	s3,s4,4d4 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4be:	0485                	addi	s1,s1,1
 4c0:	fff4c903          	lbu	s2,-1(s1)
 4c4:	16090863          	beqz	s2,634 <vprintf+0x1b8>
    if(state == 0){
 4c8:	fe0999e3          	bnez	s3,4ba <vprintf+0x3e>
      if(c == '%'){
 4cc:	ff4910e3          	bne	s2,s4,4ac <vprintf+0x30>
        state = '%';
 4d0:	89d2                	mv	s3,s4
 4d2:	b7f5                	j	4be <vprintf+0x42>
      if(c == 'd'){
 4d4:	13490563          	beq	s2,s4,5fe <vprintf+0x182>
 4d8:	f9d9079b          	addiw	a5,s2,-99
 4dc:	0ff7f793          	zext.b	a5,a5
 4e0:	12fb6863          	bltu	s6,a5,610 <vprintf+0x194>
 4e4:	f9d9079b          	addiw	a5,s2,-99
 4e8:	0ff7f713          	zext.b	a4,a5
 4ec:	12eb6263          	bltu	s6,a4,610 <vprintf+0x194>
 4f0:	00271793          	slli	a5,a4,0x2
 4f4:	00000717          	auipc	a4,0x0
 4f8:	37470713          	addi	a4,a4,884 # 868 <malloc+0x134>
 4fc:	97ba                	add	a5,a5,a4
 4fe:	439c                	lw	a5,0(a5)
 500:	97ba                	add	a5,a5,a4
 502:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 504:	008b8913          	addi	s2,s7,8
 508:	4685                	li	a3,1
 50a:	4629                	li	a2,10
 50c:	000ba583          	lw	a1,0(s7)
 510:	8556                	mv	a0,s5
 512:	00000097          	auipc	ra,0x0
 516:	ec2080e7          	jalr	-318(ra) # 3d4 <printint>
 51a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 51c:	4981                	li	s3,0
 51e:	b745                	j	4be <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 520:	008b8913          	addi	s2,s7,8
 524:	4681                	li	a3,0
 526:	4629                	li	a2,10
 528:	000ba583          	lw	a1,0(s7)
 52c:	8556                	mv	a0,s5
 52e:	00000097          	auipc	ra,0x0
 532:	ea6080e7          	jalr	-346(ra) # 3d4 <printint>
 536:	8bca                	mv	s7,s2
      state = 0;
 538:	4981                	li	s3,0
 53a:	b751                	j	4be <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 53c:	008b8913          	addi	s2,s7,8
 540:	4681                	li	a3,0
 542:	4641                	li	a2,16
 544:	000ba583          	lw	a1,0(s7)
 548:	8556                	mv	a0,s5
 54a:	00000097          	auipc	ra,0x0
 54e:	e8a080e7          	jalr	-374(ra) # 3d4 <printint>
 552:	8bca                	mv	s7,s2
      state = 0;
 554:	4981                	li	s3,0
 556:	b7a5                	j	4be <vprintf+0x42>
 558:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 55a:	008b8793          	addi	a5,s7,8
 55e:	8c3e                	mv	s8,a5
 560:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 564:	03000593          	li	a1,48
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	e48080e7          	jalr	-440(ra) # 3b2 <putc>
  putc(fd, 'x');
 572:	07800593          	li	a1,120
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	e3a080e7          	jalr	-454(ra) # 3b2 <putc>
 580:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 582:	00000b97          	auipc	s7,0x0
 586:	33eb8b93          	addi	s7,s7,830 # 8c0 <digits>
 58a:	03c9d793          	srli	a5,s3,0x3c
 58e:	97de                	add	a5,a5,s7
 590:	0007c583          	lbu	a1,0(a5)
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	e1c080e7          	jalr	-484(ra) # 3b2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 59e:	0992                	slli	s3,s3,0x4
 5a0:	397d                	addiw	s2,s2,-1
 5a2:	fe0914e3          	bnez	s2,58a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 5a6:	8be2                	mv	s7,s8
      state = 0;
 5a8:	4981                	li	s3,0
 5aa:	6c02                	ld	s8,0(sp)
 5ac:	bf09                	j	4be <vprintf+0x42>
        s = va_arg(ap, char*);
 5ae:	008b8993          	addi	s3,s7,8
 5b2:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5b6:	02090163          	beqz	s2,5d8 <vprintf+0x15c>
        while(*s != 0){
 5ba:	00094583          	lbu	a1,0(s2)
 5be:	c9a5                	beqz	a1,62e <vprintf+0x1b2>
          putc(fd, *s);
 5c0:	8556                	mv	a0,s5
 5c2:	00000097          	auipc	ra,0x0
 5c6:	df0080e7          	jalr	-528(ra) # 3b2 <putc>
          s++;
 5ca:	0905                	addi	s2,s2,1
        while(*s != 0){
 5cc:	00094583          	lbu	a1,0(s2)
 5d0:	f9e5                	bnez	a1,5c0 <vprintf+0x144>
        s = va_arg(ap, char*);
 5d2:	8bce                	mv	s7,s3
      state = 0;
 5d4:	4981                	li	s3,0
 5d6:	b5e5                	j	4be <vprintf+0x42>
          s = "(null)";
 5d8:	00000917          	auipc	s2,0x0
 5dc:	28890913          	addi	s2,s2,648 # 860 <malloc+0x12c>
        while(*s != 0){
 5e0:	02800593          	li	a1,40
 5e4:	bff1                	j	5c0 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 5e6:	008b8913          	addi	s2,s7,8
 5ea:	000bc583          	lbu	a1,0(s7)
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	dc2080e7          	jalr	-574(ra) # 3b2 <putc>
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	b5c9                	j	4be <vprintf+0x42>
        putc(fd, c);
 5fe:	02500593          	li	a1,37
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	dae080e7          	jalr	-594(ra) # 3b2 <putc>
      state = 0;
 60c:	4981                	li	s3,0
 60e:	bd45                	j	4be <vprintf+0x42>
        putc(fd, '%');
 610:	02500593          	li	a1,37
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	d9c080e7          	jalr	-612(ra) # 3b2 <putc>
        putc(fd, c);
 61e:	85ca                	mv	a1,s2
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	d90080e7          	jalr	-624(ra) # 3b2 <putc>
      state = 0;
 62a:	4981                	li	s3,0
 62c:	bd49                	j	4be <vprintf+0x42>
        s = va_arg(ap, char*);
 62e:	8bce                	mv	s7,s3
      state = 0;
 630:	4981                	li	s3,0
 632:	b571                	j	4be <vprintf+0x42>
 634:	74e2                	ld	s1,56(sp)
 636:	79a2                	ld	s3,40(sp)
 638:	7a02                	ld	s4,32(sp)
 63a:	6ae2                	ld	s5,24(sp)
 63c:	6b42                	ld	s6,16(sp)
 63e:	6ba2                	ld	s7,8(sp)
    }
  }
}
 640:	60a6                	ld	ra,72(sp)
 642:	6406                	ld	s0,64(sp)
 644:	7942                	ld	s2,48(sp)
 646:	6161                	addi	sp,sp,80
 648:	8082                	ret

000000000000064a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 64a:	715d                	addi	sp,sp,-80
 64c:	ec06                	sd	ra,24(sp)
 64e:	e822                	sd	s0,16(sp)
 650:	1000                	addi	s0,sp,32
 652:	e010                	sd	a2,0(s0)
 654:	e414                	sd	a3,8(s0)
 656:	e818                	sd	a4,16(s0)
 658:	ec1c                	sd	a5,24(s0)
 65a:	03043023          	sd	a6,32(s0)
 65e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 662:	8622                	mv	a2,s0
 664:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 668:	00000097          	auipc	ra,0x0
 66c:	e14080e7          	jalr	-492(ra) # 47c <vprintf>
}
 670:	60e2                	ld	ra,24(sp)
 672:	6442                	ld	s0,16(sp)
 674:	6161                	addi	sp,sp,80
 676:	8082                	ret

0000000000000678 <printf>:

void
printf(const char *fmt, ...)
{
 678:	711d                	addi	sp,sp,-96
 67a:	ec06                	sd	ra,24(sp)
 67c:	e822                	sd	s0,16(sp)
 67e:	1000                	addi	s0,sp,32
 680:	e40c                	sd	a1,8(s0)
 682:	e810                	sd	a2,16(s0)
 684:	ec14                	sd	a3,24(s0)
 686:	f018                	sd	a4,32(s0)
 688:	f41c                	sd	a5,40(s0)
 68a:	03043823          	sd	a6,48(s0)
 68e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 692:	00840613          	addi	a2,s0,8
 696:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 69a:	85aa                	mv	a1,a0
 69c:	4505                	li	a0,1
 69e:	00000097          	auipc	ra,0x0
 6a2:	dde080e7          	jalr	-546(ra) # 47c <vprintf>
}
 6a6:	60e2                	ld	ra,24(sp)
 6a8:	6442                	ld	s0,16(sp)
 6aa:	6125                	addi	sp,sp,96
 6ac:	8082                	ret

00000000000006ae <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ae:	1141                	addi	sp,sp,-16
 6b0:	e406                	sd	ra,8(sp)
 6b2:	e022                	sd	s0,0(sp)
 6b4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6b6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ba:	00001797          	auipc	a5,0x1
 6be:	9467b783          	ld	a5,-1722(a5) # 1000 <freep>
 6c2:	a039                	j	6d0 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c4:	6398                	ld	a4,0(a5)
 6c6:	00e7e463          	bltu	a5,a4,6ce <free+0x20>
 6ca:	00e6ea63          	bltu	a3,a4,6de <free+0x30>
{
 6ce:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d0:	fed7fae3          	bgeu	a5,a3,6c4 <free+0x16>
 6d4:	6398                	ld	a4,0(a5)
 6d6:	00e6e463          	bltu	a3,a4,6de <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6da:	fee7eae3          	bltu	a5,a4,6ce <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6de:	ff852583          	lw	a1,-8(a0)
 6e2:	6390                	ld	a2,0(a5)
 6e4:	02059813          	slli	a6,a1,0x20
 6e8:	01c85713          	srli	a4,a6,0x1c
 6ec:	9736                	add	a4,a4,a3
 6ee:	02e60563          	beq	a2,a4,718 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 6f2:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 6f6:	4790                	lw	a2,8(a5)
 6f8:	02061593          	slli	a1,a2,0x20
 6fc:	01c5d713          	srli	a4,a1,0x1c
 700:	973e                	add	a4,a4,a5
 702:	02e68263          	beq	a3,a4,726 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 706:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 708:	00001717          	auipc	a4,0x1
 70c:	8ef73c23          	sd	a5,-1800(a4) # 1000 <freep>
}
 710:	60a2                	ld	ra,8(sp)
 712:	6402                	ld	s0,0(sp)
 714:	0141                	addi	sp,sp,16
 716:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 718:	4618                	lw	a4,8(a2)
 71a:	9f2d                	addw	a4,a4,a1
 71c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 720:	6398                	ld	a4,0(a5)
 722:	6310                	ld	a2,0(a4)
 724:	b7f9                	j	6f2 <free+0x44>
    p->s.size += bp->s.size;
 726:	ff852703          	lw	a4,-8(a0)
 72a:	9f31                	addw	a4,a4,a2
 72c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 72e:	ff053683          	ld	a3,-16(a0)
 732:	bfd1                	j	706 <free+0x58>

0000000000000734 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 734:	7139                	addi	sp,sp,-64
 736:	fc06                	sd	ra,56(sp)
 738:	f822                	sd	s0,48(sp)
 73a:	f04a                	sd	s2,32(sp)
 73c:	ec4e                	sd	s3,24(sp)
 73e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 740:	02051993          	slli	s3,a0,0x20
 744:	0209d993          	srli	s3,s3,0x20
 748:	09bd                	addi	s3,s3,15
 74a:	0049d993          	srli	s3,s3,0x4
 74e:	2985                	addiw	s3,s3,1
 750:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 752:	00001517          	auipc	a0,0x1
 756:	8ae53503          	ld	a0,-1874(a0) # 1000 <freep>
 75a:	c905                	beqz	a0,78a <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 75c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 75e:	4798                	lw	a4,8(a5)
 760:	09377a63          	bgeu	a4,s3,7f4 <malloc+0xc0>
 764:	f426                	sd	s1,40(sp)
 766:	e852                	sd	s4,16(sp)
 768:	e456                	sd	s5,8(sp)
 76a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 76c:	8a4e                	mv	s4,s3
 76e:	6705                	lui	a4,0x1
 770:	00e9f363          	bgeu	s3,a4,776 <malloc+0x42>
 774:	6a05                	lui	s4,0x1
 776:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 77a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 77e:	00001497          	auipc	s1,0x1
 782:	88248493          	addi	s1,s1,-1918 # 1000 <freep>
  if(p == (char*)-1)
 786:	5afd                	li	s5,-1
 788:	a089                	j	7ca <malloc+0x96>
 78a:	f426                	sd	s1,40(sp)
 78c:	e852                	sd	s4,16(sp)
 78e:	e456                	sd	s5,8(sp)
 790:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 792:	00001797          	auipc	a5,0x1
 796:	87e78793          	addi	a5,a5,-1922 # 1010 <base>
 79a:	00001717          	auipc	a4,0x1
 79e:	86f73323          	sd	a5,-1946(a4) # 1000 <freep>
 7a2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7a4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7a8:	b7d1                	j	76c <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 7aa:	6398                	ld	a4,0(a5)
 7ac:	e118                	sd	a4,0(a0)
 7ae:	a8b9                	j	80c <malloc+0xd8>
  hp->s.size = nu;
 7b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7b4:	0541                	addi	a0,a0,16
 7b6:	00000097          	auipc	ra,0x0
 7ba:	ef8080e7          	jalr	-264(ra) # 6ae <free>
  return freep;
 7be:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 7c0:	c135                	beqz	a0,824 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7c4:	4798                	lw	a4,8(a5)
 7c6:	03277363          	bgeu	a4,s2,7ec <malloc+0xb8>
    if(p == freep)
 7ca:	6098                	ld	a4,0(s1)
 7cc:	853e                	mv	a0,a5
 7ce:	fef71ae3          	bne	a4,a5,7c2 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 7d2:	8552                	mv	a0,s4
 7d4:	00000097          	auipc	ra,0x0
 7d8:	bbe080e7          	jalr	-1090(ra) # 392 <sbrk>
  if(p == (char*)-1)
 7dc:	fd551ae3          	bne	a0,s5,7b0 <malloc+0x7c>
        return 0;
 7e0:	4501                	li	a0,0
 7e2:	74a2                	ld	s1,40(sp)
 7e4:	6a42                	ld	s4,16(sp)
 7e6:	6aa2                	ld	s5,8(sp)
 7e8:	6b02                	ld	s6,0(sp)
 7ea:	a03d                	j	818 <malloc+0xe4>
 7ec:	74a2                	ld	s1,40(sp)
 7ee:	6a42                	ld	s4,16(sp)
 7f0:	6aa2                	ld	s5,8(sp)
 7f2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7f4:	fae90be3          	beq	s2,a4,7aa <malloc+0x76>
        p->s.size -= nunits;
 7f8:	4137073b          	subw	a4,a4,s3
 7fc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7fe:	02071693          	slli	a3,a4,0x20
 802:	01c6d713          	srli	a4,a3,0x1c
 806:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 808:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 80c:	00000717          	auipc	a4,0x0
 810:	7ea73a23          	sd	a0,2036(a4) # 1000 <freep>
      return (void*)(p + 1);
 814:	01078513          	addi	a0,a5,16
  }
}
 818:	70e2                	ld	ra,56(sp)
 81a:	7442                	ld	s0,48(sp)
 81c:	7902                	ld	s2,32(sp)
 81e:	69e2                	ld	s3,24(sp)
 820:	6121                	addi	sp,sp,64
 822:	8082                	ret
 824:	74a2                	ld	s1,40(sp)
 826:	6a42                	ld	s4,16(sp)
 828:	6aa2                	ld	s5,8(sp)
 82a:	6b02                	ld	s6,0(sp)
 82c:	b7f5                	j	818 <malloc+0xe4>
