#version 430
layout (binding = 0) uniform sampler2D sourceTexture;
//layout (binding = 1) uniform sampler2D secondTexture;
in vec2 texCoord;
out vec4 color;
void main() 
{
	float c = texture(sourceTexture, texCoord).x;
	color = texture(sourceTexture, texCoord);
}