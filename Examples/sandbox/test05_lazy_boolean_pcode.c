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

void pcode_touch() {
LOADI(0)
LOAD
LOADI(1)
ADDI
LOADI(0)
STORE
LOADI(1)
// Loading function return adress
LOADBP
SHIFT(-1) // apply returned value offset -1
STORE // store returned value
return;
}
void pcode_main() {
LOADI(0)
LOADI(0)
STORE
LOADI(1)
LOADI(0)
LTI
IFN(False_0)
GOTO(True_0)
True_0:
LOADI(0)
SAVEBP
CALL(pcode_touch)
RESTOREBP
LOADI(1)
EQI
IFN(False_1)
GOTO(True_1)
False_0: GOTO(False_1)
True_1:
SAVEBP // entering block
LOADI(0)
LOAD
LOADI(100)
ADDI
LOADI(0)
STORE
RESTOREBP // exiting block
False_1:
LOADI(1)
LOADI(0)
GTI
IFN(False_2)
GOTO(True_2)
False_2:
LOADI(0)
SAVEBP
CALL(pcode_touch)
RESTOREBP
LOADI(1)
EQI
IFN(False_3)
GOTO(True_3)
True_2: GOTO(True_3)
True_3:
SAVEBP // entering block
LOADI(0)
LOAD
LOADI(10)
ADDI
LOADI(0)
STORE
RESTOREBP // exiting block
False_3:
LOADI(0)
LOAD
return;
}
