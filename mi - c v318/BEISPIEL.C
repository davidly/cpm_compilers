MAIN()
{ CHAR *VZ;
 VZ = "GUTEN";
 NL();
 OUTSTRING(VZ);
 OUTSTRING(" TAG ");
 PUTCHAR('!');
 NL();
}

OUTSTRING(P)
CHAR *P;
{ WHILE(*P!=0) PUTCHAR(*P++);
} 
NL()
{ PUTCHAR(13);
 PUTCHAR(10);
}
