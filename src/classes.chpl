

//struct body_geom_t {
//	double x;			// x positions
//	double y;			// y positions
//	double mass;		// masses
//	double x_vel;		// x velocities
//	double y_vel;		// y velocities
//	double x_accel;		// used for force calculations
//	double y_accel;		// used for force calculations
//};
//typedef struct body_geom_t body_geom_t;

class body_geom_t 
{
	var x, y: real;				// position
	var mass: real = 1.0;		// mass
	var x_vel, y_vel: real;		// velocities
	var x_accel, y_accel: real;	// used for force calculations
};

proc copy_body_to(old_b: body_geom_t, new_b: body_geom_t)
{
	new_b.x = old_b.x;
	new_b.y = old_b.y;
	new_b.mass = old_b.mass;
	new_b.x_vel = old_b.x_vel;
	new_b.y_vel = old_b.y_vel;
	new_b.x_accel = old_b.x_accel;
	new_b.y_accel = old_b.y_accel;
}

// return a copy of b.  i keep running into the case where simple assignmet
// (like var b: body_geom_t = old_body) just ends up copying a reference
proc copy_body(b: body_geom_t)
{
	var b2: body_geom_t = new body_geom_t();
	copy_body_to(b, b2);

	/*b2.x = b.x;*/
	/*b2.y = b.y;*/
	/*b2.mass = b.mass;*/
	/*b2.x_vel = b.x_vel;*/
	/*b2.y_vel = b.y_vel;*/
	/*b2.x_accel = b.x_accel;*/
	/*b2.y_accel = b.y_accel;*/

	return b2;
}

//struct tree_node_t {
//	double diam;
//	double quad_x;
//	double quad_y;
//	body_geom_t g;
//	int q[4];
//	int parent;
//	int padding;
//};
//typedef struct tree_node_t tree_node_t;

// ***NOTE
// our chapel stuff is built around the Node class in tree.chpl -- so now that
// the Node class is working we can use that instead of tree_node_t
class tree_node_t 
{
  var diam, quad_x, quad_y: real;
	var g: body_geom_t;
	var parent, padding: int;
  var q: [0..3] int;
};
