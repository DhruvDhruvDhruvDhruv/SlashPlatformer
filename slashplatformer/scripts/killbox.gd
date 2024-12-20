extends Area2D

@onready var timer: Timer = $Timer

signal player_reset

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Hero":
		print("You died.")
		Engine.time_scale = 0.3
		timer.start(1)

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	player_reset.emit()
