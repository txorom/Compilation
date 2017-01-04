//Vérifie que l'appel à une fonction possède les bons arguments
//Doit renvoyer une erreur que l'appel à la fonction ne possède pas le nombre d'argument

int toto(int a){
	return a;
}

void main(){
	toto(2);
	toto();
}