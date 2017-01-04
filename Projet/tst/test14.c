// Objectif: Vérifier que les fonctions et appels de fonctions ne posent pas de problèmes.
// Doit retourner vrai.

int function(int a, int b){
  int c;
  c = a + b;
  return b;
}

int main() {
  int h;
  h = function(2,3);
  return h;
}
