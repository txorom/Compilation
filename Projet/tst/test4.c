// Objectif: Vérifier que l'on ne puisse pas retourner un entier pour une fonction de type void.
// Doit retourner une erreur.

void main() {
  int a;
  int b;
  b=2;
  a=3;
  b=a+b;
  return b;
}
