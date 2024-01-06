extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Enables signals to be sent during collision
	set_contact_monitor(true)
	set_max_contacts_reported(1)
