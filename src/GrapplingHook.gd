
class_name GrapplingHook
extends AnimatableBody2D

# ** Variables **
@export var player : PhysicsBody2D
@export var line2d : Line2D
@export var speed : float = 32

var collisionData : KinematicCollision2D
var attatched_to_object : bool = false

var vel : Vector2 = Vector2.ZERO


func _physics_process(delta):
	
	if player:
		
		line2d.clear_points()
		line2d.add_point(Vector2.ZERO)
		line2d.add_point(player.global_position - global_position)
		
	
	attatched_to_object = false if collisionData == null else true
	
	vel = Vector2(speed, 0) * get_transform().x * delta if attatched_to_object == false else Vector2.ZERO
	
	collisionData = move_and_collide(vel)
	
	pass
