extends ColorRect

# Lista de posibles mejoras (Adaptadas a tu nuevo script de Player)
var pool_de_mejoras = [
	{"nombre": "Motores Élite", "desc": "+50 Velocidad de Nave", "tipo": "vel"},
	{"nombre": "Cañón Secundario", "desc": "Activa Disparo en V\n(Múltiples proyectiles)", "tipo": "arma_tipo2"},
	{"nombre": "Lanzamisiles", "desc": "Activa proyectiles\npesados y lentos", "tipo": "arma_misil"},
	{"nombre": "Placas de Titanio", "desc": "+30 Vida Máx y cura 20 HP", "tipo": "vida"},
	{"nombre": "Sobrecarga Eléctrica", "desc": "+15% Velocidad de disparo\npara todas las armas", "tipo": "cadencia"}
]

@onready var contenedor = $HBoxContainer 

func _ready():
	# Nos aseguramos de que procese aunque el árbol esté pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func generar_opciones():
	# -- GAME FEEL: Animación de entrada del menú --
	scale = Vector2(0.8, 0.8) # Empieza un poco pequeño
	modulate.a = 0.0 # Empieza transparente
	var tween_menu = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_menu.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)
	tween_menu.parallel().tween_property(self, "modulate:a", 1.0, 0.2)
	
	# Limpiar botones viejos
	for child in contenedor.get_children():
		child.queue_free()
	
	pool_de_mejoras.shuffle()
	
	var num_opciones = min(3, pool_de_mejoras.size())
	
	for i in range(num_opciones):
		var mejora = pool_de_mejoras[i]
		var boton = Button.new()
		
		# Configuramos el texto
		boton.text = mejora["nombre"] + "\n\n" + mejora["desc"]
		
		# Tamaño y alineación
		boton.custom_minimum_size = Vector2(250, 150)
		boton.alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		# -- GAME FEEL: Animación al pasar el ratón (Hover) --
		# El pivot_offset hace que el botón crezca desde su centro y no desde la esquina
		boton.pivot_offset = boton.custom_minimum_size / 2.0 
		
		boton.mouse_entered.connect(func():
			var btn_tween = create_tween().set_trans(Tween.TRANS_SINE)
			btn_tween.tween_property(boton, "scale", Vector2(1.05, 1.05), 0.1)
		)
		boton.mouse_exited.connect(func():
			var btn_tween = create_tween().set_trans(Tween.TRANS_SINE)
			btn_tween.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.1)
		)
		
		# Conectar señal de click
		boton.pressed.connect(self._aplicar_mejora.bind(mejora))
		contenedor.add_child(boton)
		
func _aplicar_mejora(mejora):
	# get_first_node_in_group es más seguro y eficiente en Godot 4
	var jugador = get_tree().get_first_node_in_group("jugador")
	if not jugador: return
	
	match mejora["tipo"]:
		"vel": 
			jugador.velocidad_actual += 50
		"arma_tipo2": 
			# Cambiamos al nuevo disparo del enum
			jugador.modo_disparo_actual = jugador.TipoDisparo.TIPO_2
		"arma_misil": 
			# Cambiamos al misil del enum
			jugador.modo_disparo_actual = jugador.TipoDisparo.MISIL
		"vida": 
			jugador.vida_max += 30
			jugador.vida_actual = min(jugador.vida_actual + 20, jugador.vida_max) # Evita pasarse del máximo
		"cadencia": 
			# Aceleramos todas las armas principales
			jugador.cadencia_disparo_tipo1 *= 0.85
			jugador.cadencia_disparo_tipo2 *= 0.85
			jugador.cadencia_misil *= 0.85
	
	# Actualizar UI
	if jugador.hp_bar:
		jugador.hp_bar.max_value = jugador.vida_max
		jugador.hp_bar.value = jugador.vida_actual
	
	# -- GAME FEEL: Animación de salida antes de quitar la pausa --
	var tween_salida = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween_salida.tween_property(self, "scale", Vector2(0.8, 0.8), 0.15)
	tween_salida.parallel().tween_property(self, "modulate:a", 0.0, 0.15)
	
	await tween_salida.finished # Esperamos a que termine la animación
	
	visible = false
	get_tree().paused = false # ¡Volvemos a la acción!
