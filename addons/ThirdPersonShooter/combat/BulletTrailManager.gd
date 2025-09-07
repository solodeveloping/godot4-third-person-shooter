extends Node3D
class_name BulletTrailManager

var event_bus: ThirdPersonControllerEventBus

func _ready() -> void:
	var current_scene = get_tree().current_scene

	if current_scene.has_node("ThirdPersonControllerEventBus"):
		event_bus = current_scene.get_node("ThirdPersonControllerEventBus")
		
		event_bus.send_spawn_bullet_trail.connect(_on_event_bus_send_spawn_bullet_trail)
	else:
		push_warning("ThirdPersonControllerEventBus not found")

func _on_event_bus_send_spawn_bullet_trail(
	scene: PackedScene,
	spawn_global_pos: Vector3,
	target_global_pos: Vector3
):
	var bullet_dir = spawn_global_pos.direction_to(target_global_pos)
	var starting_pos = spawn_global_pos + bullet_dir * 5
	if starting_pos.distance_to(target_global_pos) > 5:
		var instance = scene.instantiate()
		instance.target_global_pos = target_global_pos
		
		add_child(instance)
		
		instance.global_position = starting_pos
		instance.look_at(target_global_pos)
