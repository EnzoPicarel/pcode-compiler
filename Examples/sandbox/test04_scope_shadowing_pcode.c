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
LOADI(0)
}

void pcode_main() {
LOADI(100)
LOADI(0)
STORE
SAVEBP // entering block
LOADI(0)
LOADI(5)
LOADBP
SHIFT(1)
STORE
SAVEBP // entering block
LOADI(0)
LOADI(1)
LOADBP
SHIFT(1)
STORE
RESTOREBP // exiting block
LOADBP
SHIFT(1)
LOAD
LOADI(1)
ADDI
LOADBP
SHIFT(1)
STORE
LOADBP
SHIFT(1)
LOAD
LOADI(6)
EQI
IFN(False_0)
GOTO(True_0)
True_0:
SAVEBP // entering block
LOADI(0)
LOADBP
SHIFT(1)
STORE
RESTOREBP // exiting block
False_0:
RESTOREBP // exiting block
LOADBP
SHIFT(1)
LOAD
return;
}
