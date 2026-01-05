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


permisiuni=$(stat -c  "%a" "$file")
if [ "$permisiuni" -ne 600 ] && [ "$permisiuni" -ne 644 ]; then
 	echo "Permisiuni nesigure, se recomanda: 600"
fi

declare -A dictionar
curent_host="global"



while read -r linie || [ -n "$linie" ]; do

	
	if [[ -z "$linie" || "$linie" == \#* ]]; then
		continue
	fi

	
	linie=$(echo "$linie" | xargs)


	if [[ "$linie" == Host\ * ]]; then
        	curent_host=$(echo "$linie" | awk '{print $2}')
        	continue
    	fi


   	 
    	cheie=$(echo "$linie" | awk '{print $1}')       #cheie=hostname
    	valoare=$(echo "$linie" | awk '{print $2}')     #valoare = 4
    	cheie_dictionar="${curent_host}_${cheie}"      # cheia_ dictionar = alexia_hostname

    
    if [[ -n "${dictionar[$cheie_dictionar]}" ]]; then
        echo "[DUPLICAT] La host-ul $curent_host, opțiunea $cheie este deja setată!"
    else
        
        dictionar["$cheie_dictionar"]="$valoare"

	case "$cheie" in
		"PermitRootLogin")
         		if [[ "$valoare" == "yes" ]]; then
				echo "host: $curent_host -> root login este activat"
			fi
			;;
		"PasswordAuthentication")
			if [[ "$valoare" == "yes" ]]; then
                        	 echo "host: $curent_host -> permite parole; recomandat: 'no' (folositi chei)"
			fi
                        ;;
		"PermitEmptyPasswords")
			if [[ "$valoare" == "yes" ]]; then
        	                 echo "host: $curent_host -> permite parole goale"
               	        fi
          	    	;;
		"Port")
			if [[ "$valoare" == "yes" ]]; then
               	                echo "host: $curent_host -> foloseste portul standard 22"
               	        fi
               	        ;;
	esac



    fi

   
done < "$file" 


for cheie_compusa in "${!dictionar[@]}"; do
    echo   "$cheie_compusa - ${dictionar[$cheie_compusa]}"
done 
