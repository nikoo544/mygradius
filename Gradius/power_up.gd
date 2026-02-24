# En el script del Power-Up (Area2D)
extends Area2D

func _ready() -> void:
	# Forzamos la conexión de la señal por código por seguridad
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("mejorar"):
		body.mejorar()
		queue_free() # Destruye el power-up
