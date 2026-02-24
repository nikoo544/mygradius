extends Node2D

# Cargamos la escena del enemigo en memoria
@export var enemigo_escena: PackedScene
var pantalla_ancho = get_viewport_rect().size.x
func _on_spawn_timer_timeout():
	var nuevo_enemigo = enemigo_escena.instantiate()
	
	# Conseguimos el ancho y alto de la pantalla
	var ancho_pantalla = get_viewport_rect().size.x
	var alto_pantalla = get_viewport_rect().size.y
	
	# Lo ponemos justo fuera de la pantalla a la derecha
	# Y en una altura (Y) aleatoria
	var pos_x = ancho_pantalla + 50
	var pos_y = randf_range(50, alto_pantalla - 50)
	
	nuevo_enemigo.position = Vector2(pos_x, pos_y)
	
	add_child(nuevo_enemigo)
	
func mostrar_pantalla_game_over():
	var menu = get_tree().root.find_child("GameOverMenu", true, false)
	if menu:
		menu.visible = true
		# Pausamos el juego excepto el menú
		get_tree().paused = false 

# Conecta la señal 'pressed' del botón REINTENTAR a esta función:
func _on_boton_reintentar_pressed():
	# Reinicia la escena actual
	get_tree().reload_current_scene()
