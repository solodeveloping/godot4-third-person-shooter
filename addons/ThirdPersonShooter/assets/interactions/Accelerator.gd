extends Node3D

@export
var force_duration_ms: int = 5000

@export
var force_direction: Vector3 = Vector3.FORWARD

@export
var force_intensity: float = 10

@export
var stop_applying_force_on_floor := false

@export
var stop_apply_force_on_floor_delay_ms := 5000

@export
var cancel_gravity := false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") or body.is_in_group("enemy"):
		if body is CharacterBody3D:
			var force = force_direction * force_intensity
			if body.has_method("add_extra_force"):
				body.add_extra_force(
					force,
					force_duration_ms,
					stop_applying_force_on_floor,
					stop_apply_force_on_floor_delay_ms,
					cancel_gravity
				)
