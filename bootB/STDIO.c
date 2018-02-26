#include "stdarg.h"
#include "stdint.h"


/*
	Define Variables and constants needed to 
	address the screen memory in 80 x 25 VGA mode	*/

#ifndef __Video__
#define __Video__
	#define	Width	80
	#define	Height	25
	#define	Depth	2
	int8_t *Video = (char *) 0xB8000;			// VGA memory
	int8_t color = 0xD;						// color buffer [ txt | bg ]
	short Vid_X = 0;							// X Cursor tracker
	short Vid_Y = 0;							// Y Cursor tracker
	
	void Vid_XY_Update(){
		if (Vid_X >= 80){
			Vid_X = 0;	Vid_Y++;
		}
		if (Vid_Y>= Height){
			// Should actually implement scrolling effect
			Vid_X = 0;	Vid_Y = 0;
		}
	}
	void Video_Set_Color(uint8_t value){
		color = value;
	}
#endif

#ifndef __putchar__
#define __putchar__
void putchar(char XChar){
	int CuPos;
	Vid_XY_Update();
	
	if (XChar == '\n'){		// New line character
		Vid_X = 0;
		Vid_Y++;
	}else if (XChar == '\t'){		// Tab character
		Vid_X += 4;		
	}else if (XChar == '\r'){		// Carriage return
		Vid_X = 0;
	}else{
		CuPos = ( Vid_X + (Vid_Y * Width) ) * Depth ;
		Video[CuPos] = XChar;
		Video[CuPos+1] = color;
		Vid_X++;
	}
	Vid_XY_Update();
}
#endif

#ifndef __itoa__
#define __itoa__
int num_characters(int n, int8_t base){
	int32_t i = 0;
	while(n){
		n = n / base;
		i++;	
	}
	return i;
}

void itoa(int32_t n, int8_t base, char *buffer){
	int32_t i, sign;
	int vx;
	i = num_characters( n, base);

	if((sign = n) < 0){
		n = -n;
		buffer[0] = '-'; i++;
	}
	
	buffer[i--] = '\0';
	
	do {
		vx = n % base ;
		if (vx > 9)					// hex handler
			vx = 'A' + (vx - 10);
		else
			vx = '0' + vx;
		
		buffer[i--] = vx;			//  n % base + '0';
	} while ( (n /= base)>0 );

}

#endif

#ifndef __atoi__
#define __atoi__
int pow(int n, int t){
	int temp = 1;
	for(int i=t; i>=1; i--)
		temp = temp * n;
	
	return temp;
}


int atoi(char *str, int8_t base){
	int x = len(str)-1;		// length of array
	int y=0, t = 0;
	int32_t temp = 0;
	
	for(int i=x ; i>=0; i-- && t++ ){
		if( (base == 16) && (str[i] >= 'A') && (str[i] <= 'F')){
				temp = (str[i] - 55) * pow(base,t);
		}else{
				temp = str[i] - '0';
		}
		y = y + temp;
	}
	return y;
}
#endif


#ifndef __len__
#define __len__
int len(char *str)
{
int i=0;

	while(str[i++]);

	return --i;
}
#endif

#ifndef printf
void printf(char *str,...)
{
int32_t argchar;
char buffer[100];

va_list args;
va_start(args, str);

for (int x = 0; x < len(str) ; x++){
	if( str[x] == '%'){
		x++;
		if ( str[x] == '%'){

			putchar(str[x]);

		}else if( str[x] == 'd' ){		// Decimal number
			
			argchar = va_arg(args, int);
			itoa(argchar, 10 ,buffer);
			printf(buffer);
	
		}else if( str[x] == 'c' ){		// Character

			argchar = va_arg(args, int);
			putchar(argchar);
			
		}else if( str[x] == 's' ){		// String

			printf(	va_arg(args, char*));
			
		}else if( str[x] == 'b' ){		// binary

			argchar = va_arg(args, int);
			itoa(argchar, 2 ,buffer);
			printf(buffer);
		
		}else if( str[x] == '[' ){		// Screen color
			x++;
			buffer[1] =	str[x++];
			buffer[0] = str[x];
			buffer[2] = '\0';
			
			uint8_t num = atoi( buffer, 16);
			Video_Set_Color(num);			
			
		}else if( str[x] == 'o' ){		// octal

			argchar = va_arg(args, int);
			itoa(argchar, 7 ,buffer);
			printf(buffer);
			
		}else if( str[x++] == '0' ){	// Hexadecimal
			if( str[x] == 'x' ){
				
				argchar = va_arg(args, int);
				itoa(argchar, 16 ,buffer);
				printf(buffer);
				
			}else{
				x--;
				putchar(str[x]);
			}
		}
	
	}else{
		putchar(str[x]);
		
	}		
}

}
#endif

#ifndef _cls_term_
#define _cls_term_
void cls_term()
{
int CuPos;
	for (Vid_Y = 0; Vid_Y<25; Vid_Y++){
		for (Vid_X = 0; Vid_X <= 80; Vid_X++){
			CuPos = ( Vid_X + (Vid_Y * Width) ) * Depth ;
			Video[CuPos] = ' ';
			Video[CuPos+1] = color;
		}
	}
Vid_X = 0; Vid_Y = 0;
}
#endif





