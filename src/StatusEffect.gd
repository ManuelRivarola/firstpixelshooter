extends Node

class_name StatusEffect

enum Effects {
	NOTHING,
	REGENERATION,
	HASTE,
	SLOW,
	STRENGTH,
	RESISTANCE
}

var target: Node3D
var power: float
var revert: bool # Controla si hay que revertir el efecto al finalizar la duracion
var effect: Effects
var duration_timer: Timer
var interval_timer: Timer

func _init(
	target: Node3D,
	effect: Effects = Effects.NOTHING, 
	duration: float = 0.0,
	interval: float = 0.0,
	power: float = 0.0
	):
	
	self.effect = effect
	self.target = target
	self.power = power
	self.revert = false
	print("Initializing!")
	if duration == 0.0: # Efecto instantáneo
		apply_effect()
	elif duration > 0.0: # Efecto finito
		duration_timer = _make_timer(duration, true)
		duration_timer.connect("timeout", _on_duration_timeout)
	if interval > 0.0:
		interval_timer = _make_timer(interval, false)
		interval_timer.connect("timeout", _on_interval_timeout)
	
	if effect == Effects.REGENERATION:
		revert = false
	
	duration_timer.start()
	interval_timer.start()
	
func _make_timer(duration: float, one_shot: bool) -> Timer:
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = one_shot
	timer.autostart = false
	GlobalLevel.level_root.add_child(timer)
	
	return timer
	
func regeneration(duration: float, interval: float, power: float):
	var duration_timer = _make_timer(duration, true)
	var interval_timer = _make_timer(interval, false)
	
	duration_timer.connect("timeout", _on_duration_timeout)
	interval_timer.connect("timeout", _on_interval_timeout)

func apply_effect():
	if effect == Effects.REGENERATION:
		if target.has_method("heal"):
			target.heal(int(power))

func end_effect():
	duration_timer.queue_free()
	interval_timer.queue_free()
	queue_free()

func _on_duration_timeout():
	end_effect()
	
func _on_interval_timeout():
	apply_effect()
