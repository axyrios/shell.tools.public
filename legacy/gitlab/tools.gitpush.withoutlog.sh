#!/usr/bin/env bash

curl -O https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.gitpush.withoutlog.sh && chmod +x tools.gitpush.withoutlog.sh;
curl -O https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.gitpush.sh && chmod +x tools.gitpush.sh;
./tools.gitpush.sh --withoutlog