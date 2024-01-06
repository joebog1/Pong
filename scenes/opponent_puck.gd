extends CharacterBody2D

# TODO change based off of setting.
const SPEED = 200.0

# This function is expected to be called via signal from the level.
# The Location argument is the location of the ball. This will 
func apply_movement(Location):
	# TODO Do maths to figure out if we should go up or down. 
	velocity = Vector2(0,Location.y);
	
	move_and_slide()
