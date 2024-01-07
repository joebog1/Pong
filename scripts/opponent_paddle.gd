extends CharacterBody2D

# TODO change based off of setting.
const SPEED = 200.0

# This function applies the movement to the paddle based off of the direction 
# provided with magnitude SPEED.
#
# This function assumes that direction is normalised. An assert will fail if 
# that's not the case.
func apply_movement(direction):

	assert(direction.length_squared() == 1)
	velocity = direction * SPEED;
	
	move_and_slide()

var inital_x_position: float

func _ready():
	inital_x_position = get_global_position().x

func _process(_delta):
	# :HACK: The paddle keeps getting pushed back on collision. This attempts to
	# Fix that issue by enforcing the x coordinate stays the same each 
	# iteration.
	set_global_position(Vector2(inital_x_position, get_global_position().y))
