# File to be included in all makefiles

TARGET=riscv32-unknown-elf
#-----------------------------------------------------------
GCC		= $(TARGET)-gcc
OBJCOPY	= $(TARGET)-objcopy
OBJDUMP	= $(TARGET)-objdump
ELF2HEX  = elf2hex
AR		= $(TARGET)-ar
RANLIB	= $(TARGET)-ranlib
CCPATH	= /home/maarten.in_t.hout/riscv-build

PROG	= riscv-spike
CRT0	= arch/boot.S

FREERTOS_SOURCE_DIR	= ../../Source
CUNIT	= ../../../cunit

#-----------------------------------------------------------
WARNINGS= -Wall -Wextra -Wshadow -Wpointer-arith -Wbad-function-cast -Wcast-align -Wsign-compare \
		-Waggregate-return -Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations -Wunused

