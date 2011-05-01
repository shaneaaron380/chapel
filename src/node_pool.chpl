use node;

// it's just a pool of nodes that grows.  that's it.  it never frees them, but
// if you call reset() then it will reuse the ones its already allocated.  this
// is the same way we dished out nodes in our MPI implementation: we just have
// and array that grows (when necessary) and instead of freeing the memory, we
// just start at the beginning
class NodePool
{
	// you should be able to adjust this "max_size" member without breaking the
	// unit tests in test_node_pool.chpl
	var max_size = 128;
	var node_dom = [0..max_size-1];
	var nodes: [node_dom] Node_p;
	var next: int = 0;

	proc NodePool()
	{
		for n in nodes do n = new Node_p();
	}

	proc get()
	{
		next += 1;

		if next >= max_size then {
			node_dom = [0..2*max_size-1];

			for i in node_dom[max_size..8*max_size-1] do 
				nodes[i] = new Node_p();

			max_size *= 2;
		}

		for i in 0..3 do
			nodes[next-1].children[i] = nil;

		return nodes[next - 1];
	}

	proc reset()
	{
		next = 0;
	}
}

