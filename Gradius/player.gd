extends CharacterBody2D

# --- Nodos y Escenas ---
@export var bala_escena: PackedScene
@export var explosion_escena: PackedScene

# --- Parámetros Base ---
@export var velocidad_base := 350.0
var velocidad_actual := 750.0

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

# --- Estadísticas y Vida ---
@export var vida_max := 100
var vida_actual := 100
var es_invulnerable := false

# --- Experiencia (Roguelite) ---
var experiencia := 0
var exp_siguiente_nivel := 100
var nivel := 1
var multiplicador_xp := 1.0

# --- Referencias a la UI ---

func _ready():
	Events.enemy_defeated.connect(ganar_xp)
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
	# 1. Movimiento
	var direccion := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direccion * velocidad_actual
	move_and_slide()

	# 2. Inclinación visual
	rotation = lerp(rotation, direccion.y * 0.15, 10 * delta)

	# 3. Límite de pantalla
#	limitar_a_pantalla()

func limtar_a_pantalla() -> void:
	var camara := get_viewport().get_camera_2d()
	if camara:
		var tamaño_visible := get_viewport_rect().size / camara.zoom
		var lim_izq := camara.global_position.x - (tamaño_visible.x / 2.0)
		var lim_der := camara.global_position.x + (tamaño_visible.x / 2.0)
		var lim_sup := camara.global_position.y - (tamaño_visible.y / 2.0)
		var lim_inf := camara.global_position.y + (tamaño_visible.y / 2.0)
		var margen := 30.0
		global_position.x = clamp(global_position.x, lim_izq + margen, lim_der - margen)
		global_position.y = clamp(global_position.y, lim_sup + margen, lim_inf - margen)

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
			print("Disparo cambiado: TIPO_2 (secundario)")
		TipoDisparo.TIPO_2:
			modo_disparo_actual = TipoDisparo.TIPO_1
			print("Disparo cambiado: TIPO_1 (principal)")
		_:
			# Si estás en un disparo especial, vuelve al principal al pulsar switch
			modo_disparo_actual = TipoDisparo.TIPO_1
			print("Disparo cambiado: TIPO_1 (principal)")

func disparar_tipo1() -> void:
	# Disparo simple frontal (Tipo 1)
	crear_bala(Vector2(20, 0))
	# Pequeño recoil visual
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x - 3, 0.05)
	tween.tween_property(self, "position:x", position.x, 0.05)

func disparar_tipo2() -> void:
	# Disparo secundario con recoil moderado
	# Dos balas con ligero spread
	crear_bala(Vector2(20, -8))
	crear_bala(Vector2(20, 8))

	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x - 7, 0.05)
	tween.tween_property(self, "position:x", position.x, 0.05)
	# Puedes agregar más efectos opcionales aquí

func disparar_misil() -> void:
	# Misil guiado o inerte
	# Un misil que podría ir recto y luego buscar objetivo
	crear_bala(Vector2(20, 0))
	# Si tienes una escena de misil distinta, podrías instanciarla aquí
	# Ejemplo alternativo:
	# if misil_escena:
	#     var m = misil_escena.instantiate()
	#     m.global_position = global_position + Vector2(20, 0)
	#     get_tree().current_scene.add_child(m)

func disparar_laser() -> void:
	# Láser de pulso corto y alto daño
	crear_bala(Vector2(20, 0))
	# Podrías añadir un rayo visual o efecto de disparo láser

func disparar_proy_dirigido() -> void:
	# Proyectil dirigido: puede buscar objetivo o ir con guía básica
	crear_bala(Vector2(20, 0))
	# Si implementas guía, podrías ajustar la bala para que busque al jugador más adelante

func crear_bala(offset: Vector2) -> void:
	if bala_escena:
		var bala := bala_escena.instantiate()
		bala.global_position = global_position + offset
		# Por simplificación, no establecemos rotación especial aquí
		get_tree().current_scene.add_child(bala)
	else:
		push_warning(" bala_escena no está asignada. No se puede disparar.")

# --- SISTEMA DE DAÑO Y MUERTE ---
func recibir_danio(cantidad: int) -> void:
	if es_invulnerable or vida_actual <= 0:
		return
	vida_actual -= cantidad
	vida_actual = max(vida_actual, 0)

	Events.hp_changed.emit(vida_actual, vida_max)

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

func ganar_xp(cantidad: int) -> void:
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
