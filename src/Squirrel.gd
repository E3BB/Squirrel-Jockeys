
class_name Squirrel
extends MovableBase2D

# Variables
@export var queued_animation : String
@export var current_animation : String
@export var time : float


func _ready():
	
	time = 0.0
	
	pass

func _process(delta):
	
	time += delta
	
	animate_sprite(delta)
	
	pass

# ***

func _physics_process(delta):
	
	
	
	pass


func animate_sprite(delta):
	
	if compareRangeF(fmod(time, 2), 1.7, 2) or fmod(time, 2) + delta > 2:
		
		if get_node_or_null("SquirrelAnimationPlayer") != null:
			if queued_animation != $SquirrelAnimationPlayer.current_animation:
				$SquirrelAnimationPlayer.current_animation = queued_animation
				if $SquirrelAnimationPlayer: $SquirrelAnimationPlayer.play(current_animation)
		pass
	
	pass
