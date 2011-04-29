use Tree;

// from here:
// http://www.cs.princeton.edu/courses/archive/fall03/cs126/assignments/barnes-hut.html
var test_p: [0..7] Body; // bound is 1000
test_p[0] = new Body(x = -600.0, y =  550.0);
test_p[1] = new Body(x =  370.0, y =  870.0);
test_p[2] = new Body(x =  120.0, y =  650.0);
test_p[3] = new Body(x =  550.0, y =  450.0);
test_p[4] = new Body(x = -550.0, y = -450.0);
test_p[5] = new Body(x = -550.0, y = -550.0);
test_p[6] = new Body(x = -130.0, y = -900.0);
test_p[7] = new Body(x =  300.0, y = -800.0);

var test_p2: [0..4] Body; // bound is 50
test_p2[0] = new Body(x = -30, y =  15);
test_p2[1] = new Body(x = 35, y =  45);
test_p2[2] = new Body(x = 45, y =  46);
test_p2[3] = new Body(x = 46, y =  35);
test_p2[4] = new Body(x = 5, y = -40);

proc main() {

	var tree: Node = new Node(b = new Body(mass = 0.0));

	tree.create(test_p2, 0.0, 0.0, 100);
}
