
class_name PlayerV2
extends MovableBase2D

# ** Public Variables **
# Whether player has gravity and jump. If false, then gravity is replaced with vertical controls
@export var gravity_enabled : bool = false
@export var gravity : float = 4

@export var upInput : String = "ui_up"
@export var downInput : String = "ui_down"
@export var leftInput : String = "ui_left"
@export var rightInput : String = "ui_right"

@export_node_path("Node") var grapplingHookSpawnpoint : NodePath
@export_node_path("Node") var grapplingHookContainer : NodePath
@export_file("*.tscn") var grapplingHookScene : String
@export var grapplingHookLength : float = 30

@export var jumps : int = 1

@export_range(0, 90) var floor_max_angle : float = 45

# ** Private Variables **
var inputDirection : Vector2

var jumpsLeft : int = 0

@export var is_on_floor : bool

@export var is_on_wall : bool

@export var is_on_ceiling : bool

var collisionData : KinematicCollision2D

var currentGrapplingHook : AnimatableBody2D

var o = 0


# ** System Functions **
func _ready():
	
	pass

# ***

func _physics_process(delta):
	
	pointAndShootGrapplingHook(grapplingHookContainer, grapplingHookSpawnpoint, grapplingHookScene)
	
	movePlayer(delta)
	
	collisionData = move_and_collide(vel)
	
	collisionChecks(delta)
	
	pass

# ***
# ---
# ***

# ** My Functions **
func movePlayer(delta):
	
	# Reset player position
	if Input.is_action_just_pressed("reset_player_position"):
		vel = Vector2.ZERO
		position = Vector2.ZERO
		if currentGrapplingHook != null:
			currentGrapplingHook.queue_free()
	
	# Register input direction
	inputDirection.x = Input.get_action_strength(rightInput) - Input.get_action_strength(leftInput)
	inputDirection.y = Input.get_action_strength(downInput) - Input.get_action_strength(upInput) if !gravity_enabled else 0
	
	# Normal Movement & Opposite-Velocity Movement (inputDirection = 0 when gravity_enabled = false)
	if inputDirection.x > 0 && vel.x > 0 or inputDirection.x < 0 && vel.x < 0:
		inputDirection.x *= 8
	if inputDirection.y > 0 && vel.y > 0 or inputDirection.y < 0 && vel.y < 0:
		inputDirection.y *= 8
	
	if inputDirection.x < 0 && vel.x > 0 or inputDirection.x > 0 && vel.x < 0:
		inputDirection.x *= 16
	if inputDirection.y < 0 && vel.y > 0 or inputDirection.y > 0 && vel.y < 0:
		inputDirection.y *= 16
	
	# Jump if gravity_enabled
	if gravity_enabled == true && is_on_floor:
		inputDirection.y = -32 / delta * 0.1 if Input.is_action_just_pressed(upInput) else 0
	
	vel += inputDirection * delta
	vel.y += gravity * delta if gravity_enabled else 0
	
	pass

# ***

func pointAndShootGrapplingHook(grapHookCont : NodePath, grapHookSpwn : NodePath, grapHookScn : String):
	
	# Rotates gun at mouse
	$GrapplingHookGun.look_at(get_global_mouse_position())
	
	# If player shoots...
	if Input.is_action_just_pressed("shoot"):
		
		# If the current grappling hook is an object, destroy it
		if currentGrapplingHook != null:
			
			currentGrapplingHook.queue_free()
			
		
		# If there isn't a current grappling hook, make a new one at the gun's tip
		elif currentGrapplingHook == null:
			
			currentGrapplingHook = load(grapplingHookScene).instantiate()
			
			get_node(grapplingHookContainer).add_child(currentGrapplingHook)
			
			currentGrapplingHook.global_position = get_node("GrapplingHookGun/GrapplingHookSpawnpoint").global_position
			#currentGrapplingHook.global_position = get_global_mouse_position()
			
			currentGrapplingHook.get_node("GrapplingHookSprite").rotation = $GrapplingHookGun.rotation
			
			currentGrapplingHook.player = self
			
		pass
	
	pass

# ***

func collisionChecks(delta, test_mode : bool = false):
	
	if test_mode == false:
		if collisionData != null:
			
			#print("Got collider!")
			
			if collisionData.get_collider().get("vel") != null:
				vel = vel.slide(collisionData.get_normal()) + collisionData.get_collider().vel * delta
				pass
			elif collisionData.get_collider().get("velocity") != null:
				vel = vel.slide(collisionData.get_normal()) + collisionData.get_collider().velocity * delta
				pass
			elif collisionData.get_collider().get("constant_linear_velocity") != null:
				vel = vel.slide(collisionData.get_normal()) + collisionData.get_collider().constant_linear_velocity * delta
				pass
			
			var collisionNormalAngle : float = rad_to_deg(collisionData.get_normal().angle())
			
			if collisionNormalAngle > -90 - floor_max_angle && collisionNormalAngle < -90 + floor_max_angle:
				is_on_floor = true
			else: is_on_floor = false
			
			if collisionNormalAngle > 0 - (90 - floor_max_angle) && collisionNormalAngle < 0 + (90 - floor_max_angle):
				is_on_wall = true
			elif collisionNormalAngle > 180 - (90 - floor_max_angle) && collisionNormalAngle < 180 + (90 - floor_max_angle):
				is_on_wall = true
			else: is_on_wall = false
			
			if collisionNormalAngle > 90 - floor_max_angle && collisionNormalAngle < 90 + floor_max_angle:
				is_on_ceiling = true
			else: is_on_ceiling = false
			
			print("Rotation of normal of collision is: " + str(rad_to_deg(collisionData.get_normal().angle())))
			
			pass
		
		else:
			is_on_floor = false
			is_on_wall = false
			is_on_ceiling = false
			pass
		
		pass
	
	elif test_mode == true:
		if collisionData != null:
			
			var velo : Vector2
			
			if collisionData.get_collider().get("vel") != null:
				velo = vel.slide(collisionData.get_normal()) + collisionData.get_collider().vel * delta
				pass
			elif collisionData.get_collider().get("constant_linear_velocity") != null:
				velo = vel.slide(collisionData.get_normal()) + collisionData.get_collider().velocity * delta
				pass
			elif collisionData.get_collider().get("velocity") != null:
				velo = vel.slide(collisionData.get_normal()) + collisionData.get_collider().vel * delta
				pass
			
			return velo
			
			pass
		
		pass
	
	pass

# ***

func swingOnGrapplingHook():
	if currentGrapplingHook != null:
		if abs((position - currentGrapplingHook.position).length()) > grapplingHookLength:
			#position += Vector2(grapplingHookLength - (position - currentGrapplingHook.position).length(), 0).rotated((position - currentGrapplingHook.position).angle())
			var excessRope = grapplingHookLength - (position - currentGrapplingHook.position).length()
			move_and_collide(Vector2(excessRope, 0).rotated((position - currentGrapplingHook.position).angle()))
			vel = vel.slide((position - currentGrapplingHook.position).normalized())
			o += 1
			print("Swinging, this is the " + str(o) + " time")
	
	pass
