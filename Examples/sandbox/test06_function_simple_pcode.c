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

void pcode_add3() {
LOADBP
SHIFT(-3)
LOAD
LOADBP
SHIFT(-2)
LOAD
ADDI
LOADBP
SHIFT(-1)
LOAD
ADDI
LOADBP
SHIFT(-4)
STORE // ecriture valeur de retour
RESTOREBP // fermeture bloc depth 1
return;
}
void pcode_main() {
LOADI(0)
LOADI(0)
LOADI(10)
LOADI(20)
LOADI(30)
SAVEBP
CALL(pcode_add3)
RESTOREBP
DROP(3) // nettoyage args
LOADBP
SHIFT(1)
STORE
LOADBP
SHIFT(1)
LOAD
return;
}
