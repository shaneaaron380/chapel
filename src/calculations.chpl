use Math;
use Time;
use classes;
use tree;

//static double delta_time = 1.0;
var delta_time: real = 1.0;
var soften: real = 18.0;
var damping: real = 0.1;
var theta: real = 0.5;


// given 2 bodies, v and t, the force and the resultant accleration enforced by
// body v ON body t is given by the below function.
//
// t is updated in place
//
// from here:
// http://www.cs.utexas.edu/users/akanksha/cs380p/leapfrog.txt
//void compute_accln(body_geom_t const *const v, body_geom_t *t)
//{
//	double x = v->x;
//	double y = v->y;
//
//	x -= t->x;
//	y -= t->y;
//
//	double dist = x*x + y*y;
//	dist += SOFTEN;
//
//	dist = sqrt(dist * dist * dist);
//	double mag = v->mass / dist;
//
//	t->x_accel += mag * x;
//	t->y_accel += mag * y;
//}

proc compute_accln(v: body_geom_t, inout t: body_geom_t ) {

	var x: real = v.x;
	var y: real = v.y;

	x -= t.x;
	y -= t.y;

	var dist: real = x*x + y*y;
	dist += soften;

	dist = sqrt(dist * dist * dist);
	var mag: real = v.mass / dist;

	t.x_accel += mag * x;
	t.y_accel += mag * y;
}


// the below function is used to move the body ONLY after the resultant
// acceleration experienced by a body t by virtue of all other bodies is
// computed.
//
// from here:
// http://www.cs.utexas.edu/users/akanksha/cs380p/leapfrog.txt
//void move_body(body_geom_t *t) 
//{
//    // Notes : From NVIDIA CUDA SDL
//    // acceleration = force / mass;
//    // new velocity = old velocity + acceleration * deltaTime
//    // note: factor out the body's mass from the equation, here and in compute_accln
//    // (because they cancel out).  Thus here force == acceleration
//
//	// deltaTime -> is the duration of movement of each body during a single
//	// simulation of nbody system.
//    t->x_vel += t->x_accel * delta_time; 
//    t->y_vel += t->y_accel * delta_time;
//
//	// damping is used to control how much a body moves in free space
//    t->x_vel *= DAMPING; 
//    t->y_vel *= DAMPING;
//
//    t->x += t->x_vel * delta_time;
//    t->y += t->y_vel * delta_time;
//}
proc move_body(inout t: body_geom_t) 
{
    // Notes : From NVIDIA CUDA SDL
    // acceleration = force / mass;
    // new velocity = old velocity + acceleration * deltaTime
    // note: factor out the body's mass from the equation, here and in compute_accln
    // (because they cancel out).  Thus here force == acceleration

	// deltaTime -> is the duration of movement of each body during a single
	// simulation of nbody system.
  //cobegin {
    t.x_vel += t.x_accel * delta_time; 
    t.y_vel += t.y_accel * delta_time;
  //}
	// damping is used to control how much a body moves in free space
  //cobegin {
    t.x_vel *= damping; 
    t.y_vel *= damping;
  //}

  //cobegin {
    t.x += t.x_vel * delta_time;
    t.y += t.y_vel * delta_time;
  //}
}


// this is our multipole acceptance criterion for whether a the force on a
// particle "b" from another body/group of bodies "n" can be calculated with
// acceptable error
//
// this uses the simple form:
//
//		d > l / theta
//
// where "d" is the distance from "b" to center of mass of "n", and "l" is the
// length of the side of the square enclosing "n".  "theta" is a constant that
// should be acceptably set to 0.5
//
// there is supposed to be a more accurate form:
//
//		d > (1 / theta + sigma)
//
// where "sigma" is the distance from the center of mass of "n" to the
// geometric center.  see the "cell opening criterion" of "a parallel treecode"
// by john dubinski
//int MAC_acceptable(tree_node_t const *const n, body_geom_t const *const b)
//{
//	double x = b->x - n->g.x;
//	double y = b->y - n->g.y;
//
//	return sqrt(x*x + y*y) > (1.0 * n->diam / THETA);
//}
//
//void set_calculations_timestep(double timestep)
//{
//	delta_time = timestep;
//}
proc MAC_acceptable(n: Node, b: body_geom_t): int
{
	var x: real = b.x - n.b.x;
	var y: real = b.y - n.b.y;

	/*return sqrt(x*x + y*y) > (1.0 * n.diam / theta);*/
	return sqrt(x*x + y*y) > (2.0 * n.diam / theta);
}

proc set_calculations_timestep(timestep: real)
{
	delta_time = timestep;
}

// given a node and a body, calculate the force of the node (and all child
// nodes) on the body.  this is the barnes-hut implementation -- if a node is
// MAC acceptable, it just does the calculation, otherwise it opens the node
// up and recurses down the tree
//
// note that if the given node is the root of the tree, this will make the
// full barnes hut calculation for the body
//
// "b" is updated in place
proc calculate_force_of_node_on_body(n: Node, b: body_geom_t) 
{
	if n.i_am_a_leaf() then {
		compute_accln(n.b, b);
	} else if MAC_acceptable(n, b) then {
		compute_accln(n.b, b);
	} else {
		for c in n.children {
			if c != nil then {
				calculate_force_of_node_on_body(c, b);
			}
		}
	}
}

// perform the full barnes hut calculation on a set of bodies in serial.  the
// body list is modified in place
proc barnes_hut_serial(iterations: int, timestep: int, bodies: [?D] body_geom_t)
{
	set_calculations_timestep(timestep);

	var t: Timer;

	t.start();
	for i in [0..iterations-1] {

		var tree: Node = new Node(b = new body_geom_t(mass = 0.0));

		tree.create(bodies, x = 0.0, y = 0.0, desired_diam = 9999.0 * 2);

		for b in bodies {
			calculate_force_of_node_on_body(tree, b);
		}

		for b in bodies {
			move_body(b);
		}

		for b in bodies {
			b.x_accel = 0.0;
			b.y_accel = 0.0;
		}

		delete_tree(tree);
	}
	t.stop();

	writeln("Elapsed time: ", t.elapsed());
}

// perform the full barnes hut calculation on a set of bodies in parallel.  the
// body list is modified in place
proc barnes_hut_parallel(iterations: int, timestep: int, bodies: [?D] body_geom_t)
{
	set_calculations_timestep(timestep);

	var t: Timer;

	t.start();
	for i in [0..iterations-1] {

		var tree: Node = new Node(b = new body_geom_t(mass = 0.0));

		tree.create(bodies, x = 0.0, y = 0.0, desired_diam = 9999.0 * 2);

		coforall b in bodies {
			calculate_force_of_node_on_body(tree, b);
		}

		coforall b in bodies {
			move_body(b);
		}

		coforall b in bodies {
			b.x_accel = 0.0;
			b.y_accel = 0.0;
		}

		delete_tree(tree);
	}
	t.stop();

	writeln("Elapsed time: ", t.elapsed());
}
