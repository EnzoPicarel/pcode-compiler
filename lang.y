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
%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DIFF EQUAL SUP INF       // higher priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
%nonassoc ELSE


%{
char * type2string (int c) {
  switch (c)
    {
    case INT:
      return("int");
    case FLOAT:
      return("float");
    case VOID:
      return("void");
    default:
      return("type error");
    }  
};

 // dirty trick to end function init_glob_var() definition (see rule po : PO)
void end_glob_var_decl(){
  static int unfinished=1;
  if (unfinished) {
    unfinished = 0;
    printf("}\n\n");
  }
}

// Votre code C peut aller ci-dessous pour factoriser (un peu) le code des actions semantiques
 

 int make_code_aryth(int type1, const char* op, int type2) {
    int result_type;

    if (type1 == INT && type2 == INT) {
        printf("%sI\n", op);
        result_type = INT;
    } else if (type1 == FLOAT && type2 == FLOAT) {
        printf("%sF\n", op);
        result_type = FLOAT;
    } else if (type1 == INT && type2 == FLOAT) {
        printf("I2F1 // converting first arg to float\n");
        printf("%sF\n", op);
        result_type = FLOAT;
    } else if (type1 == FLOAT && type2 == INT) {
        printf("I2F2 // converting second arg to float\n");
        printf("%sF\n", op);
        result_type = FLOAT;
    } else {
        yyerror("Erreur de type pour opération binaire !");
    }

    return result_type;
}

/* Gère les comparaisons (renvoie toujours un INT) */
int make_code_rel(int type1, const char* op, int type2) {
    if (type1 == INT && type2 == FLOAT) {
        printf("I2F1 // converting first arg to float\n");
        printf("%sF\n", op);
    } 
    else if (type1 == FLOAT && type2 == INT) {
        printf("I2F2 // converting second arg to float\n");
        printf("%sF\n", op);
    } 
    else if (type1 == FLOAT && type2 == FLOAT) {
        printf("%sF\n", op);
    } 
    else {
        printf("%sI\n", op);
    }

    return INT; 
}

  %}


%start prog  

// liste de tous les type des attributs des non terminaux que vous voulez manipuler l'attribut (il faudra en ajouter plein ;-) )
%type <type_value> type exp  typename
%type <string_value> fun_head
%type <int_value> if else while

%%

 // O. Déclaration globale

prog : glob_decl_list              {}
;

glob_decl_list : glob_var_list glob_fun_list {}
;

glob_var_list : glob_var_list decl PV {}
| {printf("void init_glob_var(){\n"); // starting  function init_glob_var() definition in target code
;}

glob_fun_list : glob_fun_list fun {}
| fun {}
;

// I. Functions

fun : type fun_head fun_body   {}
;

po: PO {end_glob_var_decl();}  // dirty trick to end function init_glob_var() definition in target code
  
fun_head : ID po PF            {
  current_fun_name = $1;
  // Pas de déclaration de fonction à l'intérieur de fonctions !
  if (depth > 0) yyerror("Function must be declared at top level~!\n");
  
  printf("void pcode_%s() {\n", current_fun_name);
}

| ID po params PF              {
   current_fun_name = $1;
   // Pas de déclaration de fonction à l'intérieur de fonctions !
   if (depth > 0) yyerror("Function must be declared at top level~!\n");
   
   printf("void pcode_%s() {\n", current_fun_name);
 }
;

params: type ID vir params     {} // récursion droite pour numéroter les paramètres du dernier au premier
| type ID                      {}


vir : VIR                      {}
;

fun_body : fao block faf       {}
;

fao : AO {
  depth++;
}
;

faf : AF {
  printf("}\n");
  depth--;
}
;


// II. Block
block:
  {
    $<int_value>$ = local_offset; 
    // On commence à 1 car l'offset 0 est pris par le SAVEBP dans la pile
    local_offset = 1; 
  }
  decl_list inst_list            
  {
    // 2. SORTIE DE BLOC : Nettoyage
    // On restaure l'offset du parent (pour qu'il puisse continuer à déclarer ses variables)
    local_offset = $<int_value>1; 

  }
;

// III. Declarations

decl_list : decl_list decl PV   
    { 
    } 
|                            
    {
    }
;

decl: var_decl                  {}
;

var_decl : type vlist          {}
;

vlist: vlist vir ID            { 
  int current_offset;
  
  if (depth == 0) {
      current_offset = global_offset++;
  } else {
      current_offset = local_offset++;
  }

  attribute attr = makeSymbol(current_type, current_offset, depth);
  set_symbol_value($3, attr);

  if (current_type == INT) {
    printf("LOADI(0)\n");
  } else {
    printf("LOADF(0.0)\n");
  }
} // récursion gauche pour traiter les variables déclararées de gauche à droite
| ID                           {
    int current_offset;
  
  if (depth == 0) {
      current_offset = global_offset++;
  } else {
      current_offset = local_offset++;
  }

  attribute attr = makeSymbol(current_type, current_offset, depth);
  set_symbol_value($1, attr);
  
  if (current_type == INT) {
    printf("LOADI(0)\n");
  } else {
    printf("LOADF(0.0)\n");
  }
}
;

type
: typename                     { current_type = $$; }
;

typename // Utilisation des terminaux comme codage (entier) du type !!!
: INT                          {$$=INT;} 
| FLOAT                        {$$=FLOAT;}
| VOID                         {$$=VOID;}
;

// IV. Intructions

inst_list: inst_list inst   {} 
| inst                      {}
;

pv : PV                       {}
;
 
inst:
ao block af                   {}
| exp pv                      {}
| aff pv                      {}
| ret pv                      {}
| cond                        {}
| loop                        {}
| pv                          {}
;

// Accolades explicites pour gerer l'entrée et la sortie d'un sous-bloc

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
          printf("LOAD // accessing upper block depth %d\n", attr->depth);
          diff--;
      }       
      printf("SHIFT(%d)\n", attr->offset); 
  }
  
  printf("STORE\n");
}
;


// IV.2 Return
ret : RETURN exp              {}
| RETURN PO PF                {}
;

// IV.3. Conditionelles
//           N.B. ces rêgles génèrent un conflit déclage reduction
//           qui est résolu comme on le souhaite par un décalage (shift)
//           avec ELSE en entrée (voir y.output)

cond :
  if bool_cond 
    { 
      printf("IFN(False_%d)\n", $1); 
      printf("// la condition %d est vraie\n", $1);
    }
  inst  
  elsop       
    {
      printf("// Fin conditionelle %d\n", $1);
    }
;

elsop : 
  else 
  { 
    int id = $<label_value>-3; 
    printf("GOTO(End_%d)\n", id);
    printf("False_%d:\n", id);
    printf("// la condition %d est fausse\n", id);
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
    printf("// la condition %d est fausse\n", id);
  } 
;

bool_cond : PO exp PF         {}
;

if : IF                       
    { 
      $$ = label_count++; 
      printf("// Debut conditionelle %d\n", $$);
    }
;

else : ELSE                   {}
;

// IV.4. Iterations

loop : while while_cond 
    {
      printf("IFN(EndLoop_%d)\n", $1);
      printf("// Debut boucle while %d\n", $1);
    }
  inst
    {
      printf("GOTO(StartLoop_%d)\n", $1);
      printf("//Fin boucle while %d\n", $1);
      printf("EndLoop_%d:\n", $1);
    }
;

while_cond : PO exp PF        {}

while : WHILE                 
    { 
      $$ = label_count++; 
      printf("StartLoop_%d: // chargement condition boucle while %d\n", $$, $$); 
    }
;


// V. Expressions

// V.1 Expressions Arithmétiques

exp : MOINS exp %prec UNA       { printf("NEGI\n"); }
          // -x + y lue comme (- x) + y  et pas - (x + y)
  | exp PLUS exp                {$$ = make_code_aryth($1, "ADD", $3);}
  | exp MOINS exp               {$$ = make_code_aryth($1, "SUB", $3);}
  | exp STAR exp                {$$ = make_code_aryth($1, "MULT", $3);}
  | exp DIV exp                 {$$ = make_code_aryth($1, "DIV", $3);}
  | PO exp PF                   {}
  | ID                          {
    attribute attr = get_symbol_value($1);
    if (attr == NULL) yyerror("Variable non déclarée");
    
    if (attr->depth == 0) {
        printf("LOADI(%d)\n", attr->offset); 
    } else {
        printf("LOADBP\n");   
        int diff = depth - attr->depth;
        
        // On remonte la chaîne des BP autant de fois que nécessaire
        while (diff > 0) {
            printf("LOAD // accessing upper block depth %d\n", attr->depth);
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


// V.2. Booléens

| NOT exp %prec UNA           
    { 
      printf("NOT\n"); 
      $$ = INT; 
    }
| exp INF exp                 { $$ = make_code_rel($1, "LT", $3); }
| exp SUP exp                 { $$ = make_code_rel($1, "GT", $3); }
| exp EQUAL exp               { $$ = make_code_rel($1, "EQ", $3); }
| exp DIFF exp                { $$ = make_code_rel($1, "NEQ", $3); }
| exp AND exp                 
    { 
      if($1==FLOAT || $3==FLOAT) yyerror("Pas de ET logique sur les floats");
      printf("AND\n"); 
      $$ = INT; 
    }
| exp OR exp                  
    { 
      if($1==FLOAT || $3==FLOAT) yyerror("Pas de OU logique sur les floats");
      printf("OR\n"); 
      $$ = INT; 
    }

;

// V.3 Applications de fonctions


app : fid PO args PF          {}
;

fid : ID                      {}

args :  arglist               {}
|                             {}
;

arglist : arglist VIR exp     {} // récursion gauche pour empiler les arguements de la fonction de gauche à droite
| exp                         {}
;



%% 




int main () {

  /* Ici on peut ouvrir le fichier source, avec les messages 
     d'erreur usuel si besoin, et rediriger l'entrée standard 
     sur ce fichier pour lancer dessus la compilation.
   */

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

printf("%s\n",header); // ouput header
  
return yyparse (); // output your compilation
 
 
}

