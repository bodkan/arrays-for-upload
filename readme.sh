#!/bin/bash

rm -rf tmp
mkdir tmp

# files for the whole-chromosome capture design are in /mnt/scratch/mp/arrays/capture_design
# the final set of all probes is here:
whole_genome_probes=/mnt/scratch/mp/arrays/capture_design/output/final_sequences_10bp_tiling.txt.gz

# files for the array design based on the catalog are in /mnt/scratch/mp/arrays/catalog_array
# the final set of all probes is here:
catalog_probes=/mnt/scratch/mp/arrays/catalog_array/output/final_sequences.txt

# this script only takes what has been generated above and turns everything
# into files ready for upload to Agilent

max_probes_per_array=974016
first_array_id=122



#################################################################
# "catalog array"
# file for upload: catalog_array_AA122.txt

# replace ':' and '-' with '_', shorten the probe ID from
# 'chr_start_end' to just 'chr_start' and add a prefix "MP"
cat $catalog_probes | \
    tr ':-' '_' | \
    sed 's/\([0-9X]*\)_\([0-9]*\)_[0-9]*/\1_\2/' > catalog_array_AA${first_array_id}_unique.txt

# there are only 114,187 probes based on the catalog of fixed modern
# human-specific sites -- replicate them 8 times so that the number of probes
# in the array is closer to $max_probes_per_array
for i in {1..8}; do
    sed "s/^/${i}_/" catalog_array_AA${first_array_id}_unique.txt \
        >> catalog_array_AA${first_array_id}.txt
done



#################################################################
# "whole-chromosome arrays"
# files for upload: chr1_array_AA123, chr1_array_AA124, etc...

for chr in 1 12 21 X; do
    tmp_file="tmp/whole_chr${chr}_probes.txt"
    array_id=$((first_array_id + `ls *AA*.txt | wc -l`))

    zgrep "^${chr}:" $whole_genome_probes | \
        tr ':-' '_' |  \
        sed 's/\([0-9X]*\)_\([0-9]*\)_[0-9]*/\1_\2/' | \
        sed 's/^/MP/' > $tmp_file
    split --numeric-suffixes=$array_id -a 3 -l $max_probes_per_array \
        --additional-suffix='.txt' $tmp_file chr${chr}_array_AA
done

# as with the capture array above, there are not enough probes in the last
# chr1 array -- replicate them 4 times
for i in {1..4}; do
    sed "s/^/${i}/" chr1_array_AA139.txt >> tmp_file
done
mv chr1_array_AA139.txt chr1_array_AA139_unique.txt
mv tmp_file chr1_array_AA139.txt
