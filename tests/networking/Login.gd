extends Control

func _ready():
	pass

func _on_Connect_pressed():
	Networking.join_host($ColorRect/Margin/VBox/IP.text)
	
func _on_CreateHost_pressed():
	Networking.create_host()
