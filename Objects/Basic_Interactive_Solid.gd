extends "res://Objects/Object.gd"
onready var emote = $Canvas/KinematicBody2D/Emote

func _on_arrived_at_destination(player):
	player_ref = player
	player.facing(global_position)
	player.play("interract_up")
	if(emote.visible):
		emote.hide()
	activate()

func activate():
	number_of_activations += 1
	emit_signal("activated")
	emit_signal("zoom_and_open_screen", player_ref.camera.zoom_min , obstacle_position, "koffeeMaker")


func _on_MugPile_activated():
	if(!number_of_activations):
		emote.play("word_action_color")
		emote.show()
