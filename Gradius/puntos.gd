extends Area2D

@export var valor_xp = 50
@export var velocidad_atraccion = 400.0
var jugador = null

func _ready():
	add_to_group("collectibles")
	# Pop-in
	scale = Vector2.ZERO
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.3)

func _process(delta):
	if jugador:
		var dir = (jugador.global_position - global_position).normalized()
		position += dir * velocidad_atraccion * delta
		if global_position.distance_to(jugador.global_position) < 20:
			recolectar()

func _on_body_entered(body):
	if body.is_in_group("jugador"):
		jugador = body

func recolectar():
	Events.enemy_defeated.emit(valor_xp) # Reutilizamos la señal para dar XP
	# Efecto visual
	var t = create_tween()
	t.tween_property(self, "scale", Vector2.ZERO, 0.1)
	t.tween_callback(queue_free)
