#!/usr/bin/env bash

# curl -O https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.base64pngdecode.sh && chmod +x tools.base64pngdecode.sh
# ./tools.base64pngdecode.sh

for f in *.png
do
	echo "decoding $f"
	if base64 --decode "$f" > "$f".tmp ; then
		rm "$f"
		mv "$f".tmp "$f"
	else
		echo "fichier déjà ok"
		rm "$f".tmp
	fi
done
