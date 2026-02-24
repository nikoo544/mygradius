extends Node2D
class_name EnemyBase

@export var vida = 20
@export var puntos_xp = 30
@export var danio_al_jugador = 15
@export var velocidad = 150.0
@export var explosion_escena: PackedScene

var es_invulnerable = false

func _ready():
	add_to_group("enemigos")
	# Pop-in effect
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)

	setup_enemy()

func setup_enemy():
	pass # Override in subclasses

func recibir_danio(cantidad):
	if es_invulnerable: return
	vida -= cantidad

	# Flash effect
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE * 2.0, 0.05)
	tween.tween_property(self, "modulate", Color.WHITE, 0.05)

	if vida <= 0:
		morir()

func morir():
	Events.enemy_defeated.emit(puntos_xp)
	Events.hit_stop(0.08)

	if explosion_escena:
		var exp = explosion_escena.instantiate()
		exp.global_position = global_position
		get_tree().current_scene.add_child(exp)

	# Pop-out and free
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
	await tween.finished
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("jugador"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(danio_al_jugador)
		morir()

func _on_area_entered(area):
	var body = area.get_parent()
	if body.is_in_group("jugador"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(danio_al_jugador)
		morir()
