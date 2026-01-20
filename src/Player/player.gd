extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer
@onready var hp_label: Label = $Camera2D/HPLabel


const SPEED = 150.0 
const JUMP_VELOCITY = -250.0


var hp: int:
	set(value):
		hp = max(value, 0)
		hp_label.text = "HP: %s" % hp
		if hp == 0: kill()
var dead: bool = false
var hit: bool = false

func _ready() -> void:
	hp = 3

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
			velocity += get_gravity() * delta
			if position.y >= 1000:
				received_damage(position.y)
	
	if not dead and not hit:
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			set_animation("jump")

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			if velocity.y == 0: set_animation("run")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if velocity.y == 0: set_animation("idle")
		
		
		move_and_slide()


func set_animation(type: String) -> void:
	if animated_sprite.animation != type:
		animated_sprite.play(type)


func received_damage(damage: int) -> void:
	if dead: return
	hit = true
	set_animation("hit")
	hp -= damage

func kill() -> void:
	dead = true
	hp_label.text = "GAME OVER"
	set_animation("death")




func _on_animation_finished() -> void:
	match animated_sprite.animation:
		"hit": hit = false
		"death":
			await get_tree().create_timer(2).timeout
			get_tree().change_scene_to_file("res://src/Scenes/level_1.tscn")
