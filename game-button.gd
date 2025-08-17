extends Button
@export var CURRENT_GAME_BOX:Control;
@export var game:Game;
func _ready():
	self.connect("focus_entered",on_focus_entered);
	self.connect("focus_exited",on_focus_exit);
	self.connect("mouse_entered",on_mouse_entered);
	self.connect("mouse_exited",on_mouse_exited);
	self.connect("pressed",on_click);

func on_focus_entered():
	pass

func on_focus_exit():
	pass

func on_mouse_entered():
	pass

func on_mouse_exited():
	pass

func on_click():
	OS.shell_open(game.url)
