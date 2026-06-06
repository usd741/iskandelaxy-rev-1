extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_button_pressed():
	clear_bullets() #чистим пули
	clear_power_up() #чистим павер апы
	get_tree().paused = false
	Globals.reset()
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://game/game.tscn")

func _on_btn_main_menu_pressed() -> void:
	clear_bullets() #чистим пули
	clear_power_up() #чистим павер апы
	get_tree().paused = false
	Globals.reset()
	get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")

func clear_bullets():
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		bullet.queue_free()

func clear_power_up():
	var power_up = get_tree().get_nodes_in_group("power_up")
	print("найдено Power ups в группе:", power_up.size())
	for i in range(power_up.size() -1, -1, -1):
		var node = power_up[i]
		print("Удаляем: ", node.name, " | Путь: ", node.get_path())
		power_up[i].queue_free()
	print("Power ups cleared")