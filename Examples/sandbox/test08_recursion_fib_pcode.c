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
LOADBP
LOAD // remonte au parent (depth 2 -> 1)
SHIFT(-2)
STORE // ecriture valeur de retour
RESTOREBP // fermeture bloc depth 2
RESTOREBP // fermeture bloc depth 1
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
DROP(1) // nettoyage args
LOADI(0)
LOADBP
SHIFT(-1)
LOAD
LOADI(2)
SUBI
SAVEBP
CALL(pcode_fib)
RESTOREBP
DROP(1) // nettoyage args
ADDI
LOADBP
SHIFT(-2)
STORE // ecriture valeur de retour
RESTOREBP // fermeture bloc depth 1
return;
}
void pcode_main() {
LOADI(0)
LOADI(9)
SAVEBP
CALL(pcode_fib)
RESTOREBP
DROP(1) // nettoyage args
return;
}
