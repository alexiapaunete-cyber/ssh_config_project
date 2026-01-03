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


permisiuni=$(stat -c %a "$file")
if [[ "$permisiuni" != 600 || "$permisiuni" != 644  ]]; then
	echo "atentie: permisiuni nesigure ($permisiuni); se recomanda 600"
fi

declare -A dictionar
curent_host="global"


while read -r line || [ -n "$line" ]; do
	if [[ -z "$line" || "$line"==\#* ]]; then
		continue
	fi


	line=$(echo "$line" | xargs)


	if [[ "$line" == Host\ * ]]; then
		curent_host=$(echo "$line" | awk '{print $2}')
		continue
	fi

	cheie=$(echo "$line" | awk '{print $1}')
	valoare=$(echo "$line" | awk '{print $2}')
	cheie_dictionar="${curent_host}_${cheie}"

	if [[ -n "${dictionar[$cheie_dictionar]}" ]]; then
		echo "DUPLICAT la host-ul $curent_host, optiunea $cheie e deja setata"
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
        echo "$cheie_compusa - ${dictionar[$cheie_compusa]}"
done



