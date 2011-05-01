/*use body;*/
use node;

proc delete_tree(n: Node)
{
	for c in n.children do
		if c != nil then
			delete_tree(c);

	delete n.b;
	delete n;
}

proc delete_tree_p(n: Node_p)
{
	for c in n.children do
		if c != nil then
			delete_tree_p(c);

	delete n.b;
	delete n;
}

proc print_tree(n: Node) 
{
	writeln("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
	print_tree_iter(n, 1);
}

proc print_tree_iter(n: Node, level: int) 
{
	write(level, ": ", n.b.x, ",", n.b.y, "/", n.b.mass, "  (", n.quad_x, ",",
			n.quad_y, ")/", n.diam, "    {");

	for c in n.children {
		if c == nil then
			write("    nil");
		else
			write("    ",c.b.x,",",c.b.y,"/",c.b.mass);
	}
	writeln("    }");

	for c in n.children { if c != nil then print_tree_iter(c, level + 1); }

}

class NodePool
{
	var max_size = 64;
	var node_dom = [0..max_size-1];
	var nodes: [node_dom] Node;
	var next: int = 0;

	proc NodePool()
	{
		for n in nodes do n = new Node();
	}

	proc get()
	{
		next += 1;

		if next >= max_size then {
			node_dom = [0..2*max_size-1];
			max_size *= 2;
		}

		return nodes[next - 1];
	}

	proc reset()
	{
		next = 0;
	}
}
