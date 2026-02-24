extends CPUParticles2D

func _ready():
	emitting = true

	# -- GAME FEEL: Flash de luz --
	var flash = ColorRect.new()
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.color = Color.WHITE
	flash.modulate.a = 0.3
	get_tree().root.add_child(flash)

	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.1)
	tween.tween_callback(flash.queue_free)

	# Esperamos a que terminen las partículas y borramos el nodo
	await get_tree().create_timer(lifetime).timeout
	queue_free()
