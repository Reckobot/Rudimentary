#version 330 compatibility
#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/buffers.glsl"

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
in vec4 at_tangent;
out mat3 tbnmatrix;

out vec2 normaltex;

flat out int nonPerspective;

void main() {
	vec4 viewPos = vec4(gl_ModelViewMatrix * gl_Vertex);
	vec4 position = vec4(gl_Vertex);
	if (WARPING_INTENSITY != 0){
		position = vec4(ivec4(position*(32/WARPING_INTENSITY)));
	}

	if (length(viewPos) > 2){
		nonPerspective = 1;
	}else{
		nonPerspective = 0;
	}

	gl_Position = gl_ModelViewProjectionMatrix * position;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	normaltex = texcoord;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	normal = gl_NormalMatrix * gl_Normal;

	vec3 tangent = mat3(gbufferModelViewInverse) * normalize(gl_NormalMatrix * at_tangent.xyz);
	vec3 bitangent = mat3(gbufferModelViewInverse) * normalize(cross(tangent, normal) * at_tangent.w);
	normal = mat3(gbufferModelViewInverse) * normal;
	tbnmatrix = mat3(tangent, bitangent, normal);
}