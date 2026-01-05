#!/bin/bash

file=$1


if [[ -z "$file" ]]; then
	echo "eroare: te rog introdu calea catre un fisier"
	exit 1
fi



if [[ ! -f "$file" ]]; then
	echo "eroare: fisierul '$file' nu exista"
	exit 1
fi

permisiuni=$(stat -c  "%a" "$file")
if [ "$permisiuni" -ne 600 ] && [ "$permisiuni" -ne 644 ]; then
 	echo "permisiuni nesigure, se recomanda: 600"
fi

proprietar=$(stat -c "%U" "$file")
if [ "$proprietar" != "root" ]; then
	echo -e "fisierul nu este detinut de root! propprietar actual: $proprietar"
fi

declare -A dictionar
match_curent="global"



while read -r linie || [ -n "$linie" ]; do

	
	if [[ -z "$linie" || "$linie" == \#* ]]; then
		continue
	fi

	
	linie=$(echo "$linie" | xargs)


	if [[ "$linie" == Match\ * ]]; then
        	match_curent=$(echo "$linie")
        	continue
    	fi

    	cheie=$(echo "$linie" | awk '{print $1}')    
    	valoare=$(echo "$linie" | awk '{print $2}')     
    	cheie_dictionar="${match_curent}_${cheie}"      

    
    if [[ -n "${dictionar[$cheie_dictionar]}" ]]; then
        echo "[DUPLICAT] in sectiunea '$match_curent', optiunea '$cheie' apare de mai multe ori!"
    else
        
        dictionar["$cheie_dictionar"]="$valoare"

	case "$cheie" in
		"PermitRootLogin")
         		if [[ "$valoare" != "no" ]]; then
				echo "$match_curent: PermitRootLogin este '$valoare', se recomanda 'no'  "
			fi
			;;
		"PasswordAuthentication")
			if [[ "$valoare" != "no" ]]; then
                        	 echo " $match_curent: permite parole, recomandat: 'no' (folositi chei ssh)"
			fi
                        ;;
		"PermitEmptyPasswords")
			if [[ "$valoare" != "no" ]]; then
        	                 echo "$match_curent: permite parole goale"
               	        fi
          	    	;;
		"Port")
			if [[ "$valoare" == "22" ]]; then
               	                echo " $match_curent -> foloseste portul standard 22, schimbati-l pentru a reduce atacurile bot "
               	        fi
               	        ;;
		"X11Forwarding")
			if [[ "$valoare" != "no" ]]; then
				echo " X11Forwarding este activat, daca nu folositi aplicatii grafice se recomanda dezactivarea sa"
			fi
			;;
		"MaxAuthTries")
			if [ "$valoare" -gt 3 ]; then
				echo "MaxAuthTries este "$valoare", este recomandat sa fie <=3"
			fi
			;;
	esac



    fi

   
done < "$file" 


for cheie_compusa in "${!dictionar[@]}"; do
    echo   "$cheie_compusa - ${dictionar[$cheie_compusa]}"
done 
