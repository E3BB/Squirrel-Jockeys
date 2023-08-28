
class_name GrapplingHook
extends AnimatableBody2D

# ** Variables **
@export var player : PhysicsBody2D
@export var line2d : Line2D
@export var speed : float = 32
@export var gravity : float = 9.8

var collisionData : KinematicCollision2D
var objectAttachedTo : Object

var vel : Vector2 = Vector2.ZERO
var startingVel : Vector2 = Vector2.ZERO
var maxRopeLength : float = 40
signal rotation_matches

var attachDifference : Vector2


func _ready():
	
	await rotation_matches
	
	vel = (Vector2(speed, 0).rotated(rotation) + startingVel)
	
	pass

func _physics_process(delta):
	
	if player:
		if line2d:
			line2d.clear_points()
			line2d.add_point(Vector2.ZERO)
			line2d.add_point(player.global_position - global_position)
		
	
	if objectAttachedTo != null:
		player.swingOnGrapplingHook(delta)
	else:
		swingAroundPlayer(delta)
		vel += Vector2(0, gravity) * delta
		collisionData = move_and_collide(vel)
		player.grapplingHookLength = (position - player.position).length()
	
	collisionChecks(delta)
	
	pass

# ***

# Checks for collisions, attempts to stick to object.
func collisionChecks(delta):
	
	if objectAttachedTo != null:
		
		global_position = objectAttachedTo.global_position + attachDifference
		vel = Vector2.ZERO
		
		pass
	
	pass
	
	# If hook collides with object...
	if collisionData != null && objectAttachedTo == null:
		
		objectAttachedTo = collisionData.get_collider()
		
		attachDifference = global_position - objectAttachedTo.global_position
		
		pass
	

# ***

func swingAroundPlayer(delta):
	
	if abs((position - player.position).length()) > maxRopeLength:
		
		move_and_collide(Vector2(maxRopeLength - (position - player.position).length(), 0).rotated((position - player.position).angle()))
		vel = vel.slide((position - player.position).normalized())
		
		pass
	
	pass
