// Pseudo code du tp7
// LARGERON Jean-Baptiste
// MURE Dylan

grammar Rationnel;

//Nous sommes actuellement encore sur le TP6 (ayant pris du retard pour des raisons
//techniques)
//voici une ébauche de ce que l'on a réfléchit a faire pour le tp 7


//on aura surement un truc comme ca mais pas sûr à 100% puisque l'un de nous est sur
//le tp précédent en même temps, certaine chose peuvent changer

@members{ 

    private int compteurLabels = 0;

    private void writeFile(String code) {
    try (BufferedWriter bw = new BufferedWriter(new FileWriter("prog.mvap"))) {
        bw.write(code);
    } catch (IOException e) {
        System.err.println("Erreur d'écriture du fichier MVAP : " + e.getMessage());
    }
}

}
instruction returns [ String code]
  : decl {$code = $decl.code;}
  | affectInt {$code = $affectInt.code;}
  | affectReg {$code = $affectReg.code;}
  | affectBool {$code = $affectBool.code;}
  | exprReg {$code = $exprReg.code;}
  | exprRegbool {$code = $exprRegbool.code;}
  | afficher {$code = $afficher.code;}
  | instr_condit {$code = $instr_condit.code;}
  | boucle {$code = $boucle.code;}
  | finInstruction { $code = ""; }
  | '{' instruction+ '}' // bloc
  ;


//avec des truc un peu comme ca

affectInt returns [String code]
@init{ $code = new String(); }
    : (ID '=' op ',' {
        if (labels.get($ID.text).getType().equals("int")){
			    int p = labels.get($ID.text).getAdresse();
          $code += $op.code + "\n" + "STOREG " + p + "\n";

		    }
        else {
           throw new RuntimeException("Ce n'est pas une variable de type entier");
        }
    })*
    (ID '=' op) ';' {
        if (labels.get($ID.text).getType().equals("int")){
			    int p = labels.get($ID.text).getAdresse();
          $code += $op.code + "\n" + "STOREG " + p + "\n";
		    }
        else {
           throw new RuntimeException("Ce n'est pas une variable de type entier");
        }
    }
;

affectReg returns [String code]
@init{ $code = new String(); }
    :  (ID '=' exprReg ',' {
          if (labels.get($ID.text).getType().equals("reg"))
          {
            int p = labels.get($ID.text).getAdresse();
            System.out.println(p);
            $code += $exprReg.code + "STOREG 1" + "\n" + "STOREG 0" + "\n" + "PUSHG 1" + "\n"
                  + "STOREG " + (p) + "\n" + "PUSHG 0" + "\n" + "STOREG " + (p-1) + "\n";          
          }
          else{
            throw new RuntimeException("Ce n'est pas une variable de type rationnel");
          }
    })*
    (ID '=' exprReg) ';' {
        if (labels.get($ID.text).getType().equals("reg"))
          {
            int p = labels.get($ID.text).getAdresse();
            $code += $exprReg.code + "STOREG 1" + "\n" + "STOREG 0" + "\n" + "PUSHG 1" + "\n"
                  + "STOREG " + (p) + "\n" + "PUSHG 0" + "\n" + "STOREG " + (p-1) + "\n";          
          }
          else
          {
            throw new RuntimeException("Ce n'est pas une variable de type rationnel");
          }
    }
;

affectBool returns [String code]
@init{ $code = new String(); }
  :  (ID '=' exprRegbool ',' {
    if (labels.get($ID.text).getType().equals("bool")){
        int p = labels.get($ID.text).getAdresse();
        $code += $exprRegbool.code + "\n" + "STOREG " + p + "\n";
    }
    else if (labels.get($ID.text).getType().equals("reg"))
    {
      throw new RuntimeException("Ce n'est pas une variable de type booléen");
    }
  })*
    (ID '=' exprRegbool) ';' {
      if (labels.get($ID.text).getType().equals("bool")){
        int p = labels.get($ID.text).getAdresse();
        $code += $exprRegbool.code + "\n" + "STOREG " + p + "\n";
      }
      else if (labels.get($ID.text).getType().equals("reg"))
      {
        throw new RuntimeException(" variable non booléenne");
      }
    }
;

boucle returns [String code]
  : a=repeterInstru b=jusqueInstru ';' {$code = $a.code + $b.code;}
;

repeterInstru returns [String code]
  : 'repeter'
      {$code = "LABEL " + (compteur_Label) + "\n" ;}
      (instruction  {$code += $instruction.code ;})+
  ;

jusqueInstru return [String code]
    :'jusque' exprReg {$code = "JUMPF" + compteurLabel++;} 
    //il faudra jumpf à l'adresse du répéter qui devra être initialiser avant
    ;

decl returns [ String code ]
@init{ $code = new String(); }
  : TYPE ID ';' {
      if (($TYPE.text).equals("int") || ($TYPE.text).equals("bool")){
		    $code += "PUSHI 0" + "\n";     
        labels.put($ID.text, new MonType($TYPE.text, instrAddress));
        instrAddress = instrAddress + 1;
        cmp_decla += 1;
      }
      else {
		    $code += "PUSHI 0" + "\n";     
        labels.put($ID.text, new MonType($TYPE.text, instrAddress));
        instrAddress = instrAddress + 2;
        $code += "ALLOC 1\n";
        cmp_decla += 2;
      }}
    | TYPE ID (ID)
    |// voir s'il n'y a pas d'autre cas, on y a pas encore reflechit
    ;



TYPE : 'int' | 'reg' | 'bool';
ID : [a-zA-Z_][a-zA-Z_0-9]*;
NEWLINE : '\r'? '\n';
WS : (' '|'\t')+ -> skip;
ENTIER : ('0'..'9')+;
BOOLEAN : '0' | '1';
FININSTRUCTIONS : ';';
UNMATCH : . -> skip;