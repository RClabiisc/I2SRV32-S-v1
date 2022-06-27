# Tools Required
* Python3
* gcc
* RISC-V GCC Cross Compiler (https://github.com/riscv-collab/riscv-gnu-toolchain).

# Command to run
* **make all** command should enter in terminal on Ubuntu Machine, in the present working directory.
* Example: Goto matrixmultiplication directory in terminal, and enter **make all**.

# To-Do
* Matrix Multiplication of 8 x 8 matrix code is uploded.
* To test various benchmarks, related main C code should be written. **main.c** should be changed accordingly.
* To give any additional C files, it can be added in **app/c** directory.  
* While writting the C codes, proper notation should be followed. 
* Header file is in **include** directory. Change the header file according to application.
* **Makefile** will do the neccessary compilations. Makefile should be changed if you add any files in **app/c** directory.
* In **Makefile** installation path of RISC-V GCC Cross Compiler is mentioned. Change the path accordingly.
* COE file will be generated in **Outputfile** directory. Use this COE file in **MainMem** IP.

