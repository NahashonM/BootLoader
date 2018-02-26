
char *msg = "Hello You piece of shit..\nWakanda shit";

extern void printf(char *str,...);
void putchar(char XChar);

void MAIN()
{
cls_term();
printf("%[D0{%s}\n", "Hello World");
printf("%[30Hello %c :This number {%d} in binary is[%b] in octal is {%o} in hex is {%0x}", 'A',256,256,256,256);

int x = 1;
printf(msg);

}
