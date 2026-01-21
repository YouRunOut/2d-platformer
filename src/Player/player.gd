extends Entity

@onready var hp_label: Label = $Camera2D/HPLabel
@onready var coin_label: Label = $Camera2D/CoinLabel
@onready var kill_label: Label = $Camera2D/KillLabel

@onready var stomp_area: Area2D = $StompArea

const SPEED := 150.0
const JUMP_VELOCITY := -250.0
const FALL_KILL_Y := 120

@export var stomp_damage := 1
@export var stomp_bounce := JUMP_VELOCITY


func _ready() -> void:
	hp_changed.connect(func(v): update_hp_ui(v))
	PlayerParameters.coins_changed.connect(func(v): update_coin_ui(v))
	PlayerParameters.kills_changed.connect(func(v): update_kill_ui(v))
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

func update_coin_ui(value: int) -> void:
	coin_label.text = "Coin: %s" % value

func update_kill_ui(value: int) -> void:
	kill_label.text = "Kill: %s" % value



func _on_stomp_hit(body: Node) -> void:
	if state != State.JUMP:
		return
	
	if body is not Entity:
		return
	
	if body.state in [State.HIT, State.DEAD]:
		return
	
	stomp_area.monitoring = false
	
	body.receive_damage(stomp_damage, 0, 0)
	
	# подпрыгивание после удара
	velocity.y = stomp_bounce
	set_state(State.JUMP)
	
	await get_tree().create_timer(0.2).timeout
	stomp_area.monitoring = true


func check_fall_death() -> void:
	if position.y >= FALL_KILL_Y:
		hp = 0

func _on_animation_finished() -> void:
	if state == State.DEAD:
		await get_tree().create_timer(0.3).timeout
		# временное решение
		PlayerParameters.player_coins = 0
		PlayerParameters.player_kills = 0
		get_tree().reload_current_scene()
	else:
		super()
