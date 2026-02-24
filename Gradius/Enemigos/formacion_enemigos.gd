extends Node2D

@export var enemigo_escena: PackedScene
@export var cantidad_enemigos = 5
@export var retraso_entre_enemigos = 0.5

func _ready():
	# Iniciamos la secuencia de spawn
	spawn_escuadron()

func spawn_escuadron():
	for i in range(cantidad_enemigos):
		var nuevo_enemigo = enemigo_escena.instantiate()
		# Lo añadimos como hijo del PATH2D para que siga la curva
		$Path2D.add_child(nuevo_enemigo)
		
		# Esperamos un poco antes de soltar el siguiente
		await get_tree().create_timer(retraso_entre_enemigos).timeout
