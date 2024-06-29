/* tab - filter to insert tabs in a file wherever possible */
/* Walt Bilofsky - March 1980 */
/* Usage: tab <infile >outfile */
main() {
char line[150],*p,c,*q;
int i,j;
p=line;
while ((c=getchar()) > 0)
   if (c == '\t')
	{ do {*p++ = ' ';} while ((p-line)&7);}
   else if ((*p++ = c) == '\n') {
	*p = 0;
	p = line;
	while (*p) {
	   if (*p == ' ' && p[1] == ' ' && (((p-line)&7) != 7)) {
		q = p+1;
		while (*q++ == ' ') if (((q-line)&7) == 0) { putchar('\t');
							   p=q; goto foo; }
		}
	   putchar(*p++);
	   foo: ;
	   }
	p = line;
	}
}
