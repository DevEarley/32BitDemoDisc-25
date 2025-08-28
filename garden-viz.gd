extends CanvasLayer
@export var enabled:bool = false
const FREQ_MAX = 11050.0
const MIN_DB = 60
var game_button_prefab = preload("res://game_button.tscn")

# different types of props that dance to the music
# when the music is really loud - make the shed bump
# when the music is loud at the low end, make the bigger bushes and props dance
# when the music is loud at the high end, make smaller props dance.
# normalize the "bump" at both ends and make special props dance.
@export var TEMPO = 60;
var BPM = 60
@export var GAME_LIB:GameLib;
@export var DANCE_MAT_FOR_LOW_END:ShaderMaterial
@export var DANCE_MAT_FOR_LOW_MIDS:ShaderMaterial
@export var DANCE_MAT_FOR_MIDS:ShaderMaterial
@export var DANCE_MAT_FOR_HIGH_END:ShaderMaterial

var SAMPLE_COUNT = 4

var spectrum: AudioEffectInstance

var ANIMATION_SPEED =2.0

var MAX_VALUES = []
var MIN_VALUES = []
var RAW_SAMPLE_DATA = []

var AVERAGE_ENERGY = 0

var LOUD_ENERGY_THRESHOLD_FOR_LARGEST = 0.2
var MIDDLE_ENERGY_THRESHOLD_FOR_SPECIAL = 0.01
var MIDDLE_ENERGY_THRESHOLD_FOR_SMALL = 0.01
var LOUD_ENERGY_THRESHOLD_FOR_LARGE = 0.02

enum STATES{
	ON_TITLE_SCREEN,
	ON_BACKYARD_SCREEN,
	IN_SHED,
	CREDITS
	}
var STATE =STATES.ON_TITLE_SCREEN
func on_cancel():
	$GAME_INFO_ANIMATOR.play("hide")
	$Control/GAME_NAME.hide()
	$Control/GAME_DESCRIPTION.hide()
	$Control/LAUNCH_GAME_BUTTON.hide()
	$Control/CANCEL_BUTTON.hide()
	$Control/PAUSE_SONG.hide()
	$Control/TOGGLE_MUTE.hide()
	$Control/MUSIC_SETTINGS.hide()
	$Control/VOLUME_SLIDER.hide()
	$Control/PLAY_SONG.hide()
	$Control/PREVIOUS_SONG.hide()
	$Control/NEXT_SONG.hide()
	$Control/MUSIC_BUTTON.show();

func _ready():

	var button_container = $Control/GAMES/ScrollContainer/HBoxContainer
	$Control/CANCEL_BUTTON.connect("pressed",on_cancel);

	$Control/MUSIC_BUTTON.hide()
	for game:Game in GAME_LIB.Games:
		var child_to_add:GameButton = game_button_prefab.instantiate();
		child_to_add.GAME_INFO_UI = $Control;
		child_to_add.GAME_INFO_MESH = $"Game-info"
		child_to_add.GAME_INFO_ANIMATOR  = $GAME_INFO_ANIMATOR
		child_to_add.GAME = game;
		child_to_add.text = game.game_name
		child_to_add.get_ready()
		button_container.add_child(child_to_add)

	enabled = false
	$Control/MUSIC_BUTTON.connect("pressed",show_music_settings)
	spectrum = AudioServer.get_bus_effect_instance(0, 0)
	MIN_VALUES.resize(SAMPLE_COUNT)
	MAX_VALUES.resize(SAMPLE_COUNT)
	MIN_VALUES.fill(0.0)
	MAX_VALUES.fill(0.0)

func _input(event:InputEvent):
		if(STATE == STATES.ON_TITLE_SCREEN):
			if(event.is_released() && event.is_action_type()):
				STATE = STATES.ON_BACKYARD_SCREEN
				$CAMERA_ANIMATOR.play("logo_out");
				await WAIT.for_seconds(1.0)
				$Control/MUSIC_BUTTON.show()
				enabled = true
				$AudioStreamPlayer.playing=true;
var AVERAGE_FOR_LOW_END = 0;
var AVERAGE_FOR_LOW_MIDS = 0;
var AVERAGE_FOR_MIDS = 0;
var AVERAGE_FOR_HIGH_END = 0;

var SAMPLES_FOR_LOW_END =[0,0,0]
var SAMPLES_FOR_LOW_MIDS =[0,0,0]
var SAMPLES_FOR_MIDS =[0,0,0]
var SAMPLES_FOR_HIGH_END =[0,0,0]

func _process(delta):
	if(enabled==false):return
	RAW_SAMPLE_DATA = []
	capture_samples();
	update_average_values()
	update_low_end()
	update_low_mids()
	update_mids()
	update_high_end()
	#$WORM_ANIMATOR.speed_scale = AVERAGE_ENERGY*AVERAGE_ENERGY*20.0

func show_music_settings():
	$Control/MUSIC_BUTTON.hide()
	$GAME_INFO_ANIMATOR.play("show")
	$Control/VOLUME_SLIDER.show()
	$Control/TOGGLE_MUTE.show()
	$Control/NEXT_SONG.show()
	$Control/MUSIC_SETTINGS.show()
	$Control/PREVIOUS_SONG.show()
	$Control/PLAY_SONG.show()
	$Control/PAUSE_SONG.show()
	$Control/CANCEL_BUTTON.show()

func update_low_end():
	SAMPLES_FOR_LOW_END.insert(0, RAW_SAMPLE_DATA[0])
	SAMPLES_FOR_LOW_END.resize(3)
	var sum_for_low_end = 0
	for value__ in SAMPLES_FOR_LOW_END:
		sum_for_low_end += value__;
	AVERAGE_FOR_LOW_END = sum_for_low_end / 3.0;
	AUDIO_STATE.LOWS = 1.0+AVERAGE_FOR_LOW_END
	DANCE_MAT_FOR_LOW_END.set_shader_parameter("SCALE",AUDIO_STATE.LOWS)

func update_low_mids():
	SAMPLES_FOR_LOW_MIDS.insert(0, RAW_SAMPLE_DATA[1])
	SAMPLES_FOR_LOW_MIDS.resize(3)
	var sum_for_low_mids = 0
	for value__ in SAMPLES_FOR_LOW_MIDS:
		sum_for_low_mids += value__;
	AVERAGE_FOR_LOW_MIDS = sum_for_low_mids / 3.0;

	AUDIO_STATE.LOW_MIDS = 1.0+AVERAGE_FOR_LOW_MIDS
	DANCE_MAT_FOR_LOW_MIDS.set_shader_parameter("SCALE",AUDIO_STATE.LOW_MIDS )


func update_mids():
	SAMPLES_FOR_MIDS.insert(0, RAW_SAMPLE_DATA[2])
	SAMPLES_FOR_MIDS.resize(3)
	var sum_for_mids = 0
	for value__ in SAMPLES_FOR_MIDS:
		sum_for_mids += value__;
	AVERAGE_FOR_MIDS = sum_for_mids / 3.0;
	AUDIO_STATE.MIDS = 1.0+AVERAGE_FOR_MIDS
	DANCE_MAT_FOR_MIDS.set_shader_parameter("SCALE",AUDIO_STATE.MIDS )

func update_high_end():
	SAMPLES_FOR_HIGH_END.insert(0, RAW_SAMPLE_DATA[3])
	SAMPLES_FOR_HIGH_END.resize(3)
	var sum_for_high_end = 0
	for value__ in SAMPLES_FOR_HIGH_END:
		sum_for_high_end += value__;
	AVERAGE_FOR_MIDS = sum_for_high_end / 3.0;
	AUDIO_STATE.HIGHS = 1.0+AVERAGE_FOR_HIGH_END
	DANCE_MAT_FOR_HIGH_END.set_shader_parameter("SCALE",AUDIO_STATE.HIGHS)


func toggle_music():
	enabled = !enabled
	$AudioStreamPlayer.playing = enabled;


func update_average_values():
	var total = 0.0;
	for value in RAW_SAMPLE_DATA:
		total += value
	AVERAGE_ENERGY = total / RAW_SAMPLE_DATA.size()
	AUDIO_STATE.AVERAGE_ENERGY = AVERAGE_ENERGY;

	#for prop:AnimationPlayer in ANIMATED_SPECIAL_PROPS_FOR_AVERAGED:
		#if(energy_difference >0):
			#prop.play("bump")
			#prop.speed_scale = TEMPO / BPM
		#else:
			#prop.play("idle")



func capture_samples():
	var prev_hz = 0
	for i in range(1, SAMPLE_COUNT + 1):
		var hz = i * FREQ_MAX / SAMPLE_COUNT
		var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		RAW_SAMPLE_DATA.append(energy)
		prev_hz = hz

#func lerp_to_new_values():
	#for i in range(SAMPLE_COUNT):
		#if RAW_SAMPLE_DATA[i] > MAX_VALUES[i]:
			#MAX_VALUES[i] = RAW_SAMPLE_DATA[i]
		#else:
			#MAX_VALUES[i] = lerp(MAX_VALUES[i], RAW_SAMPLE_DATA[i], ANIMATION_SPEED)
		#if RAW_SAMPLE_DATA[i] <= 0.0:
			#MIN_VALUES[i] = lerp(MIN_VALUES[i], 0.0, ANIMATION_SPEED)
