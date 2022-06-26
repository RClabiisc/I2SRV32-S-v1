# I2SRV32-S
A 32-bit RISC-V core written in Verilog and an instruction set simulator supporting RV32IMAF.
This core has been tested on Xilinix Vivado 2020.2 Simulator. 

# Overview
![image](https://user-images.githubusercontent.com/91065965/175799840-90867b37-4cf9-4ef8-818f-32a16cd67706.png)
![image](https://user-images.githubusercontent.com/91065965/175800131-8143ba11-c9d9-4a9f-aef3-e0fac8afaebd.png)

# Features
* The processor is in-order, single-issue scalar core.
* The CPU has five-stage pipeline- Instruction Fetch, Instruction Decode, Execution, Memory and Write-Back.
* Branch Prediction Unit with 2-bit branch direction predictor designed using PC-Gshare branch predictor.
* I-Cache and D-Cache are 8KB size, 2-way set associative, with block size of 32 bytes.
* I-TLB and D-TLB are translation lookaside buffers (TLB) for I-Cache and D-cache respectively, uses Economic Value Added policy as replacement block.
* Whisbone B3 bus is designed to access Memory and UART 1650 Peripheral. 
* Main Memory is of size 1MB.
* UART Peripheral is taken from http://www.opencores.org/cores/uart16550/
* Working Frequency is 50MHz on Xilinx Vertex xc7vx485tffg1761-2 FPGA. 

# Memory Map
| Name  | Range |
| ------------- | ------------- |
| Main Memory   | 0x00000000 - 0x000F_FFFF |
| Boot Address  | 0x0000_0400 |
| ROM  |  0x0000_0000 - 0x0001_FFFF |
| RAM |  0x0002_0000 - 0x000F_FFFF |
| Stack pointer Address  |  0x000F_EFFC |
| UART Peripheral |  0x5f10_0600 |

# Interfaces
| Name  | Description |
| ------------- | ------------- |
| clk_in1_n  | Clock Input negative  |
| clk_in1_p | Clock input postive |
| rst_in  | Async reset, active-high.  |
| srx_pad_i |  Receiver Input pin |
| stx_pad_o  |  Transmitter Output pin |
| int_in |  3-bit Interrupt input |

