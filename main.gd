extends Node2D

# Cargamos la escena del enemigo en memoria
@export var enemigo_escena: PackedScene
var pantalla_ancho = get_viewport_rect().size.x
func _ready():
	Events.player_died.connect(mostrar_pantalla_game_over)

func _on_spawn_timer_timeout():
	if not enemigo_escena: return
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
		# Aseguramos que los hijos del menú sean visibles (si estaban ocultos en el editor)
		for child in menu.get_children():
			if child is Control:
				child.visible = true

		# Conectar el botón de reintentar programáticamente si no está conectado
		var btn = menu.find_child("Button", true, false)
		if btn and not btn.pressed.is_connected(_on_boton_reintentar_pressed):
			btn.pressed.connect(_on_boton_reintentar_pressed)

		# Pausamos el juego
		get_tree().paused = true

# Conecta la señal 'pressed' del botón REINTENTAR a esta función:
func _on_boton_reintentar_pressed():
	# Reinicia la escena actual
	get_tree().reload_current_scene()
