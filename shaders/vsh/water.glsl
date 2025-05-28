#version 330 compatibility
#include "/lib/common.glsl"

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;

void main() {
	#ifdef VERTEX_SNAPPING
		vec4 viewPos = vec4(gl_ModelViewMatrix * gl_Vertex);
		vec4 position = viewPos;
		if (DISTORTION != 0){
			position = vec4(ivec4(viewPos*(24/(DISTORTION))));
		}
		gl_Position = gl_ProjectionMatrix * position;
	#else
		gl_Position = ftransform();
	#endif

	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	lmcoord = (lmcoord * 33.05 / 32.0) - (1.05 / 32.0);
	#ifndef SHADING
		lmcoord = pow(lmcoord, vec2(2.1));
	#endif
	glcolor.rgb = gl_Color.rgb;
	#ifdef AMBIENT_OCCLUSION
		glcolor.rgb *= clamp(pow(pow(gl_Color.a, 1.1), AMBIENT_OCCLUSION_STRENGTH), 0.0, 1.0);
	#endif
	normal = gl_NormalMatrix * gl_Normal;
	normal = mat3(gbufferModelViewInverse) * normal;
}