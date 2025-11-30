================================================================================
                    Compilateur de langage MyC vers PCode
================================================================================

AUTEURS:
- Raphael Bély / Enzo Picarel
- Groupe numéro 16

DESCRIPTION:
Ce projet implémente un compilateur pour le langage MyC qui génère du code
PCode (code intermédiaire basé sur une pile). 

STRUCTURE DU PROJET:
- lang.l                 : Analyseur lexical (Flex)
- lang.y                 : Analyseur syntaxique et sémantique (Bison)
- Table_des_symboles.c/h : Gestion de la table des symboles
- PCode/                 : Librairie de la machine virtuelle
  - PCode.h              : Macros et définition de la machine à pile
  - PCode.c              : Runtime
- Examples/              : Fichiers de tests (.myc)

FONCTIONNALITÉS IMPLÉMENTÉES:
- Expressions arithmétiques (int/float)
- Conversions de types implicites (Promotion int -> float)
- Variables globales (Déclaration et affectation)
- Structures de contrôle (if, if/else, while)
- Variables locales et gestion des blocs imbriqués (Scope)
- Booléens paresseux (Short-circuit evaluation && et ||)
- Fonctions non récursives (Appels, paramètres, valeur de retour)
- Gestion des types de retour (Void vs Int/Float)
- Fonctions récursives (Fibonacci, Ackermann)

COMPILATION:
Pour compiler le compilateur lui-même:
    make

Pour nettoyer les fichiers générés:
    make clean

UTILISATION:
1. Préparez un fichier source MyC (ex: ex1.myc)
2. Lancez le compilateur:
    ./runComp ex1

   Cela créera ex1_pcode.c (code C généré à partir du MyC)


SYNTAXE DU LANGAGE MyC:
- Types: int, float, void
- Variables: déclaration avant utilisation
- Fonctions: type nom(params) { corps }
- Contrôle: if/else, while
- Opérateurs: +, -, *, /, <, >, ==, !=, &&, ||, !

EXEMPLE:
    int add(int a, int b) {
        return a + b;
    }
    
    int main() {
        int res = add(5, 3);
        return res;
    }