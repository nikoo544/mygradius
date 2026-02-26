extends "res://Gradius/Enemigos/enemy_base.gd"

@export var distancia_ataque = 500.0
@export var multiplicador_dash = 3.5
var atacando = false
var direccion_ataque = Vector2.LEFT

func _process(delta):
	if esta_muerto: return

	var jugador = get_tree().get_first_node_in_group("jugador")
	if not atacando:
		position.x -= velocidad * delta
		if is_instance_valid(jugador):
			if global_position.distance_to(jugador.global_position) < distancia_ataque:
				iniciar_ataque(jugador)
	else:
		position += direccion_ataque * velocidad * multiplicador_dash * delta
		# Rotar hacia la dirección del ataque
		rotation = lerp_angle(rotation, direccion_ataque.angle(), 10 * delta)

func iniciar_ataque(objetivo):
	atacando = true
	direccion_ataque = (objetivo.global_position - global_position).normalized()
	# Efecto visual de carga (Retro Feel)
	var tween = create_tween().set_loops(3)
	tween.tween_property(self, "modulate", Color.ORANGE_RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

	var scale_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.3)
