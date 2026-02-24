extends CharacterBody2D

# --- Nodos y Escenas ---
@export var bala_escena: PackedScene
@export var explosion_escena: PackedScene # No olvides asignar tu escena de explosión en el Inspector

# --- Parámetros Base ---
@export var velocidad_base = 350.0
var velocidad_actual = 750.0
var nivel_disparo = 1

# --- Sistema de Disparo ---
@export var cadencia_disparo = 0.15 # Segundos entre cada disparo
var tiempo_disparo = 0.0

# --- Estadísticas y Vida ---
@export var vida_max = 1000
var vida_actual = 1000
var es_invulnerable = false

# --- Experiencia (Roguelite) ---
var experiencia = 0
var exp_siguiente_nivel = 100
var nivel = 1

# --- Referencias a la UI ---
@onready var xp_bar = get_tree().root.find_child("XPBar", true, false)
@onready var hp_bar = get_tree().root.find_child("HealthBar", true, false)
@onready var tamaño_pantalla = get_viewport_rect().size

func _ready():
	# Inicializar barras de UI
	if hp_bar:
		hp_bar.max_value = vida_max
		hp_bar.value = vida_actual
	if xp_bar:
		xp_bar.max_value = exp_siguiente_nivel
		xp_bar.value = experiencia

func _physics_process(delta):
	# 1. Movimiento
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direccion * velocidad_actual
	move_and_slide()
	
	# 2. Inclinación visual (Game Feel): La nave rota un poco al subir o bajar
	rotation = lerp(rotation, direccion.y * 0.15, 10 * delta)
	
	# 3. Limitar a la pantalla (Evita que la nave se salga del borde)
	global_position.x = clamp(global_position.x, 20, tamaño_pantalla.x - 20)
	global_position.y = clamp(global_position.y, 20, tamaño_pantalla.y - 20)

func _process(delta):
	# Temporizador para el disparo automático
	tiempo_disparo -= delta
	
	# Usamos is_action_pressed para que dispare mientras se mantenga presionado
	if Input.is_action_pressed("ui_accept") and tiempo_disparo <= 0.0:
		disparar()
		tiempo_disparo = cadencia_disparo # Reiniciamos el temporizador

func disparar():
	# Game Feel: Pequeño retroceso (recoil) visual opcional
	# global_position.x -= 2 
	
	if nivel_disparo == 1:
		crear_bala(Vector2(20, 0)) # Disparo simple frontal
	elif nivel_disparo == 2:
		crear_bala(Vector2(20, -10)) # Disparo doble
		crear_bala(Vector2(20, 10))
	elif nivel_disparo >= 3:
		crear_bala(Vector2(20, 0))
		crear_bala(Vector2(15, -15), -20) # Disparo diagonal arriba
		crear_bala(Vector2(15, 15), 20)  # Disparo diagonal abajo

func crear_bala(offset, rotacion = 0):
	if bala_escena:
		var b = bala_escena.instantiate()
		b.global_position = global_position + offset
		b.rotation_degrees = rotacion
		get_tree().current_scene.add_child(b)

# --- SISTEMA DE DAÑO Y MUERTE ---
func recibir_danio(cantidad):
	if es_invulnerable or vida_actual <= 0:
		return
		
	vida_actual -= cantidad
	if hp_bar: hp_bar.value = vida_actual
	
	if vida_actual <= 0:
		morir_jugador()
	else:
		activar_invulnerabilidad()

func activar_invulnerabilidad():
	es_invulnerable = true
	# Efecto de parpadeo usando un Tween (Game Feel)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.2, 0.1)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	tween.set_loops(5) # Parpadea 5 veces
	
	await get_tree().create_timer(1.0).timeout
	es_invulnerable = false

func morir_jugador():
	# Efecto de explosión
	if explosion_escena:
		var exp = explosion_escena.instantiate()
		exp.global_position = global_position
		exp.scale = Vector2(2, 2) # Explosión más grande
		get_tree().current_scene.add_child(exp)
	
	# Desactivamos la nave en lugar de borrarla de golpe
	set_physics_process(false)
	set_process(false)
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	
	print("¡GAME OVER!")
	# Aquí puedes llamar a tu menú de Game Over

# --- SISTEMA DE PROGRESIÓN ---
func mejorar(): # Para Power-Ups clásicos recogidos del suelo
	nivel_disparo += 1
	velocidad_actual += 20 # Menos velocidad por power-up para no perder el control
	print("Power Up! Nivel de disparo: ", nivel_disparo)

func ganar_xp(cantidad):
	experiencia += cantidad
	if xp_bar: xp_bar.value = experiencia
	
	if experiencia >= exp_siguiente_nivel:
		subir_nivel()

func subir_nivel():
	nivel += 1
	experiencia -= exp_siguiente_nivel # Guarda la XP sobrante
	exp_siguiente_nivel = int(exp_siguiente_nivel * 1.5) # Escala de XP más agresiva
	
	if xp_bar:
		xp_bar.max_value = exp_siguiente_nivel
		xp_bar.value = experiencia
		
	print("¡Nivel subido! Nivel: ", nivel)
	# TODO: Pausar juego y abrir menú de Trinkets
