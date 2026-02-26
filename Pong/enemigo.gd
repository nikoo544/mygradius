extends Area2D

@export var velocidad_avance = 200
@export var item_powerup: PackedScene # Arrastra tu PowerUp.tscn aquí en el Inspector
@export var explosion_escena: PackedScene # Arrastra Explosion.tscn aquí
var esta_muerto = false

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _process(delta):
	# El enemigo avanza lentamente hacia la IZQUIERDA (donde está el jugador)
	position.x -= velocidad_avance * delta
	
	# Movimiento lateral + un seno matemático para que floten arriba y abajo

	position.y += sin(Time.get_ticks_msec() * 0.005) * 2

func _on_body_entered(body):
	if body.name == "Pelota":
		# Si la pelota lo toca, el enemigo muere
		morir()
		# Opcional: podrías decirle a la pelota que rebote aquí también
func _on_area_entered(area):
	# Si el enemigo choca con la nave (suponiendo que la nave tiene un Area2D)
	# o directamente con el cuerpo de la nave
	var target = area
	if not target.is_in_group("jugador") and target.get_parent().is_in_group("jugador"):
		target = target.get_parent()

	if target.is_in_group("jugador") and target.has_method("recibir_danio"):
		target.recibir_danio(20) # Quita 20 de vida
		morir() # El enemigo explota al chocar

func recibir_danio(_cantidad):
	# En el Pong original morían de un golpe, pero para consistencia:
	morir()

func morir():
	if esta_muerto: return
	esta_muerto = true

	# Aquí podrías añadir una explosión o sonido después
	var exp = explosion_escena.instantiate()
	exp.global_position = global_position
	get_tree().current_scene.add_child(exp)
	# Probabilidad de soltar item (ej: 20%)
	if randf() < 0.2: 
		var nuevo_item = item_powerup.instantiate()
		nuevo_item.global_position = global_position
		get_tree().current_scene.add_child(nuevo_item)
		
	# 1. Emitir señal de enemigo derrotado (El Player la escucha)
	Events.enemy_defeated.emit(25)

	# Sacudir cámara
	var jugadores = get_tree().get_nodes_in_group("jugador")
	if jugadores.size() > 0:
		var jugador = jugadores[0]
		if jugador.has_method("sacudir_camara"):
			jugador.sacudir_camara(4.0)

	
	queue_free()
	
	queue_free()
