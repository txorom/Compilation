// Objectif: Vérifier que le compilateur considère que b n'est pas déclaré
// Doit retourner une erreur variable indéfinie.


void main() {
  int a;
  a=3;
  if(a==3){
    int b;
    b = 4;
  }
  b=3;
}
