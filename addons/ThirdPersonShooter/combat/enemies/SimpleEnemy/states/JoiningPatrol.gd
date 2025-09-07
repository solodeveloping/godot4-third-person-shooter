extends SimpleEenemyState

func enter():
	enemy.animation_tree.set("parameters/RootState/transition_request", "Moving")

func physics_process(delta: float):
	if !enemy.patrol_path_3D:
		return
	
	enemy.try_move_to_target(delta, enemy._target_global_pos)
	
	if enemy.navigation_agent_3d.is_target_reached():
		state_machine.transition_to("Patrolling")
