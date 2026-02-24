extends CharacterBody2D

# --- Nodos y Escenas ---
@export var bala_escena: PackedScene
@export var misil_escena: PackedScene
@export var explosion_escena: PackedScene

# --- Parámetros Base ---
@export var velocidad_base := 600.0
@export var aceleracion := 1200.0
@export var friccion := 800.0
@export var velocidad_rotacion := 5.0
var velocidad_actual := 600.0

# --- Sistema de Disparo ---
# Tipos de disparo
enum TipoDisparo { TIPO_1, TIPO_2, MISIL, LASER, PROY_DIRIGIDO }

# Disparos disponibles (puedes expandir)
var modo_disparo_actual := TipoDisparo.TIPO_1

# Cadencias por tipo
@export var cadencia_disparo_tipo1 := 0.15
@export var cadencia_disparo_tipo2 := 0.25
@export var cadencia_misil := 0.5
@export var cadencia_laser := 0.08
@export var cadencia_proy_dirigido := 0.20

# Timers de disparo por tipo
var tiempo_disparo_tipo1 := 0.0
var tiempo_disparo_tipo2 := 0.0
var tiempo_misil := 0.0
var tiempo_laser := 0.0
var tiempo_proy_dirigido := 0.0

# --- Retro Trail ---
var trail_timer := 0.0
@export var trail_interval := 0.05

# --- Estadísticas y Vida ---
@export var vida_max := 100
var vida_actual := 100
var es_invulnerable := false

# --- Escudo ---
var escudo_activo := false
var vida_escudo := 0
var vida_escudo_max := 50

# --- Experiencia (Roguelite) ---
var experiencia := 0
var exp_siguiente_nivel := 100
var nivel := 1
var multiplicador_xp := 1.0
var score := 0

# --- Referencias a la UI ---

func _ready():
	# Aseguramos que la nave flote (para que no afecten rozamientos de suelo)
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	Events.enemy_defeated.connect(_on_enemy_defeated)
	# 1. Forzamos los valores base al arrancar
	vida_actual = vida_max  # Esto debería ser 100
	
	# 2. DEBUG: Vamos a ver cuánto vale realmente vida_max
	print("DEBUG: Mi vida máxima es: ", vida_max)
	print("DEBUG: Mi vida actual al iniciar es: ", vida_actual)

	# 3. Configurar UI
	Events.hp_changed.emit(vida_actual, vida_max)
	Events.xp_gained.emit(experiencia, exp_siguiente_nivel)
	
	actualizar_interfaz_xp()
	velocidad_actual = velocidad_base

func _physics_process(delta: float) -> void:
	# Retro Trail
	trail_timer += delta
	if trail_timer >= trail_interval:
		crear_rastro()
		trail_timer = 0.0

	# 1. Movimiento 360 (Thrust & Rotation)
	var rot_input = Input.get_axis("ui_left", "ui_right")
	rotation += rot_input * velocidad_rotacion * delta

	var thrust_input = Input.get_axis("ui_down", "ui_up") # ui_up es positivo
	var target_velocity = Vector2.RIGHT.rotated(rotation) * thrust_input * velocidad_actual

	if thrust_input > 0:
		velocity = velocity.move_toward(target_velocity, aceleracion * delta)
		if has_node("ThrustParticles"): $ThrustParticles.emitting = true
	else:
		velocity = velocity.move_toward(target_velocity if thrust_input < 0 else Vector2.ZERO, friccion * delta)
		if has_node("ThrustParticles"): $ThrustParticles.emitting = false

	move_and_slide()

	# 2. Feedback Visual

	# Efecto Retro: Modulación que cambia ligeramente
	modulate.v = 1.0 + (sin(Time.get_ticks_msec() * 0.01) * 0.1)

	# 3. Límite de pantalla (Removido para estabilidad, usamos StaticBody2D walls)

func _process(delta: float) -> void:
	# Actualizar timers de disparo por tipo
	tiempo_disparo_tipo1 -= delta
	tiempo_disparo_tipo2 -= delta
	tiempo_misil -= delta
	tiempo_laser -= delta
	tiempo_proy_dirigido -= delta

	# Intercambiar entre disparos (tecla de cambio)
	if Input.is_action_just_pressed("switch_gun"):
		cambiar_disparo()
	
	# Disparos disponibles por tipo según el modo actual
	# Disparo principal o alternativo cuando el modo es TIPO_1/TIPO_2
	if Input.is_action_pressed("ui_accept"):
		# Si el disparo actual es TIPO_1 o TIPO_2 y su cooldown pasa, disparar
		match modo_disparo_actual:
			TipoDisparo.TIPO_1:
				if tiempo_disparo_tipo1 <= 0.0:
					disparar_tipo1()
					tiempo_disparo_tipo1 = cadencia_disparo_tipo1
			TipoDisparo.TIPO_2:
				if tiempo_disparo_tipo2 <= 0.0:
					disparar_tipo2()
					tiempo_disparo_tipo2 = cadencia_disparo_tipo2
			TipoDisparo.MISIL:
				if tiempo_misil <= 0.0:
					disparar_misil()
					tiempo_misil = cadencia_misil
			TipoDisparo.LASER:
				if tiempo_laser <= 0.0:
					disparar_laser()
					tiempo_laser = cadencia_laser
			TipoDisparo.PROY_DIRIGIDO:
				if tiempo_proy_dirigido <= 0.0:
					disparar_proy_dirigido()
					tiempo_proy_dirigido = cadencia_proy_dirigido

func cambiar_disparo() -> void:
	# Cambiar entre TIPO_1 y TIPO_2 para el ciclo normal
	# Si ya estás en un power-up de disparo especial, puedes usar esta función para volver
	match modo_disparo_actual:
		TipoDisparo.TIPO_1:
			modo_disparo_actual = TipoDisparo.TIPO_2
			Events.weapon_switched.emit("TYPE 2 (SPREAD)")
		TipoDisparo.TIPO_2:
			modo_disparo_actual = TipoDisparo.TIPO_1
			Events.weapon_switched.emit("TYPE 1 (CENTER)")
		_:
			# Si estás en un disparo especial, vuelve al principal al pulsar switch
			modo_disparo_actual = TipoDisparo.TIPO_1
			Events.weapon_switched.emit("TYPE 1 (CENTER)")

func disparar_tipo1() -> void:
	# Disparo simple frontal (Tipo 1) - Center
	var pos = $Spawns/Center.global_position - global_position
	crear_bala(pos)
	# Pequeño recoil visual
	var tween = create_tween()
	tween.tween_property(self, "position", position - Vector2.RIGHT.rotated(rotation) * 3, 0.05)
	tween.tween_property(self, "position", position, 0.05)

func disparar_tipo2() -> void:
	# Disparo secundario con recoil moderado - Wings
	var pos_l = $Spawns/LeftWing.global_position - global_position
	var pos_r = $Spawns/RightWing.global_position - global_position
	crear_bala(pos_l)
	crear_bala(pos_r)

	var tween = create_tween()
	tween.tween_property(self, "position", position - Vector2.RIGHT.rotated(rotation) * 7, 0.05)
	tween.tween_property(self, "position", position, 0.05)
	# Puedes agregar más efectos opcionales aquí

func disparar_misil() -> void:
	var m
	if misil_escena:
		m = misil_escena.instantiate()
	else:
		# Generamos un misil por código si no hay escena
		m = Area2D.new()
		m.set_script(load("res://Gradius/homing_missile.gd"))
		# Añadir un visual simple (Polygon2D)
		var rect = Polygon2D.new()
		rect.polygon = PackedVector2Array([
			Vector2(-7, -2), Vector2(7, -2),
			Vector2(7, 2), Vector2(-7, 2)
		])
		rect.color = Color.ORANGE
		m.add_child(rect)
		# Añadir colisión
		var col = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(15, 5)
		col.shape = shape
		m.add_child(col)

	m.global_position = $Spawns/Center.global_position
	m.rotation = rotation
	get_tree().current_scene.add_child(m)

func disparar_laser() -> void:
	# Láser estilo retro: Muy rápido y brillante - From Wings
	var pos_l = $Spawns/LeftWing.global_position - global_position
	var pos_r = $Spawns/RightWing.global_position - global_position
	for pos in [pos_l, pos_r]:
		for i in range(3):
			var b = crear_bala(pos + Vector2.RIGHT.rotated(rotation) * (i*40))
			if b:
				b.modulate = Color.CYAN
				b.scale = Vector2(2, 0.5)
				if "velocidad" in b: b.velocidad *= 2.5

func disparar_proy_dirigido() -> void:
	# Proyectil dirigido: puede buscar objetivo o ir con guía básica
	var pos = $Spawns/Center.global_position - global_position
	crear_bala(pos)

func crear_bala(offset: Vector2) -> Node2D:
	if bala_escena:
		var bala := bala_escena.instantiate()
		bala.global_position = global_position + offset
		bala.rotation = rotation
		get_tree().current_scene.add_child(bala)
		return bala
	else:
		push_warning(" bala_escena no está asignada. No se puede disparar.")
		return null

# --- SISTEMA DE DAÑO Y MUERTE ---
func recibir_danio(cantidad: int) -> void:
	if es_invulnerable or vida_actual <= 0:
		return

	# Manejo de escudo
	if escudo_activo:
		vida_escudo -= cantidad
		sacudir_camara(5.0)
		if vida_escudo <= 0:
			escudo_activo = false
			print("¡Escudo destruido!")
			# Feedback visual de escudo roto
			modulate = Color.WHITE
		return

	vida_actual -= cantidad
	vida_actual = max(vida_actual, 0)

	Events.hp_changed.emit(vida_actual, vida_max)

	# Hit Stop!
	Events.hit_stop(0.15)

	# -- GAME FEEL: Hit Flash --
	var flash_tween = create_tween()
	flash_tween.tween_property(self, "modulate", Color.RED, 0.05)
	flash_tween.tween_property(self, "modulate", Color.WHITE, 0.05)

	print("Vida restante: ", vida_actual)
	if vida_actual <= 0:
		morir_jugador()
	else:
		sacudir_camara(12.0)
		activar_invulnerabilidad()

func activar_invulnerabilidad() -> void:
	es_invulnerable = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.2, 0.1)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	tween.set_loops(5)
	await get_tree().create_timer(1.0).timeout
	es_invulnerable = false

func morir_jugador() -> void:
	if explosion_escena:
		var exp := explosion_escena.instantiate()
		exp.global_position = global_position
		exp.scale = Vector2(2, 2)
		get_tree().current_scene.add_child(exp)
	set_physics_process(false)
	set_process(false)
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	print("¡GAME OVER!")
	Events.player_died.emit()

# --- SISTEMA DE PROGRESIÓN ---
# En el script del Player (CharacterBody2D)
func mejorar() -> void:
	# Curamos 20 HP sin pasarnos del máximo
	vida_actual = min(vida_actual + 20, vida_max)
	Events.hp_changed.emit(vida_actual, vida_max)
	
	# Damos un empujón de XP
	ganar_xp(30) 
	
	# Efecto visual rápido (Game Feel)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	print("¡Power Up recogido! +Vida +XP")

func _on_enemy_defeated(cantidad: int) -> void:
	# Sumar score
	score += cantidad * 10
	Events.score_changed.emit(score)

	# Ganar XP
	var xp_final = int(cantidad * multiplicador_xp)
	experiencia += xp_final
	Events.xp_gained.emit(experiencia, exp_siguiente_nivel)
	if experiencia >= exp_siguiente_nivel:
		subir_nivel()

func subir_nivel() -> void:
	nivel += 1
	experiencia -= exp_siguiente_nivel
	# Ajuste de curva XP: Un poco más suave que 1.5
	exp_siguiente_nivel = int(exp_siguiente_nivel * 1.3) + 25

	actualizar_interfaz_xp()

	get_tree().paused = true
	Events.level_up.emit(nivel)

func actualizar_interfaz_xp() -> void:
	Events.xp_gained.emit(experiencia, exp_siguiente_nivel)


func crear_rastro():
	var ghost: Node2D

	# Intentar copiar la textura si el jugador tiene una
	var sprite = get_node_or_null("Sprite2D")
	if sprite and sprite.texture:
		ghost = Sprite2D.new()
		ghost.texture = sprite.texture
		ghost.scale = sprite.global_scale
	else:
		# Si no hay sprite, un polígono neón (Node2D) para evitar errores de rotación
		ghost = Polygon2D.new()
		ghost.polygon = PackedVector2Array([
			Vector2(-20, -10), Vector2(20, -10),
			Vector2(20, 10), Vector2(-20, 10)
		])
		ghost.color = Color.CYAN

	ghost.global_position = global_position
	ghost.global_rotation = global_rotation
	ghost.modulate = Color(0, 1, 1, 0.5)
	ghost.z_index = z_index - 1
	get_tree().current_scene.add_child(ghost)

	var tween = create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.3)
	tween.tween_property(ghost, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(ghost.queue_free)

func sacudir_camara(intensidad: float = 5.0):
	var cam = get_viewport().get_camera_2d()
	if cam:
		# Cancelar cualquier shake previo si es posible
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		for i in range(6):
			var desplazar = Vector2(randf_range(-intensidad, intensidad), randf_range(-intensidad, intensidad))
			tween.tween_property(cam, "offset", desplazar, 0.04)
			intensidad *= 0.8 # Decaimiento de la intensidad

		tween.tween_property(cam, "offset", Vector2.ZERO, 0.04)
