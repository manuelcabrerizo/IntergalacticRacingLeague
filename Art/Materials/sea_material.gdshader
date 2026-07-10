shader_type spatial;

uniform float metalic: hint_range(0.0, 1.0) = 0;
uniform float roughness: hint_range(0.0, 1.0) = 0.0;

uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D water_texture;
uniform sampler2D wave0;
uniform sampler2D wave1;
uniform sampler2D texture_normal0;
uniform sampler2D texture_normal1;

uniform vec2 wave_direction0 = vec2(0.0, 0.0);
uniform vec2 wave_direction1 = vec2(0.0, 0.0);
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025;
uniform float noise_scale = 10.0;
uniform float height_scale: hint_range(0.0, 500.0) = 0.0;


varying vec3 world_pos;
const float t = 0.5f;

void vertex()
{
	vec2 time0 = (TIME * wave_direction0) * time_scale;
	vec2 time1 = (TIME * wave_direction1) * time_scale;
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float height = mix(
		texture(wave0, world_pos.xz / noise_scale + time0).r,
		texture(wave1, world_pos.xz / noise_scale + time1).r,
		t);
	VERTEX.y += height * height_scale;
}

void fragment()
{
	vec2 time0 = (TIME * wave_direction0) * time_scale;
	vec2 time1 = (TIME * wave_direction1) * time_scale;
	vec3 normal_blend = mix(
		texture(texture_normal0, world_pos.xz / noise_scale + time0).rgb,
	 	texture(texture_normal1, world_pos.xz / noise_scale + time1).rgb,
		t);
		
	ALBEDO = texture(water_texture, UV*10.0).rgb;
	METALLIC = metalic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal_blend;
}