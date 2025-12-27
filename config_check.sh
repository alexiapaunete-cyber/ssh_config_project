#!/bin/bash
file=$1
if [[ -z "$file" ]]; then
	echo "eroare: te rog introdu calea catre un fisier"
	exit 1
fi

if [[ ! -f "$file" ]]; then
	echo "fisierul '$file' nu exista"
	exit 1
fi

if grep -qi "PermissionRootLogin yes" "$file"; then
	echo "PERICOL:  root login este activat"
else
	echo "root login este dezactivat sau neschimbat"
fi

permisiuni=$(stat -c %a "$file")
if [[ "$permisiuni" != 600 || "$permisiuni" != 644  ]]; then
	echo "atentie: permisiuni nesigure ($permisiuni); se recomanda 600"
fi

while read -r line; do
	if [[ -z "$line" || "$line"==\#* ]]; then
		continue
	fi
	if [[ "$line"=="Host "* ]]; then
		nume=$(echo $line | awk '{print $2}')
		if [[ -n "$nume" ]]; then
			dictionar["Host"] = $nume
		fi
	else
		cheie = $(echo $line | awk '{print $1}')
		valoare = $(echo $line | awk '{print $2}')
		dictionar["$cheie"] = $valoare
	fi
for $cheie in "${!dictionar[@]}"; do
	echo "$cheie are valoarea: ${dictionar[2]}"
done
done < "$file"
