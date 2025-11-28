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

void pcode_reset() {
LOADI(0)
LOADI(0)
STORE
}
void pcode_inc() {
LOADI(0)
LOAD
LOADBP
SHIFT(-1)
LOAD
ADDI
LOADI(0)
STORE
}
void pcode_main() {
SAVEBP
CALL(pcode_reset)
RESTOREBP
DROP(0) // nettoyage args
LOADI(0)
LOADI(5)
SAVEBP
CALL(pcode_inc)
RESTOREBP
DROP(1) // nettoyage args
LOADI(0)
LOADI(10)
SAVEBP
CALL(pcode_inc)
RESTOREBP
DROP(1) // nettoyage args
LOADI(0)
LOAD
return;
}
