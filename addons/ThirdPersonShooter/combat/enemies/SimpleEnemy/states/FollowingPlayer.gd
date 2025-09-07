extends SimpleEenemyState

func enter():
	enemy.animation_tree.set("parameters/RootState/transition_request", "Moving")

func physics_process(delta: float):
	if enemy.target:
		var dist_to_player = (enemy.global_position - enemy.target.global_position).length()
		if (enemy.def.use_deaggro_dist):
			if dist_to_player >= enemy.def.deaggro_dist:
				state_machine.transition_to("ReturningToInitialPos")
				enemy.target = null
				return
		if !enemy.current_weapon.weapon.is_melee_weapon:
			if dist_to_player <= enemy.def.attacking_range:
				if enemy.has_line_of_sight_on_player():
					state_machine.transition_to("Attacking")
					return
				if enemy.is_gun_facing_target():
					if enemy.has_line_of_sight_on_player():
						state_machine.transition_to("Attacking")
						return
		else:
			if dist_to_player <= enemy.current_weapon.weapon.melee_attacking_range:
				if enemy.attack_timer.is_stopped():
					melee_attack()
				return
		
		if enemy.attack_timer.is_stopped():
			enemy.animation_tree.set("parameters/SwordAttack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
			enemy.try_move_to_target(delta, enemy.target.global_position)
	else:
		state_machine.transition_to("ReturningToInitialPos")

func melee_attack():
	enemy.animation_tree.set("parameters/SwordAttack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	enemy.attack_timer.start(1 / enemy.current_weapon.weapon.fire_rate)
	# TODO : do this everywhere, the checking part
	if enemy.current_weapon.weapon.shoot_sfx:
		await get_tree().create_timer(0.2).timeout
		enemy.audio_stream_player_3d.play()
	
