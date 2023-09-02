
class_name SquirrelBird
extends Squirrel

# Variables
@export var player : PhysicsBody2D
@export var pathLine : Line2D
var playerPos : Vector2
var collisionData
var newVel

func _ready():
	
	
	
	pass


func _process(delta):
	
	
	
	pass


func _physics_process(delta):
	
	playerPos = player.global_position
	
	$NavigationAgent2D.target_position = playerPos
	
	pathLine.points = $NavigationAgent2D.get_current_navigation_path()
	
	newVel = ($NavigationAgent2D.get_next_path_position() - global_position).normalized() * delta * 24
	if collisionData != null:
		newVel.slide(collisionData.get_normal()).normalized() * delta * 24
	
	collisionData = move_and_collide(newVel)
	
	pass


func animate_sprite(delta):
	
	if compareRangeF(fmod(time, 2), 1.7, 2) or fmod(time, 2) + delta > 2:
		if get_node_or_null("SquirrelBirdAnimationPlayer") != null:
			if queued_animation != $SquirrelBirdAnimationPlayer.current_animation:
				$SquirrelBirdAnimationPlayer.current_animation = queued_animation
				if $SquirrelBirdAnimationPlayer: $SquirrelBirdAnimationPlayer.play(current_animation)
		pass
	
	pass
