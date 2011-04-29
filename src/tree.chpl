use particle;

class Node {
	var p: Particle;
	var children: [0..3] Node;

	proc insert(p: Particle) {
		writeln(p);
	}
}
