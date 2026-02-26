extends "res://Gradius/Enemigos/enemy_base.gd"

@export var amplitud = 200.0
@export var frecuencia = 3.0
var tiempo = 0.0
var start_y = 0.0

func setup_enemy():
	start_y = global_position.y

func _process(delta):
	if esta_muerto: return

	tiempo += delta
	position.x -= velocidad * 1.2 * delta
	position.y = start_y + sin(tiempo * frecuencia) * amplitud

	# Rotate along the wave
	rotation = cos(tiempo * frecuencia) * 0.5
