extends GStructure

class_name GTurret

enum State {
	SLEEP, # Dormido, no hace nada
	PATROL, # Vigilando, dependera de algunas torretas si pueden vigilar o no
	TRACK, # Busca y apunta al jugador dentro del DetectArea
	SHOOT, # Cuando dispara
	DESTROYED
}
var state = State.SLEEP
var current_state = State.SLEEP

# Puede recibir daño ?
#var can_damage = true

# Contiene la data
var data : TZDStructure

signal state_changed

func _init():
	data = TZDStructure.new()
	
# Esta funcion es una forma segura de cambiar entre estados.
func change_state(state):
	self.state = state
	self.current_state = state
	emit_signal("state_changed")

# Cuando recive daño
# Si no puede recivir daño talves tambien pueda lanzar
# una animación de invulnerabilidad - TODO
func damage(amount, who_damage = null):
	if is_mark_to_destroy : return

	if $Anim2.has_animation("damage"):
		$Anim2.play("damage")
	if $Pivot/RotatorAnim.has_animation("damage"):# Animamos tambien el Rotator
		$Pivot/RotatorAnim.play("damage")

	data.damage(amount, who_damage)
	.damage(amount, who_damage)

func detect():
	if is_mark_to_destroy : return
	if $Anim.has_animation("detect"):
		$Anim.play("detect")
	if $Pivot/RotatorAnim.has_animation("detect"):
		$Pivot/RotatorAnim.play("detect")

# Golpe al jugador
func shoot():
	if is_mark_to_destroy : return
	if $Anim.has_animation("shoot"):
		$Anim.play("shoot")
	if $Pivot/RotatorAnim.has_animation("shoot"):
		$Pivot/RotatorAnim.play("shoot")

func spawn():
	if $Anim.has_animation("spawn"):
		$Anim.play("spawn")

# Equivalente a Morir
func destroy():
	if $Anim.has_animation("destroy"):
		$Anim.connect("animation_finished", self, "_on_destroy_animation_end")
		$Anim.play("destroy")
	else:
		queue_free()

func _on_destroy_animation_end(anim_name):
	if anim_name == "destroy":
		queue_free()
