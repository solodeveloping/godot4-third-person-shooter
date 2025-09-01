extends Node2D
class_name CrosshairLine

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func fire(speed: float):
	animation_player.speed_scale = speed
	animation_player.stop()
	animation_player.play('fire')
