extends Node3D
class_name PatrolPath3D

func find_closest_node(global_pos: Vector3) -> Node3D:
	var loc: Node3D
	var closest_dist := 0
	for child in get_children():
		if child is Node3D:
			if loc == null:
				loc = child
				closest_dist = global_pos.distance_to(loc.global_position)
			else:
				var dist = global_pos.distance_to(child.global_position)
				if dist < closest_dist:
					loc = child
					closest_dist = dist
	return loc

func find_index(global_pos: Vector3) -> int:
	for i in get_child_count():
		var child = get_child(i)
		if child is Node3D:
			if child.global_position.is_equal_approx(global_pos):
				return i
	return -1

func get_next_index(index: int) -> int:
	var new_index = index + 1
	if new_index >= get_child_count():
		new_index = 0
	return new_index

func get_path_node(index: int) -> Node3D:
	return get_child(index)
