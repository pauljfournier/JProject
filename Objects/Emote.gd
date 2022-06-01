extends AnimatedSprite

onready var animationPlayer = $AnimationPlayer

func success(animation):
	if animation:
		play(animation)
	animationPlayer.play("success")

func invalid(animation):
	if animation:
		play(animation)
	animationPlayer.play("invalid")
