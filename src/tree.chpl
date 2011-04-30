/*use body;*/
use Node;

proc delete_tree(n: Node)
{
	for c in n.children do
		if c != nil then
			delete_tree(c);

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

}
