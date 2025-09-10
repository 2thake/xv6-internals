
user/_interprocess:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <create_child>:

// Modifications here by John Hughes student number
// This function creates the child process that prints its message
// It takes 2 arguments, the name of the process and a pointer to the pipe
void create_child(char name, int *p)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	0080                	addi	s0,sp,64
   c:	892a                	mv	s2,a0
   e:	84ae                	mv	s1,a1
  char buf;
  if (fork() == 0)
  10:	00000097          	auipc	ra,0x0
  14:	376080e7          	jalr	886(ra) # 386 <fork>
  18:	c519                	beqz	a0,26 <create_child+0x26>
      printf("I am child %c\n", name); // write the message
      write(p[1], &buf, 1);            // send the token to the pipe
    }
    exit(0);
  }
}
  1a:	70e2                	ld	ra,56(sp)
  1c:	7442                	ld	s0,48(sp)
  1e:	74a2                	ld	s1,40(sp)
  20:	7902                	ld	s2,32(sp)
  22:	6121                	addi	sp,sp,64
  24:	8082                	ret
  26:	ec4e                	sd	s3,24(sp)
  28:	0c800793          	li	a5,200
  2c:	89be                	mv	s3,a5
      printf("I am child %c\n", name); // write the message
  2e:	0009079b          	sext.w	a5,s2
  32:	893e                	mv	s2,a5
      read(p[0], &buf, 1);             // wait for the token
  34:	4605                	li	a2,1
  36:	fcf40593          	addi	a1,s0,-49
  3a:	4088                	lw	a0,0(s1)
  3c:	00000097          	auipc	ra,0x0
  40:	36a080e7          	jalr	874(ra) # 3a6 <read>
      printf("I am child %c\n", name); // write the message
  44:	85ca                	mv	a1,s2
  46:	00001517          	auipc	a0,0x1
  4a:	87a50513          	addi	a0,a0,-1926 # 8c0 <malloc+0x108>
  4e:	00000097          	auipc	ra,0x0
  52:	6ae080e7          	jalr	1710(ra) # 6fc <printf>
      write(p[1], &buf, 1);            // send the token to the pipe
  56:	4605                	li	a2,1
  58:	fcf40593          	addi	a1,s0,-49
  5c:	40c8                	lw	a0,4(s1)
  5e:	00000097          	auipc	ra,0x0
  62:	350080e7          	jalr	848(ra) # 3ae <write>
    for (int j = 0; j < 200; j++)
  66:	fff9879b          	addiw	a5,s3,-1
  6a:	89be                	mv	s3,a5
  6c:	f7e1                	bnez	a5,34 <create_child+0x34>
    exit(0);
  6e:	4501                	li	a0,0
  70:	00000097          	auipc	ra,0x0
  74:	31e080e7          	jalr	798(ra) # 38e <exit>

0000000000000078 <main>:

int main(int argc, char *argv[])
{
  78:	7179                	addi	sp,sp,-48
  7a:	f406                	sd	ra,40(sp)
  7c:	f022                	sd	s0,32(sp)
  7e:	ec26                	sd	s1,24(sp)
  80:	1800                	addi	s0,sp,48
  int p[2];
  char c = '$'; // character token
  82:	02400793          	li	a5,36
  86:	fcf40ba3          	sb	a5,-41(s0)

  pipe(p); // create pipe
  8a:	fd840493          	addi	s1,s0,-40
  8e:	8526                	mv	a0,s1
  90:	00000097          	auipc	ra,0x0
  94:	30e080e7          	jalr	782(ra) # 39e <pipe>

  write(p[1], &c, 1); // write the character into the pipe
  98:	4605                	li	a2,1
  9a:	fd740593          	addi	a1,s0,-41
  9e:	fdc42503          	lw	a0,-36(s0)
  a2:	00000097          	auipc	ra,0x0
  a6:	30c080e7          	jalr	780(ra) # 3ae <write>

  create_child('A', p); // create process A
  aa:	85a6                	mv	a1,s1
  ac:	04100513          	li	a0,65
  b0:	00000097          	auipc	ra,0x0
  b4:	f50080e7          	jalr	-176(ra) # 0 <create_child>
  create_child('B', p); // create process B
  b8:	85a6                	mv	a1,s1
  ba:	04200513          	li	a0,66
  be:	00000097          	auipc	ra,0x0
  c2:	f42080e7          	jalr	-190(ra) # 0 <create_child>

  for (int i = 0; i < 2; i++) // wait for the two child processes to finish
  {
    wait(0);
  c6:	4501                	li	a0,0
  c8:	00000097          	auipc	ra,0x0
  cc:	2ce080e7          	jalr	718(ra) # 396 <wait>
  d0:	4501                	li	a0,0
  d2:	00000097          	auipc	ra,0x0
  d6:	2c4080e7          	jalr	708(ra) # 396 <wait>
  }
  return 0;
}
  da:	4501                	li	a0,0
  dc:	70a2                	ld	ra,40(sp)
  de:	7402                	ld	s0,32(sp)
  e0:	64e2                	ld	s1,24(sp)
  e2:	6145                	addi	sp,sp,48
  e4:	8082                	ret

00000000000000e6 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e406                	sd	ra,8(sp)
  ea:	e022                	sd	s0,0(sp)
  ec:	0800                	addi	s0,sp,16
  extern int main();
  main();
  ee:	00000097          	auipc	ra,0x0
  f2:	f8a080e7          	jalr	-118(ra) # 78 <main>
  exit(0);
  f6:	4501                	li	a0,0
  f8:	00000097          	auipc	ra,0x0
  fc:	296080e7          	jalr	662(ra) # 38e <exit>

0000000000000100 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 100:	1141                	addi	sp,sp,-16
 102:	e406                	sd	ra,8(sp)
 104:	e022                	sd	s0,0(sp)
 106:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 108:	87aa                	mv	a5,a0
 10a:	0585                	addi	a1,a1,1
 10c:	0785                	addi	a5,a5,1
 10e:	fff5c703          	lbu	a4,-1(a1)
 112:	fee78fa3          	sb	a4,-1(a5)
 116:	fb75                	bnez	a4,10a <strcpy+0xa>
    ;
  return os;
}
 118:	60a2                	ld	ra,8(sp)
 11a:	6402                	ld	s0,0(sp)
 11c:	0141                	addi	sp,sp,16
 11e:	8082                	ret

0000000000000120 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 120:	1141                	addi	sp,sp,-16
 122:	e406                	sd	ra,8(sp)
 124:	e022                	sd	s0,0(sp)
 126:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 128:	00054783          	lbu	a5,0(a0)
 12c:	cb91                	beqz	a5,140 <strcmp+0x20>
 12e:	0005c703          	lbu	a4,0(a1)
 132:	00f71763          	bne	a4,a5,140 <strcmp+0x20>
    p++, q++;
 136:	0505                	addi	a0,a0,1
 138:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	fbe5                	bnez	a5,12e <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 140:	0005c503          	lbu	a0,0(a1)
}
 144:	40a7853b          	subw	a0,a5,a0
 148:	60a2                	ld	ra,8(sp)
 14a:	6402                	ld	s0,0(sp)
 14c:	0141                	addi	sp,sp,16
 14e:	8082                	ret

0000000000000150 <strlen>:

uint
strlen(const char *s)
{
 150:	1141                	addi	sp,sp,-16
 152:	e406                	sd	ra,8(sp)
 154:	e022                	sd	s0,0(sp)
 156:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 158:	00054783          	lbu	a5,0(a0)
 15c:	cf91                	beqz	a5,178 <strlen+0x28>
 15e:	00150793          	addi	a5,a0,1
 162:	86be                	mv	a3,a5
 164:	0785                	addi	a5,a5,1
 166:	fff7c703          	lbu	a4,-1(a5)
 16a:	ff65                	bnez	a4,162 <strlen+0x12>
 16c:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 170:	60a2                	ld	ra,8(sp)
 172:	6402                	ld	s0,0(sp)
 174:	0141                	addi	sp,sp,16
 176:	8082                	ret
  for(n = 0; s[n]; n++)
 178:	4501                	li	a0,0
 17a:	bfdd                	j	170 <strlen+0x20>

000000000000017c <memset>:

void*
memset(void *dst, int c, uint n)
{
 17c:	1141                	addi	sp,sp,-16
 17e:	e406                	sd	ra,8(sp)
 180:	e022                	sd	s0,0(sp)
 182:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 184:	ca19                	beqz	a2,19a <memset+0x1e>
 186:	87aa                	mv	a5,a0
 188:	1602                	slli	a2,a2,0x20
 18a:	9201                	srli	a2,a2,0x20
 18c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 190:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 194:	0785                	addi	a5,a5,1
 196:	fee79de3          	bne	a5,a4,190 <memset+0x14>
  }
  return dst;
}
 19a:	60a2                	ld	ra,8(sp)
 19c:	6402                	ld	s0,0(sp)
 19e:	0141                	addi	sp,sp,16
 1a0:	8082                	ret

00000000000001a2 <strchr>:

char*
strchr(const char *s, char c)
{
 1a2:	1141                	addi	sp,sp,-16
 1a4:	e406                	sd	ra,8(sp)
 1a6:	e022                	sd	s0,0(sp)
 1a8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1aa:	00054783          	lbu	a5,0(a0)
 1ae:	cf81                	beqz	a5,1c6 <strchr+0x24>
    if(*s == c)
 1b0:	00f58763          	beq	a1,a5,1be <strchr+0x1c>
  for(; *s; s++)
 1b4:	0505                	addi	a0,a0,1
 1b6:	00054783          	lbu	a5,0(a0)
 1ba:	fbfd                	bnez	a5,1b0 <strchr+0xe>
      return (char*)s;
  return 0;
 1bc:	4501                	li	a0,0
}
 1be:	60a2                	ld	ra,8(sp)
 1c0:	6402                	ld	s0,0(sp)
 1c2:	0141                	addi	sp,sp,16
 1c4:	8082                	ret
  return 0;
 1c6:	4501                	li	a0,0
 1c8:	bfdd                	j	1be <strchr+0x1c>

00000000000001ca <gets>:

char*
gets(char *buf, int max)
{
 1ca:	711d                	addi	sp,sp,-96
 1cc:	ec86                	sd	ra,88(sp)
 1ce:	e8a2                	sd	s0,80(sp)
 1d0:	e4a6                	sd	s1,72(sp)
 1d2:	e0ca                	sd	s2,64(sp)
 1d4:	fc4e                	sd	s3,56(sp)
 1d6:	f852                	sd	s4,48(sp)
 1d8:	f456                	sd	s5,40(sp)
 1da:	f05a                	sd	s6,32(sp)
 1dc:	ec5e                	sd	s7,24(sp)
 1de:	e862                	sd	s8,16(sp)
 1e0:	1080                	addi	s0,sp,96
 1e2:	8baa                	mv	s7,a0
 1e4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e6:	892a                	mv	s2,a0
 1e8:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1ea:	faf40b13          	addi	s6,s0,-81
 1ee:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1f0:	8c26                	mv	s8,s1
 1f2:	0014899b          	addiw	s3,s1,1
 1f6:	84ce                	mv	s1,s3
 1f8:	0349d663          	bge	s3,s4,224 <gets+0x5a>
    cc = read(0, &c, 1);
 1fc:	8656                	mv	a2,s5
 1fe:	85da                	mv	a1,s6
 200:	4501                	li	a0,0
 202:	00000097          	auipc	ra,0x0
 206:	1a4080e7          	jalr	420(ra) # 3a6 <read>
    if(cc < 1)
 20a:	00a05d63          	blez	a0,224 <gets+0x5a>
      break;
    buf[i++] = c;
 20e:	faf44783          	lbu	a5,-81(s0)
 212:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 216:	0905                	addi	s2,s2,1
 218:	ff678713          	addi	a4,a5,-10
 21c:	c319                	beqz	a4,222 <gets+0x58>
 21e:	17cd                	addi	a5,a5,-13
 220:	fbe1                	bnez	a5,1f0 <gets+0x26>
    buf[i++] = c;
 222:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 224:	9c5e                	add	s8,s8,s7
 226:	000c0023          	sb	zero,0(s8)
  return buf;
}
 22a:	855e                	mv	a0,s7
 22c:	60e6                	ld	ra,88(sp)
 22e:	6446                	ld	s0,80(sp)
 230:	64a6                	ld	s1,72(sp)
 232:	6906                	ld	s2,64(sp)
 234:	79e2                	ld	s3,56(sp)
 236:	7a42                	ld	s4,48(sp)
 238:	7aa2                	ld	s5,40(sp)
 23a:	7b02                	ld	s6,32(sp)
 23c:	6be2                	ld	s7,24(sp)
 23e:	6c42                	ld	s8,16(sp)
 240:	6125                	addi	sp,sp,96
 242:	8082                	ret

0000000000000244 <stat>:

int
stat(const char *n, struct stat *st)
{
 244:	1101                	addi	sp,sp,-32
 246:	ec06                	sd	ra,24(sp)
 248:	e822                	sd	s0,16(sp)
 24a:	e04a                	sd	s2,0(sp)
 24c:	1000                	addi	s0,sp,32
 24e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 250:	4581                	li	a1,0
 252:	00000097          	auipc	ra,0x0
 256:	17c080e7          	jalr	380(ra) # 3ce <open>
  if(fd < 0)
 25a:	02054663          	bltz	a0,286 <stat+0x42>
 25e:	e426                	sd	s1,8(sp)
 260:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 262:	85ca                	mv	a1,s2
 264:	00000097          	auipc	ra,0x0
 268:	182080e7          	jalr	386(ra) # 3e6 <fstat>
 26c:	892a                	mv	s2,a0
  close(fd);
 26e:	8526                	mv	a0,s1
 270:	00000097          	auipc	ra,0x0
 274:	146080e7          	jalr	326(ra) # 3b6 <close>
  return r;
 278:	64a2                	ld	s1,8(sp)
}
 27a:	854a                	mv	a0,s2
 27c:	60e2                	ld	ra,24(sp)
 27e:	6442                	ld	s0,16(sp)
 280:	6902                	ld	s2,0(sp)
 282:	6105                	addi	sp,sp,32
 284:	8082                	ret
    return -1;
 286:	57fd                	li	a5,-1
 288:	893e                	mv	s2,a5
 28a:	bfc5                	j	27a <stat+0x36>

000000000000028c <atoi>:

int
atoi(const char *s)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e406                	sd	ra,8(sp)
 290:	e022                	sd	s0,0(sp)
 292:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 294:	00054683          	lbu	a3,0(a0)
 298:	fd06879b          	addiw	a5,a3,-48
 29c:	0ff7f793          	zext.b	a5,a5
 2a0:	4625                	li	a2,9
 2a2:	02f66963          	bltu	a2,a5,2d4 <atoi+0x48>
 2a6:	872a                	mv	a4,a0
  n = 0;
 2a8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2aa:	0705                	addi	a4,a4,1
 2ac:	0025179b          	slliw	a5,a0,0x2
 2b0:	9fa9                	addw	a5,a5,a0
 2b2:	0017979b          	slliw	a5,a5,0x1
 2b6:	9fb5                	addw	a5,a5,a3
 2b8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2bc:	00074683          	lbu	a3,0(a4)
 2c0:	fd06879b          	addiw	a5,a3,-48
 2c4:	0ff7f793          	zext.b	a5,a5
 2c8:	fef671e3          	bgeu	a2,a5,2aa <atoi+0x1e>
  return n;
}
 2cc:	60a2                	ld	ra,8(sp)
 2ce:	6402                	ld	s0,0(sp)
 2d0:	0141                	addi	sp,sp,16
 2d2:	8082                	ret
  n = 0;
 2d4:	4501                	li	a0,0
 2d6:	bfdd                	j	2cc <atoi+0x40>

00000000000002d8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d8:	1141                	addi	sp,sp,-16
 2da:	e406                	sd	ra,8(sp)
 2dc:	e022                	sd	s0,0(sp)
 2de:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e0:	02b57563          	bgeu	a0,a1,30a <memmove+0x32>
    while(n-- > 0)
 2e4:	00c05f63          	blez	a2,302 <memmove+0x2a>
 2e8:	1602                	slli	a2,a2,0x20
 2ea:	9201                	srli	a2,a2,0x20
 2ec:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2f0:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f2:	0585                	addi	a1,a1,1
 2f4:	0705                	addi	a4,a4,1
 2f6:	fff5c683          	lbu	a3,-1(a1)
 2fa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2fe:	fee79ae3          	bne	a5,a4,2f2 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 302:	60a2                	ld	ra,8(sp)
 304:	6402                	ld	s0,0(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret
    while(n-- > 0)
 30a:	fec05ce3          	blez	a2,302 <memmove+0x2a>
    dst += n;
 30e:	00c50733          	add	a4,a0,a2
    src += n;
 312:	95b2                	add	a1,a1,a2
 314:	fff6079b          	addiw	a5,a2,-1
 318:	1782                	slli	a5,a5,0x20
 31a:	9381                	srli	a5,a5,0x20
 31c:	fff7c793          	not	a5,a5
 320:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 322:	15fd                	addi	a1,a1,-1
 324:	177d                	addi	a4,a4,-1
 326:	0005c683          	lbu	a3,0(a1)
 32a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 32e:	fef71ae3          	bne	a4,a5,322 <memmove+0x4a>
 332:	bfc1                	j	302 <memmove+0x2a>

0000000000000334 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 334:	1141                	addi	sp,sp,-16
 336:	e406                	sd	ra,8(sp)
 338:	e022                	sd	s0,0(sp)
 33a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 33c:	c61d                	beqz	a2,36a <memcmp+0x36>
 33e:	1602                	slli	a2,a2,0x20
 340:	9201                	srli	a2,a2,0x20
 342:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 346:	00054783          	lbu	a5,0(a0)
 34a:	0005c703          	lbu	a4,0(a1)
 34e:	00e79863          	bne	a5,a4,35e <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 352:	0505                	addi	a0,a0,1
    p2++;
 354:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 356:	fed518e3          	bne	a0,a3,346 <memcmp+0x12>
  }
  return 0;
 35a:	4501                	li	a0,0
 35c:	a019                	j	362 <memcmp+0x2e>
      return *p1 - *p2;
 35e:	40e7853b          	subw	a0,a5,a4
}
 362:	60a2                	ld	ra,8(sp)
 364:	6402                	ld	s0,0(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret
  return 0;
 36a:	4501                	li	a0,0
 36c:	bfdd                	j	362 <memcmp+0x2e>

000000000000036e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e406                	sd	ra,8(sp)
 372:	e022                	sd	s0,0(sp)
 374:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 376:	00000097          	auipc	ra,0x0
 37a:	f62080e7          	jalr	-158(ra) # 2d8 <memmove>
}
 37e:	60a2                	ld	ra,8(sp)
 380:	6402                	ld	s0,0(sp)
 382:	0141                	addi	sp,sp,16
 384:	8082                	ret

0000000000000386 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 386:	4885                	li	a7,1
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <exit>:
.global exit
exit:
 li a7, SYS_exit
 38e:	4889                	li	a7,2
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <wait>:
.global wait
wait:
 li a7, SYS_wait
 396:	488d                	li	a7,3
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 39e:	4891                	li	a7,4
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <read>:
.global read
read:
 li a7, SYS_read
 3a6:	4895                	li	a7,5
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <write>:
.global write
write:
 li a7, SYS_write
 3ae:	48c1                	li	a7,16
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <close>:
.global close
close:
 li a7, SYS_close
 3b6:	48d5                	li	a7,21
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <kill>:
.global kill
kill:
 li a7, SYS_kill
 3be:	4899                	li	a7,6
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c6:	489d                	li	a7,7
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <open>:
.global open
open:
 li a7, SYS_open
 3ce:	48bd                	li	a7,15
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d6:	48c5                	li	a7,17
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3de:	48c9                	li	a7,18
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e6:	48a1                	li	a7,8
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <link>:
.global link
link:
 li a7, SYS_link
 3ee:	48cd                	li	a7,19
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f6:	48d1                	li	a7,20
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3fe:	48a5                	li	a7,9
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <dup>:
.global dup
dup:
 li a7, SYS_dup
 406:	48a9                	li	a7,10
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 40e:	48ad                	li	a7,11
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 416:	48b1                	li	a7,12
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 41e:	48b5                	li	a7,13
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 426:	48b9                	li	a7,14
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <nanotime>:
.global nanotime
nanotime:
 li a7, SYS_nanotime
 42e:	48d9                	li	a7,22
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 436:	1101                	addi	sp,sp,-32
 438:	ec06                	sd	ra,24(sp)
 43a:	e822                	sd	s0,16(sp)
 43c:	1000                	addi	s0,sp,32
 43e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 442:	4605                	li	a2,1
 444:	fef40593          	addi	a1,s0,-17
 448:	00000097          	auipc	ra,0x0
 44c:	f66080e7          	jalr	-154(ra) # 3ae <write>
}
 450:	60e2                	ld	ra,24(sp)
 452:	6442                	ld	s0,16(sp)
 454:	6105                	addi	sp,sp,32
 456:	8082                	ret

0000000000000458 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 458:	7139                	addi	sp,sp,-64
 45a:	fc06                	sd	ra,56(sp)
 45c:	f822                	sd	s0,48(sp)
 45e:	f04a                	sd	s2,32(sp)
 460:	ec4e                	sd	s3,24(sp)
 462:	0080                	addi	s0,sp,64
 464:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 466:	cad9                	beqz	a3,4fc <printint+0xa4>
 468:	01f5d79b          	srliw	a5,a1,0x1f
 46c:	cbc1                	beqz	a5,4fc <printint+0xa4>
    neg = 1;
    x = -xx;
 46e:	40b005bb          	negw	a1,a1
    neg = 1;
 472:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 474:	fc040993          	addi	s3,s0,-64
  neg = 0;
 478:	86ce                	mv	a3,s3
  i = 0;
 47a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 47c:	00000817          	auipc	a6,0x0
 480:	4b480813          	addi	a6,a6,1204 # 930 <digits>
 484:	88ba                	mv	a7,a4
 486:	0017051b          	addiw	a0,a4,1
 48a:	872a                	mv	a4,a0
 48c:	02c5f7bb          	remuw	a5,a1,a2
 490:	1782                	slli	a5,a5,0x20
 492:	9381                	srli	a5,a5,0x20
 494:	97c2                	add	a5,a5,a6
 496:	0007c783          	lbu	a5,0(a5)
 49a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 49e:	87ae                	mv	a5,a1
 4a0:	02c5d5bb          	divuw	a1,a1,a2
 4a4:	0685                	addi	a3,a3,1
 4a6:	fcc7ffe3          	bgeu	a5,a2,484 <printint+0x2c>
  if(neg)
 4aa:	00030c63          	beqz	t1,4c2 <printint+0x6a>
    buf[i++] = '-';
 4ae:	fd050793          	addi	a5,a0,-48
 4b2:	00878533          	add	a0,a5,s0
 4b6:	02d00793          	li	a5,45
 4ba:	fef50823          	sb	a5,-16(a0)
 4be:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4c2:	02e05763          	blez	a4,4f0 <printint+0x98>
 4c6:	f426                	sd	s1,40(sp)
 4c8:	377d                	addiw	a4,a4,-1
 4ca:	00e984b3          	add	s1,s3,a4
 4ce:	19fd                	addi	s3,s3,-1
 4d0:	99ba                	add	s3,s3,a4
 4d2:	1702                	slli	a4,a4,0x20
 4d4:	9301                	srli	a4,a4,0x20
 4d6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4da:	0004c583          	lbu	a1,0(s1)
 4de:	854a                	mv	a0,s2
 4e0:	00000097          	auipc	ra,0x0
 4e4:	f56080e7          	jalr	-170(ra) # 436 <putc>
  while(--i >= 0)
 4e8:	14fd                	addi	s1,s1,-1
 4ea:	ff3498e3          	bne	s1,s3,4da <printint+0x82>
 4ee:	74a2                	ld	s1,40(sp)
}
 4f0:	70e2                	ld	ra,56(sp)
 4f2:	7442                	ld	s0,48(sp)
 4f4:	7902                	ld	s2,32(sp)
 4f6:	69e2                	ld	s3,24(sp)
 4f8:	6121                	addi	sp,sp,64
 4fa:	8082                	ret
  neg = 0;
 4fc:	4301                	li	t1,0
 4fe:	bf9d                	j	474 <printint+0x1c>

0000000000000500 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 500:	715d                	addi	sp,sp,-80
 502:	e486                	sd	ra,72(sp)
 504:	e0a2                	sd	s0,64(sp)
 506:	f84a                	sd	s2,48(sp)
 508:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 50a:	0005c903          	lbu	s2,0(a1)
 50e:	1a090b63          	beqz	s2,6c4 <vprintf+0x1c4>
 512:	fc26                	sd	s1,56(sp)
 514:	f44e                	sd	s3,40(sp)
 516:	f052                	sd	s4,32(sp)
 518:	ec56                	sd	s5,24(sp)
 51a:	e85a                	sd	s6,16(sp)
 51c:	e45e                	sd	s7,8(sp)
 51e:	8aaa                	mv	s5,a0
 520:	8bb2                	mv	s7,a2
 522:	00158493          	addi	s1,a1,1
  state = 0;
 526:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 528:	02500a13          	li	s4,37
 52c:	4b55                	li	s6,21
 52e:	a839                	j	54c <vprintf+0x4c>
        putc(fd, c);
 530:	85ca                	mv	a1,s2
 532:	8556                	mv	a0,s5
 534:	00000097          	auipc	ra,0x0
 538:	f02080e7          	jalr	-254(ra) # 436 <putc>
 53c:	a019                	j	542 <vprintf+0x42>
    } else if(state == '%'){
 53e:	01498d63          	beq	s3,s4,558 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 542:	0485                	addi	s1,s1,1
 544:	fff4c903          	lbu	s2,-1(s1)
 548:	16090863          	beqz	s2,6b8 <vprintf+0x1b8>
    if(state == 0){
 54c:	fe0999e3          	bnez	s3,53e <vprintf+0x3e>
      if(c == '%'){
 550:	ff4910e3          	bne	s2,s4,530 <vprintf+0x30>
        state = '%';
 554:	89d2                	mv	s3,s4
 556:	b7f5                	j	542 <vprintf+0x42>
      if(c == 'd'){
 558:	13490563          	beq	s2,s4,682 <vprintf+0x182>
 55c:	f9d9079b          	addiw	a5,s2,-99
 560:	0ff7f793          	zext.b	a5,a5
 564:	12fb6863          	bltu	s6,a5,694 <vprintf+0x194>
 568:	f9d9079b          	addiw	a5,s2,-99
 56c:	0ff7f713          	zext.b	a4,a5
 570:	12eb6263          	bltu	s6,a4,694 <vprintf+0x194>
 574:	00271793          	slli	a5,a4,0x2
 578:	00000717          	auipc	a4,0x0
 57c:	36070713          	addi	a4,a4,864 # 8d8 <malloc+0x120>
 580:	97ba                	add	a5,a5,a4
 582:	439c                	lw	a5,0(a5)
 584:	97ba                	add	a5,a5,a4
 586:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 588:	008b8913          	addi	s2,s7,8
 58c:	4685                	li	a3,1
 58e:	4629                	li	a2,10
 590:	000ba583          	lw	a1,0(s7)
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	ec2080e7          	jalr	-318(ra) # 458 <printint>
 59e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5a0:	4981                	li	s3,0
 5a2:	b745                	j	542 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5a4:	008b8913          	addi	s2,s7,8
 5a8:	4681                	li	a3,0
 5aa:	4629                	li	a2,10
 5ac:	000ba583          	lw	a1,0(s7)
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	ea6080e7          	jalr	-346(ra) # 458 <printint>
 5ba:	8bca                	mv	s7,s2
      state = 0;
 5bc:	4981                	li	s3,0
 5be:	b751                	j	542 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 5c0:	008b8913          	addi	s2,s7,8
 5c4:	4681                	li	a3,0
 5c6:	4641                	li	a2,16
 5c8:	000ba583          	lw	a1,0(s7)
 5cc:	8556                	mv	a0,s5
 5ce:	00000097          	auipc	ra,0x0
 5d2:	e8a080e7          	jalr	-374(ra) # 458 <printint>
 5d6:	8bca                	mv	s7,s2
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	b7a5                	j	542 <vprintf+0x42>
 5dc:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5de:	008b8793          	addi	a5,s7,8
 5e2:	8c3e                	mv	s8,a5
 5e4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5e8:	03000593          	li	a1,48
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	e48080e7          	jalr	-440(ra) # 436 <putc>
  putc(fd, 'x');
 5f6:	07800593          	li	a1,120
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	e3a080e7          	jalr	-454(ra) # 436 <putc>
 604:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 606:	00000b97          	auipc	s7,0x0
 60a:	32ab8b93          	addi	s7,s7,810 # 930 <digits>
 60e:	03c9d793          	srli	a5,s3,0x3c
 612:	97de                	add	a5,a5,s7
 614:	0007c583          	lbu	a1,0(a5)
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	e1c080e7          	jalr	-484(ra) # 436 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 622:	0992                	slli	s3,s3,0x4
 624:	397d                	addiw	s2,s2,-1
 626:	fe0914e3          	bnez	s2,60e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 62a:	8be2                	mv	s7,s8
      state = 0;
 62c:	4981                	li	s3,0
 62e:	6c02                	ld	s8,0(sp)
 630:	bf09                	j	542 <vprintf+0x42>
        s = va_arg(ap, char*);
 632:	008b8993          	addi	s3,s7,8
 636:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 63a:	02090163          	beqz	s2,65c <vprintf+0x15c>
        while(*s != 0){
 63e:	00094583          	lbu	a1,0(s2)
 642:	c9a5                	beqz	a1,6b2 <vprintf+0x1b2>
          putc(fd, *s);
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	df0080e7          	jalr	-528(ra) # 436 <putc>
          s++;
 64e:	0905                	addi	s2,s2,1
        while(*s != 0){
 650:	00094583          	lbu	a1,0(s2)
 654:	f9e5                	bnez	a1,644 <vprintf+0x144>
        s = va_arg(ap, char*);
 656:	8bce                	mv	s7,s3
      state = 0;
 658:	4981                	li	s3,0
 65a:	b5e5                	j	542 <vprintf+0x42>
          s = "(null)";
 65c:	00000917          	auipc	s2,0x0
 660:	27490913          	addi	s2,s2,628 # 8d0 <malloc+0x118>
        while(*s != 0){
 664:	02800593          	li	a1,40
 668:	bff1                	j	644 <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 66a:	008b8913          	addi	s2,s7,8
 66e:	000bc583          	lbu	a1,0(s7)
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	dc2080e7          	jalr	-574(ra) # 436 <putc>
 67c:	8bca                	mv	s7,s2
      state = 0;
 67e:	4981                	li	s3,0
 680:	b5c9                	j	542 <vprintf+0x42>
        putc(fd, c);
 682:	02500593          	li	a1,37
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	dae080e7          	jalr	-594(ra) # 436 <putc>
      state = 0;
 690:	4981                	li	s3,0
 692:	bd45                	j	542 <vprintf+0x42>
        putc(fd, '%');
 694:	02500593          	li	a1,37
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	d9c080e7          	jalr	-612(ra) # 436 <putc>
        putc(fd, c);
 6a2:	85ca                	mv	a1,s2
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	d90080e7          	jalr	-624(ra) # 436 <putc>
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	bd49                	j	542 <vprintf+0x42>
        s = va_arg(ap, char*);
 6b2:	8bce                	mv	s7,s3
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	b571                	j	542 <vprintf+0x42>
 6b8:	74e2                	ld	s1,56(sp)
 6ba:	79a2                	ld	s3,40(sp)
 6bc:	7a02                	ld	s4,32(sp)
 6be:	6ae2                	ld	s5,24(sp)
 6c0:	6b42                	ld	s6,16(sp)
 6c2:	6ba2                	ld	s7,8(sp)
    }
  }
}
 6c4:	60a6                	ld	ra,72(sp)
 6c6:	6406                	ld	s0,64(sp)
 6c8:	7942                	ld	s2,48(sp)
 6ca:	6161                	addi	sp,sp,80
 6cc:	8082                	ret

00000000000006ce <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ce:	715d                	addi	sp,sp,-80
 6d0:	ec06                	sd	ra,24(sp)
 6d2:	e822                	sd	s0,16(sp)
 6d4:	1000                	addi	s0,sp,32
 6d6:	e010                	sd	a2,0(s0)
 6d8:	e414                	sd	a3,8(s0)
 6da:	e818                	sd	a4,16(s0)
 6dc:	ec1c                	sd	a5,24(s0)
 6de:	03043023          	sd	a6,32(s0)
 6e2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6e6:	8622                	mv	a2,s0
 6e8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ec:	00000097          	auipc	ra,0x0
 6f0:	e14080e7          	jalr	-492(ra) # 500 <vprintf>
}
 6f4:	60e2                	ld	ra,24(sp)
 6f6:	6442                	ld	s0,16(sp)
 6f8:	6161                	addi	sp,sp,80
 6fa:	8082                	ret

00000000000006fc <printf>:

void
printf(const char *fmt, ...)
{
 6fc:	711d                	addi	sp,sp,-96
 6fe:	ec06                	sd	ra,24(sp)
 700:	e822                	sd	s0,16(sp)
 702:	1000                	addi	s0,sp,32
 704:	e40c                	sd	a1,8(s0)
 706:	e810                	sd	a2,16(s0)
 708:	ec14                	sd	a3,24(s0)
 70a:	f018                	sd	a4,32(s0)
 70c:	f41c                	sd	a5,40(s0)
 70e:	03043823          	sd	a6,48(s0)
 712:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 716:	00840613          	addi	a2,s0,8
 71a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 71e:	85aa                	mv	a1,a0
 720:	4505                	li	a0,1
 722:	00000097          	auipc	ra,0x0
 726:	dde080e7          	jalr	-546(ra) # 500 <vprintf>
}
 72a:	60e2                	ld	ra,24(sp)
 72c:	6442                	ld	s0,16(sp)
 72e:	6125                	addi	sp,sp,96
 730:	8082                	ret

0000000000000732 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 732:	1141                	addi	sp,sp,-16
 734:	e406                	sd	ra,8(sp)
 736:	e022                	sd	s0,0(sp)
 738:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 73a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 73e:	00001797          	auipc	a5,0x1
 742:	8c27b783          	ld	a5,-1854(a5) # 1000 <freep>
 746:	a039                	j	754 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 748:	6398                	ld	a4,0(a5)
 74a:	00e7e463          	bltu	a5,a4,752 <free+0x20>
 74e:	00e6ea63          	bltu	a3,a4,762 <free+0x30>
{
 752:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 754:	fed7fae3          	bgeu	a5,a3,748 <free+0x16>
 758:	6398                	ld	a4,0(a5)
 75a:	00e6e463          	bltu	a3,a4,762 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75e:	fee7eae3          	bltu	a5,a4,752 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 762:	ff852583          	lw	a1,-8(a0)
 766:	6390                	ld	a2,0(a5)
 768:	02059813          	slli	a6,a1,0x20
 76c:	01c85713          	srli	a4,a6,0x1c
 770:	9736                	add	a4,a4,a3
 772:	02e60563          	beq	a2,a4,79c <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 776:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 77a:	4790                	lw	a2,8(a5)
 77c:	02061593          	slli	a1,a2,0x20
 780:	01c5d713          	srli	a4,a1,0x1c
 784:	973e                	add	a4,a4,a5
 786:	02e68263          	beq	a3,a4,7aa <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 78a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 78c:	00001717          	auipc	a4,0x1
 790:	86f73a23          	sd	a5,-1932(a4) # 1000 <freep>
}
 794:	60a2                	ld	ra,8(sp)
 796:	6402                	ld	s0,0(sp)
 798:	0141                	addi	sp,sp,16
 79a:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 79c:	4618                	lw	a4,8(a2)
 79e:	9f2d                	addw	a4,a4,a1
 7a0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a4:	6398                	ld	a4,0(a5)
 7a6:	6310                	ld	a2,0(a4)
 7a8:	b7f9                	j	776 <free+0x44>
    p->s.size += bp->s.size;
 7aa:	ff852703          	lw	a4,-8(a0)
 7ae:	9f31                	addw	a4,a4,a2
 7b0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7b2:	ff053683          	ld	a3,-16(a0)
 7b6:	bfd1                	j	78a <free+0x58>

00000000000007b8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7b8:	7139                	addi	sp,sp,-64
 7ba:	fc06                	sd	ra,56(sp)
 7bc:	f822                	sd	s0,48(sp)
 7be:	f04a                	sd	s2,32(sp)
 7c0:	ec4e                	sd	s3,24(sp)
 7c2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c4:	02051993          	slli	s3,a0,0x20
 7c8:	0209d993          	srli	s3,s3,0x20
 7cc:	09bd                	addi	s3,s3,15
 7ce:	0049d993          	srli	s3,s3,0x4
 7d2:	2985                	addiw	s3,s3,1
 7d4:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 7d6:	00001517          	auipc	a0,0x1
 7da:	82a53503          	ld	a0,-2006(a0) # 1000 <freep>
 7de:	c905                	beqz	a0,80e <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7e2:	4798                	lw	a4,8(a5)
 7e4:	09377a63          	bgeu	a4,s3,878 <malloc+0xc0>
 7e8:	f426                	sd	s1,40(sp)
 7ea:	e852                	sd	s4,16(sp)
 7ec:	e456                	sd	s5,8(sp)
 7ee:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7f0:	8a4e                	mv	s4,s3
 7f2:	6705                	lui	a4,0x1
 7f4:	00e9f363          	bgeu	s3,a4,7fa <malloc+0x42>
 7f8:	6a05                	lui	s4,0x1
 7fa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7fe:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 802:	00000497          	auipc	s1,0x0
 806:	7fe48493          	addi	s1,s1,2046 # 1000 <freep>
  if(p == (char*)-1)
 80a:	5afd                	li	s5,-1
 80c:	a089                	j	84e <malloc+0x96>
 80e:	f426                	sd	s1,40(sp)
 810:	e852                	sd	s4,16(sp)
 812:	e456                	sd	s5,8(sp)
 814:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 816:	00000797          	auipc	a5,0x0
 81a:	7fa78793          	addi	a5,a5,2042 # 1010 <base>
 81e:	00000717          	auipc	a4,0x0
 822:	7ef73123          	sd	a5,2018(a4) # 1000 <freep>
 826:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 828:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 82c:	b7d1                	j	7f0 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 82e:	6398                	ld	a4,0(a5)
 830:	e118                	sd	a4,0(a0)
 832:	a8b9                	j	890 <malloc+0xd8>
  hp->s.size = nu;
 834:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 838:	0541                	addi	a0,a0,16
 83a:	00000097          	auipc	ra,0x0
 83e:	ef8080e7          	jalr	-264(ra) # 732 <free>
  return freep;
 842:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 844:	c135                	beqz	a0,8a8 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 846:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 848:	4798                	lw	a4,8(a5)
 84a:	03277363          	bgeu	a4,s2,870 <malloc+0xb8>
    if(p == freep)
 84e:	6098                	ld	a4,0(s1)
 850:	853e                	mv	a0,a5
 852:	fef71ae3          	bne	a4,a5,846 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 856:	8552                	mv	a0,s4
 858:	00000097          	auipc	ra,0x0
 85c:	bbe080e7          	jalr	-1090(ra) # 416 <sbrk>
  if(p == (char*)-1)
 860:	fd551ae3          	bne	a0,s5,834 <malloc+0x7c>
        return 0;
 864:	4501                	li	a0,0
 866:	74a2                	ld	s1,40(sp)
 868:	6a42                	ld	s4,16(sp)
 86a:	6aa2                	ld	s5,8(sp)
 86c:	6b02                	ld	s6,0(sp)
 86e:	a03d                	j	89c <malloc+0xe4>
 870:	74a2                	ld	s1,40(sp)
 872:	6a42                	ld	s4,16(sp)
 874:	6aa2                	ld	s5,8(sp)
 876:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 878:	fae90be3          	beq	s2,a4,82e <malloc+0x76>
        p->s.size -= nunits;
 87c:	4137073b          	subw	a4,a4,s3
 880:	c798                	sw	a4,8(a5)
        p += p->s.size;
 882:	02071693          	slli	a3,a4,0x20
 886:	01c6d713          	srli	a4,a3,0x1c
 88a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 88c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 890:	00000717          	auipc	a4,0x0
 894:	76a73823          	sd	a0,1904(a4) # 1000 <freep>
      return (void*)(p + 1);
 898:	01078513          	addi	a0,a5,16
  }
}
 89c:	70e2                	ld	ra,56(sp)
 89e:	7442                	ld	s0,48(sp)
 8a0:	7902                	ld	s2,32(sp)
 8a2:	69e2                	ld	s3,24(sp)
 8a4:	6121                	addi	sp,sp,64
 8a6:	8082                	ret
 8a8:	74a2                	ld	s1,40(sp)
 8aa:	6a42                	ld	s4,16(sp)
 8ac:	6aa2                	ld	s5,8(sp)
 8ae:	6b02                	ld	s6,0(sp)
 8b0:	b7f5                	j	89c <malloc+0xe4>
