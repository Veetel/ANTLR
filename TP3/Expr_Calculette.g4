grammar Expr_Calculette;

start : expr (sep expr)* EOF ;


expr : expr_ar | expr_bool ;


expr_bool returns [boolean val int value]
        : a = expr_bool 'or' b = expr_bool {$val = $a.val || $b.val ;}
        | a = expr_bool 'and' b = expr_bool{$val = $a.val && $b.val ; } 
        | '(' expr_bool ')'{$val = $expr_bool.val ; }
        | 'not' expr_bool{$val = !$expr_bool.val ; }
        | BOOL {$val = BOOL.text.equals("true") ; }
        | a = expr_ar '<>' b = expr_ar {$val = !$a.value.equals($b.value);} 
        | a = expr_ar '==' b = expr_ar {$val = $a.value.equals($b.value) ;}
        | a = expr_ar '=>' b = expr_ar {$val = $b.value <= $a.value ; }
        | a = expr_ar '<=' b = expr_ar {$val = $a.value <= $b.value ; }
        | a = expr_ar '<'  b = expr_ar {$val = $a.value < $b.value ; }
        | a = expr_ar '>'  b = expr_ar {$val = $a.value > $b.value ; }
        ;

        
expr_ar returns [int val]
        :'(' expr_ar ')'{$val = $expr_ar.val ; }
        | a = expr_ar' *' b = expr_ar {$val = $a.val  * $b.val ; }
        | a = expr_ar '/' b = expr_ar {$val = $a.val  / $b.val ; }
        | a = expr_ar '+' b = expr_ar {$val = $a.val + $b.val ; }
        | a = expr_ar '-' b = expr_ar {$val = $a.val - $b.val ; }
        | '-(' expr_ar')'{$val = - $expr_ar.val ; }
        | ENTIER {$val = Integer.parseInt($ENTIER.val) ; }
        ;

sep : (';' | '\n')+;

NEWLINE : '\r'? '\n'-> skip;
WS : (' '|'\t'| ';')+ -> skip;
ENTIER : [-+]?('0'..'9')+;
BOOL : 'true' | 'false';

UNMATCH : . -> skip;
