extends Node3D
class_name WeaponVFXManager

var event_bus: ThirdPersonControllerEventBus

func _ready() -> void:
	var current_scene = get_tree().current_scene

	if current_scene.has_node("ThirdPersonControllerEventBus"):
		event_bus = current_scene.get_node("ThirdPersonControllerEventBus")
		
		event_bus.send_weapon_vfx_requested.connect(_on_event_bus_send_weapon_vfx_requested)
	else:
		push_warning("ThirdPersonControllerEventBus not found")

func _on_event_bus_send_weapon_vfx_requested(
	global_pos: Vector3,
	scene: PackedScene,
	delay: float,
):
	var instance = scene.instantiate()
	add_child(instance)
	instance.global_position = global_pos
	if instance.has_node("GPUParticles3D"):
		instance.get_node("GPUParticles3D").emitting = true
	else:
		push_warning("GPUParticles3D not found")
