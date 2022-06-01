extends "res://Objects/Object.gd"
#Super Obscure Name aka S.O.N.

var Empty_Mug = preload("res://Objects/hold/Mug.tscn")
onready var animationPlayer = $Canvas/KinematicBody2D/AnimationPlayer
onready var mug = $Canvas/KinematicBody2D/AnimatedSprite/Hold_object/Mug
onready var emote = $Canvas/KinematicBody2D/Emote

func _ready():
	emote.play("koffee")
	emote.show()
	mug.hide()
	animationPlayer.play_backwards("sip")

func _on_arrived_at_destination(player):
	player_ref = player
	player_ref.facing(global_position)
	activate()

func activate():
#	collect the mug
	if player_ref.is_holding():
		if player_ref.get_hold_object().name == "Mug":
			player_ref.immobilize()
			player_ref.play("interract_up")
			mug.animation = player_ref.get_hold_object().animation
			mug.show()
			player_ref.let_go_hold_object()
			yield(player_ref, "animation_finished")
			player_ref.play("idle")
			animationPlayer.play("wait_and_sip")
			yield(animationPlayer, "animation_finished")
			animationPlayer.play_backwards("sip")
			if mug.animation == "koffee":
				emote.success("")
				yield(animationPlayer, "animation_finished")
				emote.play("sparkle")
				animationPlayer.play("wait_and_sip_and_back")
			else:
				emote.invalid("")
				yield(animationPlayer, "animation_finished")
				emote.play("anger")
				yield(get_tree().create_timer(2.5), "timeout")
				emote.play("koffee")
				mug.hide()
				var new_empty_mug = Empty_Mug.instance()
				new_empty_mug.animation = mug.animation
				player_ref.hold(new_empty_mug)
			player_ref.release()
	yield(player_ref, "animation_finished")
	player_ref.play("idle")
	pass
