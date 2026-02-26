extends "res://Gradius/Enemigos/enemy_base.gd"

@export var amplitud = 100.0
@export var frecuencia = 2.0
var tiempo = 0.0

func _process(delta):
	tiempo += delta
	position.x -= velocidad * delta
	position.y += cos(tiempo * frecuencia) * amplitud * delta
