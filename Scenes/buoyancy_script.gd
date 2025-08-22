extends RigidBody3D

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity: float = ProjectSettings.get_setting('physics/3d/default_gravity')
@onready var probes = $ProbeContainer.get_children()

var submerged := false
var time: float
const PI_HALF := PI * 0.5

# Example use in _process to simulate vertex displacement
@export var wave1 := Vector4(1.0, 0.0, 0.01, 0.5)
@export var wave2 := Vector4(0.0, 1.0, 0.008, 1.0)
@export var water_level_y := 0.0
# Gerstner wave function in GDScript
func gerstner_wave(wave: Vector4, p: Vector3, time: float) -> Vector3:
	var steepness: float = wave.z
	var wavelength: float = wave.w
	var k: float = 0.5 * PI / wavelength
	var c: float = sqrt(2.0 / k)
	var d: Vector2 = Vector2(wave.x, wave.y).normalized()
	var f: float = k * (d.dot(Vector2(p.x, p.z)) - c * time)
	var a: float = steepness / k
	var ans = Vector3(d.x * (a * cos(f)), a * sin(f), d.y * (a * cos(f)))
	return ans

func get_water_height(time: float, world_pos: Vector3) -> float:
	var xz := Vector2(world_pos.x, world_pos.z)
	var y := water_level_y
	y += gerstner_wave(wave1, Vector3(xz.x, y, xz.y), time).y
	y += gerstner_wave(wave2, Vector3(xz.x, y, xz.y), time).y
	return y * 10

func _process(delta: float) -> void:
	time += delta

func _physics_process(delta: float) -> void:
	submerged = false
	var heights := []
	for p in probes:
		var water_height = get_water_height(time, p.global_position)
		var depth = water_height - p.global_position.y
		heights.append(water_height)
		if depth > 0:
			submerged = true
			apply_force(Vector3.UP * float_force * depth * gravity, p.global_position - global_position)
	print("Heights: ", heights)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if submerged:
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag
	

	
	
