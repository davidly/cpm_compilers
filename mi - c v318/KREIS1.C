float rad;  /*RADIUS GLOBAL DEFINIERT*/
main()
{
   float dm=7.0, flaeche();

   rad=dm/2;
   printf("radius: %f, flaeche: %f\n", rad, flaeche());
}

float flaeche()
{
  return(rad*rad*3.14159);
}

