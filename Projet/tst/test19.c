// Objectif: S'assurer que la redéclaration fonctionne à un niveau inférieur.
// Doit retourner vrai.

int main() {
  int a;
  if(a == 1){
    int a;
    a=3;
  }
  return a;
}
