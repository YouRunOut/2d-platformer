extends Entity
class_name Enemy

@export var speed := 80.0
@export var patrol_dir := -1
@export var detection_radius := 200.0
@export var attack_cooldown := 1.0
@export var damage := 1
@export var knockback := 120.0

@onready var ground_check_left: RayCast2D = $GroundCheckLeft
@onready var ground_check_right: RayCast2D = $GroundCheckRight

@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea

var target: Node2D = null
var can_attack := true
var target_in_attack_range := false

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	if state in [State.HIT, State.DEAD]:
		return
	
	apply_gravity(delta)
	
	if target:
		if target_in_attack_range:
			try_attack()
		else:
			chase_target()
	else:
		patrol()
	
	move_and_slide()

# --------------------
# AI BEHAVIOR
# --------------------

func patrol() -> void:
	var dir := patrol_dir
	
	if not has_ground_ahead(dir):
		patrol_dir *= -1
		return
	
	velocity.x = patrol_dir * speed
	update_facing_direction(patrol_dir)
	set_state(State.RUN)


func has_ground_ahead(dir: int) -> bool:
	return (dir < 0 and ground_check_left.is_colliding())or (dir > 0 and ground_check_right.is_colliding())


func chase_target() -> void:
	var dir := signi(target.global_position.x - global_position.x)
	
	velocity.x = dir * speed
	update_facing_direction(dir)
	set_state(State.RUN)

func attack(target_body: Node2D) -> void:
	if not can_attack or target_body == null:
		return
	
	can_attack = false
	
	var dir := signi(target_body.global_position.x - global_position.x)
	target_body.receive_damage(damage, knockback, dir)
	
	# тут позже можно State.ATTACK
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


# --------------------
# DETECTION / ATTACK
# --------------------

func try_attack() -> void:
	velocity.x = 0
	
	if can_attack:
		attack(target)


func _on_body_detected(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body

func _on_body_lost(body: Node2D) -> void:
	if body == target:
		target = null

func _on_attack_zone_entered(body: Node2D) -> void:
	if body == target:
		target_in_attack_range = true

func _on_attack_zone_exited(body: Node2D) -> void:
	if body == target:
		target_in_attack_range = false

func _on_animation_finished() -> void:
	if state == State.DEAD:
		PlayerParameters.player_kills += 1
		get_tree().queue_delete(self)
	else:
		super()
