#!/bin/bash

# generated record of the probe design for Matthias
ls *AA* | egrep -v "139\.|122\." | xargs wc -l | head -n-1 | \
    sed 's/  */\t/g; s/\.txt//; s/_unique//' | \
    awk -vFS="[_.\t]" '{ print $5 " " $1 " " $2 " " $3 }' | sort -k1,1 > wc_l

printf "array_number\tdesign_ID\tnumber_of_unique_probes\tgenomic_target\n" > table.tsv
join -j1 agilent_array_design_ids.txt wc_l | sed 's/  */\t/g' >> table.tsv

rm wc_l
