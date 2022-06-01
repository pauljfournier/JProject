extends Node2D

onready var player = get_parent()
var playerPixelsSize = 7
var player_offset = Vector2(0,0) setget set_offset
var hand_offset = Vector2(0,0) setget set_hand_offset

func _ready():
	pass

func _on_Sprite_frame_changed():
	match player.sprite.animation:
		"idle":
			match player.sprite.frame:
				0, 3:
					set_hand_offset(0,-1)
				1:
					set_hand_offset(0,0)
				2:
					set_hand_offset(0,1)
				4:
					set_hand_offset(0,-2)
		"move_with_fx", "move_without_fx":
			match player.sprite.frame:
				0:
					set_hand_offset(0,-3)
				1, 3:
					set_hand_offset(0,-1)
				2:
					set_hand_offset(1,-1)
				4:
					set_hand_offset(-2,-3)
				5, 7:
					set_hand_offset(-2,-1)
				6:
					set_hand_offset(-1,-1)
		"interract_up":
			match player.sprite.frame:
				0:
					set_hand_offset(6,-10)
				1:
					set_hand_offset(5,-11)
				2:
					set_hand_offset(5,-10)
				3:
					set_hand_offset(5,-11)
				4:
					set_hand_offset(6,-11)
				5:
					set_hand_offset(6,-11)

func update_position():
	position = Vector2(hand_offset.x*playerPixelsSize, player_offset.y+hand_offset.y*playerPixelsSize )

func set_hand_offset(x=0,y=0):
	hand_offset = Vector2(x*sign(scale.x),y)
	update_position()
	
func set_offset(vect):
	player_offset = Vector2(vect.x,vect.y-playerPixelsSize*6)
	update_position()
