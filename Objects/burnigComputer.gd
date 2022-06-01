extends "res://Objects/Object.gd"

func _on_BlueFire_frame_changed():
	if $Canvas/BlueFire.frame == 5:
		$Canvas/KinematicBody2D/Computer.frame = 2

func _on_play():
	$Canvas/BlueFire.play("electrocute")

func reset_anim():
	$Canvas/BlueFire.stop()
	$Canvas/BlueFire.frame = 0
	$Canvas/KinematicBody2D/Computer.frame = 0

func _on_arrived_at_destination(player):
	player.facing(global_position)
	player.play("interract_up")
	activate()

func activate():
	pass
