extends CharacterBody2D

const BASE_SPEED = 300.0
# Enum represents the direction the Runner is facing.

func _physics_process(_delta):
	
	velocity = Input.get_vector("ui_left","ui_right", "up", "down") * BASE_SPEED
	
	# Panels do not move to the left or right.
	velocity.x = 0;
	
	#print(velocity)
	# :NOTE:
	# delta is automatically incorporated in move_and_slide.
	# see https://github.com/godotengine/godot-proposals/issues/1192
	# Rather inconsistent with move_and_collide which requires delta 
	# (and an input argument that isn't needed as move_and_slide automatically
	# grabs velocity).
	move_and_slide()
