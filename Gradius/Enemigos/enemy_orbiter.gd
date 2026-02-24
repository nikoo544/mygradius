extends "res://Gradius/Enemigos/enemy_base.gd"

@export var radio = 100.0
@export var velocidad_giro = 4.0
var centro_y = 0.0
var tiempo = 0.0

func setup_enemy():
	centro_y = global_position.y

func _process(delta):
	if esta_muerto: return

	tiempo += delta
	# Movimiento constante hacia la izquierda
	position.x -= velocidad * delta
	# Oscilación circular
	position.y = centro_y + sin(tiempo * velocidad_giro) * radio

	# Retro Feel: Orientación dinámica
	var vel_y = cos(tiempo * velocidad_giro) * velocidad_giro * radio
	var angulo = atan2(vel_y, -velocidad)
	rotation = lerp_angle(rotation, angulo, 5 * delta)
