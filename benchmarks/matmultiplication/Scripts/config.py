# All the python files use the settings mention in this file
numberOfTests= 10

spikeBootAddress = 0x80000000			      # This is where spike boots from.
stackPointerRegister = 2
memoryBaseAddressRegister = 2       #Base address for memory operations is stored in this register.

sperateInstrDataMemory = False      # False will generate one "hex".
lineWidthOfMainMemory  = 4          # number of bytes per line in the main memory hex. can be 4,8,16
depthOfMainMemory      = 16384       # number of lines in the Main memory.

totalInstructions = 12000            #Total number of instructions to generate
bitwidth= 32                         #64 or 32
initialMemorySize = 1                #Size in KB. Should be less than or equal to 4 since immediate value for memory ops allows only that range.
maxNestedLoops= 0                    #Maximum number of nested loops
maxLoopIterations= 10                 #Max number of iterations for a loop
forwardBranchRange= 4               #Maximum number of instructions that can be jumped over during forward jumps
loopRange= 20                        #Maximum number of instructions within a loop is roughly loopRange
branchBackwardProbability= 0.2        #Prob of a branch being backward. Increase this to make more loops.

# Percentage split of instructions
percentBaseInstr = 100
perIntegerComputation = 40           # Integer computation
perControlTransfer = 40              # Control transfer
perLoadStore = 20                    # Load and Store
perSystemInstr = 0                   # System


# Single precision floating point

percentSPFloat = 00                  # 0 = disabled
percentSPLoadStore = 0
percentSPComputational = 100
percentSPConversionMov = 0
percentSPCompare = 00
PercentSPClassify= 0

# Double precision floating point
percentDPFloat = 0                  # 0 = disabled
percentDPLoadStore = 10
percentDPComputational = 33
percentDPConversionMov = 33
percentDPCompare = 10
PercentDPClassify= 4

# Percent privileged instructions
percentPrivilegedInstructions = 0
percentPrivilegedBaseInstr = 0
percentChangePrivilegeInstr = 0
percentTrapRedirectionInstr = 0
percentInterruptManagementInstr = 0
percentMemoryManagementInstr = 0
percentCustomInstr = 0

# Atomic instructions
percentAtomicInstructions = 0

#Data hazards Probability ( out of 1 )
numberOfPreviousRegistersToConsider=3
readAfterWrite = 0.2	#Probability of a source register being the destination of one of the previous considered instructions
writeAfterRead=0.2		#Probability of a destination register being the source of one of the previous considered instructions
writeAfterWrite=0.2		#Probability of a destination register being the destination of one of the previous considered instructions


