extends CanvasLayer

onready var animationPlayer = $AnimationPlayer
onready var newGoal_short = $NewGoal/Short
onready var newGoal_details = $NewGoal/Details
onready var newGoal_sprite = $NewGoal/Sprite
onready var goals = $GoalsLabel
var player

func _ready():
	player = get_parent().player
	
func new_goal(short, details, sprite=null):
	player = get_parent().player
	player.immobilize()
	newGoal_short.text = short
	newGoal_details.text = details
	if sprite:
		newGoal_sprite.texture = sprite
	animationPlayer.play("open_new_goal")

func remove_goal(short):
	goals.remove(newGoal_short.text)
	
func _on_Button_pressed():
	goals.add(newGoal_short.text,newGoal_short.text)
	close_message()
	yield(animationPlayer, "animation_finished")
	player.release()
	
func close_message():
	animationPlayer.play_backwards("open_new_goal")
	
func get_goals():
	return goals.Goals
