
// Majuscule = lexical minuscule =analyseur syntaxique
/*l'analalyseur lexical -> definit les mots/ jetons 
newline skip pour dire on gere pas le jeton si \n ou \r
ws pareil aev \t ou vide:  permet d'écrire 3 + 4 au lieu de 3+4
entier reconnait une séquence d'un ou plusieur nombre
unmatch jette tout les trucs pas reconnu par les regles precedente













*/



grammar Calculette;
start
    : expr EOF;
expr
    : '(' expr ')'| expr'*'expr | expr '/' expr |expr '+'expr | ENTIER ;

NEWLINE : '\r'? '\n'-> skip;
WS : (' '|'\t')+ -> skip;
ENTIER : ('0'..'9')+;
UNMATCH : . -> skip;


/*si permutation -> changement de sens de priorité des sexpression car ambiguité */