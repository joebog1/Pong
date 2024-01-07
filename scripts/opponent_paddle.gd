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
