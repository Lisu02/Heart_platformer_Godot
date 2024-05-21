extends Area2D

func _on_body_entered(body):
	queue_free()
	var amountOfHearts = get_tree().get_nodes_in_group("Hearts")
	if amountOfHearts.size() == 1:
		Events.level_completed.emit()

