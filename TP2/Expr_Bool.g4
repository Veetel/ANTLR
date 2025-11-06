grammar Expr_Bool;

start returns [String val] : expr (sep expr )* EOF; 
expr returns [String val]:   
        | a = expr 'or' b = expr {$val =  "or"+ $a.val + " " + $b.val;}
        | a = expr 'and' b = expr {$val ="and " + $a.val + " " + $b.val;}
        | '(' expr ')' {$val = $expr.val;}
        'not' expr {$val = "not " + $expr.val;}
        | BOOL {$val = $BOOL.text;};



sep : (';' | '\n')+;

WS : (' '|'\t' | ';' )+ -> skip;
BOOL : 'true' | 'false';
