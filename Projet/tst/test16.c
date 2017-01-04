// Objectif: Vérifier que le type en entrée d'une fonction soit cohérent.
// Doit retourner attention conversion implicite.

int function(int a){
  return 4;
}

void main() {
  double a;
  int b;
  a = 4.3;
  b = function(a);
}
