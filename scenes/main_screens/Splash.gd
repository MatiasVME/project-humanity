extends Node2D

func _on_AnimSplash_animation_finished(anim_name):
	if anim_name == "Intro":
		$AnimSplash.play("finish")
	
