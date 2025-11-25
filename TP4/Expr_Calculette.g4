grammar Expr_Calculette;

start : instruction (sep instruction)* sep? EOF ;

instruction
        : expr
        | 'Afficher' '(' e=expr ')'                 {System.out.println($e.val);}
        | declaration
        | affectation
        ;

declaration 
    : t=typage id1=ID suite_id[$t.type]
    ;

typage returns [String type]
    : TYPE { $type = $TYPE.text; }
    ;

suite_id[String typeVar]
    : ',' ID suite_id[$typeVar]
    |
    ;

affectation 
    : ID '=' expr
    ;

expr returns [String val, String type] 
        : a=expr_ar                                 {$val = Integer.toString($a.val); $type="entier";}
        | b=expr_bool                               {$val = Boolean.toString($b.val); $type="booleen";}
        ;

// Priorités : not > and > or
expr_bool returns [boolean val]
    : o=orExpr { $val = $o.val; }
    ;

orExpr returns [boolean val]
    : a=andExpr { $val = $a.val; } ('or' b=andExpr { $val = $val || $b.val; })*
    ;

andExpr returns [boolean val]
    : a=notExpr { $val = $a.val; } ('and' b=notExpr { $val = $val && $b.val; })*
    ;

notExpr returns [boolean val]
        : 'not' g=notExpr                 { $val = !$g.val; }
        | '(' e=expr_bool ')'             { $val = $e.val; }
        | BOOL                            { $val = $BOOL.text.equals("true"); }
        | c=expr_ar '<>' d=expr_ar        { $val = $c.val != $d.val; }
        | c=expr_ar '==' d=expr_ar        { $val = $c.val == $d.val; }
        | c=expr_ar '>=' d=expr_ar        { $val = $c.val >= $d.val; }
        | c=expr_ar '<=' d=expr_ar        { $val = $c.val <= $d.val; }
        | c=expr_ar '<'  d=expr_ar        { $val = $c.val <  $d.val; }
        | c=expr_ar '>'  d=expr_ar        { $val = $c.val >  $d.val; }
        ;

// Priorités : * / > + - 
expr_ar returns [int val]
    : c=multExpr { $val = $c.val; } ('+' d=multExpr { $val = $val + $d.val; }| '-' d=multExpr { $val = $val - $d.val; })*
    ;

multExpr returns [int val]
    : c=entExpr { $val = $c.val; } ('*' d=entExpr { $val = $val * $d.val; }| '/' d=entExpr { $val = $val / $d.val; } )*
    ;

entExpr returns [int val]
    : ENTIER { $val = Integer.parseInt($ENTIER.text); } 
    | '-' f=entExpr                         { $val = -$f.val; } 
    | '(' e=expr_ar ')'                 { $val = $e.val; }
    ;


NEWLINE : '\r'? '\n';
WS      : (' ' | '\t')+ -> skip;

TYPE    : 'entier' | 'booleen';
ENTIER  : ('0'..'9')+;
BOOL    : 'true' | 'false';
ID      : [a-z]+;

sep : (';' | NEWLINE)+;

UNMATCH : . -> skip;

