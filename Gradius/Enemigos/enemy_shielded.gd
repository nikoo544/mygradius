extends "res://Gradius/Enemigos/enemy_base.gd"

@export var shield_vida = 3
var current_shield_vida = 3

func setup_enemy():
	current_shield_vida = shield_vida
	# Visual feedback for shield
	modulate = Color.AQUAMARINE

func recibir_danio(cantidad):
	if esta_muerto: return

	if current_shield_vida > 0:
		current_shield_vida -= 1
		# Shield flash
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.05)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.05)
		if current_shield_vida <= 0:
			modulate = Color.WHITE # Shield broken
	else:
		super.recibir_danio(cantidad)

func _process(delta):
	if esta_muerto: return
	position.x -= velocidad * 0.7 * delta
