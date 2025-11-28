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
LOADI(0)
LOADI(10)
LOADBP
SHIFT(1)
STORE
LOADI(0)
LOADI(0)
STORE
LOADBP
SHIFT(1)
LOAD
LOADI(5)
LTI
IFN(False_0)
GOTO(True_0)
True_0:
SAVEBP // entering block
LOADI(1)
LOADI(0)
STORE
RESTOREBP // exiting block
GOTO(End_0)
False_0:
SAVEBP // entering block
LOADBP
LOAD
SHIFT(1)
LOAD
LOADI(10)
EQI
IFN(False_1)
GOTO(True_1)
True_1:
SAVEBP // entering block
LOADI(2)
LOADI(0)
STORE
RESTOREBP // exiting block
GOTO(End_1)
False_1:
SAVEBP // entering block
LOADI(3)
LOADI(0)
STORE
RESTOREBP // exiting block
End_1:
RESTOREBP // exiting block
End_0:
LOADI(0)
LOAD
return;
}
