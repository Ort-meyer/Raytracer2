// This file's header
#include "GraphicsHelper.h"

// Standard libraries
#include <iostream>
#include <fstream>
#include <string>

// Third party libraries
#include <Soil\SOIL.h>

using namespace std;

// "Private" help methods
string ReadShader(const char* p_fileName)
{
	//FILE* t_file;
	//fopen_s(&t_file, p_fileName, "rb");
	//if (!t_file)
	//{
	//	cout << "Error opening file " << p_fileName << endl;
	//	return NULL;
	//}

	//fseek(t_file, 0, SEEK_END);
	//int t_fileLength = ftell(t_file);
	//fseek(t_file, 0, SEEK_SET);

	//char* t_source = new char[t_fileLength + 1];
	//fread(t_source, 1, t_fileLength, t_file);
	//fclose(t_file);

	//t_source[t_fileLength] = 0;

	//return const_cast<const char*>(t_source);

	ifstream t_infile{ p_fileName };
	string t_fileString{ istreambuf_iterator<char>(t_infile), istreambuf_iterator<char>() };
	return t_fileString;
}



GLuint My_GenerateTexture()
{
	GLuint t_textureHandle;
	glGenTextures(1, &t_textureHandle);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, t_textureHandle);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, g_windowWidth, g_windowheight, 0, GL_RGBA, GL_FLOAT, NULL);
	//glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, 512, 512, 0, GL_RGBA, GL_FLOAT, NULL);

	//glBindImageTexture(0, t_textureHandle, 0, GL_FALSE, 0, GL_WRITE_ONLY, GL_RGBA32F);

	return t_textureHandle;
}

GLuint My_LoadTexture(const char* p_fileName)
{
	GLuint t_texture = SOIL_load_OGL_texture(p_fileName, SOIL_LOAD_RGBA, SOIL_CREATE_NEW_ID, SOIL_FLAG_MIPMAPS | SOIL_FLAG_INVERT_Y | SOIL_FLAG_NTSC_SAFE_RGB | SOIL_FLAG_COMPRESS_TO_DXT);
	return t_texture;
}


GLuint My_CreateShaderprogram(vector<ShaderInfo> p_programShaders)
{
	GLuint t_programHandle = glCreateProgram();
	for (size_t i = 0; i < p_programShaders.size(); i++)
	{
		// Create and load the shader
		GLuint t_shader = glCreateShader(p_programShaders[i].shaderType);
		
		// p_programShaders[i].shaderHandler = t_shader; // Possibly needed in the future
		
		string t_shaderText = ReadShader(p_programShaders[i].fileName.c_str());
		//if (!t_shaderText)
		//{
		//	return 0;
		//}
		// Compile it
		const GLchar* t_shaderTextChar = t_shaderText.c_str();
		glShaderSource(t_shader, 1, &t_shaderTextChar, NULL);
		glCompileShader(t_shader);
		// Verify it worked
		GLint t_compiled;
		glGetShaderiv(t_shader, GL_COMPILE_STATUS, &t_compiled);
		if (!t_compiled)
		{
			GLsizei t_len;
			glGetShaderiv(t_shader, GL_INFO_LOG_LENGTH, &t_len);

			GLchar* t_log = new GLchar[t_len + 1];
			glGetShaderInfoLog(t_shader, t_len, &t_len, t_log);
			cout << "Shader compilation failed: " << t_log << endl;

			return 0;
		}

		glAttachShader(t_programHandle, t_shader);
	}

	// All shaders loaded and attached. Link it together
	glLinkProgram(t_programHandle);

	// Verify it worked
	GLint t_linked;
	glGetProgramiv(t_programHandle, GL_LINK_STATUS, &t_linked);
	if (!t_linked) 
	{
		GLsizei t_len;
		glGetProgramiv(t_programHandle, GL_INFO_LOG_LENGTH, &t_len);
		GLchar* t_log = new GLchar[t_len + 1];
		glGetProgramInfoLog(t_programHandle, t_len, &t_len, t_log);
		cout << "Shader linking failed: " << t_log << endl;
		return 0;
	}

	return t_programHandle;
}

void My_DEBUGDrawSurfaceVBCreation(GLuint p_programHandle)
{
	GLuint t_positionBuffer;
	glGenBuffers(1, &t_positionBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, t_positionBuffer);
	// Hardcoded square
	float t_data[] = {
		-1.0f, -1.0f,
		-1.0f, 1.0f,
		1.0f, -1.0f,
		1.0f, 1.0f
	};
	glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 8, t_data, GL_STREAM_DRAW);
	GLint t_positionUniformHandle = glGetAttribLocation(p_programHandle, "pos");
	glVertexAttribPointer(t_positionUniformHandle, 2, GL_FLOAT, GL_FALSE, 0, 0);
	glEnableVertexAttribArray(t_positionUniformHandle);
}