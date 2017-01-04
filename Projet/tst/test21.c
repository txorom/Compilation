//Doit vérifier si les fonctions récursives marchent
//Doit renvoyer vrai
int toto(int n){
	if(n == 0){
		return 1;
	}
	else{
		return n * toto(n - 1);
	}
}

int main()
{
	toto(10);
	return 0;
}