extends CharacterBody2D

var velocidad = 300
var direccion = Vector2(1, 1) # Empieza moviéndose en diagonal

func _physics_process(delta):
	# Calculamos el movimiento este frame
	var colision = move_and_collide(direccion * velocidad * delta)
	
	# SI CHOCA CON ALGO:
	if colision:
		# La función 'bounce' calcula el rebote físico perfecto
		direccion = direccion.bounce(colision.get_normal())
		# Opcional: aumentar velocidad cada vez que choca
		velocidad += 10
