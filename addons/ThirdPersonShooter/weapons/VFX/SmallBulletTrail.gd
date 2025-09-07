extends Node3D

const MAX_LIFETIME_MS = 5000

@export var target_global_pos := Vector3(0, 0,0)
@export var speed := 75.0
@export var trail_length := 1

@onready var spawn_time = Time.get_ticks_msec()

func _process(delta: float) -> void:
	var diff = target_global_pos - global_position
	var add = diff.normalized() * speed * delta
	add.limit_length(diff.length())
	global_position += add
	if (target_global_pos - global_position).length() <= trail_length or \
		Time.get_ticks_msec() - spawn_time > MAX_LIFETIME_MS:
			queue_free()
	
