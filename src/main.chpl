// found this here:
// http://citeseer.ist.psu.edu/viewdoc/download;jsessionid=9253534F336CF4BA8A84350185FADBA7?doi=10.1.1.146.2498&rep=rep1&type=pdf

class Tree {								// k-ary tree
	var k: int;
	var D: domain(opaque);
	var CD: domain(1) = 1..k;				// child domain
	var children: [D][CD] index(D);

	class Node {
		var id: index(D);

		proc add_child(i: index(CD), c: Node) {
			children(id, i) = c.id;
		}

		proc child(i: index(CD)) : Node {
			return nodes(children(id, i));
		}
	}

	var nodes: [D] Node;

	proc newnode : Node {
		var n: index(D) = D.create();
		nodes(n) = new Node(id = n);
		return nodes(n);
	}
}

var tree: Tree = new Tree(k = 4);
