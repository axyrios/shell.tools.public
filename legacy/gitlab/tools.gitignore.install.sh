#!/usr/bin/env bash

curl -O https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.gitignore.install.sh && chmod +x tools.gitignore.install.sh
# ./tools.gitignore.install.sh

# chargement librairie insert or replace
timestamp=`date +%Y%m%d%H%M%S`
curl -s https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.function.insertorreplace.sh -o /tmp/.myscript.${timestamp}.tmp
source /tmp/.myscript.${timestamp}.tmp
rm -f /tmp/.myscript.${timestamp}.tmp

GITIGNOREFILE="Windows"
STARTCHAIN="## START GITIGNORE ${GITIGNOREFILE}"
ENDCHAIN="## END GITIGNORE ${GITIGNOREFILE}"
FILE=".gitignore"
curl -O https://raw.githubusercontent.com/github/gitignore/master/Global/${GITIGNOREFILE}.gitignore
INSERTORREPLACEFILE=${GITIGNOREFILE}.gitignore

insertorreplace_infile_betweentwochains "${INSERTORREPLACEFILE}" "${STARTCHAIN}" "${ENDCHAIN}" "${FILE}"
rm -f ${INSERTORREPLACEFILE}

GITIGNOREFILE="macOS"
STARTCHAIN="## START GITIGNORE ${GITIGNOREFILE}"
ENDCHAIN="## END GITIGNORE ${GITIGNOREFILE}"
FILE=".gitignore"
curl -O https://raw.githubusercontent.com/github/gitignore/master/Global/${GITIGNOREFILE}.gitignore
INSERTORREPLACEFILE=${GITIGNOREFILE}.gitignore

insertorreplace_infile_betweentwochains "${INSERTORREPLACEFILE}" "${STARTCHAIN}" "${ENDCHAIN}" "${FILE}"
rm -f ${INSERTORREPLACEFILE}

GITIGNOREFILE="Linux"
STARTCHAIN="## START GITIGNORE ${GITIGNOREFILE}"
ENDCHAIN="## END GITIGNORE ${GITIGNOREFILE}"
FILE=".gitignore"
curl -O https://raw.githubusercontent.com/github/gitignore/master/Global/${GITIGNOREFILE}.gitignore
INSERTORREPLACEFILE=${GITIGNOREFILE}.gitignore

insertorreplace_infile_betweentwochains "${INSERTORREPLACEFILE}" "${STARTCHAIN}" "${ENDCHAIN}" "${FILE}"
rm -f ${INSERTORREPLACEFILE}

read -p "nettoyer le git avec le nouveau .gitignore (y/n)?" choice
	case "$choice" in 
	  y|Y ) echo "yes" && 
	    git rm -r --cached .
        git add .
        git commit -m "Removing all files in .gitignore"
	  ;;
	  n|N ) echo "no" ;;
	  * ) echo "invalid" ;;
	esac


