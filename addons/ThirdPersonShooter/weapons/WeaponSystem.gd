extends Node
class_name WeaponSystem

const HANDS_WEAPON_RESOURCE = preload("res://addons/ThirdPersonShooter/weapons/resources/hands_weapon_resource.tres")

@export
var controllable_camera: ControllableCamera

@export
var controls: Controls

@export
var automatic_reload: bool = true

@export
var inventory: InventorySystem

@export
var auto_equip_weapon_when_empty_handed := true

@export
var health: int = 100

@export
var max_health: int = 150

@export
var body_armor: int = 0

@export
var max_body_armor: int = 100

@onready var shoot_timer: Timer = $ShootTimer
@onready var reload_timer: Timer = $ReloadTimer

@onready var player: Player = get_tree().get_nodes_in_group("player")[0]

var event_bus: ThirdPersonControllerEventBus

var current_weapon_drop: WeaponDrop
var current_stat_drop: StatDrop

var current_weapon: WeaponItem

var is_reloading = false

var muzzle_flash: Node3D

var shot_count: int = 0

func setup():
	var current_scene = get_tree().current_scene

	if current_scene.has_node("ThirdPersonControllerEventBus"):
		event_bus = current_scene.get_node("ThirdPersonControllerEventBus")
		
		event_bus.send_player_entered_weapon_drop.connect(_on_event_bus_send_player_entered_weapon_drop)
		event_bus.send_player_exited_weapon_drop.connect(_on_event_bus_send_player_exited_weapon_drop)
		
		event_bus.send_player_entered_stat_drop.connect(_on_event_bus_send_player_entered_stat_drop)
		event_bus.send_player_exited_stat_drop.connect(_on_event_bus_send_player_exited_stat_drop)
		
		event_bus.send_damage_player.connect(_on_event_bus_send_damage_player)
	else:
		push_warning("ThirdPersonControllerEventBus not found")
	
	switch_to_hand_combat_weapon()
	_on_weapon_changed()
	
	event_bus.send_current_health_changed.emit(health)
	event_bus.send_current_body_armor_changed.emit(body_armor)

func _process(delta: float) -> void:
	if controls.has_pressed_weapon_1():
		switch_to_hand_combat_weapon()
		_on_weapon_changed()
	elif controls.has_pressed_weapon_2():
		switch_to_weapon(0)
	elif controls.has_pressed_weapon_3():
		switch_to_weapon(1)
	elif controls.has_pressed_weapon_4():
		switch_to_weapon(2)
	elif controls.has_pressed_weapon_5():
		switch_to_weapon(3)
	elif controls.has_pressed_weapon_6():
		switch_to_weapon(4)
	elif controls.has_pressed_reload():
		reload()
	elif controls.has_pressed_pickup_loot():
		pickup_loot()
		try_pickup_stat_drop()
	
	if current_weapon.weapon.is_hand_combat == false:
		if !is_reloading:
			if controls.is_shooting():
				if has_gun():
					if current_weapon.current_mag > 0:
						if shoot_timer.is_stopped():
							shoot()
					else:
						if automatic_reload:
							reload()
				elif current_weapon.weapon.is_melee_weapon:
					if shoot_timer.is_stopped():
						melee_attack()
			
			player.skin.rotation = controllable_camera.gimbal_h.rotation
		
		if current_weapon != null and current_weapon.weapon != null:
			controllable_camera.crosshair.pos_x = current_weapon.weapon.spread + current_weapon.weapon.movement_spread * player.velocity.length() + current_weapon.weapon.jump_spread * int(player.is_on_floor())
			controllable_camera.crosshair.pos_x += current_weapon.weapon.aim_spread * int(controls.is_aiming()) + current_weapon.weapon.crouch_spread * int(controls.is_crouching())

func shoot():
	
	if !current_weapon or !current_weapon.weapon:
		return
	
	for b in range(current_weapon.weapon.projectile_count):
		shot_count += 1
		
		var spread = controllable_camera.crosshair.pos_x / 12
		var spread_x = randf_range(-spread, spread)
		var spread_y = randf_range(-spread, spread)
		controllable_camera.gun_raycast.target_position = Vector3(
			spread_x,
			spread_y,
			-current_weapon.weapon.max_range
		)
		
		controllable_camera.gun_raycast.force_raycast_update()
		var collider = controllable_camera.gun_raycast.get_collider()
		var point = controllable_camera.gun_raycast.get_collision_point()
		var normal = controllable_camera.gun_raycast.get_collision_normal()
		
		if collider:
			if collider is Node3D:
				var _parent: Node3D
				if collider is TakeDamage3D:
					_parent = collider.target_parent.get_parent().get_parent()
				else:
					if collider.get_parent().get_parent() is Node3D:
						_parent = collider.get_parent().get_parent()
				
				if _parent and _parent.is_in_group("enemy"):
					var is_critical = false
					var damage = get_current_damage()
					if collider.is_in_group("head"):
						is_critical = true
						damage *= 2
					
					event_bus.send_damage_enemy.emit(
				 		collider.get_parent().get_parent(),
						point,
						damage,
						is_critical
					)
					if current_weapon.weapon.humanoid_impact_vfx:
						event_bus.send_weapon_vfx_requested.emit(
							point,
							current_weapon.weapon.humanoid_impact_vfx,
							0
						)
					
				else:
					if current_weapon.weapon.bullet_decal:
						var decal = current_weapon.weapon.bullet_decal.instantiate()
						collider.add_child(decal)
						decal.global_transform.origin = point
						decal.look_at(point + normal, Vector3.UP)
					
					if current_weapon.weapon.environment_impact_vfx:
						event_bus.send_weapon_vfx_requested.emit(
							point,
							current_weapon.weapon.environment_impact_vfx,
							0
						)
					
				if muzzle_flash:
					if current_weapon.weapon.bullet_trail:
						event_bus.send_spawn_bullet_trail.emit(
							current_weapon.weapon.bullet_trail,
							muzzle_flash.global_position,
							point,
						)
	
	if current_weapon.weapon.shoot_sfx:
		player.attack_audio_stream_player_3d.play()

	shoot_timer.start(1 / current_weapon.weapon.fire_rate)
	
	controllable_camera.crosshair.fire(current_weapon.weapon.fire_rate * 0.2)
	
	player.anim_tree.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	current_weapon.current_mag -= 1
	event_bus.send_current_ammo_changed.emit(current_weapon.current_mag)
	
	if muzzle_flash != null:
		muzzle_flash.emitting = true

func melee_attack():
	shoot_timer.start(1 / current_weapon.weapon.fire_rate)
	player.anim_tree.set("parameters/SwordAttack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	if current_weapon.weapon.shoot_sfx:
		await get_tree().create_timer(0.3).timeout
		player.attack_audio_stream_player_3d.play()

func switch_to_hand_combat_weapon():
	current_weapon = WeaponItem.new(
		HANDS_WEAPON_RESOURCE,
		0
	)

func switch_to_weapon(weapon_index: int):
	current_weapon = inventory.get_weapon(weapon_index)
	if current_weapon == null:
		switch_to_hand_combat_weapon()
	_on_weapon_changed()

func _on_weapon_changed():
	for child in player.weapon_attachment_node.get_children():
		player.weapon_attachment_node.remove_child(child)
		
	muzzle_flash = null
	
	if current_weapon != null:
		player.attack_audio_stream_player_3d.volume_db = current_weapon.weapon.shoot_sfx_volume
		player.reload_audio_stream_player_3d.volume_db = current_weapon.weapon.reload_sfx_volume
		
		if current_weapon.weapon.shoot_sfx != null:
			player.attack_audio_stream_player_3d.stream.set_stream(
				0,
				current_weapon.weapon.shoot_sfx
			)
			
		if current_weapon.weapon.reload_sfx != null:
			player.reload_audio_stream_player_3d.stream.set_stream(
				0, 
				current_weapon.weapon.reload_sfx
			)
		
		if current_weapon.weapon.scene != null:
			var instance = current_weapon.weapon.scene.instantiate()
			player.weapon_attachment_node.add_child(instance)
			
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
					if player.override_melee_collision_shape_size:
						var collision_shape = instance.get_node("Area3D/CollisionShape3D")
						if collision_shape:
							if collision_shape is Node3D:
								collision_shape.scale *= player.melee_collision_shape_size_multiplier
				else:
					push_error("melee weapon does not have an Area3D")
	
	if event_bus != null:
		event_bus.send_current_weapon_changed.emit(current_weapon.weapon)
		event_bus.send_current_ammo_changed.emit(current_weapon.current_mag)
		if current_weapon != null:
			event_bus.send_ammo_backup_changed.emit(
				inventory.get_bullet_count(current_weapon.weapon.ammo_type)
			)

func reload():
	if !has_gun():
		return
	if inventory.get_bullet_count(current_weapon.weapon.ammo_type) <= 0:
		return
	
	is_reloading = true
	reload_timer.start(1 / current_weapon.weapon.reload_speed)
	if current_weapon.weapon.reload_sfx:
		player.reload_audio_stream_player_3d.play()
	player.anim_tree.set("parameters/ReloadGlock/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _on_reload_timer_timeout() -> void:
	is_reloading = false
	
	var bullets = inventory.try_remove_bullets(
		current_weapon.weapon.ammo_type,
		current_weapon.weapon.mag_size
	)
	current_weapon.current_mag = bullets

	event_bus.send_current_ammo_changed.emit(current_weapon.current_mag)
	event_bus.send_ammo_backup_changed.emit(
		inventory.get_bullet_count(current_weapon.weapon.ammo_type)
	)

func _on_event_bus_send_player_entered_weapon_drop(weapon_drop: WeaponDrop):
	current_weapon_drop = weapon_drop
	if weapon_drop.auto_loot:
		pickup_loot()

func _on_event_bus_send_player_exited_weapon_drop(weapon_drop: WeaponDrop):
	current_weapon_drop = null

func _on_event_bus_send_player_entered_stat_drop(stat_drop: StatDrop):
	current_stat_drop = stat_drop
	if stat_drop.auto_loot:
		try_pickup_stat_drop()

func _on_event_bus_send_player_exited_stat_drop(weapon_drop: StatDrop):
	current_stat_drop = null
	
func _on_event_bus_send_damage_player(
	_player: Node3D, point: Vector3, damage: int, is_critical: bool
):
	if _player == player:
		if body_armor > 0:
			body_armor -= damage
			if body_armor < 0:
				health += body_armor
				body_armor = 0
				event_bus.send_current_health_changed.emit(health)
			event_bus.send_current_body_armor_changed.emit(body_armor)
		else:
			health -= damage
			event_bus.send_current_health_changed.emit(health)
		
		if health <= 0:
			# TODO : implement this
			print("player is dead")
	else:
		push_warning("player damaged but is not self")

func _on_weapon_area_entered(area: Node3D):
	if !is_attacking():
		return
	var _parent: Node3D
	# FIXME : Godot is wrong, area can be TakeDamage3D
	if area is TakeDamage3D:
		_parent = area.target_parent
	else:
		if area.get_parent().get_parent() is Node3D:
			_parent = area.get_parent().get_parent()
	
	if _parent and _parent.is_in_group("enemy"):
		event_bus.send_damage_enemy.emit(
	 		_parent,
			_parent.global_position,
			current_weapon.weapon.base_damage,
			false
		)
		
func _on_weapon_body_entered(body: Node3D):
	if !is_attacking():
		return
	var node: Node3D
	if body.is_in_group("enemy"):
		node = body
	elif body is TakeDamage3D:
		node = body.target_parent
	
	if node:
		event_bus.send_damage_enemy.emit(
	 		body,
			body.global_position,
			current_weapon.weapon.base_damage,
			false
		)
	

func _on_shoot_timer_timeout() -> void:
	if has_melee_weapon():
		player.anim_tree.set("parameters/SwordAttack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

func pickup_loot():
	if current_weapon_drop == null:
		return
	
	var inventory_initial_size = inventory.content.size()
	var index = inventory.add_weapon_or_increase_ammo(current_weapon_drop.weapon_item)
	if auto_equip_weapon_when_empty_handed:
		if inventory_initial_size == 0:
			switch_to_weapon(index)
	
	current_weapon_drop.queue_free()
	current_weapon_drop = null

func try_pickup_stat_drop():
	if current_stat_drop == null:
		return
	
	var remove_drop = false
	if current_stat_drop.stats.stats.health > 0:
		if health < max_health:
			remove_drop = true
			health += current_stat_drop.stats.stats.health
			if health > max_health:
				health = max_health
				
			event_bus.send_current_health_changed.emit(health)
			event_bus.send_heal.emit(
				player,
				player.global_position + Vector3(0, 2, 0),
				current_stat_drop.stats.stats.health,
				false
			)
	if current_stat_drop.stats.stats.body_armor > 0:
		if body_armor < max_body_armor:
			remove_drop = true
			body_armor += current_stat_drop.stats.stats.body_armor
			if body_armor > max_body_armor:
				body_armor = max_body_armor
			
			event_bus.send_current_body_armor_changed.emit(body_armor)
			event_bus.send_body_armor_gain.emit(
				player,
				player.global_position + Vector3(0, 2, 0),
				current_stat_drop.stats.stats.body_armor,
				false
			)
	
	if remove_drop:
		current_stat_drop.queue_free()
		current_stat_drop = null

func get_current_damage() -> int:
	var bullet_damage = Ammunition.get_damage(current_weapon.weapon.ammo_type)
	var gun_damage = current_weapon.weapon.base_damage
	return bullet_damage + gun_damage

func has_weapon() -> bool:
	if current_weapon == null or current_weapon.weapon == null:
		return false
	if current_weapon.weapon.is_hand_combat == true:
		return false
	return true

func has_gun() -> bool:
	if current_weapon == null or current_weapon.weapon == null:
		return false
	if current_weapon.weapon.is_hand_combat == true:
		return false
	if current_weapon.weapon.is_melee_weapon:
		return false
	return true

func is_attacking():
	return !shoot_timer.is_stopped()

func has_melee_weapon():
	if current_weapon == null:
		return false
	if current_weapon.weapon == null:
		return false
	return current_weapon.weapon.is_melee_weapon
