extends CharacterBody2D

# :TODO: There are some duplication with the PlayerPaddle and OpponentPaddle 
# nodes.

const BASE_SPEED = 200.0
# Enum represents the direction the Runner is facing.

var inital_x_position: float

func _ready():
	inital_x_position = get_global_position().x

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
	
	# Paddles do not move to the left or right.
	velocity.x = 0;
	
	# :HACK: The paddle keeps getting pushed back on collision. This attempts to
	# Fix that issue by enforcing the x coordinate stays the same each 
	# iteration.
	set_global_position(Vector2(inital_x_position, get_global_position().y))
	
	# :NOTE:
	# delta is automatically incorporated in move_and_slide.
	# see https://github.com/godotengine/godot-proposals/issues/1192
	# Rather inconsistent with move_and_collide which requires delta 
	# (and an input argument that isn't needed as move_and_slide automatically
	# grabs velocity).
	move_and_slide()
