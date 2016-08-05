#pragma once

// Standard libraries
#include <vector>
#include <string>

// Third party
#include <GL\glew.h>

// My stuff
#include "GlobalConstants.h"

using namespace std;
// Loads a texture and returns the GLuint generated
GLuint My_GenerateTexture();

// Loads a texture from a file and returns GLuint to it
GLuint My_LoadTexture(const char* p_fileName);

struct ShaderInfo
{
	ShaderInfo(GLenum p_shaderType, string p_fileName)
		:shaderType(p_shaderType), fileName(p_fileName) {}

	GLenum shaderType;
	string fileName;
};
// Creates a shader program and returns the GLuint generated
GLuint My_CreateShaderprogram(vector<ShaderInfo> p_programShaders);

/* Creates a hardcoded square in screenspace. 
The purpose is to draw the result of the raytrace on this surface.
p_programHandle is the handle for the output draw program.*/
void My_DEBUGDrawSurfaceVBCreation(GLuint p_programHandle);
