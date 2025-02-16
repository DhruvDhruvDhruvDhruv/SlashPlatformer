extends Node2D

@onready var game_manager: Node2D = $game_manager
@onready var totem_sprite: AnimatedSprite2D = $totem_sprite

var save_point_num := "POST_DASH"

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Hero":
		if body.curr_save_point < save_point_num:
			print("Game Saved")
			body.curr_save_point = save_point_num
			totem_sprite.play("saved")
