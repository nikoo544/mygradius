extends Node

signal player_died
signal level_up(new_level)
signal xp_gained(current_xp, next_level_xp)
signal hp_changed(current_hp, max_hp)
signal enemy_defeated(xp_value)

var _hit_stop_count = 0

func hit_stop(duration: float = 0.1, time_scale: float = 0.05):
	_hit_stop_count += 1
	Engine.time_scale = time_scale
	# Usamos el timer del árbol ignorando el time_scale para que dure el tiempo real deseado
	await get_tree().create_timer(duration, true, false, true).timeout
	_hit_stop_count -= 1
	if _hit_stop_count <= 0:
		_hit_stop_count = 0
		Engine.time_scale = 1.0
