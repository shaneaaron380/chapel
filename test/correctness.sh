#! /bin/bash

iterations=3
timestep=1
exe=./chapel_project

for i in 10 50 100; do 
	inputfile="inputs/test_input_${i}.txt"
	outputfile="obj/$(basename $inputfile).out"
	goldfile="$(dirname $inputfile)/$(basename $inputfile .txt)_golden.txt"

	[ -e $outputfile ] && rm -rf $outputfile

	#cmd="$exe --iterations=$iterations --timestep=$timestep --inputfile=$inputfile --outputfile=$outputfile"
	#cmd="$exe --iterations=$iterations --timestep=$timestep --inputfile=$inputfile --outputfile=$outputfile --datapartasksperlocale=2 --dataparignorerunningtasks=true --dataparmingranularity=20"
	cmd="$exe --iterations=$iterations --timestep=$timestep --inputfile=$inputfile --outputfile=$outputfile --dataParIgnoreRunningTasks=true --dataParMinGranularity=20"
	echo "$cmd"
	$cmd

	bin/check_output.py $outputfile $goldfile

done

