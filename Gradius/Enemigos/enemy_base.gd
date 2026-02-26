extends Area2D
class_name EnemyBase

@export var vida = 20
@export var puntos_xp = 30
@export var danio_al_jugador = 15
@export var velocidad = 150.0
@export var explosion_escena: PackedScene
@export var drop_escena: PackedScene

var es_invulnerable = false
var esta_muerto = false

func _ready():
	add_to_group("enemigos")

	# Autoconectar señales de colisión
	if has_signal("body_entered") and not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if has_signal("area_entered") and not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

	# Pop-in effect
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)

	setup_enemy()

func setup_enemy():
	pass # Override in subclasses

func recibir_danio(cantidad):
	if es_invulnerable or esta_muerto: return
	vida -= cantidad

	# Flash effect
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE * 2.0, 0.05)
	tween.tween_property(self, "modulate", Color.WHITE, 0.05)

	if vida <= 0:
		morir()

func morir():
	if esta_muerto: return
	esta_muerto = true

	Events.enemy_defeated.emit(puntos_xp)
	Events.hit_stop(0.08)

	if explosion_escena:
		var exp = explosion_escena.instantiate()
		exp.global_position = global_position
		get_tree().current_scene.add_child(exp)

	if drop_escena or randf() < 0.3: # 30% chance to drop points if not assigned, or always if assigned
		var d_scene = drop_escena if drop_escena else load("res://Gradius/Points.tscn")
		if d_scene:
			var drop = d_scene.instantiate()
			drop.global_position = global_position
			get_tree().current_scene.add_child.call_deferred(drop)

	# Pop-out and free
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
	await tween.finished
	queue_free()

func _on_body_entered(body):
	_handle_player_collision(body)

func _on_area_entered(area):
	_handle_player_collision(area)

func _handle_player_collision(target):
	if esta_muerto: return

	var final_target = target
	if not final_target.is_in_group("jugador") and final_target.get_parent().is_in_group("jugador"):
		final_target = final_target.get_parent()

	if final_target.is_in_group("jugador"):
		if final_target.has_method("recibir_danio"):
			final_target.recibir_danio(danio_al_jugador)
		morir()
