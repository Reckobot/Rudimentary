#version 330 compatibility
#include "/lib/uniforms.glsl"
#include "/lib/buffers.glsl"

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
in vec4 at_tangent;
out mat3 tbnmatrix;

void main() {
	vec4 position = vec4(gl_Vertex)/1.1;
	vec3 viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	float dist = 0.3 + length(viewPos)/1024;

	for (int i = 0; i < 4; i++){
		bool roundDown;

		if (int(position[i]) == floor(position[i])){
			roundDown = true;
		}else{
			roundDown = false;
		}

		if (roundDown){
			float diff = abs(position[i] - floor(position[i]));
			if(diff < dist){
				position[i] = mix(position[i], floor(position[i]), diff/1);
			}
		}else{
			float diff = abs(position[i] - ceil(position[i]));
			if(diff < dist){
				position[i] = mix(position[i], ceil(position[i]), diff/1);
			}
		}
	}

	gl_Position = gl_ModelViewProjectionMatrix * position;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	normal = gl_NormalMatrix * gl_Normal;

	vec3 tangent = mat3(gbufferModelViewInverse) * normalize(gl_NormalMatrix * at_tangent.xyz);
	vec3 bitangent = mat3(gbufferModelViewInverse) * normalize(cross(tangent, normal) * at_tangent.w);
	normal = mat3(gbufferModelViewInverse) * normal;
	tbnmatrix = mat3(tangent, bitangent, normal);
}