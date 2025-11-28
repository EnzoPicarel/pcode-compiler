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

void pcode_ackermann() {
LOADBP
SHIFT(-2)
LOAD
LOADI(0)
EQI
IFN(False_0)
GOTO(True_0)
True_0:
SAVEBP // entering block
LOADBP
LOAD
SHIFT(-1)
LOAD
LOADI(1)
ADDI
LOADBP
LOAD // remonte au parent (depth 2 -> 1)
SHIFT(-3)
STORE // ecriture valeur de retour
RESTOREBP // fermeture bloc depth 2
RESTOREBP // fermeture bloc depth 1
return;
RESTOREBP // exiting block
False_0:
LOADBP
SHIFT(-2)
LOAD
LOADI(0)
GTI
IFN(False_1)
GOTO(True_1)
True_1:
LOADBP
SHIFT(-1)
LOAD
LOADI(0)
EQI
IFN(False_2)
GOTO(True_2)
False_1: GOTO(False_2)
True_2:
SAVEBP // entering block
LOADI(0)
LOADBP
LOAD
SHIFT(-2)
LOAD
LOADI(1)
SUBI
LOADI(1)
SAVEBP
CALL(pcode_ackermann)
RESTOREBP
DROP(2) // nettoyage args
LOADBP
LOAD // remonte au parent (depth 2 -> 1)
SHIFT(-3)
STORE // ecriture valeur de retour
RESTOREBP // fermeture bloc depth 2
RESTOREBP // fermeture bloc depth 1
return;
RESTOREBP // exiting block
False_2:
LOADI(0)
LOADBP
SHIFT(-2)
LOAD
LOADI(1)
SUBI
LOADI(0)
LOADBP
SHIFT(-2)
LOAD
LOADBP
SHIFT(-1)
LOAD
LOADI(1)
SUBI
SAVEBP
CALL(pcode_ackermann)
RESTOREBP
DROP(2) // nettoyage args
SAVEBP
CALL(pcode_ackermann)
RESTOREBP
DROP(2) // nettoyage args
LOADBP
SHIFT(-3)
STORE // ecriture valeur de retour
RESTOREBP // fermeture bloc depth 1
return;
}
void pcode_main() {
LOADI(0)
LOADI(3)
LOADI(2)
SAVEBP
CALL(pcode_ackermann)
RESTOREBP
DROP(2) // nettoyage args
return;
}
