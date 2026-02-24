extends Area2D

@export var velocidad = 400.0
@export var rotacion_velocidad = 5.0
@export var vida_util = 3.0
@export var danio = 50

var objetivo: Node2D = null

func _ready():
	# Conectar señal si no está conectada (importante si se crea por script)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

	# Buscar el enemigo más cercano al aparecer
	buscar_objetivo()
	await get_tree().create_timer(vida_util).timeout
	explotar()

func buscar_objetivo():
	var enemigos = get_tree().get_nodes_in_group("enemigos")
	var distancia_minima = INF
	for enemigo in enemigos:
		var dist = global_position.distance_to(enemigo.global_position)
		if dist < distancia_minima:
			distancia_minima = dist
			objetivo = enemigo

func _process(delta):
	if is_instance_valid(objetivo):
		var direccion_objetivo = (objetivo.global_position - global_position).normalized()
		var angulo_objetivo = direccion_objetivo.angle()
		rotation = lerp_angle(rotation, angulo_objetivo, rotacion_velocidad * delta)

	position += Vector2.RIGHT.rotated(rotation) * velocidad * delta

func _on_area_entered(area):
	var target = area.get_parent() if area.get_parent().is_in_group("enemigos") else area
	if target.is_in_group("enemigos"):
		if target.has_method("recibir_danio"):
			target.recibir_danio(danio)
		elif target.has_method("morir"):
			target.morir()
		explotar()

func explotar():
	# Aquí irían partículas
	queue_free()
