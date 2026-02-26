extends "res://Gradius/Enemigos/enemy_base.gd"

@export var bala_escena: PackedScene
@export var balas_por_burst = 12
@export var intervalo_burst = 2.5
var tiempo_burst = 0.0

func _process(delta):
	if esta_muerto: return

	# Movimiento lento hacia la izquierda
	position.x -= velocidad * 0.4 * delta

	tiempo_burst += delta
	if tiempo_burst >= intervalo_burst:
		disparar_burst()
		tiempo_burst = 0.0

func disparar_burst():
	# Game Feel: Pequeño flash y escala antes de disparar
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

	if not bala_escena:
		# Intentar cargar una bala por defecto si no está asignada
		bala_escena = load("res://Gradius/Bullet.tscn")

	if bala_escena:
		for i in range(balas_por_burst):
			var angulo = (PI * 2 / balas_por_burst) * i
			var b = bala_escena.instantiate()
			b.global_position = global_position
			b.rotation = angulo
			# Cambiar color para diferenciar disparos enemigos
			b.modulate = Color.YELLOW
			if "velocidad" in b: b.velocidad = 250
			if "bando_objetivo" in b: b.bando_objetivo = "jugador"
			get_tree().current_scene.add_child(b)
