extends Area2D

@export var velocidad = 700

func _process(delta):
	# Esto hace que la bala se mueva hacia donde "mira" (su eje X local)
	position += transform.x * velocidad * delta

func _on_body_entered(body):
	if body.is_in_group("enemigos"):
		body.take_damage() # Si los enemigos tienen vida
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	# Verificamos si lo que tocamos es un enemigo
	if area.is_in_group("enemigos") or area.get_parent().is_in_group("enemigos"):
		# Si el enemigo tiene la función morir, la llamamos
		if area.has_method("morir"):
			area.morir()
		elif area.get_parent().has_method("morir"):
			area.get_parent().morir()
			
		# La bala se destruye al chocar
		queue_free()
