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



if grep -qi "PermitRootLogin yes" "$file"; then
	echo "PERICOL:  root login este activat"
else
	echo "root login este dezactivat sau neschimbat"
fi

#verificarea permisiunilor
permisiuni=$(stat -c  "%a" "$file")
if [ "$permisiuni" -ne 600 ] && [ "$permisiuni" -ne 644 ]; then
 	echo "Permisiuni nesigure, se recomanda: 600"
fi

declare -A dictionar
curent_host="global"


#citirea fisierului ssh si folosirea unui dictionar pentru a memora datele 
while read -r linie || [ -n "$linie" ]; do

	#ignora spatiile si comentariile din fisier
	if [[ -z "$linie" || "$linie" == \#* ]]; then
		continue
	fi

	#elimina spatiile suplimentare in asa fel incat sa avem doar un spatiu intre cele 2 cuvinte
	linie=$(echo "$linie" | xargs)


	#punem in current_host numele hostului curent
	if [[ "$linie" == Host\ * ]]; then
        	curent_host=$(echo "$linie" | awk '{print $2}')
        	continue
    	fi


   	 # Extragem cheia (ex: Port, User, PasswordAuthentication)
    	cheie=$(echo "$linie" | awk '{print $1}')       #cheie=hostname
    	valoare=$(echo "$linie" | awk '{print $2}')     #valoare = 4
    	cheie_dictionar="${curent_host}_${cheie}"      # cheia_ dictionar = alexia_hostname

    # 1. VERIFICARE DUPLICATE (Pentru orice setare)
    if [[ -n "${dictionar[$cheie_dictionar]}" ]]; then
        echo "[DUPLICAT] La host-ul $curent_host, opțiunea $cheie este deja setată!"
    else
        # Stocăm valoarea (salvăm totul pentru a putea verifica ulterior)
        dictionar["$cheie_dictionar"]="$valoare"
    fi

   
done < "$file" 


for cheie_compusa in "${!dictionar[@]}"; do
    echo   "$cheie_compusa - ${dictionar[$cheie_compusa]}"
done 
