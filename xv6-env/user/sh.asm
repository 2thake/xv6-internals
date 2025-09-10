
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
  write(2, "$ ", 2);
      10:	4609                	li	a2,2
      12:	00001597          	auipc	a1,0x1
      16:	34e58593          	addi	a1,a1,846 # 1360 <malloc+0x100>
      1a:	8532                	mv	a0,a2
      1c:	00001097          	auipc	ra,0x1
      20:	e3a080e7          	jalr	-454(ra) # e56 <write>
  memset(buf, 0, nbuf);
      24:	864a                	mv	a2,s2
      26:	4581                	li	a1,0
      28:	8526                	mv	a0,s1
      2a:	00001097          	auipc	ra,0x1
      2e:	bfa080e7          	jalr	-1030(ra) # c24 <memset>
  gets(buf, nbuf);
      32:	85ca                	mv	a1,s2
      34:	8526                	mv	a0,s1
      36:	00001097          	auipc	ra,0x1
      3a:	c3c080e7          	jalr	-964(ra) # c72 <gets>
  if(buf[0] == 0) // EOF
      3e:	0004c503          	lbu	a0,0(s1)
      42:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      46:	40a0053b          	negw	a0,a0
      4a:	60e2                	ld	ra,24(sp)
      4c:	6442                	ld	s0,16(sp)
      4e:	64a2                	ld	s1,8(sp)
      50:	6902                	ld	s2,0(sp)
      52:	6105                	addi	sp,sp,32
      54:	8082                	ret

0000000000000056 <panic>:
  exit(0);
}

void
panic(char *s)
{
      56:	1141                	addi	sp,sp,-16
      58:	e406                	sd	ra,8(sp)
      5a:	e022                	sd	s0,0(sp)
      5c:	0800                	addi	s0,sp,16
      5e:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      60:	00001597          	auipc	a1,0x1
      64:	31058593          	addi	a1,a1,784 # 1370 <malloc+0x110>
      68:	4509                	li	a0,2
      6a:	00001097          	auipc	ra,0x1
      6e:	10c080e7          	jalr	268(ra) # 1176 <fprintf>
  exit(1);
      72:	4505                	li	a0,1
      74:	00001097          	auipc	ra,0x1
      78:	dc2080e7          	jalr	-574(ra) # e36 <exit>

000000000000007c <fork1>:
}

int
fork1(void)
{
      7c:	1141                	addi	sp,sp,-16
      7e:	e406                	sd	ra,8(sp)
      80:	e022                	sd	s0,0(sp)
      82:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      84:	00001097          	auipc	ra,0x1
      88:	daa080e7          	jalr	-598(ra) # e2e <fork>
  if(pid == -1)
      8c:	57fd                	li	a5,-1
      8e:	00f50663          	beq	a0,a5,9a <fork1+0x1e>
    panic("fork");
  return pid;
}
      92:	60a2                	ld	ra,8(sp)
      94:	6402                	ld	s0,0(sp)
      96:	0141                	addi	sp,sp,16
      98:	8082                	ret
    panic("fork");
      9a:	00001517          	auipc	a0,0x1
      9e:	2de50513          	addi	a0,a0,734 # 1378 <malloc+0x118>
      a2:	00000097          	auipc	ra,0x0
      a6:	fb4080e7          	jalr	-76(ra) # 56 <panic>

00000000000000aa <runcmd>:
{
      aa:	7179                	addi	sp,sp,-48
      ac:	f406                	sd	ra,40(sp)
      ae:	f022                	sd	s0,32(sp)
      b0:	1800                	addi	s0,sp,48
  if(cmd == 0)
      b2:	c115                	beqz	a0,d6 <runcmd+0x2c>
      b4:	ec26                	sd	s1,24(sp)
      b6:	84aa                	mv	s1,a0
  switch(cmd->type){
      b8:	4118                	lw	a4,0(a0)
      ba:	4795                	li	a5,5
      bc:	02e7e363          	bltu	a5,a4,e2 <runcmd+0x38>
      c0:	00056783          	lwu	a5,0(a0)
      c4:	078a                	slli	a5,a5,0x2
      c6:	00001717          	auipc	a4,0x1
      ca:	3b270713          	addi	a4,a4,946 # 1478 <malloc+0x218>
      ce:	97ba                	add	a5,a5,a4
      d0:	439c                	lw	a5,0(a5)
      d2:	97ba                	add	a5,a5,a4
      d4:	8782                	jr	a5
      d6:	ec26                	sd	s1,24(sp)
    exit(1);
      d8:	4505                	li	a0,1
      da:	00001097          	auipc	ra,0x1
      de:	d5c080e7          	jalr	-676(ra) # e36 <exit>
    panic("runcmd");
      e2:	00001517          	auipc	a0,0x1
      e6:	29e50513          	addi	a0,a0,670 # 1380 <malloc+0x120>
      ea:	00000097          	auipc	ra,0x0
      ee:	f6c080e7          	jalr	-148(ra) # 56 <panic>
    if(ecmd->argv[0] == 0)
      f2:	6508                	ld	a0,8(a0)
      f4:	c515                	beqz	a0,120 <runcmd+0x76>
    exec(ecmd->argv[0], ecmd->argv);
      f6:	00848593          	addi	a1,s1,8
      fa:	00001097          	auipc	ra,0x1
      fe:	d74080e7          	jalr	-652(ra) # e6e <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     102:	6490                	ld	a2,8(s1)
     104:	00001597          	auipc	a1,0x1
     108:	28458593          	addi	a1,a1,644 # 1388 <malloc+0x128>
     10c:	4509                	li	a0,2
     10e:	00001097          	auipc	ra,0x1
     112:	068080e7          	jalr	104(ra) # 1176 <fprintf>
  exit(0);
     116:	4501                	li	a0,0
     118:	00001097          	auipc	ra,0x1
     11c:	d1e080e7          	jalr	-738(ra) # e36 <exit>
      exit(1);
     120:	4505                	li	a0,1
     122:	00001097          	auipc	ra,0x1
     126:	d14080e7          	jalr	-748(ra) # e36 <exit>
    close(rcmd->fd);
     12a:	5148                	lw	a0,36(a0)
     12c:	00001097          	auipc	ra,0x1
     130:	d32080e7          	jalr	-718(ra) # e5e <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     134:	508c                	lw	a1,32(s1)
     136:	6888                	ld	a0,16(s1)
     138:	00001097          	auipc	ra,0x1
     13c:	d3e080e7          	jalr	-706(ra) # e76 <open>
     140:	00054763          	bltz	a0,14e <runcmd+0xa4>
    runcmd(rcmd->cmd);
     144:	6488                	ld	a0,8(s1)
     146:	00000097          	auipc	ra,0x0
     14a:	f64080e7          	jalr	-156(ra) # aa <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     14e:	6890                	ld	a2,16(s1)
     150:	00001597          	auipc	a1,0x1
     154:	24858593          	addi	a1,a1,584 # 1398 <malloc+0x138>
     158:	4509                	li	a0,2
     15a:	00001097          	auipc	ra,0x1
     15e:	01c080e7          	jalr	28(ra) # 1176 <fprintf>
      exit(1);
     162:	4505                	li	a0,1
     164:	00001097          	auipc	ra,0x1
     168:	cd2080e7          	jalr	-814(ra) # e36 <exit>
    if(fork1() == 0)
     16c:	00000097          	auipc	ra,0x0
     170:	f10080e7          	jalr	-240(ra) # 7c <fork1>
     174:	e511                	bnez	a0,180 <runcmd+0xd6>
      runcmd(lcmd->left);
     176:	6488                	ld	a0,8(s1)
     178:	00000097          	auipc	ra,0x0
     17c:	f32080e7          	jalr	-206(ra) # aa <runcmd>
    wait(0);
     180:	4501                	li	a0,0
     182:	00001097          	auipc	ra,0x1
     186:	cbc080e7          	jalr	-836(ra) # e3e <wait>
    runcmd(lcmd->right);
     18a:	6888                	ld	a0,16(s1)
     18c:	00000097          	auipc	ra,0x0
     190:	f1e080e7          	jalr	-226(ra) # aa <runcmd>
    if(pipe(p) < 0)
     194:	fd840513          	addi	a0,s0,-40
     198:	00001097          	auipc	ra,0x1
     19c:	cae080e7          	jalr	-850(ra) # e46 <pipe>
     1a0:	04054363          	bltz	a0,1e6 <runcmd+0x13c>
    if(fork1() == 0){
     1a4:	00000097          	auipc	ra,0x0
     1a8:	ed8080e7          	jalr	-296(ra) # 7c <fork1>
     1ac:	e529                	bnez	a0,1f6 <runcmd+0x14c>
      close(1);
     1ae:	4505                	li	a0,1
     1b0:	00001097          	auipc	ra,0x1
     1b4:	cae080e7          	jalr	-850(ra) # e5e <close>
      dup(p[1]);
     1b8:	fdc42503          	lw	a0,-36(s0)
     1bc:	00001097          	auipc	ra,0x1
     1c0:	cf2080e7          	jalr	-782(ra) # eae <dup>
      close(p[0]);
     1c4:	fd842503          	lw	a0,-40(s0)
     1c8:	00001097          	auipc	ra,0x1
     1cc:	c96080e7          	jalr	-874(ra) # e5e <close>
      close(p[1]);
     1d0:	fdc42503          	lw	a0,-36(s0)
     1d4:	00001097          	auipc	ra,0x1
     1d8:	c8a080e7          	jalr	-886(ra) # e5e <close>
      runcmd(pcmd->left);
     1dc:	6488                	ld	a0,8(s1)
     1de:	00000097          	auipc	ra,0x0
     1e2:	ecc080e7          	jalr	-308(ra) # aa <runcmd>
      panic("pipe");
     1e6:	00001517          	auipc	a0,0x1
     1ea:	1c250513          	addi	a0,a0,450 # 13a8 <malloc+0x148>
     1ee:	00000097          	auipc	ra,0x0
     1f2:	e68080e7          	jalr	-408(ra) # 56 <panic>
    if(fork1() == 0){
     1f6:	00000097          	auipc	ra,0x0
     1fa:	e86080e7          	jalr	-378(ra) # 7c <fork1>
     1fe:	ed05                	bnez	a0,236 <runcmd+0x18c>
      close(0);
     200:	00001097          	auipc	ra,0x1
     204:	c5e080e7          	jalr	-930(ra) # e5e <close>
      dup(p[0]);
     208:	fd842503          	lw	a0,-40(s0)
     20c:	00001097          	auipc	ra,0x1
     210:	ca2080e7          	jalr	-862(ra) # eae <dup>
      close(p[0]);
     214:	fd842503          	lw	a0,-40(s0)
     218:	00001097          	auipc	ra,0x1
     21c:	c46080e7          	jalr	-954(ra) # e5e <close>
      close(p[1]);
     220:	fdc42503          	lw	a0,-36(s0)
     224:	00001097          	auipc	ra,0x1
     228:	c3a080e7          	jalr	-966(ra) # e5e <close>
      runcmd(pcmd->right);
     22c:	6888                	ld	a0,16(s1)
     22e:	00000097          	auipc	ra,0x0
     232:	e7c080e7          	jalr	-388(ra) # aa <runcmd>
    close(p[0]);
     236:	fd842503          	lw	a0,-40(s0)
     23a:	00001097          	auipc	ra,0x1
     23e:	c24080e7          	jalr	-988(ra) # e5e <close>
    close(p[1]);
     242:	fdc42503          	lw	a0,-36(s0)
     246:	00001097          	auipc	ra,0x1
     24a:	c18080e7          	jalr	-1000(ra) # e5e <close>
    wait(0);
     24e:	4501                	li	a0,0
     250:	00001097          	auipc	ra,0x1
     254:	bee080e7          	jalr	-1042(ra) # e3e <wait>
    wait(0);
     258:	4501                	li	a0,0
     25a:	00001097          	auipc	ra,0x1
     25e:	be4080e7          	jalr	-1052(ra) # e3e <wait>
    break;
     262:	bd55                	j	116 <runcmd+0x6c>
    if(fork1() == 0)
     264:	00000097          	auipc	ra,0x0
     268:	e18080e7          	jalr	-488(ra) # 7c <fork1>
     26c:	ea0515e3          	bnez	a0,116 <runcmd+0x6c>
      runcmd(bcmd->cmd);
     270:	6488                	ld	a0,8(s1)
     272:	00000097          	auipc	ra,0x0
     276:	e38080e7          	jalr	-456(ra) # aa <runcmd>

000000000000027a <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     27a:	1101                	addi	sp,sp,-32
     27c:	ec06                	sd	ra,24(sp)
     27e:	e822                	sd	s0,16(sp)
     280:	e426                	sd	s1,8(sp)
     282:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     284:	0a800513          	li	a0,168
     288:	00001097          	auipc	ra,0x1
     28c:	fd8080e7          	jalr	-40(ra) # 1260 <malloc>
     290:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     292:	0a800613          	li	a2,168
     296:	4581                	li	a1,0
     298:	00001097          	auipc	ra,0x1
     29c:	98c080e7          	jalr	-1652(ra) # c24 <memset>
  cmd->type = EXEC;
     2a0:	4785                	li	a5,1
     2a2:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     2a4:	8526                	mv	a0,s1
     2a6:	60e2                	ld	ra,24(sp)
     2a8:	6442                	ld	s0,16(sp)
     2aa:	64a2                	ld	s1,8(sp)
     2ac:	6105                	addi	sp,sp,32
     2ae:	8082                	ret

00000000000002b0 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     2b0:	7139                	addi	sp,sp,-64
     2b2:	fc06                	sd	ra,56(sp)
     2b4:	f822                	sd	s0,48(sp)
     2b6:	f426                	sd	s1,40(sp)
     2b8:	f04a                	sd	s2,32(sp)
     2ba:	ec4e                	sd	s3,24(sp)
     2bc:	e852                	sd	s4,16(sp)
     2be:	e456                	sd	s5,8(sp)
     2c0:	e05a                	sd	s6,0(sp)
     2c2:	0080                	addi	s0,sp,64
     2c4:	892a                	mv	s2,a0
     2c6:	89ae                	mv	s3,a1
     2c8:	8a32                	mv	s4,a2
     2ca:	8ab6                	mv	s5,a3
     2cc:	8b3a                	mv	s6,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2ce:	02800513          	li	a0,40
     2d2:	00001097          	auipc	ra,0x1
     2d6:	f8e080e7          	jalr	-114(ra) # 1260 <malloc>
     2da:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2dc:	02800613          	li	a2,40
     2e0:	4581                	li	a1,0
     2e2:	00001097          	auipc	ra,0x1
     2e6:	942080e7          	jalr	-1726(ra) # c24 <memset>
  cmd->type = REDIR;
     2ea:	4789                	li	a5,2
     2ec:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     2ee:	0124b423          	sd	s2,8(s1)
  cmd->file = file;
     2f2:	0134b823          	sd	s3,16(s1)
  cmd->efile = efile;
     2f6:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     2fa:	0354a023          	sw	s5,32(s1)
  cmd->fd = fd;
     2fe:	0364a223          	sw	s6,36(s1)
  return (struct cmd*)cmd;
}
     302:	8526                	mv	a0,s1
     304:	70e2                	ld	ra,56(sp)
     306:	7442                	ld	s0,48(sp)
     308:	74a2                	ld	s1,40(sp)
     30a:	7902                	ld	s2,32(sp)
     30c:	69e2                	ld	s3,24(sp)
     30e:	6a42                	ld	s4,16(sp)
     310:	6aa2                	ld	s5,8(sp)
     312:	6b02                	ld	s6,0(sp)
     314:	6121                	addi	sp,sp,64
     316:	8082                	ret

0000000000000318 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     318:	7179                	addi	sp,sp,-48
     31a:	f406                	sd	ra,40(sp)
     31c:	f022                	sd	s0,32(sp)
     31e:	ec26                	sd	s1,24(sp)
     320:	e84a                	sd	s2,16(sp)
     322:	e44e                	sd	s3,8(sp)
     324:	1800                	addi	s0,sp,48
     326:	892a                	mv	s2,a0
     328:	89ae                	mv	s3,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     32a:	4561                	li	a0,24
     32c:	00001097          	auipc	ra,0x1
     330:	f34080e7          	jalr	-204(ra) # 1260 <malloc>
     334:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     336:	4661                	li	a2,24
     338:	4581                	li	a1,0
     33a:	00001097          	auipc	ra,0x1
     33e:	8ea080e7          	jalr	-1814(ra) # c24 <memset>
  cmd->type = PIPE;
     342:	478d                	li	a5,3
     344:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     346:	0124b423          	sd	s2,8(s1)
  cmd->right = right;
     34a:	0134b823          	sd	s3,16(s1)
  return (struct cmd*)cmd;
}
     34e:	8526                	mv	a0,s1
     350:	70a2                	ld	ra,40(sp)
     352:	7402                	ld	s0,32(sp)
     354:	64e2                	ld	s1,24(sp)
     356:	6942                	ld	s2,16(sp)
     358:	69a2                	ld	s3,8(sp)
     35a:	6145                	addi	sp,sp,48
     35c:	8082                	ret

000000000000035e <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     35e:	7179                	addi	sp,sp,-48
     360:	f406                	sd	ra,40(sp)
     362:	f022                	sd	s0,32(sp)
     364:	ec26                	sd	s1,24(sp)
     366:	e84a                	sd	s2,16(sp)
     368:	e44e                	sd	s3,8(sp)
     36a:	1800                	addi	s0,sp,48
     36c:	892a                	mv	s2,a0
     36e:	89ae                	mv	s3,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     370:	4561                	li	a0,24
     372:	00001097          	auipc	ra,0x1
     376:	eee080e7          	jalr	-274(ra) # 1260 <malloc>
     37a:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     37c:	4661                	li	a2,24
     37e:	4581                	li	a1,0
     380:	00001097          	auipc	ra,0x1
     384:	8a4080e7          	jalr	-1884(ra) # c24 <memset>
  cmd->type = LIST;
     388:	4791                	li	a5,4
     38a:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     38c:	0124b423          	sd	s2,8(s1)
  cmd->right = right;
     390:	0134b823          	sd	s3,16(s1)
  return (struct cmd*)cmd;
}
     394:	8526                	mv	a0,s1
     396:	70a2                	ld	ra,40(sp)
     398:	7402                	ld	s0,32(sp)
     39a:	64e2                	ld	s1,24(sp)
     39c:	6942                	ld	s2,16(sp)
     39e:	69a2                	ld	s3,8(sp)
     3a0:	6145                	addi	sp,sp,48
     3a2:	8082                	ret

00000000000003a4 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     3a4:	1101                	addi	sp,sp,-32
     3a6:	ec06                	sd	ra,24(sp)
     3a8:	e822                	sd	s0,16(sp)
     3aa:	e426                	sd	s1,8(sp)
     3ac:	e04a                	sd	s2,0(sp)
     3ae:	1000                	addi	s0,sp,32
     3b0:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3b2:	4541                	li	a0,16
     3b4:	00001097          	auipc	ra,0x1
     3b8:	eac080e7          	jalr	-340(ra) # 1260 <malloc>
     3bc:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3be:	4641                	li	a2,16
     3c0:	4581                	li	a1,0
     3c2:	00001097          	auipc	ra,0x1
     3c6:	862080e7          	jalr	-1950(ra) # c24 <memset>
  cmd->type = BACK;
     3ca:	4795                	li	a5,5
     3cc:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     3ce:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     3d2:	8526                	mv	a0,s1
     3d4:	60e2                	ld	ra,24(sp)
     3d6:	6442                	ld	s0,16(sp)
     3d8:	64a2                	ld	s1,8(sp)
     3da:	6902                	ld	s2,0(sp)
     3dc:	6105                	addi	sp,sp,32
     3de:	8082                	ret

00000000000003e0 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     3e0:	7139                	addi	sp,sp,-64
     3e2:	fc06                	sd	ra,56(sp)
     3e4:	f822                	sd	s0,48(sp)
     3e6:	f426                	sd	s1,40(sp)
     3e8:	f04a                	sd	s2,32(sp)
     3ea:	ec4e                	sd	s3,24(sp)
     3ec:	e852                	sd	s4,16(sp)
     3ee:	e456                	sd	s5,8(sp)
     3f0:	e05a                	sd	s6,0(sp)
     3f2:	0080                	addi	s0,sp,64
     3f4:	8a2a                	mv	s4,a0
     3f6:	892e                	mv	s2,a1
     3f8:	8ab2                	mv	s5,a2
     3fa:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     3fc:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     3fe:	00002997          	auipc	s3,0x2
     402:	c0a98993          	addi	s3,s3,-1014 # 2008 <whitespace>
     406:	00b4fe63          	bgeu	s1,a1,422 <gettoken+0x42>
     40a:	0004c583          	lbu	a1,0(s1)
     40e:	854e                	mv	a0,s3
     410:	00001097          	auipc	ra,0x1
     414:	83a080e7          	jalr	-1990(ra) # c4a <strchr>
     418:	c509                	beqz	a0,422 <gettoken+0x42>
    s++;
     41a:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     41c:	fe9917e3          	bne	s2,s1,40a <gettoken+0x2a>
     420:	84ca                	mv	s1,s2
  if(q)
     422:	000a8463          	beqz	s5,42a <gettoken+0x4a>
    *q = s;
     426:	009ab023          	sd	s1,0(s5)
  ret = *s;
     42a:	0004c783          	lbu	a5,0(s1)
     42e:	00078a9b          	sext.w	s5,a5
  switch(*s){
     432:	03c00713          	li	a4,60
     436:	06f76663          	bltu	a4,a5,4a2 <gettoken+0xc2>
     43a:	03a00713          	li	a4,58
     43e:	00f76e63          	bltu	a4,a5,45a <gettoken+0x7a>
     442:	cf89                	beqz	a5,45c <gettoken+0x7c>
     444:	02600713          	li	a4,38
     448:	00e78963          	beq	a5,a4,45a <gettoken+0x7a>
     44c:	fd87879b          	addiw	a5,a5,-40
     450:	0ff7f793          	zext.b	a5,a5
     454:	4705                	li	a4,1
     456:	06f76763          	bltu	a4,a5,4c4 <gettoken+0xe4>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     45a:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     45c:	000b0463          	beqz	s6,464 <gettoken+0x84>
    *eq = s;
     460:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     464:	00002997          	auipc	s3,0x2
     468:	ba498993          	addi	s3,s3,-1116 # 2008 <whitespace>
     46c:	0124fe63          	bgeu	s1,s2,488 <gettoken+0xa8>
     470:	0004c583          	lbu	a1,0(s1)
     474:	854e                	mv	a0,s3
     476:	00000097          	auipc	ra,0x0
     47a:	7d4080e7          	jalr	2004(ra) # c4a <strchr>
     47e:	c509                	beqz	a0,488 <gettoken+0xa8>
    s++;
     480:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     482:	fe9917e3          	bne	s2,s1,470 <gettoken+0x90>
     486:	84ca                	mv	s1,s2
  *ps = s;
     488:	009a3023          	sd	s1,0(s4)
  return ret;
}
     48c:	8556                	mv	a0,s5
     48e:	70e2                	ld	ra,56(sp)
     490:	7442                	ld	s0,48(sp)
     492:	74a2                	ld	s1,40(sp)
     494:	7902                	ld	s2,32(sp)
     496:	69e2                	ld	s3,24(sp)
     498:	6a42                	ld	s4,16(sp)
     49a:	6aa2                	ld	s5,8(sp)
     49c:	6b02                	ld	s6,0(sp)
     49e:	6121                	addi	sp,sp,64
     4a0:	8082                	ret
  switch(*s){
     4a2:	03e00713          	li	a4,62
     4a6:	00e79b63          	bne	a5,a4,4bc <gettoken+0xdc>
    if(*s == '>'){
     4aa:	0014c703          	lbu	a4,1(s1)
     4ae:	03e00793          	li	a5,62
     4b2:	04f70c63          	beq	a4,a5,50a <gettoken+0x12a>
    s++;
     4b6:	0485                	addi	s1,s1,1
  ret = *s;
     4b8:	8abe                	mv	s5,a5
     4ba:	b74d                	j	45c <gettoken+0x7c>
  switch(*s){
     4bc:	07c00713          	li	a4,124
     4c0:	f8e78de3          	beq	a5,a4,45a <gettoken+0x7a>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     4c4:	00002997          	auipc	s3,0x2
     4c8:	b4498993          	addi	s3,s3,-1212 # 2008 <whitespace>
     4cc:	00002a97          	auipc	s5,0x2
     4d0:	b34a8a93          	addi	s5,s5,-1228 # 2000 <symbols>
     4d4:	0524f563          	bgeu	s1,s2,51e <gettoken+0x13e>
     4d8:	0004c583          	lbu	a1,0(s1)
     4dc:	854e                	mv	a0,s3
     4de:	00000097          	auipc	ra,0x0
     4e2:	76c080e7          	jalr	1900(ra) # c4a <strchr>
     4e6:	e90d                	bnez	a0,518 <gettoken+0x138>
     4e8:	0004c583          	lbu	a1,0(s1)
     4ec:	8556                	mv	a0,s5
     4ee:	00000097          	auipc	ra,0x0
     4f2:	75c080e7          	jalr	1884(ra) # c4a <strchr>
     4f6:	ed11                	bnez	a0,512 <gettoken+0x132>
      s++;
     4f8:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     4fa:	fc991fe3          	bne	s2,s1,4d8 <gettoken+0xf8>
  if(eq)
     4fe:	84ca                	mv	s1,s2
    ret = 'a';
     500:	06100a93          	li	s5,97
  if(eq)
     504:	f40b1ee3          	bnez	s6,460 <gettoken+0x80>
     508:	b741                	j	488 <gettoken+0xa8>
      s++;
     50a:	0489                	addi	s1,s1,2
      ret = '+';
     50c:	02b00a93          	li	s5,43
     510:	b7b1                	j	45c <gettoken+0x7c>
    ret = 'a';
     512:	06100a93          	li	s5,97
     516:	b799                	j	45c <gettoken+0x7c>
     518:	06100a93          	li	s5,97
     51c:	b781                	j	45c <gettoken+0x7c>
     51e:	06100a93          	li	s5,97
  if(eq)
     522:	f20b1fe3          	bnez	s6,460 <gettoken+0x80>
     526:	b78d                	j	488 <gettoken+0xa8>

0000000000000528 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     528:	7139                	addi	sp,sp,-64
     52a:	fc06                	sd	ra,56(sp)
     52c:	f822                	sd	s0,48(sp)
     52e:	f426                	sd	s1,40(sp)
     530:	f04a                	sd	s2,32(sp)
     532:	ec4e                	sd	s3,24(sp)
     534:	e852                	sd	s4,16(sp)
     536:	e456                	sd	s5,8(sp)
     538:	0080                	addi	s0,sp,64
     53a:	8a2a                	mv	s4,a0
     53c:	892e                	mv	s2,a1
     53e:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     540:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     542:	00002997          	auipc	s3,0x2
     546:	ac698993          	addi	s3,s3,-1338 # 2008 <whitespace>
     54a:	00b4fe63          	bgeu	s1,a1,566 <peek+0x3e>
     54e:	0004c583          	lbu	a1,0(s1)
     552:	854e                	mv	a0,s3
     554:	00000097          	auipc	ra,0x0
     558:	6f6080e7          	jalr	1782(ra) # c4a <strchr>
     55c:	c509                	beqz	a0,566 <peek+0x3e>
    s++;
     55e:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     560:	fe9917e3          	bne	s2,s1,54e <peek+0x26>
     564:	84ca                	mv	s1,s2
  *ps = s;
     566:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     56a:	0004c583          	lbu	a1,0(s1)
     56e:	4501                	li	a0,0
     570:	e991                	bnez	a1,584 <peek+0x5c>
}
     572:	70e2                	ld	ra,56(sp)
     574:	7442                	ld	s0,48(sp)
     576:	74a2                	ld	s1,40(sp)
     578:	7902                	ld	s2,32(sp)
     57a:	69e2                	ld	s3,24(sp)
     57c:	6a42                	ld	s4,16(sp)
     57e:	6aa2                	ld	s5,8(sp)
     580:	6121                	addi	sp,sp,64
     582:	8082                	ret
  return *s && strchr(toks, *s);
     584:	8556                	mv	a0,s5
     586:	00000097          	auipc	ra,0x0
     58a:	6c4080e7          	jalr	1732(ra) # c4a <strchr>
     58e:	00a03533          	snez	a0,a0
     592:	b7c5                	j	572 <peek+0x4a>

0000000000000594 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     594:	7159                	addi	sp,sp,-112
     596:	f486                	sd	ra,104(sp)
     598:	f0a2                	sd	s0,96(sp)
     59a:	eca6                	sd	s1,88(sp)
     59c:	e8ca                	sd	s2,80(sp)
     59e:	e4ce                	sd	s3,72(sp)
     5a0:	e0d2                	sd	s4,64(sp)
     5a2:	fc56                	sd	s5,56(sp)
     5a4:	f85a                	sd	s6,48(sp)
     5a6:	f45e                	sd	s7,40(sp)
     5a8:	f062                	sd	s8,32(sp)
     5aa:	ec66                	sd	s9,24(sp)
     5ac:	1880                	addi	s0,sp,112
     5ae:	8a2a                	mv	s4,a0
     5b0:	89ae                	mv	s3,a1
     5b2:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     5b4:	00001b17          	auipc	s6,0x1
     5b8:	e1cb0b13          	addi	s6,s6,-484 # 13d0 <malloc+0x170>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     5bc:	f9040c93          	addi	s9,s0,-112
     5c0:	f9840c13          	addi	s8,s0,-104
     5c4:	06100b93          	li	s7,97
  while(peek(ps, es, "<>")){
     5c8:	a02d                	j	5f2 <parseredirs+0x5e>
      panic("missing file for redirection");
     5ca:	00001517          	auipc	a0,0x1
     5ce:	de650513          	addi	a0,a0,-538 # 13b0 <malloc+0x150>
     5d2:	00000097          	auipc	ra,0x0
     5d6:	a84080e7          	jalr	-1404(ra) # 56 <panic>
    switch(tok){
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     5da:	4701                	li	a4,0
     5dc:	4681                	li	a3,0
     5de:	f9043603          	ld	a2,-112(s0)
     5e2:	f9843583          	ld	a1,-104(s0)
     5e6:	8552                	mv	a0,s4
     5e8:	00000097          	auipc	ra,0x0
     5ec:	cc8080e7          	jalr	-824(ra) # 2b0 <redircmd>
     5f0:	8a2a                	mv	s4,a0
    switch(tok){
     5f2:	03c00a93          	li	s5,60
  while(peek(ps, es, "<>")){
     5f6:	865a                	mv	a2,s6
     5f8:	85ca                	mv	a1,s2
     5fa:	854e                	mv	a0,s3
     5fc:	00000097          	auipc	ra,0x0
     600:	f2c080e7          	jalr	-212(ra) # 528 <peek>
     604:	c935                	beqz	a0,678 <parseredirs+0xe4>
    tok = gettoken(ps, es, 0, 0);
     606:	4681                	li	a3,0
     608:	4601                	li	a2,0
     60a:	85ca                	mv	a1,s2
     60c:	854e                	mv	a0,s3
     60e:	00000097          	auipc	ra,0x0
     612:	dd2080e7          	jalr	-558(ra) # 3e0 <gettoken>
     616:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     618:	86e6                	mv	a3,s9
     61a:	8662                	mv	a2,s8
     61c:	85ca                	mv	a1,s2
     61e:	854e                	mv	a0,s3
     620:	00000097          	auipc	ra,0x0
     624:	dc0080e7          	jalr	-576(ra) # 3e0 <gettoken>
     628:	fb7511e3          	bne	a0,s7,5ca <parseredirs+0x36>
    switch(tok){
     62c:	fb5487e3          	beq	s1,s5,5da <parseredirs+0x46>
     630:	03e00793          	li	a5,62
     634:	02f48463          	beq	s1,a5,65c <parseredirs+0xc8>
     638:	02b00793          	li	a5,43
     63c:	faf49de3          	bne	s1,a5,5f6 <parseredirs+0x62>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     640:	4705                	li	a4,1
     642:	20100693          	li	a3,513
     646:	f9043603          	ld	a2,-112(s0)
     64a:	f9843583          	ld	a1,-104(s0)
     64e:	8552                	mv	a0,s4
     650:	00000097          	auipc	ra,0x0
     654:	c60080e7          	jalr	-928(ra) # 2b0 <redircmd>
     658:	8a2a                	mv	s4,a0
      break;
     65a:	bf61                	j	5f2 <parseredirs+0x5e>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     65c:	4705                	li	a4,1
     65e:	60100693          	li	a3,1537
     662:	f9043603          	ld	a2,-112(s0)
     666:	f9843583          	ld	a1,-104(s0)
     66a:	8552                	mv	a0,s4
     66c:	00000097          	auipc	ra,0x0
     670:	c44080e7          	jalr	-956(ra) # 2b0 <redircmd>
     674:	8a2a                	mv	s4,a0
      break;
     676:	bfb5                	j	5f2 <parseredirs+0x5e>
    }
  }
  return cmd;
}
     678:	8552                	mv	a0,s4
     67a:	70a6                	ld	ra,104(sp)
     67c:	7406                	ld	s0,96(sp)
     67e:	64e6                	ld	s1,88(sp)
     680:	6946                	ld	s2,80(sp)
     682:	69a6                	ld	s3,72(sp)
     684:	6a06                	ld	s4,64(sp)
     686:	7ae2                	ld	s5,56(sp)
     688:	7b42                	ld	s6,48(sp)
     68a:	7ba2                	ld	s7,40(sp)
     68c:	7c02                	ld	s8,32(sp)
     68e:	6ce2                	ld	s9,24(sp)
     690:	6165                	addi	sp,sp,112
     692:	8082                	ret

0000000000000694 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     694:	7119                	addi	sp,sp,-128
     696:	fc86                	sd	ra,120(sp)
     698:	f8a2                	sd	s0,112(sp)
     69a:	f4a6                	sd	s1,104(sp)
     69c:	e8d2                	sd	s4,80(sp)
     69e:	e4d6                	sd	s5,72(sp)
     6a0:	0100                	addi	s0,sp,128
     6a2:	8a2a                	mv	s4,a0
     6a4:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     6a6:	00001617          	auipc	a2,0x1
     6aa:	d3260613          	addi	a2,a2,-718 # 13d8 <malloc+0x178>
     6ae:	00000097          	auipc	ra,0x0
     6b2:	e7a080e7          	jalr	-390(ra) # 528 <peek>
     6b6:	e521                	bnez	a0,6fe <parseexec+0x6a>
     6b8:	f0ca                	sd	s2,96(sp)
     6ba:	ecce                	sd	s3,88(sp)
     6bc:	e0da                	sd	s6,64(sp)
     6be:	fc5e                	sd	s7,56(sp)
     6c0:	f862                	sd	s8,48(sp)
     6c2:	f466                	sd	s9,40(sp)
     6c4:	f06a                	sd	s10,32(sp)
     6c6:	ec6e                	sd	s11,24(sp)
     6c8:	892a                	mv	s2,a0
    return parseblock(ps, es);

  ret = execcmd();
     6ca:	00000097          	auipc	ra,0x0
     6ce:	bb0080e7          	jalr	-1104(ra) # 27a <execcmd>
     6d2:	89aa                	mv	s3,a0
     6d4:	8daa                	mv	s11,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     6d6:	8656                	mv	a2,s5
     6d8:	85d2                	mv	a1,s4
     6da:	00000097          	auipc	ra,0x0
     6de:	eba080e7          	jalr	-326(ra) # 594 <parseredirs>
     6e2:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     6e4:	09a1                	addi	s3,s3,8
     6e6:	00001b17          	auipc	s6,0x1
     6ea:	d12b0b13          	addi	s6,s6,-750 # 13f8 <malloc+0x198>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     6ee:	f8040c13          	addi	s8,s0,-128
     6f2:	f8840b93          	addi	s7,s0,-120
      break;
    if(tok != 'a')
     6f6:	06100d13          	li	s10,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     6fa:	4ca9                	li	s9,10
  while(!peek(ps, es, "|)&;")){
     6fc:	a089                	j	73e <parseexec+0xaa>
    return parseblock(ps, es);
     6fe:	85d6                	mv	a1,s5
     700:	8552                	mv	a0,s4
     702:	00000097          	auipc	ra,0x0
     706:	1c4080e7          	jalr	452(ra) # 8c6 <parseblock>
     70a:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     70c:	8526                	mv	a0,s1
     70e:	70e6                	ld	ra,120(sp)
     710:	7446                	ld	s0,112(sp)
     712:	74a6                	ld	s1,104(sp)
     714:	6a46                	ld	s4,80(sp)
     716:	6aa6                	ld	s5,72(sp)
     718:	6109                	addi	sp,sp,128
     71a:	8082                	ret
      panic("syntax");
     71c:	00001517          	auipc	a0,0x1
     720:	cc450513          	addi	a0,a0,-828 # 13e0 <malloc+0x180>
     724:	00000097          	auipc	ra,0x0
     728:	932080e7          	jalr	-1742(ra) # 56 <panic>
    if(argc >= MAXARGS)
     72c:	09a1                	addi	s3,s3,8
    ret = parseredirs(ret, ps, es);
     72e:	8656                	mv	a2,s5
     730:	85d2                	mv	a1,s4
     732:	8526                	mv	a0,s1
     734:	00000097          	auipc	ra,0x0
     738:	e60080e7          	jalr	-416(ra) # 594 <parseredirs>
     73c:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     73e:	865a                	mv	a2,s6
     740:	85d6                	mv	a1,s5
     742:	8552                	mv	a0,s4
     744:	00000097          	auipc	ra,0x0
     748:	de4080e7          	jalr	-540(ra) # 528 <peek>
     74c:	ed1d                	bnez	a0,78a <parseexec+0xf6>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     74e:	86e2                	mv	a3,s8
     750:	865e                	mv	a2,s7
     752:	85d6                	mv	a1,s5
     754:	8552                	mv	a0,s4
     756:	00000097          	auipc	ra,0x0
     75a:	c8a080e7          	jalr	-886(ra) # 3e0 <gettoken>
     75e:	c515                	beqz	a0,78a <parseexec+0xf6>
    if(tok != 'a')
     760:	fba51ee3          	bne	a0,s10,71c <parseexec+0x88>
    cmd->argv[argc] = q;
     764:	f8843783          	ld	a5,-120(s0)
     768:	00f9b023          	sd	a5,0(s3)
    cmd->eargv[argc] = eq;
     76c:	f8043783          	ld	a5,-128(s0)
     770:	04f9b823          	sd	a5,80(s3)
    argc++;
     774:	2905                	addiw	s2,s2,1
    if(argc >= MAXARGS)
     776:	fb991be3          	bne	s2,s9,72c <parseexec+0x98>
      panic("too many args");
     77a:	00001517          	auipc	a0,0x1
     77e:	c6e50513          	addi	a0,a0,-914 # 13e8 <malloc+0x188>
     782:	00000097          	auipc	ra,0x0
     786:	8d4080e7          	jalr	-1836(ra) # 56 <panic>
  cmd->argv[argc] = 0;
     78a:	090e                	slli	s2,s2,0x3
     78c:	012d87b3          	add	a5,s11,s2
     790:	0007b423          	sd	zero,8(a5)
  cmd->eargv[argc] = 0;
     794:	0407bc23          	sd	zero,88(a5)
     798:	7906                	ld	s2,96(sp)
     79a:	69e6                	ld	s3,88(sp)
     79c:	6b06                	ld	s6,64(sp)
     79e:	7be2                	ld	s7,56(sp)
     7a0:	7c42                	ld	s8,48(sp)
     7a2:	7ca2                	ld	s9,40(sp)
     7a4:	7d02                	ld	s10,32(sp)
     7a6:	6de2                	ld	s11,24(sp)
  return ret;
     7a8:	b795                	j	70c <parseexec+0x78>

00000000000007aa <parsepipe>:
{
     7aa:	7179                	addi	sp,sp,-48
     7ac:	f406                	sd	ra,40(sp)
     7ae:	f022                	sd	s0,32(sp)
     7b0:	ec26                	sd	s1,24(sp)
     7b2:	e84a                	sd	s2,16(sp)
     7b4:	e44e                	sd	s3,8(sp)
     7b6:	e052                	sd	s4,0(sp)
     7b8:	1800                	addi	s0,sp,48
     7ba:	892a                	mv	s2,a0
     7bc:	8a2a                	mv	s4,a0
     7be:	84ae                	mv	s1,a1
  cmd = parseexec(ps, es);
     7c0:	00000097          	auipc	ra,0x0
     7c4:	ed4080e7          	jalr	-300(ra) # 694 <parseexec>
     7c8:	89aa                	mv	s3,a0
  if(peek(ps, es, "|")){
     7ca:	00001617          	auipc	a2,0x1
     7ce:	c3660613          	addi	a2,a2,-970 # 1400 <malloc+0x1a0>
     7d2:	85a6                	mv	a1,s1
     7d4:	854a                	mv	a0,s2
     7d6:	00000097          	auipc	ra,0x0
     7da:	d52080e7          	jalr	-686(ra) # 528 <peek>
     7de:	e911                	bnez	a0,7f2 <parsepipe+0x48>
}
     7e0:	854e                	mv	a0,s3
     7e2:	70a2                	ld	ra,40(sp)
     7e4:	7402                	ld	s0,32(sp)
     7e6:	64e2                	ld	s1,24(sp)
     7e8:	6942                	ld	s2,16(sp)
     7ea:	69a2                	ld	s3,8(sp)
     7ec:	6a02                	ld	s4,0(sp)
     7ee:	6145                	addi	sp,sp,48
     7f0:	8082                	ret
    gettoken(ps, es, 0, 0);
     7f2:	4681                	li	a3,0
     7f4:	4601                	li	a2,0
     7f6:	85a6                	mv	a1,s1
     7f8:	8552                	mv	a0,s4
     7fa:	00000097          	auipc	ra,0x0
     7fe:	be6080e7          	jalr	-1050(ra) # 3e0 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     802:	85a6                	mv	a1,s1
     804:	8552                	mv	a0,s4
     806:	00000097          	auipc	ra,0x0
     80a:	fa4080e7          	jalr	-92(ra) # 7aa <parsepipe>
     80e:	85aa                	mv	a1,a0
     810:	854e                	mv	a0,s3
     812:	00000097          	auipc	ra,0x0
     816:	b06080e7          	jalr	-1274(ra) # 318 <pipecmd>
     81a:	89aa                	mv	s3,a0
  return cmd;
     81c:	b7d1                	j	7e0 <parsepipe+0x36>

000000000000081e <parseline>:
{
     81e:	7179                	addi	sp,sp,-48
     820:	f406                	sd	ra,40(sp)
     822:	f022                	sd	s0,32(sp)
     824:	ec26                	sd	s1,24(sp)
     826:	e84a                	sd	s2,16(sp)
     828:	e44e                	sd	s3,8(sp)
     82a:	e052                	sd	s4,0(sp)
     82c:	1800                	addi	s0,sp,48
     82e:	892a                	mv	s2,a0
     830:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     832:	00000097          	auipc	ra,0x0
     836:	f78080e7          	jalr	-136(ra) # 7aa <parsepipe>
     83a:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     83c:	00001a17          	auipc	s4,0x1
     840:	bcca0a13          	addi	s4,s4,-1076 # 1408 <malloc+0x1a8>
     844:	a839                	j	862 <parseline+0x44>
    gettoken(ps, es, 0, 0);
     846:	4681                	li	a3,0
     848:	4601                	li	a2,0
     84a:	85ce                	mv	a1,s3
     84c:	854a                	mv	a0,s2
     84e:	00000097          	auipc	ra,0x0
     852:	b92080e7          	jalr	-1134(ra) # 3e0 <gettoken>
    cmd = backcmd(cmd);
     856:	8526                	mv	a0,s1
     858:	00000097          	auipc	ra,0x0
     85c:	b4c080e7          	jalr	-1204(ra) # 3a4 <backcmd>
     860:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     862:	8652                	mv	a2,s4
     864:	85ce                	mv	a1,s3
     866:	854a                	mv	a0,s2
     868:	00000097          	auipc	ra,0x0
     86c:	cc0080e7          	jalr	-832(ra) # 528 <peek>
     870:	f979                	bnez	a0,846 <parseline+0x28>
  if(peek(ps, es, ";")){
     872:	00001617          	auipc	a2,0x1
     876:	b9e60613          	addi	a2,a2,-1122 # 1410 <malloc+0x1b0>
     87a:	85ce                	mv	a1,s3
     87c:	854a                	mv	a0,s2
     87e:	00000097          	auipc	ra,0x0
     882:	caa080e7          	jalr	-854(ra) # 528 <peek>
     886:	e911                	bnez	a0,89a <parseline+0x7c>
}
     888:	8526                	mv	a0,s1
     88a:	70a2                	ld	ra,40(sp)
     88c:	7402                	ld	s0,32(sp)
     88e:	64e2                	ld	s1,24(sp)
     890:	6942                	ld	s2,16(sp)
     892:	69a2                	ld	s3,8(sp)
     894:	6a02                	ld	s4,0(sp)
     896:	6145                	addi	sp,sp,48
     898:	8082                	ret
    gettoken(ps, es, 0, 0);
     89a:	4681                	li	a3,0
     89c:	4601                	li	a2,0
     89e:	85ce                	mv	a1,s3
     8a0:	854a                	mv	a0,s2
     8a2:	00000097          	auipc	ra,0x0
     8a6:	b3e080e7          	jalr	-1218(ra) # 3e0 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     8aa:	85ce                	mv	a1,s3
     8ac:	854a                	mv	a0,s2
     8ae:	00000097          	auipc	ra,0x0
     8b2:	f70080e7          	jalr	-144(ra) # 81e <parseline>
     8b6:	85aa                	mv	a1,a0
     8b8:	8526                	mv	a0,s1
     8ba:	00000097          	auipc	ra,0x0
     8be:	aa4080e7          	jalr	-1372(ra) # 35e <listcmd>
     8c2:	84aa                	mv	s1,a0
  return cmd;
     8c4:	b7d1                	j	888 <parseline+0x6a>

00000000000008c6 <parseblock>:
{
     8c6:	7179                	addi	sp,sp,-48
     8c8:	f406                	sd	ra,40(sp)
     8ca:	f022                	sd	s0,32(sp)
     8cc:	ec26                	sd	s1,24(sp)
     8ce:	e84a                	sd	s2,16(sp)
     8d0:	e44e                	sd	s3,8(sp)
     8d2:	1800                	addi	s0,sp,48
     8d4:	84aa                	mv	s1,a0
     8d6:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     8d8:	00001617          	auipc	a2,0x1
     8dc:	b0060613          	addi	a2,a2,-1280 # 13d8 <malloc+0x178>
     8e0:	00000097          	auipc	ra,0x0
     8e4:	c48080e7          	jalr	-952(ra) # 528 <peek>
     8e8:	c12d                	beqz	a0,94a <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     8ea:	4681                	li	a3,0
     8ec:	4601                	li	a2,0
     8ee:	85ca                	mv	a1,s2
     8f0:	8526                	mv	a0,s1
     8f2:	00000097          	auipc	ra,0x0
     8f6:	aee080e7          	jalr	-1298(ra) # 3e0 <gettoken>
  cmd = parseline(ps, es);
     8fa:	85ca                	mv	a1,s2
     8fc:	8526                	mv	a0,s1
     8fe:	00000097          	auipc	ra,0x0
     902:	f20080e7          	jalr	-224(ra) # 81e <parseline>
     906:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     908:	00001617          	auipc	a2,0x1
     90c:	b2060613          	addi	a2,a2,-1248 # 1428 <malloc+0x1c8>
     910:	85ca                	mv	a1,s2
     912:	8526                	mv	a0,s1
     914:	00000097          	auipc	ra,0x0
     918:	c14080e7          	jalr	-1004(ra) # 528 <peek>
     91c:	cd1d                	beqz	a0,95a <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     91e:	4681                	li	a3,0
     920:	4601                	li	a2,0
     922:	85ca                	mv	a1,s2
     924:	8526                	mv	a0,s1
     926:	00000097          	auipc	ra,0x0
     92a:	aba080e7          	jalr	-1350(ra) # 3e0 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     92e:	864a                	mv	a2,s2
     930:	85a6                	mv	a1,s1
     932:	854e                	mv	a0,s3
     934:	00000097          	auipc	ra,0x0
     938:	c60080e7          	jalr	-928(ra) # 594 <parseredirs>
}
     93c:	70a2                	ld	ra,40(sp)
     93e:	7402                	ld	s0,32(sp)
     940:	64e2                	ld	s1,24(sp)
     942:	6942                	ld	s2,16(sp)
     944:	69a2                	ld	s3,8(sp)
     946:	6145                	addi	sp,sp,48
     948:	8082                	ret
    panic("parseblock");
     94a:	00001517          	auipc	a0,0x1
     94e:	ace50513          	addi	a0,a0,-1330 # 1418 <malloc+0x1b8>
     952:	fffff097          	auipc	ra,0xfffff
     956:	704080e7          	jalr	1796(ra) # 56 <panic>
    panic("syntax - missing )");
     95a:	00001517          	auipc	a0,0x1
     95e:	ad650513          	addi	a0,a0,-1322 # 1430 <malloc+0x1d0>
     962:	fffff097          	auipc	ra,0xfffff
     966:	6f4080e7          	jalr	1780(ra) # 56 <panic>

000000000000096a <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     96a:	1101                	addi	sp,sp,-32
     96c:	ec06                	sd	ra,24(sp)
     96e:	e822                	sd	s0,16(sp)
     970:	e426                	sd	s1,8(sp)
     972:	1000                	addi	s0,sp,32
     974:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     976:	c521                	beqz	a0,9be <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     978:	4118                	lw	a4,0(a0)
     97a:	4795                	li	a5,5
     97c:	04e7e163          	bltu	a5,a4,9be <nulterminate+0x54>
     980:	00056783          	lwu	a5,0(a0)
     984:	078a                	slli	a5,a5,0x2
     986:	00001717          	auipc	a4,0x1
     98a:	b0a70713          	addi	a4,a4,-1270 # 1490 <malloc+0x230>
     98e:	97ba                	add	a5,a5,a4
     990:	439c                	lw	a5,0(a5)
     992:	97ba                	add	a5,a5,a4
     994:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     996:	651c                	ld	a5,8(a0)
     998:	c39d                	beqz	a5,9be <nulterminate+0x54>
     99a:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     99e:	67b8                	ld	a4,72(a5)
     9a0:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     9a4:	07a1                	addi	a5,a5,8
     9a6:	ff87b703          	ld	a4,-8(a5)
     9aa:	fb75                	bnez	a4,99e <nulterminate+0x34>
     9ac:	a809                	j	9be <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     9ae:	6508                	ld	a0,8(a0)
     9b0:	00000097          	auipc	ra,0x0
     9b4:	fba080e7          	jalr	-70(ra) # 96a <nulterminate>
    *rcmd->efile = 0;
     9b8:	6c9c                	ld	a5,24(s1)
     9ba:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     9be:	8526                	mv	a0,s1
     9c0:	60e2                	ld	ra,24(sp)
     9c2:	6442                	ld	s0,16(sp)
     9c4:	64a2                	ld	s1,8(sp)
     9c6:	6105                	addi	sp,sp,32
     9c8:	8082                	ret
    nulterminate(pcmd->left);
     9ca:	6508                	ld	a0,8(a0)
     9cc:	00000097          	auipc	ra,0x0
     9d0:	f9e080e7          	jalr	-98(ra) # 96a <nulterminate>
    nulterminate(pcmd->right);
     9d4:	6888                	ld	a0,16(s1)
     9d6:	00000097          	auipc	ra,0x0
     9da:	f94080e7          	jalr	-108(ra) # 96a <nulterminate>
    break;
     9de:	b7c5                	j	9be <nulterminate+0x54>
    nulterminate(lcmd->left);
     9e0:	6508                	ld	a0,8(a0)
     9e2:	00000097          	auipc	ra,0x0
     9e6:	f88080e7          	jalr	-120(ra) # 96a <nulterminate>
    nulterminate(lcmd->right);
     9ea:	6888                	ld	a0,16(s1)
     9ec:	00000097          	auipc	ra,0x0
     9f0:	f7e080e7          	jalr	-130(ra) # 96a <nulterminate>
    break;
     9f4:	b7e9                	j	9be <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     9f6:	6508                	ld	a0,8(a0)
     9f8:	00000097          	auipc	ra,0x0
     9fc:	f72080e7          	jalr	-142(ra) # 96a <nulterminate>
    break;
     a00:	bf7d                	j	9be <nulterminate+0x54>

0000000000000a02 <parsecmd>:
{
     a02:	7139                	addi	sp,sp,-64
     a04:	fc06                	sd	ra,56(sp)
     a06:	f822                	sd	s0,48(sp)
     a08:	f426                	sd	s1,40(sp)
     a0a:	f04a                	sd	s2,32(sp)
     a0c:	ec4e                	sd	s3,24(sp)
     a0e:	0080                	addi	s0,sp,64
     a10:	fca43423          	sd	a0,-56(s0)
  es = s + strlen(s);
     a14:	84aa                	mv	s1,a0
     a16:	00000097          	auipc	ra,0x0
     a1a:	1e2080e7          	jalr	482(ra) # bf8 <strlen>
     a1e:	1502                	slli	a0,a0,0x20
     a20:	9101                	srli	a0,a0,0x20
     a22:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     a24:	fc840913          	addi	s2,s0,-56
     a28:	85a6                	mv	a1,s1
     a2a:	854a                	mv	a0,s2
     a2c:	00000097          	auipc	ra,0x0
     a30:	df2080e7          	jalr	-526(ra) # 81e <parseline>
     a34:	89aa                	mv	s3,a0
  peek(&s, es, "");
     a36:	00001617          	auipc	a2,0x1
     a3a:	93260613          	addi	a2,a2,-1742 # 1368 <malloc+0x108>
     a3e:	85a6                	mv	a1,s1
     a40:	854a                	mv	a0,s2
     a42:	00000097          	auipc	ra,0x0
     a46:	ae6080e7          	jalr	-1306(ra) # 528 <peek>
  if(s != es){
     a4a:	fc843603          	ld	a2,-56(s0)
     a4e:	00961f63          	bne	a2,s1,a6c <parsecmd+0x6a>
  nulterminate(cmd);
     a52:	854e                	mv	a0,s3
     a54:	00000097          	auipc	ra,0x0
     a58:	f16080e7          	jalr	-234(ra) # 96a <nulterminate>
}
     a5c:	854e                	mv	a0,s3
     a5e:	70e2                	ld	ra,56(sp)
     a60:	7442                	ld	s0,48(sp)
     a62:	74a2                	ld	s1,40(sp)
     a64:	7902                	ld	s2,32(sp)
     a66:	69e2                	ld	s3,24(sp)
     a68:	6121                	addi	sp,sp,64
     a6a:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     a6c:	00001597          	auipc	a1,0x1
     a70:	9dc58593          	addi	a1,a1,-1572 # 1448 <malloc+0x1e8>
     a74:	4509                	li	a0,2
     a76:	00000097          	auipc	ra,0x0
     a7a:	700080e7          	jalr	1792(ra) # 1176 <fprintf>
    panic("syntax");
     a7e:	00001517          	auipc	a0,0x1
     a82:	96250513          	addi	a0,a0,-1694 # 13e0 <malloc+0x180>
     a86:	fffff097          	auipc	ra,0xfffff
     a8a:	5d0080e7          	jalr	1488(ra) # 56 <panic>

0000000000000a8e <main>:
{
     a8e:	7179                	addi	sp,sp,-48
     a90:	f406                	sd	ra,40(sp)
     a92:	f022                	sd	s0,32(sp)
     a94:	ec26                	sd	s1,24(sp)
     a96:	e84a                	sd	s2,16(sp)
     a98:	e44e                	sd	s3,8(sp)
     a9a:	e052                	sd	s4,0(sp)
     a9c:	1800                	addi	s0,sp,48
  while((fd = open("console", O_RDWR)) >= 0){
     a9e:	4489                	li	s1,2
     aa0:	00001917          	auipc	s2,0x1
     aa4:	9b890913          	addi	s2,s2,-1608 # 1458 <malloc+0x1f8>
     aa8:	85a6                	mv	a1,s1
     aaa:	854a                	mv	a0,s2
     aac:	00000097          	auipc	ra,0x0
     ab0:	3ca080e7          	jalr	970(ra) # e76 <open>
     ab4:	00054863          	bltz	a0,ac4 <main+0x36>
    if(fd >= 3){
     ab8:	fea4d8e3          	bge	s1,a0,aa8 <main+0x1a>
      close(fd);
     abc:	00000097          	auipc	ra,0x0
     ac0:	3a2080e7          	jalr	930(ra) # e5e <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     ac4:	06400913          	li	s2,100
     ac8:	00001497          	auipc	s1,0x1
     acc:	55848493          	addi	s1,s1,1368 # 2020 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     ad0:	06300993          	li	s3,99
     ad4:	02000a13          	li	s4,32
     ad8:	a819                	j	aee <main+0x60>
    if(fork1() == 0)
     ada:	fffff097          	auipc	ra,0xfffff
     ade:	5a2080e7          	jalr	1442(ra) # 7c <fork1>
     ae2:	c549                	beqz	a0,b6c <main+0xde>
    wait(0);
     ae4:	4501                	li	a0,0
     ae6:	00000097          	auipc	ra,0x0
     aea:	358080e7          	jalr	856(ra) # e3e <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     aee:	85ca                	mv	a1,s2
     af0:	8526                	mv	a0,s1
     af2:	fffff097          	auipc	ra,0xfffff
     af6:	50e080e7          	jalr	1294(ra) # 0 <getcmd>
     afa:	08054563          	bltz	a0,b84 <main+0xf6>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     afe:	0004c783          	lbu	a5,0(s1)
     b02:	fd379ce3          	bne	a5,s3,ada <main+0x4c>
     b06:	0014c783          	lbu	a5,1(s1)
     b0a:	fd2798e3          	bne	a5,s2,ada <main+0x4c>
     b0e:	0024c783          	lbu	a5,2(s1)
     b12:	fd4794e3          	bne	a5,s4,ada <main+0x4c>
      buf[strlen(buf)-1] = 0;  // chop \n
     b16:	00001517          	auipc	a0,0x1
     b1a:	50a50513          	addi	a0,a0,1290 # 2020 <buf.0>
     b1e:	00000097          	auipc	ra,0x0
     b22:	0da080e7          	jalr	218(ra) # bf8 <strlen>
     b26:	fff5079b          	addiw	a5,a0,-1
     b2a:	1782                	slli	a5,a5,0x20
     b2c:	9381                	srli	a5,a5,0x20
     b2e:	00001717          	auipc	a4,0x1
     b32:	4f270713          	addi	a4,a4,1266 # 2020 <buf.0>
     b36:	97ba                	add	a5,a5,a4
     b38:	00078023          	sb	zero,0(a5)
      if(chdir(buf+3) < 0)
     b3c:	00001517          	auipc	a0,0x1
     b40:	4e750513          	addi	a0,a0,1255 # 2023 <buf.0+0x3>
     b44:	00000097          	auipc	ra,0x0
     b48:	362080e7          	jalr	866(ra) # ea6 <chdir>
     b4c:	fa0551e3          	bgez	a0,aee <main+0x60>
        fprintf(2, "cannot cd %s\n", buf+3);
     b50:	00001617          	auipc	a2,0x1
     b54:	4d360613          	addi	a2,a2,1235 # 2023 <buf.0+0x3>
     b58:	00001597          	auipc	a1,0x1
     b5c:	90858593          	addi	a1,a1,-1784 # 1460 <malloc+0x200>
     b60:	4509                	li	a0,2
     b62:	00000097          	auipc	ra,0x0
     b66:	614080e7          	jalr	1556(ra) # 1176 <fprintf>
     b6a:	b751                	j	aee <main+0x60>
      runcmd(parsecmd(buf));
     b6c:	00001517          	auipc	a0,0x1
     b70:	4b450513          	addi	a0,a0,1204 # 2020 <buf.0>
     b74:	00000097          	auipc	ra,0x0
     b78:	e8e080e7          	jalr	-370(ra) # a02 <parsecmd>
     b7c:	fffff097          	auipc	ra,0xfffff
     b80:	52e080e7          	jalr	1326(ra) # aa <runcmd>
  exit(0);
     b84:	4501                	li	a0,0
     b86:	00000097          	auipc	ra,0x0
     b8a:	2b0080e7          	jalr	688(ra) # e36 <exit>

0000000000000b8e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     b8e:	1141                	addi	sp,sp,-16
     b90:	e406                	sd	ra,8(sp)
     b92:	e022                	sd	s0,0(sp)
     b94:	0800                	addi	s0,sp,16
  extern int main();
  main();
     b96:	00000097          	auipc	ra,0x0
     b9a:	ef8080e7          	jalr	-264(ra) # a8e <main>
  exit(0);
     b9e:	4501                	li	a0,0
     ba0:	00000097          	auipc	ra,0x0
     ba4:	296080e7          	jalr	662(ra) # e36 <exit>

0000000000000ba8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     ba8:	1141                	addi	sp,sp,-16
     baa:	e406                	sd	ra,8(sp)
     bac:	e022                	sd	s0,0(sp)
     bae:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bb0:	87aa                	mv	a5,a0
     bb2:	0585                	addi	a1,a1,1
     bb4:	0785                	addi	a5,a5,1
     bb6:	fff5c703          	lbu	a4,-1(a1)
     bba:	fee78fa3          	sb	a4,-1(a5)
     bbe:	fb75                	bnez	a4,bb2 <strcpy+0xa>
    ;
  return os;
}
     bc0:	60a2                	ld	ra,8(sp)
     bc2:	6402                	ld	s0,0(sp)
     bc4:	0141                	addi	sp,sp,16
     bc6:	8082                	ret

0000000000000bc8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     bc8:	1141                	addi	sp,sp,-16
     bca:	e406                	sd	ra,8(sp)
     bcc:	e022                	sd	s0,0(sp)
     bce:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     bd0:	00054783          	lbu	a5,0(a0)
     bd4:	cb91                	beqz	a5,be8 <strcmp+0x20>
     bd6:	0005c703          	lbu	a4,0(a1)
     bda:	00f71763          	bne	a4,a5,be8 <strcmp+0x20>
    p++, q++;
     bde:	0505                	addi	a0,a0,1
     be0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     be2:	00054783          	lbu	a5,0(a0)
     be6:	fbe5                	bnez	a5,bd6 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
     be8:	0005c503          	lbu	a0,0(a1)
}
     bec:	40a7853b          	subw	a0,a5,a0
     bf0:	60a2                	ld	ra,8(sp)
     bf2:	6402                	ld	s0,0(sp)
     bf4:	0141                	addi	sp,sp,16
     bf6:	8082                	ret

0000000000000bf8 <strlen>:

uint
strlen(const char *s)
{
     bf8:	1141                	addi	sp,sp,-16
     bfa:	e406                	sd	ra,8(sp)
     bfc:	e022                	sd	s0,0(sp)
     bfe:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c00:	00054783          	lbu	a5,0(a0)
     c04:	cf91                	beqz	a5,c20 <strlen+0x28>
     c06:	00150793          	addi	a5,a0,1
     c0a:	86be                	mv	a3,a5
     c0c:	0785                	addi	a5,a5,1
     c0e:	fff7c703          	lbu	a4,-1(a5)
     c12:	ff65                	bnez	a4,c0a <strlen+0x12>
     c14:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
     c18:	60a2                	ld	ra,8(sp)
     c1a:	6402                	ld	s0,0(sp)
     c1c:	0141                	addi	sp,sp,16
     c1e:	8082                	ret
  for(n = 0; s[n]; n++)
     c20:	4501                	li	a0,0
     c22:	bfdd                	j	c18 <strlen+0x20>

0000000000000c24 <memset>:

void*
memset(void *dst, int c, uint n)
{
     c24:	1141                	addi	sp,sp,-16
     c26:	e406                	sd	ra,8(sp)
     c28:	e022                	sd	s0,0(sp)
     c2a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c2c:	ca19                	beqz	a2,c42 <memset+0x1e>
     c2e:	87aa                	mv	a5,a0
     c30:	1602                	slli	a2,a2,0x20
     c32:	9201                	srli	a2,a2,0x20
     c34:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c38:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c3c:	0785                	addi	a5,a5,1
     c3e:	fee79de3          	bne	a5,a4,c38 <memset+0x14>
  }
  return dst;
}
     c42:	60a2                	ld	ra,8(sp)
     c44:	6402                	ld	s0,0(sp)
     c46:	0141                	addi	sp,sp,16
     c48:	8082                	ret

0000000000000c4a <strchr>:

char*
strchr(const char *s, char c)
{
     c4a:	1141                	addi	sp,sp,-16
     c4c:	e406                	sd	ra,8(sp)
     c4e:	e022                	sd	s0,0(sp)
     c50:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c52:	00054783          	lbu	a5,0(a0)
     c56:	cf81                	beqz	a5,c6e <strchr+0x24>
    if(*s == c)
     c58:	00f58763          	beq	a1,a5,c66 <strchr+0x1c>
  for(; *s; s++)
     c5c:	0505                	addi	a0,a0,1
     c5e:	00054783          	lbu	a5,0(a0)
     c62:	fbfd                	bnez	a5,c58 <strchr+0xe>
      return (char*)s;
  return 0;
     c64:	4501                	li	a0,0
}
     c66:	60a2                	ld	ra,8(sp)
     c68:	6402                	ld	s0,0(sp)
     c6a:	0141                	addi	sp,sp,16
     c6c:	8082                	ret
  return 0;
     c6e:	4501                	li	a0,0
     c70:	bfdd                	j	c66 <strchr+0x1c>

0000000000000c72 <gets>:

char*
gets(char *buf, int max)
{
     c72:	711d                	addi	sp,sp,-96
     c74:	ec86                	sd	ra,88(sp)
     c76:	e8a2                	sd	s0,80(sp)
     c78:	e4a6                	sd	s1,72(sp)
     c7a:	e0ca                	sd	s2,64(sp)
     c7c:	fc4e                	sd	s3,56(sp)
     c7e:	f852                	sd	s4,48(sp)
     c80:	f456                	sd	s5,40(sp)
     c82:	f05a                	sd	s6,32(sp)
     c84:	ec5e                	sd	s7,24(sp)
     c86:	e862                	sd	s8,16(sp)
     c88:	1080                	addi	s0,sp,96
     c8a:	8baa                	mv	s7,a0
     c8c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     c8e:	892a                	mv	s2,a0
     c90:	4481                	li	s1,0
    cc = read(0, &c, 1);
     c92:	faf40b13          	addi	s6,s0,-81
     c96:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
     c98:	8c26                	mv	s8,s1
     c9a:	0014899b          	addiw	s3,s1,1
     c9e:	84ce                	mv	s1,s3
     ca0:	0349d663          	bge	s3,s4,ccc <gets+0x5a>
    cc = read(0, &c, 1);
     ca4:	8656                	mv	a2,s5
     ca6:	85da                	mv	a1,s6
     ca8:	4501                	li	a0,0
     caa:	00000097          	auipc	ra,0x0
     cae:	1a4080e7          	jalr	420(ra) # e4e <read>
    if(cc < 1)
     cb2:	00a05d63          	blez	a0,ccc <gets+0x5a>
      break;
    buf[i++] = c;
     cb6:	faf44783          	lbu	a5,-81(s0)
     cba:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     cbe:	0905                	addi	s2,s2,1
     cc0:	ff678713          	addi	a4,a5,-10
     cc4:	c319                	beqz	a4,cca <gets+0x58>
     cc6:	17cd                	addi	a5,a5,-13
     cc8:	fbe1                	bnez	a5,c98 <gets+0x26>
    buf[i++] = c;
     cca:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
     ccc:	9c5e                	add	s8,s8,s7
     cce:	000c0023          	sb	zero,0(s8)
  return buf;
}
     cd2:	855e                	mv	a0,s7
     cd4:	60e6                	ld	ra,88(sp)
     cd6:	6446                	ld	s0,80(sp)
     cd8:	64a6                	ld	s1,72(sp)
     cda:	6906                	ld	s2,64(sp)
     cdc:	79e2                	ld	s3,56(sp)
     cde:	7a42                	ld	s4,48(sp)
     ce0:	7aa2                	ld	s5,40(sp)
     ce2:	7b02                	ld	s6,32(sp)
     ce4:	6be2                	ld	s7,24(sp)
     ce6:	6c42                	ld	s8,16(sp)
     ce8:	6125                	addi	sp,sp,96
     cea:	8082                	ret

0000000000000cec <stat>:

int
stat(const char *n, struct stat *st)
{
     cec:	1101                	addi	sp,sp,-32
     cee:	ec06                	sd	ra,24(sp)
     cf0:	e822                	sd	s0,16(sp)
     cf2:	e04a                	sd	s2,0(sp)
     cf4:	1000                	addi	s0,sp,32
     cf6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     cf8:	4581                	li	a1,0
     cfa:	00000097          	auipc	ra,0x0
     cfe:	17c080e7          	jalr	380(ra) # e76 <open>
  if(fd < 0)
     d02:	02054663          	bltz	a0,d2e <stat+0x42>
     d06:	e426                	sd	s1,8(sp)
     d08:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d0a:	85ca                	mv	a1,s2
     d0c:	00000097          	auipc	ra,0x0
     d10:	182080e7          	jalr	386(ra) # e8e <fstat>
     d14:	892a                	mv	s2,a0
  close(fd);
     d16:	8526                	mv	a0,s1
     d18:	00000097          	auipc	ra,0x0
     d1c:	146080e7          	jalr	326(ra) # e5e <close>
  return r;
     d20:	64a2                	ld	s1,8(sp)
}
     d22:	854a                	mv	a0,s2
     d24:	60e2                	ld	ra,24(sp)
     d26:	6442                	ld	s0,16(sp)
     d28:	6902                	ld	s2,0(sp)
     d2a:	6105                	addi	sp,sp,32
     d2c:	8082                	ret
    return -1;
     d2e:	57fd                	li	a5,-1
     d30:	893e                	mv	s2,a5
     d32:	bfc5                	j	d22 <stat+0x36>

0000000000000d34 <atoi>:

int
atoi(const char *s)
{
     d34:	1141                	addi	sp,sp,-16
     d36:	e406                	sd	ra,8(sp)
     d38:	e022                	sd	s0,0(sp)
     d3a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d3c:	00054683          	lbu	a3,0(a0)
     d40:	fd06879b          	addiw	a5,a3,-48
     d44:	0ff7f793          	zext.b	a5,a5
     d48:	4625                	li	a2,9
     d4a:	02f66963          	bltu	a2,a5,d7c <atoi+0x48>
     d4e:	872a                	mv	a4,a0
  n = 0;
     d50:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     d52:	0705                	addi	a4,a4,1
     d54:	0025179b          	slliw	a5,a0,0x2
     d58:	9fa9                	addw	a5,a5,a0
     d5a:	0017979b          	slliw	a5,a5,0x1
     d5e:	9fb5                	addw	a5,a5,a3
     d60:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d64:	00074683          	lbu	a3,0(a4)
     d68:	fd06879b          	addiw	a5,a3,-48
     d6c:	0ff7f793          	zext.b	a5,a5
     d70:	fef671e3          	bgeu	a2,a5,d52 <atoi+0x1e>
  return n;
}
     d74:	60a2                	ld	ra,8(sp)
     d76:	6402                	ld	s0,0(sp)
     d78:	0141                	addi	sp,sp,16
     d7a:	8082                	ret
  n = 0;
     d7c:	4501                	li	a0,0
     d7e:	bfdd                	j	d74 <atoi+0x40>

0000000000000d80 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     d80:	1141                	addi	sp,sp,-16
     d82:	e406                	sd	ra,8(sp)
     d84:	e022                	sd	s0,0(sp)
     d86:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     d88:	02b57563          	bgeu	a0,a1,db2 <memmove+0x32>
    while(n-- > 0)
     d8c:	00c05f63          	blez	a2,daa <memmove+0x2a>
     d90:	1602                	slli	a2,a2,0x20
     d92:	9201                	srli	a2,a2,0x20
     d94:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     d98:	872a                	mv	a4,a0
      *dst++ = *src++;
     d9a:	0585                	addi	a1,a1,1
     d9c:	0705                	addi	a4,a4,1
     d9e:	fff5c683          	lbu	a3,-1(a1)
     da2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     da6:	fee79ae3          	bne	a5,a4,d9a <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     daa:	60a2                	ld	ra,8(sp)
     dac:	6402                	ld	s0,0(sp)
     dae:	0141                	addi	sp,sp,16
     db0:	8082                	ret
    while(n-- > 0)
     db2:	fec05ce3          	blez	a2,daa <memmove+0x2a>
    dst += n;
     db6:	00c50733          	add	a4,a0,a2
    src += n;
     dba:	95b2                	add	a1,a1,a2
     dbc:	fff6079b          	addiw	a5,a2,-1
     dc0:	1782                	slli	a5,a5,0x20
     dc2:	9381                	srli	a5,a5,0x20
     dc4:	fff7c793          	not	a5,a5
     dc8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     dca:	15fd                	addi	a1,a1,-1
     dcc:	177d                	addi	a4,a4,-1
     dce:	0005c683          	lbu	a3,0(a1)
     dd2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     dd6:	fef71ae3          	bne	a4,a5,dca <memmove+0x4a>
     dda:	bfc1                	j	daa <memmove+0x2a>

0000000000000ddc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     ddc:	1141                	addi	sp,sp,-16
     dde:	e406                	sd	ra,8(sp)
     de0:	e022                	sd	s0,0(sp)
     de2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     de4:	c61d                	beqz	a2,e12 <memcmp+0x36>
     de6:	1602                	slli	a2,a2,0x20
     de8:	9201                	srli	a2,a2,0x20
     dea:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
     dee:	00054783          	lbu	a5,0(a0)
     df2:	0005c703          	lbu	a4,0(a1)
     df6:	00e79863          	bne	a5,a4,e06 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
     dfa:	0505                	addi	a0,a0,1
    p2++;
     dfc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     dfe:	fed518e3          	bne	a0,a3,dee <memcmp+0x12>
  }
  return 0;
     e02:	4501                	li	a0,0
     e04:	a019                	j	e0a <memcmp+0x2e>
      return *p1 - *p2;
     e06:	40e7853b          	subw	a0,a5,a4
}
     e0a:	60a2                	ld	ra,8(sp)
     e0c:	6402                	ld	s0,0(sp)
     e0e:	0141                	addi	sp,sp,16
     e10:	8082                	ret
  return 0;
     e12:	4501                	li	a0,0
     e14:	bfdd                	j	e0a <memcmp+0x2e>

0000000000000e16 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e16:	1141                	addi	sp,sp,-16
     e18:	e406                	sd	ra,8(sp)
     e1a:	e022                	sd	s0,0(sp)
     e1c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e1e:	00000097          	auipc	ra,0x0
     e22:	f62080e7          	jalr	-158(ra) # d80 <memmove>
}
     e26:	60a2                	ld	ra,8(sp)
     e28:	6402                	ld	s0,0(sp)
     e2a:	0141                	addi	sp,sp,16
     e2c:	8082                	ret

0000000000000e2e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e2e:	4885                	li	a7,1
 ecall
     e30:	00000073          	ecall
 ret
     e34:	8082                	ret

0000000000000e36 <exit>:
.global exit
exit:
 li a7, SYS_exit
     e36:	4889                	li	a7,2
 ecall
     e38:	00000073          	ecall
 ret
     e3c:	8082                	ret

0000000000000e3e <wait>:
.global wait
wait:
 li a7, SYS_wait
     e3e:	488d                	li	a7,3
 ecall
     e40:	00000073          	ecall
 ret
     e44:	8082                	ret

0000000000000e46 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e46:	4891                	li	a7,4
 ecall
     e48:	00000073          	ecall
 ret
     e4c:	8082                	ret

0000000000000e4e <read>:
.global read
read:
 li a7, SYS_read
     e4e:	4895                	li	a7,5
 ecall
     e50:	00000073          	ecall
 ret
     e54:	8082                	ret

0000000000000e56 <write>:
.global write
write:
 li a7, SYS_write
     e56:	48c1                	li	a7,16
 ecall
     e58:	00000073          	ecall
 ret
     e5c:	8082                	ret

0000000000000e5e <close>:
.global close
close:
 li a7, SYS_close
     e5e:	48d5                	li	a7,21
 ecall
     e60:	00000073          	ecall
 ret
     e64:	8082                	ret

0000000000000e66 <kill>:
.global kill
kill:
 li a7, SYS_kill
     e66:	4899                	li	a7,6
 ecall
     e68:	00000073          	ecall
 ret
     e6c:	8082                	ret

0000000000000e6e <exec>:
.global exec
exec:
 li a7, SYS_exec
     e6e:	489d                	li	a7,7
 ecall
     e70:	00000073          	ecall
 ret
     e74:	8082                	ret

0000000000000e76 <open>:
.global open
open:
 li a7, SYS_open
     e76:	48bd                	li	a7,15
 ecall
     e78:	00000073          	ecall
 ret
     e7c:	8082                	ret

0000000000000e7e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     e7e:	48c5                	li	a7,17
 ecall
     e80:	00000073          	ecall
 ret
     e84:	8082                	ret

0000000000000e86 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     e86:	48c9                	li	a7,18
 ecall
     e88:	00000073          	ecall
 ret
     e8c:	8082                	ret

0000000000000e8e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     e8e:	48a1                	li	a7,8
 ecall
     e90:	00000073          	ecall
 ret
     e94:	8082                	ret

0000000000000e96 <link>:
.global link
link:
 li a7, SYS_link
     e96:	48cd                	li	a7,19
 ecall
     e98:	00000073          	ecall
 ret
     e9c:	8082                	ret

0000000000000e9e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     e9e:	48d1                	li	a7,20
 ecall
     ea0:	00000073          	ecall
 ret
     ea4:	8082                	ret

0000000000000ea6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     ea6:	48a5                	li	a7,9
 ecall
     ea8:	00000073          	ecall
 ret
     eac:	8082                	ret

0000000000000eae <dup>:
.global dup
dup:
 li a7, SYS_dup
     eae:	48a9                	li	a7,10
 ecall
     eb0:	00000073          	ecall
 ret
     eb4:	8082                	ret

0000000000000eb6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     eb6:	48ad                	li	a7,11
 ecall
     eb8:	00000073          	ecall
 ret
     ebc:	8082                	ret

0000000000000ebe <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     ebe:	48b1                	li	a7,12
 ecall
     ec0:	00000073          	ecall
 ret
     ec4:	8082                	ret

0000000000000ec6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     ec6:	48b5                	li	a7,13
 ecall
     ec8:	00000073          	ecall
 ret
     ecc:	8082                	ret

0000000000000ece <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     ece:	48b9                	li	a7,14
 ecall
     ed0:	00000073          	ecall
 ret
     ed4:	8082                	ret

0000000000000ed6 <nanotime>:
.global nanotime
nanotime:
 li a7, SYS_nanotime
     ed6:	48d9                	li	a7,22
 ecall
     ed8:	00000073          	ecall
 ret
     edc:	8082                	ret

0000000000000ede <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     ede:	1101                	addi	sp,sp,-32
     ee0:	ec06                	sd	ra,24(sp)
     ee2:	e822                	sd	s0,16(sp)
     ee4:	1000                	addi	s0,sp,32
     ee6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     eea:	4605                	li	a2,1
     eec:	fef40593          	addi	a1,s0,-17
     ef0:	00000097          	auipc	ra,0x0
     ef4:	f66080e7          	jalr	-154(ra) # e56 <write>
}
     ef8:	60e2                	ld	ra,24(sp)
     efa:	6442                	ld	s0,16(sp)
     efc:	6105                	addi	sp,sp,32
     efe:	8082                	ret

0000000000000f00 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f00:	7139                	addi	sp,sp,-64
     f02:	fc06                	sd	ra,56(sp)
     f04:	f822                	sd	s0,48(sp)
     f06:	f04a                	sd	s2,32(sp)
     f08:	ec4e                	sd	s3,24(sp)
     f0a:	0080                	addi	s0,sp,64
     f0c:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f0e:	cad9                	beqz	a3,fa4 <printint+0xa4>
     f10:	01f5d79b          	srliw	a5,a1,0x1f
     f14:	cbc1                	beqz	a5,fa4 <printint+0xa4>
    neg = 1;
    x = -xx;
     f16:	40b005bb          	negw	a1,a1
    neg = 1;
     f1a:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
     f1c:	fc040993          	addi	s3,s0,-64
  neg = 0;
     f20:	86ce                	mv	a3,s3
  i = 0;
     f22:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f24:	00000817          	auipc	a6,0x0
     f28:	5dc80813          	addi	a6,a6,1500 # 1500 <digits>
     f2c:	88ba                	mv	a7,a4
     f2e:	0017051b          	addiw	a0,a4,1
     f32:	872a                	mv	a4,a0
     f34:	02c5f7bb          	remuw	a5,a1,a2
     f38:	1782                	slli	a5,a5,0x20
     f3a:	9381                	srli	a5,a5,0x20
     f3c:	97c2                	add	a5,a5,a6
     f3e:	0007c783          	lbu	a5,0(a5)
     f42:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f46:	87ae                	mv	a5,a1
     f48:	02c5d5bb          	divuw	a1,a1,a2
     f4c:	0685                	addi	a3,a3,1
     f4e:	fcc7ffe3          	bgeu	a5,a2,f2c <printint+0x2c>
  if(neg)
     f52:	00030c63          	beqz	t1,f6a <printint+0x6a>
    buf[i++] = '-';
     f56:	fd050793          	addi	a5,a0,-48
     f5a:	00878533          	add	a0,a5,s0
     f5e:	02d00793          	li	a5,45
     f62:	fef50823          	sb	a5,-16(a0)
     f66:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
     f6a:	02e05763          	blez	a4,f98 <printint+0x98>
     f6e:	f426                	sd	s1,40(sp)
     f70:	377d                	addiw	a4,a4,-1
     f72:	00e984b3          	add	s1,s3,a4
     f76:	19fd                	addi	s3,s3,-1
     f78:	99ba                	add	s3,s3,a4
     f7a:	1702                	slli	a4,a4,0x20
     f7c:	9301                	srli	a4,a4,0x20
     f7e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     f82:	0004c583          	lbu	a1,0(s1)
     f86:	854a                	mv	a0,s2
     f88:	00000097          	auipc	ra,0x0
     f8c:	f56080e7          	jalr	-170(ra) # ede <putc>
  while(--i >= 0)
     f90:	14fd                	addi	s1,s1,-1
     f92:	ff3498e3          	bne	s1,s3,f82 <printint+0x82>
     f96:	74a2                	ld	s1,40(sp)
}
     f98:	70e2                	ld	ra,56(sp)
     f9a:	7442                	ld	s0,48(sp)
     f9c:	7902                	ld	s2,32(sp)
     f9e:	69e2                	ld	s3,24(sp)
     fa0:	6121                	addi	sp,sp,64
     fa2:	8082                	ret
  neg = 0;
     fa4:	4301                	li	t1,0
     fa6:	bf9d                	j	f1c <printint+0x1c>

0000000000000fa8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     fa8:	715d                	addi	sp,sp,-80
     faa:	e486                	sd	ra,72(sp)
     fac:	e0a2                	sd	s0,64(sp)
     fae:	f84a                	sd	s2,48(sp)
     fb0:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     fb2:	0005c903          	lbu	s2,0(a1)
     fb6:	1a090b63          	beqz	s2,116c <vprintf+0x1c4>
     fba:	fc26                	sd	s1,56(sp)
     fbc:	f44e                	sd	s3,40(sp)
     fbe:	f052                	sd	s4,32(sp)
     fc0:	ec56                	sd	s5,24(sp)
     fc2:	e85a                	sd	s6,16(sp)
     fc4:	e45e                	sd	s7,8(sp)
     fc6:	8aaa                	mv	s5,a0
     fc8:	8bb2                	mv	s7,a2
     fca:	00158493          	addi	s1,a1,1
  state = 0;
     fce:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     fd0:	02500a13          	li	s4,37
     fd4:	4b55                	li	s6,21
     fd6:	a839                	j	ff4 <vprintf+0x4c>
        putc(fd, c);
     fd8:	85ca                	mv	a1,s2
     fda:	8556                	mv	a0,s5
     fdc:	00000097          	auipc	ra,0x0
     fe0:	f02080e7          	jalr	-254(ra) # ede <putc>
     fe4:	a019                	j	fea <vprintf+0x42>
    } else if(state == '%'){
     fe6:	01498d63          	beq	s3,s4,1000 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
     fea:	0485                	addi	s1,s1,1
     fec:	fff4c903          	lbu	s2,-1(s1)
     ff0:	16090863          	beqz	s2,1160 <vprintf+0x1b8>
    if(state == 0){
     ff4:	fe0999e3          	bnez	s3,fe6 <vprintf+0x3e>
      if(c == '%'){
     ff8:	ff4910e3          	bne	s2,s4,fd8 <vprintf+0x30>
        state = '%';
     ffc:	89d2                	mv	s3,s4
     ffe:	b7f5                	j	fea <vprintf+0x42>
      if(c == 'd'){
    1000:	13490563          	beq	s2,s4,112a <vprintf+0x182>
    1004:	f9d9079b          	addiw	a5,s2,-99
    1008:	0ff7f793          	zext.b	a5,a5
    100c:	12fb6863          	bltu	s6,a5,113c <vprintf+0x194>
    1010:	f9d9079b          	addiw	a5,s2,-99
    1014:	0ff7f713          	zext.b	a4,a5
    1018:	12eb6263          	bltu	s6,a4,113c <vprintf+0x194>
    101c:	00271793          	slli	a5,a4,0x2
    1020:	00000717          	auipc	a4,0x0
    1024:	48870713          	addi	a4,a4,1160 # 14a8 <malloc+0x248>
    1028:	97ba                	add	a5,a5,a4
    102a:	439c                	lw	a5,0(a5)
    102c:	97ba                	add	a5,a5,a4
    102e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    1030:	008b8913          	addi	s2,s7,8
    1034:	4685                	li	a3,1
    1036:	4629                	li	a2,10
    1038:	000ba583          	lw	a1,0(s7)
    103c:	8556                	mv	a0,s5
    103e:	00000097          	auipc	ra,0x0
    1042:	ec2080e7          	jalr	-318(ra) # f00 <printint>
    1046:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    1048:	4981                	li	s3,0
    104a:	b745                	j	fea <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
    104c:	008b8913          	addi	s2,s7,8
    1050:	4681                	li	a3,0
    1052:	4629                	li	a2,10
    1054:	000ba583          	lw	a1,0(s7)
    1058:	8556                	mv	a0,s5
    105a:	00000097          	auipc	ra,0x0
    105e:	ea6080e7          	jalr	-346(ra) # f00 <printint>
    1062:	8bca                	mv	s7,s2
      state = 0;
    1064:	4981                	li	s3,0
    1066:	b751                	j	fea <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
    1068:	008b8913          	addi	s2,s7,8
    106c:	4681                	li	a3,0
    106e:	4641                	li	a2,16
    1070:	000ba583          	lw	a1,0(s7)
    1074:	8556                	mv	a0,s5
    1076:	00000097          	auipc	ra,0x0
    107a:	e8a080e7          	jalr	-374(ra) # f00 <printint>
    107e:	8bca                	mv	s7,s2
      state = 0;
    1080:	4981                	li	s3,0
    1082:	b7a5                	j	fea <vprintf+0x42>
    1084:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
    1086:	008b8793          	addi	a5,s7,8
    108a:	8c3e                	mv	s8,a5
    108c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    1090:	03000593          	li	a1,48
    1094:	8556                	mv	a0,s5
    1096:	00000097          	auipc	ra,0x0
    109a:	e48080e7          	jalr	-440(ra) # ede <putc>
  putc(fd, 'x');
    109e:	07800593          	li	a1,120
    10a2:	8556                	mv	a0,s5
    10a4:	00000097          	auipc	ra,0x0
    10a8:	e3a080e7          	jalr	-454(ra) # ede <putc>
    10ac:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10ae:	00000b97          	auipc	s7,0x0
    10b2:	452b8b93          	addi	s7,s7,1106 # 1500 <digits>
    10b6:	03c9d793          	srli	a5,s3,0x3c
    10ba:	97de                	add	a5,a5,s7
    10bc:	0007c583          	lbu	a1,0(a5)
    10c0:	8556                	mv	a0,s5
    10c2:	00000097          	auipc	ra,0x0
    10c6:	e1c080e7          	jalr	-484(ra) # ede <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    10ca:	0992                	slli	s3,s3,0x4
    10cc:	397d                	addiw	s2,s2,-1
    10ce:	fe0914e3          	bnez	s2,10b6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
    10d2:	8be2                	mv	s7,s8
      state = 0;
    10d4:	4981                	li	s3,0
    10d6:	6c02                	ld	s8,0(sp)
    10d8:	bf09                	j	fea <vprintf+0x42>
        s = va_arg(ap, char*);
    10da:	008b8993          	addi	s3,s7,8
    10de:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    10e2:	02090163          	beqz	s2,1104 <vprintf+0x15c>
        while(*s != 0){
    10e6:	00094583          	lbu	a1,0(s2)
    10ea:	c9a5                	beqz	a1,115a <vprintf+0x1b2>
          putc(fd, *s);
    10ec:	8556                	mv	a0,s5
    10ee:	00000097          	auipc	ra,0x0
    10f2:	df0080e7          	jalr	-528(ra) # ede <putc>
          s++;
    10f6:	0905                	addi	s2,s2,1
        while(*s != 0){
    10f8:	00094583          	lbu	a1,0(s2)
    10fc:	f9e5                	bnez	a1,10ec <vprintf+0x144>
        s = va_arg(ap, char*);
    10fe:	8bce                	mv	s7,s3
      state = 0;
    1100:	4981                	li	s3,0
    1102:	b5e5                	j	fea <vprintf+0x42>
          s = "(null)";
    1104:	00000917          	auipc	s2,0x0
    1108:	36c90913          	addi	s2,s2,876 # 1470 <malloc+0x210>
        while(*s != 0){
    110c:	02800593          	li	a1,40
    1110:	bff1                	j	10ec <vprintf+0x144>
        putc(fd, va_arg(ap, uint));
    1112:	008b8913          	addi	s2,s7,8
    1116:	000bc583          	lbu	a1,0(s7)
    111a:	8556                	mv	a0,s5
    111c:	00000097          	auipc	ra,0x0
    1120:	dc2080e7          	jalr	-574(ra) # ede <putc>
    1124:	8bca                	mv	s7,s2
      state = 0;
    1126:	4981                	li	s3,0
    1128:	b5c9                	j	fea <vprintf+0x42>
        putc(fd, c);
    112a:	02500593          	li	a1,37
    112e:	8556                	mv	a0,s5
    1130:	00000097          	auipc	ra,0x0
    1134:	dae080e7          	jalr	-594(ra) # ede <putc>
      state = 0;
    1138:	4981                	li	s3,0
    113a:	bd45                	j	fea <vprintf+0x42>
        putc(fd, '%');
    113c:	02500593          	li	a1,37
    1140:	8556                	mv	a0,s5
    1142:	00000097          	auipc	ra,0x0
    1146:	d9c080e7          	jalr	-612(ra) # ede <putc>
        putc(fd, c);
    114a:	85ca                	mv	a1,s2
    114c:	8556                	mv	a0,s5
    114e:	00000097          	auipc	ra,0x0
    1152:	d90080e7          	jalr	-624(ra) # ede <putc>
      state = 0;
    1156:	4981                	li	s3,0
    1158:	bd49                	j	fea <vprintf+0x42>
        s = va_arg(ap, char*);
    115a:	8bce                	mv	s7,s3
      state = 0;
    115c:	4981                	li	s3,0
    115e:	b571                	j	fea <vprintf+0x42>
    1160:	74e2                	ld	s1,56(sp)
    1162:	79a2                	ld	s3,40(sp)
    1164:	7a02                	ld	s4,32(sp)
    1166:	6ae2                	ld	s5,24(sp)
    1168:	6b42                	ld	s6,16(sp)
    116a:	6ba2                	ld	s7,8(sp)
    }
  }
}
    116c:	60a6                	ld	ra,72(sp)
    116e:	6406                	ld	s0,64(sp)
    1170:	7942                	ld	s2,48(sp)
    1172:	6161                	addi	sp,sp,80
    1174:	8082                	ret

0000000000001176 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1176:	715d                	addi	sp,sp,-80
    1178:	ec06                	sd	ra,24(sp)
    117a:	e822                	sd	s0,16(sp)
    117c:	1000                	addi	s0,sp,32
    117e:	e010                	sd	a2,0(s0)
    1180:	e414                	sd	a3,8(s0)
    1182:	e818                	sd	a4,16(s0)
    1184:	ec1c                	sd	a5,24(s0)
    1186:	03043023          	sd	a6,32(s0)
    118a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    118e:	8622                	mv	a2,s0
    1190:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1194:	00000097          	auipc	ra,0x0
    1198:	e14080e7          	jalr	-492(ra) # fa8 <vprintf>
}
    119c:	60e2                	ld	ra,24(sp)
    119e:	6442                	ld	s0,16(sp)
    11a0:	6161                	addi	sp,sp,80
    11a2:	8082                	ret

00000000000011a4 <printf>:

void
printf(const char *fmt, ...)
{
    11a4:	711d                	addi	sp,sp,-96
    11a6:	ec06                	sd	ra,24(sp)
    11a8:	e822                	sd	s0,16(sp)
    11aa:	1000                	addi	s0,sp,32
    11ac:	e40c                	sd	a1,8(s0)
    11ae:	e810                	sd	a2,16(s0)
    11b0:	ec14                	sd	a3,24(s0)
    11b2:	f018                	sd	a4,32(s0)
    11b4:	f41c                	sd	a5,40(s0)
    11b6:	03043823          	sd	a6,48(s0)
    11ba:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    11be:	00840613          	addi	a2,s0,8
    11c2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    11c6:	85aa                	mv	a1,a0
    11c8:	4505                	li	a0,1
    11ca:	00000097          	auipc	ra,0x0
    11ce:	dde080e7          	jalr	-546(ra) # fa8 <vprintf>
}
    11d2:	60e2                	ld	ra,24(sp)
    11d4:	6442                	ld	s0,16(sp)
    11d6:	6125                	addi	sp,sp,96
    11d8:	8082                	ret

00000000000011da <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    11da:	1141                	addi	sp,sp,-16
    11dc:	e406                	sd	ra,8(sp)
    11de:	e022                	sd	s0,0(sp)
    11e0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    11e2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    11e6:	00001797          	auipc	a5,0x1
    11ea:	e2a7b783          	ld	a5,-470(a5) # 2010 <freep>
    11ee:	a039                	j	11fc <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    11f0:	6398                	ld	a4,0(a5)
    11f2:	00e7e463          	bltu	a5,a4,11fa <free+0x20>
    11f6:	00e6ea63          	bltu	a3,a4,120a <free+0x30>
{
    11fa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    11fc:	fed7fae3          	bgeu	a5,a3,11f0 <free+0x16>
    1200:	6398                	ld	a4,0(a5)
    1202:	00e6e463          	bltu	a3,a4,120a <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1206:	fee7eae3          	bltu	a5,a4,11fa <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
    120a:	ff852583          	lw	a1,-8(a0)
    120e:	6390                	ld	a2,0(a5)
    1210:	02059813          	slli	a6,a1,0x20
    1214:	01c85713          	srli	a4,a6,0x1c
    1218:	9736                	add	a4,a4,a3
    121a:	02e60563          	beq	a2,a4,1244 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
    121e:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    1222:	4790                	lw	a2,8(a5)
    1224:	02061593          	slli	a1,a2,0x20
    1228:	01c5d713          	srli	a4,a1,0x1c
    122c:	973e                	add	a4,a4,a5
    122e:	02e68263          	beq	a3,a4,1252 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
    1232:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1234:	00001717          	auipc	a4,0x1
    1238:	dcf73e23          	sd	a5,-548(a4) # 2010 <freep>
}
    123c:	60a2                	ld	ra,8(sp)
    123e:	6402                	ld	s0,0(sp)
    1240:	0141                	addi	sp,sp,16
    1242:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
    1244:	4618                	lw	a4,8(a2)
    1246:	9f2d                	addw	a4,a4,a1
    1248:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    124c:	6398                	ld	a4,0(a5)
    124e:	6310                	ld	a2,0(a4)
    1250:	b7f9                	j	121e <free+0x44>
    p->s.size += bp->s.size;
    1252:	ff852703          	lw	a4,-8(a0)
    1256:	9f31                	addw	a4,a4,a2
    1258:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    125a:	ff053683          	ld	a3,-16(a0)
    125e:	bfd1                	j	1232 <free+0x58>

0000000000001260 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1260:	7139                	addi	sp,sp,-64
    1262:	fc06                	sd	ra,56(sp)
    1264:	f822                	sd	s0,48(sp)
    1266:	f04a                	sd	s2,32(sp)
    1268:	ec4e                	sd	s3,24(sp)
    126a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    126c:	02051993          	slli	s3,a0,0x20
    1270:	0209d993          	srli	s3,s3,0x20
    1274:	09bd                	addi	s3,s3,15
    1276:	0049d993          	srli	s3,s3,0x4
    127a:	2985                	addiw	s3,s3,1
    127c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
    127e:	00001517          	auipc	a0,0x1
    1282:	d9253503          	ld	a0,-622(a0) # 2010 <freep>
    1286:	c905                	beqz	a0,12b6 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1288:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    128a:	4798                	lw	a4,8(a5)
    128c:	09377a63          	bgeu	a4,s3,1320 <malloc+0xc0>
    1290:	f426                	sd	s1,40(sp)
    1292:	e852                	sd	s4,16(sp)
    1294:	e456                	sd	s5,8(sp)
    1296:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    1298:	8a4e                	mv	s4,s3
    129a:	6705                	lui	a4,0x1
    129c:	00e9f363          	bgeu	s3,a4,12a2 <malloc+0x42>
    12a0:	6a05                	lui	s4,0x1
    12a2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    12a6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    12aa:	00001497          	auipc	s1,0x1
    12ae:	d6648493          	addi	s1,s1,-666 # 2010 <freep>
  if(p == (char*)-1)
    12b2:	5afd                	li	s5,-1
    12b4:	a089                	j	12f6 <malloc+0x96>
    12b6:	f426                	sd	s1,40(sp)
    12b8:	e852                	sd	s4,16(sp)
    12ba:	e456                	sd	s5,8(sp)
    12bc:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    12be:	00001797          	auipc	a5,0x1
    12c2:	dca78793          	addi	a5,a5,-566 # 2088 <base>
    12c6:	00001717          	auipc	a4,0x1
    12ca:	d4f73523          	sd	a5,-694(a4) # 2010 <freep>
    12ce:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    12d0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    12d4:	b7d1                	j	1298 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
    12d6:	6398                	ld	a4,0(a5)
    12d8:	e118                	sd	a4,0(a0)
    12da:	a8b9                	j	1338 <malloc+0xd8>
  hp->s.size = nu;
    12dc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    12e0:	0541                	addi	a0,a0,16
    12e2:	00000097          	auipc	ra,0x0
    12e6:	ef8080e7          	jalr	-264(ra) # 11da <free>
  return freep;
    12ea:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    12ec:	c135                	beqz	a0,1350 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12f0:	4798                	lw	a4,8(a5)
    12f2:	03277363          	bgeu	a4,s2,1318 <malloc+0xb8>
    if(p == freep)
    12f6:	6098                	ld	a4,0(s1)
    12f8:	853e                	mv	a0,a5
    12fa:	fef71ae3          	bne	a4,a5,12ee <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    12fe:	8552                	mv	a0,s4
    1300:	00000097          	auipc	ra,0x0
    1304:	bbe080e7          	jalr	-1090(ra) # ebe <sbrk>
  if(p == (char*)-1)
    1308:	fd551ae3          	bne	a0,s5,12dc <malloc+0x7c>
        return 0;
    130c:	4501                	li	a0,0
    130e:	74a2                	ld	s1,40(sp)
    1310:	6a42                	ld	s4,16(sp)
    1312:	6aa2                	ld	s5,8(sp)
    1314:	6b02                	ld	s6,0(sp)
    1316:	a03d                	j	1344 <malloc+0xe4>
    1318:	74a2                	ld	s1,40(sp)
    131a:	6a42                	ld	s4,16(sp)
    131c:	6aa2                	ld	s5,8(sp)
    131e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    1320:	fae90be3          	beq	s2,a4,12d6 <malloc+0x76>
        p->s.size -= nunits;
    1324:	4137073b          	subw	a4,a4,s3
    1328:	c798                	sw	a4,8(a5)
        p += p->s.size;
    132a:	02071693          	slli	a3,a4,0x20
    132e:	01c6d713          	srli	a4,a3,0x1c
    1332:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1334:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1338:	00001717          	auipc	a4,0x1
    133c:	cca73c23          	sd	a0,-808(a4) # 2010 <freep>
      return (void*)(p + 1);
    1340:	01078513          	addi	a0,a5,16
  }
}
    1344:	70e2                	ld	ra,56(sp)
    1346:	7442                	ld	s0,48(sp)
    1348:	7902                	ld	s2,32(sp)
    134a:	69e2                	ld	s3,24(sp)
    134c:	6121                	addi	sp,sp,64
    134e:	8082                	ret
    1350:	74a2                	ld	s1,40(sp)
    1352:	6a42                	ld	s4,16(sp)
    1354:	6aa2                	ld	s5,8(sp)
    1356:	6b02                	ld	s6,0(sp)
    1358:	b7f5                	j	1344 <malloc+0xe4>
