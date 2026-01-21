extends Node

var _player_kills := 0
var player_kills: int = 0:
	get: return _player_kills
	set(value):
		_player_kills = clamp(value, 0, 999)
		kills_changed.emit(_player_kills)

var _player_coins := 0
var player_coins: int = 0:
	get: return _player_coins
	set(value):
		_player_coins = clamp(value, 0, 999)
		coins_changed.emit(_player_coins)

signal coins_changed(current_coins : int)
signal kills_changed(current_kills : int)

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
