<div align="center">
  <h3 align="center">PCode Compiler</h3>

  <p align="center">
    A stack-based intermediate representation compiler using <strong>Flex</strong>, <strong>Bison</strong>, and a custom <strong>PCode</strong> VM.
    <br />
    <a href="#-getting-started"><strong>Get Started »</strong></a>
  </p>
  
  ![CI Status](https://img.shields.io/badge/build-passing-brightgreen)
  ![License](https://img.shields.io/badge/license-MIT-blue)
</div>

## 🔍 About The Project
This project implements a compiler for **MyC** (a simplified C subset) targeting a stack-based virtual machine (**PCode**). 

Instead of generating assembly directly, the compiler emits C code containing PCode macros. This approach simulates a low-level stack machine (managing frames, stack pointers, and block scoping) while remaining portable. The core engineering challenges involve **static lexical scoping**, **type-directed code generation**, and **lazy boolean evaluation** without an intermediate AST.

*Built as a Semester 7 project at ENSEIRB-MATMECA.*

### 🛠 Built With
* **Language:** C (C99)
* **Parser Generator:** Flex & Bison
* **Build System:** GNU Make

## 📐 Architecture

### Technical Highlights
* **Type-Directed Codegen:** Resolves operand types at parse-time to emit specific integer/float PCode ops, injecting implicit promotions (`I2F1`/`I2F2`) where necessary.
* **Stack & Scope Management:** Implements static scoping via block-pointer (`bp`) walks. Variable access is compiled to depth-aware `LOADBP` + `SHIFT` operations based on symbol table attributes `{offset, depth}`.
* **Lazy Boolean Evaluation:** Short-circuits `&&` and `||` by compiling them into control-flow graphs with threaded labels (`True_k`/`False_k`) and conditional jumps (`IFN`, `GOTO`), optimizing runtime performance.
* **Function ABI:** Manages the call stack manually: reserving return slots, pushing arguments at negative offsets, saving/restoring `bp`, and handling return values strictly through stack operations.

### File Organization
```text
├── lang.l                  # Lexer (Flex): Token definitions
├── lang.y                  # Parser (Bison): Grammar rules & direct PCode emission
├── Table_des_symboles.c    # Symbol Table: Linked list for {type, offset, depth}
├── Makefile                # Build pipeline (Flex -> Bison -> GCC)
├── runComp                 # Wrapper script: Compiles .myc files to .c
├── PCode/                  # Stack Machine Runtime
│   ├── PCode.h             # VM Instruction Set (Macros)
│   ├── PCode.c             # Runtime state (Stack, SP, BP)
│   └── Makefile            # VM Builder
└── Examples/               # Test Suite
    └── ex*.myc             # Source files covering loops, recursion, scoping
```

## 🚀 Getting Started

### Prerequisites
* **GCC**
* **Flex**
* **Bison**
* **Make**

### Installation & Build
1. **Clone the Repository**
   ```bash
   git clone https://github.com/EnzoPicarel/pcode-compiler.git
   cd pcode-compiler
   ```

2. **Build the Compiler**
   ```bash
   make
   ```

3. **Compile a Source File**
   ```bash
   ./runComp Examples/ex1.0
   ```
   *Output: `Examples/ex1.0_pcode.c`*

## 🧪 Tests
To validate the compiler, the generated code must be linked with the pre-built PCode object file (`PCode/PCode.o`).

**Example:**

```bash
# 1. Compile MyC source to PCode C
./runComp Examples/ex3.2

# 2. Link the generated file with the VM object file
#    -I PCode       : Include path for PCode.h headers
#    PCode/PCode.o  : The pre-compiled VM runtime (built by 'make')
gcc -I PCode -o ex3.2 Examples/ex3.2_pcode.c PCode/PCode.o

# 3. Run the executable
./ex3.2
```

## 👥 Authors
* **Enzo Picarel**
* **Raphaël Bely**