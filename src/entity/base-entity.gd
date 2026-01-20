extends CharacterBody2D
class_name Entity
signal hp_changed(current_hp)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer


enum State { IDLE, RUN, JUMP, HIT, DEAD }
var state: State = State.IDLE


@export var max_hp := 3
var _hp := 0
var hp:
	get: return _hp
	set(value):
		_hp = clamp(value, 0, max_hp)
		hp_changed.emit(_hp)
		if _hp == 0:
			set_state(State.DEAD)

func _ready() -> void:
	_hp = max_hp
	hp_changed.emit(_hp)
	set_state(State.IDLE)

func set_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state
	if state == State.HIT or state == State.DEAD:
		velocity.x = 0

	update_animation()

func play_sound(sound: AudioStream):
	audio_player.stream = sound
	audio_player.play()

func update_animation() -> void:
	match state:
		State.IDLE:
			animated_sprite.play("idle")
		State.RUN:
			animated_sprite.play("run")
		State.JUMP:
			animated_sprite.play("jump")
			play_sound(preload("uid://dspn23cp1bagb"))
		State.HIT:
			animated_sprite.play("hit")
			play_sound(preload("uid://c1ndb6aymtk5h"))
		State.DEAD:
			animated_sprite.play("death")
			play_sound(preload("uid://dqfkgm1wnf4co"))


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func receive_damage(damage: int, knockback := 0.0, from_dir := 0) -> void:
	if state in [State.HIT, State.DEAD]:
		return
	hp -= damage
	if hp <= 0:
		set_state(State.DEAD)  # Принудительно устанавливаем DEAD, если HP <= 0
	else:
		velocity.x = knockback * from_dir
		set_state(State.HIT)
	#hp_changed.emit(hp)


func _on_animation_finished() -> void:
	if state == State.HIT:
		set_state(State.IDLE)
