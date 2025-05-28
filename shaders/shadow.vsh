#version 330 compatibility
#include "/lib/common.glsl"

out vec2 texcoord;

in vec2 mc_Entity;
flat out int isGrass;

void main() {
	if(mc_Entity.y == 1) {
		return;
	}

	gl_Position = ftransform();
	gl_Position.xyz = distortShadowClipPos(gl_Position.xyz);
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	if(mc_Entity.x == 102) {
		isGrass = 1;
	} else {
		isGrass = 0;
	}
}