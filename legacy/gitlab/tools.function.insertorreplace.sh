#!/usr/bin/env bash

function insertorreplace_infile_betweentwochains () {
	FILETOREAD=$1
	STARTCHAIN=$2
	ENDCHAIN=$3
	FILETOWRITE=$4
	
	if [ -e  ${FILETOWRITE} ] && grep -q "${STARTCHAIN}" ${FILETOWRITE} ; then
	  echo "${STARTCHAIN} trouvé"
	  sed "
	   /^${STARTCHAIN}/,/^${ENDCHAIN}/{
		  /^${STARTCHAIN}/{
			 n
			 r $FILETOREAD
		  }
		  /^${ENDCHAIN}/!d
	   }
	  " ${FILETOWRITE} > ${FILETOWRITE}.tmp
	else
	  echo "${STARTCHAIN} non trouvé"
	  echo "" > "${FILETOWRITE}.tmp"
	  [ -e ${FILETOWRITE} ] && cat ${FILETOWRITE} > ${FILETOWRITE}.tmp
	  echo "${STARTCHAIN}" >> ${FILETOWRITE}.tmp &&
		  cat ${FILETOREAD} >> ${FILETOWRITE}.tmp &&
		  echo "${ENDCHAIN}" >> ${FILETOWRITE}.tmp
	fi

	cat ${FILETOWRITE}.tmp
	read -p "Remplacer ${FILE} (y/n)?" choice
	case "$choice" in 
	  y|Y ) echo "yes" && mv ${FILETOWRITE}.tmp ${FILETOWRITE};;
	  n|N ) echo "no" && rm ${FILETOWRITE}.tmp;;
	  * ) echo "invalid" && rm ${FILETOWRITE}.tmp;;
	esac
}
export insertorreplace_infile_betweentwochains


function insertorreplace_infile_betweentwochains_quiet () {
	FILETOREAD=$1
	STARTCHAIN=$2
	ENDCHAIN=$3
	FILETOWRITE=$4
	
	if [ -e  ${FILETOWRITE} ] && grep -q "${STARTCHAIN}" ${FILETOWRITE} ; then
	  # echo "${STARTCHAIN} trouvé"
	  sed "
	   /^${STARTCHAIN}/,/^${ENDCHAIN}/{
		  /^${STARTCHAIN}/{
			 n
			 r $FILETOREAD
		  }
		  /^${ENDCHAIN}/!d
	   }
	  " ${FILETOWRITE} > ${FILETOWRITE}.tmp
	else
	  echo "${STARTCHAIN} non trouvé"
	  echo "" > "${FILETOWRITE}.tmp"
	  [ -e ${FILETOWRITE} ] && cat ${FILETOWRITE} > ${FILETOWRITE}.tmp
	  echo "${STARTCHAIN}" >> ${FILETOWRITE}.tmp &&
		  cat ${FILETOREAD} >> ${FILETOWRITE}.tmp &&
		  echo "${ENDCHAIN}" >> ${FILETOWRITE}.tmp
	fi
    mv ${FILETOWRITE}.tmp ${FILETOWRITE}
}
export insertorreplace_infile_betweentwochains_quiet