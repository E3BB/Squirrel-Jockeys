
class_name GrapplingHook
extends AnimatableBody2D

# ** Variables **
@export var player : PhysicsBody2D
@export var line2d : Line2D
@export var speed : float = 32

var collisionData : KinematicCollision2D
var objectAttachedTo : Object

var vel : Vector2 = Vector2.ZERO

var attachDifference : Vector2


func _physics_process(delta):
	
	if player:
		if line2d:
			line2d.clear_points()
			line2d.add_point(Vector2.ZERO)
			line2d.add_point(player.global_position - global_position)
		
	
	vel = Vector2(speed, 0).rotated($GrapplingHookSprite.rotation) * delta if objectAttachedTo == null else Vector2.ZERO
	
	if objectAttachedTo != null:
		player.swingOnGrapplingHook(delta)
	else:
		collisionData = move_and_collide(vel)
		player.grapplingHookLength = (position - player.position).length()
	
	collisionChecks(delta)
	
	pass

# ***

# Checks for collisions, attempts to stick to object.
func collisionChecks(delta):
	
	# If hook collides with object...
	if collisionData != null && objectAttachedTo == null:
		
		objectAttachedTo = collisionData.get_collider()
		
		attachDifference = global_position - objectAttachedTo.global_position
		
		pass
	
	
	if objectAttachedTo != null:
		
		global_position = objectAttachedTo.global_position + attachDifference
		
		pass
	
	pass
