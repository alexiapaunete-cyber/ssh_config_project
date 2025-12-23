#!/bin/bash

file="$1"

#verificare daca file a primit un argument?
if [ -z "$file" ]; then
	echo " Error, input format: ./config_check <filename>"
	exit 1
fi

#verificarea permisiunilor
permisiuni=$(stat -c  "%a" "$file")
if [ "$permisiuni" -ne 600 ] && [ "$permisiuni" -ne 644 ]; then
 	echo "Permisiuni nesigure, se recomanda: 600"
	exit 1
fi

#citirea fisierului ssh
while read -r line; do
	if [[ -z "$line" || "$line" == \#* ]]; then
		continue
 	fi
	echo "$line"
	myarray+=($line)
done < "$file" 


