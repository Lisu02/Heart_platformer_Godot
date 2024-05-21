extends CharacterBody2D


@export var movment_data : PlayerMovmentData


var air_jump = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position



func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")	
	else:
		animated_sprite_2d.play("idle")
	if not is_on_floor():
		animated_sprite_2d.play("jump")

func _physics_process(delta):
	apply_gravity(delta)
	handle_jump()
	handle_wall_jump()
	var input_axis = Input.get_axis("ui_left", "ui_right")
	handle_acceleration(input_axis,delta)
	handle_air_acceleration(input_axis,delta)
	apply_friction(input_axis,delta)
	apply_air_resistance(input_axis,delta)
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	if Input.is_action_just_pressed("ui_accept"):
		movment_data = load("res://FasterMovmentData.tres")

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta * movment_data.gravity_scale

func handle_wall_jump():
	if not is_on_wall_only(): return
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("ui_left") and wall_normal == Vector2.LEFT:
		velocity.x = wall_normal.x * movment_data.speed
		velocity.y = movment_data.jump_velocity
	if Input.is_action_just_pressed("ui_right") and wall_normal == Vector2.RIGHT:
		velocity.x = wall_normal.x * movment_data.speed
		velocity.y = movment_data.jump_velocity


func handle_jump():
	if is_on_floor(): air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = movment_data.jump_velocity
	elif not is_on_floor():
		if Input.is_action_just_released("ui_up") and velocity.y < movment_data.jump_velocity / 2:
			velocity.y = movment_data.jump_velocity / 2
		
		if Input.is_action_just_pressed("ui_up") and air_jump:
			velocity.y = movment_data.jump_velocity * 0.8
			air_jump = false

func handle_acceleration(input_axis,delta):
	if input_axis and is_on_floor():
		velocity.x = move_toward(velocity.x,movment_data.speed*input_axis,movment_data.acceleration * delta)

func handle_air_acceleration(input_axis,delta):
	if input_axis and not is_on_floor():
		velocity.x = move_toward(velocity.x,movment_data.speed * input_axis,movment_data.air_acceleration * delta)

func apply_air_resistance(input_axis,delta):
	if input_axis == 0 and not is_on_floor():
		velocity.y = move_toward(velocity.y,0,movment_data.air_resistance * delta)


func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x,0,movment_data.friction * delta)


func _on_hazard_detector_area_entered(area):
	global_position = starting_position
