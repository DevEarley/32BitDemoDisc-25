extends CanvasLayer
@export var enabled:bool = false
const FREQ_MAX = 11050.0
const MIN_DB = 60

# different types of props that dance to the music
# when the music is really loud - make the shed bump
# when the music is loud at the low end, make the bigger bushes and props dance
# when the music is loud at the high end, make smaller props dance.
# normalize the "bump" at both ends and make special props dance.
@export var TEMPO = 60;
var BPM = 60
@export var LARGEST_PROPS_FOR_AVERAGED:Array[MeshInstance3D] = []
@export var LARGE_PROPS_FOR_LOW_END :Array[MeshInstance3D]= []
@export var SMALL_PROPS_FOR_HIGH_END :Array[MeshInstance3D]= []
@export var SPECIAL_PROPS_FOR_AVERAGED:Array[MeshInstance3D] = []
@export var ANIMATED_LARGEST_PROPS_FOR_AVERAGED :Array[AnimationPlayer]= []
@export var ANIMATED_LARGE_PROPS_FOR_LOW_END  :Array[AnimationPlayer]= []
@export var ANIMATED_SMALL_PROPS_FOR_HIGH_END  :Array[AnimationPlayer]= []
@export var ANIMATED_SPECIAL_PROPS_FOR_AVERAGED  :Array[AnimationPlayer]= []

var SAMPLE_COUNT = 4

var spectrum: AudioEffectInstance

var ANIMATION_SPEED = 0.1
var MAX_VALUES = []
var MIN_VALUES = []
var RAW_SAMPLE_DATA = []

var AVERAGE_ENERGY = 0
var LOUD_ENERGY_THRESHOLD_FOR_LARGEST = 0.2
var MIDDLE_ENERGY_THRESHOLD_FOR_SPECIAL = 0.01
var MIDDLE_ENERGY_THRESHOLD_FOR_SMALL = 0.01
var LOUD_ENERGY_THRESHOLD_FOR_LARGE = 0.02

func _ready():

	spectrum = AudioServer.get_bus_effect_instance(0, 0)
	MIN_VALUES.resize(SAMPLE_COUNT)
	MAX_VALUES.resize(SAMPLE_COUNT)
	MIN_VALUES.fill(0.0)
	MAX_VALUES.fill(0.0)
func _process(delta):
	if(enabled==false):return
	RAW_SAMPLE_DATA = []
	capture_samples();
	lerp_to_new_values();
	update_average_values()
	update_largest_props();
	update_large_props();
	update_small_props();
	update_special_props();

func update_average_values():
	var total = 0.0;
	for value in RAW_SAMPLE_DATA:
		total += value
	AVERAGE_ENERGY = total / RAW_SAMPLE_DATA.size()

func update_largest_props():
	var energy_difference = AVERAGE_ENERGY - LOUD_ENERGY_THRESHOLD_FOR_LARGEST
	var target = 0
	if(energy_difference > 0):
		var max_difference = 1 - LOUD_ENERGY_THRESHOLD_FOR_LARGEST
		target = energy_difference/max_difference
	for prop:Node3D in LARGEST_PROPS_FOR_AVERAGED:
		scale_and_shift_prop(prop,target)
	for prop:AnimationPlayer in ANIMATED_LARGEST_PROPS_FOR_AVERAGED:
		if(target>0 ):
			prop.play("bump")
			prop.speed_scale = TEMPO / BPM
		else:
			prop.play("idle")

func update_large_props():
	# Props bump "individually" but then bump all together if the avg. energy is high enough.
	var are_bumping_together = AVERAGE_ENERGY > LOUD_ENERGY_THRESHOLD_FOR_LARGE
	var low_end_index = 0
	for prop:MeshInstance3D in LARGE_PROPS_FOR_LOW_END:
		if(are_bumping_together):
			scale_and_shift_prop(prop,1)
		else:
			var sample = RAW_SAMPLE_DATA[low_end_index]
			scale_and_shift_prop(prop,sample)
		low_end_index+=1
	low_end_index = 0
	for prop:AnimationPlayer in ANIMATED_LARGE_PROPS_FOR_LOW_END:
		if(are_bumping_together):
			prop.play("bump")
			prop.speed_scale = TEMPO / BPM
		else:
			prop.play("idle")


func update_small_props():
	# do the "wave" and have props only aninmate in order.
	var high_end_index =  SAMPLE_COUNT - SMALL_PROPS_FOR_HIGH_END.size()
	for prop:Node3D in SMALL_PROPS_FOR_HIGH_END:
		var sample = RAW_SAMPLE_DATA[high_end_index]
		scale_and_shift_prop(prop,sample)
		high_end_index+=1
	high_end_index =  SAMPLE_COUNT - ANIMATED_SMALL_PROPS_FOR_HIGH_END.size()
	for prop:AnimationPlayer in ANIMATED_SMALL_PROPS_FOR_HIGH_END:
		var sample = RAW_SAMPLE_DATA[high_end_index]
		high_end_index+=1


func update_special_props():
	var energy_difference = AVERAGE_ENERGY - MIDDLE_ENERGY_THRESHOLD_FOR_SPECIAL
	var target = 0
	if(energy_difference >0):
		var max_difference = 1 - MIDDLE_ENERGY_THRESHOLD_FOR_SPECIAL
		target = energy_difference/max_difference

	for prop:Node3D in SPECIAL_PROPS_FOR_AVERAGED:

		scale_and_shift_prop(prop,target)

	for prop:AnimationPlayer in ANIMATED_SPECIAL_PROPS_FOR_AVERAGED:
		if(energy_difference >0):
			prop.play("bump")
			prop.speed_scale = TEMPO / BPM
		else:
			prop.play("idle")

func scale_and_shift_prop(prop,sample):
	prop.scale = Vector3.ONE
	var original_height = prop.get_aabb().size.y
	prop.scale = lerp(prop.scale, Vector3.ONE + Vector3(0,sample*4.0,0),ANIMATION_SPEED)
	var height = prop.get_aabb().size.y*prop.scale.y
	prop.global_position.y = (height - original_height)

func capture_samples():
	var prev_hz = 0
	for i in range(1, SAMPLE_COUNT + 1):
		var hz = i * FREQ_MAX / SAMPLE_COUNT
		var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		RAW_SAMPLE_DATA.append(energy)
		prev_hz = hz

func lerp_to_new_values():
	for i in range(SAMPLE_COUNT):
		if RAW_SAMPLE_DATA[i] > MAX_VALUES[i]:
			MAX_VALUES[i] = RAW_SAMPLE_DATA[i]
		else:
			MAX_VALUES[i] = lerp(MAX_VALUES[i], RAW_SAMPLE_DATA[i], ANIMATION_SPEED)
		if RAW_SAMPLE_DATA[i] <= 0.0:
			MIN_VALUES[i] = lerp(MIN_VALUES[i], 0.0, ANIMATION_SPEED)
