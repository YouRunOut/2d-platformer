extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		PlayerParameters.player_coins += 1
		body.play_sound(preload("uid://foadwcw1lao0"))
		get_tree().queue_delete(self)
