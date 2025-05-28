#version 330 compatibility

uniform sampler2D colortex0;

in vec2 texcoord;
flat in int isGrass;

/* RENDERTARGETS: 0,1 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 grass;

void main() {
	color = texture(colortex0, texcoord);

	if(color.a < 0.1) {
		discard;
	}

	grass = vec4(vec3(isGrass), 1.0);
}