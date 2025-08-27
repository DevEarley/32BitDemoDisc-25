extends Button
class_name GameButton;
@export var GAME:Game;
@export var GAME_INFO_MESH:Node3D;
@export var GAME_INFO_ANIMATOR:AnimationPlayer;
@export var GAME_INFO_UI:Control;

var GAME_NAME;
var GAME_DESCRIPTION
var LAUNCH_GAME_BUTTON
var CANCEL_BUTTON
func get_ready():
	self.connect("focus_entered",on_focus_entered);
	self.connect("focus_exited",on_focus_exit);
	self.connect("mouse_entered",on_mouse_entered);
	self.connect("mouse_exited",on_mouse_exited);
	self.connect("pressed",on_thumbnail_click);
	GAME_NAME = GAME_INFO_UI.get_node("GAME_NAME")
	GAME_DESCRIPTION = GAME_INFO_UI.get_node("GAME_DESCRIPTION")
	LAUNCH_GAME_BUTTON = GAME_INFO_UI.get_node("LAUNCH_GAME_BUTTON")
	CANCEL_BUTTON = GAME_INFO_UI.get_node("CANCEL_BUTTON")

func on_focus_entered():
	#GAME_INFO_ANIMATOR.play("show")
	#GAME_INFO_MESH.show()
	#GAME_NAME.show()
	#GAME_DESCRIPTION.show()
	#GAME_NAME.text = GAME.game_name;
	#GAME_DESCRIPTION.text = GAME.game_description
	pass

func on_focus_exit():
	#GAME_INFO_ANIMATOR.play("hide")
#
	#GAME_NAME.hide()
	#GAME_DESCRIPTION.hide()

	pass

func on_mouse_entered():
	on_focus_entered()
	pass

func on_mouse_exited():
	pass

func on_thumbnail_click():
	GAME_INFO_ANIMATOR.play("hide")
	GAME_NAME.hide()
	GAME_DESCRIPTION.hide()
	LAUNCH_GAME_BUTTON.hide()
	CANCEL_BUTTON.hide()
	await WAIT.for_seconds(0.33)

	GAME_INFO_ANIMATOR.play("show")
	await WAIT.for_seconds(0.33)
	GAME_NAME.text = GAME.game_name;
	GAME_DESCRIPTION.text = GAME.game_description
	GAME_NAME.show()
	GAME_DESCRIPTION.show()
	LAUNCH_GAME_BUTTON.show()
	CANCEL_BUTTON.show()
	LAUNCH_GAME_BUTTON.connect("pressed",on_click);


func on_click():
	OS.shell_open(GAME.url)
