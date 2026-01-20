extends Entity

@onready var hp_label: Label = $Camera2D/HPLabel

const SPEED := 150.0
const JUMP_VELOCITY := -250.0
const FALL_KILL_Y := 120

func _ready() -> void:
	hp_changed.connect(func(v): update_hp_ui(v))
	super()
	

func _physics_process(delta: float) -> void:
	apply_gravity(delta)

	if state in [State.IDLE, State.RUN, State.JUMP]:
		handle_input()

	move_and_slide()
	check_fall_death()

func handle_input() -> void:
	var direction := Input.get_axis("ui_left", "ui_right")

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		set_state(State.JUMP)
		return

	if direction != 0:
		velocity.x = direction * SPEED
		update_facing_direction(velocity.x)
		if is_on_floor():
			set_state(State.RUN)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			set_state(State.IDLE)

	if not is_on_floor():
		set_state(State.JUMP)

func update_hp_ui(value: int) -> void:
	hp_label.text = "HP: %s" % value




func check_fall_death() -> void:
	if position.y >= FALL_KILL_Y:
		hp = 0

func _on_animation_finished() -> void:
	if state == State.DEAD:
		await get_tree().create_timer(0.3).timeout
		get_tree().reload_current_scene()
	else:
		super()
