#include "header.h"
//#include "uart_lib.h"

// Define top of stack
extern unsigned __stacktop;
// initial stack pointer is first address of program
__attribute__((section(".stack"), used)) unsigned *__stack_init = &__stacktop;

int __attribute__((aligned(32))) __attribute__((section(".ram_data")))  y_mat[MAT_SIZE];    
// MAT_DIM and MAT_SIZE are mentoined in include/header.h file.

int main(int argc, char* argv[])
{
    int sum;
    for(int i=0;i<MAT_DIM;i++)
        for(int j=0;j<MAT_DIM;j++)
        {
            sum=0;
            for(int k=0;k<MAT_DIM;k++)
                sum+=a_mat[i*MAT_DIM+k]*b_mat[k*MAT_DIM+j];
            y_mat[i*MAT_DIM+j] = sum;
        }                                              
    return 0;
}

void ISR5_uart()
{
    
}
void ISR6_addr_exception()
{
}

