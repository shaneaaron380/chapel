use node;

class BodyPool
{
	var max_size = 128;
	var body_dom = [0..max_size-1];
	var bodies: [body_dom] body_geom_t;
	var next: int = 0;

	proc BodyPool()
	{
		atomic {
			for n in bodies do n = new body_geom_t();
		}
	}

	proc get()
	{
		atomic {
			next += 1;

			if next >= max_size then {
				/*writeln("BodyPool resize triggered");*/
				body_dom = [0..2*max_size-1];

				for i in body_dom[max_size..8*max_size-1] do 
					bodies[i] = new body_geom_t();

				max_size *= 2;
			}

			return bodies[next - 1];
		}
	}

	proc reset()
	{
		atomic {
			next = 0;
		}
	}

}

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
	var nodes: [node_dom] Node;
	var next: int = 0;

	// since there's never really a time where we'll need a node w/o a body, we
	// can just create a body pool as well
	var bp: BodyPool;

	proc NodePool()
	{
		atomic {
			bp = new BodyPool();
			for n in nodes do n = new Node();
		}
	}

	proc get()
	{
		atomic {
			next += 1;

			if next >= max_size then {
				node_dom = [0..2*max_size-1];

				for i in node_dom[max_size..8*max_size-1] do 
					nodes[i] = new Node();

				max_size *= 2;
				/*writeln("NodePool resize triggered: ", max_size);*/
			}

			nodes[next-1].b = bp.get();

			for i in 0..3 do
				nodes[next-1].children[i] = nil;

			return nodes[next - 1];
		}
	}

	proc reset()
	{
		atomic {
			bp.reset();
			next = 0;
		}
	}
}

