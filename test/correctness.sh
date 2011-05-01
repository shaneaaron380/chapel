#! /bin/bash

for i in 10 50 100; do 
	infile="inputs/test_input_${i}.txt"
	outfile="obj/$(basename $infile).out"
	goldfile="$(dirname $infile)/$(basename $infile .txt)_golden.txt"

	[ -e $outfile ] && rm -rf $outfile

	./chapel_project    --iterations=3 \
						--timestep=1 \
						--inputfile=$infile \
						--outputfile=$outfile

	bin/check_output.py $outfile $goldfile

done

