extends Node

signal player_died
signal level_up(new_level)
signal xp_gained(current_xp, next_level_xp)
signal hp_changed(current_hp, max_hp)
signal enemy_defeated(xp_value)

func hit_stop(duration: float = 0.1, time_scale: float = 0.05):
	Engine.time_scale = time_scale
	# Usamos el timer del árbol ignorando el time_scale para que dure el tiempo real deseado
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
