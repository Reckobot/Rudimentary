#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/settings.glsl"

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;

flat out int isWater;

in vec2 mc_Entity;

void main() {
	vec4 viewPos = vec4(gl_ModelViewMatrix * gl_Vertex);
	vec4 position = viewPos;
	if (DISTORTION != 0){
		position = vec4(ivec4(viewPos*(24/(DISTORTION))));
	}

	gl_Position = gl_ProjectionMatrix * position;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	normal = gl_NormalMatrix * gl_Normal;
	normal = mat3(gbufferModelViewInverse) * normal;

	if (mc_Entity.x == 200){
		isWater = 1;
	}else{
		isWater = 0;
	}
}