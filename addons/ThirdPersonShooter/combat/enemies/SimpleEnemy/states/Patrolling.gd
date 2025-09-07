extends SimpleEenemyState

var current_index := 0

func enter():
	enemy.animation_tree.set("parameters/RootState/transition_request", "Moving")
	
	var index = enemy.patrol_path_3D.find_index(
		enemy._target_global_pos
	)
	if index == -1:
		push_warning("node of path not found")
		index = 0
	
	current_index = enemy.patrol_path_3D.get_next_index(index)
	var node = enemy.patrol_path_3D.get_path_node(current_index)
	enemy._target_global_pos = node.global_position

func physics_process(delta: float):
	enemy.try_move_to_target(delta, enemy._target_global_pos)
	
	if enemy.navigation_agent_3d.is_target_reached():
		current_index = enemy.patrol_path_3D.get_next_index(current_index)
		var node = enemy.patrol_path_3D.get_path_node(current_index)
		enemy._target_global_pos = node.global_position
		enemy.set_nagivation_target_pos(node.global_position)
	
