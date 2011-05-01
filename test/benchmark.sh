#! /bin/bash

iterations=3
timestep=1
exe=./chapel_project

for i in {1..4}; do
	inputfile="inputs/test_input_${i}.txt"
	outputfile="obj/$(basename $inputfile).out"

	[ -e $outputfile ] && rm -rf $outputfile

	#./chapel_project	--iterations=3 \
	#                    --timestep=1 \
	#                    --inputfile=$inputfile \
	#                    --outputfile=$outputfile
	cmd="$exe --iterations=$iterations --timestep=$timestep --inputfile=$inputfile --outputfile=$outputfile"
	echo "$cmd"
	$cmd

done
