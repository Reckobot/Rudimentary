#version 330 compatibility
#include "/lib/common.glsl"

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;

flat out int isTintedAlpha;

in vec2 mc_Entity;

void main() {
	vec4 offset = gl_Vertex;
	offset.y += CLOUD_OFFSET;
	gl_Position = gl_ModelViewProjectionMatrix * (offset);
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	normal = gl_NormalMatrix * gl_Normal;
	normal = mat3(gbufferModelViewInverse) * normal;

	if (mc_Entity.x == 100){
		isTintedAlpha = 1;
	}else{
		isTintedAlpha = 0;
	}
}