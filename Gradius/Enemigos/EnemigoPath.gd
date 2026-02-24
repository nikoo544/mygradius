extends PathFollow2D

@export_group("Configuración")
@export var velocidad = 0.2          # Velocidad de recorrido (0 a 1)
@export var vida = 1                 # Cuántos disparos aguanta
@export var puntos_xp = 25           # Cuánta experiencia da al morir
@export var daño_al_jugador = 1     # Cuánta vida le quita a la nave

@export_group("Recursos")
@export var explosion_escena: PackedScene
@export var item_powerup: PackedScene # Opcional: arrastra tu PowerUp.tscn aquí

func _process(delta):
	# Movimiento constante por la curva
	progress_ratio += velocidad * delta
	
	# Si llega al final, desaparece silenciosamente
	if progress_ratio >= 1.0:
		queue_free()

# Esta función la llama la BALA del jugador
func morir():
	# 1. Intentar dar XP al jugador
	var jugadores = get_tree().get_nodes_in_group("jugador")
	if jugadores.size() > 0:
		var jugador = jugadores[0]
		if jugador.has_method("ganar_xp"):
			jugador.ganar_xp(puntos_xp)
	
	# 2. Probabilidad de soltar un item (10% de chance)
	if item_powerup and randf() < 0.1:
		var item = item_powerup.instantiate()
		item.global_position = global_position
		get_tree().current_scene.add_child(item)

	# 3. Efecto visual de explosión
	if explosion_escena:
		var exp = explosion_escena.instantiate()
		exp.global_position = global_position
		# Aseguramos que la explosión se vea por encima
		exp.z_index = 10 
		get_tree().current_scene.add_child(exp)
	Input.start_joy_vibration(0, 0.4, 0.4, 0.2) # Si usan mando
	queue_free()

# --- DETECCIÓN DE COLISIÓN ---
# Conecta la señal "area_entered" de tu Area2D (hijo de este nodo) a esta función
# --- DETECCIÓN DE COLISIÓN ---
func _on_area_2d_area_entered(area: Area2D) -> void:
	var objeto = area.get_parent() 
	
	if objeto.has_method("recibir_danio"):
		print("Impacto legal. Vida antes: ", objeto.vida_actual)
		objeto.recibir_danio(daño_al_jugador)
		
		# EL TRUCO: Desactivamos la colisión inmediatamente para que no le de 2 veces
		$Area2D.set_deferred("monitoring", false) 
		$Area2D.set_deferred("monitorable", false)
			
		morir() # El enemigo desaparece tras el primer golpe
