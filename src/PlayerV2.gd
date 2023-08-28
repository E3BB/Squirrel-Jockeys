
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

@export var jumpStrength : int = 32

@export_range(0, 90) var floor_max_angle : float = 45

@export var playerJumpCoyoteTime : float = 0.2
@export var playerJumpCoyoteTimer : float = 0.2

@export var reelSpeed : float = 4
@export var maxRopeLength : float = 300

# ** Private Variables **
var inputDirection : Vector2
var collisionData : KinematicCollision2D
var playerHasJumped : bool = true

var is_on_floor : bool
var is_on_wall : bool
var is_on_ceiling : bool

var currentGrapplingHook : AnimatableBody2D

var is_climb_hook_pressed : bool = false


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
	if gravity_enabled == true && is_on_floor && playerHasJumped == false && Input.is_action_just_pressed(upInput):
		inputDirection.y = -jumpStrength / delta * 0.1
		playerHasJumped = true
	
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
			currentGrapplingHook.rotation = $GrapplingHookGun.rotation
			currentGrapplingHook.get_node("Rope").rotation = -$GrapplingHookGun.rotation
			currentGrapplingHook.player = self
			currentGrapplingHook.startingVel = vel
			currentGrapplingHook.maxRopeLength = maxRopeLength
			currentGrapplingHook.gravity = gravity
			if currentGrapplingHook.rotation == $GrapplingHookGun.rotation:
				currentGrapplingHook.rotation_matches.emit()
			
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
			
			
			# Updates for is_on_floor, wall & ceiling bools
			var collisionNormalAngle : float = rad_to_deg(collisionData.get_normal().angle())
			
			if collisionNormalAngle > -90 - floor_max_angle && collisionNormalAngle < -90 + floor_max_angle:
				is_on_floor = true
				playerJumpCoyoteTimer = playerJumpCoyoteTime
				playerHasJumped = false
			else: playerJumpCoyoteTimer -= delta
			
			if collisionNormalAngle > 0 - (90 - floor_max_angle) && collisionNormalAngle < 0 + (90 - floor_max_angle):
				is_on_wall = true
			elif collisionNormalAngle > 180 - (90 - floor_max_angle) && collisionNormalAngle < 180 + (90 - floor_max_angle):
				is_on_wall = true
			else: is_on_wall = false
			
			if collisionNormalAngle > 90 - floor_max_angle && collisionNormalAngle < 90 + floor_max_angle:
				is_on_ceiling = true
			else: is_on_ceiling = false
			
			#print("Rotation of normal of collision is: " + str(rad_to_deg(collisionData.get_normal().angle())))
			
			pass
		
		else:
			playerJumpCoyoteTimer -= delta
			is_on_wall = false
			is_on_ceiling = false
			pass
		
		pass
	
	if playerJumpCoyoteTimer < 0:
		is_on_floor = false
	
	if test_mode == true:
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

func swingOnGrapplingHook(delta):
	
	# Excess rope = Length of grappling hook - Distance btwn player and grappling hook
	var excessRope = grapplingHookLength - (position - currentGrapplingHook.position).length()
	
	# If there is a hook...
	if currentGrapplingHook != null:
		
		# If rope is stretched too far...
		if abs((position - currentGrapplingHook.position).length()) > grapplingHookLength:
			
			# Move player by excess rope pointed towards grappling hook...
			move_and_collide(Vector2(excessRope, 0).rotated((position - currentGrapplingHook.position).angle()))
			# then slide the velocity perpendicular to the player-grappling-hook line
			vel = vel.slide((position - currentGrapplingHook.position).normalized())
			
			pass
		
		pass
	
	# Set climb button state b/c mouse wheel is weird
	if Input.is_action_just_pressed("climb_rope"): is_climb_hook_pressed = true
	if Input.is_action_just_released("climb_rope"): is_climb_hook_pressed = false
	
	# Let go of rope if pressed, unless at end of rope
	if Input.is_action_pressed("loose_rope"): grapplingHookLength = maxRopeLength
	if Input.is_action_just_released("loose_rope"): grapplingHookLength = (position - currentGrapplingHook.position).length()
	
	# Make sure length is between 0 and max rope length
	grapplingHookLength = clamp(grapplingHookLength, 0, maxRopeLength)
	
	# Climb the hook if button is pressed
	if is_climb_hook_pressed: grapplingHookLength = (position - currentGrapplingHook.position).length() - reelSpeed * delta
	
	pass
