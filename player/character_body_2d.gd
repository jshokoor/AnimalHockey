extends CharacterBody2D

@export var speed := 200.0
@export var jump_force := -400.0
@export var gravity := 1200.0

func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")

	# Horizontal movement
	velocity.x = direction * speed

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()
