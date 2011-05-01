use node_pool;
use classes;

var NW: int = 0;
var NE: int = 1;
var SW: int = 2;
var SE: int = 3;

var global_node_pool: NodePool = nil;
proc set_global_node_pool(n: NodePool)
{
	global_node_pool = n;
}

class Limits
{
	var max_x, min_x, max_y, min_y: real;

	proc Limits(bodies: [?D] body_geom_t) 
	{
		max_x = bodies[0].x;
		min_x = bodies[0].x;
		max_y = bodies[0].y;
		min_y = bodies[0].y;

		//coforall b in bodies {
		for b in bodies {

			if (b.x > max_x) then max_x = b.x;

			if (b.y > max_y) then max_y = b.y;

			if (b.x < min_x) then min_x = b.x;

			if (b.y < min_y) then min_y = b.y;

		}
	}

	proc diam(): real 
	{
		if max_x - min_x > max_y - min_y then 
			return max_x - min_x;
		else
			return max_y - min_y;
	}

	proc quad_x(): real 
	{
		return (max_x + min_x) / 2.0;
	}

	proc quad_y(): real 
	{
		return (max_y + min_y) / 2.0;
	}

}

class Limits_p : Limits 
{

	proc Limits_p(bodies: [?D] body_geom_t) 
	{
		cobegin {
			max_x = max reduce [b in bodies] b.x; 
			max_y = max reduce [b in bodies] b.y; 
			min_x = min reduce [b in bodies] b.x; 
			min_y = min reduce [b in bodies] b.y; 
		}
	}

}

class Node 
{
	var b: body_geom_t;

	// quad_x/y is the center location of this node.  note that for a leaf node
	// this doesn't matter, but for internal nodes, this is used to determine
	// in which quadrant a new particle falls.  as particles are added to a
	// node, its center of mass changes, but the location (quad_x/y) stays the
	// same
	var quad_x, quad_y: real;
	var diam: real;				// diameter of this node's area

	var children: [0..3] Node;


	// given a new body, update my mass and center of mass with its numbers
	proc update_mass_and_com(new_b: body_geom_t) 
	{

		var new_mass: real = b.mass + new_b.mass;

		// center of mass (com)
		b.x = (b.x * b.mass + new_b.x * new_b.mass) / new_mass;
		b.y = (b.y * b.mass + new_b.y * new_b.mass) / new_mass;

		// mass
		b.mass = new_mass;

	}

	// given a body, determine which quadrant of mine it belongs to
	proc which_quadrant(new_b: body_geom_t): int 
	{
		var which = NW;
		if new_b.x <= quad_x then
			if new_b.y >= quad_y then
				return NW;
			else
				return SW;
		else
			if new_b.y >= quad_y then
				return NE;
			else
				return SE;
	}

	proc i_am_a_leaf(): bool 
	{
		return  (children[NW] == nil) && 
				(children[NE] == nil) &&
				(children[SW] == nil) &&
				(children[SE] == nil);
	}

	
	proc new_node_from_body(new_b: body_geom_t): Node 
	{ 

		/////////////////////////////////////// DEBUG
		/*// make sure the body is actually in our area*/
		/*if ! (new_b.x <= (quad_x + (diam / 2.0))) then {*/
		/*    writeln("============================================= ERROR:");*/
		/*    writeln(new_b);*/
		/*    writeln(this);*/
		/*    writeln("=============================================");*/
		/*}*/
		/*assert(new_b.x <= (quad_x + (diam / 2.0)));*/

		/*assert(new_b.x >= (quad_x - (diam / 2.0)));*/

		/*if ! (new_b.y <= (quad_y + (diam / 2.0))) then {*/
		/*    writeln("ERROR:");*/
		/*    writeln("(",new_b.x,",",new_b.y, ") ", quad_y, " ", diam);*/
		/*}*/
		/*assert(new_b.y <= (quad_y + (diam / 2.0)));*/

		/*assert(new_b.y >= (quad_y - (diam / 2.0)));*/
		/////////////////////////////////////// END DEBUG



		/*var n: Node = new Node(b = new_b, diam = diam / 2.0);*/

		// the above line would be nice, but it doesn't copy new_b, it just
		// references it, so we've got do make it hacky

		/*var n: Node = new Node(diam = diam / 2.0);*/
		/*n.b = new body_geom_t();*/
		/*n.b.x = new_b.x;*/
		/*n.b.y = new_b.y;*/
		/*n.b.mass = new_b.mass;*/
		/*n.b.x_vel = new_b.x_vel;*/
		/*n.b.y_vel = new_b.y_vel;*/
		/*n.b.x_accel = new_b.x_accel;*/
		/*n.b.y_accel = new_b.y_accel;*/

		var n: Node = new Node(b = copy_body(new_b), diam = diam / 2.0);

		var new_quad = which_quadrant(new_b);

		if  new_quad == NW then {
			n.quad_x = quad_x - n.diam / 2;
			n.quad_y = quad_y + n.diam / 2;

		} else if new_quad == NE {
			n.quad_x = quad_x + n.diam / 2;
			n.quad_y = quad_y + n.diam / 2;

		} else if new_quad == SW {
			n.quad_x = quad_x - n.diam / 2;
			n.quad_y = quad_y - n.diam / 2;

		} else if new_quad == SE {
			n.quad_x = quad_x + n.diam / 2;
			n.quad_y = quad_y - n.diam / 2;
		}

		return n;
	}

	proc split_leaf_into_two(new_b: body_geom_t) 
	{
		assert(i_am_a_leaf());

		// insert my current body as a child in the appropriate quadrant
		children[which_quadrant(b)] = new_node_from_body(b);

		// now that i'm an internal node, re-insert the new body into myself
		insert(new_b);
	}

	// this inserts a new body into one the appropriate child of this node.
	proc insert(new_b: body_geom_t) 
	{
		if i_am_a_leaf() then {
			split_leaf_into_two(new_b);

		} else {

			var quad: int = which_quadrant(new_b);

			if children[quad] == nil then {
				children[quad] = new_node_from_body(new_b);
			} else {
				children[quad].insert(new_b);
			}

			update_mass_and_com(new_b);

		}

	}

	// this creates a tree, using this node as the root.  this should be a
	// separate function, but when i make it separate i get these 'invalid use
	// of "new"' compilation errors, so i'm just putting it here
	proc create(bodies: [?D] body_geom_t) 
	{
		var l: Limits = new Limits(bodies);

		create(bodies, l.quad_x(), l.quad_y(), l.diam() + 0.1);

		delete l;
	}

	proc create(bodies: [?D] body_geom_t, x: real, y: real, desired_diam: real) 
	{
		// make sure we're not calling this function on a node that already has
		// children
		assert(i_am_a_leaf());

		diam = desired_diam;
		quad_x = x;
		quad_y = y;

		// make this node the root node with the first body
		b = copy_body(bodies[0]);

		for new_b in bodies(1..) {
			insert(new_b);
		}

	}

}

//Parallel Node class with functions exploiting task parallelism
class Node_p 
{
	var b: body_geom_t;

	// quad_x/y is the center location of this node.  note that for a leaf node
	// this doesn't matter, but for internal nodes, this is used to determine
	// in which quadrant a new particle falls.  as particles are added to a
	// node, its center of mass changes, but the location (quad_x/y) stays the
	// same
	var quad_x, quad_y: real;
	var diam: real;				// diameter of this node's area

	var children: [0..3] Node_p;


	// given a new body, update my mass and center of mass with its numbers
	proc update_mass_and_com(new_b: body_geom_t) 
	{
		var new_mass: real = b.mass + new_b.mass;

		// center of mass (com)
		//cobegin {
		b.x = (b.x * b.mass + new_b.x * new_b.mass) / new_mass;
		b.y = (b.y * b.mass + new_b.y * new_b.mass) / new_mass;
		//}
		// mass
		b.mass = new_mass;

	}

	// given a body, determine which quadrant of mine it belongs to
	proc which_quadrant(new_b: body_geom_t): int 
	{
		var which = NW;
		if new_b.x <= quad_x then
			if new_b.y >= quad_y then
				return NW;
			else
				return SW;
		else
			if new_b.y >= quad_y then
				return NE;
			else
				return SE;
	}

	proc i_am_a_leaf(): bool 
	{
		return  (children[NW] == nil) && 
				(children[NE] == nil) &&
				(children[SW] == nil) &&
				(children[SE] == nil);
	}

	
	proc new_node_from_body(new_b: body_geom_t): Node_p 
	{ 

		/////////////////////////////////////// DEBUG
		/*// make sure the body is actually in our area*/
		/*if ! (new_b.x <= (quad_x + (diam / 2.0))) then {*/
		/*    writeln("============================================= ERROR:");*/
		/*    writeln(new_b);*/
		/*    writeln(this);*/
		/*    writeln("=============================================");*/
		/*}*/
		/*assert(new_b.x <= (quad_x + (diam / 2.0)));*/

		/*assert(new_b.x >= (quad_x - (diam / 2.0)));*/

		/*if ! (new_b.y <= (quad_y + (diam / 2.0))) then {*/
		/*    writeln("ERROR:");*/
		/*    writeln("(",new_b.x,",",new_b.y, ") ", quad_y, " ", diam);*/
		/*}*/
		/*assert(new_b.y <= (quad_y + (diam / 2.0)));*/

		/*assert(new_b.y >= (quad_y - (diam / 2.0)));*/
		/////////////////////////////////////// END DEBUG



		/*var n: Node_p = new Node_p(b = new_b, diam = diam / 2.0);*/

		// the above line would be nice, but it doesn't copy new_b, it just
		// references it, so we've got do make it hacky

		/*var n: Node_p = new Node_p(diam = diam / 2.0);*/
		/*n.b = new body_geom_t();*/
		/*n.b.x = new_b.x;*/
		/*n.b.y = new_b.y;*/
		/*n.b.mass = new_b.mass;*/
		/*n.b.x_vel = new_b.x_vel;*/
		/*n.b.y_vel = new_b.y_vel;*/
		/*n.b.x_accel = new_b.x_accel;*/
		/*n.b.y_accel = new_b.y_accel;*/

		var n: Node_p = new Node_p(b = copy_body(new_b), diam = diam / 2.0);

		var new_quad = which_quadrant(new_b);

		if  new_quad == NW then {
			n.quad_x = quad_x - n.diam / 2;
			n.quad_y = quad_y + n.diam / 2;

		} else if new_quad == NE {
			n.quad_x = quad_x + n.diam / 2;
			n.quad_y = quad_y + n.diam / 2;

		} else if new_quad == SW {
			n.quad_x = quad_x - n.diam / 2;
			n.quad_y = quad_y - n.diam / 2;

		} else if new_quad == SE {
			n.quad_x = quad_x + n.diam / 2;
			n.quad_y = quad_y - n.diam / 2;
		}

		return n;
	}

	proc split_leaf_into_two(new_b: body_geom_t) 
	{
		assert(i_am_a_leaf());

		//cobegin {
		// insert my current body as a child in the appropriate quadrant
		children[which_quadrant(b)] = new_node_from_body(b);
		//}

		// now that i'm an internal node, re-insert the new body into myself
		insert(new_b);
	}

	// this inserts a new body into one the appropriate child of this node.
	proc insert(new_b: body_geom_t) 
	{
		if i_am_a_leaf() then {
			split_leaf_into_two(new_b);

		} else {

			var quad: int = which_quadrant(new_b);

			if children[quad] == nil then {
				children[quad] = new_node_from_body(new_b);
			} else {
				children[quad].insert(new_b);
			}

			update_mass_and_com(new_b);

		}

	}

	// this creates a tree, using this node as the root.  this should be a
	// separate function, but when i make it separate i get these 'invalid use
	// of "new"' compilation errors, so i'm just putting it here
	proc create(bodies: [?D] body_geom_t) 
	{
		var l: Limits_p = new Limits_p(bodies);

		create(bodies, l.quad_x(), l.quad_y(), l.diam() + 0.1);

		delete l;
	}

	proc create(bodies: [?D] body_geom_t, x: real, y: real, desired_diam: real) 
	{
		// make sure we're not calling this function on a node that already has
		// children
		assert(i_am_a_leaf());

		diam = desired_diam;
		quad_x = x;
		quad_y = y;
		// make this node the root node with the first body
		b = copy_body(bodies[0]);

		for new_b in bodies(1..) {
			insert(new_b);
		}

	}

}

