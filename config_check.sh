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

         valoare_ideala=${recomandari[$i]}
    
    
         valoare_curenta=${dictionar["global_$i"]}
    
         if [[ -n "$valoare_curenta" ]]; then
         if [[ "$valoare_curenta" != "$valoare_ideala" ]]; then
         	 echo " '$i' are  valoarea '$valoare_curenta', trebuie schimbata in '$valoare_ideala'!"
         fi
         else
		linie_comentata=$(grep "#$i" "$file" | head -n 1)
		valoare_comentata=$(echo "$linie_comentata" | awk '{print $2}')
        
                if [[ -n "$valoare_comentata" ]]; then
               		 if [[ "$valoare_comentata" != "$valoare_ideala" ]]; then
                          	 echo "atentie '$i' este comentata cu valoarea '$valoare_comentata', valoarea default a sistemului este nesigura, se recomanda '$i $valoare_ideala' "
               		 else
               			 echo " '$i' este comentata, dar are valoarea default sigura '$valoare_comentata' "
               		 fi
                else
           		 echo "lipseste '$i' nu apare deloc, se recomanda adaugarea liniei '$i $valoare_ideala' "
                fi
         fi
done 



for cheie_compusa in "${!dictionar[@]}"; do
    echo   "$cheie_compusa - ${dictionar[$cheie_compusa]}"
done 
