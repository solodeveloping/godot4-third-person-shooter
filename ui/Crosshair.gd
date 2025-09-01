extends Control
class_name Crosshair

@onready var lines: Node2D = $Node2D/lines

var pos_x: float = 15

func fire(speed: float):
	for child:CrosshairLine in lines.get_children():
		child.fire(speed)

func _process(delta):
	for line in lines.get_children():
		line.get_node("base").position.x = lerp(line.get_node("base").position.x, pos_x, delta * 12)
