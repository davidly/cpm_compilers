main()
{
   float dm, rad, fl, flaeche();

   dm  = 7.0;
   rad = dm / 2;
   fl  = flaeche(rad);
   printf("Radius: %f, Flaeche: %f\n", rad, fl);
}

float flaeche(r)   /*Kreisflaechenberechnung*/
float r;
{
   float f;

   f =  r * r * 3.14159;
   return(f);
}


   	
