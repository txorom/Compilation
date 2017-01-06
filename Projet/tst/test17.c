// Objectif: Vérifier que le type en sortie d'une fonction soit cohérent.
// Doit retourner attention conversion implicite.

double function(int a){
  double h;
  h = 4.6;
  return a;
}

void main() {
  int a;
  double b;
  a = 2;
  b = function(a);
}
