extends Node

func _ready():
	if not OS.has_feature("editor"):
		queue_free()
