
user/_forktest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print>:

#define N  1000

void
print(const char *s)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
  write(1, s, strlen(s));
   c:	00000097          	auipc	ra,0x0
  10:	172080e7          	jalr	370(ra) # 17e <strlen>
  14:	862a                	mv	a2,a0
  16:	85a6                	mv	a1,s1
  18:	4505                	li	a0,1
  1a:	00000097          	auipc	ra,0x0
  1e:	3c2080e7          	jalr	962(ra) # 3dc <write>
}
  22:	60e2                	ld	ra,24(sp)
  24:	6442                	ld	s0,16(sp)
  26:	64a2                	ld	s1,8(sp)
  28:	6105                	addi	sp,sp,32
  2a:	8082                	ret

000000000000002c <forktest>:

void
forktest(void)
{
  2c:	1101                	addi	sp,sp,-32
  2e:	ec06                	sd	ra,24(sp)
  30:	e822                	sd	s0,16(sp)
  32:	e426                	sd	s1,8(sp)
  34:	e04a                	sd	s2,0(sp)
  36:	1000                	addi	s0,sp,32
  int n, pid;

  print("fork test\n");
  38:	00000517          	auipc	a0,0x0
  3c:	43050513          	addi	a0,a0,1072 # 468 <nanotime+0xc>
  40:	00000097          	auipc	ra,0x0
  44:	fc0080e7          	jalr	-64(ra) # 0 <print>

  for(n=0; n<N; n++){
  48:	4481                	li	s1,0
  4a:	3e800913          	li	s2,1000
    pid = fork();
  4e:	00000097          	auipc	ra,0x0
  52:	366080e7          	jalr	870(ra) # 3b4 <fork>
    if(pid < 0)
  56:	06054163          	bltz	a0,b8 <forktest+0x8c>
      break;
    if(pid == 0)
  5a:	c10d                	beqz	a0,7c <forktest+0x50>
  for(n=0; n<N; n++){
  5c:	2485                	addiw	s1,s1,1
  5e:	ff2498e3          	bne	s1,s2,4e <forktest+0x22>
      exit(0);
  }

  if(n == N){
    print("fork claimed to work N times!\n");
  62:	00000517          	auipc	a0,0x0
  66:	45650513          	addi	a0,a0,1110 # 4b8 <nanotime+0x5c>
  6a:	00000097          	auipc	ra,0x0
  6e:	f96080e7          	jalr	-106(ra) # 0 <print>
    exit(1);
  72:	4505                	li	a0,1
  74:	00000097          	auipc	ra,0x0
  78:	348080e7          	jalr	840(ra) # 3bc <exit>
      exit(0);
  7c:	00000097          	auipc	ra,0x0
  80:	340080e7          	jalr	832(ra) # 3bc <exit>
  }

  for(; n > 0; n--){
    if(wait(0) < 0){
      print("wait stopped early\n");
  84:	00000517          	auipc	a0,0x0
  88:	3f450513          	addi	a0,a0,1012 # 478 <nanotime+0x1c>
  8c:	00000097          	auipc	ra,0x0
  90:	f74080e7          	jalr	-140(ra) # 0 <print>
      exit(1);
  94:	4505                	li	a0,1
  96:	00000097          	auipc	ra,0x0
  9a:	326080e7          	jalr	806(ra) # 3bc <exit>
    }
  }

  if(wait(0) != -1){
    print("wait got too many\n");
  9e:	00000517          	auipc	a0,0x0
  a2:	3f250513          	addi	a0,a0,1010 # 490 <nanotime+0x34>
  a6:	00000097          	auipc	ra,0x0
  aa:	f5a080e7          	jalr	-166(ra) # 0 <print>
    exit(1);
  ae:	4505                	li	a0,1
  b0:	00000097          	auipc	ra,0x0
  b4:	30c080e7          	jalr	780(ra) # 3bc <exit>
  for(; n > 0; n--){
  b8:	00905b63          	blez	s1,ce <forktest+0xa2>
    if(wait(0) < 0){
  bc:	4501                	li	a0,0
  be:	00000097          	auipc	ra,0x0
  c2:	306080e7          	jalr	774(ra) # 3c4 <wait>
  c6:	fa054fe3          	bltz	a0,84 <forktest+0x58>
  for(; n > 0; n--){
  ca:	34fd                	addiw	s1,s1,-1
  cc:	f8e5                	bnez	s1,bc <forktest+0x90>
  if(wait(0) != -1){
  ce:	4501                	li	a0,0
  d0:	00000097          	auipc	ra,0x0
  d4:	2f4080e7          	jalr	756(ra) # 3c4 <wait>
  d8:	57fd                	li	a5,-1
  da:	fcf512e3          	bne	a0,a5,9e <forktest+0x72>
  }

  print("fork test OK\n");
  de:	00000517          	auipc	a0,0x0
  e2:	3ca50513          	addi	a0,a0,970 # 4a8 <nanotime+0x4c>
  e6:	00000097          	auipc	ra,0x0
  ea:	f1a080e7          	jalr	-230(ra) # 0 <print>
}
  ee:	60e2                	ld	ra,24(sp)
  f0:	6442                	ld	s0,16(sp)
  f2:	64a2                	ld	s1,8(sp)
  f4:	6902                	ld	s2,0(sp)
  f6:	6105                	addi	sp,sp,32
  f8:	8082                	ret

00000000000000fa <main>:

int
main(void)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e406                	sd	ra,8(sp)
  fe:	e022                	sd	s0,0(sp)
 100:	0800                	addi	s0,sp,16
  forktest();
 102:	00000097          	auipc	ra,0x0
 106:	f2a080e7          	jalr	-214(ra) # 2c <forktest>
  exit(0);
 10a:	4501                	li	a0,0
 10c:	00000097          	auipc	ra,0x0
 110:	2b0080e7          	jalr	688(ra) # 3bc <exit>

0000000000000114 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 114:	1141                	addi	sp,sp,-16
 116:	e406                	sd	ra,8(sp)
 118:	e022                	sd	s0,0(sp)
 11a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 11c:	00000097          	auipc	ra,0x0
 120:	fde080e7          	jalr	-34(ra) # fa <main>
  exit(0);
 124:	4501                	li	a0,0
 126:	00000097          	auipc	ra,0x0
 12a:	296080e7          	jalr	662(ra) # 3bc <exit>

000000000000012e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e406                	sd	ra,8(sp)
 132:	e022                	sd	s0,0(sp)
 134:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 136:	87aa                	mv	a5,a0
 138:	0585                	addi	a1,a1,1
 13a:	0785                	addi	a5,a5,1
 13c:	fff5c703          	lbu	a4,-1(a1)
 140:	fee78fa3          	sb	a4,-1(a5)
 144:	fb75                	bnez	a4,138 <strcpy+0xa>
    ;
  return os;
}
 146:	60a2                	ld	ra,8(sp)
 148:	6402                	ld	s0,0(sp)
 14a:	0141                	addi	sp,sp,16
 14c:	8082                	ret

000000000000014e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 14e:	1141                	addi	sp,sp,-16
 150:	e406                	sd	ra,8(sp)
 152:	e022                	sd	s0,0(sp)
 154:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 156:	00054783          	lbu	a5,0(a0)
 15a:	cb91                	beqz	a5,16e <strcmp+0x20>
 15c:	0005c703          	lbu	a4,0(a1)
 160:	00f71763          	bne	a4,a5,16e <strcmp+0x20>
    p++, q++;
 164:	0505                	addi	a0,a0,1
 166:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 168:	00054783          	lbu	a5,0(a0)
 16c:	fbe5                	bnez	a5,15c <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 16e:	0005c503          	lbu	a0,0(a1)
}
 172:	40a7853b          	subw	a0,a5,a0
 176:	60a2                	ld	ra,8(sp)
 178:	6402                	ld	s0,0(sp)
 17a:	0141                	addi	sp,sp,16
 17c:	8082                	ret

000000000000017e <strlen>:

uint
strlen(const char *s)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e406                	sd	ra,8(sp)
 182:	e022                	sd	s0,0(sp)
 184:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 186:	00054783          	lbu	a5,0(a0)
 18a:	cf91                	beqz	a5,1a6 <strlen+0x28>
 18c:	00150793          	addi	a5,a0,1
 190:	86be                	mv	a3,a5
 192:	0785                	addi	a5,a5,1
 194:	fff7c703          	lbu	a4,-1(a5)
 198:	ff65                	bnez	a4,190 <strlen+0x12>
 19a:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 19e:	60a2                	ld	ra,8(sp)
 1a0:	6402                	ld	s0,0(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret
  for(n = 0; s[n]; n++)
 1a6:	4501                	li	a0,0
 1a8:	bfdd                	j	19e <strlen+0x20>

00000000000001aa <memset>:

void*
memset(void *dst, int c, uint n)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e406                	sd	ra,8(sp)
 1ae:	e022                	sd	s0,0(sp)
 1b0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1b2:	ca19                	beqz	a2,1c8 <memset+0x1e>
 1b4:	87aa                	mv	a5,a0
 1b6:	1602                	slli	a2,a2,0x20
 1b8:	9201                	srli	a2,a2,0x20
 1ba:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1be:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c2:	0785                	addi	a5,a5,1
 1c4:	fee79de3          	bne	a5,a4,1be <memset+0x14>
  }
  return dst;
}
 1c8:	60a2                	ld	ra,8(sp)
 1ca:	6402                	ld	s0,0(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret

00000000000001d0 <strchr>:

char*
strchr(const char *s, char c)
{
 1d0:	1141                	addi	sp,sp,-16
 1d2:	e406                	sd	ra,8(sp)
 1d4:	e022                	sd	s0,0(sp)
 1d6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d8:	00054783          	lbu	a5,0(a0)
 1dc:	cf81                	beqz	a5,1f4 <strchr+0x24>
    if(*s == c)
 1de:	00f58763          	beq	a1,a5,1ec <strchr+0x1c>
  for(; *s; s++)
 1e2:	0505                	addi	a0,a0,1
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	fbfd                	bnez	a5,1de <strchr+0xe>
      return (char*)s;
  return 0;
 1ea:	4501                	li	a0,0
}
 1ec:	60a2                	ld	ra,8(sp)
 1ee:	6402                	ld	s0,0(sp)
 1f0:	0141                	addi	sp,sp,16
 1f2:	8082                	ret
  return 0;
 1f4:	4501                	li	a0,0
 1f6:	bfdd                	j	1ec <strchr+0x1c>

00000000000001f8 <gets>:

char*
gets(char *buf, int max)
{
 1f8:	711d                	addi	sp,sp,-96
 1fa:	ec86                	sd	ra,88(sp)
 1fc:	e8a2                	sd	s0,80(sp)
 1fe:	e4a6                	sd	s1,72(sp)
 200:	e0ca                	sd	s2,64(sp)
 202:	fc4e                	sd	s3,56(sp)
 204:	f852                	sd	s4,48(sp)
 206:	f456                	sd	s5,40(sp)
 208:	f05a                	sd	s6,32(sp)
 20a:	ec5e                	sd	s7,24(sp)
 20c:	e862                	sd	s8,16(sp)
 20e:	1080                	addi	s0,sp,96
 210:	8baa                	mv	s7,a0
 212:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 214:	892a                	mv	s2,a0
 216:	4481                	li	s1,0
    cc = read(0, &c, 1);
 218:	faf40b13          	addi	s6,s0,-81
 21c:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 21e:	8c26                	mv	s8,s1
 220:	0014899b          	addiw	s3,s1,1
 224:	84ce                	mv	s1,s3
 226:	0349d663          	bge	s3,s4,252 <gets+0x5a>
    cc = read(0, &c, 1);
 22a:	8656                	mv	a2,s5
 22c:	85da                	mv	a1,s6
 22e:	4501                	li	a0,0
 230:	00000097          	auipc	ra,0x0
 234:	1a4080e7          	jalr	420(ra) # 3d4 <read>
    if(cc < 1)
 238:	00a05d63          	blez	a0,252 <gets+0x5a>
      break;
    buf[i++] = c;
 23c:	faf44783          	lbu	a5,-81(s0)
 240:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 244:	0905                	addi	s2,s2,1
 246:	ff678713          	addi	a4,a5,-10
 24a:	c319                	beqz	a4,250 <gets+0x58>
 24c:	17cd                	addi	a5,a5,-13
 24e:	fbe1                	bnez	a5,21e <gets+0x26>
    buf[i++] = c;
 250:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 252:	9c5e                	add	s8,s8,s7
 254:	000c0023          	sb	zero,0(s8)
  return buf;
}
 258:	855e                	mv	a0,s7
 25a:	60e6                	ld	ra,88(sp)
 25c:	6446                	ld	s0,80(sp)
 25e:	64a6                	ld	s1,72(sp)
 260:	6906                	ld	s2,64(sp)
 262:	79e2                	ld	s3,56(sp)
 264:	7a42                	ld	s4,48(sp)
 266:	7aa2                	ld	s5,40(sp)
 268:	7b02                	ld	s6,32(sp)
 26a:	6be2                	ld	s7,24(sp)
 26c:	6c42                	ld	s8,16(sp)
 26e:	6125                	addi	sp,sp,96
 270:	8082                	ret

0000000000000272 <stat>:

int
stat(const char *n, struct stat *st)
{
 272:	1101                	addi	sp,sp,-32
 274:	ec06                	sd	ra,24(sp)
 276:	e822                	sd	s0,16(sp)
 278:	e04a                	sd	s2,0(sp)
 27a:	1000                	addi	s0,sp,32
 27c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27e:	4581                	li	a1,0
 280:	00000097          	auipc	ra,0x0
 284:	17c080e7          	jalr	380(ra) # 3fc <open>
  if(fd < 0)
 288:	02054663          	bltz	a0,2b4 <stat+0x42>
 28c:	e426                	sd	s1,8(sp)
 28e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 290:	85ca                	mv	a1,s2
 292:	00000097          	auipc	ra,0x0
 296:	182080e7          	jalr	386(ra) # 414 <fstat>
 29a:	892a                	mv	s2,a0
  close(fd);
 29c:	8526                	mv	a0,s1
 29e:	00000097          	auipc	ra,0x0
 2a2:	146080e7          	jalr	326(ra) # 3e4 <close>
  return r;
 2a6:	64a2                	ld	s1,8(sp)
}
 2a8:	854a                	mv	a0,s2
 2aa:	60e2                	ld	ra,24(sp)
 2ac:	6442                	ld	s0,16(sp)
 2ae:	6902                	ld	s2,0(sp)
 2b0:	6105                	addi	sp,sp,32
 2b2:	8082                	ret
    return -1;
 2b4:	57fd                	li	a5,-1
 2b6:	893e                	mv	s2,a5
 2b8:	bfc5                	j	2a8 <stat+0x36>

00000000000002ba <atoi>:

int
atoi(const char *s)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e406                	sd	ra,8(sp)
 2be:	e022                	sd	s0,0(sp)
 2c0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c2:	00054683          	lbu	a3,0(a0)
 2c6:	fd06879b          	addiw	a5,a3,-48
 2ca:	0ff7f793          	zext.b	a5,a5
 2ce:	4625                	li	a2,9
 2d0:	02f66963          	bltu	a2,a5,302 <atoi+0x48>
 2d4:	872a                	mv	a4,a0
  n = 0;
 2d6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2d8:	0705                	addi	a4,a4,1
 2da:	0025179b          	slliw	a5,a0,0x2
 2de:	9fa9                	addw	a5,a5,a0
 2e0:	0017979b          	slliw	a5,a5,0x1
 2e4:	9fb5                	addw	a5,a5,a3
 2e6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ea:	00074683          	lbu	a3,0(a4)
 2ee:	fd06879b          	addiw	a5,a3,-48
 2f2:	0ff7f793          	zext.b	a5,a5
 2f6:	fef671e3          	bgeu	a2,a5,2d8 <atoi+0x1e>
  return n;
}
 2fa:	60a2                	ld	ra,8(sp)
 2fc:	6402                	ld	s0,0(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret
  n = 0;
 302:	4501                	li	a0,0
 304:	bfdd                	j	2fa <atoi+0x40>

0000000000000306 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 306:	1141                	addi	sp,sp,-16
 308:	e406                	sd	ra,8(sp)
 30a:	e022                	sd	s0,0(sp)
 30c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 30e:	02b57563          	bgeu	a0,a1,338 <memmove+0x32>
    while(n-- > 0)
 312:	00c05f63          	blez	a2,330 <memmove+0x2a>
 316:	1602                	slli	a2,a2,0x20
 318:	9201                	srli	a2,a2,0x20
 31a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 31e:	872a                	mv	a4,a0
      *dst++ = *src++;
 320:	0585                	addi	a1,a1,1
 322:	0705                	addi	a4,a4,1
 324:	fff5c683          	lbu	a3,-1(a1)
 328:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 32c:	fee79ae3          	bne	a5,a4,320 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret
    while(n-- > 0)
 338:	fec05ce3          	blez	a2,330 <memmove+0x2a>
    dst += n;
 33c:	00c50733          	add	a4,a0,a2
    src += n;
 340:	95b2                	add	a1,a1,a2
 342:	fff6079b          	addiw	a5,a2,-1
 346:	1782                	slli	a5,a5,0x20
 348:	9381                	srli	a5,a5,0x20
 34a:	fff7c793          	not	a5,a5
 34e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 350:	15fd                	addi	a1,a1,-1
 352:	177d                	addi	a4,a4,-1
 354:	0005c683          	lbu	a3,0(a1)
 358:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 35c:	fef71ae3          	bne	a4,a5,350 <memmove+0x4a>
 360:	bfc1                	j	330 <memmove+0x2a>

0000000000000362 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 362:	1141                	addi	sp,sp,-16
 364:	e406                	sd	ra,8(sp)
 366:	e022                	sd	s0,0(sp)
 368:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 36a:	c61d                	beqz	a2,398 <memcmp+0x36>
 36c:	1602                	slli	a2,a2,0x20
 36e:	9201                	srli	a2,a2,0x20
 370:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 374:	00054783          	lbu	a5,0(a0)
 378:	0005c703          	lbu	a4,0(a1)
 37c:	00e79863          	bne	a5,a4,38c <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 380:	0505                	addi	a0,a0,1
    p2++;
 382:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 384:	fed518e3          	bne	a0,a3,374 <memcmp+0x12>
  }
  return 0;
 388:	4501                	li	a0,0
 38a:	a019                	j	390 <memcmp+0x2e>
      return *p1 - *p2;
 38c:	40e7853b          	subw	a0,a5,a4
}
 390:	60a2                	ld	ra,8(sp)
 392:	6402                	ld	s0,0(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret
  return 0;
 398:	4501                	li	a0,0
 39a:	bfdd                	j	390 <memcmp+0x2e>

000000000000039c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 39c:	1141                	addi	sp,sp,-16
 39e:	e406                	sd	ra,8(sp)
 3a0:	e022                	sd	s0,0(sp)
 3a2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3a4:	00000097          	auipc	ra,0x0
 3a8:	f62080e7          	jalr	-158(ra) # 306 <memmove>
}
 3ac:	60a2                	ld	ra,8(sp)
 3ae:	6402                	ld	s0,0(sp)
 3b0:	0141                	addi	sp,sp,16
 3b2:	8082                	ret

00000000000003b4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3b4:	4885                	li	a7,1
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3bc:	4889                	li	a7,2
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3c4:	488d                	li	a7,3
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3cc:	4891                	li	a7,4
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <read>:
.global read
read:
 li a7, SYS_read
 3d4:	4895                	li	a7,5
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <write>:
.global write
write:
 li a7, SYS_write
 3dc:	48c1                	li	a7,16
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <close>:
.global close
close:
 li a7, SYS_close
 3e4:	48d5                	li	a7,21
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ec:	4899                	li	a7,6
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3f4:	489d                	li	a7,7
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <open>:
.global open
open:
 li a7, SYS_open
 3fc:	48bd                	li	a7,15
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 404:	48c5                	li	a7,17
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 40c:	48c9                	li	a7,18
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 414:	48a1                	li	a7,8
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <link>:
.global link
link:
 li a7, SYS_link
 41c:	48cd                	li	a7,19
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 424:	48d1                	li	a7,20
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 42c:	48a5                	li	a7,9
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <dup>:
.global dup
dup:
 li a7, SYS_dup
 434:	48a9                	li	a7,10
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 43c:	48ad                	li	a7,11
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 444:	48b1                	li	a7,12
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 44c:	48b5                	li	a7,13
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 454:	48b9                	li	a7,14
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <nanotime>:
.global nanotime
nanotime:
 li a7, SYS_nanotime
 45c:	48d9                	li	a7,22
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret
