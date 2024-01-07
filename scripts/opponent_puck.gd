extends CharacterBody2D

# TODO change based off of setting.
const SPEED = 200.0

# :TODO: Write comments explaining behaviour
# This function assumes that direction is normalised. An assert will fail if 
# that's not the case.
func apply_movement(direction):
	
	# If the direction is 0 we don't need to do anything and return early.
	if(direction.length_squared() == 0):
		return
	
	# TODO Do maths to figure out if we should go up or down. 
	assert(direction.length_squared() == 1)
	velocity = direction * SPEED;
	
	move_and_slide()
