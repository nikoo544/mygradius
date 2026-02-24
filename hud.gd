extends Control

@onready var xp_bar = $XPBar
@onready var hp_bar = $HealthBar
@onready var score_label = $"../BottomBar/HBox/VBoxStats/ScoreLabel"
@onready var speed_label = $"../BottomBar/HBox/VBoxStats/SpeedLabel"
@onready var weapon_label = $"../BottomBar/HBox/VBoxWeapon/WeaponName"

func _ready():
	Events.hp_changed.connect(_on_hp_changed)
	Events.xp_gained.connect(_on_xp_gained)
	Events.score_changed.connect(_on_score_changed)
	Events.weapon_switched.connect(_on_weapon_switched)
	Events.speed_changed.connect(_on_speed_changed)

	# Initial update for speed
	var player = get_tree().get_first_node_in_group("jugador")
	if player:
		speed_label.text = "SPEED: " + str(int(player.velocidad_actual))

func _on_score_changed(new_score):
	score_label.text = "SCORE: " + str(new_score)

func _on_speed_changed(new_speed):
	speed_label.text = "SPEED: " + str(int(new_speed))

func _on_weapon_switched(weapon_name):
	weapon_label.text = weapon_name
	# Animation for emphasis
	var tween = create_tween()
	weapon_label.modulate = Color.WHITE
	tween.tween_property(weapon_label, "modulate", Color.CYAN, 0.3)

func _on_hp_changed(current, max_val):
	hp_bar.max_value = max_val
	# Lerp the value for smoother feel
	var tween = create_tween()
	tween.tween_property(hp_bar, "value", current, 0.2).set_trans(Tween.TRANS_SINE)

func _on_xp_gained(current, max_val):
	xp_bar.max_value = max_val
	var tween = create_tween()
	tween.tween_property(xp_bar, "value", current, 0.2).set_trans(Tween.TRANS_SINE)
