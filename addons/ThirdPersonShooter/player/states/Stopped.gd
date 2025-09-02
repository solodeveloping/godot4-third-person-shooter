extends PlayerState

func enter():
	player.anim_tree.set("parameters/RootState/transition_request", "idle")
