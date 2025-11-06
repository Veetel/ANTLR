grammar Mot_Eg;
//regle de grammaire

s: A s B s | B s A s | C s | ;
// analyseur lexical
A :'a';
B: 'b';
C: 'c';



