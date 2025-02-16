extends CharacterBody2D


const SPEED = 250.0
const DECELERATION = 100
const JUMP_VELOCITY = -400.0
const DASH_VELOCITY = 1200.0

@onready var hero_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_timer: Timer = $coyote_timer
@onready var dash_end_timer: Timer = $dash_end_timer
@onready var label: Label = $CanvasLayer/Label
@onready var level_1: Node2D = $".."
@onready var killbox: Area2D = $"../killbox"

var coyote_allowed := true
var dash_reset_allowed := true
var timer_started := false
var dashes := 1
var curr_save_point := "INIT"

func _on_ready() -> void:
	position = get_save_location_vector(curr_save_point)

func _physics_process(delta: float) -> void:
	# DEBUG STATEMENT
	label.text = "dash_reset_allowed: " + str(dash_reset_allowed) + "\nDashes: " + str(dashes)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not timer_started:
			coyote_timer.start()
			timer_started = true

	# Handle jump.
	if Input.is_action_just_pressed("jump") and coyote_allowed:
		velocity.y = JUMP_VELOCITY
	
	var direction = -1 if hero_sprite.flip_h else 1
	if Input.is_action_just_pressed("dash") and dashes > 0:
		velocity.x = direction * DASH_VELOCITY
		dash_end_timer.start()
		dashes -= 1
		hero_sprite.play("dash")
		if velocity.y > 0:
			velocity.y = -110
		dash_reset_allowed = false
			
	# Get the input move_direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var move_direction := Input.get_axis("move_left", "move_right")
	face_direction(move_direction)
	
	if is_on_floor():
		reset_jump()
		if dash_reset_allowed:
			reset_dash()
		if move_direction == 0:
			hero_sprite.play("idle")
		else:
			hero_sprite.play("run")
	else:
		hero_sprite.play("jump")

	velocity.x = move_toward(velocity.x, 0, DECELERATION)
	if move_direction and dash_reset_allowed:
		velocity.x = move_direction * SPEED 
		
	move_and_slide()

func reset_jump():
	coyote_timer.stop()
	timer_started = false
	coyote_allowed = true

func reset_dash():
	dash_end_timer.stop()
	dashes = 1

func face_direction(mov_dir):
	if mov_dir  > 0:
		hero_sprite.flip_h = false
	elif mov_dir < 0:
		hero_sprite.flip_h = true

func _on_coyote_timer_timeout() -> void:
	coyote_allowed = false

func _on_dash_timer_timeout() -> void:
	dash_reset_allowed = true

func get_save_location_vector(location: String) -> Vector2:
	return level_1.save_vectors[level_1.SAVE_POINTS.get(str(location))]

func _on_killbox_player_reset() -> void:
	position = get_save_location_vector(str(curr_save_point))
