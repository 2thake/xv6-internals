
user/_circulate_byte:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <circulate>:
#define NUM_CHILDREN 2
#define NUM_PIPES (NUM_CHILDREN + 1)

// child process
void circulate(int (*p)[NUM_CHILDREN], int readpipe)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	0080                	addi	s0,sp,64
    char buf;                                 // create char to store piped char
    while (read(p[readpipe][0], &buf, 1) > 0) // read from "start" pipe
  10:	058e                	slli	a1,a1,0x3
  12:	00b50a33          	add	s4,a0,a1
        write(p[readpipe + 1][1], &buf, 1);   // write to "end" pipe
  16:	05a1                	addi	a1,a1,8
  18:	00b509b3          	add	s3,a0,a1
    while (read(p[readpipe][0], &buf, 1) > 0) // read from "start" pipe
  1c:	fcf40913          	addi	s2,s0,-49
  20:	4485                	li	s1,1
  22:	a809                	j	34 <circulate+0x34>
        write(p[readpipe + 1][1], &buf, 1);   // write to "end" pipe
  24:	8626                	mv	a2,s1
  26:	85ca                	mv	a1,s2
  28:	0049a503          	lw	a0,4(s3)
  2c:	00000097          	auipc	ra,0x0
  30:	41a080e7          	jalr	1050(ra) # 446 <write>
    while (read(p[readpipe][0], &buf, 1) > 0) // read from "start" pipe
  34:	8626                	mv	a2,s1
  36:	85ca                	mv	a1,s2
  38:	000a2503          	lw	a0,0(s4)
  3c:	00000097          	auipc	ra,0x0
  40:	402080e7          	jalr	1026(ra) # 43e <read>
  44:	fea040e3          	bgtz	a0,24 <circulate+0x24>
}
  48:	70e2                	ld	ra,56(sp)
  4a:	7442                	ld	s0,48(sp)
  4c:	74a2                	ld	s1,40(sp)
  4e:	7902                	ld	s2,32(sp)
  50:	69e2                	ld	s3,24(sp)
  52:	6a42                	ld	s4,16(sp)
  54:	6121                	addi	sp,sp,64
  56:	8082                	ret

0000000000000058 <main>:

int main()
{
  58:	711d                	addi	sp,sp,-96
  5a:	ec86                	sd	ra,88(sp)
  5c:	e8a2                	sd	s0,80(sp)
  5e:	f852                	sd	s4,48(sp)
  60:	f456                	sd	s5,40(sp)
  62:	1080                	addi	s0,sp,96
    int p[NUM_PIPES][2]; // create array to store pipes
    for (int i = 0; i < NUM_PIPES; i++)
        pipe(p[i]); // loop through array and create pipes
  64:	fa840513          	addi	a0,s0,-88
  68:	00000097          	auipc	ra,0x0
  6c:	3ce080e7          	jalr	974(ra) # 436 <pipe>
  70:	fb040513          	addi	a0,s0,-80
  74:	00000097          	auipc	ra,0x0
  78:	3c2080e7          	jalr	962(ra) # 436 <pipe>
  7c:	fb840513          	addi	a0,s0,-72
  80:	00000097          	auipc	ra,0x0
  84:	3b6080e7          	jalr	950(ra) # 436 <pipe>

    int pids[NUM_CHILDREN];                // create array to store PIDs
    for (int i = 0; i < NUM_CHILDREN; i++) // repeat for all children
        if ((pids[i] = fork()) == 0)
  88:	00000097          	auipc	ra,0x0
  8c:	396080e7          	jalr	918(ra) # 41e <fork>
  90:	8a2a                	mv	s4,a0
  92:	c579                	beqz	a0,160 <main+0x108>
  94:	00000097          	auipc	ra,0x0
  98:	38a080e7          	jalr	906(ra) # 41e <fork>
  9c:	8aaa                	mv	s5,a0
  9e:	c161                	beqz	a0,15e <main+0x106>
  a0:	e4a6                	sd	s1,72(sp)
  a2:	e0ca                	sd	s2,64(sp)
  a4:	fc4e                	sd	s3,56(sp)
            circulate(p, i); // call child function
            exit(0);         // kill child
        }

    // Parent process
    char buf = 'A';
  a6:	04100793          	li	a5,65
  aa:	faf403a3          	sb	a5,-89(s0)
    printf("Parent sending: %c\n", buf); // print opening message
  ae:	85be                	mv	a1,a5
  b0:	00001517          	auipc	a0,0x1
  b4:	8a050513          	addi	a0,a0,-1888 # 950 <malloc+0x100>
  b8:	00000097          	auipc	ra,0x0
  bc:	6dc080e7          	jalr	1756(ra) # 794 <printf>

    write(p[0][1], &buf, 1); // Write to first pipe to begin
  c0:	4605                	li	a2,1
  c2:	fa740593          	addi	a1,s0,-89
  c6:	fac42503          	lw	a0,-84(s0)
  ca:	00000097          	auipc	ra,0x0
  ce:	37c080e7          	jalr	892(ra) # 446 <write>
  d2:	6489                	lui	s1,0x2
  d4:	71048493          	addi	s1,s1,1808 # 2710 <base+0x1700>
    for (int i = 1; i <= NUM_LOOPS && read(p[NUM_CHILDREN][0], &buf, 1); i++)
  d8:	fa740993          	addi	s3,s0,-89
  dc:	4905                	li	s2,1
  de:	864a                	mv	a2,s2
  e0:	85ce                	mv	a1,s3
  e2:	fb842503          	lw	a0,-72(s0)
  e6:	00000097          	auipc	ra,0x0
  ea:	358080e7          	jalr	856(ra) # 43e <read>
  ee:	c919                	beqz	a0,104 <main+0xac>
    {                            // Read from third pipe
        write(p[0][1], &buf, 1); // Write to first pipe
  f0:	864a                	mv	a2,s2
  f2:	85ce                	mv	a1,s3
  f4:	fac42503          	lw	a0,-84(s0)
  f8:	00000097          	auipc	ra,0x0
  fc:	34e080e7          	jalr	846(ra) # 446 <write>
    for (int i = 1; i <= NUM_LOOPS && read(p[NUM_CHILDREN][0], &buf, 1); i++)
 100:	34fd                	addiw	s1,s1,-1
 102:	fcf1                	bnez	s1,de <main+0x86>
    }
    printf("Parent received %c in %d loops\n", buf, NUM_LOOPS);
 104:	6609                	lui	a2,0x2
 106:	71060613          	addi	a2,a2,1808 # 2710 <base+0x1700>
 10a:	fa744583          	lbu	a1,-89(s0)
 10e:	00001517          	auipc	a0,0x1
 112:	85a50513          	addi	a0,a0,-1958 # 968 <malloc+0x118>
 116:	00000097          	auipc	ra,0x0
 11a:	67e080e7          	jalr	1662(ra) # 794 <printf>

    for (int i = 0; i < NUM_PIPES; i++)
 11e:	fa840493          	addi	s1,s0,-88
 122:	fc040913          	addi	s2,s0,-64
    {                   // loop through each pipe
        close(p[i][0]); // close read end
 126:	4088                	lw	a0,0(s1)
 128:	00000097          	auipc	ra,0x0
 12c:	326080e7          	jalr	806(ra) # 44e <close>
        close(p[i][1]); // close write end
 130:	40c8                	lw	a0,4(s1)
 132:	00000097          	auipc	ra,0x0
 136:	31c080e7          	jalr	796(ra) # 44e <close>
    for (int i = 0; i < NUM_PIPES; i++)
 13a:	04a1                	addi	s1,s1,8
 13c:	ff2495e3          	bne	s1,s2,126 <main+0xce>
    }

    // Clean up and exit
    for (int i = 0; i < NUM_CHILDREN; i++) // loop through each child pid
        kill(pids[i]);                     // kill each child
 140:	8552                	mv	a0,s4
 142:	00000097          	auipc	ra,0x0
 146:	314080e7          	jalr	788(ra) # 456 <kill>
 14a:	8556                	mv	a0,s5
 14c:	00000097          	auipc	ra,0x0
 150:	30a080e7          	jalr	778(ra) # 456 <kill>

    exit(0);
 154:	4501                	li	a0,0
 156:	00000097          	auipc	ra,0x0
 15a:	2d0080e7          	jalr	720(ra) # 426 <exit>
 15e:	4a05                	li	s4,1
 160:	e4a6                	sd	s1,72(sp)
 162:	e0ca                	sd	s2,64(sp)
 164:	fc4e                	sd	s3,56(sp)
            circulate(p, i); // call child function
 166:	85d2                	mv	a1,s4
 168:	fa840513          	addi	a0,s0,-88
 16c:	00000097          	auipc	ra,0x0
 170:	e94080e7          	jalr	-364(ra) # 0 <circulate>
            exit(0);         // kill child
 174:	4501                	li	a0,0
 176:	00000097          	auipc	ra,0x0
 17a:	2b0080e7          	jalr	688(ra) # 426 <exit>

000000000000017e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 17e:	1141                	addi	sp,sp,-16
 180:	e406                	sd	ra,8(sp)
 182:	e022                	sd	s0,0(sp)
 184:	0800                	addi	s0,sp,16
  extern int main();
  main();
 186:	00000097          	auipc	ra,0x0
 18a:	ed2080e7          	jalr	-302(ra) # 58 <main>
  exit(0);
 18e:	4501                	li	a0,0
 190:	00000097          	auipc	ra,0x0
 194:	296080e7          	jalr	662(ra) # 426 <exit>

0000000000000198 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e406                	sd	ra,8(sp)
 19c:	e022                	sd	s0,0(sp)
 19e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1a0:	87aa                	mv	a5,a0
 1a2:	0585                	addi	a1,a1,1
 1a4:	0785                	addi	a5,a5,1
 1a6:	fff5c703          	lbu	a4,-1(a1)
 1aa:	fee78fa3          	sb	a4,-1(a5)
 1ae:	fb75                	bnez	a4,1a2 <strcpy+0xa>
    ;
  return os;
}
 1b0:	60a2                	ld	ra,8(sp)
 1b2:	6402                	ld	s0,0(sp)
 1b4:	0141                	addi	sp,sp,16
 1b6:	8082                	ret

00000000000001b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b8:	1141                	addi	sp,sp,-16
 1ba:	e406                	sd	ra,8(sp)
 1bc:	e022                	sd	s0,0(sp)
 1be:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	cb91                	beqz	a5,1d8 <strcmp+0x20>
 1c6:	0005c703          	lbu	a4,0(a1)
 1ca:	00f71763          	bne	a4,a5,1d8 <strcmp+0x20>
    p++, q++;
 1ce:	0505                	addi	a0,a0,1
 1d0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	fbe5                	bnez	a5,1c6 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 1d8:	0005c503          	lbu	a0,0(a1)
}
 1dc:	40a7853b          	subw	a0,a5,a0
 1e0:	60a2                	ld	ra,8(sp)
 1e2:	6402                	ld	s0,0(sp)
 1e4:	0141                	addi	sp,sp,16
 1e6:	8082                	ret

00000000000001e8 <strlen>:

uint
strlen(const char *s)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e406                	sd	ra,8(sp)
 1ec:	e022                	sd	s0,0(sp)
 1ee:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1f0:	00054783          	lbu	a5,0(a0)
 1f4:	cf91                	beqz	a5,210 <strlen+0x28>
 1f6:	00150793          	addi	a5,a0,1
 1fa:	86be                	mv	a3,a5
 1fc:	0785                	addi	a5,a5,1
 1fe:	fff7c703          	lbu	a4,-1(a5)
 202:	ff65                	bnez	a4,1fa <strlen+0x12>
 204:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 208:	60a2                	ld	ra,8(sp)
 20a:	6402                	ld	s0,0(sp)
 20c:	0141                	addi	sp,sp,16
 20e:	8082                	ret
  for(n = 0; s[n]; n++)
 210:	4501                	li	a0,0
 212:	bfdd                	j	208 <strlen+0x20>

0000000000000214 <memset>:

void*
memset(void *dst, int c, uint n)
{
 214:	1141                	addi	sp,sp,-16
 216:	e406                	sd	ra,8(sp)
 218:	e022                	sd	s0,0(sp)
 21a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 21c:	ca19                	beqz	a2,232 <memset+0x1e>
 21e:	87aa                	mv	a5,a0
 220:	1602                	slli	a2,a2,0x20
 222:	9201                	srli	a2,a2,0x20
 224:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 228:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 22c:	0785                	addi	a5,a5,1
 22e:	fee79de3          	bne	a5,a4,228 <memset+0x14>
  }
  return dst;
}
 232:	60a2                	ld	ra,8(sp)
 234:	6402                	ld	s0,0(sp)
 236:	0141                	addi	sp,sp,16
 238:	8082                	ret

000000000000023a <strchr>:

char*
strchr(const char *s, char c)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e406                	sd	ra,8(sp)
 23e:	e022                	sd	s0,0(sp)
 240:	0800                	addi	s0,sp,16
  for(; *s; s++)
 242:	00054783          	lbu	a5,0(a0)
 246:	cf81                	beqz	a5,25e <strchr+0x24>
    if(*s == c)
 248:	00f58763          	beq	a1,a5,256 <strchr+0x1c>
  for(; *s; s++)
 24c:	0505                	addi	a0,a0,1
 24e:	00054783          	lbu	a5,0(a0)
 252:	fbfd                	bnez	a5,248 <strchr+0xe>
      return (char*)s;
  return 0;
 254:	4501                	li	a0,0
}
 256:	60a2                	ld	ra,8(sp)
 258:	6402                	ld	s0,0(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
  return 0;
 25e:	4501                	li	a0,0
 260:	bfdd                	j	256 <strchr+0x1c>

0000000000000262 <gets>:

char*
gets(char *buf, int max)
{
 262:	711d                	addi	sp,sp,-96
 264:	ec86                	sd	ra,88(sp)
 266:	e8a2                	sd	s0,80(sp)
 268:	e4a6                	sd	s1,72(sp)
 26a:	e0ca                	sd	s2,64(sp)
 26c:	fc4e                	sd	s3,56(sp)
 26e:	f852                	sd	s4,48(sp)
 270:	f456                	sd	s5,40(sp)
 272:	f05a                	sd	s6,32(sp)
 274:	ec5e                	sd	s7,24(sp)
 276:	e862                	sd	s8,16(sp)
 278:	1080                	addi	s0,sp,96
 27a:	8baa                	mv	s7,a0
 27c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27e:	892a                	mv	s2,a0
 280:	4481                	li	s1,0
    cc = read(0, &c, 1);
 282:	faf40b13          	addi	s6,s0,-81
 286:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 288:	8c26                	mv	s8,s1
 28a:	0014899b          	addiw	s3,s1,1
 28e:	84ce                	mv	s1,s3
 290:	0349d663          	bge	s3,s4,2bc <gets+0x5a>
    cc = read(0, &c, 1);
 294:	8656                	mv	a2,s5
 296:	85da                	mv	a1,s6
 298:	4501                	li	a0,0
 29a:	00000097          	auipc	ra,0x0
 29e:	1a4080e7          	jalr	420(ra) # 43e <read>
    if(cc < 1)
 2a2:	00a05d63          	blez	a0,2bc <gets+0x5a>
      break;
    buf[i++] = c;
 2a6:	faf44783          	lbu	a5,-81(s0)
 2aa:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ae:	0905                	addi	s2,s2,1
 2b0:	ff678713          	addi	a4,a5,-10
 2b4:	c319                	beqz	a4,2ba <gets+0x58>
 2b6:	17cd                	addi	a5,a5,-13
 2b8:	fbe1                	bnez	a5,288 <gets+0x26>
    buf[i++] = c;
 2ba:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 2bc:	9c5e                	add	s8,s8,s7
 2be:	000c0023          	sb	zero,0(s8)
  return buf;
}
 2c2:	855e                	mv	a0,s7
 2c4:	60e6                	ld	ra,88(sp)
 2c6:	6446                	ld	s0,80(sp)
 2c8:	64a6                	ld	s1,72(sp)
 2ca:	6906                	ld	s2,64(sp)
 2cc:	79e2                	ld	s3,56(sp)
 2ce:	7a42                	ld	s4,48(sp)
 2d0:	7aa2                	ld	s5,40(sp)
 2d2:	7b02                	ld	s6,32(sp)
 2d4:	6be2                	ld	s7,24(sp)
 2d6:	6c42                	ld	s8,16(sp)
 2d8:	6125                	addi	sp,sp,96
 2da:	8082                	ret

00000000000002dc <stat>:

int
stat(const char *n, struct stat *st)
{
 2dc:	1101                	addi	sp,sp,-32
 2de:	ec06                	sd	ra,24(sp)
 2e0:	e822                	sd	s0,16(sp)
 2e2:	e04a                	sd	s2,0(sp)
 2e4:	1000                	addi	s0,sp,32
 2e6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2e8:	4581                	li	a1,0
 2ea:	00000097          	auipc	ra,0x0
 2ee:	17c080e7          	jalr	380(ra) # 466 <open>
  if(fd < 0)
 2f2:	02054663          	bltz	a0,31e <stat+0x42>
 2f6:	e426                	sd	s1,8(sp)
 2f8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2fa:	85ca                	mv	a1,s2
 2fc:	00000097          	auipc	ra,0x0
 300:	182080e7          	jalr	386(ra) # 47e <fstat>
 304:	892a                	mv	s2,a0
  close(fd);
 306:	8526                	mv	a0,s1
 308:	00000097          	auipc	ra,0x0
 30c:	146080e7          	jalr	326(ra) # 44e <close>
  return r;
 310:	64a2                	ld	s1,8(sp)
}
 312:	854a                	mv	a0,s2
 314:	60e2                	ld	ra,24(sp)
 316:	6442                	ld	s0,16(sp)
 318:	6902                	ld	s2,0(sp)
 31a:	6105                	addi	sp,sp,32
 31c:	8082                	ret
    return -1;
 31e:	57fd                	li	a5,-1
 320:	893e                	mv	s2,a5
 322:	bfc5                	j	312 <stat+0x36>

0000000000000324 <atoi>:

int
atoi(const char *s)
{
 324:	1141                	addi	sp,sp,-16
 326:	e406                	sd	ra,8(sp)
 328:	e022                	sd	s0,0(sp)
 32a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 32c:	00054683          	lbu	a3,0(a0)
 330:	fd06879b          	addiw	a5,a3,-48
 334:	0ff7f793          	zext.b	a5,a5
 338:	4625                	li	a2,9
 33a:	02f66963          	bltu	a2,a5,36c <atoi+0x48>
 33e:	872a                	mv	a4,a0
  n = 0;
 340:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 342:	0705                	addi	a4,a4,1
 344:	0025179b          	slliw	a5,a0,0x2
 348:	9fa9                	addw	a5,a5,a0
 34a:	0017979b          	slliw	a5,a5,0x1
 34e:	9fb5                	addw	a5,a5,a3
 350:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 354:	00074683          	lbu	a3,0(a4)
 358:	fd06879b          	addiw	a5,a3,-48
 35c:	0ff7f793          	zext.b	a5,a5
 360:	fef671e3          	bgeu	a2,a5,342 <atoi+0x1e>
  return n;
}
 364:	60a2                	ld	ra,8(sp)
 366:	6402                	ld	s0,0(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret
  n = 0;
 36c:	4501                	li	a0,0
 36e:	bfdd                	j	364 <atoi+0x40>

0000000000000370 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 370:	1141                	addi	sp,sp,-16
 372:	e406                	sd	ra,8(sp)
 374:	e022                	sd	s0,0(sp)
 376:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 378:	02b57563          	bgeu	a0,a1,3a2 <memmove+0x32>
    while(n-- > 0)
 37c:	00c05f63          	blez	a2,39a <memmove+0x2a>
 380:	1602                	slli	a2,a2,0x20
 382:	9201                	srli	a2,a2,0x20
 384:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 388:	872a                	mv	a4,a0
      *dst++ = *src++;
 38a:	0585                	addi	a1,a1,1
 38c:	0705                	addi	a4,a4,1
 38e:	fff5c683          	lbu	a3,-1(a1)
 392:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 396:	fee79ae3          	bne	a5,a4,38a <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 39a:	60a2                	ld	ra,8(sp)
 39c:	6402                	ld	s0,0(sp)
 39e:	0141                	addi	sp,sp,16
 3a0:	8082                	ret
    while(n-- > 0)
 3a2:	fec05ce3          	blez	a2,39a <memmove+0x2a>
    dst += n;
 3a6:	00c50733          	add	a4,a0,a2
    src += n;
 3aa:	95b2                	add	a1,a1,a2
 3ac:	fff6079b          	addiw	a5,a2,-1
 3b0:	1782                	slli	a5,a5,0x20
 3b2:	9381                	srli	a5,a5,0x20
 3b4:	fff7c793          	not	a5,a5
 3b8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3ba:	15fd                	addi	a1,a1,-1
 3bc:	177d                	addi	a4,a4,-1
 3be:	0005c683          	lbu	a3,0(a1)
 3c2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3c6:	fef71ae3          	bne	a4,a5,3ba <memmove+0x4a>
 3ca:	bfc1                	j	39a <memmove+0x2a>

00000000000003cc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3cc:	1141                	addi	sp,sp,-16
 3ce:	e406                	sd	ra,8(sp)
 3d0:	e022                	sd	s0,0(sp)
 3d2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3d4:	c61d                	beqz	a2,402 <memcmp+0x36>
 3d6:	1602                	slli	a2,a2,0x20
 3d8:	9201                	srli	a2,a2,0x20
 3da:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 3de:	00054783          	lbu	a5,0(a0)
 3e2:	0005c703          	lbu	a4,0(a1)
 3e6:	00e79863          	bne	a5,a4,3f6 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 3ea:	0505                	addi	a0,a0,1
    p2++;
 3ec:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3ee:	fed518e3          	bne	a0,a3,3de <memcmp+0x12>
  }
  return 0;
 3f2:	4501                	li	a0,0
 3f4:	a019                	j	3fa <memcmp+0x2e>
      return *p1 - *p2;
 3f6:	40e7853b          	subw	a0,a5,a4
}
 3fa:	60a2                	ld	ra,8(sp)
 3fc:	6402                	ld	s0,0(sp)
 3fe:	0141                	addi	sp,sp,16
 400:	8082                	ret
  return 0;
 402:	4501                	li	a0,0
 404:	bfdd                	j	3fa <memcmp+0x2e>

0000000000000406 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 406:	1141                	addi	sp,sp,-16
 408:	e406                	sd	ra,8(sp)
 40a:	e022                	sd	s0,0(sp)
 40c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 40e:	00000097          	auipc	ra,0x0
 412:	f62080e7          	jalr	-158(ra) # 370 <memmove>
}
 416:	60a2                	ld	ra,8(sp)
 418:	6402                	ld	s0,0(sp)
 41a:	0141                	addi	sp,sp,16
 41c:	8082                	ret

000000000000041e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 41e:	4885                	li	a7,1
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <exit>:
.global exit
exit:
 li a7, SYS_exit
 426:	4889                	li	a7,2
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <wait>:
.global wait
wait:
 li a7, SYS_wait
 42e:	488d                	li	a7,3
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 436:	4891                	li	a7,4
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <read>:
.global read
read:
 li a7, SYS_read
 43e:	4895                	li	a7,5
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <write>:
.global write
write:
 li a7, SYS_write
 446:	48c1                	li	a7,16
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <close>:
.global close
close:
 li a7, SYS_close
 44e:	48d5                	li	a7,21
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <kill>:
.global kill
kill:
 li a7, SYS_kill
 456:	4899                	li	a7,6
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <exec>:
.global exec
exec:
 li a7, SYS_exec
 45e:	489d                	li	a7,7
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <open>:
.global open
open:
 li a7, SYS_open
 466:	48bd                	li	a7,15
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 46e:	48c5                	li	a7,17
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 476:	48c9                	li	a7,18
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 47e:	48a1                	li	a7,8
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <link>:
.global link
link:
 li a7, SYS_link
 486:	48cd                	li	a7,19
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 48e:	48d1                	li	a7,20
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 496:	48a5                	li	a7,9
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <dup>:
.global dup
dup:
 li a7, SYS_dup
 49e:	48a9                	li	a7,10
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4a6:	48ad                	li	a7,11
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ae:	48b1                	li	a7,12
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4b6:	48b5                	li	a7,13
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4be:	48b9                	li	a7,14
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <nanotime>:
.global nanotime
nanotime:
 li a7, SYS_nanotime
 4c6:	48d9                	li	a7,22
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ce:	1101                	addi	sp,sp,-32
 4d0:	ec06                	sd	ra,24(sp)
 4d2:	e822                	sd	s0,16(sp)
 4d4:	1000                	addi	s0,sp,32
 4d6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4da:	4605                	li	a2,1
 4dc:	fef40593          	addi	a1,s0,-17
 4e0:	00000097          	auipc	ra,0x0
 4e4:	f66080e7          	jalr	-154(ra) # 446 <write>
}
 4e8:	60e2                	ld	ra,24(sp)
 4ea:	6442                	ld	s0,16(sp)
 4ec:	6105                	addi	sp,sp,32
 4ee:	8082                	ret

00000000000004f0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f0:	7139                	addi	sp,sp,-64
 4f2:	fc06                	sd	ra,56(sp)
 4f4:	f822                	sd	s0,48(sp)
 4f6:	f04a                	sd	s2,32(sp)
 4f8:	ec4e                	sd	s3,24(sp)
 4fa:	0080                	addi	s0,sp,64
 4fc:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4fe:	cad9                	beqz	a3,594 <printint+0xa4>
 500:	01f5d79b          	srliw	a5,a1,0x1f
 504:	cbc1                	beqz	a5,594 <printint+0xa4>
    neg = 1;
    x = -xx;
 506:	40b005bb          	negw	a1,a1
    neg = 1;
 50a:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 50c:	fc040993          	addi	s3,s0,-64
  neg = 0;
 510:	86ce                	mv	a3,s3
  i = 0;
 512:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 514:	00000817          	auipc	a6,0x0
 518:	4d480813          	addi	a6,a6,1236 # 9e8 <digits>
 51c:	88ba                	mv	a7,a4
 51e:	0017051b          	addiw	a0,a4,1
 522:	872a                	mv	a4,a0
 524:	02c5f7bb          	remuw	a5,a1,a2
 528:	1782                	slli	a5,a5,0x20
 52a:	9381                	srli	a5,a5,0x20
 52c:	97c2                	add	a5,a5,a6
 52e:	0007c783          	lbu	a5,0(a5)
 532:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 536:	87ae                	mv	a5,a1
 538:	02c5d5bb          	divuw	a1,a1,a2
 53c:	0685                	addi	a3,a3,1
 53e:	fcc7ffe3          	bgeu	a5,a2,51c <printint+0x2c>
  if(neg)
 542:	00030c63          	beqz	t1,55a <printint+0x6a>
    buf[i++] = '-';
 546:	fd050793          	addi	a5,a0,-48
 54a:	00878533          	add	a0,a5,s0
 54e:	02d00793          	li	a5,45
 552:	fef50823          	sb	a5,-16(a0)
 556:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 55a:	02e05763          	blez	a4,588 <printint+0x98>
 55e:	f426                	sd	s1,40(sp)
 560:	377d                	addiw	a4,a4,-1
 562:	00e984b3          	add	s1,s3,a4
 566:	19fd                	addi	s3,s3,-1
 568:	99ba                	add	s3,s3,a4
 56a:	1702                	slli	a4,a4,0x20
 56c:	9301                	srli	a4,a4,0x20
 56e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 572:	0004c583          	lbu	a1,0(s1)
 576:	854a                	mv	a0,s2
 578:	00000097          	auipc	ra,0x0
 57c:	f56080e7          	jalr	-170(ra) # 4ce <putc>
  while(--i >= 0)
 580:	14fd                	addi	s1,s1,-1
 582:	ff3498e3          	bne	s1,s3,572 <printint+0x82>
 586:	74a2                	ld	s1,40(sp)
}
 588:	70e2                	ld	ra,56(sp)
 58a:	7442                	ld	s0,48(sp)
 58c:	7902                	ld	s2,32(sp)
 58e:	69e2                	ld	s3,24(sp)
 590:	6121                	addi	sp,sp,64
 592:	8082                	ret
  neg = 0;
 594:	4301                	li	t1,0
 596:	bf9d                	j	50c <printint+0x1c>

0000000000000598 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 598:	715d                	addi	sp,sp,-80
 59a:	e486                	sd	ra,72(sp)
 59c:	e0a2                	sd	s0,64(sp)
 59e:	f84a                	sd	s2,48(sp)
 5a0:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5a2:	0005c903          	lbu	s2,0(a1)
 5a6:	1a090b63          	beqz	s2,75c <vprintf+0x1c4>
 5aa:	fc26                	sd	s1,56(sp)
 5ac:	f44e                	sd	s3,40(sp)
 5ae:	f052                	sd	s4,32(sp)
 5b0:	ec56                	sd	s5,24(sp)
 5b2:	e85a                	sd	s6,16(sp)
 5b4:	e45e                	sd	s7,8(sp)
 5b6:	8aaa                	mv	s5,a0
 5b8:	8bb2                	mv	s7,a2
 5ba:	00158493          	addi	s1,a1,1
  state = 0;
 5be:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5c0:	02500a13          	li	s4,37
 5c4:	4b55                	li	s6,21
 5c6:	a839                	j	5e4 <vprintf+0x4c>
        putc(fd, c);
 5c8:	85ca                	mv	a1,s2
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	f02080e7          	jalr	-254(ra) # 4ce <putc>
 5d4:	a019                	j	5da <vprintf+0x42>
    } else if(state == '%'){
 5d6:	01498d63          	beq	s3,s4,5f0 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 5da:	0485                	addi	s1,s1,1
 5dc:	fff4c903          	lbu	s2,-1(s1)
 5e0:	16090863          	beqz	s2,750 <vprintf+0x1b8>
    if(state == 0){
 5e4:	fe0999e3          	bnez	s3,5d6 <vprintf+0x3e>
      if(c == '%'){
 5e8:	ff4910e3          	bne	s2,s4,5c8 <vprintf+0x30>
        state = '%';
 5ec:	89d2                	mv	s3,s4
 5ee:	b7f5                	j	5da <vprintf+0x42>
      if(c == 'd'){
 5f0:	13490563          	beq	s2,s4,71a <vprintf+0x182>
 5f4:	f9d9079b          	addiw	a5,s2,-99
 5f8:	0ff7f793          	zext.b	a5,a5
 5fc:	12fb6863          	bltu	s6,a5,72c <vprintf+0x194>
 600:	f9d9079b          	addiw	a5,s2,-99
 604:	0ff7f713          	zext.b	a4,a5
 608:	12eb6263          	bltu	s6,a4,72c <vprintf+0x194>
 60c:	00271793          	slli	a5,a4,0x2
 610:	00000717          	auipc	a4,0x0
 614:	38070713          	addi	a4,a4,896 # 990 <malloc+0x140>
 618:	97ba                	add	a5,a5,a4
 61a:	439c                	lw	a5,0(a5)
 61c:	97ba                	add	a5,a5,a4
 61e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 620:	008b8913          	addi	s2,s7,8
 624:	4685                	li	a3,1
 626:	4629                	li	a2,10
 628:	000ba583          	lw	a1,0(s7)
 62c:	8556                	mv	a0,s5
 62e:	00000097          	auipc	ra,0x0
 632:	ec2080e7          	jalr	-318(ra) # 4f0 <printint>
 636:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 638:	4981                	li	s3,0
 63a:	b745                	j	5da <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 63c:	008b8913          	addi	s2,s7,8
 640:	4681                	li	a3,0
 642:	4629                	li	a2,10
 644:	000ba583          	lw	a1,0(s7)
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	ea6080e7          	jalr	-346(ra) # 4f0 <printint>
 652:	8bca                	mv	s7,s2
      state = 0;
 654:	4981                	li	s3,0
 656:	b751                	j	5da <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 658:	008b8913          	addi	s2,s7,8
 65c:	4681                	li	a3,0
 65e:	4641                	li	a2,16
 660:	000ba583          	lw	a1,0(s7)
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	e8a080e7          	jalr	-374(ra) # 4f0 <printint>
 66e:	8bca                	mv	s7,s2
      state = 0;
 670:	4981                	li	s3,0
 672:	b7a5                	j	5da <vprintf+0x42>
 674:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 676:	008b8793          	addi	a5,s7,8
 67a:	8c3e                	mv	s8,a5
 67c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 680:	03000593          	li	a1,48
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	e48080e7          	jalr	-440(ra) # 4ce <putc>
  putc(fd, 'x');
 68e:	07800593          	li	a1,120
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	e3a080e7          	jalr	-454(ra) # 4ce <putc>
 69c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 69e:	00000b97          	auipc	s7,0x0
 6a2:	34ab8b93          	addi	s7,s7,842 # 9e8 <digits>
 6a6:	03c9d793          	srli	a5,s3,0x3c
 6aa:	97de                	add	a5,a5,s7
 6ac:	0007c583          	lbu	a1,0(a5)
 6b0:	8556                	mv	a0,s5
 6b2:	00000097          	auipc	ra,0x0
 6b6:	e1c080e7          	jalr	-484(ra) # 4ce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ba:	0992                	slli	s3,s3,0x4
 6bc:	397d                	addiw	s2,s2,-1
 6be:	fe0914e3          	bnez	s2,6a6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
 6c2:	8be2                	mv	s7,s8
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	6c02                	ld	s8,0(sp)
 6c8:	bf09                	j	5da <vprintf+0x42>
        s = va_arg(ap, char*);
 6ca:	008b8993          	addi	s3,s7,8
 6ce:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6d2:	02090163          	beqz	s2,6f4 <vprintf+0x15c>
        while(*s != 0){
 6d6:	00094583          	lbu	a1,0(s2)
 6da:	c9a5                	beqz	a1,74a <vprintf+0x1b2>
          putc(fd, *s);
 6dc:	8556                	mv	a0,s5
 6de:	00000097          	auipc	ra,0x0
 6e2:	df0080e7          	jalr	-528(ra) # 4ce <putc>
          s++;
 6e6:	0905                	addi	s2,s2,1
        while(*s != 0){
 6e8:	00094583          	lbu	a1,0(s2)
 6ec:	f9e5                	bnez	a1,6dc <vprintf+0x144>
        s = va_arg(ap, char*);
 6ee:	8bce                	mv	s7,s3
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	b5e5                	j	5da <vprintf+0x42>
          s = "(null)";
 6f4:	00000917          	auipc	s2,0x0
 6f8:	29490913          	addi	s2,s2,660 # 988 <malloc+0x138>
        while(*s != 0){
 6fc:	02800593          	li	a1,40
 700:	bff1                	j	6dc <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
 702:	008b8913          	addi	s2,s7,8
 706:	000bc583          	lbu	a1,0(s7)
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	dc2080e7          	jalr	-574(ra) # 4ce <putc>
 714:	8bca                	mv	s7,s2
      state = 0;
 716:	4981                	li	s3,0
 718:	b5c9                	j	5da <vprintf+0x42>
        putc(fd, c);
 71a:	02500593          	li	a1,37
 71e:	8556                	mv	a0,s5
 720:	00000097          	auipc	ra,0x0
 724:	dae080e7          	jalr	-594(ra) # 4ce <putc>
      state = 0;
 728:	4981                	li	s3,0
 72a:	bd45                	j	5da <vprintf+0x42>
        putc(fd, '%');
 72c:	02500593          	li	a1,37
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	d9c080e7          	jalr	-612(ra) # 4ce <putc>
        putc(fd, c);
 73a:	85ca                	mv	a1,s2
 73c:	8556                	mv	a0,s5
 73e:	00000097          	auipc	ra,0x0
 742:	d90080e7          	jalr	-624(ra) # 4ce <putc>
      state = 0;
 746:	4981                	li	s3,0
 748:	bd49                	j	5da <vprintf+0x42>
        s = va_arg(ap, char*);
 74a:	8bce                	mv	s7,s3
      state = 0;
 74c:	4981                	li	s3,0
 74e:	b571                	j	5da <vprintf+0x42>
 750:	74e2                	ld	s1,56(sp)
 752:	79a2                	ld	s3,40(sp)
 754:	7a02                	ld	s4,32(sp)
 756:	6ae2                	ld	s5,24(sp)
 758:	6b42                	ld	s6,16(sp)
 75a:	6ba2                	ld	s7,8(sp)
    }
  }
}
 75c:	60a6                	ld	ra,72(sp)
 75e:	6406                	ld	s0,64(sp)
 760:	7942                	ld	s2,48(sp)
 762:	6161                	addi	sp,sp,80
 764:	8082                	ret

0000000000000766 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 766:	715d                	addi	sp,sp,-80
 768:	ec06                	sd	ra,24(sp)
 76a:	e822                	sd	s0,16(sp)
 76c:	1000                	addi	s0,sp,32
 76e:	e010                	sd	a2,0(s0)
 770:	e414                	sd	a3,8(s0)
 772:	e818                	sd	a4,16(s0)
 774:	ec1c                	sd	a5,24(s0)
 776:	03043023          	sd	a6,32(s0)
 77a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 77e:	8622                	mv	a2,s0
 780:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 784:	00000097          	auipc	ra,0x0
 788:	e14080e7          	jalr	-492(ra) # 598 <vprintf>
}
 78c:	60e2                	ld	ra,24(sp)
 78e:	6442                	ld	s0,16(sp)
 790:	6161                	addi	sp,sp,80
 792:	8082                	ret

0000000000000794 <printf>:

void
printf(const char *fmt, ...)
{
 794:	711d                	addi	sp,sp,-96
 796:	ec06                	sd	ra,24(sp)
 798:	e822                	sd	s0,16(sp)
 79a:	1000                	addi	s0,sp,32
 79c:	e40c                	sd	a1,8(s0)
 79e:	e810                	sd	a2,16(s0)
 7a0:	ec14                	sd	a3,24(s0)
 7a2:	f018                	sd	a4,32(s0)
 7a4:	f41c                	sd	a5,40(s0)
 7a6:	03043823          	sd	a6,48(s0)
 7aa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ae:	00840613          	addi	a2,s0,8
 7b2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7b6:	85aa                	mv	a1,a0
 7b8:	4505                	li	a0,1
 7ba:	00000097          	auipc	ra,0x0
 7be:	dde080e7          	jalr	-546(ra) # 598 <vprintf>
}
 7c2:	60e2                	ld	ra,24(sp)
 7c4:	6442                	ld	s0,16(sp)
 7c6:	6125                	addi	sp,sp,96
 7c8:	8082                	ret

00000000000007ca <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ca:	1141                	addi	sp,sp,-16
 7cc:	e406                	sd	ra,8(sp)
 7ce:	e022                	sd	s0,0(sp)
 7d0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d6:	00001797          	auipc	a5,0x1
 7da:	82a7b783          	ld	a5,-2006(a5) # 1000 <freep>
 7de:	a039                	j	7ec <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e0:	6398                	ld	a4,0(a5)
 7e2:	00e7e463          	bltu	a5,a4,7ea <free+0x20>
 7e6:	00e6ea63          	bltu	a3,a4,7fa <free+0x30>
{
 7ea:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ec:	fed7fae3          	bgeu	a5,a3,7e0 <free+0x16>
 7f0:	6398                	ld	a4,0(a5)
 7f2:	00e6e463          	bltu	a3,a4,7fa <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f6:	fee7eae3          	bltu	a5,a4,7ea <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7fa:	ff852583          	lw	a1,-8(a0)
 7fe:	6390                	ld	a2,0(a5)
 800:	02059813          	slli	a6,a1,0x20
 804:	01c85713          	srli	a4,a6,0x1c
 808:	9736                	add	a4,a4,a3
 80a:	02e60563          	beq	a2,a4,834 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 80e:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 812:	4790                	lw	a2,8(a5)
 814:	02061593          	slli	a1,a2,0x20
 818:	01c5d713          	srli	a4,a1,0x1c
 81c:	973e                	add	a4,a4,a5
 81e:	02e68263          	beq	a3,a4,842 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 822:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 824:	00000717          	auipc	a4,0x0
 828:	7cf73e23          	sd	a5,2012(a4) # 1000 <freep>
}
 82c:	60a2                	ld	ra,8(sp)
 82e:	6402                	ld	s0,0(sp)
 830:	0141                	addi	sp,sp,16
 832:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 834:	4618                	lw	a4,8(a2)
 836:	9f2d                	addw	a4,a4,a1
 838:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 83c:	6398                	ld	a4,0(a5)
 83e:	6310                	ld	a2,0(a4)
 840:	b7f9                	j	80e <free+0x44>
    p->s.size += bp->s.size;
 842:	ff852703          	lw	a4,-8(a0)
 846:	9f31                	addw	a4,a4,a2
 848:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 84a:	ff053683          	ld	a3,-16(a0)
 84e:	bfd1                	j	822 <free+0x58>

0000000000000850 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 850:	7139                	addi	sp,sp,-64
 852:	fc06                	sd	ra,56(sp)
 854:	f822                	sd	s0,48(sp)
 856:	f04a                	sd	s2,32(sp)
 858:	ec4e                	sd	s3,24(sp)
 85a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 85c:	02051993          	slli	s3,a0,0x20
 860:	0209d993          	srli	s3,s3,0x20
 864:	09bd                	addi	s3,s3,15
 866:	0049d993          	srli	s3,s3,0x4
 86a:	2985                	addiw	s3,s3,1
 86c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 86e:	00000517          	auipc	a0,0x0
 872:	79253503          	ld	a0,1938(a0) # 1000 <freep>
 876:	c905                	beqz	a0,8a6 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 878:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 87a:	4798                	lw	a4,8(a5)
 87c:	09377a63          	bgeu	a4,s3,910 <malloc+0xc0>
 880:	f426                	sd	s1,40(sp)
 882:	e852                	sd	s4,16(sp)
 884:	e456                	sd	s5,8(sp)
 886:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 888:	8a4e                	mv	s4,s3
 88a:	6705                	lui	a4,0x1
 88c:	00e9f363          	bgeu	s3,a4,892 <malloc+0x42>
 890:	6a05                	lui	s4,0x1
 892:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 896:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 89a:	00000497          	auipc	s1,0x0
 89e:	76648493          	addi	s1,s1,1894 # 1000 <freep>
  if(p == (char*)-1)
 8a2:	5afd                	li	s5,-1
 8a4:	a089                	j	8e6 <malloc+0x96>
 8a6:	f426                	sd	s1,40(sp)
 8a8:	e852                	sd	s4,16(sp)
 8aa:	e456                	sd	s5,8(sp)
 8ac:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8ae:	00000797          	auipc	a5,0x0
 8b2:	76278793          	addi	a5,a5,1890 # 1010 <base>
 8b6:	00000717          	auipc	a4,0x0
 8ba:	74f73523          	sd	a5,1866(a4) # 1000 <freep>
 8be:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8c4:	b7d1                	j	888 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8c6:	6398                	ld	a4,0(a5)
 8c8:	e118                	sd	a4,0(a0)
 8ca:	a8b9                	j	928 <malloc+0xd8>
  hp->s.size = nu;
 8cc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d0:	0541                	addi	a0,a0,16
 8d2:	00000097          	auipc	ra,0x0
 8d6:	ef8080e7          	jalr	-264(ra) # 7ca <free>
  return freep;
 8da:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8dc:	c135                	beqz	a0,940 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e0:	4798                	lw	a4,8(a5)
 8e2:	03277363          	bgeu	a4,s2,908 <malloc+0xb8>
    if(p == freep)
 8e6:	6098                	ld	a4,0(s1)
 8e8:	853e                	mv	a0,a5
 8ea:	fef71ae3          	bne	a4,a5,8de <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8ee:	8552                	mv	a0,s4
 8f0:	00000097          	auipc	ra,0x0
 8f4:	bbe080e7          	jalr	-1090(ra) # 4ae <sbrk>
  if(p == (char*)-1)
 8f8:	fd551ae3          	bne	a0,s5,8cc <malloc+0x7c>
        return 0;
 8fc:	4501                	li	a0,0
 8fe:	74a2                	ld	s1,40(sp)
 900:	6a42                	ld	s4,16(sp)
 902:	6aa2                	ld	s5,8(sp)
 904:	6b02                	ld	s6,0(sp)
 906:	a03d                	j	934 <malloc+0xe4>
 908:	74a2                	ld	s1,40(sp)
 90a:	6a42                	ld	s4,16(sp)
 90c:	6aa2                	ld	s5,8(sp)
 90e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 910:	fae90be3          	beq	s2,a4,8c6 <malloc+0x76>
        p->s.size -= nunits;
 914:	4137073b          	subw	a4,a4,s3
 918:	c798                	sw	a4,8(a5)
        p += p->s.size;
 91a:	02071693          	slli	a3,a4,0x20
 91e:	01c6d713          	srli	a4,a3,0x1c
 922:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 924:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 928:	00000717          	auipc	a4,0x0
 92c:	6ca73c23          	sd	a0,1752(a4) # 1000 <freep>
      return (void*)(p + 1);
 930:	01078513          	addi	a0,a5,16
  }
}
 934:	70e2                	ld	ra,56(sp)
 936:	7442                	ld	s0,48(sp)
 938:	7902                	ld	s2,32(sp)
 93a:	69e2                	ld	s3,24(sp)
 93c:	6121                	addi	sp,sp,64
 93e:	8082                	ret
 940:	74a2                	ld	s1,40(sp)
 942:	6a42                	ld	s4,16(sp)
 944:	6aa2                	ld	s5,8(sp)
 946:	6b02                	ld	s6,0(sp)
 948:	b7f5                	j	934 <malloc+0xe4>
