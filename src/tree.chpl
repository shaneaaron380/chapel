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

