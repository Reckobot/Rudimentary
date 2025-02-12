#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/settings.glsl"

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;

flat out int isTintedAlpha;
flat out int isEntityShadow;
flat out int isLeaves;
flat out int isGrass;
out float tintSaturation;

uniform int entityId;

in vec2 mc_Entity;
uniform vec4 entityColor;

void main() {
	vec4 viewPos = vec4(gl_ModelViewMatrix * gl_Vertex);
	vec4 position = viewPos;
	#ifdef ENTITY_DISTORTION
		if (DISTORTION != 0){
			position = vec4(ivec4(viewPos*(24/(DISTORTION))));
		}
	#endif
	gl_Position = gl_ProjectionMatrix * position;
	if (entityId == 100){
		isEntityShadow = 1;
	}else{
		isEntityShadow = 0;
	}
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	normal = gl_NormalMatrix * gl_Normal;
	normal = mat3(gbufferModelViewInverse) * normal;

	if ((mc_Entity.x >= 100)&&(mc_Entity.x <= 102)){
		isTintedAlpha = 1;
	}else{
		isTintedAlpha = 0;
	}

	if (mc_Entity.x == 101){
		tintSaturation = 1.0;
	}else{
		tintSaturation = 1.7;
	}

	if (mc_Entity.x != 100){
		isLeaves = 1;
	}else{
		isLeaves = 0;
	}

	if (mc_Entity.x == 102){
		isGrass = 1;
	}else{
		isGrass = 0;
	}

	glcolor.rgb = mix(glcolor.rgb, entityColor.rgb*4, entityColor.a);
}