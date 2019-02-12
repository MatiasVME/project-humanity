extends KinematicBody2D

export (int) var speed = 2500

var vehicle : Vehicle = null

var move_x
var move_y

puppet var p_move_x = 0
puppet var p_move_y = 0

var input_dir : Vector2 = Vector2()
var input_run : bool = false
var input_interact : bool = false

func _ready():
	pass

func _physics_process(delta):
	if vehicle and vehicle._driver:
		vehicle._get_input(delta)
	else:
		get_input(delta)
	
func get_input(delta : float) -> void:
	input_dir.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input_dir.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	input_run = Input.is_action_pressed("run")
	input_interact = Input.is_action_just_pressed("ui_accept")
	
	if input_interact and vehicle:
		disable_player()
		vehicle.mount_vehicle()
	
	if not input_run:
		move_x = input_dir.x * speed * delta
		move_y = input_dir.y * speed * delta
		$Sprite.speed_scale = 0.6
	else:
		move_x = input_dir.x * speed * 2 * delta
		move_y = input_dir.y * speed * 2 * delta
		$Sprite.speed_scale = 1.2
	
	if input_dir.x == -1 and input_dir.y == 0:
		$Anim.play("MoveSide")
		$Sprite.flip_h = true
	elif input_dir.x == -1 and input_dir.y == -1:
		$Anim.play("MoveUp")
	elif input_dir.x == 0 and input_dir.y == -1:
		$Anim.play("MoveUp")
	elif input_dir.x == 1 and input_dir.y == -1:
		$Anim.play("MoveUp")
	elif input_dir.x == 1 and input_dir.y == 0:
		$Anim.play("MoveSide")
		$Sprite.flip_h = false
	elif input_dir.x == 1 and input_dir.y == 1:
		$Anim.play("MoveDown")
		$Sprite.flip_h = false
	elif input_dir.x == 0 and input_dir.y == 1:
		$Anim.play("MoveDown")
		$Sprite.flip_h = false
	elif input_dir.x == -1 and input_dir.y == 1:
		$Anim.play("MoveDown")
		$Sprite.flip_h = false
	else:
		if $Anim.current_animation != "Idle" or not $Anim.is_playing():
			$Anim.play("Idle")
			$Sprite.speed_scale = 0.1
		
	if move_x != 0 and move_y != 0:
		move_x /= 1.5
		move_y /= 1.5
		
	move_and_slide(Vector2(move_x, move_y), Vector2())
	
func set_vehicle(v : Vehicle) -> void:
	vehicle = v
	
func disable_player():
	visible = false
	$Collision.disabled = true
	
func enable_player(pos : Vector2):
	position = pos
	visible = true
	$Collision.disabled = false