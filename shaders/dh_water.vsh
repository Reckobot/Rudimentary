#version 330 compatibility
#include "/lib/common.glsl"

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
out vec3 viewPos;

flat out int isEntityShadow;

uniform int entityId;

in vec2 mc_Entity;

void main() {
	gl_Position = ftransform();
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

    vec3 vPos = gl_Vertex.xyz;
    vec3 cameraOffset = fract(cameraPosition);
    vPos = floor(vPos + cameraOffset + 0.5) - cameraOffset;
    viewPos = (mat3(gl_ModelViewMatrix) * vPos);
}