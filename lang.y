%{
#include "Table_des_symboles.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
  
extern int yylex();
extern int yyparse();

void yyerror (char* s) {
  printf ("%s\n",s);
  exit(0);
}
    
int depth=0;
int global_offset = 0;
int local_offset = 0;
int current_type;
char * current_fun_name;

int label_count = 0;
int bool_count = 0;
%}

%union { 
  struct ATTRIBUTE * symbol_value;
  char * string_value;
  int int_value;
  float float_value;
  int type_value;
  int label_value;
  int offset_value;
}

%token <int_value> NUM
%token <float_value> DEC
%token INT FLOAT VOID
%token <string_value> ID
%token AO AF PO PF PV VIR
%token RETURN  EQ
%token <label_value> IF ELSE WHILE
%token <label_value> AND OR NOT DIFF EQUAL SUP INF
%token PLUS MOINS STAR DIV
%token DOT ARR

%nonassoc IFX
%left OR                       
%left AND                      
%left DIFF EQUAL SUP INF       
%left PLUS MOINS               
%left STAR DIV                 
%left DOT ARR                  
%nonassoc UNA                  
%nonassoc ELSE

%{
char * type2string (int c) {
  switch (c) {
    case INT: return("int");
    case FLOAT: return("float");
    case VOID: return("void");
    default: return("type error");
  }  
};

void end_glob_var_decl(){
  static int unfinished=1;
  if (unfinished) {
    unfinished = 0;
    printf("}\n\n");
  }
}

int new_bool() {
    return bool_count++;
}

void make_code_comp(int type1, const char* op, int type2) {
    if (type1 == INT && type2 == FLOAT) {
        printf("I2F1\n"); printf("%sF\n", op);
    } else if (type1 == FLOAT && type2 == INT) {
        printf("I2F2\n"); printf("%sF\n", op);
    } else if (type1 == FLOAT && type2 == FLOAT) {
        printf("%sF\n", op);
    } else {
        printf("%sI\n", op);
    }
}

int make_code_aryth(int type1, const char* op, int type2) {
    int result_type;
    if (type1 == INT && type2 == INT) {
        printf("%sI\n", op); result_type = INT;
    } else if (type1 == FLOAT && type2 == FLOAT) {
        printf("%sF\n", op); result_type = FLOAT;
    } else if (type1 == INT && type2 == FLOAT) {
        printf("I2F1 // converting first arg to float\n");
        printf("%sF\n", op); result_type = FLOAT;
    } else if (type1 == FLOAT && type2 == INT) {
        printf("I2F2 // converting second arg to float\n");
        printf("%sF\n", op); result_type = FLOAT;
    } else {
        yyerror("Erreur de type pour opération binaire !");
    }
    return result_type;
}
%}

%start prog  

%type <type_value> type exp typename app
%type <string_value> fun_head
%type <label_value> bool_exp
%type <int_value> params args arglist

%%

// O. Déclaration globale

prog : glob_decl_list {}
;

glob_decl_list : glob_var_list glob_fun_list {}
;

glob_var_list : glob_var_list decl PV {}
| {printf("void init_glob_var(){\n"); }
;

glob_fun_list : glob_fun_list fun {}
| fun {}
;

// I. Functions

fun : type fun_head fun_body   {}
;
  
fun_head : ID PO PF            {
  end_glob_var_decl();
  current_fun_name = $1;
  attribute attr = makeSymbol(current_type, 0, 0); 
  set_symbol_value($1, attr);
  if (depth > 0) yyerror("Function must be declared at top level~!\n");
  printf("void pcode_%s() {\n", current_fun_name);
}
| ID PO params PF              {
   end_glob_var_decl();
   current_fun_name = $1;
   attribute attr = makeSymbol(current_type, $3, 0);
   set_symbol_value($1, attr);
   if (depth > 0) yyerror("Function must be declared at top level~!\n");
   printf("void pcode_%s() {\n", current_fun_name);
 }
;

params: type ID vir params     {
    attribute attr = makeSymbol($1, -($4 + 1), 1); 
    set_symbol_value($2, attr);
    $$ = $4 + 1; 
}
| type ID                      {
    attribute attr = makeSymbol($1, -1, 1);
    set_symbol_value($2, attr);
    $$ = 1; 
}
;

vir : VIR {}
;

fun_body : fao block faf {}
;

fao : AO {
  depth++;
}
;

faf : AF {
  if (strcmp(current_fun_name, "main") != 0) {
      printf("RESTOREBP // exiting function\n");
  }
  printf("}\n");
  depth--;
}
;


// II. Block

block:
  {
    $<int_value>$ = local_offset; 
    local_offset = 1; 
  }
  decl_list inst_list            
  {
    local_offset = $<int_value>1; 
  }
;

// III. Declarations

decl_list : decl_list decl PV {} 
| {}
;

decl: var_decl {}
;

var_decl : type vlist {}
;

vlist: vlist vir ID            { 
  int current_offset;
  if (depth == 0) current_offset = global_offset++;
  else current_offset = local_offset++;

  attribute attr = makeSymbol(current_type, current_offset, depth);
  set_symbol_value($3, attr);
  if (current_type == INT) printf("LOADI(0)\n");
  else printf("LOADF(0.0)\n");
} 
| ID                           {
    int current_offset;
    if (depth == 0) current_offset = global_offset++;
    else current_offset = local_offset++;

    attribute attr = makeSymbol(current_type, current_offset, depth);
    set_symbol_value($1, attr);
    if (current_type == INT) printf("LOADI(0)\n");
    else printf("LOADF(0.0)\n");
}
;

type : typename { current_type = $$; }
;

typename 
: INT   {$$=INT;} 
| FLOAT {$$=FLOAT;}
| VOID  {$$=VOID;}
;

// IV. Intructions

inst_list: inst_list inst {} 
| inst {}
;

pv : PV {}
;
 
inst:
  ao block af                 {}
| exp pv                      {}
| aff pv                      {}
| ret pv                      {}
| cond                        {}
| loop                        {}
| pv                          {}
;

ao : AO { depth++; printf("SAVEBP // entering block\n"); }
;

af : AF { printf("RESTOREBP // exiting block\n"); depth--; }
;

// IV.1 Affectations

aff : ID EQ exp               {
  attribute attr = get_symbol_value($1);
  if (attr == NULL) yyerror("Variable non déclarée");
  
  if (attr->type == INT && $3 == FLOAT) {
    yyerror("Type incompatible: cannot assign float to int");
  } else if (attr->type == FLOAT && $3 == INT) {
    printf("I2F2 // converting second arg to float\n");
  }

  if (attr->depth == 0) {
      printf("LOADI(%d)\n", attr->offset); 
  } else {
      printf("LOADBP\n");
      int diff = depth - attr->depth;
      while (diff > 0) {
          printf("LOAD\n");
          diff--;
      }       
      printf("SHIFT(%d)\n", attr->offset); 
  }
  printf("STORE\n");
}
;

// IV.2 Return

ret : RETURN exp             
{
    if (strcmp(current_fun_name, "main") == 0) {
        printf("return;\n");
    }
    else {
        attribute attr = get_symbol_value(current_fun_name);
        int nb_params = attr->offset;
        
        printf("LOADBP\n");
        int d = depth;
        while (d > 1) { 
            printf("LOAD // remonte au parent (depth %d -> %d)\n", d, d-1);
            d--;
        }
        printf("SHIFT(%d)\n", -(nb_params + 1));
        printf("STORE // ecriture valeur de retour\n");
        
        d = depth;
        while (d > 0) {
            printf("RESTOREBP // fermeture bloc depth %d\n", d);
            d--;
        }
        printf("return;\n");
    }
}
;

// IV.3. Conditionelles

cond :
  IF PO bool_exp PF 
    { 
      printf("True_%d:\n", $3); 
    }
  inst  
  else_part
    {
    }
;

else_part : 
  ELSE 
  { 
    int id = $<label_value>-3; 
    printf("GOTO(End_%d)\n", id);
    printf("False_%d:\n", id);
  }
  inst              
  {
    int id = $<label_value>-3; 
    printf("End_%d:\n", id);
  }
| %prec IFX   
  { 
    int id = $<label_value>-3;
    printf("False_%d:\n", id);
  } 
;

// IV.4. Iterations

loop : 
    WHILE 
    {
      $1 = label_count++; 
      printf("StartLoop_%d:\n", $1);
    }
    PO bool_exp PF 
    {
      printf("True_%d:\n", $4);
    }
  inst
    {
      printf("GOTO(StartLoop_%d)\n", $1);
      printf("False_%d:\n", $4);
    }
;

// V. Expressions

// V.1 Expressions Arithmétiques

exp : MOINS exp %prec UNA       { 
    if ($2 == INT) printf("MINUSI\n");
    else printf("MINUSF\n");
    $$ = $2;
  }
  | exp PLUS exp                {$$ = make_code_aryth($1, "ADD", $3);}
  | exp MOINS exp               {$$ = make_code_aryth($1, "SUB", $3);}
  | exp STAR exp                {$$ = make_code_aryth($1, "MULT", $3);}
  | exp DIV exp                 {$$ = make_code_aryth($1, "DIV", $3);}
  | PO exp PF                   { $$ = $2; }
  | ID                          {
    attribute attr = get_symbol_value($1);
    if (attr == NULL) yyerror("Variable non déclarée");
    
    if (attr->depth == 0) {
        printf("LOADI(%d)\n", attr->offset); 
    } else {
        printf("LOADBP\n");
        int diff = depth - attr->depth;
        while (diff > 0) {
            printf("LOAD\n");
            diff--;
        }               
        printf("SHIFT(%d)\n", attr->offset); 
    }
    printf("LOAD\n");
    $$ = attr->type;
  }
  | app                         {}
  | NUM                         {printf("LOADI(%i)\n",$1); $$ = INT;}
  | DEC                         {printf("LOADF(%f)\n",$1); $$ = FLOAT;}
;

// V.2.bis Booléens Paresseux (bool_exp)

bool_exp : 
  exp INF exp {
      $$ = new_bool();
      make_code_comp($1, "LT", $3); 
      printf("IFN(False_%d)\n", $$); 
      printf("GOTO(True_%d)\n", $$);
  }
| exp SUP exp {
      $$ = new_bool();
      make_code_comp($1, "GT", $3);
      printf("IFN(False_%d)\n", $$);
      printf("GOTO(True_%d)\n", $$);
  }
| exp EQUAL exp {
      $$ = new_bool();
      make_code_comp($1, "EQ", $3);
      printf("IFN(False_%d)\n", $$);
      printf("GOTO(True_%d)\n", $$);
  }
| exp DIFF exp {
      $$ = new_bool();
      make_code_comp($1, "NEQ", $3);
      printf("IFN(False_%d)\n", $$);
      printf("GOTO(True_%d)\n", $$);
  }
| bool_exp AND 
  { printf("True_%d:\n", $1); } 
  bool_exp 
  {
      $$ = $4;
      printf("False_%d: GOTO(False_%d)\n", $1, $4);
  }
| bool_exp OR 
  { printf("False_%d:\n", $1); } 
  bool_exp 
  {
      $$ = $4;
      printf("True_%d: GOTO(True_%d)\n", $1, $4);
  }
| NOT bool_exp {
      $$ = new_bool();
      printf("True_%d: GOTO(False_%d)\n", $2, $$);
      printf("False_%d: GOTO(True_%d)\n", $2, $$);
  }
| PO bool_exp PF { $$ = $2; }
| exp {
      $$ = new_bool();
      printf("IFN(False_%d)\n", $$);
      printf("GOTO(True_%d)\n", $$);
  }
;

// V.3 Applications de fonctions

app : ID PO 
      { 
        attribute attr = get_symbol_value($1);
        if (attr == NULL) yyerror("Function undeclared");
        
        if (attr->type == INT) printf("LOADI(0)\n");
        else if (attr->type == FLOAT) printf("LOADF(0.0)\n");
      }
      args PF          
      {
        attribute attr = get_symbol_value($1);
        printf("SAVEBP\n");
        printf("CALL(pcode_%s)\n", $1);
        printf("RESTOREBP\n");
        printf("DROP(%d) // nettoyage args\n", $4);
        $$ = attr->type;
      }
;

args :  arglist               { $$ = $1; }
|                             { $$ = 0; }
;

arglist : arglist VIR exp     { $$ = $1 + 1; }
| exp                         { $$ = 1; }
;

%% 

int main () {
char * header=
"// Begin PCode Header\n\
#include \"PCode.h\"\n\
\n\
void pcode_main();\n\
void init_glob_var();\n\
\n\
int main() {\n\
init_glob_var();\n\
pcode_main();\n\
return stack[sp-1].int_value;\n\
}\n\
// End PCode Header\
\n";  

printf("%s\n",header); 
return yyparse (); 
}