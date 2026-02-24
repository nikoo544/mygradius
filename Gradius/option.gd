extends Node2D

@export var nave: CharacterBody2D
@export var id_seguimiento = 1 # El primer Option usa el frame 10, el segundo el 20, etc.

func _process(_delta):
	if nave and nave.historial_posiciones.size() > (id_seguimiento * nave.distancia_seguimiento):
		# El Option se mueve a una posición pasada de la nave
		var indice = id_seguimiento * nave.distancia_seguimiento
		global_position = nave.historial_posiciones[indice]
		
	# Disparar cuando el jugador dispare
	if Input.is_action_just_pressed("ui_accept"):
		disparar()

func disparar():
	# Aquí instancias la misma bala que usa la nave
	pass
