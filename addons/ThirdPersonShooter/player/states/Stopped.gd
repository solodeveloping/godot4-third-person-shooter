extends PlayerState

func enter():
	player.anim_tree.set("parameters/RootState/transition_request", "idle")

func _physics_process(delta: float) -> void:
	if player.controls.is_aiming() and player.has_gun():
		player.anim_tree.set("parameters/AimingIdleBlend/blend_amount", 1)
	else:
		player.anim_tree.set("parameters/AimingIdleBlend/blend_amount", 0)
