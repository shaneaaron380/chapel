use tree;
use calculations;

// from here:
// http://www.cs.princeton.edu/courses/archive/fall03/cs126/assignments/barnes-hut.html
var test_p: [0..7] body_geom_t; // bound is 1000
test_p[0] = new body_geom_t(x = -600.0, y =  550.0);
test_p[1] = new body_geom_t(x =  370.0, y =  870.0);
test_p[2] = new body_geom_t(x =  120.0, y =  650.0);
test_p[3] = new body_geom_t(x =  550.0, y =  450.0);
test_p[4] = new body_geom_t(x = -550.0, y = -450.0);
test_p[5] = new body_geom_t(x = -550.0, y = -550.0);
test_p[6] = new body_geom_t(x = -130.0, y = -900.0);
test_p[7] = new body_geom_t(x =  300.0, y = -800.0);

var test_p2: [0..4] body_geom_t; // bound is 50
test_p2[0] = new body_geom_t(x = -30, y =  15);
test_p2[1] = new body_geom_t(x = 35, y =  45);
test_p2[2] = new body_geom_t(x = 45, y =  46);
test_p2[3] = new body_geom_t(x = 46, y =  35);
test_p2[4] = new body_geom_t(x = 5, y = -40);

var test_p3: [0..9] body_geom_t;
test_p3[0] = new body_geom_t(x = 1000, y = 1000, mass = 3);
test_p3[1] = new body_geom_t(x = 1000, y = 999, mass = 2);
test_p3[2] = new body_geom_t(x = 1000, y = 998, mass = 1);
test_p3[3] = new body_geom_t(x = 1000, y = 997, mass = 3);
test_p3[4] = new body_geom_t(x = 1000, y = 996, mass = 1);
test_p3[5] = new body_geom_t(x = 1000, y = 995, mass = 3);
test_p3[6] = new body_geom_t(x = 1000, y = 994, mass = 2);
test_p3[7] = new body_geom_t(x = 1000, y = 993, mass = 1);
test_p3[8] = new body_geom_t(x = 1000, y = 992, mass = 1);
test_p3[9] = new body_geom_t(x = 1000, y = 991, mass = 1);

proc main() 
{
	var iterations: int = 3;

	for i in [0..iterations-1] {

		var tree: Node = new Node(b = new body_geom_t(mass = 0.0));

		tree.create(test_p3);

		for b in test_p3 {
			calculate_force_of_node_on_body(tree, b);
		}

		for b in test_p3 {
			move_body(b);
		}

		for b in test_p3 {
			writeln(b.x, " ", b.y, " ", b.mass, " ", b.x_vel, " ", b.y_vel, " ");
		}

		for b in test_p3 {
			b.x_accel = 0.0;
			b.y_accel = 0.0;
		}
	}
}
