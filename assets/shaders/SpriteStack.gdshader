shader_type canvas_item;

uniform float depth = 0.0;

void vertex() {
	float scale = 1.0 + depth * abs(VERTEX.y);
	//VERTEX.x += 8.0;
	VERTEX.x += scale;
	//VERTEX.x -= 8.0;
}