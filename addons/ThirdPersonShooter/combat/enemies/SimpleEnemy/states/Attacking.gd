extends SimpleEenemyState

var shot_count: int = 0

var out_of_line_of_sight_time: int = 0

func enter():
	out_of_line_of_sight_time = 0
	if enemy.current_weapon != null:
		enemy.animation_tree.set("parameters/RootState/transition_request", "Aiming")

func process(delta: float):
	if enemy.target == null:
		return
		
	var dir = enemy.global_position.direction_to(
		enemy.target.global_position
	)
	dir.y = 0
	
	enemy.rotation.y = lerp_angle(
		enemy.rotation.y,
		atan2(-dir.x,-dir.z),
		enemy.def.turn_speed
	)
	
	if enemy.current_weapon == null:
		push_warning("enemy does not have a weapon")
		return
		
	var dist_to_player = enemy.global_position.distance_to(
		enemy.target.chest_point.global_position
	)
	if dist_to_player >= enemy.def.deaggro_dist:
		state_machine.transition_to("ReturningToInitialPos")
		return
	
	# TODO : destructibles, enemy can shoot on them
	if !enemy.has_line_of_sight_on_player():
		if out_of_line_of_sight_time == 0:
			out_of_line_of_sight_time = Time.get_ticks_msec() +  \
				enemy.def.out_of_line_of_sight_follow_time_ms
		else:
			if Time.get_ticks_msec() >= out_of_line_of_sight_time:
				state_machine.transition_to("FollowingPlayer")
		return
		
	if dist_to_player >= enemy.def.attacking_range:
		state_machine.transition_to("FollowingPlayer")
		return
	
	if enemy.is_gun_facing_target():
		if enemy.current_weapon.weapon.is_hand_combat == false:
			if !enemy.is_reloading:
				if enemy.current_weapon.current_mag > 0:
					if enemy.attack_timer.is_stopped():
						if enemy.def.gun_attack_rate_limit_enabled:
							if enemy.gun_attack_rate_limiter_timer.is_stopped():
								shoot()
						else:
							shoot()
				else:
					reload()
	else:
		pass

func shoot():
	if !enemy.current_weapon or !enemy.current_weapon.weapon:
		return
	
	var space_state = enemy.get_world_3d().direct_space_state
	
	for b in range(enemy.current_weapon.weapon.projectile_count):
		shot_count += 1
		
		var spread = enemy.current_weapon.weapon.spread + enemy.current_weapon.weapon.aim_spread
		var spread_x = randf_range(-spread, spread)
		var spread_y = randf_range(-spread, spread)
		
		var dir = enemy.gun_ray_cast_3d.global_position.direction_to(
			enemy.target.chest_point.global_position
		)
		var dist = enemy.gun_ray_cast_3d.global_position.distance_to(
			enemy.target.chest_point.global_position
		)
		var target = enemy.gun_ray_cast_3d.global_position + (dir * enemy.current_weapon.weapon.max_range)
		var variation = remap(
			enemy.current_weapon.weapon.spread,
			0,
			50,
			-30,
			30
		)
		var dist_scaled = remap(
			dist,
			0,
			enemy.current_weapon.weapon.max_range,
			-1,
			1
		)
		var _range = variation * dist_scaled
		var offset = Vector3(
			randf_range(-_range, _range),
			randf_range(-_range, _range) / 10,
			randf_range(-_range, _range),
		)
		target += offset
		
		var query = PhysicsRayQueryParameters3D.create(
			enemy.gun_ray_cast_3d.global_position, target
		)
		query.collide_with_areas = true
		query.collide_with_bodies = true
		query.collision_mask = enemy.def.player_and_env_collision_mask

		var result = space_state.intersect_ray(query)
		
		var collider = result.get("collider", null)
		var point = result.get("position", null)
		var normal = result.get("normal", null)
		
		if collider:
			if collider is Node3D:
				var _parent: Node3D
				if collider is TakeDamage3D:
					_parent = collider.target_parent.get_parent()
				else:
					if collider.get_parent().get_parent() is Node3D:
						_parent = collider.get_parent().get_parent()
				
				if collider.is_in_group("player") or (_parent and _parent.is_in_group("player")):
					var is_critical = false
					var damage = get_current_damage()
					if collider.is_in_group("head"):
						is_critical = true
						damage *= 2
					
					enemy.event_bus.send_damage_player.emit(
				 		collider,
						point,
						damage,
						is_critical
					)
					if enemy.current_weapon.weapon.humanoid_impact_vfx:
						enemy.event_bus.send_weapon_vfx_requested.emit(
							point,
							enemy.current_weapon.weapon.humanoid_impact_vfx,
							0
						)
				else:
					if enemy.current_weapon.weapon.bullet_decal:
						var decal = enemy.current_weapon.weapon.bullet_decal.instantiate()
						collider.add_child(decal)
						decal.global_transform.origin = point
						decal.look_at(point + normal, Vector3.UP)
					
					if enemy.current_weapon.weapon.environment_impact_vfx:
						enemy.event_bus.send_weapon_vfx_requested.emit(
							point,
							enemy.current_weapon.weapon.environment_impact_vfx,
							0
						)
					
				if enemy.muzzle_flash:
					if enemy.current_weapon.weapon.bullet_trail:
						enemy.event_bus.send_spawn_bullet_trail.emit(
							enemy.current_weapon.weapon.bullet_trail,
							enemy.muzzle_flash.global_position,
							point,
						)
		else:
			if enemy.muzzle_flash:
				if enemy.current_weapon.weapon.bullet_trail:
					enemy.event_bus.send_spawn_bullet_trail.emit(
						enemy.current_weapon.weapon.bullet_trail,
						enemy.muzzle_flash.global_position,
						target,
					)
	
	if !enemy.audio_stream_player_3d.playing:
		enemy.audio_stream_player_3d.play()

	enemy.attack_timer.start(1 / enemy.current_weapon.weapon.fire_rate)
	if enemy.def.gun_attack_rate_limit_enabled:
		enemy.gun_attack_rate_limiter_timer.start()
	
	enemy.animation_tree.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	enemy.current_weapon.current_mag -= 1
	
	if enemy.muzzle_flash != null:
		enemy.muzzle_flash.emitting = true

func reload():
	if !enemy.has_gun():
		return
	if enemy.inventory.get_bullet_count(enemy.current_weapon.weapon.ammo_type) == 0:
		return
	
	enemy.is_reloading = true
	enemy.reload_timer.start(1 / enemy.current_weapon.weapon.reload_speed)
	enemy.reload_audio_stream_player_3d.play()
	enemy.animation_tree.set("parameters/ReloadGlock/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func get_current_damage() -> int:
	var bullet_damage = Ammunition.get_damage(enemy.current_weapon.weapon.ammo_type)
	var gun_damage = enemy.current_weapon.weapon.base_damage
	return bullet_damage + gun_damage
