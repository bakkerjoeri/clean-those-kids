shader_type canvas_item;
uniform float screen_width = 320f;
uniform float screen_height = 180f;
uniform float ratio = 3.14f;
uniform vec2 center_pos = vec2(0.3, 0.5);

uniform float size = 0.1f;
uniform float strength = 0.7f;
void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;	
	vec3 c2 = textureLod(SCREEN_TEXTURE, uv+(center_pos-uv)*size, 0.0).rgb;	
	float dist = strength - 0.4f * sqrt(sqrt(pow(uv.x - center_pos.x,2)*ratio + pow(uv.y - center_pos.y, 2)));
	dist = max(0,dist);
	COLOR.rgb = c*(1.0f-dist/2f) + c2*dist;
	
}
