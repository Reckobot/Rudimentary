#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/settings.glsl"

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;

flat out int isWater;

in vec2 mc_Entity;
in vec2 mc_midTexCoord;

void main() {
	vec4 modelPos = gl_Vertex;
	vec4 viewPos = vec4(gl_ModelViewMatrix * modelPos);
	vec4 worldPos = gbufferModelViewInverse * viewPos;
	worldPos.xyz += cameraPosition;
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

		#ifdef WAVY_WATER
			vec2 halfSize = abs((texcoord) - mc_midTexCoord);
			vec4 textureBounds = vec4(mc_midTexCoord.xy - halfSize, mc_midTexCoord.xy + halfSize);
			texcoord -= pNoise(worldPos.xz + (frameTimeCounter-18000), 1, 5)*0.005;
			texcoord = clamp(texcoord, textureBounds.xy, textureBounds.zw);
		#endif
	}else{
		isWater = 0;
	}

	float ogY = gl_Position.y;
}