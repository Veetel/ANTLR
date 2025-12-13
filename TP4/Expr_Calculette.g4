grammar Expr_Calculette;
/
@header{ 
    import java.util.HashMap;
    import java.util.Map;
}
@members{
    Map<String, String> types = new HashMap<>();
    Map<String, String> valeurs = new HashMap<>();
}

start : instruction (sep instruction)* sep? EOF ;

instruction
        : expr
        | 'Afficher' '(' e=expr ')'                 {System.out.println($e.val);}
        | declaration
        | affectation
        ;

declaration 
    : t=typage id=ID {types.put($id.text,$t.type);} (',' a=ID {types.put($a.text,$t.type);})*
    ;

typage returns [String type]
    : a=TYPE {$type=$a.text;}
    ;

affectation 
    : a=ID '=' b=expr { if (types.get($a.text) == null){
                            System.err.println("Erreur : Variable non déclaré");
                        }else if (!types.get($a.text).equals($b.type)) {
                            System.err.println("Erreur : Type ID ≠ Type expr");
                        } else {
                            valeurs.put($a.text, $b.val);
                        }
        }
    ;

expr returns [String val, String type] 
        : a=expr_ar                                 {$val = Integer.toString($a.val); $type="entier";}
        | b=expr_bool                               {$val = Boolean.toString($b.val); $type="booleen";}
        ;

// Priorités : not > and > or
expr_bool returns [boolean val]
    : '(' e=expr_bool ')'             { $val = $e.val; }
    |'not' e=expr_bool               { $val = !$e.val; } 
    | a=expr_bool 'and' b=expr_bool   { $val = $a.val && $b.val; } 
    | a=expr_bool 'or'  b=expr_bool   { $val = $a.val || $b.val; }
    | BOOL                                              { $val = $BOOL.text.equals("true"); }
    | c=expr_ar '<>' d=expr_ar                          { $val = $c.val != $d.val; }
    | c=expr_ar '==' d=expr_ar                          { $val = $c.val == $d.val; }
    | c=expr_ar '>=' d=expr_ar                          { $val = $c.val >= $d.val; }
    | c=expr_ar '<=' d=expr_ar                          { $val = $c.val <= $d.val; }
    | c=expr_ar '<'  d=expr_ar                          { $val = $c.val <  $d.val; }
    | c=expr_ar '>'  d=expr_ar                          { $val = $c.val >  $d.val; }
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
ENTIER  : ('0'..'9')+; // ENTIER  : '0' |  ('1'..'9')('0'..'9')*;
BOOL    : 'true' | 'false';
ID      : [a-z]+;

sep : (';' | NEWLINE) (NEWLINE)* ;

UNMATCH : . -> skip;

    