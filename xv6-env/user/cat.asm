
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
  12:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  14:	20000a13          	li	s4,512
  18:	00001917          	auipc	s2,0x1
  1c:	ff890913          	addi	s2,s2,-8 # 1010 <buf>
    if (write(1, buf, n) != n) {
  20:	4a85                	li	s5,1
  while((n = read(fd, buf, sizeof(buf))) > 0) {
  22:	8652                	mv	a2,s4
  24:	85ca                	mv	a1,s2
  26:	854e                	mv	a0,s3
  28:	00000097          	auipc	ra,0x0
  2c:	3c6080e7          	jalr	966(ra) # 3ee <read>
  30:	84aa                	mv	s1,a0
  32:	02a05963          	blez	a0,64 <cat+0x64>
    if (write(1, buf, n) != n) {
  36:	8626                	mv	a2,s1
  38:	85ca                	mv	a1,s2
  3a:	8556                	mv	a0,s5
  3c:	00000097          	auipc	ra,0x0
  40:	3ba080e7          	jalr	954(ra) # 3f6 <write>
  44:	fc950fe3          	beq	a0,s1,22 <cat+0x22>
      fprintf(2, "cat: write error\n");
  48:	00001597          	auipc	a1,0x1
  4c:	8b858593          	addi	a1,a1,-1864 # 900 <malloc+0x100>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	6c4080e7          	jalr	1732(ra) # 716 <fprintf>
      exit(1);
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	37a080e7          	jalr	890(ra) # 3d6 <exit>
    }
  }
  if(n < 0){
  64:	00054b63          	bltz	a0,7a <cat+0x7a>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  68:	70e2                	ld	ra,56(sp)
  6a:	7442                	ld	s0,48(sp)
  6c:	74a2                	ld	s1,40(sp)
  6e:	7902                	ld	s2,32(sp)
  70:	69e2                	ld	s3,24(sp)
  72:	6a42                	ld	s4,16(sp)
  74:	6aa2                	ld	s5,8(sp)
  76:	6121                	addi	sp,sp,64
  78:	8082                	ret
    fprintf(2, "cat: read error\n");
  7a:	00001597          	auipc	a1,0x1
  7e:	89e58593          	addi	a1,a1,-1890 # 918 <malloc+0x118>
  82:	4509                	li	a0,2
  84:	00000097          	auipc	ra,0x0
  88:	692080e7          	jalr	1682(ra) # 716 <fprintf>
    exit(1);
  8c:	4505                	li	a0,1
  8e:	00000097          	auipc	ra,0x0
  92:	348080e7          	jalr	840(ra) # 3d6 <exit>

0000000000000096 <main>:

int
main(int argc, char *argv[])
{
  96:	7179                	addi	sp,sp,-48
  98:	f406                	sd	ra,40(sp)
  9a:	f022                	sd	s0,32(sp)
  9c:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  9e:	4785                	li	a5,1
  a0:	04a7da63          	bge	a5,a0,f4 <main+0x5e>
  a4:	ec26                	sd	s1,24(sp)
  a6:	e84a                	sd	s2,16(sp)
  a8:	e44e                	sd	s3,8(sp)
  aa:	00858913          	addi	s2,a1,8
  ae:	ffe5099b          	addiw	s3,a0,-2
  b2:	02099793          	slli	a5,s3,0x20
  b6:	01d7d993          	srli	s3,a5,0x1d
  ba:	05c1                	addi	a1,a1,16
  bc:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  be:	4581                	li	a1,0
  c0:	00093503          	ld	a0,0(s2)
  c4:	00000097          	auipc	ra,0x0
  c8:	352080e7          	jalr	850(ra) # 416 <open>
  cc:	84aa                	mv	s1,a0
  ce:	04054063          	bltz	a0,10e <main+0x78>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  d2:	00000097          	auipc	ra,0x0
  d6:	f2e080e7          	jalr	-210(ra) # 0 <cat>
    close(fd);
  da:	8526                	mv	a0,s1
  dc:	00000097          	auipc	ra,0x0
  e0:	322080e7          	jalr	802(ra) # 3fe <close>
  for(i = 1; i < argc; i++){
  e4:	0921                	addi	s2,s2,8
  e6:	fd391ce3          	bne	s2,s3,be <main+0x28>
  }
  exit(0);
  ea:	4501                	li	a0,0
  ec:	00000097          	auipc	ra,0x0
  f0:	2ea080e7          	jalr	746(ra) # 3d6 <exit>
  f4:	ec26                	sd	s1,24(sp)
  f6:	e84a                	sd	s2,16(sp)
  f8:	e44e                	sd	s3,8(sp)
    cat(0);
  fa:	4501                	li	a0,0
  fc:	00000097          	auipc	ra,0x0
 100:	f04080e7          	jalr	-252(ra) # 0 <cat>
    exit(0);
 104:	4501                	li	a0,0
 106:	00000097          	auipc	ra,0x0
 10a:	2d0080e7          	jalr	720(ra) # 3d6 <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
 10e:	00093603          	ld	a2,0(s2)
 112:	00001597          	auipc	a1,0x1
 116:	81e58593          	addi	a1,a1,-2018 # 930 <malloc+0x130>
 11a:	4509                	li	a0,2
 11c:	00000097          	auipc	ra,0x0
 120:	5fa080e7          	jalr	1530(ra) # 716 <fprintf>
      exit(1);
 124:	4505                	li	a0,1
 126:	00000097          	auipc	ra,0x0
 12a:	2b0080e7          	jalr	688(ra) # 3d6 <exit>

000000000000012e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 12e:	1141                	addi	sp,sp,-16
 130:	e406                	sd	ra,8(sp)
 132:	e022                	sd	s0,0(sp)
 134:	0800                	addi	s0,sp,16
  extern int main();
  main();
 136:	00000097          	auipc	ra,0x0
 13a:	f60080e7          	jalr	-160(ra) # 96 <main>
  exit(0);
 13e:	4501                	li	a0,0
 140:	00000097          	auipc	ra,0x0
 144:	296080e7          	jalr	662(ra) # 3d6 <exit>

0000000000000148 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e406                	sd	ra,8(sp)
 14c:	e022                	sd	s0,0(sp)
 14e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 150:	87aa                	mv	a5,a0
 152:	0585                	addi	a1,a1,1
 154:	0785                	addi	a5,a5,1
 156:	fff5c703          	lbu	a4,-1(a1)
 15a:	fee78fa3          	sb	a4,-1(a5)
 15e:	fb75                	bnez	a4,152 <strcpy+0xa>
    ;
  return os;
}
 160:	60a2                	ld	ra,8(sp)
 162:	6402                	ld	s0,0(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e406                	sd	ra,8(sp)
 16c:	e022                	sd	s0,0(sp)
 16e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 170:	00054783          	lbu	a5,0(a0)
 174:	cb91                	beqz	a5,188 <strcmp+0x20>
 176:	0005c703          	lbu	a4,0(a1)
 17a:	00f71763          	bne	a4,a5,188 <strcmp+0x20>
    p++, q++;
 17e:	0505                	addi	a0,a0,1
 180:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 182:	00054783          	lbu	a5,0(a0)
 186:	fbe5                	bnez	a5,176 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 188:	0005c503          	lbu	a0,0(a1)
}
 18c:	40a7853b          	subw	a0,a5,a0
 190:	60a2                	ld	ra,8(sp)
 192:	6402                	ld	s0,0(sp)
 194:	0141                	addi	sp,sp,16
 196:	8082                	ret

0000000000000198 <strlen>:

uint
strlen(const char *s)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e406                	sd	ra,8(sp)
 19c:	e022                	sd	s0,0(sp)
 19e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	cf91                	beqz	a5,1c0 <strlen+0x28>
 1a6:	00150793          	addi	a5,a0,1
 1aa:	86be                	mv	a3,a5
 1ac:	0785                	addi	a5,a5,1
 1ae:	fff7c703          	lbu	a4,-1(a5)
 1b2:	ff65                	bnez	a4,1aa <strlen+0x12>
 1b4:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 1b8:	60a2                	ld	ra,8(sp)
 1ba:	6402                	ld	s0,0(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret
  for(n = 0; s[n]; n++)
 1c0:	4501                	li	a0,0
 1c2:	bfdd                	j	1b8 <strlen+0x20>

00000000000001c4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c4:	1141                	addi	sp,sp,-16
 1c6:	e406                	sd	ra,8(sp)
 1c8:	e022                	sd	s0,0(sp)
 1ca:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1cc:	ca19                	beqz	a2,1e2 <memset+0x1e>
 1ce:	87aa                	mv	a5,a0
 1d0:	1602                	slli	a2,a2,0x20
 1d2:	9201                	srli	a2,a2,0x20
 1d4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1d8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1dc:	0785                	addi	a5,a5,1
 1de:	fee79de3          	bne	a5,a4,1d8 <memset+0x14>
  }
  return dst;
}
 1e2:	60a2                	ld	ra,8(sp)
 1e4:	6402                	ld	s0,0(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret

00000000000001ea <strchr>:

char*
strchr(const char *s, char c)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e406                	sd	ra,8(sp)
 1ee:	e022                	sd	s0,0(sp)
 1f0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1f2:	00054783          	lbu	a5,0(a0)
 1f6:	cf81                	beqz	a5,20e <strchr+0x24>
    if(*s == c)
 1f8:	00f58763          	beq	a1,a5,206 <strchr+0x1c>
  for(; *s; s++)
 1fc:	0505                	addi	a0,a0,1
 1fe:	00054783          	lbu	a5,0(a0)
 202:	fbfd                	bnez	a5,1f8 <strchr+0xe>
      return (char*)s;
  return 0;
 204:	4501                	li	a0,0
}
 206:	60a2                	ld	ra,8(sp)
 208:	6402                	ld	s0,0(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret
  return 0;
 20e:	4501                	li	a0,0
 210:	bfdd                	j	206 <strchr+0x1c>

0000000000000212 <gets>:

char*
gets(char *buf, int max)
{
 212:	711d                	addi	sp,sp,-96
 214:	ec86                	sd	ra,88(sp)
 216:	e8a2                	sd	s0,80(sp)
 218:	e4a6                	sd	s1,72(sp)
 21a:	e0ca                	sd	s2,64(sp)
 21c:	fc4e                	sd	s3,56(sp)
 21e:	f852                	sd	s4,48(sp)
 220:	f456                	sd	s5,40(sp)
 222:	f05a                	sd	s6,32(sp)
 224:	ec5e                	sd	s7,24(sp)
 226:	e862                	sd	s8,16(sp)
 228:	1080                	addi	s0,sp,96
 22a:	8baa                	mv	s7,a0
 22c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22e:	892a                	mv	s2,a0
 230:	4481                	li	s1,0
    cc = read(0, &c, 1);
 232:	faf40b13          	addi	s6,s0,-81
 236:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 238:	8c26                	mv	s8,s1
 23a:	0014899b          	addiw	s3,s1,1
 23e:	84ce                	mv	s1,s3
 240:	0349d663          	bge	s3,s4,26c <gets+0x5a>
    cc = read(0, &c, 1);
 244:	8656                	mv	a2,s5
 246:	85da                	mv	a1,s6
 248:	4501                	li	a0,0
 24a:	00000097          	auipc	ra,0x0
 24e:	1a4080e7          	jalr	420(ra) # 3ee <read>
    if(cc < 1)
 252:	00a05d63          	blez	a0,26c <gets+0x5a>
      break;
    buf[i++] = c;
 256:	faf44783          	lbu	a5,-81(s0)
 25a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 25e:	0905                	addi	s2,s2,1
 260:	ff678713          	addi	a4,a5,-10
 264:	c319                	beqz	a4,26a <gets+0x58>
 266:	17cd                	addi	a5,a5,-13
 268:	fbe1                	bnez	a5,238 <gets+0x26>
    buf[i++] = c;
 26a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 26c:	9c5e                	add	s8,s8,s7
 26e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 272:	855e                	mv	a0,s7
 274:	60e6                	ld	ra,88(sp)
 276:	6446                	ld	s0,80(sp)
 278:	64a6                	ld	s1,72(sp)
 27a:	6906                	ld	s2,64(sp)
 27c:	79e2                	ld	s3,56(sp)
 27e:	7a42                	ld	s4,48(sp)
 280:	7aa2                	ld	s5,40(sp)
 282:	7b02                	ld	s6,32(sp)
 284:	6be2                	ld	s7,24(sp)
 286:	6c42                	ld	s8,16(sp)
 288:	6125                	addi	sp,sp,96
 28a:	8082                	ret

000000000000028c <stat>:

int
stat(const char *n, struct stat *st)
{
 28c:	1101                	addi	sp,sp,-32
 28e:	ec06                	sd	ra,24(sp)
 290:	e822                	sd	s0,16(sp)
 292:	e04a                	sd	s2,0(sp)
 294:	1000                	addi	s0,sp,32
 296:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 298:	4581                	li	a1,0
 29a:	00000097          	auipc	ra,0x0
 29e:	17c080e7          	jalr	380(ra) # 416 <open>
  if(fd < 0)
 2a2:	02054663          	bltz	a0,2ce <stat+0x42>
 2a6:	e426                	sd	s1,8(sp)
 2a8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2aa:	85ca                	mv	a1,s2
 2ac:	00000097          	auipc	ra,0x0
 2b0:	182080e7          	jalr	386(ra) # 42e <fstat>
 2b4:	892a                	mv	s2,a0
  close(fd);
 2b6:	8526                	mv	a0,s1
 2b8:	00000097          	auipc	ra,0x0
 2bc:	146080e7          	jalr	326(ra) # 3fe <close>
  return r;
 2c0:	64a2                	ld	s1,8(sp)
}
 2c2:	854a                	mv	a0,s2
 2c4:	60e2                	ld	ra,24(sp)
 2c6:	6442                	ld	s0,16(sp)
 2c8:	6902                	ld	s2,0(sp)
 2ca:	6105                	addi	sp,sp,32
 2cc:	8082                	ret
    return -1;
 2ce:	57fd                	li	a5,-1
 2d0:	893e                	mv	s2,a5
 2d2:	bfc5                	j	2c2 <stat+0x36>

00000000000002d4 <atoi>:

int
atoi(const char *s)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e406                	sd	ra,8(sp)
 2d8:	e022                	sd	s0,0(sp)
 2da:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2dc:	00054683          	lbu	a3,0(a0)
 2e0:	fd06879b          	addiw	a5,a3,-48
 2e4:	0ff7f793          	zext.b	a5,a5
 2e8:	4625                	li	a2,9
 2ea:	02f66963          	bltu	a2,a5,31c <atoi+0x48>
 2ee:	872a                	mv	a4,a0
  n = 0;
 2f0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2f2:	0705                	addi	a4,a4,1
 2f4:	0025179b          	slliw	a5,a0,0x2
 2f8:	9fa9                	addw	a5,a5,a0
 2fa:	0017979b          	slliw	a5,a5,0x1
 2fe:	9fb5                	addw	a5,a5,a3
 300:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 304:	00074683          	lbu	a3,0(a4)
 308:	fd06879b          	addiw	a5,a3,-48
 30c:	0ff7f793          	zext.b	a5,a5
 310:	fef671e3          	bgeu	a2,a5,2f2 <atoi+0x1e>
  return n;
}
 314:	60a2                	ld	ra,8(sp)
 316:	6402                	ld	s0,0(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret
  n = 0;
 31c:	4501                	li	a0,0
 31e:	bfdd                	j	314 <atoi+0x40>

0000000000000320 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 320:	1141                	addi	sp,sp,-16
 322:	e406                	sd	ra,8(sp)
 324:	e022                	sd	s0,0(sp)
 326:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 328:	02b57563          	bgeu	a0,a1,352 <memmove+0x32>
    while(n-- > 0)
 32c:	00c05f63          	blez	a2,34a <memmove+0x2a>
 330:	1602                	slli	a2,a2,0x20
 332:	9201                	srli	a2,a2,0x20
 334:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 338:	872a                	mv	a4,a0
      *dst++ = *src++;
 33a:	0585                	addi	a1,a1,1
 33c:	0705                	addi	a4,a4,1
 33e:	fff5c683          	lbu	a3,-1(a1)
 342:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 346:	fee79ae3          	bne	a5,a4,33a <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 34a:	60a2                	ld	ra,8(sp)
 34c:	6402                	ld	s0,0(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret
    while(n-- > 0)
 352:	fec05ce3          	blez	a2,34a <memmove+0x2a>
    dst += n;
 356:	00c50733          	add	a4,a0,a2
    src += n;
 35a:	95b2                	add	a1,a1,a2
 35c:	fff6079b          	addiw	a5,a2,-1
 360:	1782                	slli	a5,a5,0x20
 362:	9381                	srli	a5,a5,0x20
 364:	fff7c793          	not	a5,a5
 368:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 36a:	15fd                	addi	a1,a1,-1
 36c:	177d                	addi	a4,a4,-1
 36e:	0005c683          	lbu	a3,0(a1)
 372:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 376:	fef71ae3          	bne	a4,a5,36a <memmove+0x4a>
 37a:	bfc1                	j	34a <memmove+0x2a>

000000000000037c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 37c:	1141                	addi	sp,sp,-16
 37e:	e406                	sd	ra,8(sp)
 380:	e022                	sd	s0,0(sp)
 382:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 384:	c61d                	beqz	a2,3b2 <memcmp+0x36>
 386:	1602                	slli	a2,a2,0x20
 388:	9201                	srli	a2,a2,0x20
 38a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 38e:	00054783          	lbu	a5,0(a0)
 392:	0005c703          	lbu	a4,0(a1)
 396:	00e79863          	bne	a5,a4,3a6 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 39a:	0505                	addi	a0,a0,1
    p2++;
 39c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 39e:	fed518e3          	bne	a0,a3,38e <memcmp+0x12>
  }
  return 0;
 3a2:	4501                	li	a0,0
 3a4:	a019                	j	3aa <memcmp+0x2e>
      return *p1 - *p2;
 3a6:	40e7853b          	subw	a0,a5,a4
}
 3aa:	60a2                	ld	ra,8(sp)
 3ac:	6402                	ld	s0,0(sp)
 3ae:	0141                	addi	sp,sp,16
 3b0:	8082                	ret
  return 0;
 3b2:	4501                	li	a0,0
 3b4:	bfdd                	j	3aa <memcmp+0x2e>

00000000000003b6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3b6:	1141                	addi	sp,sp,-16
 3b8:	e406                	sd	ra,8(sp)
 3ba:	e022                	sd	s0,0(sp)
 3bc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3be:	00000097          	auipc	ra,0x0
 3c2:	f62080e7          	jalr	-158(ra) # 320 <memmove>
}
 3c6:	60a2                	ld	ra,8(sp)
 3c8:	6402                	ld	s0,0(sp)
 3ca:	0141                	addi	sp,sp,16
 3cc:	8082                	ret

00000000000003ce <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ce:	4885                	li	a7,1
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3d6:	4889                	li	a7,2
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <wait>:
.global wait
wait:
 li a7, SYS_wait
 3de:	488d                	li	a7,3
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3e6:	4891                	li	a7,4
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <read>:
.global read
read:
 li a7, SYS_read
 3ee:	4895                	li	a7,5
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <write>:
.global write
write:
 li a7, SYS_write
 3f6:	48c1                	li	a7,16
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <close>:
.global close
close:
 li a7, SYS_close
 3fe:	48d5                	li	a7,21
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <kill>:
.global kill
kill:
 li a7, SYS_kill
 406:	4899                	li	a7,6
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <exec>:
.global exec
exec:
 li a7, SYS_exec
 40e:	489d                	li	a7,7
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <open>:
.global open
open:
 li a7, SYS_open
 416:	48bd                	li	a7,15
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 41e:	48c5                	li	a7,17
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 426:	48c9                	li	a7,18
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 42e:	48a1                	li	a7,8
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <link>:
.global link
link:
 li a7, SYS_link
 436:	48cd                	li	a7,19
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 43e:	48d1                	li	a7,20
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 446:	48a5                	li	a7,9
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <dup>:
.global dup
dup:
 li a7, SYS_dup
 44e:	48a9                	li	a7,10
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 456:	48ad                	li	a7,11
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 45e:	48b1                	li	a7,12
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 466:	48b5                	li	a7,13
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 46e:	48b9                	li	a7,14
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <nanotime>:
.global nanotime
nanotime:
 li a7, SYS_nanotime
 476:	48d9                	li	a7,22
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 47e:	1101                	addi	sp,sp,-32
 480:	ec06                	sd	ra,24(sp)
 482:	e822                	sd	s0,16(sp)
 484:	1000                	addi	s0,sp,32
 486:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 48a:	4605                	li	a2,1
 48c:	fef40593          	addi	a1,s0,-17
 490:	00000097          	auipc	ra,0x0
 494:	f66080e7          	jalr	-154(ra) # 3f6 <write>
}
 498:	60e2                	ld	ra,24(sp)
 49a:	6442                	ld	s0,16(sp)
 49c:	6105                	addi	sp,sp,32
 49e:	8082                	ret

00000000000004a0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4a0:	7139                	addi	sp,sp,-64
 4a2:	fc06                	sd	ra,56(sp)
 4a4:	f822                	sd	s0,48(sp)
 4a6:	f04a                	sd	s2,32(sp)
 4a8:	ec4e                	sd	s3,24(sp)
 4aa:	0080                	addi	s0,sp,64
 4ac:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ae:	cad9                	beqz	a3,544 <printint+0xa4>
 4b0:	01f5d79b          	srliw	a5,a1,0x1f
 4b4:	cbc1                	beqz	a5,544 <printint+0xa4>
    neg = 1;
    x = -xx;
 4b6:	40b005bb          	negw	a1,a1
    neg = 1;
 4ba:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4bc:	fc040993          	addi	s3,s0,-64
  neg = 0;
 4c0:	86ce                	mv	a3,s3
  i = 0;
 4c2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4c4:	00000817          	auipc	a6,0x0
 4c8:	4e480813          	addi	a6,a6,1252 # 9a8 <digits>
 4cc:	88ba                	mv	a7,a4
 4ce:	0017051b          	addiw	a0,a4,1
 4d2:	872a                	mv	a4,a0
 4d4:	02c5f7bb          	remuw	a5,a1,a2
 4d8:	1782                	slli	a5,a5,0x20
 4da:	9381                	srli	a5,a5,0x20
 4dc:	97c2                	add	a5,a5,a6
 4de:	0007c783          	lbu	a5,0(a5)
 4e2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4e6:	87ae                	mv	a5,a1
 4e8:	02c5d5bb          	divuw	a1,a1,a2
 4ec:	0685                	addi	a3,a3,1
 4ee:	fcc7ffe3          	bgeu	a5,a2,4cc <printint+0x2c>
  if(neg)
 4f2:	00030c63          	beqz	t1,50a <printint+0x6a>
    buf[i++] = '-';
 4f6:	fd050793          	addi	a5,a0,-48
 4fa:	00878533          	add	a0,a5,s0
 4fe:	02d00793          	li	a5,45
 502:	fef50823          	sb	a5,-16(a0)
 506:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 50a:	02e05763          	blez	a4,538 <printint+0x98>
 50e:	f426                	sd	s1,40(sp)
 510:	377d                	addiw	a4,a4,-1
 512:	00e984b3          	add	s1,s3,a4
 516:	19fd                	addi	s3,s3,-1
 518:	99ba                	add	s3,s3,a4
 51a:	1702                	slli	a4,a4,0x20
 51c:	9301                	srli	a4,a4,0x20
 51e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 522:	0004c583          	lbu	a1,0(s1)
 526:	854a                	mv	a0,s2
 528:	00000097          	auipc	ra,0x0
 52c:	f56080e7          	jalr	-170(ra) # 47e <putc>
  while(--i >= 0)
 530:	14fd                	addi	s1,s1,-1
 532:	ff3498e3          	bne	s1,s3,522 <printint+0x82>
 536:	74a2                	ld	s1,40(sp)
}
 538:	70e2                	ld	ra,56(sp)
 53a:	7442                	ld	s0,48(sp)
 53c:	7902                	ld	s2,32(sp)
 53e:	69e2                	ld	s3,24(sp)
 540:	6121                	addi	sp,sp,64
 542:	8082                	ret
  neg = 0;
 544:	4301                	li	t1,0
 546:	bf9d                	j	4bc <printint+0x1c>

0000000000000548 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 548:	715d                	addi	sp,sp,-80
 54a:	e486                	sd	ra,72(sp)
 54c:	e0a2                	sd	s0,64(sp)
 54e:	f84a                	sd	s2,48(sp)
 550:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 552:	0005c903          	lbu	s2,0(a1)
 556:	1a090b63          	beqz	s2,70c <vprintf+0x1c4>
 55a:	fc26                	sd	s1,56(sp)
 55c:	f44e                	sd	s3,40(sp)
 55e:	f052                	sd	s4,32(sp)
 560:	ec56                	sd	s5,24(sp)
 562:	e85a                	sd	s6,16(sp)
 564:	e45e                	sd	s7,8(sp)
 566:	8aaa                	mv	s5,a0
 568:	8bb2                	mv	s7,a2
 56a:	00158493          	addi	s1,a1,1
  state = 0;
 56e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 570:	02500a13          	li	s4,37
 574:	4b55                	li	s6,21
 576:	a839                	j	594 <vprintf+0x4c>
        putc(fd, c);
 578:	85ca                	mv	a1,s2
 57a:	8556                	mv	a0,s5
 57c:	00000097          	auipc	ra,0x0
 580:	f02080e7          	jalr	-254(ra) # 47e <putc>
 584:	a019                	j	58a <vprintf+0x42>
    } else if(state == '%'){
 586:	01498d63          	beq	s3,s4,5a0 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 58a:	0485                	addi	s1,s1,1
 58c:	fff4c903          	lbu	s2,-1(s1)
 590:	16090863          	beqz	s2,700 <vprintf+0x1b8>
    if(state == 0){
 594:	fe0999e3          	bnez	s3,586 <vprintf+0x3e>
      if(c == '%'){
 598:	ff4910e3          	bne	s2,s4,578 <vprintf+0x30>
        state = '%';
 59c:	89d2                	mv	s3,s4
 59e:	b7f5                	j	58a <vprintf+0x42>
      if(c == 'd'){
 5a0:	13490563          	beq	s2,s4,6ca <vprintf+0x182>
 5a4:	f9d9079b          	addiw	a5,s2,-99
 5a8:	0ff7f793          	zext.b	a5,a5
 5ac:	12fb6863          	bltu	s6,a5,6dc <vprintf+0x194>
 5b0:	f9d9079b          	addiw	a5,s2,-99
 5b4:	0ff7f713          	zext.b	a4,a5
 5b8:	12eb6263          	bltu	s6,a4,6dc <vprintf+0x194>
 5bc:	00271793          	slli	a5,a4,0x2
 5c0:	00000717          	auipc	a4,0x0
 5c4:	39070713          	addi	a4,a4,912 # 950 <malloc+0x150>
 5c8:	97ba                	add	a5,a5,a4
 5ca:	439c                	lw	a5,0(a5)
 5cc:	97ba                	add	a5,a5,a4
 5ce:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5d0:	008b8913          	addi	s2,s7,8
 5d4:	4685                	li	a3,1
 5d6:	4629                	li	a2,10
 5d8:	000ba583          	lw	a1,0(s7)
 5dc:	8556                	mv	a0,s5
 5de:	00000097          	auipc	ra,0x0
 5e2:	ec2080e7          	jalr	-318(ra) # 4a0 <printint>
 5e6:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5e8:	4981                	li	s3,0
 5ea:	b745                	j	58a <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ec:	008b8913          	addi	s2,s7,8
 5f0:	4681                	li	a3,0
 5f2:	4629                	li	a2,10
 5f4:	000ba583          	lw	a1,0(s7)
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	ea6080e7          	jalr	-346(ra) # 4a0 <printint>
 602:	8bca                	mv	s7,s2
      state = 0;
 604:	4981                	li	s3,0
 606:	b751                	j	58a <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 608:	008b8913          	addi	s2,s7,8
 60c:	4681                	li	a3,0
 60e:	4641                	li	a2,16
 610:	000ba583          	lw	a1,0(s7)
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	e8a080e7          	jalr	-374(ra) # 4a0 <printint>
 61e:	8bca                	mv	s7,s2
      state = 0;
 620:	4981                	li	s3,0
 622:	b7a5                	j	58a <vprintf+0x42>
 624:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 626:	008b8793          	addi	a5,s7,8
 62a:	8c3e                	mv	s8,a5
 62c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 630:	03000593          	li	a1,48
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	e48080e7          	jalr	-440(ra) # 47e <putc>
  putc(fd, 'x');
 63e:	07800593          	li	a1,120
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	e3a080e7          	jalr	-454(ra) # 47e <putc>
 64c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 64e:	00000b97          	auipc	s7,0x0
 652:	35ab8b93          	addi	s7,s7,858 # 9a8 <digits>
 656:	03c9d793          	srli	a5,s3,0x3c
 65a:	97de                	add	a5,a5,s7
 65c:	0007c583          	lbu	a1,0(a5)
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	e1c080e7          	jalr	-484(ra) # 47e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 66a:	0992                	slli	s3,s3,0x4
 66c:	397d                	addiw	s2,s2,-1
 66e:	fe0914e3          	bnez	s2,656 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 672:	8be2                	mv	s7,s8
      state = 0;
 674:	4981                	li	s3,0
 676:	6c02                	ld	s8,0(sp)
 678:	bf09                	j	58a <vprintf+0x42>
        s = va_arg(ap, char*);
 67a:	008b8993          	addi	s3,s7,8
 67e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 682:	02090163          	beqz	s2,6a4 <vprintf+0x15c>
        while(*s != 0){
 686:	00094583          	lbu	a1,0(s2)
 68a:	c9a5                	beqz	a1,6fa <vprintf+0x1b2>
          putc(fd, *s);
 68c:	8556                	mv	a0,s5
 68e:	00000097          	auipc	ra,0x0
 692:	df0080e7          	jalr	-528(ra) # 47e <putc>
          s++;
 696:	0905                	addi	s2,s2,1
        while(*s != 0){
 698:	00094583          	lbu	a1,0(s2)
 69c:	f9e5                	bnez	a1,68c <vprintf+0x144>
        s = va_arg(ap, char*);
 69e:	8bce                	mv	s7,s3
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	b5e5                	j	58a <vprintf+0x42>
          s = "(null)";
 6a4:	00000917          	auipc	s2,0x0
 6a8:	2a490913          	addi	s2,s2,676 # 948 <malloc+0x148>
        while(*s != 0){
 6ac:	02800593          	li	a1,40
 6b0:	bff1                	j	68c <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 6b2:	008b8913          	addi	s2,s7,8
 6b6:	000bc583          	lbu	a1,0(s7)
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	dc2080e7          	jalr	-574(ra) # 47e <putc>
 6c4:	8bca                	mv	s7,s2
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	b5c9                	j	58a <vprintf+0x42>
        putc(fd, c);
 6ca:	02500593          	li	a1,37
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	dae080e7          	jalr	-594(ra) # 47e <putc>
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	bd45                	j	58a <vprintf+0x42>
        putc(fd, '%');
 6dc:	02500593          	li	a1,37
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	d9c080e7          	jalr	-612(ra) # 47e <putc>
        putc(fd, c);
 6ea:	85ca                	mv	a1,s2
 6ec:	8556                	mv	a0,s5
 6ee:	00000097          	auipc	ra,0x0
 6f2:	d90080e7          	jalr	-624(ra) # 47e <putc>
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bd49                	j	58a <vprintf+0x42>
        s = va_arg(ap, char*);
 6fa:	8bce                	mv	s7,s3
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	b571                	j	58a <vprintf+0x42>
 700:	74e2                	ld	s1,56(sp)
 702:	79a2                	ld	s3,40(sp)
 704:	7a02                	ld	s4,32(sp)
 706:	6ae2                	ld	s5,24(sp)
 708:	6b42                	ld	s6,16(sp)
 70a:	6ba2                	ld	s7,8(sp)
    }
  }
}
 70c:	60a6                	ld	ra,72(sp)
 70e:	6406                	ld	s0,64(sp)
 710:	7942                	ld	s2,48(sp)
 712:	6161                	addi	sp,sp,80
 714:	8082                	ret

0000000000000716 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 716:	715d                	addi	sp,sp,-80
 718:	ec06                	sd	ra,24(sp)
 71a:	e822                	sd	s0,16(sp)
 71c:	1000                	addi	s0,sp,32
 71e:	e010                	sd	a2,0(s0)
 720:	e414                	sd	a3,8(s0)
 722:	e818                	sd	a4,16(s0)
 724:	ec1c                	sd	a5,24(s0)
 726:	03043023          	sd	a6,32(s0)
 72a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 72e:	8622                	mv	a2,s0
 730:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 734:	00000097          	auipc	ra,0x0
 738:	e14080e7          	jalr	-492(ra) # 548 <vprintf>
}
 73c:	60e2                	ld	ra,24(sp)
 73e:	6442                	ld	s0,16(sp)
 740:	6161                	addi	sp,sp,80
 742:	8082                	ret

0000000000000744 <printf>:

void
printf(const char *fmt, ...)
{
 744:	711d                	addi	sp,sp,-96
 746:	ec06                	sd	ra,24(sp)
 748:	e822                	sd	s0,16(sp)
 74a:	1000                	addi	s0,sp,32
 74c:	e40c                	sd	a1,8(s0)
 74e:	e810                	sd	a2,16(s0)
 750:	ec14                	sd	a3,24(s0)
 752:	f018                	sd	a4,32(s0)
 754:	f41c                	sd	a5,40(s0)
 756:	03043823          	sd	a6,48(s0)
 75a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 75e:	00840613          	addi	a2,s0,8
 762:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 766:	85aa                	mv	a1,a0
 768:	4505                	li	a0,1
 76a:	00000097          	auipc	ra,0x0
 76e:	dde080e7          	jalr	-546(ra) # 548 <vprintf>
}
 772:	60e2                	ld	ra,24(sp)
 774:	6442                	ld	s0,16(sp)
 776:	6125                	addi	sp,sp,96
 778:	8082                	ret

000000000000077a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 77a:	1141                	addi	sp,sp,-16
 77c:	e406                	sd	ra,8(sp)
 77e:	e022                	sd	s0,0(sp)
 780:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 782:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 786:	00001797          	auipc	a5,0x1
 78a:	87a7b783          	ld	a5,-1926(a5) # 1000 <freep>
 78e:	a039                	j	79c <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 790:	6398                	ld	a4,0(a5)
 792:	00e7e463          	bltu	a5,a4,79a <free+0x20>
 796:	00e6ea63          	bltu	a3,a4,7aa <free+0x30>
{
 79a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79c:	fed7fae3          	bgeu	a5,a3,790 <free+0x16>
 7a0:	6398                	ld	a4,0(a5)
 7a2:	00e6e463          	bltu	a3,a4,7aa <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a6:	fee7eae3          	bltu	a5,a4,79a <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7aa:	ff852583          	lw	a1,-8(a0)
 7ae:	6390                	ld	a2,0(a5)
 7b0:	02059813          	slli	a6,a1,0x20
 7b4:	01c85713          	srli	a4,a6,0x1c
 7b8:	9736                	add	a4,a4,a3
 7ba:	02e60563          	beq	a2,a4,7e4 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7be:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7c2:	4790                	lw	a2,8(a5)
 7c4:	02061593          	slli	a1,a2,0x20
 7c8:	01c5d713          	srli	a4,a1,0x1c
 7cc:	973e                	add	a4,a4,a5
 7ce:	02e68263          	beq	a3,a4,7f2 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 7d2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7d4:	00001717          	auipc	a4,0x1
 7d8:	82f73623          	sd	a5,-2004(a4) # 1000 <freep>
}
 7dc:	60a2                	ld	ra,8(sp)
 7de:	6402                	ld	s0,0(sp)
 7e0:	0141                	addi	sp,sp,16
 7e2:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7e4:	4618                	lw	a4,8(a2)
 7e6:	9f2d                	addw	a4,a4,a1
 7e8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ec:	6398                	ld	a4,0(a5)
 7ee:	6310                	ld	a2,0(a4)
 7f0:	b7f9                	j	7be <free+0x44>
    p->s.size += bp->s.size;
 7f2:	ff852703          	lw	a4,-8(a0)
 7f6:	9f31                	addw	a4,a4,a2
 7f8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7fa:	ff053683          	ld	a3,-16(a0)
 7fe:	bfd1                	j	7d2 <free+0x58>

0000000000000800 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 800:	7139                	addi	sp,sp,-64
 802:	fc06                	sd	ra,56(sp)
 804:	f822                	sd	s0,48(sp)
 806:	f04a                	sd	s2,32(sp)
 808:	ec4e                	sd	s3,24(sp)
 80a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 80c:	02051993          	slli	s3,a0,0x20
 810:	0209d993          	srli	s3,s3,0x20
 814:	09bd                	addi	s3,s3,15
 816:	0049d993          	srli	s3,s3,0x4
 81a:	2985                	addiw	s3,s3,1
 81c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 81e:	00000517          	auipc	a0,0x0
 822:	7e253503          	ld	a0,2018(a0) # 1000 <freep>
 826:	c905                	beqz	a0,856 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 828:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 82a:	4798                	lw	a4,8(a5)
 82c:	09377a63          	bgeu	a4,s3,8c0 <malloc+0xc0>
 830:	f426                	sd	s1,40(sp)
 832:	e852                	sd	s4,16(sp)
 834:	e456                	sd	s5,8(sp)
 836:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 838:	8a4e                	mv	s4,s3
 83a:	6705                	lui	a4,0x1
 83c:	00e9f363          	bgeu	s3,a4,842 <malloc+0x42>
 840:	6a05                	lui	s4,0x1
 842:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 846:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 84a:	00000497          	auipc	s1,0x0
 84e:	7b648493          	addi	s1,s1,1974 # 1000 <freep>
  if(p == (char*)-1)
 852:	5afd                	li	s5,-1
 854:	a089                	j	896 <malloc+0x96>
 856:	f426                	sd	s1,40(sp)
 858:	e852                	sd	s4,16(sp)
 85a:	e456                	sd	s5,8(sp)
 85c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 85e:	00001797          	auipc	a5,0x1
 862:	9b278793          	addi	a5,a5,-1614 # 1210 <base>
 866:	00000717          	auipc	a4,0x0
 86a:	78f73d23          	sd	a5,1946(a4) # 1000 <freep>
 86e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 870:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 874:	b7d1                	j	838 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 876:	6398                	ld	a4,0(a5)
 878:	e118                	sd	a4,0(a0)
 87a:	a8b9                	j	8d8 <malloc+0xd8>
  hp->s.size = nu;
 87c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 880:	0541                	addi	a0,a0,16
 882:	00000097          	auipc	ra,0x0
 886:	ef8080e7          	jalr	-264(ra) # 77a <free>
  return freep;
 88a:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 88c:	c135                	beqz	a0,8f0 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 890:	4798                	lw	a4,8(a5)
 892:	03277363          	bgeu	a4,s2,8b8 <malloc+0xb8>
    if(p == freep)
 896:	6098                	ld	a4,0(s1)
 898:	853e                	mv	a0,a5
 89a:	fef71ae3          	bne	a4,a5,88e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 89e:	8552                	mv	a0,s4
 8a0:	00000097          	auipc	ra,0x0
 8a4:	bbe080e7          	jalr	-1090(ra) # 45e <sbrk>
  if(p == (char*)-1)
 8a8:	fd551ae3          	bne	a0,s5,87c <malloc+0x7c>
        return 0;
 8ac:	4501                	li	a0,0
 8ae:	74a2                	ld	s1,40(sp)
 8b0:	6a42                	ld	s4,16(sp)
 8b2:	6aa2                	ld	s5,8(sp)
 8b4:	6b02                	ld	s6,0(sp)
 8b6:	a03d                	j	8e4 <malloc+0xe4>
 8b8:	74a2                	ld	s1,40(sp)
 8ba:	6a42                	ld	s4,16(sp)
 8bc:	6aa2                	ld	s5,8(sp)
 8be:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8c0:	fae90be3          	beq	s2,a4,876 <malloc+0x76>
        p->s.size -= nunits;
 8c4:	4137073b          	subw	a4,a4,s3
 8c8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ca:	02071693          	slli	a3,a4,0x20
 8ce:	01c6d713          	srli	a4,a3,0x1c
 8d2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8d4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8d8:	00000717          	auipc	a4,0x0
 8dc:	72a73423          	sd	a0,1832(a4) # 1000 <freep>
      return (void*)(p + 1);
 8e0:	01078513          	addi	a0,a5,16
  }
}
 8e4:	70e2                	ld	ra,56(sp)
 8e6:	7442                	ld	s0,48(sp)
 8e8:	7902                	ld	s2,32(sp)
 8ea:	69e2                	ld	s3,24(sp)
 8ec:	6121                	addi	sp,sp,64
 8ee:	8082                	ret
 8f0:	74a2                	ld	s1,40(sp)
 8f2:	6a42                	ld	s4,16(sp)
 8f4:	6aa2                	ld	s5,8(sp)
 8f6:	6b02                	ld	s6,0(sp)
 8f8:	b7f5                	j	8e4 <malloc+0xe4>
