#version 330 compatibility

uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0,12 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 eyeBuffer;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	eyeBuffer = vec4(1.0);
	if (color.a < alphaTestRef) {
		discard;
	}
}