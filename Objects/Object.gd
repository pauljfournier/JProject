extends Node2D

signal input_event(viewport, event, shape_idx)
signal mouse_entered(node)
signal mouse_exited(node)
signal zoom_in(new_zoom, zoom_position)
signal open_screen(screneScene)
signal zoom_and_open_screen(new_zoom, zoom_position, screneScene)
signal reset_zoom()
signal activated()
signal clicked()
signal arrived_at_destination()

export var interactive_position := Vector3(0,0,0)
export var obstacle_position := Vector3(0,0,0)
export var interractive := false
export var solid_obstacle := false
var player_ref
var number_of_activations = 0

func _on_KinematicBody2D_input_event(viewport, event, shape_idx):
	emit_signal("input_event", viewport, event, shape_idx)

func _on_KinematicBody2D_mouse_entered():
	if interractive:
		modulate = "#c8c8c8"
	emit_signal("mouse_entered",self)

func _on_KinematicBody2D_mouse_exited():	
	modulate = "#ffffff"
	emit_signal("mouse_exited",self)
	
func clicked():
	#move in front of the object
	emit_signal("clicked")
	print("34")
	return interactive_position

func _on_arrived_at_destination(player):
	emit_signal("arrived_at_destination")
	player_ref = player
	player_ref.facing(global_position)
#	player_ref.play("interract_up")
	activate()

func activate():
	emit_signal("activated",self)
