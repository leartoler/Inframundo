//Apuntes: https://www.evernote.com/shard/s474/sh/3b246d44-c132-6ed7-8061-2456b1b517c4/057aefb9cd8401ac7053f06a5b6460b5
//https://www.evernote.com/shard/s474/sh/ad34c078-e964-462d-898e-803a1c2a81f3/6977caa707b344e0f4d4d9ea0a07e23e

shader_type canvas_item;

uniform vec3 color = vec3(0.33, 0.20, 0.85);
uniform int OCTAVES = 4;
float rand(vec2 coord)
{
	return fract(sin(dot(coord, vec2(56,78)) * 1000.0) * 1000.0);
}

float noise(vec2 coord)
{
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));
	
	vec2 cubic = f * f * (3.0 - 2.0 * f);
	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;	 
}

float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.5;
	
	for(int i = 0; i < OCTAVES; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

void fragment()
{
	vec2 coord = UV * 20.0;
	vec2 motion = vec2(fbm(coord + vec2(TIME * -0.5, TIME * 0.5)));
	float final = fbm(coord + motion);
	
	COLOR = vec4(color, final * 0.6);
}