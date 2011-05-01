use classes;
use calculations;
use body_list;
use tree;

//command-line example 
//./a.out --iterations=10 --timestep=20 --inputfile=infile --outputfile=outfile
config const iterations = 1;
config const timestep = 1;
config const inputfile = "in";
config const outputfile = "none";

proc Usage(prog_name: string, ret_val: int)
{
	writeln("USAGE: ", prog_name, " --iterations=<iterations> --timestep=<timestep> --inputfile=<input file> --outputfile=<output file>\n");
	exit(ret_val);
}

proc main 
{
	/*writeln("iterations: ", iterations, " timestep: ", timestep, " inputfile: ",*/
	/*        inputfile, " outputfile: ", outputfile);*/

	// this is done in barnes_hut_serial(), but we'll keep it here just in
	// case
	set_calculations_timestep(timestep);

	var infile = new file(inputfile,FileAccessMode.read);
	infile.open();
	var num_bodies: int = body_get_num_from_file(infile):int;
	var N: domain(1) = [0..num_bodies-1];
	var bodies: [N] body_geom_t;
	for b in bodies do
		b = new body_geom_t();
	body_get_list_from_file(infile, bodies);
	infile.close();
	writeln("num_bodies: ", num_bodies);

	barnes_hut_serial(iterations, timestep, bodies);
	/*barnes_hut_parallel(iterations, timestep, bodies);*/

	if outputfile != "none" then
		dump_bodies_to_file(outputfile,bodies,num_bodies);

	for b in bodies do
		delete b;
	
  return 0;
}

