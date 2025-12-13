
grammar Rationnel;

@header{
    import java.util.*;
    import java.io.FileOutputStream;
    import java.io.FileWriter;
    import java.io.File;

}

@parser::members{


  /** La map pour mémoriser les addresses des étiquettes */
    private HashMap<String, MonType> labels = new HashMap<String, MonType>();

    /** adresse instruction */
    private int instrAddress = 8; //on commence à 8 car les précédentes cases sont réservées pour les calculs
    private int cmp_decla = 8; //car déjà alloué 8
    private int cmpt_label = 20;

  public class MonType {
    		private String type;
    		private int adresse;
        private String valeur;

    		public MonType(String t, int adresse) {
        		this.type = t;
        		this.adresse = adresse;
    		}

    		// Getter pour le identifiant
    		public String getType() {
        		return type;
    		}

    		// Getter pour l'adresse
    		public int getAdresse() {
        		return adresse;
    		}

	}

  String calculerPGCD(String c_code, String d_code) {
      String code =
                /// pgcd x,n
                // mémoire
                // ?, ?, ?, ?, ?, ?
                // stocker le x et n finale
                // entete de la pile x puis enbas n
                c_code +
                "STOREG 0\n" + // stocker x
                d_code +
                "STOREG 1\n" + // stocker n
                // x, n, ?, ?, ?, ?
                "LABEL 6\n" +
                "PUSHG 1\n" + // pousser n
                "JUMPF 7\n" + // si n est 0 pas de calcul
                // modulo
                "PUSHG 1\n" + // pousse n
                "STOREG 4\n" + // ajoute l'ancien n
                // x, n, ?, ?, n_ancier, ?
                "PUSHG 0\n" + // pousse x
                "PUSHG 1\n" + // pousse n
                "DIV\n" +
                "STOREG 2\n" + // on ajoute le résultat du quotient à l'adresse 2
                // x, n, quotient, ?, n_ancier, ?
                "PUSHG 2\n" + // pouusse le quotion
                "PUSHG 1\n" + // on poussse n
                "MUL\n" + // multiplie par n
                "STOREG 3\n" + // stocke  produit à l'adresse 3
                // x, n, quotient, produit, n_ancier, ?
                "PUSHG 0\n" + // on pousse x
                "PUSHG 3\n" + // on pousse le produit
                "SUB\n" + // on soustrait de x le produit
                "STOREG 1\n" +
                // x, n_nouv, quotient, produit, n_ancier, ?
                "PUSHG 4\n" + //  // Pousse l'ancien n
                "STOREG 0\n" + // Stocke l'ancien n dans nouveau x à l'adresse 0
                // x_remplacer, n_nouv, quotient, produit, n_ancier, ?
                "JUMP 6\n" + // RECOMMENCER
                "LABEL 7\n" +
                "PUSHG 0\n" ; // pgcd
      return code;
  }

  String calculerPPCM(String c_code, String d_code) {
    String code =
                c_code +
                "STOREG 4\n" + // stocker x
                d_code +
                "STOREG 5\n" + // stocker n
                /// pgcd x,n
                // mémoire
                // 0, 1, 2, 3, 4, 5, 6
                // ?, ?, ?, ?, x, n, ?
                // stocker le x et n finale
                // entete de la pile x puis enbas n
                "PUSHG 4\n" +
                "STOREG 0\n" + // stocker x
                "PUSHG 5" +
                "STOREG 1\n" + // stocker n
                // 0, 1, 2, 3, 4, 5, 6
                // x, n, ?, ?, x, n, ?
                "LABEL 8\n" +
                "PUSHG 1\n" +
                "JUMPF 9\n" +
                // modulo
                "PUSHG 1\n" + // pousse n
                "STOREG 3\n" + // ajoute l'ancien n
                // 0, 1, 2, 3, 4, 5, 6
                // x, n, ?, n_ancier, x, n, ?
                "PUSHG 0\n" + // pousse x
                "PUSHG 1\n" + // pousse n
                "DIV\n" +
                "STOREG 2\n" + // on ajoute le résultat du quotient à l'adresse 2
                // 0, 1, 2, 3, 4, 5, 6
                // x, n, qotient, n_ancier, x, n, ?
                "PUSHG 2\n" + // pouusse le quotion
                "PUSHG 1\n" + // on poussse n
                "MUL\n" + // multiplie par n
                "STOREG 2\n" + // stocke  produit à l'adresse 3
                // x, n, produit, n_ancier, x, n, ?
                // x, n, quotient, produit, n_ancier, x, n
                "PUSHG 0\n" + // on pousse x
                "PUSHG 2\n" + // on pousse le produit
                "SUB\n" + // on soustrait de x le produit
                "STOREG 1\n" +
                // x, n_nouv, produit, n_ancier, x, n, ?
                // x, n_nouv, quotient, produit, n_ancier, x, n
                "PUSHG 3\n" + //  // Pousse l'ancien n
                "STOREG 0\n" + // Stocke l'ancien n dans nouveau x à l'adresse 0
                // x_remplacer, n_nouv, produit, n_ancier, x, n, ?
                //"PUSHI 0\n" + a voir
                "JUMP 8\n" + // RECOMMENCER
                "LABEL 9\n" +
                // x_remplacer, n_nouv, produit, n_ancier, x, n, ?
                "PUSHG 4\n" +
                "PUSHG 5\n" +
                "MUL\n" +
                "PUSHG 0\n" + // le PGCD
                "DIV\n" ;
    return code;
  }


  String simplifierRationnel(String numerateur, String denominateur) {
        String code = calculerPGCD(numerateur, denominateur);
        // x_remplacer, n_nouv, quotient, produit, n_ancier, ?
        // pgcd, ?, ?, ?, ?, ?
        code +=
          "STOREG 0\n" + // pgcd, ?, ?, ?, ?, ?  mettre le pgcd a l'addresse 0 tampon
          "PUSHI " + numerateur + "\n" +
          "PUSHG 0\n" + //pgcd
          "DIV\n"+
          "STOREG 1\n" + // pgcd, num, ?, ?, ?, ?
          "PUSHI " + denominateur + " \n" +
          "PUSHG 0\n" +
          "DIV\n"+
          "STOREG 2\n" + // pgcd, num, denum, ?, ?, ?
          "PUSHG 1\n" + // num
          "PUSHG 2\n"; // deno
        return code;
  }

  String calcul_pourcentage(String a_code, String b_code) {
    String code = simplifierRationnel(a_code, b_code);
    code +=
            "STOREG 1\n" + // mettre le denominateur a l'adress 1
            "STOREG 0\n" + // mettre le numerateur a l'adresse 0
            "PUSHG 0\n" +
            "PUSHI 100\n" +
            "MUL\n" +
            "PUSHG 1\n" +
            "PUSHI 2\n" +
            "DIV\n"+
            "ADD\n"+
            "PUSHG 1\n"+
            "DIV\n";
    return code;
  }

  String calcul_expr_reg_bool(String e_code, String f_code, String operateur)
  { // bien vérifier. 3,4 pt 2
    String code = "";
    if(operateur == "and") {
      code +=
          e_code +
          "JUMPF 13\n" + // Si e_code est faux, on saute à l'étiquette 13
          "JUMP 16\n" + // On saute à l'étiquette 16
          "LABEL 13\n" +
            f_code +
            "JUMPF 14\n" + // Si f_code est faux, on saute à l'étiquette 14
            "JUMP 15\n" + // Si e_code faux et f_code vrai, on pousse 0
          "LABEL 14\n" +
            "PUSHI 1\n" + // Si e_code et f_code est faux, on pousse 1
            "POP\n" +
            "JUMP 16" +
          "LABEL 15\n" +
            "PUSHI 0\n" +
            "POP\n" +
            "JUMP 16\n" +
          "LABEL 16";
    }
    else if (operateur == "or") {
      code +=
              e_code +
              "JUMPF 17\n" +
              "PUSHI 1\n" +
              "JUMP 12\n" + // Si e_code est vrai, on saute à l'étiquette 12
              "LABEL 17\n" +
                f_code +
                "STOREG 1\n" + // on stocke la valuer boolean de f_code
                "PUSHG 0\n" +
                "PUSHG 1\n" +
                "ADD\n" +
              "LABEL 12\n" +
                "POP\n";
    }
    else {
      code +=
                e_code +
                // ?, ?, ?, ?, ?, ?,
                "STOREG 1\n" +
                "STOREG 0\n" +
                // num_e, deno_e, ?, ?, ?, ?,
                f_code +
                "STOREG 3\n" +
                "STOREG 2\n" +
                // num_e, deno_e, num_f, deno_f, ?, ?,
                "PUSHG 1\n"+
                "PUSHG 3\n"+
                "NEQ\n"+
                "JUMPF 18\n" + //modifier là
                "PUSHG 0\n" +
                "PUSHG 3\n" +
                "MUL\n" +
                "STOREG 0\n" +
                "PUSHG 1\n" +
                "PUSHG 2\n" +
                "MUL\n" +
                "STOREG 2\n" +
                "PUSHG 1\n" +
                "PUSHG 3\n" +
                "MUL\n" +
                "STOREG 3\n" +
                "PUSHG 3\n" +
                "STOREG 1\n" +
                // num_e, deno_e, num_f, deno_f, ?, ?,
                "LABEL 18\n" +
                "PUSHG 0\n" +
                "PUSHG 2\n" +
                operateur  + // on compare num_e et num_f
                "\n";
    }
    return code;
  }

}

calcul returns [String code]
  @init{ $code = new String() + "ALLOC 8\n"; } // On initialise $code, pour ensuite l’utiliser comme accumulateur
  @after{ System.out.println($code); } // on affiche le code MVaP stocké dans code
  :
    (decl { $code += $decl.code; })* NEWLINE*
    (instruction { $code += $instruction.code; }  )* { $code += "FREE " + (cmp_decla) + "\nHALT\n"; }
;

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
;

finInstruction
  : (NEWLINE | ';')+
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
      }

  }
  |TYPE (ID {
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
      }
	} ',')* (ID) ';'{
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
      }
	}
;

affectInt returns [String code]
@init{ $code = new String(); }
    : (ID '=' op2 ',' {
        if (labels.get($ID.text).getType().equals("int")){
			    int p = labels.get($ID.text).getAdresse();
          $code += $op2.code + "\n" + "STOREG " + p + "\n";

		    }
        else {
           throw new RuntimeException("Ce n'est pas une variable de type entier");
        }
    })*
    (ID '=' op2) ';' {
        if (labels.get($ID.text).getType().equals("int")){
			    int p = labels.get($ID.text).getAdresse();
          $code += $op2.code + "\n" + "STOREG " + p + "\n";
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
        throw new RuntimeException("Ce n'est pas une variable de type booléen");
      }
    }
;

afficher returns [ String code]
    : 'afficher(' exprReg ')'';'{
        $code = $exprReg.code +
                "STOREG 1\n" + //récupère le dénominateur en tête
                "STOREG 0\n" + //même pour le numérateur
                "PUSHG 0\n" + // récupère le numérateur et l'affiche
                "WRITE\n" + //l'affiche
                "POP\n" +
                "PUSHG 1\n" + //pareil pour deno
                "WRITE\n" + //l'affiche
                "POP\n";
    }
;

lireInt returns [String code]
  : 'lire()' {$code = "READ\n" ;}
;
lireReg returns [String code]
  : 'lire()' {$code = "READ\n" + "READ\n";}
;
lireBool returns [String code]
  : 'lire()' {$code = "READ\n" ;}
;
boucle returns [String code]
  : a=repeterInstru b=jusqueInstru ';' {$code = $a.code + $b.code;}
;

repeterInstru returns [String code]
  : 'repeter'
      {$code = "LABEL " + (cmpt_label) + "\n" ;}
      (instruction  {$code += $instruction.code ;})+

;

jusqueInstru returns [String code]
  : 'jusque' b=exprRegbool
    {$code = $b.code + "JUMPF " + cmpt_label++ + "\n";}
;

instr_condit returns [ String code ]
    : exprRegbool'?' a=exprReg':' b=exprReg ';' {
        $code = $exprRegbool.code + "JUMPF 19" + "\n" 
        + $a.code + "POP\nPOP\n" + "JUMP 20" + "\n" 
        + "LABEL 19" + ":" + "\n"  
        + $b.code + "POP\nPOP\n" + "LABEL 20" + ":" + "\n";
    }
;

// label : 0, 1, 2, 3, 4, 5, 6, 7, 8
// emplacement d'espace utiliser : 0, 1, 2, 3, 4, 5, 6, 7
exprReg returns [ String code, int num, int denum ]
  : '['z=exprReg']' {
    $code =
            // mémoire
            // ?, ?, ?, ?, ?, ?
            // stocker le numérateur et le dénominateur finale
            // entete de la pile déno puis enbas num
            $z.code +
            "STOREG 1\n" + // stocker déno dans 1
            "STOREG 0\n" + // stocker num dans 0
            // num, déno, ?, ?, ?, ?
            // pousser le dénominateur et le numérateur
            "PUSHG 0\n" +
            "PUSHG 1\n" +
            "SUP\n" + // Compare déno et num
            "JUMPF 0\n" +// jump label 0  si vrai on continue sinon si num inf deno on saute a 0
            "PUSHG 0\n" +
            "PUSHG 1\n" +
            "DIV\n" +
            "JUMP 1\n" + // jump label 1 end
            "LABEL 0\n" + // label multiplicaiton
            "PUSHG 0\n" +
            "PUSHI 10\n" +
            "MUL\n" +
            "PUSHG 1\n" + // pousser le dénominateur
            "DIV\n" + // diviser par le dénominateur
            "PUSHI 5\n" +
            "SUPEQ\n" + // resultat sup a 5
            "JUMPF 2\n" + // label 2 zero , si le résultat est inferieur on saute a 0 pour etre arrondi
            "PUSHI 1\n" + // Si résultat stric sup à 5, on arrondi à 1 et on pousse
            "JUMP 1\n" + // jump label 1 end
            "LABEL 2\n" + // label 2 zero
            "PUSHI 0\n" + // cela veut dire on arrondi a 0
            "LABEL 1\n" + // label end
            "WRITE\n" +
            "POP\n" ;
    }

  | '[+'b=exprReg'+]' {
    $code =
            // mémoire
            // ?, ?, ?, ?, ?, ?
            // stocker le numérateur et le dénominateur finale
            // entete de la pile déno puis enbas num
            $b.code +
            "STOREG 1\n" + // stocker déno dans 1
            "STOREG 0\n" + // stocker num dans 0
            // num, déno, ?, ?, ?, ?
            // pousser le dénominateur et le numérateur
            // on commence par faire num mod deno
            "PUSHG 0\n" +
            "PUSHG 1\n" +
            "DIV\n" +
            "STOREG 2\n" + // on ajoute le résultat du le quotient à l'adresse 2
            // num, déno, quotient, ?, ?, ?
            "PUSHG 2\n" +
            "PUSHG 1\n" + // on poussse deno
            "MUL\n" +
            "STOREG 3\n" + // stocke  produit à l'adresse 3
            // num, déno, quotient, produit, ?, ?
            "PUSHG 0\n" + // on pousse num
            "PUSHG 3\n" + // on pousse le produit
            "SUB\n" + // on soustrait de x le produit
            "PUSHI 0\n" +
            "EQUAL\n" + // si le modulo est 0 alors le résultat de la division est pair
            "JUMPF 3\n" +
            "PUSHG 0\n" +
            "PUSHG 1\n" +
            "DIV\n" +
            "LABEL 3\n" +
            "PUSHG 0\n" +
            "PUSHG 1\n" +
            "DIV\n" +
            "PUSHI 1\n" +
            "ADD\n" +
            "WRITE\n" ;
  }
  | '[-'b=exprReg'-]' {
    $code =
            // entete de la pile déno puis enbas num
            // pas besoin de se compliquer la command DIV le fait deja pour arrondir a l'inférieur
            $b.code +
            "DIV\n" +
            "WRITE\n" ;
  }
  | '(' a=exprReg ')' { $code = $a.code;}
  | a=exprReg'**'e=op {
    $code =
            // mémoire
            // ?, ?, ?, ?, ?, ?
            // stocker le numérateur et le dénominateur finale
            // entete de la pile déno puis enbas num
            $e.code +
            "STOREG 2\n" +
            $a.code +
            // on stocke num et deno
            "STOREG 1\n" +
            "STOREG 0\n" +
            // num, deno, n, ?, ?, ?
            // intilialer des resultat tmp
            "PUSHI 1\n" +
            "STOREG 3\n" +
            "PUSHI 1\n" +
            "STOREG 4\n" +
            // num, deno, n, tempnum, tempdeno, ?
            "LABEL 4\n" +
            "PUSHG 2\n" + // on pousse n
            "PUSHI 0\n" +
            "NEQ\n" +
            "JUMPF 5\n" +
            // num, deno, n, tempnum, tempdeno, ?
            "PUSHG 3\n" +
            "PUSHG 0\n" +
            "MUL\n" +
            "STOREG 3\n" + // stocke le nouveau temp num
            "PUSHG 4\n" +
            "PUSHG 1\n" +
            "MUL\n" +
            "STOREG 4\n" + // stocke le nouveau temp num
            "PUSHG 2\n" +
            "PUSHI 1\n" +
            "SUB\n" +
            "STOREG 2\n" + // on stocke n - 1
            "JUMP 4\n" +
            "LABEL 5\n" +
            // num, deno, n, tempnum, tempdeno, ?
            "PUSHG 3\n" +
            "PUSHG 4\n" ;
  }
  | a=exprReg '*' b=exprReg {
    $code =
          // Prépare a et c pour la multiplication
          $a.code + // a, b
          "STOREG 2\n" + // Stocker b
          "STOREG 0\n" + // stocker a
          $b.code + // c, d
          "STOREG 3\n" + // Stocker d
          "STOREG 1\n" + // Stocker c
          "PUSHG 0\n" +  // Pousser a
          "PUSHG 1\n" +  // Pousser c
          "MUL\n" +       // Multiplie a et c
          "STOREG 4\n" + // Stocker le numérateur
          // "a,c,b,d,num,"
          // Prépare b et d pour la multiplication
          "PUSHG 2\n" +  // Pousser b
          "PUSHG 3\n" +  // Pousser d
          "MUL\n" +       // Multiplie b et d
          "STOREG 5\n" + // Stocker le numérateur
          // "a,c,b,d,num,deno"
          // pousser le numerateur et le denominateur pour des éventuelle calcule
          "PUSHG 4\n" +  // Pousser le numérateur
          "PUSHG 5\n" +  // Pousser le dénominateur
          "WRITE\n";
  }
  | k=exprReg':'l=exprReg {
    $code =
          // TODO si les deux nombre sont entier les divisier par 1 par defaut

          // Prépare a et c pour la multiplication
          $k.code + // a, b
          "STOREG 2\n" + // Stocker b
          "STOREG 0\n" + // stocker a
          $l.code + // c, d
          "STOREG 1\n" + // Stocker d
          "STOREG 3\n" + // Stocker c
          "PUSHG 0\n" +  // Pousser a
          "PUSHG 1\n" +  // Pousser d
          "MUL\n" +       // Multiplie a et d
          "STOREG 4\n" + // Stocker le numérateur
          // "a,d,b,c,num,"
          // Prépare b et c pour la multiplication
          "PUSHG 2\n" +  // Pousser b
          "PUSHG 3\n" +  // Pousser c
          "MUL\n" +       // Multiplie b et d
          "STOREG 5\n" + // Stocker le numérateur
          // "a,d,b,c,num,deno"
          // pousser le numerateur et le denominateur pour des éventuelle calcule
          "PUSHG 4\n" +  // Pousser le numérateur
          "PUSHG 5\n" ;  // Pousser le dénominateur
  }
  | a=exprReg '+' b=exprReg {
    $code =
          // Prépare a et d pour la multiplication
          $a.code + // a, b
          // ?, ?, ?, ?, ?, ?, not_used, not_used
          "STOREG 6\n" + // Stocker b
          "STOREG 7\n" + // stocker a
          // 0, 1, 2, 3, 4, 5, 6, 7
          // ?, ?, ?, ?, ?, ?, b, a
          // il se peut que des valeur de $b.code utilise de 0 a 5
          $b.code + // c, d
          "STOREG 2\n" + // Stocker d
          "STOREG 0\n" + // Stocker c
          // c, ?, d, ?, ?, ?, b, a
          "PUSHG 6\n" +  // Pousser b
          "PUSHG 7\n" +  // Pousser a
          "STOREG 3\n" + // Stocker a
          "STOREG 1\n" + // Stocker b
          // "c,b,d,a,,,,"
          "PUSHG 3\n" +  // Pousser a
          "PUSHG 2\n" +  // Pousser d
          "MUL\n" +       // Multiplie a et d
          // "c,b,d,a,,,,"
          // Prépare c et b pour la multiplication
          "PUSHG 0\n" +  // Pousser c
          "PUSHG 1\n" +  // Pousser b
          "MUL\n" +       // Multiplie c et b
          // "c,b,d,a,,,,"
          // Additionne les résultats de multiplication
          "ADD\n" +
          "STOREG 4\n" + // Stocker le numérateur
          // "c,b,d,a,num,"
          // Prépare b et d pour la multiplication dénominateur commun
          "PUSHG 1\n" +  // Pousser b
          "PUSHG 2\n" +  // Pousser d
          "MUL\n" +       // Multiplie b et d
          "STOREG 5\n" + // Stocker le dénominateur
          // "c,b,d,a,num,deno"
          // pousser le numerateur et le denominateur pour des éventuelle calcule
          "PUSHG 4\n" +  // Pousser le numérateur
          "PUSHG 5\n" ;  // Pousser le dénominateur
  }
  | a=exprReg '-' b=exprReg {
     $code =
          // Prépare a et d pour la multiplication
          $a.code + // a, b
          "STOREG 1\n" + // Stocker b
          "STOREG 3\n" + // stocker a
          $b.code + // c, d
          "STOREG 2\n" + // Stocker d
          "STOREG 0\n" + // Stocker c
          "PUSHG 3\n" +  // Pousser a
          "PUSHG 2\n" +  // Pousser d
          "MUL\n" +       // Multiplie a et d
          // "c,b,d,a,,"
          // Prépare c et b pour la multiplication
          "PUSHG 0\n" +  // Pousser c
          "PUSHG 1\n" +  // Pousser b
          "MUL\n" +       // Multiplie c et b
          // "c,b,d,a,,"
          // Soustraire les résultats de multiplication
          "SUB\n" +
          "STOREG 4\n" + // Stocker le numérateur
          // "c,b,d,a,num,"
          // Prépare b et d pour la multiplication dénominateur commun
          "PUSHG 1\n" +  // Pousser b
          "PUSHG 2\n" +  // Pousser d
          "MUL\n" +       // Multiplie b et d
          "STOREG 5\n" + // Stocker le dénominateur
          // "c,b,d,a,num,deno"
          // pousser le numerateur et le denominateur pour des éventuelle calcule
          "PUSHG 4\n" +  // Pousser le numérateur
          "PUSHG 5\n" ;  // Pousser le dénominateur
  }
  | '-'exprReg {
    $code =
          $exprReg.code +
          "STOREG 1\n" +
          "STOREG 0\n" +
          "PUSHG 0\n" +
          "PUSHI 0\n" +
          "PUSHI 1\n" +
          "SUB\n" +
          "MUL\n" +
          "PUSHG 1\n" ;
  }
  | e=op'/'f=op'%' {$code = calcul_pourcentage($e.code, $f.code) ;}
  | 'num('c=ENTIER '/' d=ENTIER ')' {$code = "PUSHI " + $c.text + "\n"; $num = $c.int;}
  | 'sim('e=op '/' f=op ')' {$code = simplifierRationnel($e.code, $f.code);}
  | 'denum('c=ENTIER '/' d=ENTIER ')' {$code = "PUSHI " + $d.text + "\n"; $denum = $d.int;}
  | lireReg {$code = $lireReg.code;}
  | op3 {$code = $op3.code;}
  | op {$code = $op.code;}
;

op returns [String code]
  : 'pgcd('c=op',' d=op ')' {
      $code = calculerPGCD($c.code, $d.code);
    }
  | 'ppcm('c=op ',' d=op ')' {
      $code = calculerPPCM($c.code, $d.code);
    }
  | e=op '/' f=op {$code = $e.code + $f.code;}
  | lireInt {$code = $lireInt.code;}
  | ENTIER {$code = "PUSHI " + $ENTIER.text + "\n";}
  | ID {  int p = labels.get($ID.text).getAdresse();
          $code = "PUSHG " + (p-1) + "\n" +
            "PUSHG " + p + "\n";}
;

op2 returns [String code]
  : 'pgcd('c=op2',' d=op2 ')' {
      $code = calculerPGCD($c.code, $d.code);
    }
  | 'ppcm('c=op2 ',' d=op2 ')' {
      $code = calculerPPCM($c.code, $d.code);
    }
  | ENTIER {$code = "PUSHI " + $ENTIER.text + "\n";}
;

op3 returns [String code]
  : ENTIER {$code = "PUSHI " + $ENTIER.text + "\n"+ "PUSHI 1" + "\n";}
;

exprRegbool returns [String code]
  :'true' {$code = "PUSHI 1" + "\n";}
  |'false' {$code = "PUSHI 0" + "\n";}
  |'(' exprRegbool ')' {$code = $exprRegbool.code;}
  |'not' d=exprRegbool {$code = "PUSHI 1\n" +  $d.code + "SUB\n";}
  |d=exprRegbool 'and' g=exprRegbool {$code = calcul_expr_reg_bool($d.code, $g.code, "and"); }
  |d=exprRegbool 'or' g=exprRegbool {$code = calcul_expr_reg_bool($d.code, $g.code, "or"); }
  |e=exprReg '>' f=exprReg {$code = calcul_expr_reg_bool($e.code, $f.code, "SUP"); }
  |e=exprReg '<' f=exprReg {$code = calcul_expr_reg_bool($e.code, $f.code, "INF"); }
  |e=exprReg '>=' f=exprReg {$code = calcul_expr_reg_bool($e.code, $f.code, "SUPEQ"); }
  |e=exprReg '<=' f=exprReg {$code = calcul_expr_reg_bool($e.code, $f.code, "INFEQ"); }
  |e=exprReg '==' f=exprReg {$code = calcul_expr_reg_bool($e.code, $f.code, "EQUAL");}
  |e=exprReg '<>' f=exprReg {$code = calcul_expr_reg_bool($e.code, $f.code, "NEQ");}
  | lireBool {$code = $lireBool.code;}
;

TYPE : 'int' | 'reg' | 'bool';
ID : [a-zA-Z_][a-zA-Z_0-9]*;
NEWLINE : '\r'? '\n';
WS : (' '|'\t')+ -> skip;
ENTIER : ('0'..'9')+;
BOOLEAN : '0' | '1';
FININSTRUCTIONS : ';';
UNMATCH : . -> skip;