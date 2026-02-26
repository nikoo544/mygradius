extends "res://Gradius/Enemigos/enemy_base.gd"

@export var drone_escena: PackedScene
@export var intervalo_spawn = 4.0
var tiempo_spawn = 0.0

func _process(delta):
	if esta_muerto: return

	# Se queda en la parte derecha de la pantalla
	var cam = get_viewport().get_camera_2d()
	if cam:
		var target_x = cam.global_position.x + (get_viewport_rect().size.x / cam.zoom.x / 2.0) - 150
		global_position.x = lerp(global_position.x, target_x, 2 * delta)

	tiempo_spawn += delta
	if tiempo_spawn >= intervalo_spawn:
		spawn_drone()
		tiempo_spawn = 0.0

func spawn_drone():
	if drone_escena:
		var drone = drone_escena.instantiate()
		drone.global_position = global_position + Vector2(-50, randf_range(-30, 30))
		get_tree().current_scene.add_child(drone)
	else:
		# Fallback: spawn a small kamikaze
		var k_scene = load("res://Gradius/Enemigos/EnemyKamikaze.tscn")
		if not k_scene: return
		var k = k_scene.instantiate()
		k.global_position = global_position + Vector2(-50, randf_range(-30, 30))
		k.scale = Vector2(0.5, 0.5)
		if "puntos_xp" in k: k.puntos_xp = 10
		get_tree().current_scene.add_child(k)
