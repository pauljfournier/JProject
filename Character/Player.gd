extends KinematicBody2D

signal animation_finished

export (int) var default_speed = 400
var speed = default_speed

onready var terrain = get_parent().get_parent()
onready var sprite = $Sprite
onready var hold_object = $Hold_object
onready var camera = $Camera2D
onready var objectifEmote = $OjectifEmote
var velocity = Vector2()
#onready var target_position = get_parent().get_to_position()
var target_position
var moving = false
var moving_path = [] setget _set_moving_path
var lvl_index = 1 setget _set_lvl_index
var previous_path_point = []
var sprite_lvl_index = 1.0 setget _set_sprite_lvl_index
var direct_target_point setget , _get_direct_target_point
var current_point setget , _get_current_point
var immobilized = false
var goal_position: Vector2 setget _set_goal

func _ready():
	play("sleeping")
	var t = Timer.new()
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	play("wake")

func _process(delta):
	if goal_position and objectifEmote.visible:
		goal_point_direction()

func _physics_process(delta):
	if moving:
		play("move_with_fx")
		if(len(moving_path)>4) && moving_path[0][1] == -1:
			speed = default_speed * 2
		else:
			speed = default_speed
		target_position = Vector2(moving_path[0][0].x,moving_path[0][0].y)
		facing(target_position)
		var speed_distance = speed * delta
		velocity = position.direction_to(target_position) * speed_distance
		var gap_distance = position.distance_to(target_position)
		if gap_distance >= speed_distance:
			position += velocity
			if gap_distance <= terrain._half_cell_side_distance:
				if moving_path[0][0].z != lvl_index: 
					self.lvl_index = moving_path[0][0].z
				if moving_path[0][1] != -1 : #start getting on stairs
					#start moving half a z level
					if previous_path_point[0].z < moving_path[0][0].z:
						#moving up
						if(moving_path[0][1] == 3 || moving_path[0][1] == 4): #climbing further from camera
							terrain.tilemaps[moving_path[0][0].z].cell_y_sort = false
						_set_sprite_lvl_index(moving_path[0][0].z - 1 + 0.5*(1-gap_distance/terrain._half_cell_side_distance))
					else:
						#moving down
						if(moving_path[0][1] == 1 || moving_path[0][1] == 2): #climbing closer to camera
							terrain.tilemaps[moving_path[0][0].z].cell_y_sort = true
						_set_sprite_lvl_index(moving_path[0][0].z - 0.5 * (1-gap_distance/terrain._half_cell_side_distance))
				if previous_path_point[1] != -1: #just finish moving through stairs
					if previous_path_point[0].z <= moving_path[0][0].z: 
						#moving up
						if(previous_path_point[1] == 1 || previous_path_point[1] == 2): #climbing closer to camera
							terrain.tilemaps[previous_path_point[0].z].cell_y_sort = false
					else: 
						#moving down
						if(previous_path_point[1] == 3 || previous_path_point[1] == 4): #climbing further from camera
							terrain.tilemaps[previous_path_point[0].z].cell_y_sort = true
			else:
				if previous_path_point[1] != -1: #Was on stairs
					#finish moving half a z level
					if previous_path_point[0].z<=moving_path[0][0].z:
						#moving up
						_set_sprite_lvl_index(moving_path[0][0].z + 0.5 * (1-gap_distance/terrain._half_cell_side_distance))
					else:
						#moving down
						_set_sprite_lvl_index(moving_path[0][0].z - 0.5 * (1-gap_distance/terrain._half_cell_side_distance))
		else:
			#when no more gap, move directly to exact position
			position = target_position
			if moving_path[0][1] == -1 :
				_set_sprite_lvl_index(moving_path[0][0].z)
			else:
				_set_sprite_lvl_index(moving_path[0][0].z-0.5)
			previous_path_point = moving_path.pop_front()
			if !len(moving_path):
				play("idle")
				terrain._player_arrived_at_destination()
				moving = false

func play(animation):
	sprite.play(animation)
	hold_object._on_Sprite_frame_changed()

func facing(facing_position):
	if !immobilized:
		if facing_position.x < position.x :
			sprite.scale.x = -abs(sprite.scale.x)
			hold_object.scale.x = -abs(hold_object.scale.x)
		elif facing_position.x > position.x :
			sprite.scale.x = abs(sprite.scale.x)
			hold_object.scale.x = abs(hold_object.scale.x)

func _set_lvl_index(new_lvl_index):
	lvl_index = new_lvl_index

func _set_sprite_lvl_index(new_sprite_lvl_index):
	sprite_lvl_index = new_sprite_lvl_index
	sprite.offset.y = _get_sprite_offset(new_sprite_lvl_index)
	$Camera2D.offset.y = _get_camera_offset(new_sprite_lvl_index)
	hold_object.player_offset.y = _get_camera_offset(new_sprite_lvl_index)

func _set_moving_path(new_moving_path):
	if !immobilized:
		new_moving_path.pop_front()
		if moving && len(moving_path):
			moving_path = [moving_path[0]] + new_moving_path
		else:
			moving_path = new_moving_path
		if(len(new_moving_path)):
			moving = true

func _get_sprite_offset(new_sprite_lvl_index):
	return  ( - new_sprite_lvl_index * 80) / sprite.scale.y

func _get_camera_offset(new_sprite_lvl_index):
	return - new_sprite_lvl_index * 80

func _get_direct_target_point():
	if len(moving_path):
		return moving_path[0]
	return []

func _get_current_point():
	var player_coodinates = terrain.tilemaps[0].world_to_map(global_position)
	return Vector3(player_coodinates.x, player_coodinates.y, lvl_index)

func _on_Sprite_animation_finished():
	emit_signal("animation_finished")
	
func hold(instance):
	if !is_holding():
		hold_object.add_child(instance)
	
func get_hold_object():
	if is_holding():
		return hold_object.get_children()[0]
	else:
		return null
		
func is_holding():
	return hold_object.get_child_count()>0
	
func let_go_hold_object():
	var obj = get_hold_object()
	hold_object.remove_child(obj)
	return obj
	
func immobilize():
	immobilized = true
	if moving && len(moving_path):
		moving_path = [moving_path[0]]

func release():
	immobilized = false
	
func goal_point_direction():
	var angle = (self.position.angle_to_point(goal_position))
	objectifEmote.rotation = angle

func _set_goal(new_goal_position):
	goal_position = new_goal_position
	if goal_position:
		objectifEmote.show()
		objectifEmote.play("triangle_red_left")
	else:
		objectifEmote.hide()
