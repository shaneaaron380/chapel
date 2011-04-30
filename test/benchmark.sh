#! /bin/bash

for i in {1..4}; do
	infile="inputs/test_input_${i}.txt"
	outfile="obj/$(basename $infile).out"

	[ -e $outfile ] && rm -rf $outfile

	./chapel_project	--iterations=3 \
						--timestep=1 \
						--inputfile=$infile \
						--outputfile=$outfile

done
