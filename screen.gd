extends Node2D

signal open
signal close

onready var animationPlayer = $AnimationPlayer
onready var terminalOutput = $Canvas/Terminal/Output
onready var main = get_parent()
onready var mug = $Canvas/Mug

var Mug = preload("res://Objects/hold/Mug.tscn")

var beverage  = ""

var states_lines = {"bev_type": "Type your beverage (Tea/Koffee/StarTearsOfJoy)"}
var current_state = "bev_type"

func play(anim):
	animationPlayer.play(anim)

func play_backwards(anim):
	animationPlayer.play_backwards(anim)

func open():
	#add play init aspect
	play("open")
#	print(get_parent().player)
	if main.player.is_holding():
		if main.player.get_hold_object().name == "Mug":
			mug.play(main.player.get_hold_object().animation)
			mug.visible = true
			main.player.let_go_hold_object()
			

func close():
	if mug.visible:
		mug.hide()
		var hold_mug = Mug.instance()
		hold_mug.play(mug.animation)
		main.player.hold(hold_mug)
	play_backwards("open")
	yield(animationPlayer,"animation_finished")
	play_backwards("open_terminal")
	yield(animationPlayer,"animation_finished")
	emit_signal("close")
	
func _on_Connect_plug_pressed():
	$Canvas/Spot.hide()
	play("open_terminal")
	beverage = ""
#	print_current_state_line()
	terminalOutput.grab_focus()

func printError(error_text):
	terminalOutput.bbcode_text += "[color=#e42222]"+error_text+"[/color]"

func _on_Output_exit():
	###TODO only close terminal not everything (pb is the escape is done at Main level for the moment, screen should handle it and send a close signal)
	close()

func _on_Output_beverage(beverage_type):
	if mug.visible && mug.animation == "empty":
			var lower_beverage_type = beverage_type.to_lower()
			if lower_beverage_type in ["tea", "koffee", "startearsofjoy"]:
				$Canvas/Tear.play(lower_beverage_type)
				play("tearDrop")
				yield(animationPlayer,"animation_finished")
				$Canvas/Mug.play(lower_beverage_type)
