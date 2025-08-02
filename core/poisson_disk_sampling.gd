class_name PoissonDiskSampling
extends Object

# Poisson disk sampling algorithm for even distribution of points
# Based on Bridson's algorithm: https://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph07-poissondisk.pdf

static func generate_points(rect: Rect2, min_distance: float, max_attempts: int = 30) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var active_list: Array[Vector2] = []
	
	# Grid for spatial acceleration
	var cell_size = min_distance / sqrt(2)
	var grid_width = int(ceil(rect.size.x / cell_size))
	var grid_height = int(ceil(rect.size.y / cell_size))
	var grid: Array = []
	
	# Initialize grid
	for i in range(grid_width * grid_height):
		grid.append(-1)
	
	# Helper function to get grid index
	var get_grid_index = func(pos: Vector2) -> int:
		var x = int((pos.x - rect.position.x) / cell_size)
		var y = int((pos.y - rect.position.y) / cell_size)
		if x < 0 or x >= grid_width or y < 0 or y >= grid_height:
			return -1
		return y * grid_width + x
	
	# Helper function to check if a point is valid
	var is_valid_point = func(pos: Vector2) -> bool:
		if not rect.has_point(pos):
			return false
		
		# Check neighboring grid cells
		var grid_x = int((pos.x - rect.position.x) / cell_size)
		var grid_y = int((pos.y - rect.position.y) / cell_size)
		
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				var check_x = grid_x + dx
				var check_y = grid_y + dy
				
				if check_x < 0 or check_x >= grid_width or check_y < 0 or check_y >= grid_height:
					continue
				
				var check_index = check_y * grid_width + check_x
				if grid[check_index] != -1:
					var existing_point = points[grid[check_index]]
					if pos.distance_to(existing_point) < min_distance:
						return false
		
		return true
	
	# Start with a random point in the rect
	var initial_point = Vector2(
		rect.position.x + randf() * rect.size.x,
		rect.position.y + randf() * rect.size.y
	)
	
	points.append(initial_point)
	active_list.append(initial_point)
	var grid_index = get_grid_index.call(initial_point)
	if grid_index >= 0:
		grid[grid_index] = 0
	
	# Main algorithm loop
	while active_list.size() > 0:
		var random_index = randi() % active_list.size()
		var current_point = active_list[random_index]
		var found_valid_point = false
		
		# Try to generate a new point around the current point
		for attempt in range(max_attempts):
			var angle = randf() * TAU
			var distance = min_distance + randf() * min_distance
			var new_point = current_point + Vector2(cos(angle), sin(angle)) * distance
			
			if is_valid_point.call(new_point):
				points.append(new_point)
				active_list.append(new_point)
				var new_grid_index = get_grid_index.call(new_point)
				if new_grid_index >= 0:
					grid[new_grid_index] = points.size() - 1
				found_valid_point = true
				break
		
		# If no valid point was found, remove from active list
		if not found_valid_point:
			active_list.remove_at(random_index)
	
	return points

static func distribute_points(rect: Rect2, min_distance: float) -> Array[Vector2]:
	var all_points = generate_points(rect, min_distance)
	
	all_points.shuffle()
	return all_points
