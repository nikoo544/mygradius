extends Area2D

@export var velocidad = 700

func _process(delta):
	# Esto hace que la bala se mueva hacia donde "mira" (su eje X local)
	position += transform.x * velocidad * delta

func _on_body_entered(body):
	if body.is_in_group("enemigos"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(10)
		elif body.has_method("morir"):
			body.morir()
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	# Verificamos si lo que tocamos es un enemigo
	var target = area
	if not target.is_in_group("enemigos") and target.get_parent().is_in_group("enemigos"):
		target = target.get_parent()

	if target.is_in_group("enemigos"):
		if target.has_method("recibir_danio"):
			target.recibir_danio(10)
		elif target.has_method("morir"):
			target.morir()
			
		# La bala se destruye al chocar
		queue_free()
