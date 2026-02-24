extends CPUParticles2D

func _ready():
	emitting = true
	# Esperamos a que terminen las partículas y borramos el nodo
	await get_tree().create_timer(lifetime).timeout
	queue_free()
