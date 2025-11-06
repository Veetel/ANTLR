grammar Enseignant;

s returns [boolean val]:  BOOL {$val = $BOOL.text.equals("true");}
    | 'not' s {$val = ! $s.val;}
    | 'and' a=s b=s {$val = $a.val && $b.val;}
    |'or' a=s b=s {$val = $a.val || $b.val;};



WS : ('\t'|';'| ' ') -> skip;
NEWLINE : '\r'? '\n' -> skip;

BOOL  : 'true' 
| 'false';
