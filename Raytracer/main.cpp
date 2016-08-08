// Standard libraries
#include <iostream>
#include <vector>

// 3rd party libraries
#include <GL\glew.h>
#include <GL\freeglut.h>
#include <glm\glm.hpp>


// My own stuff
#include "GlobalConstants.h"
#include "GraphicsHelper.h"
#include "InputHelper.h"
#include "Camera.h"
#include "World.h"
#include "PointLight.h"
#include "ModelLoader.h"


static int turning = 0;


///////////// Global variables (master main)
/// Textures
// Main texture on which raytrace output is stored
GLuint g_computeOutputHandle;
// Texture for the boxes
GLuint g_cheryl;

/// SSBOs
// ssbo of bth logo
GLuint g_bthSSBO = 0;
GLuint g_textureSSBO = 0;

/// Shader programs
// Used to render the final picture
GLuint g_renderProgramHandle;
// Used to actually compute the frame
GLuint g_computeProgramHandle;

/// Other stuff
Camera* g_camera;
World* g_world;

using namespace std;

/// Methods used to control the program
// Big render method. Where we do all our rendering
void RenderScene()
{
	// Update things
	g_camera->Update();
	g_world->UpdateWorld();

	/// Render things DO COMPUTE THINGIES
	// Start with clearing the screen
	glClear(GL_COLOR_BUFFER_BIT);

	// Start with compute shader
	glUseProgram(g_computeProgramHandle);

	//glUniform1i(glGetUniformLocation(g_computeProgramHandle, "outTex"), 0); // boxTextureSampler

	glActiveTexture(GL_TEXTURE0);
	glBindImageTexture(0, g_computeOutputHandle, 0, GL_FALSE, 0, GL_WRITE_ONLY, GL_RGBA32F);
	glActiveTexture(GL_TEXTURE1);
	glBindImageTexture(1, g_cheryl, 0, GL_FALSE, 0, GL_READ_ONLY, GL_RGBA32F);
	//glUniform1i(glGetUniformLocation(g_computeProgramHandle, "inTex"), 1); // boxTextureSampler




	// BELOW STUFF IS IMPORTANT!!
	//// We use texture 0, our only texture. Will probably have to be changed in the future
	//// Texture
	//glUniform1i(glGetUniformLocation(g_computeProgramHandle, "fdsgsadf"), g_computeOutputHandle); // destTex
	//glUniform1i(glGetUniformLocation(g_computeProgramHandle, "gdfgs"), g_cheryl); // boxTextureSampler
	//glActiveTexture(GL_TEXTURE0);
	//glBindTexture(GL_TEXTURE_2D, g_computeOutputHandle);
	//
	//glActiveTexture(GL_TEXTURE1);
	//glBindTexture(GL_TEXTURE_2D, g_cheryl);
	//
	//// Send position and direction of camera 
	//glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "cameraPosition"), 1, &g_camera->m_position[0]);
	//glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "cameraDirection"), 1, &g_camera->m_target[0]);
	//// Send in frustum
	//glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "ray00"), 1, &g_camera->m_frustum.ray00[0]);
	//glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "ray10"), 1, &g_camera->m_frustum.ray10[0]);
	//glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "ray11"), 1, &g_camera->m_frustum.ray11[0]);
	//glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "ray01"), 1, &g_camera->m_frustum.ray01[0]);
	//
	//// Send in light positions
	//vector<vec3> t_lightPositions;
	//g_world->GetPointLightInfor(t_lightPositions);
	//if (t_lightPositions.size() > 0)
	//{
	//	glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "lightPositions"), t_lightPositions.size(), &t_lightPositions[0][0]);
	//	glUniform1i(glGetUniformLocation(g_computeProgramHandle, "numLights"), t_lightPositions.size());
	//}
	//
	//vector<vec3> t_diffuseLightingDirection;
	//g_world->GetDiffuseLighting(t_diffuseLightingDirection);
	//if (t_diffuseLightingDirection.size() > 0)
	//{
	//	glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "diffuseLightingDirections"), t_diffuseLightingDirection.size(), &t_diffuseLightingDirection[0][0]);
	//	glUniform1i(glGetUniformLocation(g_computeProgramHandle, "numDiffuseLights"), t_diffuseLightingDirection.size());
	//}
	//// Send in spheres
	//vector<vec3> t_spherePositions;
	//vector<float> t_sphereRadii;
	//vector<vec3> t_sphereColors;
	//g_world->GetSphereInfo(t_spherePositions, t_sphereRadii, t_sphereColors);
	//if (t_spherePositions.size() > 0)
	//{
	//	glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "spherePositions"), t_spherePositions.size(), &t_spherePositions[0][0]);
	//	glUniform1fv(glGetUniformLocation(g_computeProgramHandle, "sphereRadii"), t_sphereRadii.size(), &t_sphereRadii[0]);
	//	glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "spherePositions"), t_spherePositions.size(), &t_spherePositions[0][0]);
	//	glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "sphereColors"), t_sphereColors.size(), &t_sphereColors[0][0]);
	//	glUniform1i(glGetUniformLocation(g_computeProgramHandle, "numSpheres"), t_spherePositions.size());
	//}
	//
	//// Send in triangles
	//vector<vec3> t_trianglePositions;
	//vector<vec3> t_triangleColors;
	//g_world->GetTriangleInfo(t_trianglePositions, t_triangleColors);
	//if (t_trianglePositions.size() > 0)
	//{
	//	glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "trianglePositions"), t_trianglePositions.size(), &t_trianglePositions[0][0]);
	//	glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "triangleColors"), t_triangleColors.size(), &t_triangleColors[0][0]);
	//	glUniform1i(glGetUniformLocation(g_computeProgramHandle, "numTrianglePositions"), t_trianglePositions.size());
	//}

	
	//glActiveTexture(GL_TEXTURE0);
	//glBindTexture(GL_TEXTURE_2D, g_cheryl);

	// BTH ssbo thingies
	//GLuint block_index = 0;
	//block_index = glGetProgramResourceIndex(g_computeProgramHandle, GL_SHADER_STORAGE_BLOCK, "shader_data");
	//GLuint ssbo_binding_point_index = 2;
	//glShaderStorageBlockBinding(g_computeProgramHandle, block_index, ssbo_binding_point_index);

	// Start compute
	glDispatchCompute(1024 / 16, 768 / 16, 1);

	/// END COMPUTE THINGIES

	// Render the results
	glUseProgram(g_renderProgramHandle);	

	glUniform1i(glGetUniformLocation(g_computeProgramHandle, "sourceTexture"), 0);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, g_computeOutputHandle);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glutSwapBuffers();
}

void CreateObjSSBO()
{
	glGenBuffers(1, &g_bthSSBO);
	glBindBuffer(GL_SHADER_STORAGE_BUFFER, g_bthSSBO);
	// Load model to triangles (should be changed, really)
	ModelLoader t_modelLoader;
	vector<Triangle> t_bthTriangles = t_modelLoader.LoadModel("cube.obj");
	// Get triangle corners into its own list
	vector<vec3> t_bthCorners;
	for (size_t i = 0; i < t_bthTriangles.size(); i++)
	{
		for (size_t j = 0; j < 3; j++)
		{
			t_bthCorners.push_back(t_bthTriangles[i].m_corners[j]);
		}
	}

	GLuint block_index = 0;
	block_index = glGetProgramResourceIndex(g_computeProgramHandle, GL_SHADER_STORAGE_BLOCK, "shader_data");
	GLuint ssbo_binding_point_index = 2;
	glShaderStorageBlockBinding(g_computeProgramHandle, block_index, ssbo_binding_point_index);
	
	// Bind data to buffer
	//glBufferData(GL_SHADER_STORAGE_BUFFER, t_bthCorners.size() * sizeof(vec3), &t_bthCorners[0], GL_DYNAMIC_COPY);
	//glBufferData(GL_SHADER_STORAGE_BUFFER, t_bthCorners.size() * sizeof(vec3) - 4, &t_bthCorners[0].y, GL_DYNAMIC_COPY);
	//glBufferData(GL_SHADER_STORAGE_BUFFER, 9*4, &fuckoff2, GL_DYNAMIC_COPY);
	glBufferData(GL_SHADER_STORAGE_BUFFER, t_bthCorners.size() * sizeof(vec3), &t_bthCorners[0], GL_DYNAMIC_COPY);
	glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 2, g_bthSSBO);


	/// Now for texture coordinates
	glGenBuffers(1, &g_textureSSBO);
	glBindBuffer(GL_SHADER_STORAGE_BUFFER, g_textureSSBO);
	// Load model to triangles (should be changed, really)
	// Get triangle corners into its own list
	vector<vec2> t_textureCoordinates;
	for (size_t i = 0; i < t_bthTriangles.size(); i++)
	{
		for (size_t j = 0; j < 3; j++)
		{
			t_textureCoordinates.push_back(t_bthTriangles[i].m_texCoords[j]);
		}
	}

	block_index = 0;
	block_index = glGetProgramResourceIndex(g_computeProgramHandle, GL_SHADER_STORAGE_BLOCK, "texture_data");
	ssbo_binding_point_index = 3;
	glShaderStorageBlockBinding(g_computeProgramHandle, block_index, ssbo_binding_point_index);

	// Bind data to buffer
	glBufferData(GL_SHADER_STORAGE_BUFFER, t_textureCoordinates.size() * sizeof(vec2), &t_textureCoordinates[0], GL_DYNAMIC_COPY);
	glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 3, g_textureSSBO);
}

// Methods to handle keyboard input. Bound to glut callback
void HandleKeyboardInputUp(unsigned char key, int x, int y)
{
	//cout << "up" << endl;
	Input::InputHelper::GetInstance()->UpdateKeyDown(key);
}

void HandleKeyboardInputDown(unsigned char key, int x, int y)
{
	//cout << "down" << endl;
	Input::InputHelper::GetInstance()->UpdateKeyUp(key);
}

// Method to handle mouse input. Bound to glut callback
void HandleMouseMovement(int x, int y)
{
	if (x != g_windowWidth / 2 && y != g_windowheight / 2)
		Input::InputHelper::GetInstance()->WarpMouseToMiddle(x, y);
}

// Method to bind methods to glut callbacks
void InitializeGlutCallbacks()
{
	glutDisplayFunc(RenderScene);
	glutIdleFunc(RenderScene);
	// Keyboard callbacks seem inverted... glut is silly sometimes
	glutKeyboardUpFunc(HandleKeyboardInputDown);
	glutKeyboardFunc(HandleKeyboardInputUp);
	glutPassiveMotionFunc(HandleMouseMovement);
}

// Main method
int main(int argc, char** argv)
{
	//Initialize glut stuff
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA);
	glutInitWindowSize(g_windowWidth, g_windowheight);
	glutInitWindowPosition(100, 100); // Hardcoded. Should be changed
	glutCreateWindow("Raytracer");
	InitializeGlutCallbacks();

	GLenum result = glewInit();
	if (result != GLEW_OK)
	{
		cout << "Error initializing glew";
	}

	glClearColor(0, 0, 0, 0);
	glutSetCursor(GLUT_CURSOR_NONE);

	/// My stuff before starting the main loop
	// Create bth logo buffer
	CreateObjSSBO();

	// Load basic render shader
	vector<ShaderInfo> t_renderShaders;
	t_renderShaders.push_back(ShaderInfo(GL_VERTEX_SHADER, "simpleVertexShader.glsl"));
	t_renderShaders.push_back(ShaderInfo(GL_FRAGMENT_SHADER, "simpleFragmentShader.glsl"));
	g_renderProgramHandle = My_CreateShaderprogram(t_renderShaders);
	// Bind the VB for the draw surface
	My_DEBUGDrawSurfaceVBCreation(g_renderProgramHandle);
	// Load texture for draw surface
	g_computeOutputHandle = My_GenerateTexture();
	// Load texture for box
	glActiveTexture(GL_TEXTURE1);
	g_cheryl = My_LoadTexture("green.png");

	// Load main compute shader
	vector<ShaderInfo> t_computeShaders;
//	t_computeShaders.push_back(ShaderInfo(GL_COMPUTE_SHADER, "ComputeShader.glsl"));
	t_computeShaders.push_back(ShaderInfo(GL_COMPUTE_SHADER, "DebugComputeShader.glsl"));
	g_computeProgramHandle = My_CreateShaderprogram(t_computeShaders);

	// Create the camera
	g_camera = new Camera(vec3(0, 0, 1), vec3(0, 1, 0), vec3(1, -1, -3));
	
	// CreateWorld
	g_world = new World();

	glutMainLoop();


}