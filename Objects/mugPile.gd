extends "res://Objects/Object.gd"

var Empty_Mug = preload("res://Objects/hold/Mug.tscn")
onready var emote = $Canvas/KinematicBody2D/Emote

func _on_arrived_at_destination(player):
	player_ref = player
	player_ref.facing(global_position)
	player_ref.play("interract_up")
	activate()

func activate():
#	collect the mug
	emit_signal("activated")
	number_of_activations += 1
	player_ref.immobilize()
	yield(player_ref, "animation_finished")
	player_ref.play("idle")
	if(emote.visible):
		emote.hide()
	if player_ref.is_holding():
		if player_ref.get_hold_object().name == "Mug":
			player_ref.let_go_hold_object()
	else:
		var new_empty_mug = Empty_Mug.instance()
		player_ref.hold(new_empty_mug)
	player_ref.release()

func playEmote():
	emote.play("word_color_get")
	emote.show()
