
class_name MovableBase2D
extends AnimatableBody2D

# Variables
@export var vel := Vector2.ZERO

var prev_frame_pos := Vector2.ZERO

func _physics_process(delta):
	
	vel = (position - prev_frame_pos) / delta
	
	prev_frame_pos = position
	
	pass


func compareRangeF(num : float, i : float, ii : float):
	
	if num < ii && num > i:
		return true
	else: return false
	
	pass
