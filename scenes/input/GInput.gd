extends Node

class_name GInput

onready var actor = get_parent()

var is_active := false

var input_dir := Vector2()
var input_run := false

func _ready():
	if actor is GActor:
		active()

func _physics_process(delta):
	
	if not is_active or actor.is_disabled : return
	
	if actor.can_move:
		input_dir.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
		input_dir.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
		input_run = Input.is_action_pressed("run")
		
		if input_dir == Vector2():
			actor._stop_handler(delta)
		else:
			actor._move_handler(delta, input_dir, input_run)
	
	if Input.is_action_pressed("fire"):
		
		actor._fire_handler()
	
	if Input.is_action_just_pressed("reload"):
		
		actor._reload_handler()
	
	
func active(_active := true):
	is_active = _active
