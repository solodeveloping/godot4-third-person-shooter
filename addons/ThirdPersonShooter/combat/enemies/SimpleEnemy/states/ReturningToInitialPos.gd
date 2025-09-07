extends SimpleEenemyState

func enter():
	enemy.animation_tree.set("parameters/RootState/transition_request", "Moving")

func physics_process(delta: float):
	if enemy.patrol_path_3D:
		pass
	enemy.try_move_to_target(delta, enemy.pre_aggro_global_pos)
	if enemy.navigation_agent_3d.is_navigation_finished():
		if enemy.patrol_path_3D:
			# TODO : implement this
			pass
		else:
			state_machine.transition_to("Idle")
