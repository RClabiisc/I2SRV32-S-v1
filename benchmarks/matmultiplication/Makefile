
include ./Makefile.inc

# Root of RISC-V tools installation. Note that we expect to find the spike
# simulator header files here under $(RISCV)/include/spike .
RISCV = /opt/rvv-intrinsic/
#@export PATH = $PATH:RISCV/bin
#@echo $PATH
DRIVER_SOURCE_DIR	= drivers

DRIVER_SRC = \
	$(DRIVER_SOURCE_DIR)/uart_lib.c

APP_SOURCE_C_DIR	= app/c

APP_SRC_C =  \
	$(APP_SOURCE_C_DIR)/a_mat.c \
	$(APP_SOURCE_C_DIR)/b_mat.c \
	$(APP_SOURCE_C_DIR)/expected_output.c

	

PORT_INT = arch/interrupt.S

DEMO_SRC = main.c

INCLUDES = \
	-I. \
	-I./app \
	-I./arch \
	-I./drivers \
	-I./include 

#CFLAGS = \
#	$(WARNINGS) $(INCLUDES) \
#	-fomit-frame-pointer -fno-strict-aliasing -fno-builtin \
#	-D__gracefulExit -march=rv32imv -mabi=ilp32 #-fPIC

CFLAGS = $(INCLUDES) -static -nostartfiles -march=rv32imv -mabi=ilp32
GCCVER 	= $(shell $(GCC) --version | grep gcc | cut -d" " -f9)

#
# Define all object files.
#
APP_COBJ  	= $(APP_SRC_C:.c=.o)
APP_SOBJ  	= $(APP_SRC_ASM:.S=.o)
DRIVER_OBJ	= $(DRIVER_SRC:.c=.o)
DEMO_OBJ  	= $(DEMO_SRC:.c=.o)
CRT0_OBJ  	= $(CRT0:.S=.o)
PORT_INT_OBJ= $(PORT_INT:.S=.o)
OBJS = $(CRT0_OBJ) $(DRIVER_OBJ) $(APP_COBJ) $(APP_SOBJ) $(PORT_INT_OBJ) $(DEMO_OBJ)

LDFLAGS	 =  arch/riscv.ld -nostartfiles -static 

#LIBS	 = -L$(CCPATH)/lib/gcc/$(TARGET)/$(GCCVER) \
#		   -L$(CCPATH)/$(TARGET)/lib 

%.o: %.c
#	@echo "    GCC $<"
	$(GCC) -c $(CFLAGS) -o $@ $<

%.o: %.S
#	@echo "    CC $<"
	$(GCC) -c $(CFLAGS) -o $@ $<

PRINT_%:; $*=$($*)
all: $(PROG).elf

$(PROG).elf  : $(OBJS) 
	@echo Linking....
	$(GCC) -o $@ $(OBJS) $(LDFLAGS) $(LIBS) 
	$(OBJDUMP) -S $(PROG).elf > $(PROG).asm	
	$(OBJDUMP) -D $(PROG).elf > $(PROG).dump
	~/project/prebuilt/elf2hex/elf2hex --bit-width 32 --input $(PROG).elf --output temphex
	./Scripts/run.sh	
	@echo Completed $@
###---------COE file in hex format from special script --------------
#	@$(OBJCOPY) -O verilog -j .text -j .sdata -j .rodata -j .sbss -j .bss -j .tohost -j .data --gap-fill 00000000 --reverse-bytes=4 riscv-spike.elf temphex
#	@sed -i 's/ //g' temphex
#	@python Scripts/hex.py
#	@$(ELF2HEX) 4 524288 $(PROG).elf > $(PROG).hex
###---------COE file in hex format from tool chain---------
#	@python Scripts/toolhex.py
###---------SECDED COE file in binary format from tool chain---------
#	@python Scripts/secded.py
#	@gcc Scripts/secded.c
#	@./a.out
###--------Removal of unnecessary files
#	@rm -f $(OBJS)
#	@rm -f code.bin
#	@rm -f a.out 
#	@rm -f code.hex
#	@rm -f riscv.hex
#	@rm -f $(PROG).map
#	@rm -f Outputfiles/riscv-spike.hex	
###--------Removal of unnecessary files
#	@rm -f $(PROG).elf 
#	@rm -f temp.hex
#	@rm -f temphex
#	@echo Completed $@
#
	rm -rf $(DRIVER_SOURCE_DIR)/*.o
	rm -rf $(APP_SOURCE_C_DIR)/*.o
	rm -rf $(APP_SOURCE_ASM_DIR)/*.o
	rm -rf arch/*.o
	rm -rf *.o
####@rm -f $(OBJS)
####@rm -rf .elf 
####@rm -f Outputfiles/code.coe
####@rm -f Outputfiles/secded.coe
####@rm -f Outputfiles/Toolcode.coe
####@rm -f code.bin
####@rm -f a.out 
####@rm -f code.hex
####@rm -f riscv.hex
####@rm -f riscv-spike.hex
####@rm -f temp.hex
####@rm -f temphex
####@rm -f $(PROG).map
####@rm -f $(PROG).asm
####@rm -f $(PROG).hex
####@rm -f $(PROG).dump

force_true:
	@true

#-------------------------------------------------------------
sim:
	spike $(PROG).elf


