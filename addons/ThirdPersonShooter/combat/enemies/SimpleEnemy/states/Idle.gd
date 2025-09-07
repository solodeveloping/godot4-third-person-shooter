extends SimpleEenemyState

func enter():
	enemy.animation_tree.set("parameters/RootState/transition_request", "Idle")
	if enemy.patrol_path_3D:
		var closest = enemy.patrol_path_3D.find_closest_node(enemy.global_position)
		enemy._target_global_pos = closest.global_position
		state_machine.transition_to("JoiningPatrol")

func process(delta: float):
	if enemy.target:
		if enemy.def.use_aggro_fow:
			if enemy.is_node_in_fow(enemy.def.aggro_fow_deg, enemy.target):
				enemy.pre_aggro_global_pos = enemy.global_position
				state_machine.transition_to("FollowingPlayer")
