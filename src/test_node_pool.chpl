use tree;

// this function iteratively adds children (as child 0) with "node" as the
// root.  so it builds a "tree" that's really more of just a linked list.  as
// it does so, it sets the "diam" field of the node, starting at "val" and
// incrementing as it goes
proc add_n_children_inc_vals(np: NodePool, node: Node_p, n: int, val: real = 0): Node_p
{
	proc add_and_return(np: NodePool, node: Node_p, val: real): Node_p
	{
		node.children[0] = np.get();
		node.children[0].diam = val;

		return node.children[0];
	}

	var cur_val: real = val;
	node.diam = cur_val;
	var cur: Node_p = node;

	for i in 1..n-1 do {
		cur_val += 1.0;
		cur = add_and_return(np, cur, cur_val);
	}

	return cur;
}

// this function iteratively adds children (as child 0) with "node" as the
// root.  so it builds a "tree" that's really more of just a linked list.  as
// it does so, it sets the "diam" field of the node to "val"
proc add_n_children_const_val(np: NodePool, node: Node_p, n: int, val: real = 5): Node_p
{
	proc add_and_return(np: NodePool, node: Node_p): Node_p
	{
		node.children[0] = np.get();
		node.children[0].diam = val;

		return node.children[0];
	}

	node.diam = val;
	var cur: Node_p = node;
	for i in 1..n-1 do {
		cur = add_and_return(np, cur);
	}

	return cur;
}

proc print_vals(n: Node_p)
{
	write(n.diam, ' ');
	if n.children[0] == nil then
		write('\n');
	else
		print_vals(n.children[0]);
}

proc main()
{
	var np = new NodePool();
	var start: Node_p = np.get();
	var orig_max_size = np.max_size;

	// add just under the max size of children
	var last: Node_p = add_n_children_inc_vals(np, start, np.max_size - 1);

	// make sure there hasn't been a re-alloc
	assert(np.max_size == orig_max_size);
	assert(np.next == np.max_size - 1);

	var max_size_before_realloc: int = np.max_size;

	// now add another 16 to trigger a re-alloc
	var node_at_realloc: Node_p = 
		add_n_children_inc_vals(np, last, 16, last.diam);
	assert(np.max_size == max_size_before_realloc * 2);

	var cur_node = start; 
	/*writeln("====================");*/
	/*print_vals(start);*/
	/*writeln("--------------------");*/
	for i in 0..(orig_max_size-1 + 16 - 2) do {
		assert(i == cur_node.diam: int);
		
		if i < (orig_max_size-1 + 16 - 2) then
			assert(cur_node.children[0] != nil);
		else
			assert(cur_node.children[0] == nil);

		cur_node = cur_node.children[0];
	}

	// now reset the node pool and ensure that the nodes are still valid
	np.reset();
	cur_node = start;
	for i in 0..(orig_max_size-1 + 16 - 2) do {
		assert(i == cur_node.diam: int);
		
		if i < (orig_max_size-1 + 16 - 2) then
			assert(cur_node.children[0] != nil);
		else
			assert(cur_node.children[0] == nil);

		cur_node = cur_node.children[0];
	}
	var new_start: Node_p = np.get();
	assert(new_start.diam == start.diam);

	// verywell. now let's add a bunch more with a constant value
	var const_val: real = 5.0;
	new_start.diam = const_val;

	last = add_n_children_const_val(np, new_start, 512, const_val);
	cur_node = new_start;
	for i in 0..511 do {
		assert(cur_node.diam == const_val);
		cur_node = cur_node.children[0];
	}

	// check that our original reference to the start is now pointing to the
	// same thing as the new reference to the start (since they both refer to
	// the beginning of the array)
	assert(start.diam == new_start.diam);

	// now we need to stress test it for long enough that i can open up
	// activity monitor and make sure memory isn't spilling out all over the
	// place.  this test simulates how NodePool will be used in the barnes-hut
	// calculation
	for i in 0..4096-1 do {
		np.reset();
		var iter_start: Node_p = np.get();
		iter_start.diam = i;
		var iter_last: Node_p = add_n_children_inc_vals(np, iter_start, 1024, i);
		/*writeln("====================");*/
		/*print_vals(start);*/
		/*writeln("--------------------");*/

		var iter_cur: Node_p = iter_start;
		for j in 0..1024-1 do {
			assert(iter_cur.diam == i+j);
			iter_cur = iter_cur.children[0];
		}
	}
}
