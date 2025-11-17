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
LOADI(3)
LOADI(0)
SHIFT(0)
STORE
LOADI(5)
LOADI(0)
SHIFT(1)
STORE
LOADI(0)
SHIFT(0)
LOAD
LOADI(0)
SHIFT(1)
LOAD
ADDI
}
