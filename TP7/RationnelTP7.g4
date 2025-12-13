/*
        TP6 - Langage Rationnel
    Par Mure Dylan 
    Et LARGERON Jean-Baptiste
 */


/*

    On finit le TP6 et on à commencé le TP7 en parrallele.
    On rend la version qui compile.
 */



grammar RationnelTP7;

@parser::header {
    import java.io.BufferedWriter;
    import java.io.FileWriter;
    import java.io.IOException;
    import java.lang.StringBuilder;
    import java.util.Map;
    import java.util.HashMap;
}

@parser::members {
    private int labelCounter = 0;
    private int currentAddr = 0;


    static class VarInfo{ //class pour avoir les infos des variables stockées dans HashMap
        String types; //Entier / Bool / Rationnel
        int address;
    
        public VarInfo(String t, int a ){
            this.address = a;
            this.types = t;
        }
    }


    private Map<String,VarInfo> symbolTable = new HashMap<>();


    private String newLabel() {
        return "L" + (labelCounter++);
    }
    private boolean isNextType( String type){
        String nextVar = _input.LT(1).getText();
        VarInfo v = symbolTable.get(nextVar);
        return v != null && v.types.equalsIgnoreCase(type);
    }

    // Pour écrire dans le fichier MVAP :
    private void writeFile(String code) {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter("prog.mvap"))) {
            bw.write(code);
        } catch (IOException e) {
            System.err.println(" ERREUR ECRITURE FICHIER :" + e.getMessage());
        }
    }
}

// #################### Start :

start returns [StringBuilder code]
@init {
    $code = new StringBuilder();
    $code.append("ALLOC 100\n");
}
@after {
    // Pour terminer avec HALT dans le code MVAP
    $code.append("HALT\n");
    writeFile($code.toString());
}
    :   (instr=instruction { 
            if($instr.code != null){
            $code.append($instr.code.toString()); }
            }
        )*
        EOF
    ;


declaration returns [ StringBuilder code ]
@init{ $code = new StringBuilder(); }
  : t=TYPE id1=ID (','nextId = ID)*';' {
        if(symbolTable.containsKey($id1.text)){
            System.err.println("ERROR : Varriable" + $id1.text + " already used ");   
        } else {
            VarInfo var = new VarInfo($t.text,currentAddr);
            symbolTable.put($id1.text, var);

            if($t.text.equals("RAT")){currentAddr += 2;}
            else{currentAddr ++;}

        }

        if(symbolTable.containsKey($nextId.text)){
            System.err.println("ERROR : Var " + $nextId.text + "already used");
        }
        else{
            VarInfo var2 = new VarInfo($t.text, currentAddr);
            symbolTable.put($nextId.text,var2);

            if($t.text.equals("RAT")){currentAddr += 2;}
            else{currentAddr ++;}

            
        }
  
      }

    
    ;



affectation returns[StringBuilder code]
    : id = ID '=' e=expr ';' {
        $code = $e.code;

        VarInfo var = symbolTable.get($id.text);
        if(var == null){ 
            System.err.println("ERROR : var "+ $id.text + " not defined");
        } else {
            String typeVar = var.types;
            String typeExpr = $e.type;

            if(!typeVar.equals(typeExpr)){
                System.err.println("ERROR TYPE : " + $id.text + " is type :" + typeVar + " but expression attended was : " + typeExpr);
            }

            if(typeVar.equals("RAT")){
                $code.append("STOREG " + (var.address +1)+ "\n");
                $code.append("STOREG " + var.address + "\n");
            }else{
                $code.append("STOREG " + var.address + "\n");
            }
        }
    }
    ;

instr_cond returns [StringBuilder code]
    :   cond = expr_Bool '?' then = bloc_instr (':' sinon=bloc_instr)?
    {
        $code = $cond.code;
        String labelElse = newLabel();
        String labelEnd = newLabel();

        
        $code.append("JUMPF " + labelElse + "\n");

        //partie du alors
        $code.append($then.code);
        $code.append("JUMP " + labelEnd + "\n");

        //partie du sinon
        $code.append(labelElse + "\n");
        if($sinon.text != null){
            $code.append($sinon.code);
        }else {

        }
        $code.append(labelEnd + "\n");

    }
    ;

//plus simple avec cette regle

bloc_instr returns [StringBuilder code]
    @init {$code = new StringBuilder();}
    :   i = instruction {$code.append($i.code); }
    |   b = bloc        { $code = $b.code; }
    ;


bloc returns [StringBuilder code]
    @init{$code = new StringBuilder();}
    : '{' (instruction)+ '}' {$code.append( $instruction.code);}
    ;



instr_boucle returns[StringBuilder code] 
    : 'repeter' body=bloc_instr 'jusque' cond = expr_Bool
        {
            String labelStart = newLabel();
            $code = new StringBuilder();

            $code.append(labelStart + ": \n");
            $code.append($body.code);
            $code.append($cond.code);
            $code.append("JUMPF " + labelStart + "\n");
        }
    ;

instr_boucle_pour returns[StringBuilder code]
    : 'Pour' id = ID '=' starter=expr_Int '..' end=expr_Int 'Faire' body=bloc_instr 
    { 
        $code = new StringBuilder();
        VarInfo v = symbolTable.get($id.text);

        String labelStart = newLabel();
        String labelEnd = newLabel();

        //initialisation

        $code.append($starter.code);
        $code.append("STOREG " + v.address + "\n");

        //label de debut

        $code.append(labelStart + "\n");

        //Test : index < fin (on fait index <fin -> index - fin < 0)

        $code.append("PUSHG " + v.address + "\n");
        $code.append($end.code);
        $code.append("SUB \n");
        $code.append("PUSHI 0\n");


        //si index >= fin on jump a la suite

        $code.append("NOT \n");
        $code.append("JUMPF " +labelEnd + "\n");

        //coeur de la boucle
        $code.append($body.code);

        //incrémentation

        $code.append("PUSHG " + v.address + "\n");
        $code.append("PUSHI 1\n");
        $code.append("ADD \n ");
        $code.append("STOREG " + v.address + "\n");

        //apres instruction on retourne au début de la boucle pour re-test
        $code.append("JUMP " + labelStart + "\n");

        //si c'est fini on va à l'étiquette de fin

        $code.append(labelEnd + "\n");
    }
    ;


instruction returns [StringBuilder code]
    :   AFFICHER '(' e=expr ')' ';'
        {
            $code = $e.code;
            if ($e.type.equals("INT") || $e.type.equals("BOOL")) {
                $code.append("WRITE\n");
                $code.append("POP\n");
            } else if ($e.type.equals("RAT")) {
                // Dans la pile on stocke le numérateur puis le dénominateur, donc numérateur dessous dans la pile :
                // Pour afficher Numérateur puis Dénominateur :
                $code.append("STOREG 1\n");  // Dénominateur -> mem[1]
                $code.append("STOREG 0\n");  // Numérateur -> mem[0]
                $code.append("PUSHG 0\n");
                $code.append("WRITE\n");  // On affiche le Numérateur
                $code.append("POP\n");
                $code.append("PUSHG 1\n");   
                $code.append("WRITE\n"); // On affiche le Dénumérateur
                $code.append("POP\n");
            }
        }
    | decl=declaration {
        $code = $decl.code; //la decl ne genere pas de code MVaP, on renvoie une chaine vide
     }
    |a =affectation  {$code = $a.code;}
    |c = instr_cond {$code = $c.code;}
    |l = instr_boucle ';'{$code = $l.code;}
    | bloc{$code = $bloc.code;}
    | p = instr_boucle_pour {$code = $p.code;}
    ;

// #################### Type d'expression :
expr returns [StringBuilder code, String type]
    :   b=expr_Bool
        {
            $code = $b.code;
            $type = "BOOL";
        }
    |   i=expr_Int
        {
            $code = $i.code;
            $type = "INT";
        }
    |   r=expr_Rat
        {
            $code = $r.code;
            $type = "RAT";
        }
    ;

// #################### EXPR ENTIER :
expr_Int returns[StringBuilder code]
    : l= term_Int {$code = $l.code ;}
    ( '+' r = term_Int{
        $code.append($r.code);
        $code.append("ADD \n");
    }
     | '-' r2 = term_Int{
        $code.append($r2.code);
        $code.append("ADD \n");
        }
        
        )* 
    ;


term_Int returns[StringBuilder code]
    : l = fact_int {$code = $l.code;}
    ('*' r = term_Int{
        $code.append($r.code);
        $code.append("MUL \n");

    } 
    | '/' r2 = fact_int{
        $code.append($r2.code);
        $code.append("DIV \n");
    }
    )*
    ;
fact_int returns [StringBuilder code]
    :   '(' e=expr_Int ')'
        { $code = $e.code; }
    |   ENTIER
        {
            $code = new StringBuilder();
            $code.append("PUSHI ");
            $code.append($ENTIER.text);
            $code.append("\n");
        }
    |   NUM '(' r=expr_Rat ')'
        {
            // on cacule l'expression rationnel puis on garde le numérateur
            $code = $r.code;
            $code.append("STOREG 1\n");  // den
            $code.append("STOREG 0\n");  // num
            $code.append("PUSHG 0\n");   // num
        }
    |   DENUM '(' r=expr_Rat ')'
        {
            // on cacule l'expression rationnel puis on garde le dénominateur
            $code = $r.code;
            $code.append("STOREG 1\n");  // den
            $code.append("STOREG 0\n");  // num
            $code.append("PUSHG 1\n");   // den
        }
    |   LIRE '(' ')'
        {
            $code = new StringBuilder();
            $code.append("READ\n");
        }
    |   
            {isNextType("INT")}?
        ID
            {
                $code = new StringBuilder();
                VarInfo v2 = symbolTable.get($ID.text);
                $code.append("PUSHG " + v2.address + "\n");
            }
        
    ;

// #################### EXPR RATIONNEL

// Priorité avec () puis ** puis *,: puis +,-

expr_Rat returns [StringBuilder code]
    :   left=expr_RatAddSub
        { $code = $left.code; }
    ;

expr_RatAddSub returns [StringBuilder code]
    :   left=expr_RatMulDiv
        { $code = $left.code; }
        (   '+' right=expr_RatMulDiv
            {
                // On additionne des rationnelles donc n1/d1 + n2/d2 :
                $code.append($right.code.toString());
                $code.append("STOREG 3\n"); // d2
                $code.append("STOREG 2\n"); // n2
                $code.append("STOREG 1\n"); // d1
                $code.append("STOREG 0\n"); // n1

                // On calcule le numérateur = n1*d2 + n2*d1
                $code.append("PUSHG 0\nPUSHG 3\nMUL\n");
                $code.append("PUSHG 2\nPUSHG 1\nMUL\n");
                $code.append("ADD\n");

                // On calcule le dénumérateur = d1*d2
                $code.append("PUSHG 1\nPUSHG 3\nMUL\n");
            }
        |   '-' right=expr_RatMulDiv
            {
                // On soustrait des rationnelles donc n1/d1 - n2/d2 :
                $code.append($right.code.toString());
                $code.append("STOREG 3\n"); // d2
                $code.append("STOREG 2\n"); // n2
                $code.append("STOREG 1\n"); // d1
                $code.append("STOREG 0\n"); // n1

                // On calcule le numérateur = n1*d2 - n2*d1
                $code.append("PUSHG 0\nPUSHG 3\nMUL\n");
                $code.append("PUSHG 2\nPUSHG 1\nMUL\n");
                $code.append("SUB\n");

                // On calcule le dénumérateur = d1*d2
                $code.append("PUSHG 1\nPUSHG 3\nMUL\n");
            }
        )*
    ;

expr_RatMulDiv returns [StringBuilder code]
    :   left=expr_RatPow
        { $code = $left.code; }
        (   '*' right=expr_RatPow
            {
                // On multiplie des rationnelles donc n1/d1 * n2/d2 :
                $code.append($right.code.toString());
                $code.append("STOREG 3\n"); // d2
                $code.append("STOREG 2\n"); // n2
                $code.append("STOREG 1\n"); // d1
                $code.append("STOREG 0\n"); // n1
                
                // On calcule le numérateur = n1*n2
                $code.append("PUSHG 0\nPUSHG 2\nMUL\n");

                // On calcule le dénumérateur = d1*d2
                $code.append("PUSHG 1\nPUSHG 3\nMUL\n");
            }
        |   ':' right=expr_RatPow
            {
                // On divise des rationnelles donc n1/d1 : n2/d2 (= (n1*d2)/(d1*n2))
                $code.append($right.code.toString());
                $code.append("STOREG 3\n"); // d2
                $code.append("STOREG 2\n"); // n2
                $code.append("STOREG 1\n"); // d1
                $code.append("STOREG 0\n"); // n1

                // On calcule le numérateur = n1*d2
                $code.append("PUSHG 0\nPUSHG 3\nMUL\n");
                // On calcule le dénumérateur =  d1*n2
                $code.append("PUSHG 1\nPUSHG 2\nMUL\n");
            }
        )*
    ;

expr_RatPow returns [StringBuilder code]
    :   base=expr_RatBase
        { $code = $base.code; }
        (   '**' exp=ENTIER
            {
                int n = Integer.parseInt($exp.text);

                if (n == 0) { // Si puissance 0 on renvoie 1/1 :
                    $code = new StringBuilder();
                    $code.append("PUSHI 1\nPUSHI 1\n");

                } else if (n > 1) {

                    // On suppose que sur la pile on à base : (num,den). On sauvegarde :
                    $code.append("STOREG 1\n"); // den
                    $code.append("STOREG 0\n"); // num

                    // Résultat initial = base
                    $code.append("PUSHG 0\nPUSHG 1\n"); // num den

                    // On va multiplier n-1 fois par la base :
                    for (int i = 1; i < n; i++) {

                        // Multiplie le numérateur et dénominateur courant par la base dans mem[0],mem[1]
                        $code.append("STOREG 3\n"); // dr
                        $code.append("STOREG 2\n"); // nr
                        $code.append("PUSHG 0\nPUSHG 1\n"); // nb db
                        $code.append("STOREG 5\n"); // db
                        $code.append("STOREG 4\n"); // nb

                        // On calcule le numérateur = nr * nb
                        $code.append("PUSHG 2\nPUSHG 4\nMUL\n");
                        // On calcule le dénominateur = dr * db
                        $code.append("PUSHG 3\nPUSHG 5\nMUL\n");
                    }
                }
            }
        )?
    ;

expr_RatBase returns [StringBuilder code]
    :   '(' r=expr_Rat ')'
        { $code = $r.code; }
    |   n=ENTIER '/' m=ENTIER
        {
            $code = new StringBuilder();
            $code.append("PUSHI ");
            $code.append($n.text);
            $code.append("\nPUSHI ");
            $code.append($m.text);
            $code.append("\n");
        }
    |   ENTIER
        {
            // On interpréte l'entier comme n/1
            $code = new StringBuilder();
            $code.append("PUSHI ");
            $code.append($ENTIER.text);
            $code.append("\nPUSHI 1\n");
        }
    |   LIRE '(' ')'
        {
            $code = new StringBuilder();
            $code.append("READ\n"); // num
            $code.append("READ\n"); // den
        }
    |   
        {isNextType("RAT")}?

        ID
            
        { 
            $code = new StringBuilder();
            VarInfo v2 = symbolTable.get($ID.text);            
            $code.append("PUSHG " + v2.address + "\n"); //Numérateur
            $code.append("PUSHG " + (v2.address+1) + "\n"); //Dénominateur

        }
    ;

// #################### BOOL

// Priorité : non > et > ou

expr_Bool returns [StringBuilder code]

    // ()
    :   '(' e=expr_Bool ')'
        {
            $code = $e.code;
        }

    // NOT
    |   NON e=expr_Bool
        {
            $code = $e.code;
            $code.append("PUSHI 0\nEQUAL\n"); 
        }

    // AND
    |   a=expr_Bool ET b=expr_Bool
        {
            $code = new StringBuilder();
            $code.append($a.code.toString());

            String lEvalRight = newLabel();
            String lEnd       = newLabel();

            $code.append("DUP\n");
            $code.append("PUSHI 0\nEQUAL\n");
            $code.append("JUMPF " + lEvalRight + "\n");

            $code.append("POP\n");
            $code.append("PUSHI 0\n");
            $code.append("JUMP " + lEnd + "\n");

            $code.append(lEvalRight + ":\n");
            $code.append("POP\n");
            $code.append($b.code.toString());

            $code.append(lEnd + ":\n");
        }

    // OU
    |   c=expr_Bool OU d=expr_Bool
        {
            $code = new StringBuilder();
            $code.append($c.code.toString());

            String lEvalRight = newLabel();
            String lEnd       = newLabel();

            $code.append("DUP\n");
            $code.append("PUSHI 1\nEQUAL\n");
            $code.append("JUMPF " + lEvalRight + "\n");

            $code.append("POP\n");
            $code.append("PUSHI 1\n");
            $code.append("JUMP " + lEnd + "\n");

            $code.append(lEvalRight + ":\n");
            $code.append("POP\n");
            $code.append($d.code.toString());

            $code.append(lEnd + ":\n");
        }

    |   BOOL
        {
            $code = new StringBuilder();
            if ($BOOL.text.equals("true")) {
                $code.append("PUSHI 1\n");
            } else {
                $code.append("PUSHI 0\n");
            }
        }

    |   y=expr_Rat op=OP z=expr_Rat
    {
        $code = new StringBuilder();
        $code.append($y.code.toString());
        $code.append($z.code.toString());

        $code.append("STOREG 3\n"); // d2
        $code.append("STOREG 2\n"); // n2
        $code.append("STOREG 1\n"); // d1
        $code.append("STOREG 0\n"); // n1

        String oper = $op.text;

        if (oper.equals("==")) {
            $code.append("PUSHG 0\nPUSHG 3\nMUL\n");
            $code.append("PUSHG 2\nPUSHG 1\nMUL\n");
            $code.append("EQUAL\n");

        } else if (oper.equals("<>")) {
            $code.append("PUSHG 0\nPUSHG 3\nMUL\n");
            $code.append("PUSHG 2\nPUSHG 1\nMUL\n");
            $code.append("NEQ\n");

        } else if (oper.equals("<")) {
            $code.append("PUSHG 0\nPUSHG 3\nMUL\n");
            $code.append("PUSHG 2\nPUSHG 1\nMUL\n");
            $code.append("SUB\n");
            $code.append("PUSHI 0\nINF\n");

        } else if (oper.equals("<=")) {
            $code.append("PUSHG 0\nPUSHG 3\nMUL\n");
            $code.append("PUSHG 2\nPUSHG 1\nMUL\n");
            $code.append("SUB\n");
            $code.append("PUSHI 0\nINFEQ\n");

        } else if (oper.equals(">")) {
            $code.append("PUSHG 0\nPUSHG 3\nMUL\n");
            $code.append("PUSHG 2\nPUSHG 1\nMUL\n");
            $code.append("SUB\n");
            $code.append("PUSHI 0\nSUP\n");
            
        } else if (oper.equals(">=")) {
            $code.append("PUSHG 0\nPUSHG 3\nMUL\n");
            $code.append("PUSHG 2\nPUSHG 1\nMUL\n");
            $code.append("SUB\n");
            $code.append("PUSHI 0\nSUPEQ\n");
        }
    }

    |   LIRE '(' ')'
        {
            $code = new StringBuilder();
            $code.append("READ\n");
            $code.append("PUSHI 0\nSUP\n"); // (val > 0) ? 1 : 0
        }

    |   {isNextType("BOOL")}?
        
        ID
            {

            $code = new StringBuilder();
            VarInfo var2 = symbolTable.get($ID.text);
            $code.append("PUSHG " + var2.address + "\n");

            }

        
    ;

// Opération de comparaison possible: 
OP  :   '<='
    |   '>='
    |   '<'
    |   '>'
    |   '=='
    |   '<>'
    ;

// Mots Clés :
AFFICHER : 'Afficher' ;
LIRE     : 'lire' ;
NUM      : 'num' ;
DENUM    : 'denum' ;
ET       : 'et' ;
OU       : 'ou' ;
NON      : 'non' ;
TYPE    : 'RAT' | 'INT' | 'BOOL';
BOOL    : 'true' | 'false' ;

ENTIER  : [0-9]+ ;

WS      : [ \t\r\n]+ -> skip ;

ID      : [a-zA-Z_][a-zA-Z0-9_]* ;

UNMATCH : . -> skip;
