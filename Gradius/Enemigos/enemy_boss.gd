extends "res://Gradius/Enemigos/enemy_base.gd"

@export var rotacion_velocidad = 1.0
var phase = 1
var timer_phase = 0.0

func setup_enemy():
	vida = 1000
	puntos_xp = 500
	scale = Vector2(4, 4)
	modulate = Color.MEDIUM_PURPLE

func _process(delta):
	if esta_muerto: return

	timer_phase += delta
	# Movimiento lento de entrada
	if position.x > 800:
		position.x -= velocidad * 0.5 * delta

	# Rotación psicodélica
	rotation += rotacion_velocidad * delta

	# Disparos tipo Polybius (Patrones circulares)
	if timer_phase > 2.0:
		disparar_patron()
		timer_phase = 0.0

func disparar_patron():
	var num_balas = 16
	for i in range(num_balas):
		var angulo = (PI * 2 / num_balas) * i + rotation
		var b = load("res://Gradius/Bullet.tscn").instantiate()
		b.global_position = global_position
		b.rotation = angulo
		b.modulate = Color.from_hsv(randf(), 1.0, 1.0) # Colores psicodélicos
		if "bando_objetivo" in b: b.bando_objetivo = "jugador"
		if "velocidad" in b: b.velocidad = 200
		get_tree().current_scene.add_child(b)

	# Efecto visual Polybius (Shake)
	var jug = get_tree().get_first_node_in_group("jugador")
	if jug: jug.sacudir_camara(10.0)
