extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite_2d.set_frame(randi_range(0, 11))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hp += 1
		body.play_sound(preload("uid://b27sn7oqellh5"))
		get_tree().queue_delete(self)
