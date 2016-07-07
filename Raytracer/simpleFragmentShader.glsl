#version 430
uniform sampler2D sourceTexture;
in vec2 texCoord;
out vec4 color;
void main() 
{
	float c = texture(sourceTexture, texCoord).x;
	// color = vec4(0, 1.0, 0, 1.0);
	color = texture(sourceTexture, texCoord);
}