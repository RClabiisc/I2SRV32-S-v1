#ifndef __H
#define __H


// Model Sizes
#define MAT_DIM 8
#define MAT_SIZE MAT_DIM*MAT_DIM

// UART Related Defines //
#define Baud_1M 1500000
#define UART_REG_RB  0x5F1006F0
#define LED_ADDR 0x5F100780
#define PWM_DC_REG 0x5F100800
#define ADC_REG 0x5F100804
#define REG_1 0x5F1007fc
#define REG_2 0x5F1007e0
#define BUZZER_REG 0x5F100810

#define UART_REG_RB  0x5F1006F0
#define UART_REG_LS  0x5F1006F6

//////////////////////////////////
// Model Related GlobVars
//////////////////////////////////
extern int a_mat[MAT_SIZE];
extern int b_mat[MAT_SIZE];
extern int y_mat[MAT_SIZE];
extern int expected_output[MAT_SIZE];


//////////////////////////////////
// Function Declaration 
//////////////////////////////////
// main function
int main(int argc, char* argv[]);
//convolutional Neural Network Related
//void matmul64(int y_mat[MAT_SIZE], int a_mat[MAT_SIZE], int b_mat[MAT_SIZE], int matsize);
// ISR Related Functions
void ISR6_addr_exception();
void ISR5_uart();    // UART Receive Interrupt handler

#endif
