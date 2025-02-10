 
#define DIRSTART        0x0     /*CRL directory*/
#define DIREND          0x1ff   /*dir. stops here*/
#define FNCSTART        0x205   /*fnc.'s can start*/
#define TPAHBRLC        0x1     /*hi byte of tpa add*/
 
#define JUMPINSTR       0xc3    /*jump instr. op code*/
#define MASK7           0x7f    /*seven bit mask*/
#define NULENTRY        0x80    /*null function*/
 
#define CR              0xd     /*carriage return*/
#define LF              0xa     /*line feed*/
 
#define MXFNSIZE        4096    /*max function size*/
#define MXRELOCS        512     /*mx # reloc. symbls*/
#define MXRLCJTS        128     /*max # j.t. relocs*/
 
 
char    fncbuf[134], extbuf[134], outbuf[134];
char    filestr[20];            /*where file names are kept*/
 
main(argc, argv)
  int argc;
  char **argv;
{
  char  function[MXFNSIZE];
  int   fncfd, extfd, outfd;
  int   addr, fsize, size, fend, outbytes;
  int   rlc[MXRELOCS], rlcjt[MXRLCJTS];
  int   fip, rip, ripjt, rlcoffset;
  char  *s, *fn;
  int   i, j, k, ip, bust, c, cp;
 
  ip = 0;
 
  printf("Ccrl, 11/19/79\n");
  if(argc < 2)
    { printf("File required\n");
      exit();
    }
 
  s = *++argv;
  fn = filename(s, "COM");
  fncfd = fopen(fn, fncbuf);
  if(fncfd <= 0)
    { printf("Cannot open %s\n",fn);
      exit();
    }
 
  fn = filename(s, "EXT");
  extfd = fopen(fn, extbuf);
  if(extfd <= 0)
    { printf("Cannot open %s\n",fn);
      exit();
    }
 
  fn = filename(s, "CRL");
  outfd = fcreat(fn, outbuf);
  if(outfd <= 0)
    { printf("Cannot create %s\n",fn);
      exit();
    }
  else
    printf("Creating %s\n",fn);
 
  outbytes = -1;
  addr = FNCSTART;
  fn = funcname(extbuf);
  if(fn == '\0')
    { printf("Error: no function name on first line of .ext file\n");
      exit();
    }
  putstr(fn, outbuf, &outbytes);
  putw(addr, outbuf);
  outbytes += 2;
  putc(NULENTRY, outbuf);
  ++outbytes;
  fsize = rdhexlf(extbuf);      /*read function length*/
  size = rdhexlf(extbuf);       /*size incl. all other stuff*/
  fend = addr + size;
  putw(fend, outbuf);
  outbytes += 2;
  printf("Total size is %0d bytes\n", size);
  if(outbytes > DIREND)
    { printf("Error: new directory overflows directory area\n");
      exit();
    }
  while(outbytes < (addr - 1))
    { putc(0,outbuf);
      ++outbytes;
    }
  ip = 0;                       /*count of external functions*/
  do
    { fn = funcname(extbuf);
      if(fn != '\0')
        { while(*fn != '\0')
            { putc(*fn++, outbuf);
              ++outbytes;
            }
          ++ip;
        }
    }
  while(fn != '\0');
  putc(0x0, outbuf);
  ++outbytes;             /*null to end*/
  if(ip > 0)
    { if(3*ip >= 0xff)
        { printf("Error: to many external functions\n");
          exit();
        }
      function[0] = JUMPINSTR;
      function[1] = 3*(ip + 1);
      function[2] = TPAHBRLC;
      fip = 3;
      for(j = 1; j <= ip; j++)
        { function[fip++] = JUMPINSTR;
          function[fip++] = 0x0;
          function[fip++] = 0x0;
        }
      rlcoffset = 3*(ip + 1);
      rlcjt[0] = 1;             /*re-locate jump over jump table*/
      ripjt = 1;                /*this is first relocation parameter*/
    }
  else
    { fip = 0;
      rlcoffset = 0;
      ripjt = 0;
    }
  for(j = 1; j <= fsize; j++)
    { c = getc(fncbuf);
      function[fip++] = c;
      if(fip > MXFNSIZE)
        { printf("Error: function buffer size exceeded\n");
          exit();
        }
    }
  putw(fip, outbuf);
  outbytes += 2;                /*fnc size*/
  if(ripjt)                     /*no JT RLC's unless one already*/
    { while((c = readhex(extbuf))  >=  0)
        { rlcjt[ripjt++] = rlcoffset + c;
          if(ripjt > MXRLCJTS)
            { printf("Error: To many jump table relocation parameters\n");
              exit();
            }
        }
    }
  rip = 0;
  do
    { if((c = readhex(extbuf)) >= 0)
        rlc[rip++] = rlcoffset + c;
      if(rip > MXRELOCS)
        { printf("Error: To many relocation parameters\n");
          exit();
        }
    }
  while(c >= 0);
  printf("Number of jump table relocations is %0d\n",ripjt);
  printf("Number of local reference relocations is %0d\n",rip);
  if((rip + ripjt) > 0)
    { if(ripjt > 0)
        printf("Relocating jump table by 0x%4x\n", TPAHBRLC << 8);
      for(j = 0; j < ripjt; j++)
        function[rlcjt[j] + 1] -= TPAHBRLC;
      if(rip > 0)
        printf("Relocating local references by 0x%4x\n",
          (TPAHBRLC << 8) - rlcoffset);
      for(j = 0; j < rip; j++)
        { function[rlc[j]] += rlcoffset;
          function[rlc[j] + 1] -= TPAHBRLC;
          if(function[rlc[j]] < rlcoffset)
            ++function[rlc[j] + 1];
        }
    }
  for(j = 0; j < fip; j++)
    { putc(function[j], outbuf);
      ++outbytes;
    }
  putw(rip + ripjt, outbuf);
  outbytes += 2;
  rlcjt[ripjt] = 0x4000;
  rlc[rip] = 0x4000;
  i = 0;
  j = 0;
  while((i < rip)  ||  (j < ripjt))
    { if(rlc[i] < rlcjt[j])
        { putw(rlc[i++], outbuf);
          outbytes += 2;
        }
      else
        { putw(rlcjt[j++], outbuf);
          outbytes += 2;
        }
    }
  if(outbytes >= fend)
    { printf("Error: outbytes >= fend\n");
      printf("Outbytes = 0x%4x, fend = 0x%4x\n", outbytes, fend);
    }
  else
    if((outbytes + 1) != fend)
      { printf("Outbytes = 0x%4x, fend = 0x%4x\n", outbytes, fend);
        printf("Padding with %0d nulls\n", fend - outbytes - 1);
      }
  for(i = outbytes; i < fend; i++)
    putc(0x0, outbuf);
  fflush(fncbuf);
  close(fncfd);
  fflush(extbuf);
  close(extfd);
  fflush(outbuf);
  close(outbuf);
}
 
char *filename(flnmptr, flnmend)
  char *flnmptr, *flnmend;
{
  int i, havedot;
 
  havedot = 0;
  i = -1;
  while((filestr[++i] = *flnmptr++)  !=  '\0')
    havedot = havedot  ||  (filestr[i] == '.');
  if(!havedot)
    { filestr[i] = '.';
      while((filestr[++i] = *flnmend++)  !=  '\0');
    }
  return(filestr);
}
 
char *funcname(buf)
  int buf[];
{
  int c, i;
 
  i = -1;
  for(; ;)
    { c = getc(buf);
      if((c == CR)  ||  (c == LF))
        break;
      if(c == '\0')
        { printf("Error: premature EOF in .ext file\n");
          exit();
        }
      filestr[++i] = toupper(c);
    }
  c = getc(buf);
  if((c != CR)  &&  (c != LF))
    { printf("Error: non CR (LF) following LF (CR) in .ext file is %c\n", c);
      exit();
    }
  if(c == '\0')
    { printf("Error: premature EOF in .ext file\n");
      exit();
    }
  if(i < 0)
    return('\0');                       /*if blank line or something*/
  filestr[i] |= NULENTRY;               /*set high bit of last char*/
  filestr[++i] = '\0';
  return(filestr);
}
 
readhex(buf)
  int buf[];
{ int sum, c, h, count;
 
  c = skip(buf);
  count = 0;
  sum = 0;
  while((h = hexdig(c))  >=  0)
    { sum = (sum << 4) + h;
      ++count;
      c = getc(buf);
    }
  return((count ? sum : -1));
}
 
rdhexlf(buf)
  int buf[];
{ int c, h, sum, count;
 
  c = skip(buf);
  count = 0;
  sum = 0;
  while((h = hexdig(c))  >=  0)
    { sum = (sum << 4) + h;
      ++count;
      c = getc(buf);
    }
  if((c != CR)  &&  (c != LF))
    while((c != CR)  &&  (c != LF))
        c = getc(buf);
  c = getc(buf);
  if((c != CR)  &&  (c != LF))
    { printf("Error: non CR (LF) following LF (CR) in .ext file is %c\n", c);
      exit();
    }
  return((count ? sum : -1));
}
 
hexdig(c)
  int c;
{ if(c < '0')
    return(-1);
  if(c <= '9')
    return(c - '0');
  if(c < 'A')
    return(-1);
  if(c <= 'F')
    return(c - ('A' - 0xa));
  if(c < 'a')
    return(-1);
  if(c <= 'f')
    return(c - ('a' - 0xa));
  return(-1);
}
 
skip(buf)
  int buf[];
{ int c;
 
  do
    c = getc(buf);
  while((c == CR)  ||  (c == LF)  ||  (c == ' ')  ||  (c == '\t'));
  return(c);
}
 
putstr(str, buf, count)
  char *str;
  int buf[];
  int *count;
{ while(*str != '\0')
  { putc(*str++, buf);
    ++(*count);
  }
}
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
xþ	Âƒ$yöO/þ ÒŽ$þÊŽ$:º¹xÁÉÍš$åõ!„&þ Ú·$4:º¾Ê¯$ÒÑ$6+4ñÃ›$þÊ¤$þ
ÊÏ$þÊÔ$þ	ÊÜ$4Ã¤$+4ñáÉÍN#6 ñáÉ~öwÃ¤$õ>Íü$>
Íü$ñÉþÈþÈþ