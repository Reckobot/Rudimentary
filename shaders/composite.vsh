#version 330 compatibility
#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"

out vec2 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy * RESOLUTION;
}