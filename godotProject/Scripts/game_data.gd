extends Node

var caveList: Array[Cave] = []
var batList: Array[Cave] = []
var pitList: Array[Cave] = []
var wumpusCave: Cave

# start_index - the starting point of the search
# goal_index - the ending point of the search
# finds the shortest path to the end point from the start point and returns
# the path
func bfs_shortest_path(start_index: int, goal_index: int, caveList: Array) -> Array:
	var visited = []        # stores the nodes we've already dequeued
	var fringe = []         # queue: stores the nodes we still need to explore
	var parent = {}         # for each discovered node, who we came from

	# sanity check
	if start_index < 1 or start_index > caveList.size():
		print("Start not found")
		return []

	# BFS uses indices 0–29, but cave numbers are 1–30
	var start = start_index
	var goal = goal_index

	# initialize the queue
	fringe.append(start)

	# BFS loop
	while fringe.size() > 0:
		var current = fringe.pop_front()
		visited.append(current)

		# goal test
		if current == goal:
			# reconstruct path by walking parents backwards
			var path = []
			var step = goal
			while step != start:
				path.insert(0, step + 1)  # convert index back to cave number
				step = parent.get(step, -1)
				if step == -1:
					# something went wrong
					return []
			path.insert(0, start + 1)
			return path

		# enqueue all unvisited neighbors
		for neighbor_node in caveList[current].connectingCaves:
			var neighbor = caveList.find(neighbor_node)
			if neighbor == -1:
				continue
			if neighbor in visited or neighbor in fringe:
				continue

			parent[neighbor] = current
			fringe.append(neighbor)

	# if we exhaust the queue without finding the goal
	print("Doesn't Exist")
	return []
