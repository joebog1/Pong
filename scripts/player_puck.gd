extends CharacterBody2D

# :NOTE: I've called these pucks. That's probably not the right word for it. In 
# air hockey (or just hockey in general) the puck is what I have called the 
# ball. Consider a rename in the future.

const BASE_SPEED = 300.0
# Enum represents the direction the Runner is facing.

func _physics_process(_delta):
	
	# :TODO: Find a way of doing this that doesn't rely on getting input for x 
	# direction movement. Makes the code look ugly having to clip all x based 
	# change.
	# :BUG: Since we consider ui_left and ui_right as movement if the user does 
	# press these inputs. The y portion of the velocity vector will be affected. 
	# Causing it to have less of a y velocity. Ideally we don't get the vector 
	# this way but a hack fix would be to set the y value to BASE_SPEED or 
	# -BASE_SPEED depending on the current value.
	velocity = Input.get_vector("ui_left","ui_right", "up", "down") * BASE_SPEED
	
	# Pucks do not move to the left or right.
	velocity.x = 0;
	
	# :NOTE:
	# delta is automatically incorporated in move_and_slide.
	# see https://github.com/godotengine/godot-proposals/issues/1192
	# Rather inconsistent with move_and_collide which requires delta 
	# (and an input argument that isn't needed as move_and_slide automatically
	# grabs velocity).
	move_and_slide()
