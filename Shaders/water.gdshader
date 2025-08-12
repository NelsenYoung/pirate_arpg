shader_type spatial;

uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform vec2 wave_direction = vec2(2.0, 0.0);
uniform vec2 wave_direction2 = vec2(0.0, 1.0);
uniform float time_scale : hint_range(0.0, 10, 0.005) = 0.025;
uniform float noise_scale = 10.0;

varying vec3 world_pos;
uniform vec4 wave1 = vec4(1.0, 0.0, 0.5, 2.0);
uniform vec4 wave2 = vec4(0.0, 1.0, 0.25, 4.0);
varying vec3 tangent;
varying vec3 binormal;
//uniform float wavelength = 10;
uniform vec2 direction = vec2(1.0, 0.0);

float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

vec3[3] gerstnerWave(vec4 wave, vec3 p){
	float steepness = wave.z;
	float wavelength = wave.w;
	float k = 0.5 * PI / wavelength;
	float c = sqrt(2.0 / k);
	vec2 d = normalize(wave.xy);
	float f = k * (dot(d, p.xz) - c * TIME);
	float a = steepness / k;
	vec3 t = vec3(1.0 - d.x * d.x * (steepness * sin(f)), d.x * (steepness * cos(f)), -d.x * d.y * (steepness * sin(f)));
	vec3 b = vec3(-d.x * d.y * (steepness * sin(f)), d.y * (steepness * cos(f)), 1.0 - d.y * d.y * (steepness * sin(f)));
	vec3 result[3];
	result[0] = vec3(d.x * (a * cos(f)), a * sin(f), d.y * (a * cos(f)));
	result[1] = t;
	result[2] = b;
	return result;
}

void vertex() {
	tangent = vec3(1.0, 0.0, 0.0);
	binormal = vec3(0.0, 0.0, 1.0);
	// get the position of the vertex
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// Wave 1
	vec3[3] w1 = gerstnerWave(wave1, world_pos);
	VERTEX += w1[0];
	tangent += w1[1];
	binormal += w1[2];

	// Wave 2
	vec3[3] w2 = gerstnerWave(wave2, world_pos);
	VERTEX += w2[0];
	tangent += w2[1];
	binormal += w2[2];

	// Adjust the normals
	vec3 normal = normalize(cross(binormal, tangent));
	NORMAL = normal;
}

void fragment() {

	vec2 time = (TIME * wave_direction) * time_scale;
	vec2 time2 = (TIME * wave_direction2) * time_scale;

	vec3 normal = mix(texture(texture_normal, world_pos.xz + time).rgb, texture(texture_normal2, world_pos.xz + time2).rgb, 0.5);

	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(albedo, albedo2, fresnel);

	ALBEDO = surface_color;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
