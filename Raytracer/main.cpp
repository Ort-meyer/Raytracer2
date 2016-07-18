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


static int turning = 0;


///////////// Global variables (master main)
/// Textures
// Main texture on which raytrace output is stored
GLuint g_textureHandle;

/// Vertex Buffers

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

	// We use texture 0, our only texture. Will probably have to be changed in the future
	glUniform1i(glGetUniformLocation(g_computeProgramHandle, "outputTexture"), g_textureHandle);
	// Send position and direction of camera 
	glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "cameraPosition"), 1, &g_camera->m_position[0]);
	glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "cameraDirection"), 1, &g_camera->m_target[0]);
	// Send in frustum
	glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "ray00"), 1, &g_camera->m_frustum.ray00[0]);
	glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "ray10"), 1, &g_camera->m_frustum.ray10[0]);
	glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "ray11"), 1, &g_camera->m_frustum.ray11[0]);
	glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "ray01"), 1, &g_camera->m_frustum.ray01[0]);

	// Send in light positions
	vector<vec3> t_lightPositions;
	g_world->GetPointLightInfor(t_lightPositions);
	if (t_lightPositions.size() > 0)
	{
		glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "lightPositions"), t_lightPositions.size(), &t_lightPositions[0][0]);
		glUniform1i(glGetUniformLocation(g_computeProgramHandle, "numLights"), t_lightPositions.size());
	}
	// Send in spheres
	vector<vec3> t_spherePositions;
	vector<float> t_sphereRadii;
	g_world->GetSphereInfo(t_spherePositions, t_sphereRadii);
	if (t_spherePositions.size() > 0)
	{
		glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "spherePositions"), t_spherePositions.size(), &t_spherePositions[0][0]);
		glUniform1fv(glGetUniformLocation(g_computeProgramHandle, "sphereRadii"), t_sphereRadii.size(), &t_sphereRadii[0]);
		glUniform1i(glGetUniformLocation(g_computeProgramHandle, "numSpheres"), t_spherePositions.size());
	}

	// Send in triangles
	vector<vec3> t_trianglePositions;
	g_world->GetTriangleInfo(t_trianglePositions);
	if (t_trianglePositions.size() > 0)
	{
		glUniform3fv(glGetUniformLocation(g_computeProgramHandle, "trianglePositions"), t_trianglePositions.size(), &t_trianglePositions[0][0]);
		glUniform1i(glGetUniformLocation(g_computeProgramHandle, "numTriangles"), t_trianglePositions.size());
	}
	// Start compute
	glDispatchCompute(1024 / 16, 768 / 16, 1);

	/// END COMPUTE THINGIES

	// Render the results
	glUseProgram(g_renderProgramHandle);
	glUniform1i(glGetUniformLocation(g_computeProgramHandle, "sourceTexture"), g_textureHandle);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	glutSwapBuffers();
	turning = 0;
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
	// Load basic render shader
	vector<ShaderInfo> t_renderShaders;
	t_renderShaders.push_back(ShaderInfo(GL_VERTEX_SHADER, "simpleVertexShader.glsl"));
	t_renderShaders.push_back(ShaderInfo(GL_FRAGMENT_SHADER, "simpleFragmentShader.glsl"));
	g_renderProgramHandle = My_CreateShaderprogram(t_renderShaders);
	// Bind the VB for the draw surface
	My_DEBUGDrawSurfaceVBCreation(g_renderProgramHandle);
	// Load texture for draw surface
	g_textureHandle = My_GenerateTexture();

	// Load main compute shader
	vector<ShaderInfo> t_computeShaders;
	t_computeShaders.push_back(ShaderInfo(GL_COMPUTE_SHADER, "ComputeShader.glsl"));
	g_computeProgramHandle = My_CreateShaderprogram(t_computeShaders);

	// Create the camera
	g_camera = new Camera(vec3(0, 0, 1), vec3(0, 1, 0), vec3(0, 0, 0));

	// CreateWorld
	g_world = new World();

	glutMainLoop();


}