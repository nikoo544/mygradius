extends PathFollow2D

@export_group("Configuración")
@export var velocidad = 0.2          # Velocidad de recorrido (0 a 1)
@export var vida = 1                 # Cuántos disparos aguanta
@export var puntos_xp = 25           # Cuánta experiencia da al morir
@export var daño_al_jugador = 1     # Cuánta vida le quita a la nave

@export_group("Recursos")
@export var explosion_escena: PackedScene
@export var item_powerup: PackedScene # Opcional: arrastra tu PowerUp.tscn aquí

func _ready():
	# -- GAME FEEL: Pop-in effect --
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)

func _process(delta):
	# Movimiento constante por la curva
	progress_ratio += velocidad * delta
	
	# Si llega al final, desaparece silenciosamente
	if progress_ratio >= 1.0:
		queue_free()

func recibir_danio(cantidad):
	vida -= cantidad
	# Hit Flash
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE * 2.0, 0.05)
	tween.tween_property(self, "modulate", Color.WHITE, 0.05)

	if vida <= 0:
		morir()

# Esta función la llama la BALA del jugador
func morir():
	# -- GAME FEEL: Pequeña sacudida al morir --
	Events.enemy_defeated.emit(puntos_xp)
	Events.hit_stop(0.05)

	var jugadores = get_tree().get_nodes_in_group("jugador")
	if jugadores.size() > 0:
		var jugador = jugadores[0]
		if jugador.has_method("sacudir_camara"):
			jugador.sacudir_camara(4.0)
	
	# -- GAME FEEL: Hit Stop (opcional, muy breve) --
	# Engine.time_scale = 0.05
	# await get_tree().create_timer(0.02, true, false, true).timeout
	# Engine.time_scale = 1.0

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

	# Desactivamos colisión para evitar múltiples disparos
	if has_node("Area2D"):
		$Area2D.queue_free()

	# -- GAME FEEL: Desaparecer con estilo --
	var tween_muerte = create_tween()
	tween_muerte.tween_property(self, "scale", Vector2.ZERO, 0.1)
	await tween_muerte.finished

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
