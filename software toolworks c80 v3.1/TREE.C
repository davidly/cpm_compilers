/* This is a sample program using structures.  It sorts a list of input
   words alphabetically using a binary sort tree. */

struct tree {
	struct tree *left,*right;
	char value[20];
	int count; } *tree = 0;
main() {
	char c[20];
	while (putstr("Word: "), getline(c,20)) entree(c,&tree);
	putstr("Here are the sorted words:\n");
	walk(tree,1);
	}

/* This routine prints out the tree recursively: walk left node, print
	value of this node, and walk right node */
walk(t,n) struct tree *t; {
	static int i;
	if (t) {walk(t->left,n+1);
		for (i = n; i--; putchar('-'));
		putchar('\t'); putstr(t->value);
		if (t->count > 1) {
			putchar('(');
			if (t->count > 9) putchar('0' + t->count / 10);
			putchar('0' + t->count % 10); putchar(')'); }
		putchar('\n');
		walk(t->right,n+1);
	}	}

/* This routine recursively finds the place in the tree to hang the string c */
entree(c,tree) struct tree **tree; char c[20]; {
	char *p;
	if (*tree == 0) {
		*tree = alloc(sizeof (struct tree));
		(*tree)->left = (*tree)->right = 0;
		for (p = (*tree)->value; *p++ = *c++; );
		(*tree)->count = 1;
		return; }
	switch (strcmp(c,(*tree)->value)) {
		case 0: (*tree)->count += 1; break;
		case -1: entree(c,&(*tree)->left); break;
		case 1: entree(c,&(*tree)->right);
	}	}

putstr(s) char *s; {while (*s) putchar(*s++); }

#include "stdlib.c"

turn *p < *q ? -1 : 1; }
