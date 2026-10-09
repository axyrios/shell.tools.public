#!/usr/bin/env bash
set -x 

curl -O https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.gitpush.install.sh && chmod +x tools.gitpush.install.sh;

for dir in $(find . -name ".git")
do 
    cd $(dirname "${dir}")
    
    if ! (git remote -v | grep gitlab.com ) && \
         ! (git remote -v | grep github.com ) then
        
        echo "repo non gitlab.com et non github"
    else 
        echo $PWD
        
        curl -O https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.gitpush.sh && chmod +x tools.gitpush.sh;
        ./tools.gitpush.sh
        echo ""
    fi;
    cd - > /dev/null
    
done
