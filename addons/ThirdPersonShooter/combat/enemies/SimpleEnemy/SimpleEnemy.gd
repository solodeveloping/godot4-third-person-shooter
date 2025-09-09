extends CharacterBody3D
class_name SimpleEnemy

@export
var def: EnemyDefResource 

@export
var patrol_path_3D: PatrolPath3D

@export
var inventory: InventorySystem

var current_weapon: WeaponItem

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
#@onready var weapon_node: Node3D = $AnimationLibrary_Godot_Standard/Rig/GeneralSkeleton/BoneAttachment3D2/WeaponNode
@onready var model_node: Node3D = $ModelNode


@onready var state_machine: StateMachine = $StateMachine

@onready var attack_timer: Timer = $AttackTimer
@onready var reload_timer: Timer = $ReloadTimer
@onready var gun_attack_rate_limiter_timer: Timer = $GunAttackRateLimiterTimer

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var reload_audio_stream_player_3d: AudioStreamPlayer3D = $ReloadAudioStreamPlayer3D
@onready var gun_ray_cast_3d: RayCast3D = $GunRayCast3D

@onready var detection_collision_shape_3d: CollisionShape3D = $DetectionArea3D/DetectionCollisionShape3D

var time := 0.0
var target: Node3D
var _target_global_pos: Vector3
var pre_aggro_global_pos: Vector3
var has_returned_to_pre_aggro_pos := false

var is_reloading := false

var muzzle_flash: Node3D

var weapon_node: Node3D

var event_bus: ThirdPersonControllerEventBus

func _ready() -> void:
	var current_scene = get_tree().current_scene

	if current_scene.has_node("ThirdPersonControllerEventBus"):
		event_bus = current_scene.get_node("ThirdPersonControllerEventBus")
	else:
		push_warning("ThirdPersonControllerEventBus not found")
	
	if def == null:
		push_error("def is null")
		return
		
	inventory.init_from_def(def.inventory)
	if inventory.content.size() > 0:
		current_weapon = inventory.content[0]
	
	var shape = detection_collision_shape_3d.shape
	if shape is CylinderShape3D:
		shape.radius = def.aggro_range
	
	pre_aggro_global_pos = global_position
	
	setup_current_weapon()
	
	gun_attack_rate_limiter_timer.wait_time = def.gun_attack_rate_limit

func setup_current_weapon():
	if def.model:
		model_node.rotation_degrees = def.rotation_for_model
		var instance = def.model.instantiate()
		model_node.add_child(instance)
		weapon_node = instance.get_node("%WeaponNode")
		animation_tree.anim_player = instance.get_node("AnimationPlayer").get_path()
	
	for child in weapon_node.get_children():
		weapon_node.remove_child(child)
	
	if !current_weapon:
		return
	if !current_weapon.weapon:
		return
		
	var instance = current_weapon.weapon.scene.instantiate()
	weapon_node.add_child(instance)
	
	audio_stream_player_3d.volume_db = current_weapon.weapon.shoot_sfx_volume
	if has_gun():
		audio_stream_player_3d.volume_db += def.extra_volume_db_for_gunshots
	reload_audio_stream_player_3d.volume_db = current_weapon.weapon.reload_sfx_volume
	
	if current_weapon.weapon.shoot_sfx != null:
		var stream = audio_stream_player_3d.stream as AudioStreamRandomizer
		stream.set_stream(0, current_weapon.weapon.shoot_sfx)
		
	if current_weapon.weapon.reload_sfx:
		reload_audio_stream_player_3d.stream.set_stream(
			0,
			current_weapon.weapon.reload_sfx
		)
		
	if current_weapon.weapon.muzzle_flash:
		if instance.has_node("MuzzlePoint"):
			var muzzle_point = instance.get_node("MuzzlePoint")
			muzzle_flash = current_weapon.weapon.muzzle_flash.instantiate()
			muzzle_point.add_child(muzzle_flash)
		else:
			push_warning("weapon has muzzle_flash but no MuzzlePoint")
			
	if current_weapon.weapon.is_melee_weapon:
		if instance.has_node("Area3D"):
			var area_3d = instance.get_node("Area3D")
			if area_3d is Area3D:
				area_3d.area_entered.connect(_on_weapon_area_entered)
				area_3d.body_entered.connect(_on_weapon_body_entered)
			else:
				push_error("Area3D is not an Area3D")
		else:
			push_error("melee weapon does not have an Area3D")

func try_move_to_target(delta: float, target_global_pos: Vector3):
	time += delta
	if time > delta:
		# FIXME : no need to update if its a patrol node / static
		time = 0
		set_nagivation_target_pos(target_global_pos)

	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		return
	
	if navigation_agent_3d.is_navigation_finished():
		return
		
	var next_path_pos = navigation_agent_3d.get_next_path_position()
	var dir = (next_path_pos - global_position).normalized()
	dir.y = 0
 
	var current_facing = -global_transform.basis.z
	var new_dir = current_facing.slerp(dir, def.turn_speed).normalized()
	rotation.y = lerp_angle(
		rotation.y,
		atan2(-velocity.x,-velocity.z),
		def.turn_speed
	)
	
	var speed = def.running_speed
	if str(state_machine._state.name) != "Patrolling":
		if global_position.distance_to(target_global_pos) <= def.walking_dist:
			# FIXME : maybe refacto to order the behaviour from the other states ?
			if str(state_machine._state.name) == "FollowingPlayer":
				if def.enable_walking_when_chasing_player == true:
					speed = def.walking_speed
			else:
				speed = def.walking_speed
	elif def.walk_when_patrolling:
		speed = def.walking_speed
	
	var anim_pos: float = animation_tree.get("parameters/walk_run_blend/blend_position")
	anim_pos = lerpf(anim_pos, speed / def.running_speed, 4 * delta)
	animation_tree.set("parameters/walk_run_blend/blend_position", anim_pos)
 
	velocity = velocity.lerp(dir * speed * delta, def.turn_speed)
	move_and_slide()

func set_nagivation_target_pos(pos: Vector3):
	navigation_agent_3d.target_position = pos
	
func has_line_of_sight_on_player() -> bool:
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(
		gun_ray_cast_3d.global_position,
		target.chest_point.global_position
	)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = def.player_and_env_collision_mask

	var result = space_state.intersect_ray(query)
	
	var collider = result.get("collider", null)
	if collider == null:
		return false
		
	if !collider.is_in_group("player"):
		return false
	
	if collider != target:
		return false
	
	return true

func is_gun_facing_target() -> bool:
	return is_target_in_fow(def.attacking_with_gun_fow)

func is_target_in_fow(fow_in_deg: float) -> bool:
	return is_node_in_fow(fow_in_deg, target)

func is_node_in_fow(fow_in_deg: float, node: Node3D) -> bool:
	var target_pos = Vector3(
		node.global_position.x,
		global_position.y,
		node.global_position.z
	)
	var dir = target_pos.direction_to(global_position)
	var facing_dir = global_transform.basis.tdotz(dir)
	var fow = cos(deg_to_rad(fow_in_deg))
	
	if facing_dir >= fow:
		return true
	return false

func _on_detection_area_3d_body_entered(body: Node3D) -> void:
	if !body.is_in_group("player"):
		push_warning("body not in group player")
		return
	
	if target != null:
		return
	
	if def.use_aggro_fow:
		if !is_node_in_fow(def.aggro_fow_deg, body):
			# FIXME : better implementation than this
			if str(state_machine._state.name) == "Idle" \
				or  str(state_machine._state.name) == "Patrolling" \
				or str(state_machine._state.name) == "ReturningToInitialPos":
				target = body
			elif str(state_machine._state.name) == "ReturningToInitialPos":
				if !def.ignore_player_when_returning_to_initial_pos:
					target = body
			return
	
	if str(state_machine._state.name) == "ReturningToInitialPos":
		if def.ignore_player_when_returning_to_initial_pos:
			# Info : if we ignore player we do nothing
			pass
		else:
			state_machine.transition_to("FollowingPlayer")
	else:
		state_machine.transition_to("FollowingPlayer")
		
	aggro_target(body)

func aggro_target(node: Node3D):
	pre_aggro_global_pos = global_position
	target = node

func _on_reload_timer_timeout() -> void:
	is_reloading = false
	
	var bullets = inventory.try_remove_bullets(
		current_weapon.weapon.ammo_type,
		current_weapon.weapon.mag_size
	)
	current_weapon.current_mag = bullets

func _on_weapon_area_entered(area: Area3D):
	if !area.get_parent().is_in_group("player"):
		return
	# TODO : TakeDamage
	event_bus.send_damage_player.emit(
		area.get_parent(),
		area.global_position,
		current_weapon.weapon.base_damage,
		false
	)
	
func _on_weapon_body_entered(body: Node3D):
	if !body.is_in_group("player"):
		return
	event_bus.send_damage_player.emit(
		body,
		body.global_position,
		current_weapon.weapon.base_damage,
		false
	)

func _on_attack_timer_timeout() -> void:
	if !current_weapon.weapon.is_melee_weapon:
		return
	if current_weapon.weapon.melee_damage_is_physics_based:
		return
	event_bus.send_damage_player.emit(
		target,
		target.global_position,
		current_weapon.weapon.base_damage,
		false
	)
	
func has_gun() -> bool:
	if current_weapon == null:
		return false
	if current_weapon.weapon == null:
		return false
	if current_weapon.weapon.is_hand_combat:
		return false
	if current_weapon.weapon.is_melee_weapon:
		return false
	return true
