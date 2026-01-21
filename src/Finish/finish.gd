extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#body.play_sound(preload("uid://3v2g8jl5qky3"))
		#await get_tree().create_timer(0.26).timeout
		get_tree().change_scene_to_file("res://src/Scenes/End.tscn")
