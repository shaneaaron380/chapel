
use classes;
use calculations;
use body_list;
use tree;

//command-line example 
//./a.out --iterations=10 --timestep=20 --input=infile --output=outfile
config const iterations = 1;
config const timestep = 1;
config const input = "in";
config const output = "out";

proc Usage(prog_name: string, ret_val: int)
{
	writeln("USAGE: ", prog_name, " --iterations=<iterations> --timestep=<timestep> --input=<input file> --output=<output file>\n");
	exit(ret_val);
}

proc main 
{
	//Usage("command", 1);

  writeln("iterations: ", iterations, " timestep: ", timestep, " input: ",
		  input, " output: ", output, "\n");
	set_calculations_timestep(timestep);

	var infile = new file(input,FileAccessMode.read);
  infile.open();
  var num_bodies: int = body_get_num_from_file(infile):int;
  var N: domain(1) = [0..num_bodies-1];
  //var bodies: [0..num_bodies-1] body_geom_t;
  var bodies: [N] body_geom_t;
  //for i in [0..num_bodies-1] do
  for b in bodies do
    b = new body_geom_t();

  body_get_list_from_file(infile, bodies);
  infile.close();
  writeln("num_bodies: ", num_bodies);
  writeln(bodies);

	for i in [0..iterations-1] {

		var tree: Node = new Node(b = new body_geom_t(mass = 0.0));

		tree.create(bodies);

		for b in bodies {
			calculate_force_of_node_on_body(tree, b);
		}

		for b in bodies {
			move_body(b);
		}

		for b in bodies {
			writeln(b.x, " ", b.y, " ", b.mass, " ", b.x_vel, " ", b.y_vel, " ");
		}

		for b in bodies {
			b.x_accel = 0.0;
			b.y_accel = 0.0;
		}
	}

  dump_bodies_to_file(output,bodies,num_bodies);

  return 0;
}

