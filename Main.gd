extends Node2D

onready var screen = $screen
onready var terrain = $terrain
onready var player = $terrain/YSort/JAE
onready var son = $terrain/YSort/Objects/SON
onready var hud = $HUD
var screen_opened = false
var on_menu = false

func _ready():
	screen.hide()
	hud.new_goal("Move around", "Hello. You have been summon for a task.\nFirst, move around, by clicking somewhere where you can go to move to that position.")
	player.goal_position = son.position

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		if screen_opened:
			close_screen()

func get_to_position():
	return $Position2D.position

func open_screen(screenScene):
	on_menu = true
	screen_opened = true
	screen.position = terrain.player.global_position  + terrain.camera.position - (terrain.player.lvl_index * 80 * Vector2.DOWN)
#	print(screen.position)
	screen.open()

func close_screen():
	on_menu = false
	screen_opened = false
	screen.close()
	player.play("idle")	

func _on_screen_close():
	player.camera._zoom_back_to_normal()

func _on_terrain_arrived_at_destination():
	if(hud.get_goals().has("Move around")):
		hud.remove_goal("Move around")
		hud.new_goal("Find the Supervisor S.O.N.", "Great moves\nNow find the supervisor S.O.N. to learn the reason of your call.")

func _on_SON_arrived_at_destination():
	$terrain/YSort/Objects/MugPile.playEmote()
	if(hud.get_goals().has("Find the Supervisor S.O.N.")):
		hud.remove_goal("Find the Supervisor S.O.N.")
		hud.new_goal("Make S.O.N. a koffee", "S.O.N. wants a koffee. Make one and bring it back.")

func _on_SON_got_the_correct_drink():
	if(hud.get_goals().has("Make S.O.N. a koffee")):
		hud.remove_goal("Make S.O.N. a koffee")
		hud.new_goal("Explore", "Congratulation! More will be added soon!")
