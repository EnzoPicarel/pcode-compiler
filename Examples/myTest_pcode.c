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
LOADI(0)
}

void pcode_main() {
LOADI(0)
LOADI(0)
// Debut conditionelle 0
LOADBP
SHIFT(0)
LOAD
IFN(False_0)
// la condition 0 est vraie
SAVEBP // entering block
LOADI(0)
LOADI(4)
LOADBP
SHIFT(2)
STORE
RESTOREBP // exiting block
False_0:
// la condition 0 est fausse
// Fin conditionelle 0
LOADI(2)
LOADBP
SHIFT(0)
STORE
LOADBP
SHIFT(0)
LOAD
LOADI(1)
STORE
}
