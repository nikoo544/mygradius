extends "res://Gradius/Enemigos/enemy_base.gd"

@export var rotacion_random = 2.0
var move_dir = Vector2.LEFT

func setup_enemy():
	vida = 50
	puntos_xp = 10
	danio_al_jugador = 25
	velocidad = randf_range(50, 150)
	rotacion_random = randf_range(-2, 2)
	move_dir = Vector2.LEFT.rotated(randf_range(-PI/4, PI/4))
	scale = Vector2.ONE * randf_range(0.8, 2.5)

func _process(delta):
	if esta_muerto: return
	position += move_dir * velocidad * delta
	rotation += rotacion_random * delta
