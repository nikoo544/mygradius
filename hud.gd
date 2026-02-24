extends Control

@onready var xp_bar = $XPBar
@onready var hp_bar = $HealthBar

func _ready():
	Events.hp_changed.connect(_on_hp_changed)
	Events.xp_gained.connect(_on_xp_gained)

func _on_hp_changed(current, max_val):
	hp_bar.max_value = max_val
	# Lerp the value for smoother feel
	var tween = create_tween()
	tween.tween_property(hp_bar, "value", current, 0.2).set_trans(Tween.TRANS_SINE)

func _on_xp_gained(current, max_val):
	xp_bar.max_value = max_val
	var tween = create_tween()
	tween.tween_property(xp_bar, "value", current, 0.2).set_trans(Tween.TRANS_SINE)
