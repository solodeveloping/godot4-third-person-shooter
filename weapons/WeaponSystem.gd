extends Node
class_name WeaponSystem

const SQUARE_BULLET_DECAL = preload("res://weapons/SquareBulletDecal.tscn")

const HANDS_WEAPON_RESOURCE = preload("res://weapons/resources/hands_weapon_resource.tres")
@export
var controllable_camera: ControllableCamera

@export
var controls: Controls

@export
var automatic_reload: bool = true

@export
var inventory: InventorySystem

@onready var shoot_timer: Timer = $ShootTimer
@onready var reload_timer: Timer = $ReloadTimer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var reload_audio_stream_player: AudioStreamPlayer = $ReloadAudioStreamPlayer

@onready var player: Player = get_tree().get_nodes_in_group("player")[0]

var event_bus: ThirdPersonControllerEventBus

var current_weapon_drop: WeaponDrop

var current_weapon: WeaponItem

var is_reloading = false

func setup():
	var current_scene = get_tree().current_scene

	if current_scene.has_node("ThirdPersonControllerEventBus"):
		event_bus = current_scene.get_node("ThirdPersonControllerEventBus")
		
		event_bus.send_player_entered_weapon_drop.connect(_on_event_bus_send_player_entered_weapon_drop)
		event_bus.send_player_exited_weapon_drop.connect(_on_event_bus_send_player_exited_weapon_drop)
	else:
		push_warning("ThirdPersonControllerEventBus not found")
	
	switch_to_hand_combat_weapon()
	_on_weapon_changed()

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
	
	if current_weapon.weapon.is_hand_combat == false:
		if !is_reloading:
			if controls.is_shooting():
				if current_weapon.current_mag > 0:
					if shoot_timer.is_stopped():
						shoot()
				else:
					if automatic_reload:
						reload()
			
			player.skin.rotation = controllable_camera.gimbal_h.rotation
		
		if current_weapon != null and current_weapon.weapon != null:
			controllable_camera.crosshair.pos_x = current_weapon.weapon.spread + current_weapon.weapon.movement_spread * player.velocity.length() + current_weapon.weapon.jump_spread * int(player.is_on_floor())
			controllable_camera.crosshair.pos_x += current_weapon.weapon.aim_spread * int(controls.is_aiming()) + current_weapon.weapon.crouch_spread * int(controls.is_crouching())

func has_weapon() -> bool:
	if current_weapon == null or current_weapon.weapon == null:
		return false
	if current_weapon.weapon.is_hand_combat == true:
		return false
	return true

func shoot():
	
	if !current_weapon or !current_weapon.weapon:
		return
	
	for b in range(current_weapon.weapon.projectile_count):
		#var spread_x = randf_range(-1, 1)
		#var spread_y = randf_range(-1, 1)
		
		var spread = controllable_camera.crosshair.pos_x / 12
		var spread_x = randf_range(-spread, spread)
		var spread_y = randf_range(-spread, spread)
		controllable_camera.gun_raycast.target_position = Vector3(spread_x, spread_y, -100)
		
		controllable_camera.gun_raycast.force_raycast_update()
		var collider = controllable_camera.gun_raycast.get_collider()
		var point = controllable_camera.gun_raycast.get_collision_point()
		var normal = controllable_camera.gun_raycast.get_collision_normal()
		
		if collider:
			if collider is Node3D:
				var decal = SQUARE_BULLET_DECAL.instantiate()
				collider.add_child(decal)
				decal.global_transform.origin = point
				decal.look_at(point + normal, Vector3.UP)
	
	audio_stream_player.play()

	shoot_timer.start(1 / current_weapon.weapon.fire_rate)
	
	controllable_camera.crosshair.fire(current_weapon.weapon.fire_rate * 0.2)
	
	player.anim_tree.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	current_weapon.current_mag -= 1
	event_bus.send_current_ammo_changed.emit(current_weapon.current_mag)
	
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
	
	if current_weapon != null:
		if current_weapon.weapon.shoot_sfx != null:
			var stream = audio_stream_player.stream as AudioStreamRandomizer
			stream.set_stream(0, current_weapon.weapon.shoot_sfx)
			reload_audio_stream_player.stream.set_stream(
				0, 
				current_weapon.weapon.reload_sfx
			)
		
		if current_weapon.weapon.scene != null:
			var instance = current_weapon.weapon.scene.instantiate()
			player.weapon_attachment_node.add_child(instance)
	
	if event_bus != null:
		event_bus.send_current_weapon_changed.emit(current_weapon.weapon)
		event_bus.send_current_ammo_changed.emit(current_weapon.current_mag)
		if current_weapon != null:
			event_bus.send_ammo_backup_changed.emit(
				inventory.get_bullet_count(current_weapon.weapon.ammo_type)
			)

func reload():
	if inventory.get_bullet_count(current_weapon.weapon.ammo_type) <= 0:
		return
	
	is_reloading = true
	reload_timer.start(1 / current_weapon.weapon.reload_speed)
	reload_audio_stream_player.play()
	player.anim_tree.set("parameters/ReloadGlock/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _on_reload_timer_timeout() -> void:
	print("_on_reload_timer_timeout")
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

func pickup_loot():
	if current_weapon_drop == null:
		return
	
	inventory.add_weapon_or_increase_ammo(current_weapon_drop.weapon_item)
	
	current_weapon_drop.queue_free()
	current_weapon_drop = null
