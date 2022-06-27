#ifndef UART_LIB_H
#define UART_LIB_H

#include <stdio.h>
#include <stdarg.h>

void UART_init(uint32_t baud, char fifo_trig_level);
void UARTCharPut(char i);
void UART_string(char string[]);
void UART_integer_digit (unsigned long int value, int digits);
void UART_integer (unsigned long int value);
void UART_newline(void);
void UART_Htab(void);
void UART_float(double number,int digits);
int UARTwrite(const char *pcBuf, uint32_t ui32Len);
void UARTvprintf(const char *pcString, va_list vaArgP);
void UARTprintf(const char *pcString, ...);

#endif /* UART_LIB_H */
