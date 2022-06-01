extends Camera2D

signal animation_finished

var zoom_min = Vector2(.8,.8)
var zoom_max = Vector2(2.2,2.2)
var zoom_step = Vector2(.1,.1)
var init_position = position
var zoom_speed = .1
var des_zoom = zoom
var position_speed = .4
var des_position = position
var saved_zoom = null
var forced = false
var moving = false

func _process(_delta):
	if moving:
		position = lerp(position, des_position, position_speed)
		zoom = lerp(zoom, des_zoom, zoom_speed)
		if position.distance_to(des_position) < position_speed/10 && zoom.distance_to(des_zoom) < zoom_speed/10:
			position = des_position
			zoom = des_zoom
			moving = false
			emit_signal("animation_finished")

func _input(event):
	if !forced:
		if event is InputEventMouseButton:
			if event.is_pressed():
				if event.button_index == BUTTON_WHEEL_UP:
					des_zoom -= zoom_step
					if des_zoom < zoom_min:
						des_zoom = zoom_min
				elif event.button_index == BUTTON_WHEEL_DOWN:
					des_zoom += zoom_step
					if des_zoom > zoom_max:
						des_zoom = zoom_max
				if des_zoom != zoom:
					moving = true

func _zoom_forced(new_zoom, to_position):
	forced = true
	moving = true
	if not saved_zoom:
		saved_zoom = zoom
	if new_zoom:
		des_zoom = new_zoom
	if to_position:
		des_position = to_position

func _zoom_back_to_normal():
	moving = true
	if saved_zoom:
		des_zoom = saved_zoom
	saved_zoom = null
	des_position = init_position
	forced = false
