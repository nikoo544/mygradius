extends "res://Gradius/Enemigos/enemy_base.gd"

@export var bala_escena: PackedScene
@export var cadencia = 2.0
var tiempo_disparo = 0.0

func _process(delta):
	position.x -= velocidad * 0.5 * delta # Se mueve más lento

	tiempo_disparo += delta
	if tiempo_disparo >= cadencia:
		disparar()
		tiempo_disparo = 0.0

func disparar():
	var jugador = get_tree().get_first_node_in_group("jugador")
	if is_instance_valid(jugador) and bala_escena:
		var bala = bala_escena.instantiate()
		bala.global_position = global_position
		var direccion = (jugador.global_position - global_position).normalized()
		bala.rotation = direccion.angle()
		# Configurar bala enemiga
		if "velocidad" in bala: bala.velocidad = 300
		if "bando_objetivo" in bala: bala.bando_objetivo = "jugador"
		get_tree().current_scene.add_child(bala)
