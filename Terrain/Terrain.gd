extends Node2D

signal play
signal reset
signal animation_finished
signal arrived_at_destination

onready var astar_node = AStar.new()
var destination = Vector3() setget _set_destination
onready var tilemaps = [$YSort/TileMap_lvl0,$YSort/TileMap_lvl1,$YSort/TileMap_lvl2,$YSort/TileMap_lvl3,$YSort/TileMap_lvl4]
onready var player = $YSort/JAE
onready var camera = $YSort/JAE/Camera2D
onready var objects = $YSort/Objects
onready var main_node = get_parent()

var interactivesHovered = []
var _point_path = []
var _half_cell_size = Vector2()
var _half_cell_side_distance = 0.0
var _map_rect = Rect2() #note: end not included
var clickedNode

# Called when the node enters the scene tree for the first time.
func _ready():
	_half_cell_size = tilemaps[0].cell_size/2
	_half_cell_side_distance = sqrt(_half_cell_size.x*_half_cell_size.x + _half_cell_size.y*_half_cell_size.y)/2
	
	#calculate the astar
	_map_rect = calculate_map_rect()
	var _walkable_points_array_by_levels = astar_get_walkable_cells()
	astar_connect_walkable_cells(_walkable_points_array_by_levels)
	
	#init the player node
	var player_coodinates = tilemaps[0].world_to_map(player.global_position)
	player.previous_path_point = [Vector3(player_coodinates.x, player_coodinates.y, player.lvl_index), -1]

	#connect the interractive objects
	connect_interractive_objects()

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		emit_signal("reset")
	if Input.is_action_pressed("ui_accept"):
		emit_signal("play")
	if event is InputEventMouseButton:
		if !main_node.on_menu:
			if event.button_index == BUTTON_LEFT && event.pressed:
				var world_coordinate = get_global_mouse_position()
				player.facing(world_coordinate)
				if len(interactivesHovered):
					clickedNode = interactivesHovered[-1]
					if clickedNode.interractive && clickedNode.has_method("clicked"):
						var move_destination = clickedNode.clicked()
						if player.current_point != move_destination:
							var new_moving_path = _move_to_point(move_destination)
							if(len(new_moving_path)):
								player._set_moving_path(new_moving_path)
						elif player.current_point == move_destination && !player.moving:
							_player_arrived_at_destination()
					else:
						print("None interactive node.")
				else:
					var new_moving_path = _clicked_on_world_coordinates(world_coordinate)
					if(len(new_moving_path)):
						clickedNode = null
						player._set_moving_path(new_moving_path)

func _player_arrived_at_destination():
	emit_signal("arrived_at_destination")
	if(clickedNode && player.current_point==clickedNode.interactive_position):
		if clickedNode.has_method("_on_arrived_at_destination"):
			clickedNode._on_arrived_at_destination(player)
		clickedNode = null

func astar_get_walkable_cells():
	var _walkable_points_array_by_levels = []
	var tilemaps_used_cells = []
	var nb_of_lvl = len(tilemaps)
	# get used tiles and init _walkable_points_array_by_levels with empty list
	for tilemap in tilemaps:
		tilemaps_used_cells.append(tilemap.get_used_cells())
		_walkable_points_array_by_levels.append([])
	# filter those that are obstructed by levels on top of them
	for tilemap_lvl in nb_of_lvl:
		for tile in tilemaps_used_cells[tilemap_lvl]:
			var obstructed = false
			#check every superior level for possible obstacle
			if tilemap_lvl < nb_of_lvl-1:
				for lvl_on_top in range(tilemap_lvl+1,nb_of_lvl):
					if tilemaps_used_cells[lvl_on_top].has(tile) || does_object_exist_at(Vector3(tile.x, tile.y, lvl_on_top)):
						obstructed = true
						break
			# if not obstructed, add to the possible path as point
			if !obstructed:
				var point = Vector3(tile.x, tile.y, tilemap_lvl)
				_walkable_points_array_by_levels[tilemap_lvl].append(Vector2(point.x,point.y))
				var point_index = calculate_point_index(point)
				astar_node.add_point(point_index, point)
	return _walkable_points_array_by_levels
	
func astar_connect_walkable_cells(walkable_points_array_by_levels):
	for lvl in len(walkable_points_array_by_levels):
		for point in walkable_points_array_by_levels[lvl]:
			var point_V3 = Vector3(point.x, point.y, lvl)
			var point_index = calculate_point_index(point_V3)
			var relative_points_non_diagonal = PoolVector3Array()
			var relative_points_diagonal = PoolVector3Array()
			var stairs_type = tile_stairs_type(point_V3)
			if stairs_type == 1:
				relative_points_non_diagonal = PoolVector3Array([
					Vector3(point.x    , point.y + 1, lvl),
					Vector3(point.x    , point.y - 1, lvl-1)
				])
				#TODO check lvl-1 exist?
			elif stairs_type == 2:
				relative_points_non_diagonal = PoolVector3Array([
					Vector3(point.x + 1, point.y    , lvl),
					Vector3(point.x - 1, point.y    , lvl-1)
				])
			elif stairs_type == 3:
				relative_points_non_diagonal = PoolVector3Array([
					Vector3(point.x    , point.y - 1, lvl),
					Vector3(point.x    , point.y + 1, lvl-1)
				])
			elif stairs_type == 4:
				relative_points_non_diagonal = PoolVector3Array([
					Vector3(point.x - 1, point.y    , lvl),
					Vector3(point.x + 1, point.y    , lvl-1)
				])
			else:
				relative_points_non_diagonal = PoolVector3Array([
					Vector3(point.x + 1, point.y    , lvl),
					Vector3(point.x    , point.y - 1, lvl),
					Vector3(point.x - 1, point.y    , lvl),
					Vector3(point.x    , point.y + 1, lvl)
				])
				relative_points_diagonal = PoolVector3Array([
					Vector3(point.x + 1, point.y + 1, lvl),
					Vector3(point.x + 1, point.y - 1, lvl),
					Vector3(point.x - 1, point.y - 1, lvl),
					Vector3(point.x - 1, point.y + 1, lvl)
				])
			for relative_point in relative_points_non_diagonal:
				var relative_point_index = calculate_point_index(relative_point)
				if is_inside_map_bounds(relative_point):
					if astar_node.has_point(relative_point_index):
						if !(tile_stairs_type(point_V3)==-1 && tile_stairs_type(relative_point)!=-1):
							astar_node.connect_points(point_index, relative_point_index, true)
			for relative_point_list_index in len(relative_points_diagonal):
				var relative_point = relative_points_diagonal[relative_point_list_index]
				var relative_point_index = calculate_point_index(relative_point)
				var relative_point_neighbour_one = relative_points_non_diagonal[relative_point_list_index]
				var relative_point_index_neighbour_one = calculate_point_index(relative_point_neighbour_one)
				var relative_point_neighbour_two = relative_points_non_diagonal[(relative_point_list_index-1)%4]
				var relative_point_index_neighbour_two = calculate_point_index(relative_point_neighbour_two)
				if is_inside_map_bounds(relative_point):
					if astar_node.has_point(relative_point_index) && astar_node.has_point(relative_point_index_neighbour_one) && astar_node.has_point(relative_point_index_neighbour_two) && tile_stairs_type(relative_point)==-1 && tile_stairs_type(relative_point_neighbour_one)==-1 && tile_stairs_type(relative_point_neighbour_two)==-1:
						astar_node.connect_points(point_index, relative_point_index, true)

func does_object_exist_at(point, objectsNode = objects.get_children()):
	for object in objectsNode:
		if object.get("solid_obstacle") != null:
			if object.solid_obstacle:
				if object.obstacle_position == point:
					return true
		elif does_object_exist_at(point, object.get_children()):
				return true
	return false
	
func connect_interractive_objects(objectsNode = objects.get_children()):
	for object in objectsNode:
		if object.get("interractive") != null:
			if object.interractive:
				object.connect("mouse_entered", self, "interactive_mouse_entered")
				object.connect("mouse_exited", self, "interactive_mouse_exited")
				object.connect("zoom_in", self, "zoom_in")
				object.connect("open_screen", self, "open_screen")
				object.connect("zoom_and_open_screen", self, "zoom_and_open_screen")
				object.connect("reset_zoom", self, "reset_zoom")
		else:
			 connect_interractive_objects(object.get_children())

func _cell_position(world_coordinates):
	var cell_coordinates = $YSort/TileMap_lvl0.world_to_map(world_coordinates)
	var cell_pos = $YSort/TileMap_lvl0.map_to_world(cell_coordinates)
	return cell_pos

func _cell_centered_position(coordinates):
	var cell_centered_pos = _cell_position(coordinates)+Vector2.DOWN*38
	return cell_centered_pos

func _clicked_on_world_coordinates(world_coordinates):
	var clicked_cell_coordinates = tilemaps[0].world_to_map(world_coordinates)
	# get the coordinate corrected with z axis
	var _points_path_with_correction = correct_coordinates_v2(clicked_cell_coordinates)
	
	return _point_path_for_player(_points_path_with_correction)

func _move_to_point(point):
	var _points_path = _calculate_path_to_point(point)
	return _point_path_for_player(_points_path)

func _set_destination(new_destination):
	# destination is a coordonate
	destination = new_destination
	_point_path  = _calculate_path()
	_draw_path_line()

func calculate_map_rect():
	var rect0 = tilemaps[0].get_used_rect()
	var x_min = rect0.position.x
	var y_min = rect0.position.y
	var x_max = rect0.end.x
	var y_max = rect0.end.y
	for tilemap in tilemaps.slice(1,len(tilemaps)-1):
		var rect = tilemap.get_used_rect()
		if rect.position.x < x_min:
			x_min = rect.position.x
		if rect.position.y < y_min:
			y_min = rect.position.y
		if rect.end.x > x_max:
			x_max = rect.end.x
		if rect.end.y > y_max:
			y_max = rect.end.y
	return Rect2(x_min, y_min, x_max-x_min, y_max-y_min)

func calculate_point_index(point):
	#worked assuming there are max 10 z levels
	if(_map_rect.has_point(Vector2(point.x, point.y))):
		return (point.x - _map_rect.position.x + _map_rect.size.x * (point.y - _map_rect.position.y) ) * 10 + point.z
	else:
		return -1
		
func tile_stairs_type(point):
	var cell_id = tilemaps[point.z].get_cell(point.x, point.y)
	if cell_id != -1:
		var name = tilemaps[point.z].tile_set.tile_get_name(cell_id)
		if "Stairs 1." in name:
			return 1
		elif "Stairs 2." in name:
			return 2
		elif "Stairs 3." in name:
			return 3
		elif "Stairs 4." in name:
			return 4
	return -1

func is_inside_map_bounds(point):
	return _map_rect.has_point(Vector2(point.x,point.y)) && point.z < len(tilemaps) && point.z >= 0

func correct_coordinates(coodinates):
	for lvl in range(len(tilemaps)-1,0,-1):
		var leveled_coordinates = coodinates+Vector2(1,1)*lvl
		var leveled_point = Vector3(leveled_coordinates.x, leveled_coordinates.y, lvl)
		var leveled_point_index = calculate_point_index(leveled_point)
		if astar_node.has_point(leveled_point_index):
			return leveled_point
	return Vector3(coodinates.x, coodinates.y, 0)

func correct_coordinates_v2(coodinates):
	for lvl in range(len(tilemaps)-1,-1,-1):
		var leveled_coordinates = coodinates+Vector2(1,1)*lvl
		var leveled_point = Vector3(leveled_coordinates.x, leveled_coordinates.y, lvl)
		var new_point_path = _calculate_path_to_point(leveled_point)
		if len(new_point_path)>0:
			return new_point_path
		#test if it's stairs cell on this level
		var stairs_leveled_point = Vector3(leveled_coordinates.x-1, leveled_coordinates.y-1, lvl)
		if tile_stairs_type(stairs_leveled_point) != -1:
			new_point_path = _calculate_path_to_point(stairs_leveled_point)
			if len(new_point_path)>0:
				return new_point_path
	return []

func _calculate_path_to_point(point):
	var point_index = calculate_point_index(point)
	if astar_node.has_point(point_index):
		return _calculate_path(point)
	return []

func _calculate_path(new_destination = destination):
	var player_start_position = Vector2()
	var player_start_lvl = 0
	if player.direct_target_point == []:
		player_start_position = player.global_position
		player_start_lvl = player.lvl_index
	else:
		player_start_position = Vector2(player.direct_target_point[0].x, player.direct_target_point[0].y)
		player_start_lvl = player.direct_target_point[0].z
	var player_coodinates = tilemaps[0].world_to_map(player_start_position)
	var start_point_index = calculate_point_index(Vector3(player_coodinates.x, player_coodinates.y, player_start_lvl))
	var end_point_index = calculate_point_index(new_destination)
	# This method gives us an array of points. Note you need the start and end
	# points' indices as input
	return astar_node.get_point_path(start_point_index, end_point_index)

func _draw_path_line(point_path = _point_path):
	$PathfindingLine2D.clear_points()
	for point in point_path:
		var world_point = $YSort/TileMap_lvl0.map_to_world(Vector2(point.x,point.y))+Vector2.UP*(point.z*80-38)
		$PathfindingLine2D.add_point(world_point)

func _point_path_world(point_path = _point_path):
	var point_path_world = []
	for point in point_path:
		point_path_world.append(_point_map_to_world(point))
	return point_path_world

func _point_map_to_world(point):
	var world_point = tilemaps[0].map_to_world(Vector2(point.x,point.y))+Vector2.DOWN*38
	return Vector3(world_point.x,world_point.y,point.z)

func _point_path_for_player(point_path = _point_path):
	if(len(point_path)):
		_draw_path_line(point_path)
	var point_path_world = []
	for point in point_path:
		var stairs_type = tile_stairs_type(point)
		var world_point = _point_map_to_world(point)
		point_path_world.append([world_point,stairs_type])
	return point_path_world

func interactive_mouse_entered(node):
	interactivesHovered.append(node)

func interactive_mouse_exited(node):
	interactivesHovered.erase(node)

func zoom_in(new_zoom,point):
	var player_position = tilemaps[0].world_to_map(player.global_position)
	var vector_to_move = point - Vector3(player_position.x, player_position.y, player.lvl_index+1)
	var to_position = vector_to_move.x*Vector2(80,40)+vector_to_move.y*Vector2(-80,40)+vector_to_move.z*Vector2(0,-80)
	camera._zoom_forced(new_zoom, to_position)
	yield(camera,"animation_finished")
	emit_signal("animation_finished")
	
func open_screen(screenScene):
	main_node.open_screen(screenScene)

func zoom_and_open_screen(new_zoom, zoom_point, screenScene):
	zoom_in(new_zoom, zoom_point)
	yield(self,"animation_finished")
	open_screen(screenScene)

func reset_zoom():
	camera._zoom_back_to_normal()
	yield(camera,"animation_finished")
	emit_signal("animation_finished")
