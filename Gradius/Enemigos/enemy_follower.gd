extends "res://Gradius/Enemigos/enemy_base.gd"

var jugador: Node2D

func setup_enemy():
	jugador = get_tree().get_first_node_in_group("jugador")

func _process(delta):
	if is_instance_valid(jugador):
		var direccion = (jugador.global_position - global_position).normalized()
		position += direccion * velocidad * delta
	else:
		position.x -= velocidad * delta
