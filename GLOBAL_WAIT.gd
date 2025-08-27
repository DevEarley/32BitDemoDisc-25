extends Node

var current_timers=[];

func _input(event:InputEvent):
	if(event.is_action_released("ui_select")):
		for timer:Timer in current_timers:
			timer.emit_signal("timeout")

func get_current_timers()->int:
	return current_timers.size()

func for_seconds(seconds: float,skippable=false) -> void: #unskippable
	var current_timer = Timer.new()
	add_child(current_timer)
	if(skippable):
		current_timers.push_back(current_timer);
	current_timer.start(seconds)
	await current_timer.timeout
	if(skippable):
		current_timers.erase(current_timer);
	current_timer.queue_free()

func for_animation(Animation_Player:AnimationPlayer) -> void:
	var current_timer = Timer.new()
	add_child(current_timer)
	current_timers.push_back(current_timer);
	current_timer.start(Animation_Player.current_animation_length)
	await current_timer.timeout
	current_timers.erase(current_timer);
	current_timer.queue_free()
