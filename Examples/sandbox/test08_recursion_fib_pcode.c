// Begin PCode Header
#include "PCode.h"

void pcode_main();
void init_glob_var();

int main() {
init_glob_var();
pcode_main();
return stack[sp-1].int_value;
}
// End PCode Header

void init_glob_var(){
}

void pcode_fib() {
LOADBP
SHIFT(-1)
LOAD
LOADI(2)
LTI
IFN(False_0)
GOTO(True_0)
True_0:
SAVEBP // entering block
LOADBP
LOAD
SHIFT(-1)
LOAD
// Loading function return adress
LOADBP
LOAD
SHIFT(-2) // apply returned value offset -2
STORE // store returned value
RESTOREBP // fermeture bloc depth 2
return;
RESTOREBP // exiting block
False_0:
LOADI(0)
LOADBP
SHIFT(-1)
LOAD
LOADI(1)
SUBI
SAVEBP
CALL(pcode_fib)
RESTOREBP
DROP(1) //remove 1 fun. parameters from stack
LOADI(0)
LOADBP
SHIFT(-1)
LOAD
LOADI(2)
SUBI
SAVEBP
CALL(pcode_fib)
RESTOREBP
DROP(1) //remove 1 fun. parameters from stack
ADDI
// Loading function return adress
LOADBP
SHIFT(-2) // apply returned value offset -2
STORE // store returned value
return;
}
void pcode_main() {
LOADI(0)
LOADI(9)
SAVEBP
CALL(pcode_fib)
RESTOREBP
DROP(1) //remove 1 fun. parameters from stack
return;
}
