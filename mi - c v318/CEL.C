MAIN()
{
	int lower, upper, step;
	float fahr, celsius;

	lower = 0;
	upper = 300;
	step = 20;

	fahr = lower;
	while (fahr <= upper){
		celsius = (5.0/9.0)*(fahr-32.0);
		printf("%6.2f %10.2f\r\n",fahr,celsius);
		fahr = fahr + step;
	}
}  