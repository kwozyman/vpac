#!/bin/bash
# Author: Pablo Iranzo Gómez (Pablo.Iranzo@gmail.com)
# Description: Script to copy modified files to server

if [[ $1 == "" ]]; then
    TARGETHOST="root@r450-n45-u16.pool.se-lab.eng.rdu2.dc.redhat.com"
else
    TARGETHOST="$1"
fi

for file in $(LANG=C git status | grep -E 'modified|new' | cut -d ":" -f 2 | sort | uniq); do
    if [[ -f ${file} ]]; then
        echo "###### ${file} ##########"
        scp ${file} ${TARGETHOST}:vpac/${file}
    fi
done
