char      *c[]={"FINGER","TAT","ZEIG","LABSAL"};
char     **cp[]={c+3,c+2,c+1,c};
char    ***cpp=cp;

main()
{
printf("%6s   ",**++cpp);
printf("%6s   ",*--*++cpp+4);
printf("%6s   ",*cpp[-2]+3);
printf("%6s   ",cpp[-1][-1]+1);
} 
  