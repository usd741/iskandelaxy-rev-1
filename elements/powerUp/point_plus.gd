extends CharacterBody2D

var speed = 1.0
var random = randi_range(30, 60)


func _physics_process(delta):
	var collision = move_and_collide(Vector2.DOWN * delta * speed * random)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("point_plus"):
			collider.point_plus()
			Globals.change_points(+1)
			queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
