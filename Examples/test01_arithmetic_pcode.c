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
LOADF(0.0)
LOADI(0)
}

void pcode_main() {
LOADI(10)
LOADI(0)
STORE
LOADF(2.500000)
LOADI(1)
STORE
LOADI(0)
LOAD
LOADI(2)
MULTI
LOADI(5)
ADDI
LOADI(2)
STORE
LOADI(1)
LOAD
LOADI(0)
LOAD
I2F2 // converting second arg to float
ADDF
LOADI(1)
STORE
LOADI(2)
LOAD
return;
}
