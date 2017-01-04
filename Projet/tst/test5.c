// Objectif: Plusieurs tests vérifiant que les opérations entre variables de même type sont tolérées.
// Doit retourner un attention pour la ligne 15 ou on converti int en double.

void main() {
  int a;
  int b;
  double c;
  double d;
  a=2;
  b=3;
  c=1.3;
  d=3.4;
  a = a + b + 3;
  c = c + d * 1 + 2.5;
  c = a + b;
}
