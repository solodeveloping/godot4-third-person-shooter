extends Node3D
class_name TPSTeleporter

@export
var target: Node3D

@export_flags_3d_physics
var collision_mask: int

@export
var override_collision_mask: bool = false

#@export
#var auto_teleport: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_3d: Area3D = $Area3D

func _ready() -> void:
	animation_player.play("up_and_down")
	if override_collision_mask:
		area_3d.collision_mask = collision_mask

func _on_area_3d_area_entered(area: Area3D) -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") or body.is_in_group("enemy"):
		teleport_to_target(body)
	
func teleport_to_target(body: Node3D):
	if !target:
		push_warning("teleporter does not have a target")
		return
	
	body.global_position = target.global_position
	if body is CharacterBody3D:
		# Info : we do this otherwise we don't know if we are on the floor
		body.move_and_slide()
