extends Area2D

@export var velocidad = 800
@export var danio = 10
@export var bando_objetivo = "enemigos"
@export var vida_util = 4.0

func _ready():
	await get_tree().create_timer(vida_util).timeout
	queue_free()

func _process(delta):
	# Esto hace que la bala se mueva hacia donde "mira" (su eje X local)
	position += transform.x * velocidad * delta

func _on_body_entered(body):
	_handle_collision(body)

func _on_area_entered(area: Area2D) -> void:
	_handle_collision(area)

func _handle_collision(target):
	# Verificamos si lo que tocamos es del bando objetivo (buscando en el nodo o su padre)
	var final_target = target
	if not final_target.is_in_group(bando_objetivo) and final_target.get_parent().is_in_group(bando_objetivo):
		final_target = final_target.get_parent()

	if final_target.is_in_group(bando_objetivo):
		if final_target.has_method("recibir_danio"):
			final_target.recibir_danio(danio)
		elif final_target.has_method("morir"):
			final_target.morir()
			
		# La bala se destruye al chocar
		queue_free()
