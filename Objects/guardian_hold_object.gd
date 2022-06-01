extends Node2D

onready var guardian = get_parent()
onready var pixelsSize = int(round(5*guardian.scale.x))
onready var default_offset = self.position
var character_offset = Vector2(0,0) setget set_character_offset
var hand_offset = Vector2(0,0) setget set_hand_offset

func _ready():
	pass

func _on_Sprite_frame_changed():
	match guardian.animation:
		"idle":
			match guardian.frame:
				0, 1:
					set_hand_offset(0,-1)
				2,4:
					set_hand_offset(0,0)
				3:
					set_hand_offset(0,1)

func update_position():
	position = Vector2(
		default_offset.x+hand_offset.x*pixelsSize, 
		character_offset.y+default_offset.y+hand_offset.y*pixelsSize
	)

func set_hand_offset(x=0,y=0):
	hand_offset = Vector2(x*sign(scale.x),y)
	update_position()
	
func set_character_offset(vect):
	character_offset = Vector2(vect.x,vect.y)
	update_position()
