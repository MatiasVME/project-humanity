extends GEnemy

class_name EDogbot

var objective
var objectives := []
var velocity := Vector2.ZERO
export (float) var max_speed := 50.0
export (float) var mass := 2.0

# Puede cambiar de objetivo cada 7 segundos
export (float) var can_change_objective := 7.0
# Tiempo acumulado para cambiar de objetivo
var accum_can_change_objective := 0.0

# Es solo para el area de ataque
var in_attack_area := []
# Cada cuanto tiempo ataca
export (float) var pulse_attack_time := 0.6
# Tiempo acumulado para el proximo ataque
var accum_pulse_attack_time := 0.0

# One time die: Para que muera una sola vez
var ot_die = true

func _ready():
	self.actor_name = "Dogbot"
	
	state = State.STAND
	
	$Body.playing = true
	$DamageDelay.set_wait_time(0.2)
	
	randomize()
	
	data.max_hp = int(round(rand_range(20, 30)))
	data.restore_hp()
	data.xp_drop = 2 # temp
	data.attack = 6
	data.money_drop = int(rand_range(30, 60))
	
	data.connect("dead", self, "_on_dead")
	
func _physics_process(delta):
	if data.is_dead and ot_die:
		ot_die = false
		change_state(State.DIE)
	
	match state:
		State.STAND: state_stand(delta)
		State.SEEKER: state_seeker(delta)
		State.ATTACK: state_attack(delta)
		State.DIE: state_die()

func state_stand(delta):
	accum_can_change_objective += delta
	
	if not $Sprites/AnimIdle.is_playing(): 
		$Sprites/Anims.play("IdleDogbot")
		$Sprites/AttackAndRun.active = false
		
	if is_instance_valid(objective):
		change_state(State.SEEKER)
	elif objectives.size() > 0:
		if accum_can_change_objective >= can_change_objective:
			accum_can_change_objective = 0
			objective = objectives[(objectives.find(objective) + 1) % objectives.size()]
		elif not is_instance_valid(objective):
			objective = objectives[(objectives.find(objective) + 1) % objectives.size()]
	
func state_seeker(delta):
	accum_can_change_objective += delta
	
	if is_instance_valid(objective) and in_attack_area.size() == 0:
		sekeer(objective.global_position, delta)
		
		if not $Sprites/AnimRun.is_playing():
			$Sprites/Anims.play("RunDogbot")
			$Sprites/AttackAndRun.active = false
			
	elif is_instance_valid(objective) and in_attack_area.size() > 0:
		change_state(State.ATTACK)
	else:
		change_state(State.STAND)
	
func state_attack(delta):
	accum_can_change_objective += delta
	
	if is_instance_valid(objective):
		sekeer(objective.global_position, delta)
	
	if in_attack_area.size() > 0:
		if accum_pulse_attack_time >= pulse_attack_time:
			for actor in in_attack_area:
				if is_instance_valid(actor):
					actor.damage(data.attack, self)
				else:
					in_attack_area.erase(actor)
						
					change_state(State.STAND)
					
			accum_pulse_attack_time = 0.0
			
			if not $Sprites/AnimAttack.is_playing():
				$Sprites/Anims.stop()
				$Sprites/AttackAndRun.active = true
		else:
			accum_pulse_attack_time += delta
	else:
		change_state(State.STAND)
	
func state_die():
	print("Mori")

# Rutina en caso de que vea al objetivo
func sekeer(_objective : Vector2, delta):
	$Navigator.time_current += delta
	
	if $Navigator.can_navigate and $Navigator.time_current >= $Navigator.time_to_update_path and state == State.SEEKER:
		$Navigator.update_path(_objective)
	
	if velocity.x > 0:
		if $Sprites.scale.x == 1:
			$Sprites.scale.x = -1
	elif velocity.x < 0:
		if $Sprites.scale.x == -1:
			$Sprites.scale.x = 1
	
	if state == State.SEEKER and $Navigator.can_navigate and not $Navigator.out_of_index:
		var current_point = $Navigator.get_current_point()
		
		if not current_point:
			current_point = _objective
		
		velocity = Steering.follow(
			velocity,
			global_position,
			current_point,
			100.0
		)
		move_and_slide(velocity)
		
		var b_point
		if $Navigator.navigation_path.size() - 1 -$Navigator.current_index < 1 :
			b_point = _objective
		else:
			b_point = $Navigator.navigation_path[$Navigator.current_index + 1]
		
#		print_debug("$Navigator.navigation_path", $Navigator.navigation_path.size())
		
		var AB = b_point.distance_to(current_point)
		var b_dist = global_position.distance_to(b_point)
		if b_dist <= AB:
			$Navigator.next_index()
	else:
		velocity = Steering.follow(
			velocity,
			global_position,
			_objective,
			100.0
		)
		move_and_slide(velocity)
		
#		print_debug("not navigator")

func change_state(_state):
	if _state == State.SEEKER and $Navigator.can_navigate:
		$Navigator.time_current = $Navigator.time_to_update_path
	
#	print_debug("Dogbot State: ", _state)
	
	.change_state(_state)

func _on_dead():
	pass
	
func _on_DetectArea_body_entered(body):
	if body is GPlayer:
		objective = body
		objectives.append(body)
	elif body is EGluton:
		objective = body
		objectives.append(body)

func _on_DetectArea_body_exited(body):
	if body is GPlayer:
		objective = null
		objectives.remove(objectives.find(body))
	elif body is EGluton:
		objective = null
		objectives.remove(objectives.find(body))

func _on_AttackArea_body_entered(body):
	if body is GPlayer:
		in_attack_area.append(body)
	elif body is EGluton:
		in_attack_area.append(body)

func _on_AttackArea_body_exited(body):
	if body is GPlayer:
		in_attack_area.remove(in_attack_area.find(body))
	if body is EGluton:
		in_attack_area.remove(in_attack_area.find(body))

func _on_DamageArea_body_entered(body):
	if body is GBullet:
		.damage(body.damage)

		print_debug("test")