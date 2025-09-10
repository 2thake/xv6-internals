
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	dc010113          	addi	sp,sp,-576
   4:	22113c23          	sd	ra,568(sp)
   8:	22813823          	sd	s0,560(sp)
   c:	22913423          	sd	s1,552(sp)
  10:	23213023          	sd	s2,544(sp)
  14:	21313c23          	sd	s3,536(sp)
  18:	21413823          	sd	s4,528(sp)
  1c:	0480                	addi	s0,sp,576
  int fd, i;
  char path[] = "stressfs0";
  1e:	00001797          	auipc	a5,0x1
  22:	90278793          	addi	a5,a5,-1790 # 920 <malloc+0x132>
  26:	6398                	ld	a4,0(a5)
  28:	fce43023          	sd	a4,-64(s0)
  2c:	0087d783          	lhu	a5,8(a5)
  30:	fcf41423          	sh	a5,-56(s0)
  char data[512];

  printf("stressfs starting\n");
  34:	00001517          	auipc	a0,0x1
  38:	8bc50513          	addi	a0,a0,-1860 # 8f0 <malloc+0x102>
  3c:	00000097          	auipc	ra,0x0
  40:	6f6080e7          	jalr	1782(ra) # 732 <printf>
  memset(data, 'a', sizeof(data));
  44:	20000613          	li	a2,512
  48:	06100593          	li	a1,97
  4c:	dc040513          	addi	a0,s0,-576
  50:	00000097          	auipc	ra,0x0
  54:	162080e7          	jalr	354(ra) # 1b2 <memset>

  for(i = 0; i < 4; i++)
  58:	4481                	li	s1,0
  5a:	4911                	li	s2,4
    if(fork() > 0)
  5c:	00000097          	auipc	ra,0x0
  60:	360080e7          	jalr	864(ra) # 3bc <fork>
  64:	00a04563          	bgtz	a0,6e <main+0x6e>
  for(i = 0; i < 4; i++)
  68:	2485                	addiw	s1,s1,1
  6a:	ff2499e3          	bne	s1,s2,5c <main+0x5c>
      break;

  printf("write %d\n", i);
  6e:	85a6                	mv	a1,s1
  70:	00001517          	auipc	a0,0x1
  74:	89850513          	addi	a0,a0,-1896 # 908 <malloc+0x11a>
  78:	00000097          	auipc	ra,0x0
  7c:	6ba080e7          	jalr	1722(ra) # 732 <printf>

  path[8] += i;
  80:	fc844783          	lbu	a5,-56(s0)
  84:	9fa5                	addw	a5,a5,s1
  86:	fcf40423          	sb	a5,-56(s0)
  fd = open(path, O_CREATE | O_RDWR);
  8a:	20200593          	li	a1,514
  8e:	fc040513          	addi	a0,s0,-64
  92:	00000097          	auipc	ra,0x0
  96:	372080e7          	jalr	882(ra) # 404 <open>
  9a:	892a                	mv	s2,a0
  9c:	44d1                	li	s1,20
  for(i = 0; i < 20; i++)
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  9e:	dc040a13          	addi	s4,s0,-576
  a2:	20000993          	li	s3,512
  a6:	864e                	mv	a2,s3
  a8:	85d2                	mv	a1,s4
  aa:	854a                	mv	a0,s2
  ac:	00000097          	auipc	ra,0x0
  b0:	338080e7          	jalr	824(ra) # 3e4 <write>
  for(i = 0; i < 20; i++)
  b4:	34fd                	addiw	s1,s1,-1
  b6:	f8e5                	bnez	s1,a6 <main+0xa6>
  close(fd);
  b8:	854a                	mv	a0,s2
  ba:	00000097          	auipc	ra,0x0
  be:	332080e7          	jalr	818(ra) # 3ec <close>

  printf("read\n");
  c2:	00001517          	auipc	a0,0x1
  c6:	85650513          	addi	a0,a0,-1962 # 918 <malloc+0x12a>
  ca:	00000097          	auipc	ra,0x0
  ce:	668080e7          	jalr	1640(ra) # 732 <printf>

  fd = open(path, O_RDONLY);
  d2:	4581                	li	a1,0
  d4:	fc040513          	addi	a0,s0,-64
  d8:	00000097          	auipc	ra,0x0
  dc:	32c080e7          	jalr	812(ra) # 404 <open>
  e0:	892a                	mv	s2,a0
  e2:	44d1                	li	s1,20
  for (i = 0; i < 20; i++)
    read(fd, data, sizeof(data));
  e4:	dc040a13          	addi	s4,s0,-576
  e8:	20000993          	li	s3,512
  ec:	864e                	mv	a2,s3
  ee:	85d2                	mv	a1,s4
  f0:	854a                	mv	a0,s2
  f2:	00000097          	auipc	ra,0x0
  f6:	2ea080e7          	jalr	746(ra) # 3dc <read>
  for (i = 0; i < 20; i++)
  fa:	34fd                	addiw	s1,s1,-1
  fc:	f8e5                	bnez	s1,ec <main+0xec>
  close(fd);
  fe:	854a                	mv	a0,s2
 100:	00000097          	auipc	ra,0x0
 104:	2ec080e7          	jalr	748(ra) # 3ec <close>

  wait(0);
 108:	4501                	li	a0,0
 10a:	00000097          	auipc	ra,0x0
 10e:	2c2080e7          	jalr	706(ra) # 3cc <wait>

  exit(0);
 112:	4501                	li	a0,0
 114:	00000097          	auipc	ra,0x0
 118:	2b0080e7          	jalr	688(ra) # 3c4 <exit>

000000000000011c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e406                	sd	ra,8(sp)
 120:	e022                	sd	s0,0(sp)
 122:	0800                	addi	s0,sp,16
  extern int main();
  main();
 124:	00000097          	auipc	ra,0x0
 128:	edc080e7          	jalr	-292(ra) # 0 <main>
  exit(0);
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	296080e7          	jalr	662(ra) # 3c4 <exit>

0000000000000136 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 136:	1141                	addi	sp,sp,-16
 138:	e406                	sd	ra,8(sp)
 13a:	e022                	sd	s0,0(sp)
 13c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13e:	87aa                	mv	a5,a0
 140:	0585                	addi	a1,a1,1
 142:	0785                	addi	a5,a5,1
 144:	fff5c703          	lbu	a4,-1(a1)
 148:	fee78fa3          	sb	a4,-1(a5)
 14c:	fb75                	bnez	a4,140 <strcpy+0xa>
    ;
  return os;
}
 14e:	60a2                	ld	ra,8(sp)
 150:	6402                	ld	s0,0(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret

0000000000000156 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 156:	1141                	addi	sp,sp,-16
 158:	e406                	sd	ra,8(sp)
 15a:	e022                	sd	s0,0(sp)
 15c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 15e:	00054783          	lbu	a5,0(a0)
 162:	cb91                	beqz	a5,176 <strcmp+0x20>
 164:	0005c703          	lbu	a4,0(a1)
 168:	00f71763          	bne	a4,a5,176 <strcmp+0x20>
    p++, q++;
 16c:	0505                	addi	a0,a0,1
 16e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 170:	00054783          	lbu	a5,0(a0)
 174:	fbe5                	bnez	a5,164 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 176:	0005c503          	lbu	a0,0(a1)
}
 17a:	40a7853b          	subw	a0,a5,a0
 17e:	60a2                	ld	ra,8(sp)
 180:	6402                	ld	s0,0(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret

0000000000000186 <strlen>:

uint
strlen(const char *s)
{
 186:	1141                	addi	sp,sp,-16
 188:	e406                	sd	ra,8(sp)
 18a:	e022                	sd	s0,0(sp)
 18c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 18e:	00054783          	lbu	a5,0(a0)
 192:	cf91                	beqz	a5,1ae <strlen+0x28>
 194:	00150793          	addi	a5,a0,1
 198:	86be                	mv	a3,a5
 19a:	0785                	addi	a5,a5,1
 19c:	fff7c703          	lbu	a4,-1(a5)
 1a0:	ff65                	bnez	a4,198 <strlen+0x12>
 1a2:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 1a6:	60a2                	ld	ra,8(sp)
 1a8:	6402                	ld	s0,0(sp)
 1aa:	0141                	addi	sp,sp,16
 1ac:	8082                	ret
  for(n = 0; s[n]; n++)
 1ae:	4501                	li	a0,0
 1b0:	bfdd                	j	1a6 <strlen+0x20>

00000000000001b2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1b2:	1141                	addi	sp,sp,-16
 1b4:	e406                	sd	ra,8(sp)
 1b6:	e022                	sd	s0,0(sp)
 1b8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ba:	ca19                	beqz	a2,1d0 <memset+0x1e>
 1bc:	87aa                	mv	a5,a0
 1be:	1602                	slli	a2,a2,0x20
 1c0:	9201                	srli	a2,a2,0x20
 1c2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1c6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ca:	0785                	addi	a5,a5,1
 1cc:	fee79de3          	bne	a5,a4,1c6 <memset+0x14>
  }
  return dst;
}
 1d0:	60a2                	ld	ra,8(sp)
 1d2:	6402                	ld	s0,0(sp)
 1d4:	0141                	addi	sp,sp,16
 1d6:	8082                	ret

00000000000001d8 <strchr>:

char*
strchr(const char *s, char c)
{
 1d8:	1141                	addi	sp,sp,-16
 1da:	e406                	sd	ra,8(sp)
 1dc:	e022                	sd	s0,0(sp)
 1de:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1e0:	00054783          	lbu	a5,0(a0)
 1e4:	cf81                	beqz	a5,1fc <strchr+0x24>
    if(*s == c)
 1e6:	00f58763          	beq	a1,a5,1f4 <strchr+0x1c>
  for(; *s; s++)
 1ea:	0505                	addi	a0,a0,1
 1ec:	00054783          	lbu	a5,0(a0)
 1f0:	fbfd                	bnez	a5,1e6 <strchr+0xe>
      return (char*)s;
  return 0;
 1f2:	4501                	li	a0,0
}
 1f4:	60a2                	ld	ra,8(sp)
 1f6:	6402                	ld	s0,0(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret
  return 0;
 1fc:	4501                	li	a0,0
 1fe:	bfdd                	j	1f4 <strchr+0x1c>

0000000000000200 <gets>:

char*
gets(char *buf, int max)
{
 200:	711d                	addi	sp,sp,-96
 202:	ec86                	sd	ra,88(sp)
 204:	e8a2                	sd	s0,80(sp)
 206:	e4a6                	sd	s1,72(sp)
 208:	e0ca                	sd	s2,64(sp)
 20a:	fc4e                	sd	s3,56(sp)
 20c:	f852                	sd	s4,48(sp)
 20e:	f456                	sd	s5,40(sp)
 210:	f05a                	sd	s6,32(sp)
 212:	ec5e                	sd	s7,24(sp)
 214:	e862                	sd	s8,16(sp)
 216:	1080                	addi	s0,sp,96
 218:	8baa                	mv	s7,a0
 21a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21c:	892a                	mv	s2,a0
 21e:	4481                	li	s1,0
    cc = read(0, &c, 1);
 220:	faf40b13          	addi	s6,s0,-81
 224:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 226:	8c26                	mv	s8,s1
 228:	0014899b          	addiw	s3,s1,1
 22c:	84ce                	mv	s1,s3
 22e:	0349d663          	bge	s3,s4,25a <gets+0x5a>
    cc = read(0, &c, 1);
 232:	8656                	mv	a2,s5
 234:	85da                	mv	a1,s6
 236:	4501                	li	a0,0
 238:	00000097          	auipc	ra,0x0
 23c:	1a4080e7          	jalr	420(ra) # 3dc <read>
    if(cc < 1)
 240:	00a05d63          	blez	a0,25a <gets+0x5a>
      break;
    buf[i++] = c;
 244:	faf44783          	lbu	a5,-81(s0)
 248:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 24c:	0905                	addi	s2,s2,1
 24e:	ff678713          	addi	a4,a5,-10
 252:	c319                	beqz	a4,258 <gets+0x58>
 254:	17cd                	addi	a5,a5,-13
 256:	fbe1                	bnez	a5,226 <gets+0x26>
    buf[i++] = c;
 258:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 25a:	9c5e                	add	s8,s8,s7
 25c:	000c0023          	sb	zero,0(s8)
  return buf;
}
 260:	855e                	mv	a0,s7
 262:	60e6                	ld	ra,88(sp)
 264:	6446                	ld	s0,80(sp)
 266:	64a6                	ld	s1,72(sp)
 268:	6906                	ld	s2,64(sp)
 26a:	79e2                	ld	s3,56(sp)
 26c:	7a42                	ld	s4,48(sp)
 26e:	7aa2                	ld	s5,40(sp)
 270:	7b02                	ld	s6,32(sp)
 272:	6be2                	ld	s7,24(sp)
 274:	6c42                	ld	s8,16(sp)
 276:	6125                	addi	sp,sp,96
 278:	8082                	ret

000000000000027a <stat>:

int
stat(const char *n, struct stat *st)
{
 27a:	1101                	addi	sp,sp,-32
 27c:	ec06                	sd	ra,24(sp)
 27e:	e822                	sd	s0,16(sp)
 280:	e04a                	sd	s2,0(sp)
 282:	1000                	addi	s0,sp,32
 284:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 286:	4581                	li	a1,0
 288:	00000097          	auipc	ra,0x0
 28c:	17c080e7          	jalr	380(ra) # 404 <open>
  if(fd < 0)
 290:	02054663          	bltz	a0,2bc <stat+0x42>
 294:	e426                	sd	s1,8(sp)
 296:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 298:	85ca                	mv	a1,s2
 29a:	00000097          	auipc	ra,0x0
 29e:	182080e7          	jalr	386(ra) # 41c <fstat>
 2a2:	892a                	mv	s2,a0
  close(fd);
 2a4:	8526                	mv	a0,s1
 2a6:	00000097          	auipc	ra,0x0
 2aa:	146080e7          	jalr	326(ra) # 3ec <close>
  return r;
 2ae:	64a2                	ld	s1,8(sp)
}
 2b0:	854a                	mv	a0,s2
 2b2:	60e2                	ld	ra,24(sp)
 2b4:	6442                	ld	s0,16(sp)
 2b6:	6902                	ld	s2,0(sp)
 2b8:	6105                	addi	sp,sp,32
 2ba:	8082                	ret
    return -1;
 2bc:	57fd                	li	a5,-1
 2be:	893e                	mv	s2,a5
 2c0:	bfc5                	j	2b0 <stat+0x36>

00000000000002c2 <atoi>:

int
atoi(const char *s)
{
 2c2:	1141                	addi	sp,sp,-16
 2c4:	e406                	sd	ra,8(sp)
 2c6:	e022                	sd	s0,0(sp)
 2c8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ca:	00054683          	lbu	a3,0(a0)
 2ce:	fd06879b          	addiw	a5,a3,-48
 2d2:	0ff7f793          	zext.b	a5,a5
 2d6:	4625                	li	a2,9
 2d8:	02f66963          	bltu	a2,a5,30a <atoi+0x48>
 2dc:	872a                	mv	a4,a0
  n = 0;
 2de:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2e0:	0705                	addi	a4,a4,1
 2e2:	0025179b          	slliw	a5,a0,0x2
 2e6:	9fa9                	addw	a5,a5,a0
 2e8:	0017979b          	slliw	a5,a5,0x1
 2ec:	9fb5                	addw	a5,a5,a3
 2ee:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2f2:	00074683          	lbu	a3,0(a4)
 2f6:	fd06879b          	addiw	a5,a3,-48
 2fa:	0ff7f793          	zext.b	a5,a5
 2fe:	fef671e3          	bgeu	a2,a5,2e0 <atoi+0x1e>
  return n;
}
 302:	60a2                	ld	ra,8(sp)
 304:	6402                	ld	s0,0(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret
  n = 0;
 30a:	4501                	li	a0,0
 30c:	bfdd                	j	302 <atoi+0x40>

000000000000030e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e406                	sd	ra,8(sp)
 312:	e022                	sd	s0,0(sp)
 314:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 316:	02b57563          	bgeu	a0,a1,340 <memmove+0x32>
    while(n-- > 0)
 31a:	00c05f63          	blez	a2,338 <memmove+0x2a>
 31e:	1602                	slli	a2,a2,0x20
 320:	9201                	srli	a2,a2,0x20
 322:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 326:	872a                	mv	a4,a0
      *dst++ = *src++;
 328:	0585                	addi	a1,a1,1
 32a:	0705                	addi	a4,a4,1
 32c:	fff5c683          	lbu	a3,-1(a1)
 330:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 334:	fee79ae3          	bne	a5,a4,328 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 338:	60a2                	ld	ra,8(sp)
 33a:	6402                	ld	s0,0(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret
    while(n-- > 0)
 340:	fec05ce3          	blez	a2,338 <memmove+0x2a>
    dst += n;
 344:	00c50733          	add	a4,a0,a2
    src += n;
 348:	95b2                	add	a1,a1,a2
 34a:	fff6079b          	addiw	a5,a2,-1
 34e:	1782                	slli	a5,a5,0x20
 350:	9381                	srli	a5,a5,0x20
 352:	fff7c793          	not	a5,a5
 356:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 358:	15fd                	addi	a1,a1,-1
 35a:	177d                	addi	a4,a4,-1
 35c:	0005c683          	lbu	a3,0(a1)
 360:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 364:	fef71ae3          	bne	a4,a5,358 <memmove+0x4a>
 368:	bfc1                	j	338 <memmove+0x2a>

000000000000036a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 36a:	1141                	addi	sp,sp,-16
 36c:	e406                	sd	ra,8(sp)
 36e:	e022                	sd	s0,0(sp)
 370:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 372:	c61d                	beqz	a2,3a0 <memcmp+0x36>
 374:	1602                	slli	a2,a2,0x20
 376:	9201                	srli	a2,a2,0x20
 378:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 37c:	00054783          	lbu	a5,0(a0)
 380:	0005c703          	lbu	a4,0(a1)
 384:	00e79863          	bne	a5,a4,394 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 388:	0505                	addi	a0,a0,1
    p2++;
 38a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 38c:	fed518e3          	bne	a0,a3,37c <memcmp+0x12>
  }
  return 0;
 390:	4501                	li	a0,0
 392:	a019                	j	398 <memcmp+0x2e>
      return *p1 - *p2;
 394:	40e7853b          	subw	a0,a5,a4
}
 398:	60a2                	ld	ra,8(sp)
 39a:	6402                	ld	s0,0(sp)
 39c:	0141                	addi	sp,sp,16
 39e:	8082                	ret
  return 0;
 3a0:	4501                	li	a0,0
 3a2:	bfdd                	j	398 <memcmp+0x2e>

00000000000003a4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a4:	1141                	addi	sp,sp,-16
 3a6:	e406                	sd	ra,8(sp)
 3a8:	e022                	sd	s0,0(sp)
 3aa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ac:	00000097          	auipc	ra,0x0
 3b0:	f62080e7          	jalr	-158(ra) # 30e <memmove>
}
 3b4:	60a2                	ld	ra,8(sp)
 3b6:	6402                	ld	s0,0(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret

00000000000003bc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3bc:	4885                	li	a7,1
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3c4:	4889                	li	a7,2
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <wait>:
.global wait
wait:
 li a7, SYS_wait
 3cc:	488d                	li	a7,3
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3d4:	4891                	li	a7,4
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <read>:
.global read
read:
 li a7, SYS_read
 3dc:	4895                	li	a7,5
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <write>:
.global write
write:
 li a7, SYS_write
 3e4:	48c1                	li	a7,16
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <close>:
.global close
close:
 li a7, SYS_close
 3ec:	48d5                	li	a7,21
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3f4:	4899                	li	a7,6
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <exec>:
.global exec
exec:
 li a7, SYS_exec
 3fc:	489d                	li	a7,7
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <open>:
.global open
open:
 li a7, SYS_open
 404:	48bd                	li	a7,15
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 40c:	48c5                	li	a7,17
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 414:	48c9                	li	a7,18
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 41c:	48a1                	li	a7,8
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <link>:
.global link
link:
 li a7, SYS_link
 424:	48cd                	li	a7,19
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 42c:	48d1                	li	a7,20
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 434:	48a5                	li	a7,9
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <dup>:
.global dup
dup:
 li a7, SYS_dup
 43c:	48a9                	li	a7,10
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 444:	48ad                	li	a7,11
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 44c:	48b1                	li	a7,12
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 454:	48b5                	li	a7,13
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 45c:	48b9                	li	a7,14
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <nanotime>:
.global nanotime
nanotime:
 li a7, SYS_nanotime
 464:	48d9                	li	a7,22
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 46c:	1101                	addi	sp,sp,-32
 46e:	ec06                	sd	ra,24(sp)
 470:	e822                	sd	s0,16(sp)
 472:	1000                	addi	s0,sp,32
 474:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 478:	4605                	li	a2,1
 47a:	fef40593          	addi	a1,s0,-17
 47e:	00000097          	auipc	ra,0x0
 482:	f66080e7          	jalr	-154(ra) # 3e4 <write>
}
 486:	60e2                	ld	ra,24(sp)
 488:	6442                	ld	s0,16(sp)
 48a:	6105                	addi	sp,sp,32
 48c:	8082                	ret

000000000000048e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 48e:	7139                	addi	sp,sp,-64
 490:	fc06                	sd	ra,56(sp)
 492:	f822                	sd	s0,48(sp)
 494:	f04a                	sd	s2,32(sp)
 496:	ec4e                	sd	s3,24(sp)
 498:	0080                	addi	s0,sp,64
 49a:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 49c:	cad9                	beqz	a3,532 <printint+0xa4>
 49e:	01f5d79b          	srliw	a5,a1,0x1f
 4a2:	cbc1                	beqz	a5,532 <printint+0xa4>
    neg = 1;
    x = -xx;
 4a4:	40b005bb          	negw	a1,a1
    neg = 1;
 4a8:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4aa:	fc040993          	addi	s3,s0,-64
  neg = 0;
 4ae:	86ce                	mv	a3,s3
  i = 0;
 4b0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4b2:	00000817          	auipc	a6,0x0
 4b6:	4de80813          	addi	a6,a6,1246 # 990 <digits>
 4ba:	88ba                	mv	a7,a4
 4bc:	0017051b          	addiw	a0,a4,1
 4c0:	872a                	mv	a4,a0
 4c2:	02c5f7bb          	remuw	a5,a1,a2
 4c6:	1782                	slli	a5,a5,0x20
 4c8:	9381                	srli	a5,a5,0x20
 4ca:	97c2                	add	a5,a5,a6
 4cc:	0007c783          	lbu	a5,0(a5)
 4d0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4d4:	87ae                	mv	a5,a1
 4d6:	02c5d5bb          	divuw	a1,a1,a2
 4da:	0685                	addi	a3,a3,1
 4dc:	fcc7ffe3          	bgeu	a5,a2,4ba <printint+0x2c>
  if(neg)
 4e0:	00030c63          	beqz	t1,4f8 <printint+0x6a>
    buf[i++] = '-';
 4e4:	fd050793          	addi	a5,a0,-48
 4e8:	00878533          	add	a0,a5,s0
 4ec:	02d00793          	li	a5,45
 4f0:	fef50823          	sb	a5,-16(a0)
 4f4:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4f8:	02e05763          	blez	a4,526 <printint+0x98>
 4fc:	f426                	sd	s1,40(sp)
 4fe:	377d                	addiw	a4,a4,-1
 500:	00e984b3          	add	s1,s3,a4
 504:	19fd                	addi	s3,s3,-1
 506:	99ba                	add	s3,s3,a4
 508:	1702                	slli	a4,a4,0x20
 50a:	9301                	srli	a4,a4,0x20
 50c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 510:	0004c583          	lbu	a1,0(s1)
 514:	854a                	mv	a0,s2
 516:	00000097          	auipc	ra,0x0
 51a:	f56080e7          	jalr	-170(ra) # 46c <putc>
  while(--i >= 0)
 51e:	14fd                	addi	s1,s1,-1
 520:	ff3498e3          	bne	s1,s3,510 <printint+0x82>
 524:	74a2                	ld	s1,40(sp)
}
 526:	70e2                	ld	ra,56(sp)
 528:	7442                	ld	s0,48(sp)
 52a:	7902                	ld	s2,32(sp)
 52c:	69e2                	ld	s3,24(sp)
 52e:	6121                	addi	sp,sp,64
 530:	8082                	ret
  neg = 0;
 532:	4301                	li	t1,0
 534:	bf9d                	j	4aa <printint+0x1c>

0000000000000536 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 536:	715d                	addi	sp,sp,-80
 538:	e486                	sd	ra,72(sp)
 53a:	e0a2                	sd	s0,64(sp)
 53c:	f84a                	sd	s2,48(sp)
 53e:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 540:	0005c903          	lbu	s2,0(a1)
 544:	1a090b63          	beqz	s2,6fa <vprintf+0x1c4>
 548:	fc26                	sd	s1,56(sp)
 54a:	f44e                	sd	s3,40(sp)
 54c:	f052                	sd	s4,32(sp)
 54e:	ec56                	sd	s5,24(sp)
 550:	e85a                	sd	s6,16(sp)
 552:	e45e                	sd	s7,8(sp)
 554:	8aaa                	mv	s5,a0
 556:	8bb2                	mv	s7,a2
 558:	00158493          	addi	s1,a1,1
  state = 0;
 55c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 55e:	02500a13          	li	s4,37
 562:	4b55                	li	s6,21
 564:	a839                	j	582 <vprintf+0x4c>
        putc(fd, c);
 566:	85ca                	mv	a1,s2
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	f02080e7          	jalr	-254(ra) # 46c <putc>
 572:	a019                	j	578 <vprintf+0x42>
    } else if(state == '%'){
 574:	01498d63          	beq	s3,s4,58e <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 578:	0485                	addi	s1,s1,1
 57a:	fff4c903          	lbu	s2,-1(s1)
 57e:	16090863          	beqz	s2,6ee <vprintf+0x1b8>
    if(state == 0){
 582:	fe0999e3          	bnez	s3,574 <vprintf+0x3e>
      if(c == '%'){
 586:	ff4910e3          	bne	s2,s4,566 <vprintf+0x30>
        state = '%';
 58a:	89d2                	mv	s3,s4
 58c:	b7f5                	j	578 <vprintf+0x42>
      if(c == 'd'){
 58e:	13490563          	beq	s2,s4,6b8 <vprintf+0x182>
 592:	f9d9079b          	addiw	a5,s2,-99
 596:	0ff7f793          	zext.b	a5,a5
 59a:	12fb6863          	bltu	s6,a5,6ca <vprintf+0x194>
 59e:	f9d9079b          	addiw	a5,s2,-99
 5a2:	0ff7f713          	zext.b	a4,a5
 5a6:	12eb6263          	bltu	s6,a4,6ca <vprintf+0x194>
 5aa:	00271793          	slli	a5,a4,0x2
 5ae:	00000717          	auipc	a4,0x0
 5b2:	38a70713          	addi	a4,a4,906 # 938 <malloc+0x14a>
 5b6:	97ba                	add	a5,a5,a4
 5b8:	439c                	lw	a5,0(a5)
 5ba:	97ba                	add	a5,a5,a4
 5bc:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5be:	008b8913          	addi	s2,s7,8
 5c2:	4685                	li	a3,1
 5c4:	4629                	li	a2,10
 5c6:	000ba583          	lw	a1,0(s7)
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	ec2080e7          	jalr	-318(ra) # 48e <printint>
 5d4:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5d6:	4981                	li	s3,0
 5d8:	b745                	j	578 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5da:	008b8913          	addi	s2,s7,8
 5de:	4681                	li	a3,0
 5e0:	4629                	li	a2,10
 5e2:	000ba583          	lw	a1,0(s7)
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	ea6080e7          	jalr	-346(ra) # 48e <printint>
 5f0:	8bca                	mv	s7,s2
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b751                	j	578 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 5f6:	008b8913          	addi	s2,s7,8
 5fa:	4681                	li	a3,0
 5fc:	4641                	li	a2,16
 5fe:	000ba583          	lw	a1,0(s7)
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	e8a080e7          	jalr	-374(ra) # 48e <printint>
 60c:	8bca                	mv	s7,s2
      state = 0;
 60e:	4981                	li	s3,0
 610:	b7a5                	j	578 <vprintf+0x42>
 612:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 614:	008b8793          	addi	a5,s7,8
 618:	8c3e                	mv	s8,a5
 61a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 61e:	03000593          	li	a1,48
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	e48080e7          	jalr	-440(ra) # 46c <putc>
  putc(fd, 'x');
 62c:	07800593          	li	a1,120
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	e3a080e7          	jalr	-454(ra) # 46c <putc>
 63a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 63c:	00000b97          	auipc	s7,0x0
 640:	354b8b93          	addi	s7,s7,852 # 990 <digits>
 644:	03c9d793          	srli	a5,s3,0x3c
 648:	97de                	add	a5,a5,s7
 64a:	0007c583          	lbu	a1,0(a5)
 64e:	8556                	mv	a0,s5
 650:	00000097          	auipc	ra,0x0
 654:	e1c080e7          	jalr	-484(ra) # 46c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 658:	0992                	slli	s3,s3,0x4
 65a:	397d                	addiw	s2,s2,-1
 65c:	fe0914e3          	bnez	s2,644 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 660:	8be2                	mv	s7,s8
      state = 0;
 662:	4981                	li	s3,0
 664:	6c02                	ld	s8,0(sp)
 666:	bf09                	j	578 <vprintf+0x42>
        s = va_arg(ap, char*);
 668:	008b8993          	addi	s3,s7,8
 66c:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 670:	02090163          	beqz	s2,692 <vprintf+0x15c>
        while(*s != 0){
 674:	00094583          	lbu	a1,0(s2)
 678:	c9a5                	beqz	a1,6e8 <vprintf+0x1b2>
          putc(fd, *s);
 67a:	8556                	mv	a0,s5
 67c:	00000097          	auipc	ra,0x0
 680:	df0080e7          	jalr	-528(ra) # 46c <putc>
          s++;
 684:	0905                	addi	s2,s2,1
        while(*s != 0){
 686:	00094583          	lbu	a1,0(s2)
 68a:	f9e5                	bnez	a1,67a <vprintf+0x144>
        s = va_arg(ap, char*);
 68c:	8bce                	mv	s7,s3
      state = 0;
 68e:	4981                	li	s3,0
 690:	b5e5                	j	578 <vprintf+0x42>
          s = "(null)";
 692:	00000917          	auipc	s2,0x0
 696:	29e90913          	addi	s2,s2,670 # 930 <malloc+0x142>
        while(*s != 0){
 69a:	02800593          	li	a1,40
 69e:	bff1                	j	67a <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 6a0:	008b8913          	addi	s2,s7,8
 6a4:	000bc583          	lbu	a1,0(s7)
 6a8:	8556                	mv	a0,s5
 6aa:	00000097          	auipc	ra,0x0
 6ae:	dc2080e7          	jalr	-574(ra) # 46c <putc>
 6b2:	8bca                	mv	s7,s2
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	b5c9                	j	578 <vprintf+0x42>
        putc(fd, c);
 6b8:	02500593          	li	a1,37
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	dae080e7          	jalr	-594(ra) # 46c <putc>
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	bd45                	j	578 <vprintf+0x42>
        putc(fd, '%');
 6ca:	02500593          	li	a1,37
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	d9c080e7          	jalr	-612(ra) # 46c <putc>
        putc(fd, c);
 6d8:	85ca                	mv	a1,s2
 6da:	8556                	mv	a0,s5
 6dc:	00000097          	auipc	ra,0x0
 6e0:	d90080e7          	jalr	-624(ra) # 46c <putc>
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	bd49                	j	578 <vprintf+0x42>
        s = va_arg(ap, char*);
 6e8:	8bce                	mv	s7,s3
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	b571                	j	578 <vprintf+0x42>
 6ee:	74e2                	ld	s1,56(sp)
 6f0:	79a2                	ld	s3,40(sp)
 6f2:	7a02                	ld	s4,32(sp)
 6f4:	6ae2                	ld	s5,24(sp)
 6f6:	6b42                	ld	s6,16(sp)
 6f8:	6ba2                	ld	s7,8(sp)
    }
  }
}
 6fa:	60a6                	ld	ra,72(sp)
 6fc:	6406                	ld	s0,64(sp)
 6fe:	7942                	ld	s2,48(sp)
 700:	6161                	addi	sp,sp,80
 702:	8082                	ret

0000000000000704 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 704:	715d                	addi	sp,sp,-80
 706:	ec06                	sd	ra,24(sp)
 708:	e822                	sd	s0,16(sp)
 70a:	1000                	addi	s0,sp,32
 70c:	e010                	sd	a2,0(s0)
 70e:	e414                	sd	a3,8(s0)
 710:	e818                	sd	a4,16(s0)
 712:	ec1c                	sd	a5,24(s0)
 714:	03043023          	sd	a6,32(s0)
 718:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 71c:	8622                	mv	a2,s0
 71e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 722:	00000097          	auipc	ra,0x0
 726:	e14080e7          	jalr	-492(ra) # 536 <vprintf>
}
 72a:	60e2                	ld	ra,24(sp)
 72c:	6442                	ld	s0,16(sp)
 72e:	6161                	addi	sp,sp,80
 730:	8082                	ret

0000000000000732 <printf>:

void
printf(const char *fmt, ...)
{
 732:	711d                	addi	sp,sp,-96
 734:	ec06                	sd	ra,24(sp)
 736:	e822                	sd	s0,16(sp)
 738:	1000                	addi	s0,sp,32
 73a:	e40c                	sd	a1,8(s0)
 73c:	e810                	sd	a2,16(s0)
 73e:	ec14                	sd	a3,24(s0)
 740:	f018                	sd	a4,32(s0)
 742:	f41c                	sd	a5,40(s0)
 744:	03043823          	sd	a6,48(s0)
 748:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 74c:	00840613          	addi	a2,s0,8
 750:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 754:	85aa                	mv	a1,a0
 756:	4505                	li	a0,1
 758:	00000097          	auipc	ra,0x0
 75c:	dde080e7          	jalr	-546(ra) # 536 <vprintf>
}
 760:	60e2                	ld	ra,24(sp)
 762:	6442                	ld	s0,16(sp)
 764:	6125                	addi	sp,sp,96
 766:	8082                	ret

0000000000000768 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 768:	1141                	addi	sp,sp,-16
 76a:	e406                	sd	ra,8(sp)
 76c:	e022                	sd	s0,0(sp)
 76e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 770:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 774:	00001797          	auipc	a5,0x1
 778:	88c7b783          	ld	a5,-1908(a5) # 1000 <freep>
 77c:	a039                	j	78a <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77e:	6398                	ld	a4,0(a5)
 780:	00e7e463          	bltu	a5,a4,788 <free+0x20>
 784:	00e6ea63          	bltu	a3,a4,798 <free+0x30>
{
 788:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78a:	fed7fae3          	bgeu	a5,a3,77e <free+0x16>
 78e:	6398                	ld	a4,0(a5)
 790:	00e6e463          	bltu	a3,a4,798 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 794:	fee7eae3          	bltu	a5,a4,788 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 798:	ff852583          	lw	a1,-8(a0)
 79c:	6390                	ld	a2,0(a5)
 79e:	02059813          	slli	a6,a1,0x20
 7a2:	01c85713          	srli	a4,a6,0x1c
 7a6:	9736                	add	a4,a4,a3
 7a8:	02e60563          	beq	a2,a4,7d2 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7ac:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7b0:	4790                	lw	a2,8(a5)
 7b2:	02061593          	slli	a1,a2,0x20
 7b6:	01c5d713          	srli	a4,a1,0x1c
 7ba:	973e                	add	a4,a4,a5
 7bc:	02e68263          	beq	a3,a4,7e0 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 7c0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7c2:	00001717          	auipc	a4,0x1
 7c6:	82f73f23          	sd	a5,-1986(a4) # 1000 <freep>
}
 7ca:	60a2                	ld	ra,8(sp)
 7cc:	6402                	ld	s0,0(sp)
 7ce:	0141                	addi	sp,sp,16
 7d0:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7d2:	4618                	lw	a4,8(a2)
 7d4:	9f2d                	addw	a4,a4,a1
 7d6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7da:	6398                	ld	a4,0(a5)
 7dc:	6310                	ld	a2,0(a4)
 7de:	b7f9                	j	7ac <free+0x44>
    p->s.size += bp->s.size;
 7e0:	ff852703          	lw	a4,-8(a0)
 7e4:	9f31                	addw	a4,a4,a2
 7e6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7e8:	ff053683          	ld	a3,-16(a0)
 7ec:	bfd1                	j	7c0 <free+0x58>

00000000000007ee <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ee:	7139                	addi	sp,sp,-64
 7f0:	fc06                	sd	ra,56(sp)
 7f2:	f822                	sd	s0,48(sp)
 7f4:	f04a                	sd	s2,32(sp)
 7f6:	ec4e                	sd	s3,24(sp)
 7f8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7fa:	02051993          	slli	s3,a0,0x20
 7fe:	0209d993          	srli	s3,s3,0x20
 802:	09bd                	addi	s3,s3,15
 804:	0049d993          	srli	s3,s3,0x4
 808:	2985                	addiw	s3,s3,1
 80a:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 80c:	00000517          	auipc	a0,0x0
 810:	7f453503          	ld	a0,2036(a0) # 1000 <freep>
 814:	c905                	beqz	a0,844 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 816:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 818:	4798                	lw	a4,8(a5)
 81a:	09377a63          	bgeu	a4,s3,8ae <malloc+0xc0>
 81e:	f426                	sd	s1,40(sp)
 820:	e852                	sd	s4,16(sp)
 822:	e456                	sd	s5,8(sp)
 824:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 826:	8a4e                	mv	s4,s3
 828:	6705                	lui	a4,0x1
 82a:	00e9f363          	bgeu	s3,a4,830 <malloc+0x42>
 82e:	6a05                	lui	s4,0x1
 830:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 834:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 838:	00000497          	auipc	s1,0x0
 83c:	7c848493          	addi	s1,s1,1992 # 1000 <freep>
  if(p == (char*)-1)
 840:	5afd                	li	s5,-1
 842:	a089                	j	884 <malloc+0x96>
 844:	f426                	sd	s1,40(sp)
 846:	e852                	sd	s4,16(sp)
 848:	e456                	sd	s5,8(sp)
 84a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 84c:	00000797          	auipc	a5,0x0
 850:	7c478793          	addi	a5,a5,1988 # 1010 <base>
 854:	00000717          	auipc	a4,0x0
 858:	7af73623          	sd	a5,1964(a4) # 1000 <freep>
 85c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 85e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 862:	b7d1                	j	826 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 864:	6398                	ld	a4,0(a5)
 866:	e118                	sd	a4,0(a0)
 868:	a8b9                	j	8c6 <malloc+0xd8>
  hp->s.size = nu;
 86a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 86e:	0541                	addi	a0,a0,16
 870:	00000097          	auipc	ra,0x0
 874:	ef8080e7          	jalr	-264(ra) # 768 <free>
  return freep;
 878:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 87a:	c135                	beqz	a0,8de <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 87e:	4798                	lw	a4,8(a5)
 880:	03277363          	bgeu	a4,s2,8a6 <malloc+0xb8>
    if(p == freep)
 884:	6098                	ld	a4,0(s1)
 886:	853e                	mv	a0,a5
 888:	fef71ae3          	bne	a4,a5,87c <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 88c:	8552                	mv	a0,s4
 88e:	00000097          	auipc	ra,0x0
 892:	bbe080e7          	jalr	-1090(ra) # 44c <sbrk>
  if(p == (char*)-1)
 896:	fd551ae3          	bne	a0,s5,86a <malloc+0x7c>
        return 0;
 89a:	4501                	li	a0,0
 89c:	74a2                	ld	s1,40(sp)
 89e:	6a42                	ld	s4,16(sp)
 8a0:	6aa2                	ld	s5,8(sp)
 8a2:	6b02                	ld	s6,0(sp)
 8a4:	a03d                	j	8d2 <malloc+0xe4>
 8a6:	74a2                	ld	s1,40(sp)
 8a8:	6a42                	ld	s4,16(sp)
 8aa:	6aa2                	ld	s5,8(sp)
 8ac:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8ae:	fae90be3          	beq	s2,a4,864 <malloc+0x76>
        p->s.size -= nunits;
 8b2:	4137073b          	subw	a4,a4,s3
 8b6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8b8:	02071693          	slli	a3,a4,0x20
 8bc:	01c6d713          	srli	a4,a3,0x1c
 8c0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8c6:	00000717          	auipc	a4,0x0
 8ca:	72a73d23          	sd	a0,1850(a4) # 1000 <freep>
      return (void*)(p + 1);
 8ce:	01078513          	addi	a0,a5,16
  }
}
 8d2:	70e2                	ld	ra,56(sp)
 8d4:	7442                	ld	s0,48(sp)
 8d6:	7902                	ld	s2,32(sp)
 8d8:	69e2                	ld	s3,24(sp)
 8da:	6121                	addi	sp,sp,64
 8dc:	8082                	ret
 8de:	74a2                	ld	s1,40(sp)
 8e0:	6a42                	ld	s4,16(sp)
 8e2:	6aa2                	ld	s5,8(sp)
 8e4:	6b02                	ld	s6,0(sp)
 8e6:	b7f5                	j	8d2 <malloc+0xe4>
