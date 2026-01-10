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


permisiuni=$(stat -c "%a" "$file")
if [ "$permisiuni" -ne 600 ] && [ "$permisiuni" -ne 644 ]; then
 	echo "permisiuni nesigure, se recomanda: 600"
fi

proprietar=$(stat -c "%U" "$file")
if [ "$proprietar" != "root" ]; then
	echo -e "fisierul nu este detinut de root! proprietar actual: $proprietar"
fi

declare -A dictionar



while read -r linie || [ -n "$linie" ]; do

	if [[ -z "$linie" || "$linie" == \#* ]]; then
		continue
	fi


	linie=$(echo "$linie" | xargs)


	if [[ "$linie" == Match\ * ]]; then
        	continue
    	fi

    	cheie=$(echo "$linie" | awk '{print $1}')
    	valoare=$(echo "$linie" | awk '{print $2}')
        if [[ -n "${dictionar[$cheie]}" ]]; then
        	if [[ "${dictionar[$cheie]}" == "$valoare" ]]; then
       		   	 echo "[DUPLICAT]  optiunea $cheie apare de mai multe ori cu aceeasi valoare!"
 		else
			echo "[SUPRASCRIERE] in $cheie se atribuie mai multe valori diferite!"
		fi
  	else
       		 dictionar["$cheie"]="$valoare"

     		case "$cheie" in
			"PermitRootLogin")
         			if [[ "$valoare" != "no" ]]; then
					echo "$cheie: PermitRootLogin este $valoare, se recomanda no  "
				fi
				;;
			"PasswordAuthentication")
				if [[ "$valoare" != "no" ]]; then
                        		 echo " $cheie: permite parole, recomandat: no (folositi chei ssh)"
				fi
                       		;;
			"PermitEmptyPasswords")
				if [[ "$valoare" != "no" ]]; then
        	        	         echo "$cheie: permite parole goale"
               	       		fi
          	    	       	;;
			"Port")
				if [[ "$valoare" == "22" ]]; then
               	        	        echo " $cheie: foloseste portul standard 22, schimbati-l pentru a reduce atacurile bot "
               	       		fi
               	       		;;
			"X11Forwarding")
				if [[ "$valoare" != "no" ]]; then
					echo " $cheie: este activat, daca nu folositi aplicatii grafice se recomanda dezactivarea sa"
				fi
				;;
			"MaxAuthTries")
				if [ "$valoare" -gt 3 ]; then
					echo "$cheie: este $valoare, este recomandat sa fie <=3"
				fi
				;;
				esac
   	 fi
done < "$file" 



declare -A recomandari
recomandari["PermitRootLogin"]="no"
recomandari["PasswordAuthentication"]="no"
recomandari["PermitEmptyPasswords"]="no"
recomandari["MaxAuthTries"]="3"
recomandari["X11Forwarding"]="no"

printf "%s\n" "${!recomandari[@]}" | while read -r i; do
	if [[ -z "$i" ]]; then
		 continue
	fi
	if [[ -n "${dictionar[$i]}" ]]; then
		continue
	fi
        linie_comentata=$(grep "#$i ${recomandari[$i]}" "$file" | head -n 1)
        if [[ -n "$linie_comentata" ]]; then
                          	 echo "atentie ar trebui ca $i ${recomandari[$i]} sa fie decomentata "
               		 else
               			 echo " lipseste $i ${recomandari[$i]} "
	fi
done


