
class_name PlayerV1
extends CharacterBody2D

# ** Public Variables **
@export_category("--- Player Variables ---")

# Whether player has gravity and jump. If false, then gravity is replaced with vertical controls
@export var gravityEnabled : bool = false
@export var gravity : float = 9.8 * 16

@export var upInput : String = "ui_up"
@export var downInput : String = "ui_down"
@export var leftInput : String = "ui_left"
@export var rightInput : String = "ui_right"

@export_node_path("Node") var grapplingHookSpawnpoint : NodePath
@export_node_path("Node") var grapplingHookContainer : NodePath
@export_file("*.tscn") var grapplingHookScene : String

@export var jumps : int = 1

# ** Private Variables **
var inputDirection : Vector2

@export var vel : Vector2 = Vector2.ZERO

var jumpsLeft : int = 0


# ** System Functions **
func _ready():
	
	#motion_mode = MOTION_MODE_GROUNDED if gravityEnabled else MOTION_MODE_FLOATING
	pass

func _physics_process(delta):
	
	if Input.is_action_just_pressed("reset_player_position"):
		velocity = Vector2.ZERO
		position = Vector2.ZERO
	
	if Input.is_action_just_pressed("shoot"):
		shootGrapplingHook(grapplingHookContainer, grapplingHookSpawnpoint, grapplingHookScene)
	
	movePlayer(delta)
	
	move_and_slide()
	
	vel = velocity
	
	pass


# ** My Functions **
func movePlayer(delta):
	
	# Velocity checks
	
	# Register input direction
	inputDirection.x = Input.get_action_strength(rightInput) - Input.get_action_strength(leftInput)
	inputDirection.y = Input.get_action_strength(downInput) - Input.get_action_strength(upInput) if !gravityEnabled else 0
	
	# Normal Movement & Opposite-Velocity Movement (inputDirection = 0 when gravityEnabled = false)
	if inputDirection.x > 0 && velocity.x > 0 or inputDirection.x < 0 && velocity.x < 0:
		inputDirection.x *= 8
	if inputDirection.y > 0 && velocity.y > 0 or inputDirection.y < 0 && velocity.y < 0:
		inputDirection.y *= 8
	
	if inputDirection.x < 0 && velocity.x > 0 or inputDirection.x > 0 && velocity.x < 0:
		inputDirection.x *= 16
	if inputDirection.y < 0 && velocity.y > 0 or inputDirection.y > 0 && velocity.y < 0:
		inputDirection.y *= 16
	
	# If gravityEnabled movement (Only applies if gravityEnabled = true) (Contains Jump)
	if gravityEnabled == true:
		inputDirection.y = -32 / delta * 0.1 if Input.is_action_just_pressed(upInput) else 0
	
	velocity += inputDirection
	velocity.y += gravity if gravityEnabled else 0
	
	pass

func shootGrapplingHook(grapHookCont : NodePath, grapHookSpwn : NodePath, grapHookScn : String):
	
	var grapplingHook = load(grapHookScn).instantiate()
	get_node(grapHookCont).add_child(grapplingHook)
	grapplingHook.global_position = get_node(grapHookSpwn).global_position
	grapplingHook.player = self
	
	pass
