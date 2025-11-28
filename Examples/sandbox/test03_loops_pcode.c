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

void pcode_main() {
LOADI(0)
LOADI(0)
LOADI(0)
LOADBP
SHIFT(1)
STORE
LOADI(0)
LOADBP
SHIFT(2)
STORE
StartLoop_0:
LOADBP
SHIFT(1)
LOAD
LOADI(10)
LTI
IFN(False_0)
GOTO(True_0)
True_0:
SAVEBP // entering block
LOADBP
LOAD
SHIFT(2)
LOAD
LOADBP
LOAD
SHIFT(1)
LOAD
ADDI
LOADBP
LOAD
SHIFT(2)
STORE
LOADBP
LOAD
SHIFT(1)
LOAD
LOADI(1)
ADDI
LOADBP
LOAD
SHIFT(1)
STORE
RESTOREBP // exiting block
GOTO(StartLoop_0)
False_0:
LOADBP
SHIFT(2)
LOAD
return;
}
