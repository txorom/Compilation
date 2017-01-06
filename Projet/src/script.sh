#!/bin/bash

for (( i = 1; i < 31; i++ )); do
	echo -n "test"$i" : ";
	fichier1="../tst/res"$i".txt";
	fichier2="../tst/resbis"$i".txt";
	cmp -s $fichier1 $fichier2;
	if [ $? -eq 0 ]; then
		echo -e "\033[32mok";
	else
		echo -e "\033[31mko";
	fi
	echo -en "\033[0m";
done